from typing import Optional
from pydantic import BaseModel

class CourseCreate(BaseModel):
    code: str
    title: str
    description: Optional[str] = None
    target_level: str # e.g. "IELTS 6.5"
    duration_weeks: int = 12
    fee: float = 0.0

class CourseUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    target_level: Optional[str] = None
    duration_weeks: Optional[int] = None
    fee: Optional[float] = None
    is_active: Optional[bool] = None

class CourseResponse(BaseModel):
    id: int
    code: str
    title: str
    description: Optional[str] = None
    target_level: str
    duration_weeks: int
    fee: float
    is_active: bool

    class Config:
        from_attributes = True

