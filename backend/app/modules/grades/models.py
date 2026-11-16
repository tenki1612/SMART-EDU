from sqlalchemy import Column, String, Integer, ForeignKey, Float, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class GradeRecord(Base, TimestampMixin):
    """Quản lý điểm và kết quả học tập (FR-69 -> FR-77)"""
    __tablename__ = "BANG_DIEM"

    id = Column("MaBangDiem", Integer, primary_key=True, index=True, autoincrement=True)
    class_id = Column("MaLopHoc", Integer, ForeignKey("LOP_HOC.MaLopHoc"), nullable=False)
    student_id = Column("MaHocVien", Integer, ForeignKey("HOC_VIEN.MaHocVien"), nullable=False)
    attendance_score = Column("DiemChuyenCan", Float, default=0.0) # Chuyên cần (0-10)
    midterm_score = Column("DiemGiuaKy", Float, default=0.0)    # Điểm giữa kỳ (0-10)
    final_score = Column("DiemCuoiKy", Float, default=0.0)      # Điểm cuối kỳ (0-10)
    total_score = Column("DiemTongKet", Float, default=0.0)      # Tổng kết
    result_status = Column("KetQua", String(50), default="PENDING") # PENDING, PASSED, FAILED (FR-75)
    is_confirmed = Column("DaKhoaSo", Boolean, default=False) # FR-76: Xác nhận kết quả chính thức
    note = Column("GhiChu", Text, nullable=True)

    # Relationships
    enrolled_class = relationship("Class", back_populates="grades")
    student = relationship("Student", back_populates="grades")
