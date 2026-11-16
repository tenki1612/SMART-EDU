from typing import Optional, List
from datetime import datetime, date
from pydantic import BaseModel

class ProgressionCheckRequest(BaseModel):
    student_id: int
    current_course_id: int
    next_course_id: int
    note: Optional[str] = None

class ProgressionResponse(BaseModel):
    id: int
    student_id: int
    student_code: str
    student_name: str
    current_course_id: int
    current_course_title: str
    next_course_id: int
    next_course_title: str
    is_eligible: bool
    is_confirmed: bool
    confirmed_by_name: Optional[str] = None
    confirmed_at: Optional[datetime] = None
    note: Optional[str] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class StudentProgressionRequest(BaseModel):
    next_course_id: int
    current_course_id: Optional[int] = None
    note: Optional[str] = None

class ProgressionRejectRequest(BaseModel):
    reason: Optional[str] = None

class AvailableCourseResponse(BaseModel):
    id: int
    code: str
    title: str
    description: Optional[str] = None
    target_level: Optional[str] = None
    fee: float = 0.0
    tuition_fee: float = 0.0
    duration_weeks: int
    is_current: bool
    is_confirmed: bool = False
    is_pending: bool = False

class ParentWardInfoResponse(BaseModel):
    student_id: int
    student_code: str
    full_name: str
    date_of_birth: Optional[date] = None
    relationship_type: str
    enrolled_courses_count: int
    average_score: Optional[float] = None
    latest_status: str

