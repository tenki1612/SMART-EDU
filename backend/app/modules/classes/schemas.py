from typing import Optional, List
from datetime import date, datetime
from pydantic import BaseModel

class ClassCreate(BaseModel):
    class_code: str
    course_id: int
    teacher_id: Optional[int] = None
    max_capacity: int = 25
    start_date: Optional[date] = None
    end_date: Optional[date] = None

class ClassUpdate(BaseModel):
    teacher_id: Optional[int] = None
    max_capacity: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[str] = None

class ClassRosterStudentItem(BaseModel):
    student_id: int
    student_code: str
    full_name: str
    email: str
    phone: Optional[str] = None
    enrolled_at: datetime
    status: str

class ClassResponse(BaseModel):
    id: int
    class_code: str
    course_id: int
    course_title: Optional[str] = None
    target_level: Optional[str] = None
    teacher_id: Optional[int] = None
    teacher_name: Optional[str] = None
    max_capacity: int
    current_enrolled: int
    is_full: bool
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: str

    class Config:
        from_attributes = True

class AddStudentToClassRequest(BaseModel):
    student_id: int

