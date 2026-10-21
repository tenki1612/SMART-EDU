from typing import Optional, List
from datetime import date, datetime
from pydantic import BaseModel, EmailStr

class StudentCreate(BaseModel):
    username: str
    email: EmailStr
    full_name: str
    password: str
    phone: Optional[str] = None
    date_of_birth: Optional[date] = None
    address: Optional[str] = None

class StudentUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    date_of_birth: Optional[date] = None
    address: Optional[str] = None
    status: Optional[str] = None

class StudentResponse(BaseModel):
    id: int
    user_id: int
    student_code: str
    full_name: str
    email: str
    phone: Optional[str] = None
    date_of_birth: Optional[date] = None
    address: Optional[str] = None
    status: str

    class Config:
        from_attributes = True

class EnrolledClassHistoryItem(BaseModel):
    class_id: int
    class_code: str
    course_title: str
    target_level: str
    enrolled_at: datetime
    class_status: str
    student_class_status: str
    total_score: Optional[float] = None
    result_status: Optional[str] = None

