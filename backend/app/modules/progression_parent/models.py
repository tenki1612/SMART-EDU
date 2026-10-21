from sqlalchemy import Column, String, Integer, ForeignKey, Boolean, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class CourseProgression(Base, TimestampMixin):
    """Kiểm tra điều kiện và chuyển khóa học tiếp theo (FR-78 -> FR-80)"""
    __tablename__ = "course_progressions"

    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    current_course_id = Column(Integer, ForeignKey("courses.id"), nullable=False)
    next_course_id = Column(Integer, ForeignKey("courses.id"), nullable=False)
    is_eligible = Column(Boolean, default=False)       # FR-78: Đủ điều kiện
    is_confirmed = Column(Boolean, default=False)      # FR-79: Nhân viên học vụ xác nhận
    confirmed_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    confirmed_at = Column(DateTime, nullable=True)
    note = Column(Text, nullable=True)

    # Relationships
    student = relationship("Student", back_populates="progressions")
    current_course = relationship("Course", foreign_keys=[current_course_id])
    next_course = relationship("Course", foreign_keys=[next_course_id])
    confirmer = relationship("User", foreign_keys=[confirmed_by])

class ParentStudent(Base, TimestampMixin):
    """Liên kết Phụ huynh và Học viên được giám hộ (FR-81, FR-82)"""
    __tablename__ = "parent_students"

    parent_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    relationship_type = Column(String(50), default="Phụ huynh / Người giám hộ")

    # Relationships
    parent_user = relationship("User", foreign_keys=[parent_user_id], back_populates="parent_links")
    student = relationship("Student", foreign_keys=[student_id], back_populates="parents")

