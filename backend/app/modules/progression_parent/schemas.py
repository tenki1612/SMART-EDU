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

    class Config:
        from_attributes = True

class ParentWardInfoResponse(BaseModel):
    student_id: int
    student_code: str
    full_name: str
    date_of_birth: Optional[date] = None
    relationship_type: str
    enrolled_courses_count: int
    average_score: Optional[float] = None
    latest_status: str

