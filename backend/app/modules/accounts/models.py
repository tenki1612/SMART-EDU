from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, Integer, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin
from app.core.permissions import RoleEnum

class User(Base, TimestampMixin):
    __tablename__ = "users"

    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    full_name = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(SQLEnum(RoleEnum), default=RoleEnum.STUDENT, nullable=False)
    phone = Column(String(20), nullable=True)
    is_active = Column(Boolean, default=True)

    # Security: Login Lockout & Password Reset
    failed_login_attempts = Column(Integer, default=0, nullable=False)
    locked_until = Column(DateTime, nullable=True)
    reset_token = Column(String(100), nullable=True)
    reset_token_expires_at = Column(DateTime, nullable=True)

    # Relationships
    student_profile = relationship("Student", back_populates="user", uselist=False, cascade="all, delete-orphan")
    teacher_profile = relationship("Teacher", back_populates="user", uselist=False, cascade="all, delete-orphan")
    parent_links = relationship("ParentStudent", foreign_keys="ParentStudent.parent_user_id", back_populates="parent_user")

    @property
    def is_locked(self) -> bool:
        """Kiểm tra tài khoản có đang bị khóa (vô hiệu hóa hoặc khóa tạm thời)"""
        if not self.is_active:
            return True
        if self.locked_until:
            now = datetime.now(timezone.utc)
            locked_time = self.locked_until
            if locked_time.tzinfo is None:
                locked_time = locked_time.replace(tzinfo=timezone.utc)
            return locked_time > now
        return False

