from sqlalchemy import Column, String, Integer, ForeignKey, Date, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Class(Base, TimestampMixin):
    __tablename__ = "LOP_HOC"

    id = Column("MaLopHoc", Integer, primary_key=True, index=True, autoincrement=True)
    class_code = Column("MaSoLop", String(50), unique=True, index=True, nullable=False) # ví dụ: IELTS-K26-01
    course_id = Column("MaKhoaHoc", Integer, ForeignKey("KHOA_HOC.MaKhoaHoc"), nullable=False)
    teacher_id = Column("MaGiangVien", Integer, ForeignKey("GIANG_VIEN.MaGiangVien"), nullable=True) # Gán giáo viên cho lớp (FR-39)
    max_capacity = Column("SiSoToiDa", Integer, default=25) # Sức chứa / Sĩ số tối đa (FR-37)
    current_enrolled = Column("SiSoHienTai", Integer, default=0) # Sĩ số hiện tại
    start_date = Column("NgayBatDau", Date, nullable=True)
    end_date = Column("NgayKetThuc", Date, nullable=True)
    status = Column("TrangThai", String(50), default="OPEN_FOR_ENROLLMENT") # PLANNED, OPEN_FOR_ENROLLMENT, IN_PROGRESS, COMPLETED, CANCELLED

    # Relationships
    course = relationship("Course", back_populates="classes")
    teacher = relationship("Teacher", back_populates="classes")
    students = relationship("ClassStudent", back_populates="enrolled_class", cascade="all, delete-orphan")
    schedules = relationship("ScheduleSession", back_populates="session_class", cascade="all, delete-orphan")
    enrollment_requests = relationship("EnrollmentRequest", back_populates="enrolled_class", cascade="all, delete-orphan")
    grades = relationship("GradeRecord", back_populates="enrolled_class", cascade="all, delete-orphan")

class ClassStudent(Base, TimestampMixin):
    """Danh sách học viên trong lớp (FR-38, FR-59)"""
    __tablename__ = "HOC_VIEN_LOP_HOC"

    id = Column("MaHV_LH", Integer, primary_key=True, index=True, autoincrement=True)
    class_id = Column("MaLopHoc", Integer, ForeignKey("LOP_HOC.MaLopHoc"), nullable=False)
    student_id = Column("MaHocVien", Integer, ForeignKey("HOC_VIEN.MaHocVien"), nullable=False)
    enrolled_at = Column("NgayVaoLop", DateTime, default=lambda: datetime.now(timezone.utc))
    status = Column("TrangThaiHoc", String(50), default="ENROLLED") # ENROLLED, DROPPED, COMPLETED

    # Relationships
    enrolled_class = relationship("Class", back_populates="students")
    student = relationship("Student", back_populates="class_enrollments")
