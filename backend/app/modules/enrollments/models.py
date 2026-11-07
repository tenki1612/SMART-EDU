from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class EnrollmentRequest(Base, TimestampMixin):
    """Đăng ký và xét duyệt lớp học (FR-50 -> FR-60)"""
    __tablename__ = "YEU_CAU_DANG_KY"

    id = Column("MaYeuCau", Integer, primary_key=True, index=True, autoincrement=True)
    student_id = Column("MaHocVien", Integer, ForeignKey("HOC_VIEN.MaHocVien"), nullable=False)
    class_id = Column("MaLopHoc", Integer, ForeignKey("LOP_HOC.MaLopHoc"), nullable=False)
    request_date = Column("NgayYeuCau", DateTime, default=lambda: datetime.now(timezone.utc))
    status = Column("TrangThai", String(50), default="PENDING") # PENDING, APPROVED, REJECTED, CANCELLED
    note = Column("GhiChu", Text, nullable=True)
    rejection_reason = Column("LyDoTuChoi", Text, nullable=True) # FR-58: Lý do từ chối
    reviewed_by = Column("MaNguoiDuyet", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung"), nullable=True)
    reviewed_at = Column("NgayDuyet", DateTime, nullable=True)

    # Relationships
    student = relationship("Student", back_populates="enrollment_requests")
    enrolled_class = relationship("Class", back_populates="enrollment_requests")
    reviewer = relationship("User", foreign_keys=[reviewed_by])
