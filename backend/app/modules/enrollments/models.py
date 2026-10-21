from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class EnrollmentRequest(Base, TimestampMixin):
    """Đăng ký và xét duyệt lớp học (FR-50 -> FR-60)"""
    __tablename__ = "enrollment_requests"

    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    request_date = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    status = Column(String(50), default="PENDING") # PENDING, APPROVED, REJECTED, CANCELLED
    note = Column(Text, nullable=True)
    rejection_reason = Column(Text, nullable=True) # FR-58: Lý do từ chối
    reviewed_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    reviewed_at = Column(DateTime, nullable=True)

    # Relationships
    student = relationship("Student", back_populates="enrollment_requests")
    enrolled_class = relationship("Class", back_populates="enrollment_requests")
    reviewer = relationship("User", foreign_keys=[reviewed_by])

