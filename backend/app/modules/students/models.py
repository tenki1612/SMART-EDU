from sqlalchemy import Column, String, Integer, ForeignKey, Date
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Student(Base, TimestampMixin):
    __tablename__ = "HOC_VIEN"

    id = Column("MaHocVien", Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column("MaNguoiDung", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung", ondelete="CASCADE"), unique=True, nullable=False)
    student_code = Column("MaSoHocVien", String(50), unique=True, index=True, nullable=False) # ví dụ: HV2026-001
    date_of_birth = Column("NgaySinh", Date, nullable=True)
    address = Column("DiaChi", String(255), nullable=True)
    status = Column("TrangThai", String(50), default="ACTIVE") # ACTIVE, INACTIVE, SUSPENDED, COMPLETED

    # Relationships
    user = relationship("User", back_populates="student_profile")
    class_enrollments = relationship("ClassStudent", back_populates="student", cascade="all, delete-orphan")
    enrollment_requests = relationship("EnrollmentRequest", back_populates="student", cascade="all, delete-orphan")
    grades = relationship("GradeRecord", back_populates="student", cascade="all, delete-orphan")
    progressions = relationship("CourseProgression", back_populates="student", cascade="all, delete-orphan")
    parents = relationship("ParentStudent", foreign_keys="ParentStudent.student_id", back_populates="student")
