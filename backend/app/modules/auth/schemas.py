from typing import Optional
from pydantic import BaseModel, EmailStr
from app.core.permissions import RoleEnum

class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    username: str
    full_name: str
    role: RoleEnum

class UserInfoResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: str
    role: RoleEnum
    phone: Optional[str] = None
    is_active: bool

    class Config:
        from_attributes = True

class ForgotPasswordRequest(BaseModel):
    identifier: str # Username hoặc Email

class ForgotPasswordResponse(BaseModel):
    identifier: str
    reset_code: str
    expires_in_minutes: int = 15
    message: str

class ResetPasswordRequest(BaseModel):
    identifier: str
    reset_code: str
    new_password: str

class ResetPasswordResponse(BaseModel):
    success: bool = True
    message: str
