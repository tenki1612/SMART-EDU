from typing import Optional, List
from datetime import date
from pydantic import BaseModel, EmailStr

class TeacherCreate(BaseModel):
    username: str
    email: EmailStr
    full_name: str
    password: str
    phone: Optional[str] = None
    specialty: str = "IELTS / TOEIC"
    degree: str = "Bachelor of English"

class TeacherUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    specialty: Optional[str] = None
    degree: Optional[str] = None
    status: Optional[str] = None

class TeacherResponse(BaseModel):
    id: int
    user_id: int
    teacher_code: str
    full_name: str
    email: str
    phone: Optional[str] = None
    specialty: str
    degree: str
    status: str

    class Config:
        from_attributes = True

class TeacherScheduleItem(BaseModel):
    session_id: int
    class_code: str
    course_title: str
    room_code: str
    session_date: date
    start_time: str
    end_time: str
    slot_name: str
    is_confirmed: bool

