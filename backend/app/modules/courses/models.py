from sqlalchemy import Column, String, Integer, Float, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Course(Base, TimestampMixin):
    __tablename__ = "KHOA_HOC"

    id = Column("MaKhoaHoc", Integer, primary_key=True, index=True, autoincrement=True)
    code = Column("MaSoKhoaHoc", String(50), unique=True, index=True, nullable=False) # ví dụ: IELTS-6.5, TOEIC-750
    title = Column("TenKhoaHoc", String(150), nullable=False)
    description = Column("MoTa", Text, nullable=True)
    target_level = Column("TrinhDoMucTieu", String(100), nullable=False) # ví dụ: "IELTS 6.5", "B2 Vstep"
    duration_weeks = Column("ThoiLuongTuan", Integer, default=12)
    fee = Column("HocPhi", Float, default=0.0)
    is_active = Column("TrangThai", Boolean, default=True)

    # Relationships
    classes = relationship("Class", back_populates="course", cascade="all, delete-orphan")
