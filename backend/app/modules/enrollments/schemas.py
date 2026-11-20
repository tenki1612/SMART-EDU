from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel

class EnrollmentCreateRequest(BaseModel):
    class_id: int
    note: Optional[str] = None

class EnrollmentRejectRequest(BaseModel):
    rejection_reason: str

class EnrollmentRequestResponse(BaseModel):
    id: int
    student_id: int
    student_code: Optional[str] = ""
    student_name: Optional[str] = ""
    student_phone: Optional[str] = None
    class_id: int
    class_code: Optional[str] = ""
    course_title: Optional[str] = ""
    target_level: Optional[str] = ""
    request_date: Optional[datetime] = None
    status: str = "PENDING" # PENDING, APPROVED, REJECTED, CANCELLED
    note: Optional[str] = None
    rejection_reason: Optional[str] = None
    reviewed_at: Optional[datetime] = None
    reviewer_name: Optional[str] = None

    class Config:
        from_attributes = True

