from typing import Optional, List
from datetime import date, datetime
from enum import Enum
from pydantic import BaseModel, Field, model_validator

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
    enrolled_at: Optional[datetime] = None
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

class ClassTransferCreateRequest(BaseModel):
    current_class_id: int
    target_class_id: int
    student_id: Optional[int] = None
    reason: Optional[str] = None

class ClassTransferRejectRequest(BaseModel):
    reason: Optional[str] = Field(None, description="Lý do từ chối yêu cầu chuyển lớp")
    rejection_reason: Optional[str] = Field(None, description="Bí danh lý do từ chối")

    @model_validator(mode="before")
    @classmethod
    def validate_rejection_reason(cls, data):
        if isinstance(data, dict):
            val = data.get("reason") or data.get("rejection_reason")
            if not val or not str(val).strip():
                raise ValueError("Lý do từ chối yêu cầu chuyển lớp là bắt buộc.")
            data["reason"] = str(val).strip()
        return data

class ConditionCheckItem(BaseModel):
    code: str
    name: str
    passed: bool
    message: str

class ClassTransferItemResponse(BaseModel):
    id: int
    student_id: int
    student_code: str
    student_name: str
    source_class_id: int
    source_class_code: str
    source_course_title: str
    source_target_level: Optional[str] = None
    target_class_id: int
    target_class_code: str
    target_course_title: str
    target_target_level: Optional[str] = None
    level_relation: str # "SAME_LEVEL", "HIGHER_LEVEL", "LOWER_LEVEL", "UNKNOWN_LEVEL"
    status: str # "PENDING", "APPROVED", "REJECTED"
    reason: Optional[str] = None
    rejection_reason: Optional[str] = None
    request_date: datetime
    reviewed_at: Optional[datetime] = None
    reviewer_name: Optional[str] = None

class ClassTransferDetailResponse(BaseModel):
    id: int
    student_id: int
    student_code: str
    student_name: str
    student_email: Optional[str] = None
    student_phone: Optional[str] = None
    source_class_id: int
    source_class_code: str
    source_course_id: int
    source_course_title: str
    source_target_level: Optional[str] = None
    source_teacher_name: Optional[str] = None
    target_class_id: int
    target_class_code: str
    target_course_id: int
    target_course_title: str
    target_target_level: Optional[str] = None
    target_teacher_name: Optional[str] = None
    target_max_capacity: int
    target_current_enrolled: int
    target_available_slots: int
    target_status: str
    target_schedule_summary: Optional[str] = None
    level_relation: str # "SAME_LEVEL", "HIGHER_LEVEL", "LOWER_LEVEL", "UNKNOWN_LEVEL"
    status: str # "PENDING", "APPROVED", "REJECTED"
    reason: Optional[str] = None
    rejection_reason: Optional[str] = None
    request_date: datetime
    reviewed_at: Optional[datetime] = None
    reviewer_name: Optional[str] = None
    can_approve: bool = False
    checklist: List[ConditionCheckItem] = []

class ClassTransferTargetItem(BaseModel):
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
    status: str
    schedule_summary: Optional[str] = None
    level_relation: Optional[str] = "SAME_LEVEL"
    is_eligible: Optional[bool] = True
    ineligible_reason: Optional[str] = None


