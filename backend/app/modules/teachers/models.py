from sqlalchemy import Column, String, Integer, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Teacher(Base, TimestampMixin):
    __tablename__ = "GIANG_VIEN"

    id = Column("MaGiangVien", Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column("MaNguoiDung", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung", ondelete="CASCADE"), unique=True, nullable=False)
    teacher_code = Column("MaSoGiangVien", String(50), unique=True, index=True, nullable=False) # ví dụ: GV2026-001
    specialty = Column("ChuyenMon", String(100), default="IELTS/TOEIC")
    degree = Column("HocVi", String(100), default="Bachelor of English Linguistics")
    status = Column("TrangThai", String(50), default="ACTIVE") # ACTIVE, ON_LEAVE, INACTIVE

    # Relationships
    user = relationship("User", back_populates="teacher_profile")
    classes = relationship("Class", back_populates="teacher")
    schedules = relationship("ScheduleSession", back_populates="teacher")
