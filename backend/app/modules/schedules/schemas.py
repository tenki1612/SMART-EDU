from typing import Optional, List
from datetime import date
from pydantic import BaseModel

class ScheduleSessionCreate(BaseModel):
    class_id: int
    classroom_id: int
    teacher_id: int
    session_date: date
    start_time: str # e.g. "18:00"
    end_time: str   # e.g. "20:00"
    slot_name: str = "Ca tối (18:00 - 20:00)"

class ScheduleSessionUpdate(BaseModel):
    classroom_id: Optional[int] = None
    teacher_id: Optional[int] = None
    session_date: Optional[date] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    slot_name: Optional[str] = None
    status: Optional[str] = None

class ConflictCheckRequest(BaseModel):
    classroom_id: int
    teacher_id: int
    session_date: date
    start_time: str
    end_time: str
    exclude_session_id: Optional[int] = None

class ConflictCheckResponse(BaseModel):
    has_conflict: bool
    conflict_type: Optional[str] = None # "ROOM_CONFLICT", "TEACHER_CONFLICT", "NONE"
    message: str

class ScheduleSessionResponse(BaseModel):
    id: int
    class_id: int
    class_code: str
    course_title: str
    classroom_id: int
    room_code: str
    teacher_id: int
    teacher_name: str
    session_date: date
    start_time: str
    end_time: str
    slot_name: str
    is_confirmed: bool
    status: str

    class Config:
        from_attributes = True

