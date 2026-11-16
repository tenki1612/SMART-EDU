import secrets
from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session
from app.modules.accounts.models import User
from app.core.security import verify_password, create_access_token, get_password_hash
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.auth.schemas import (
    LoginRequest, RegisterRequest, TokenResponse,
    ForgotPasswordRequest, ForgotPasswordResponse,
    ResetPasswordRequest, ResetPasswordResponse
)

MAX_FAILED_ATTEMPTS = 5
LOCKOUT_MINUTES = 15
RESET_CODE_EXPIRY_MINUTES = 15

class AuthService:
    @staticmethod
    def _check_account_lockout(user: User) -> tuple[bool, int]:
        """Kiểm tra tài khoản có đang bị khóa tạm thời do nhập sai quá 5 lần không"""
        if not user.locked_until:
            return False, 0
        
        now = datetime.now(timezone.utc)
        locked_time = user.locked_until
        if locked_time.tzinfo is None:
            locked_time = locked_time.replace(tzinfo=timezone.utc)
            
        if locked_time > now:
            remaining_seconds = int((locked_time - now).total_seconds())
            remaining_minutes = max(1, (remaining_seconds + 59) // 60)
            return True, remaining_minutes
            
        return False, 0

    @staticmethod
    def authenticate_user(db: Session, creds: LoginRequest) -> TokenResponse:
        # Truy vấn tìm tài khoản bất kể trạng thái is_deleted để phản hồi chính xác lý do lỗi
        user = db.query(User).filter(
            (User.username == creds.username) | (User.email == creds.username)
        ).first()
        
        # 1. Trường hợp tài khoản không tồn tại
        if not user:
            raise BusinessException("Tài khoản không tồn tại trong hệ thống. Vui lòng kiểm tra lại thông tin hoặc đăng ký tài khoản mới.")

        # 2. Trường hợp tài khoản đã bị xóa (Soft-deleted)
        if user.is_deleted:
            raise BusinessException("Tài khoản này đã bị xóa khỏi hệ thống. Vui lòng liên hệ ban quản trị để được hỗ trợ.")

        # 3. Kiểm tra trạng thái hoạt động do Quản trị viên quản trị (Khóa tài khoản)
        if not user.is_active:
            raise BusinessException("Tài khoản của bạn đã bị Quản trị viên khóa hoặc vô hiệu hóa. Vui lòng liên hệ ban quản trị để được hỗ trợ.")

        # 4. Kiểm tra tài khoản có đang bị khóa tạm thời do nhập sai quá 5 lần không
        is_locked, remaining_minutes = AuthService._check_account_lockout(user)
        if is_locked:
            raise BusinessException(
                f"Tài khoản của bạn đã bị khóa tạm thời do nhập sai mật khẩu quá 5 lần. "
                f"Vui lòng thử lại sau {remaining_minutes} phút hoặc liên hệ Quản trị viên để mở khóa ngay."
            )
        
        # Nếu thời gian khóa đã hết thì reset trạng thái
        if user.locked_until is not None:
            user.locked_until = None
            user.failed_login_attempts = 0
            db.commit()

        # 5. Xác thực mật khẩu
        if not verify_password(creds.password, user.hashed_password):
            user.failed_login_attempts = (user.failed_login_attempts or 0) + 1
            
            if user.failed_login_attempts >= MAX_FAILED_ATTEMPTS:
                user.locked_until = datetime.now(timezone.utc) + timedelta(minutes=LOCKOUT_MINUTES)
                db.commit()
                raise BusinessException(
                    f"Bạn đã nhập sai mật khẩu 5 lần. Tài khoản đã bị khóa tạm thời trong {LOCKOUT_MINUTES} phút để bảo mật. Vui lòng thử lại sau."
                )
            else:
                remaining = MAX_FAILED_ATTEMPTS - user.failed_login_attempts
                db.commit()
                raise BusinessException(
                    f"Mật khẩu không chính xác. Bạn còn {remaining} lần thử trước khi tài khoản bị khóa tạm thời."
                )
        
        # Đăng nhập thành công: reset số lần sai và thời gian khóa
        user.failed_login_attempts = 0
        user.locked_until = None
        db.commit()

        token = create_access_token(subject=user.id, role=user.role.value)
        return TokenResponse(
            access_token=token,
            user_id=user.id,
            username=user.username,
            full_name=user.full_name,
            role=user.role,
            avatar_url=user.avatar_url
        )

    @staticmethod
    def register_user(db: Session, req: RegisterRequest) -> TokenResponse:
        """Đăng ký tài khoản mới cho học viên hoặc phụ huynh"""
        from app.core.permissions import RoleEnum
        username = req.username.strip().lower()
        email = req.email.strip().lower()
        full_name = req.full_name.strip()

        if len(username) < 3:
            raise BusinessException("Tên đăng nhập phải có ít nhất 3 ký tự.")

        if len(req.password) < 6:
            raise BusinessException("Mật khẩu phải có tối thiểu 6 ký tự.")

        # Kiểm tra trùng lặp username hoặc email
        existing = db.query(User).filter(
            (User.username == username) | (User.email == email)
        ).first()
        if existing:
            if existing.username == username:
                raise BusinessException("Tên đăng nhập này đã được sử dụng. Vui lòng chọn tên đăng nhập khác.")
            raise BusinessException("Địa chỉ email này đã được sử dụng. Vui lòng chọn email khác.")

        # Vai trò cho phép tự đăng ký: STUDENT hoặc PARENT
        chosen_role = req.role if req.role in [RoleEnum.STUDENT, RoleEnum.PARENT] else RoleEnum.STUDENT

        user = User(
            username=username,
            email=email,
            full_name=full_name,
            hashed_password=get_password_hash(req.password),
            role=chosen_role,
            phone=req.phone.strip() if req.phone else None,
            is_active=True
        )
        db.add(user)
        db.flush()

        # Nếu là học viên thì tự động tạo Student profile
        if chosen_role == RoleEnum.STUDENT:
            from app.modules.students.models import Student
            student = Student(
                user_id=user.id,
                student_code=f"HV{user.id:04d}",
                status="ACTIVE"
            )
            db.add(student)

        db.commit()
        db.refresh(user)

        token = create_access_token(subject=user.id, role=user.role.value)
        return TokenResponse(
            access_token=token,
            user_id=user.id,
            username=user.username,
            full_name=user.full_name,
            role=user.role,
            avatar_url=user.avatar_url
        )

    @staticmethod
    def forgot_password(db: Session, req: ForgotPasswordRequest) -> ForgotPasswordResponse:
        """Tạo mã OTP xác thực khôi phục mật khẩu"""
        identifier = req.identifier.strip()
        user = db.query(User).filter(
            (User.username == identifier) | (User.email == identifier),
            User.is_deleted == False
        ).first()

        if not user:
            raise NotFoundException("Tài khoản người dùng", identifier)

        if not user.is_active:
            raise BusinessException("Tài khoản này đã bị vô hiệu hóa, vui lòng liên hệ bộ phận Học vụ.")

        # Sinh mã OTP 6 chữ số ngẫu nhiên an toàn
        otp_code = f"{secrets.randbelow(900000) + 100000}"
        user.reset_token = otp_code
        user.reset_token_expires_at = datetime.now(timezone.utc) + timedelta(minutes=RESET_CODE_EXPIRY_MINUTES)
        db.commit()

        return ForgotPasswordResponse(
            identifier=identifier,
            reset_code=otp_code,
            expires_in_minutes=RESET_CODE_EXPIRY_MINUTES,
            message=f"Mã OTP khôi phục mật khẩu đã được gửi (Mã demo: {otp_code}). Mã có hiệu lực trong {RESET_CODE_EXPIRY_MINUTES} phút."
        )

    @staticmethod
    def reset_password(db: Session, req: ResetPasswordRequest) -> ResetPasswordResponse:
        """Xác thực mã OTP và đặt mật khẩu mới, đồng thời giải phóng khóa tài khoản"""
        identifier = req.identifier.strip()
        user = db.query(User).filter(
            (User.username == identifier) | (User.email == identifier),
            User.is_deleted == False
        ).first()

        if not user:
            raise NotFoundException("Tài khoản người dùng", identifier)

        if len(req.new_password) < 6:
            raise BusinessException("Mật khẩu mới phải có độ dài tối thiểu 6 ký tự.")

        if not user.reset_token or user.reset_token.strip() != req.reset_code.strip():
            raise BusinessException("Mã xác thực OTP không chính xác.")

        # Kiểm tra hạn sử dụng của mã OTP
        if user.reset_token_expires_at:
            expires_at = user.reset_token_expires_at
            if expires_at.tzinfo is None:
                expires_at = expires_at.replace(tzinfo=timezone.utc)
            if expires_at < datetime.now(timezone.utc):
                raise BusinessException("Mã xác thực OTP đã hết hạn (quá 15 phút). Vui lòng yêu cầu mã mới.")

        # Cập nhật mật khẩu mới và mở khóa tài khoản
        user.hashed_password = get_password_hash(req.new_password)
        user.failed_login_attempts = 0
        user.locked_until = None
        user.reset_token = None
        user.reset_token_expires_at = None
        db.commit()

        return ResetPasswordResponse(
            success=True,
            message="Đặt lại mật khẩu thành công! Tài khoản đã được mở khóa, bạn có thể đăng nhập ngay bằng mật khẩu mới."
        )
