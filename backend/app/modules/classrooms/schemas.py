from typing import Optional
from pydantic import BaseModel

class ClassroomCreate(BaseModel):
    room_code: str
    building: str = "Tòa nhà A"
    capacity: int = 30
    status: str = "AVAILABLE"

class ClassroomUpdate(BaseModel):
    building: Optional[str] = None
    capacity: Optional[int] = None
    status: Optional[str] = None

class ClassroomResponse(BaseModel):
    id: int
    room_code: str
    building: str
    capacity: int
    status: str

    class Config:
        from_attributes = True

