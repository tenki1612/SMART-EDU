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

