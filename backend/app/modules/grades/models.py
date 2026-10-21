from sqlalchemy import Column, String, Integer, ForeignKey, Float, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class GradeRecord(Base, TimestampMixin):
    """Quản lý điểm và kết quả học tập (FR-69 -> FR-77)"""
    __tablename__ = "grade_records"

    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    attendance_score = Column(Float, default=0.0) # Chuyên cần (0-10)
    midterm_score = Column(Float, default=0.0)    # Điểm giữa kỳ (0-10)
    final_score = Column(Float, default=0.0)      # Điểm cuối kỳ (0-10)
    total_score = Column(Float, default=0.0)      # Tổng kết
    result_status = Column(String(50), default="PENDING") # PENDING, PASSED, FAILED (FR-75)
    is_confirmed = Column(Boolean, default=False) # FR-76: Xác nhận kết quả chính thức
    note = Column(Text, nullable=True)

    # Relationships
    enrolled_class = relationship("Class", back_populates="grades")
    student = relationship("Student", back_populates="grades")

