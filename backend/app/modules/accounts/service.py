from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.accounts.models import User
from app.core.security import get_password_hash, verify_password
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.accounts.schemas import UserCreate, UserUpdate, ChangePasswordRequest

class AccountService:
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
            is_active=True
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def change_password(db: Session, user_id: int, req: ChangePasswordRequest) -> bool:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        if not verify_password(req.old_password, user.hashed_password):
            raise BusinessException("Mật khẩu cũ không chính xác.")
        
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
        if data.is_active is not None:
            user.is_active = data.is_active
        
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
        return q.all()

    @staticmethod
    def delete_user(db: Session, user_id: int) -> bool:
        user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
        if not user:
            raise NotFoundException("Người dùng", user_id)
        
        # Soft delete
        user.is_deleted = True
        user.is_active = False
        db.commit()
        return True

