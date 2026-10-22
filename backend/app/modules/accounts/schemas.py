from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, EmailStr
from app.core.permissions import RoleEnum

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    full_name: str
    password: str
    role: RoleEnum
    phone: Optional[str] = None

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None
    is_active: Optional[bool] = None

class RoleUpdateRequest(BaseModel):
    role: RoleEnum

class AdminResetPasswordRequest(BaseModel):
    new_password: str

class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: str
    role: RoleEnum
    phone: Optional[str] = None
    is_active: bool
    failed_login_attempts: int = 0
    locked_until: Optional[datetime] = None
    is_locked: bool = False
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
