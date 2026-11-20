from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field, field_validator

class TicketCreate(BaseModel):
    ticket_type: str = Field(..., description="COMPLAINT (Khiếu nại) hoặc REQUEST (Yêu cầu)")
    receiver_id: Optional[int] = Field(None, description="ID người nhận cụ thể")
    receiver_role: Optional[str] = Field(None, description="Vai trò nhận đơn: ADMIN, ACADEMIC_STAFF, TEACHER, STUDENT")
    category: str = Field("OTHER", description="GRADE, SCHEDULE, ENROLLMENT, OTHER")
    related_class_id: Optional[int] = Field(None, description="ID lớp học liên quan")
    title: str = Field(..., min_length=3, max_length=255, description="Tiêu đề đơn")
    content: str = Field(..., min_length=5, description="Nội dung chi tiết")

    @field_validator("title")
    @classmethod
    def _validate_title(cls, v: str) -> str:
        v = v.strip()
        if len(v) < 3:
            raise ValueError("Tiêu đề không được để trống hoặc quá ngắn (tối thiểu 3 ký tự).")
        return v

    @field_validator("content")
    @classmethod
    def _validate_content(cls, v: str) -> str:
        v = v.strip()
        if len(v) < 5:
            raise ValueError("Nội dung không được để trống hoặc quá ngắn (tối thiểu 5 ký tự).")
        return v

class TicketMessageCreate(BaseModel):
    content: str = Field(..., min_length=1, description="Nội dung phản hồi / trao đổi")

    @field_validator("content")
    @classmethod
    def _validate_message(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Nội dung phản hồi không được để trống.")
        return v

class TicketStatusUpdate(BaseModel):
    status: str = Field(..., description="PENDING, PROCESSING, APPROVED, REJECTED, RESOLVED, CLOSED")
    reason: Optional[str] = Field(None, description="Lý do phê duyệt, từ chối hoặc giải thích kết quả xử lý")

class TicketMessageResponse(BaseModel):
    id: int
    ticket_id: int
    sender_id: int
    sender_name: str
    sender_role: str
    content: str
    created_at: datetime

    class Config:
        from_attributes = True

class TicketResponse(BaseModel):
    id: int
    ticket_code: str
    ticket_type: str
    sender_id: int
    sender_name: str
    sender_role: str
    receiver_id: Optional[int] = None
    receiver_name: Optional[str] = None
    receiver_role: Optional[str] = None
    category: str
    related_class_id: Optional[int] = None
    class_code: Optional[str] = None
    course_title: Optional[str] = None
    teacher_name: Optional[str] = None
    title: str
    content: str
    status: str
    deadline_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    messages_count: int = 0
    current_grade: Optional[dict] = None
    is_grade_locked: Optional[bool] = None

    class Config:
        from_attributes = True

class TicketDetailResponse(TicketResponse):
    messages: List[TicketMessageResponse] = []
