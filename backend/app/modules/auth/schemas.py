from typing import Optional
from pydantic import BaseModel, EmailStr
from app.core.permissions import RoleEnum

class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    full_name: str
    password: str
    phone: Optional[str] = None
    role: RoleEnum = RoleEnum.STUDENT

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    username: str
    full_name: str
    role: RoleEnum
    avatar_url: Optional[str] = None

class UserInfoResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: str
    role: RoleEnum
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    is_active: bool

    class Config:
        from_attributes = True

class ForgotPasswordRequest(BaseModel):
    email: Optional[str] = None # Địa chỉ email đăng ký
    phone: Optional[str] = None # Số điện thoại đăng ký
    identifier: Optional[str] = None # Fallback định danh username/email/phone
    channel: Optional[str] = "BOTH" # "BOTH", "EMAIL", "SMS"

class ForgotPasswordResponse(BaseModel):
    identifier: str
    email: Optional[str] = None
    phone: Optional[str] = None
    channel: str = "BOTH"
    target_masked: str = "" # Ví dụ: "ad***ed@center.edu.vn & 099****777"
    expires_in_minutes: int = 15
    message: str

class ResetPasswordRequest(BaseModel):
    identifier: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    reset_code: str
    new_password: str

class ResetPasswordResponse(BaseModel):
    success: bool = True
    message: str
