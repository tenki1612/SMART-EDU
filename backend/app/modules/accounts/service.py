from typing import List, Optional, Tuple
from sqlalchemy.orm import Session
from app.modules.accounts.models import User
from app.core.security import get_password_hash, verify_password
from app.core.permissions import RoleEnum
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.accounts.schemas import UserCreate, UserUpdate, ChangePasswordRequest
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student

class AccountService:
    @staticmethod
    def _ensure_role_profile(db: Session, user: User, role: RoleEnum):
        """Tự động đồng bộ profile tương ứng (Teacher/Student) nếu chưa có"""
        if role == RoleEnum.TEACHER:
            teacher = db.query(Teacher).filter(Teacher.user_id == user.id).first()
            if not teacher:
                teacher = Teacher(
                    user_id=user.id,
                    teacher_code=f"GV{user.id:04d}",
                    specialty="Giảng viên Ngoại ngữ",
                    degree="Cử nhân Ngôn ngữ Anh",
                    status="ACTIVE"
                )
                db.add(teacher)
            else:
                teacher.status = "ACTIVE"
                teacher.is_deleted = False
        elif role == RoleEnum.STUDENT:
            student = db.query(Student).filter(Student.user_id == user.id).first()
            if not student:
                student = Student(
                    user_id=user.id,
                    student_code=f"HV{user.id:04d}",
                    status="ACTIVE"
                )
                db.add(student)
            else:
                student.status = "ACTIVE"
                student.is_deleted = False

    @staticmethod
    def create_user(db: Session, data: UserCreate) -> User:
        # Check duplicate
        if db.query(User).filter((User.username == data.username) | (User.email == data.email)).first():
            raise BusinessException("Tên đăng nhập hoặc email đã tồn tại trong hệ thống.")
        
        user = User(
            username=data.username,
            email=data.email,
            full_name=data.full_name,
            hashed_password=get_password_hash(data.password),
            role=data.role,
            phone=data.phone,
            avatar_url=data.avatar_url,
            is_active=True
        )
        db.add(user)
        db.flush()
        
        AccountService._ensure_role_profile(db, user, data.role)
        
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def update_user_role(db: Session, user_id: int, new_role: RoleEnum, current_user_id: int) -> User:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        
        # Ngăn ngừa Admin tự hạ quyền nếu không còn Admin nào khác
        if user.id == current_user_id and new_role != RoleEnum.ADMIN:
            active_admins = db.query(User).filter(
                User.role == RoleEnum.ADMIN, 
                User.is_deleted == False, 
                User.is_active == True,
                User.id != user_id
            ).count()
            if active_admins == 0:
                raise BusinessException("Không thể hạ quyền Quản trị viên duy nhất đang hoạt động trong hệ thống.")
        
        user.role = new_role
        AccountService._ensure_role_profile(db, user, new_role)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def toggle_user_lock(db: Session, user_id: int, current_user_id: int) -> Tuple[User, str]:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        
        if user.id == current_user_id:
            raise BusinessException("Quản trị viên không thể tự khóa tài khoản của chính mình.")
        
        # Kiểm tra trạng thái hiện tại (nếu đang bị khóa vì bất kỳ lý do gì: is_active=False hoặc bị lockout)
        if user.is_locked:
            # Mở khóa tài khoản
            user.is_active = True
            user.locked_until = None
            user.failed_login_attempts = 0
            message = f"Đã mở khóa và kích hoạt tài khoản '{user.username}' thành công."
        else:
            # Khóa tài khoản
            user.is_active = False
            message = f"Đã khóa tài khoản '{user.username}'. Người dùng sẽ không thể đăng nhập."
        
        db.commit()
        db.refresh(user)
        return user, message

    @staticmethod
    def admin_reset_password(db: Session, user_id: int, new_password: str) -> bool:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        
        if len(new_password) < 6:
            raise BusinessException("Mật khẩu mới phải có tối thiểu 6 ký tự.")
        
        user.hashed_password = get_password_hash(new_password)
        # Tự động gỡ khóa nếu tài khoản đang bị khóa do nhập sai
        user.failed_login_attempts = 0
        user.locked_until = None
        user.is_active = True
        db.commit()
        return True

    @staticmethod
    def change_password(db: Session, user_id: int, req: ChangePasswordRequest) -> bool:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        if not verify_password(req.old_password, user.hashed_password):
            raise BusinessException("Mật khẩu cũ không chính xác.")
        
        if len(req.new_password) < 6:
            raise BusinessException("Mật khẩu mới phải có ít nhất 6 ký tự.")
            
        user.hashed_password = get_password_hash(req.new_password)
        db.commit()
        return True

    @staticmethod
    def update_user(db: Session, user_id: int, data: UserUpdate) -> User:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        
        if data.email:
            existing = db.query(User).filter(User.email == data.email, User.id != user_id).first()
            if existing:
                raise BusinessException("Email đã được sử dụng bởi tài khoản khác.")
            user.email = data.email
        if data.full_name is not None:
            user.full_name = data.full_name
        if data.phone is not None:
            user.phone = data.phone
        if data.avatar_url is not None:
            user.avatar_url = data.avatar_url
        if data.is_active is not None:
            user.is_active = data.is_active
            if data.is_active:
                user.locked_until = None
                user.failed_login_attempts = 0
        
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def update_user_avatar(db: Session, user_id: int, avatar_url: Optional[str]) -> User:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        user.avatar_url = avatar_url
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def search_users(db: Session, query: Optional[str] = None, role: Optional[str] = None) -> List[User]:
        q = db.query(User).filter(User.is_deleted == False)
        if query:
            q = q.filter((User.username.ilike(f"%{query}%")) | (User.full_name.ilike(f"%{query}%")) | (User.email.ilike(f"%{query}%")))
        if role:
            q = q.filter(User.role == role)
        return q.order_by(User.id.desc()).all()

    @staticmethod
    def delete_user(db: Session, user_id: int, current_user_id: Optional[int] = None) -> bool:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        
        if current_user_id and user.id == current_user_id:
            raise BusinessException("Không thể tự xóa tài khoản đang đăng nhập.")
            
        # Soft delete
        user.is_deleted = True
        user.is_active = False
        db.commit()
        return True
