import os
from datetime import datetime, date, time, timedelta, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.modules.tickets.models import Ticket, TicketMessage
from app.modules.accounts.models import User
from app.modules.classes.models import Class
from app.core.exceptions import BusinessException, NotFoundException, ForbiddenException
from app.modules.tickets.schemas import TicketCreate, TicketMessageCreate, TicketStatusUpdate

# Thời hạn khiếu nại có thể cấu hình thông qua biến môi trường hoặc cấu hình hệ thống (mặc định 7 ngày)
DEFAULT_COMPLAINT_WINDOW_DAYS = int(os.getenv("COMPLAINT_WINDOW_DAYS", "7"))

class TicketService:
    @staticmethod
    def _format_message(m: TicketMessage) -> dict:
        sender = m.sender
        return {
            "id": m.id,
            "ticket_id": m.ticket_id,
            "sender_id": m.sender_id,
            "sender_name": sender.full_name if sender else "Người dùng",
            "sender_role": sender.role if sender else "",
            "content": m.content,
            "created_at": m.created_at
        }

    @staticmethod
    def _format_ticket(t: Ticket, include_messages: bool = False) -> dict:
        sender = t.sender
        receiver = t.receiver
        cls = t.related_class
        data = {
            "id": t.id,
            "ticket_code": t.ticket_code,
            "ticket_type": t.ticket_type,
            "sender_id": t.sender_id,
            "sender_name": sender.full_name if sender else "",
            "sender_role": sender.role if sender else "",
            "receiver_id": t.receiver_id,
            "receiver_name": receiver.full_name if receiver else None,
            "receiver_role": t.receiver_role,
            "category": t.category,
            "related_class_id": t.related_class_id,
            "class_code": cls.class_code if cls else None,
            "title": t.title,
            "content": t.content,
            "status": t.status,
            "deadline_at": t.deadline_at,
            "created_at": t.created_at,
            "updated_at": t.updated_at,
            "messages_count": len(t.messages) if t.messages else 0
        }
        if include_messages:
            data["messages"] = [TicketService._format_message(m) for m in (t.messages or [])]
        return data

    @staticmethod
    def check_complaint_deadline(db: Session, class_id: int) -> dict:
        """Kiểm tra thời hạn gửi khiếu nại cho một lớp học cụ thể"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        
        if not cls.end_date:
            return {"is_expired": False, "deadline_at": None, "message": "Lớp học chưa có ngày kết thúc xác định. Được phép gửi khiếu nại."}

        window_days = DEFAULT_COMPLAINT_WINDOW_DAYS
        # Thời hạn tính theo ngày kết thúc lớp học + window_days
        deadline_date = cls.end_date + timedelta(days=window_days)
        today = date.today()
        is_expired = today > deadline_date

        return {
            "class_id": cls.id,
            "class_code": cls.class_code,
            "end_date": cls.end_date,
            "window_days": window_days,
            "deadline_date": deadline_date,
            "is_expired": is_expired,
            "message": f"Thời hạn khiếu nại là {window_days} ngày kể từ ngày kết thúc lớp ({cls.end_date}). Hạn chót: {deadline_date}." if not is_expired
                       else f"Đã quá thời hạn khiếu nại ({window_days} ngày kể từ khi lớp kết thúc ngày {cls.end_date}). Hạn chót là {deadline_date}."
        }

    @staticmethod
    def create_ticket(db: Session, sender_id: int, data: TicketCreate) -> dict:
        ticket_type = data.ticket_type.upper()
        if ticket_type not in ["COMPLAINT", "REQUEST"]:
            raise BusinessException("Loại đơn không hợp lệ. Chỉ chấp nhận 'COMPLAINT' (Khiếu nại) hoặc 'REQUEST' (Yêu cầu).")

        sender = db.query(User).filter(User.id == sender_id).first()
        if not sender:
            raise NotFoundException("Người gửi", sender_id)

        deadline_at = None
        # Kiểm tra thời hạn đối với đơn KHIẾU NẠI (COMPLAINT)
        if ticket_type == "COMPLAINT" and data.related_class_id:
            cls = db.query(Class).filter(Class.id == data.related_class_id, Class.is_deleted == False).first()
            if not cls:
                raise NotFoundException("Lớp học liên quan", data.related_class_id)
            
            if cls.end_date:
                window_days = DEFAULT_COMPLAINT_WINDOW_DAYS
                deadline_date = cls.end_date + timedelta(days=window_days)
                if date.today() > deadline_date:
                    raise BusinessException(
                        f"Đã quá thời hạn gửi khiếu nại ({window_days} ngày kể từ khi lớp học kết thúc ngày {cls.end_date}). "
                        f"Hạn chót khiếu nại là {deadline_date}. Hệ thống từ chối tiếp nhận đơn khiếu nại mới."
                    )
                deadline_at = datetime.combine(deadline_date, time.max).replace(tzinfo=timezone.utc)

        # Tạo mã đơn sơ bộ
        prefix = "KN" if ticket_type == "COMPLAINT" else "YC"
        temp_code = f"{prefix}-{datetime.now().strftime('%Y%m%d%H%M%S')}"

        ticket = Ticket(
            ticket_code=temp_code,
            ticket_type=ticket_type,
            sender_id=sender_id,
            receiver_id=data.receiver_id,
            receiver_role=data.receiver_role.upper() if data.receiver_role else None,
            category=data.category.upper(),
            related_class_id=data.related_class_id,
            title=data.title.strip(),
            content=data.content.strip(),
            status="PENDING",
            deadline_at=deadline_at
        )
        db.add(ticket)
        db.commit()
        db.refresh(ticket)

        # Định dạng mã chuẩn KN-YYYYMM-XXXX
        official_code = f"{prefix}-{datetime.now().strftime('%Y%m')}-{ticket.id:04d}"
        ticket.ticket_code = official_code
        db.commit()
        db.refresh(ticket)

        return TicketService._format_ticket(ticket, include_messages=True)

    @staticmethod
    def list_sent_tickets(db: Session, sender_id: int) -> List[dict]:
        tickets = db.query(Ticket).filter(
            Ticket.sender_id == sender_id,
            Ticket.is_deleted == False
        ).order_by(Ticket.id.desc()).all()
        return [TicketService._format_ticket(t) for t in tickets]

    @staticmethod
    def list_inbox_tickets(db: Session, user_id: int, user_role: str) -> List[dict]:
        # Hộp thư đến:
        # - Đích danh người nhận (receiver_id == user_id)
        # - Hoặc gửi đến vai trò của user (receiver_role == user_role)
        # - Nếu user là ADMIN, có quyền xem toàn bộ đơn gửi đến trung tâm
        if user_role == "ADMIN":
            tickets = db.query(Ticket).filter(Ticket.is_deleted == False).order_by(Ticket.id.desc()).all()
        else:
            tickets = db.query(Ticket).filter(
                Ticket.is_deleted == False,
                or_(
                    Ticket.receiver_id == user_id,
                    Ticket.receiver_role == user_role
                )
            ).order_by(Ticket.id.desc()).all()
        return [TicketService._format_ticket(t) for t in tickets]

    @staticmethod
    def get_ticket_detail(db: Session, ticket_id: int, user_id: int, user_role: str) -> dict:
        ticket = db.query(Ticket).filter(Ticket.id == ticket_id, Ticket.is_deleted == False).first()
        if not ticket:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        # Kiểm tra quyền xem đơn:
        # Sender, Receiver, Receiver Role, hoặc Admin/Staff
        is_sender = ticket.sender_id == user_id
        is_receiver = ticket.receiver_id == user_id
        is_role_match = ticket.receiver_role and (ticket.receiver_role == user_role)
        is_privileged = user_role in ["ADMIN", "ACADEMIC_STAFF"]

        if not (is_sender or is_receiver or is_role_match or is_privileged):
            raise ForbiddenException("Bạn không có quyền xem chi tiết đơn này.")

        return TicketService._format_ticket(ticket, include_messages=True)

    @staticmethod
    def add_message(db: Session, ticket_id: int, sender_id: int, sender_role: str, data: TicketMessageCreate) -> dict:
        ticket = db.query(Ticket).filter(Ticket.id == ticket_id, Ticket.is_deleted == False).first()
        if not ticket:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        # Kiểm tra quyền gửi phản hồi
        is_sender = ticket.sender_id == sender_id
        is_receiver = ticket.receiver_id == sender_id
        is_role_match = ticket.receiver_role and (ticket.receiver_role == sender_role)
        is_privileged = sender_role in ["ADMIN", "ACADEMIC_STAFF"]

        if not (is_sender or is_receiver or is_role_match or is_privileged):
            raise ForbiddenException("Bạn không có quyền tham gia thảo luận trong đơn này.")

        msg = TicketMessage(
            ticket_id=ticket_id,
            sender_id=sender_id,
            content=data.content.strip()
        )
        db.add(msg)

        # Nếu người phản hồi không phải là người gửi và đơn đang PENDING, tự động chuyển sang PROCESSING
        if not is_sender and ticket.status == "PENDING":
            ticket.status = "PROCESSING"

        ticket.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(msg)
        return TicketService._format_message(msg)

    @staticmethod
    def update_status(db: Session, ticket_id: int, user_id: int, user_role: str, data: TicketStatusUpdate) -> dict:
        ticket = db.query(Ticket).filter(Ticket.id == ticket_id, Ticket.is_deleted == False).first()
        if not ticket:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        valid_statuses = ["PENDING", "PROCESSING", "RESOLVED", "CLOSED"]
        new_status = data.status.upper()
        if new_status not in valid_statuses:
            raise BusinessException(f"Trạng thái '{new_status}' không hợp lệ. Các trạng thái hợp lệ: {', '.join(valid_statuses)}.")

        # Sender có thể đóng đơn (CLOSED). Receiver / Staff / Admin có thể cập nhật mọi trạng thái.
        is_sender = ticket.sender_id == user_id
        is_receiver = ticket.receiver_id == user_id
        is_role_match = ticket.receiver_role and (ticket.receiver_role == user_role)
        is_privileged = user_role in ["ADMIN", "ACADEMIC_STAFF"]

        if not (is_receiver or is_role_match or is_privileged or (is_sender and new_status == "CLOSED")):
            raise ForbiddenException("Bạn không có quyền thay đổi trạng thái đơn này.")

        ticket.status = new_status
        ticket.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(ticket)
        return TicketService._format_ticket(ticket, include_messages=True)
