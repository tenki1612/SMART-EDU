from sqlalchemy import Column, String, Integer, ForeignKey, Date, Time, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class ScheduleSession(Base, TimestampMixin):
    """Thời khóa biểu từng buổi học (FR-61 -> FR-68)"""
    __tablename__ = "BUOI_HOC"

    id = Column("MaBuoiHoc", Integer, primary_key=True, index=True, autoincrement=True)
    class_id = Column("MaLopHoc", Integer, ForeignKey("LOP_HOC.MaLopHoc"), nullable=False)
    classroom_id = Column("MaPhongHoc", Integer, ForeignKey("PHONG_HOC.MaPhongHoc"), nullable=False) # Chọn phòng theo buổi (Ghi chú #7, #9)
    teacher_id = Column("MaGiangVien", Integer, ForeignKey("GIANG_VIEN.MaGiangVien"), nullable=False)
    session_date = Column("NgayHoc", Date, nullable=False)
    start_time = Column("GioBatDau", String(10), nullable=False) # e.g. "18:00"
    end_time = Column("GioKetThuc", String(10), nullable=False)   # e.g. "20:00"
    slot_name = Column("CaHoc", String(100), default="Ca tối (18:00 - 20:00)")
    is_confirmed = Column("DaXacNhan", Boolean, default=False)   # FR-66: Xác nhận thời khóa biểu
    status = Column("TrangThai", String(50), default="SCHEDULED")# SCHEDULED, COMPLETED, CANCELLED

    # Relationships
    session_class = relationship("Class", back_populates="schedules")
    classroom = relationship("Classroom", back_populates="schedules")
    teacher = relationship("Teacher", back_populates="schedules")
