from sqlalchemy import Column, String, Integer, ForeignKey, Boolean, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class CourseProgression(Base, TimestampMixin):
    """Kiểm tra điều kiện và chuyển khóa học tiếp theo (FR-78 -> FR-80)"""
    __tablename__ = "TIEN_TRINH_KHOA_HOC"

    id = Column("MaTienTrinh", Integer, primary_key=True, index=True, autoincrement=True)
    student_id = Column("MaHocVien", Integer, ForeignKey("HOC_VIEN.MaHocVien"), nullable=False)
    current_course_id = Column("MaKhoaHocHienTai", Integer, ForeignKey("KHOA_HOC.MaKhoaHoc"), nullable=False)
    next_course_id = Column("MaKhoaHocTiepTheo", Integer, ForeignKey("KHOA_HOC.MaKhoaHoc"), nullable=False)
    is_eligible = Column("DuDieuKien", Boolean, default=False)       # FR-78: Đủ điều kiện
    is_confirmed = Column("DaXacNhan", Boolean, default=False)      # FR-79: Nhân viên học vụ xác nhận
    confirmed_by = Column("MaNguoiXacNhan", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung"), nullable=True)
    confirmed_at = Column("NgayXacNhan", DateTime, nullable=True)
    note = Column("GhiChu", Text, nullable=True)

    # Relationships
    student = relationship("Student", back_populates="progressions")
    current_course = relationship("Course", foreign_keys=[current_course_id])
    next_course = relationship("Course", foreign_keys=[next_course_id])
    confirmer = relationship("User", foreign_keys=[confirmed_by])

class ParentStudent(Base, TimestampMixin):
    """Liên kết Phụ huynh và Học viên được giám hộ (FR-81, FR-82)"""
    __tablename__ = "PHU_HUYNH_HOC_VIEN"

    id = Column("MaPH_HV", Integer, primary_key=True, index=True, autoincrement=True)
    parent_user_id = Column("MaNguoiDung_PH", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung"), nullable=False)
    student_id = Column("MaHocVien", Integer, ForeignKey("HOC_VIEN.MaHocVien"), nullable=False)
    relationship_type = Column("QuanHe", String(50), default="Phụ huynh / Người giám hộ")

    # Relationships
    parent_user = relationship("User", foreign_keys=[parent_user_id], back_populates="parent_links")
    student = relationship("Student", foreign_keys=[student_id], back_populates="parents")
