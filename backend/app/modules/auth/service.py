from sqlalchemy.orm import Session
from app.modules.accounts.models import User
from app.core.security import verify_password, create_access_token
from app.core.exceptions import BusinessException
from app.modules.auth.schemas import LoginRequest, TokenResponse

class AuthService:
    @staticmethod
    def authenticate_user(db: Session, creds: LoginRequest) -> TokenResponse:
        user = db.query(User).filter(
            (User.username == creds.username) | (User.email == creds.username),
            User.is_deleted == False
        ).first()
        
        if not user or not verify_password(creds.password, user.hashed_password):
            raise BusinessException("Tên đăng nhập hoặc mật khẩu không chính xác.")
        
        if not user.is_active:
            raise BusinessException("Tài khoản của bạn đã bị vô hiệu hóa.")
        
        token = create_access_token(subject=user.id, role=user.role.value)
        return TokenResponse(
            access_token=token,
            user_id=user.id,
            username=user.username,
            full_name=user.full_name,
            role=user.role
        )

