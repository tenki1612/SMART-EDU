from sqlalchemy import Column, String, Integer, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Teacher(Base, TimestampMixin):
    __tablename__ = "teachers"

    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    teacher_code = Column(String(50), unique=True, index=True, nullable=False) # ví dụ: GV2026-001
    specialty = Column(String(100), default="IELTS/TOEIC")
    degree = Column(String(100), default="Bachelor of English Linguistics")
    status = Column(String(50), default="ACTIVE") # ACTIVE, ON_LEAVE, INACTIVE

    # Relationships
    user = relationship("User", back_populates="teacher_profile")
    classes = relationship("Class", back_populates="teacher")
    schedules = relationship("ScheduleSession", back_populates="teacher")

