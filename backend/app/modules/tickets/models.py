from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Text, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Ticket(Base, TimestampMixin):
    """Quản lý Đơn khiếu nại / Đơn yêu cầu giao tiếp nội bộ giữa các vai trò (FR-New)"""
    __tablename__ = "DON_THU"

    id = Column("MaDon", Integer, primary_key=True, index=True, autoincrement=True)
    ticket_code = Column("MaSoDon", String(50), unique=True, index=True, nullable=False) # KN-202611-001 / YC-202611-001
    ticket_type = Column("LoaiDon", String(50), nullable=False) # COMPLAINT (Khiếu nại) | REQUEST (Yêu cầu)
    sender_id = Column("MaNguoiGui", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung"), nullable=False, index=True)
    receiver_id = Column("MaNguoiNhan", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung"), nullable=True, index=True) # Người nhận cụ thể
    receiver_role = Column("VaiTroNguoiNhan", String(50), nullable=True) # Hoặc gửi đến Role (ADMIN, ACADEMIC_STAFF, TEACHER)
    category = Column("LinhVuc", String(50), nullable=False, default="OTHER") # GRADE, SCHEDULE, ENROLLMENT, OTHER
    related_class_id = Column("MaLopHoc", Integer, ForeignKey("LOP_HOC.MaLopHoc"), nullable=True, index=True)
    title = Column("TieuDe", String(255), nullable=False)
    content = Column("NoiDung", Text, nullable=False)
    status = Column("TrangThai", String(50), default="PENDING") # PENDING, PROCESSING, RESOLVED, CLOSED
    deadline_at = Column("HanChotKhieuNai", DateTime, nullable=True) # Hạn chót gửi khiếu nại (chỉ áp dụng COMPLAINT)

    # Relationships
    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])
    related_class = relationship("Class")
    messages = relationship("TicketMessage", back_populates="ticket", cascade="all, delete-orphan", order_by="TicketMessage.id.asc()")

class TicketMessage(Base, TimestampMixin):
    """Nội dung phản hồi / trao đổi trong đơn khiếu nại, yêu cầu"""
    __tablename__ = "DON_THU_PHAN_HOI"

    id = Column("MaPhanHoi", Integer, primary_key=True, index=True, autoincrement=True)
    ticket_id = Column("MaDon", Integer, ForeignKey("DON_THU.MaDon"), nullable=False, index=True)
    sender_id = Column("MaNguoiGui", Integer, ForeignKey("NGUOI_DUNG.MaNguoiDung"), nullable=False)
    content = Column("NoiDung", Text, nullable=False)

    # Relationships
    ticket = relationship("Ticket", back_populates="messages")
    sender = relationship("User")
