from sqlalchemy import Column, String, Integer, ForeignKey, Date, Time, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class ScheduleSession(Base, TimestampMixin):
    """Thời khóa biểu từng buổi học (FR-61 -> FR-68)"""
    __tablename__ = "schedule_sessions"

    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    classroom_id = Column(Integer, ForeignKey("classrooms.id"), nullable=False) # Chọn phòng theo buổi (Ghi chú #7, #9)
    teacher_id = Column(Integer, ForeignKey("teachers.id"), nullable=False)
    session_date = Column(Date, nullable=False)
    start_time = Column(String(10), nullable=False) # e.g. "18:00"
    end_time = Column(String(10), nullable=False)   # e.g. "20:00"
    slot_name = Column(String(50), default="Ca tối (18:00 - 20:00)")
    is_confirmed = Column(Boolean, default=False)   # FR-66: Xác nhận thời khóa biểu
    status = Column(String(50), default="SCHEDULED")# SCHEDULED, COMPLETED, CANCELLED

    # Relationships
    session_class = relationship("Class", back_populates="schedules")
    classroom = relationship("Classroom", back_populates="schedules")
    teacher = relationship("Teacher", back_populates="schedules")

