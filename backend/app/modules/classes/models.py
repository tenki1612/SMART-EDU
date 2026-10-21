from sqlalchemy import Column, String, Integer, ForeignKey, Date, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Class(Base, TimestampMixin):
    __tablename__ = "classes"

    class_code = Column(String(50), unique=True, index=True, nullable=False) # ví dụ: IELTS-K26-01
    course_id = Column(Integer, ForeignKey("courses.id"), nullable=False)
    teacher_id = Column(Integer, ForeignKey("teachers.id"), nullable=True) # Gán giáo viên cho lớp (FR-39)
    max_capacity = Column(Integer, default=25) # Sức chứa / Sĩ số tối đa (FR-37)
    current_enrolled = Column(Integer, default=0) # Sĩ số hiện tại
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    status = Column(String(50), default="OPEN_FOR_ENROLLMENT") # PLANNED, OPEN_FOR_ENROLLMENT, IN_PROGRESS, COMPLETED, CANCELLED

    # Relationships
    course = relationship("Course", back_populates="classes")
    teacher = relationship("Teacher", back_populates="classes")
    students = relationship("ClassStudent", back_populates="enrolled_class", cascade="all, delete-orphan")
    schedules = relationship("ScheduleSession", back_populates="session_class", cascade="all, delete-orphan")
    enrollment_requests = relationship("EnrollmentRequest", back_populates="enrolled_class", cascade="all, delete-orphan")
    grades = relationship("GradeRecord", back_populates="enrolled_class", cascade="all, delete-orphan")

class ClassStudent(Base, TimestampMixin):
    """Danh sách học viên trong lớp (FR-38, FR-59)"""
    __tablename__ = "class_students"

    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    enrolled_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    status = Column(String(50), default="ENROLLED") # ENROLLED, DROPPED, COMPLETED

    # Relationships
    enrolled_class = relationship("Class", back_populates="students")
    student = relationship("Student", back_populates="class_enrollments")

