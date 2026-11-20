from typing import Optional, List
from datetime import date, datetime
from enum import Enum
from pydantic import BaseModel, Field

class ClassStatusEnum(str, Enum):
    PLANNING = "PLANNING"
    OPEN_FOR_ENROLLMENT = "OPEN_FOR_ENROLLMENT"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"

class ClassCreate(BaseModel):
    class_code: str
    course_id: int
    teacher_id: Optional[int] = None
    max_capacity: int = Field(default=25, ge=1, le=500)
    opening_date: Optional[date] = None # Thời gian mở lớp
    start_date: Optional[date] = None   # Thời gian bắt đầu học thực tế
    end_date: Optional[date] = None

class ClassUpdate(BaseModel):
    teacher_id: Optional[int] = None
    max_capacity: Optional[int] = Field(default=None, ge=1, le=500)
    opening_date: Optional[date] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[ClassStatusEnum] = None

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
    is_enrolled: Optional[bool] = False
    opening_date: Optional[date] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: str

    class Config:
        from_attributes = True

class AddStudentToClassRequest(BaseModel):
    student_id: int

class ClassTransferRequest(BaseModel):
    current_class_id: int
    target_class_id: int
    student_id: Optional[int] = None # Dành cho Admin/Staff chỉ định học viên, nếu là Student thì tự động lấy từ phiên đăng nhập
    reason: Optional[str] = None

class ClassTransferTargetItem(BaseModel):
    id: int
    class_code: str
    course_id: int
    course_title: Optional[str] = None
    teacher_id: Optional[int] = None
    teacher_name: Optional[str] = None
    max_capacity: int
    current_enrolled: int
    is_full: bool
    status: str
    schedule_summary: Optional[str] = None


