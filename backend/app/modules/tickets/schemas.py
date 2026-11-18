from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

class TicketCreate(BaseModel):
    ticket_type: str = Field(..., description="COMPLAINT (Khiếu nại) hoặc REQUEST (Yêu cầu)")
    receiver_id: Optional[int] = Field(None, description="ID người nhận cụ thể")
    receiver_role: Optional[str] = Field(None, description="Vai trò nhận đơn: ADMIN, ACADEMIC_STAFF, TEACHER, STUDENT")
    category: str = Field("OTHER", description="GRADE, SCHEDULE, ENROLLMENT, OTHER")
    related_class_id: Optional[int] = Field(None, description="ID lớp học liên quan")
    title: str = Field(..., min_length=3, max_length=255, description="Tiêu đề đơn")
    content: str = Field(..., min_length=5, description="Nội dung chi tiết")

class TicketMessageCreate(BaseModel):
    content: str = Field(..., min_length=1, description="Nội dung phản hồi / trao đổi")

class TicketStatusUpdate(BaseModel):
    status: str = Field(..., description="PENDING, PROCESSING, RESOLVED, CLOSED")

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
    title: str
    content: str
    status: str
    deadline_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    messages_count: int = 0

    class Config:
        from_attributes = True

class TicketDetailResponse(TicketResponse):
    messages: List[TicketMessageResponse] = []
