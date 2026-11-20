import os
import uuid
import math
from datetime import datetime, date, time, timedelta, timezone
from typing import List, Optional, Union, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_

from app.modules.tickets.models import Ticket, TicketMessage
from app.modules.accounts.models import User
from app.modules.classes.models import Class, ClassStudent
from app.modules.students.models import Student
from app.modules.teachers.models import Teacher
from app.modules.grades.models import GradeRecord
from app.core.exceptions import BusinessException, NotFoundException, ForbiddenException
from app.modules.tickets.schemas import TicketCreate, TicketMessageCreate, TicketStatusUpdate
from app.core.permissions import RoleEnum

# Thời hạn khiếu nại có thể cấu hình thông qua biến môi trường hoặc cấu hình hệ thống (mặc định 7 ngày)
DEFAULT_COMPLAINT_WINDOW_DAYS = int(os.getenv("COMPLAINT_WINDOW_DAYS", "7"))

class TicketService:
    SCORE_COMPLAINT_CATEGORIES = {"GRADE", "GRADE_COMPLAINT"}
    UNLOCK_REQUEST_CATEGORIES = {"GRADE_UNLOCK", "UNLOCK_GRADE"}
    VALID_STUDENT_CATEGORIES = {"GRADE", "SCHEDULE", "ENROLLMENT", "OTHER"}
    VALID_TEACHER_CATEGORIES = {"GRADE_UNLOCK", "SCHEDULE", "OTHER"}

    @staticmethod
    def is_score_complaint(ticket_or_type, category: Optional[str] = None) -> bool:
        """
        Quy tắc phân loại khiếu nại điểm thống nhất (F-01):
        - Bất kỳ đơn có ticket_type == COMPLAINT
        - Hoặc category thuộc nhóm SCORE_COMPLAINT_CATEGORIES (GRADE, GRADE_COMPLAINT) bất kể ticket_type
        - Tuyệt đối không phân loại GRADE_UNLOCK / UNLOCK_GRADE thành khiếu nại điểm.
        """
        if hasattr(ticket_or_type, "ticket_type"):
            t_type = (ticket_or_type.ticket_type or "").upper()
            cat = (ticket_or_type.category or "").upper()
        elif isinstance(ticket_or_type, dict):
            t_type = (ticket_or_type.get("ticket_type") or "").upper()
            cat = (ticket_or_type.get("category") or "").upper()
        else:
            t_type = (str(ticket_or_type) or "").upper()
            cat = (str(category) or "").upper() if category else ""

        if cat in TicketService.UNLOCK_REQUEST_CATEGORIES:
            return False
        if t_type == "COMPLAINT":
            return True
        if cat in TicketService.SCORE_COMPLAINT_CATEGORIES:
            return True
        return False

    @staticmethod
    def is_unlock_request(ticket) -> bool:
        """
        Xác định đơn yêu cầu mở sổ điểm chính xác (F-02), loại bỏ hoàn toàn heuristic category == GRADE:
        1. ticket_type == REQUEST
        2. category thuộc UNLOCK_REQUEST_CATEGORIES (GRADE_UNLOCK, UNLOCK_GRADE)
        """
        if hasattr(ticket, "ticket_type"):
            t_type = (ticket.ticket_type or "").upper()
            cat = (ticket.category or "").upper()
        elif isinstance(ticket, dict):
            t_type = (ticket.get("ticket_type") or "").upper()
            cat = (ticket.get("category") or "").upper()
        else:
            return False
        return t_type == "REQUEST" and cat in TicketService.UNLOCK_REQUEST_CATEGORIES

    @staticmethod
    def _format_message(m: TicketMessage) -> dict:
        sender = m.sender
        sender_role = ""
        if sender:
            sender_role = sender.role.value if hasattr(sender.role, 'value') else str(sender.role)
        return {
            "id": m.id,
            "ticket_id": m.ticket_id,
            "sender_id": m.sender_id,
            "sender_name": sender.full_name if sender else "Người dùng",
            "sender_role": sender_role,
            "content": m.content,
            "created_at": m.created_at
        }

    @staticmethod
    def _format_ticket(db: Optional[Session], t: Ticket, include_messages: bool = False) -> dict:
        sender = t.sender
        receiver = t.receiver
        cls = t.related_class

        course_title = cls.course.title if (cls and cls.course) else None
        teacher_name = cls.teacher.user.full_name if (cls and cls.teacher and cls.teacher.user) else None

        current_grade = None
        is_grade_locked = None

        if db and t.related_class_id:
            # Nếu là khiếu nại điểm hoặc đơn liên quan đến điểm của học viên
            if t.category in ["GRADE", "GRADE_COMPLAINT"] or t.ticket_type == "COMPLAINT":
                stu = db.query(Student).filter(Student.user_id == t.sender_id, Student.is_deleted == False).first()
                if stu:
                    gr = db.query(GradeRecord).filter(
                        GradeRecord.class_id == t.related_class_id,
                        GradeRecord.student_id == stu.id,
                        GradeRecord.is_deleted == False
                    ).first()
                    if gr:
                        current_grade = {
                            "attendance_score": gr.attendance_score,
                            "midterm_score": gr.midterm_score,
                            "final_score": gr.final_score,
                            "total_score": gr.total_score,
                            "result_status": gr.result_status
                        }

            # Kiểm tra trạng thái khóa sổ điểm của lớp
            if cls:
                from app.modules.grades.service import GradeService
                try:
                    is_grade_locked, _ = GradeService.check_and_update_class_grade_lock(db, cls)
                except Exception:
                    is_grade_locked = None

        sender_role = ""
        if sender:
            sender_role = sender.role.value if hasattr(sender.role, 'value') else str(sender.role)

        data = {
            "id": t.id,
            "ticket_code": t.ticket_code,
            "ticket_type": t.ticket_type,
            "sender_id": t.sender_id,
            "sender_name": sender.full_name if sender else "",
            "sender_role": sender_role,
            "receiver_id": t.receiver_id,
            "receiver_name": receiver.full_name if receiver else None,
            "receiver_role": t.receiver_role,
            "category": t.category,
            "related_class_id": t.related_class_id,
            "class_code": cls.class_code if cls else None,
            "course_title": course_title,
            "teacher_name": teacher_name,
            "current_grade": current_grade,
            "is_grade_locked": is_grade_locked,
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
    def create_ticket(db: Session, sender_id: int, sender_role: str, data: TicketCreate) -> dict:
        ticket_type = data.ticket_type.upper()
        if ticket_type not in ["COMPLAINT", "REQUEST"]:
            raise BusinessException("Loại đơn không hợp lệ. Chỉ chấp nhận 'COMPLAINT' (Khiếu nại) hoặc 'REQUEST' (Yêu cầu).")

        sender = db.query(User).filter(User.id == sender_id).first()
        if not sender:
            raise NotFoundException("Người gửi", sender_id)

        role_str = sender_role or (sender.role.value if hasattr(sender.role, 'value') else str(sender.role))
        category_upper = data.category.upper() if data.category else "OTHER"

        # QUY TẮC BẮT BUỘC: Admin và Academic Staff KHÔNG CÓ QUYỀN tạo đơn mới
        if role_str in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]:
            raise ForbiddenException("Quản trị viên và Nhân viên học vụ không có quyền tạo đơn mới.")

        deadline_at = None
        receiver_id = data.receiver_id
        receiver_role = data.receiver_role.upper() if data.receiver_role else None
        related_class_id = data.related_class_id

        # --- 1. NGHIỆP VỤ HỌC VIÊN (STUDENT) ---
        if role_str == RoleEnum.STUDENT.value:
            # Học viên KHÔNG được tạo yêu cầu mở sổ điểm (F-02, F-03)
            if category_upper in TicketService.UNLOCK_REQUEST_CATEGORIES or "mở sổ" in data.title.lower() or "mở điểm" in data.title.lower():
                raise ForbiddenException("Học viên không có quyền tạo yêu cầu mở sổ điểm.")

            # Kiểm tra danh mục hợp lệ cho Học viên (F-03)
            if category_upper not in TicketService.VALID_STUDENT_CATEGORIES:
                raise BusinessException(
                    f"Danh mục '{data.category}' không hợp lệ cho học viên. Danh mục hợp lệ: {', '.join(sorted(TicketService.VALID_STUDENT_CATEGORIES))}."
                )

            # Chặn học viên ngụy tạo khiếu nại điểm dưới dạng REQUEST (F-03)
            if ticket_type == "REQUEST" and category_upper in TicketService.SCORE_COMPLAINT_CATEGORIES:
                raise BusinessException("Khiếu nại về điểm số phải được gửi dưới dạng Đơn khiếu nại (COMPLAINT), không được gửi dưới dạng Đơn yêu cầu (REQUEST).")

            # Nếu là khiếu nại điểm số (COMPLAINT hoặc category GRADE)
            if TicketService.is_score_complaint(ticket_type, category_upper):
                # Kiểm tra chặn gửi khiếu nại điểm trực tiếp đến Admin hoặc Academic Staff (F-03)
                if data.receiver_role and data.receiver_role.upper() in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]:
                    raise BusinessException("Khiếu nại điểm phải được gửi đến giảng viên phụ trách lớp, không được gửi trực tiếp đến Quản trị viên hoặc Nhân viên học vụ.")

                if data.receiver_id:
                    target_rx = db.query(User).filter(User.id == data.receiver_id).first()
                    if target_rx:
                        target_rx_role = target_rx.role.value if hasattr(target_rx.role, 'value') else str(target_rx.role)
                        if target_rx_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]:
                            raise BusinessException("Khiếu nại điểm phải được gửi đến giảng viên phụ trách lớp, không được gửi trực tiếp đến Quản trị viên hoặc Nhân viên học vụ.")

                if not related_class_id:
                    raise BusinessException("Khiếu nại điểm phải gắn liền với một lớp học phần cụ thể.")

                cls = db.query(Class).filter(Class.id == related_class_id, Class.is_deleted == False).first()
                if not cls:
                    raise NotFoundException("Lớp học", related_class_id)

                # Kiểm tra thời hạn khiếu nại (mặc định 7 ngày sau khi kết thúc lớp) trước tiên
                if cls.end_date:
                    window_days = DEFAULT_COMPLAINT_WINDOW_DAYS
                    deadline_date = cls.end_date + timedelta(days=window_days)
                    if date.today() > deadline_date:
                        raise BusinessException(
                            f"Đã quá thời hạn gửi khiếu nại ({window_days} ngày kể từ khi lớp học kết thúc ngày {cls.end_date}). "
                            f"Hạn chót khiếu nại là {deadline_date}. Hệ thống từ chối tiếp nhận đơn khiếu nại mới."
                        )
                    deadline_at = datetime.combine(deadline_date, time.max).replace(tzinfo=timezone.utc)

                # Kiểm tra học viên có thực sự tham gia lớp học này không
                student = db.query(Student).filter(Student.user_id == sender_id, Student.is_deleted == False).first()
                if not student:
                    raise BusinessException("Không tìm thấy hồ sơ học viên của tài khoản này.")

                enrollment = db.query(ClassStudent).filter(
                    ClassStudent.class_id == related_class_id,
                    ClassStudent.student_id == student.id,
                    ClassStudent.is_deleted == False
                ).first()
                if not enrollment:
                    raise BusinessException("Học viên chỉ có thể gửi khiếu nại điểm cho lớp học phần mà mình đã tham gia.")

                # Tự động gán người nhận là Giảng viên phụ trách lớp
                if not cls.teacher or not cls.teacher.user_id:
                    raise BusinessException("Lớp học chưa được phân công giảng viên phụ trách.")
                receiver_id = cls.teacher.user_id
                receiver_role = RoleEnum.TEACHER.value
                category_upper = "GRADE"

        # --- 2. NGHIỆP VỤ GIẢNG VIÊN (TEACHER) ---
        elif role_str == RoleEnum.TEACHER.value:
            if category_upper not in TicketService.VALID_TEACHER_CATEGORIES:
                raise BusinessException(
                    f"Danh mục '{data.category}' không hợp lệ cho giảng viên. Danh mục hợp lệ: {', '.join(sorted(TicketService.VALID_TEACHER_CATEGORIES))}."
                )

            # Giảng viên KHÔNG được tạo khiếu nại điểm
            if TicketService.is_score_complaint(ticket_type, category_upper):
                raise BusinessException("Giảng viên không được tạo khiếu nại điểm số.")

            # Giảng viên tạo yêu cầu mở sổ điểm
            if category_upper in TicketService.UNLOCK_REQUEST_CATEGORIES:
                if ticket_type != "REQUEST":
                    raise BusinessException("Yêu cầu mở sổ điểm phải là Đơn yêu cầu (REQUEST).")
                if not related_class_id:
                    raise BusinessException("Yêu cầu mở sổ điểm phải chọn lớp học phần cần mở.")

                teacher = db.query(Teacher).filter(Teacher.user_id == sender_id, Teacher.is_deleted == False).first()
                if not teacher:
                    raise BusinessException("Không tìm thấy thông tin giảng viên của tài khoản này.")

                cls = db.query(Class).filter(Class.id == related_class_id, Class.is_deleted == False).first()
                if not cls:
                    raise NotFoundException("Lớp học", related_class_id)

                if cls.teacher_id != teacher.id:
                    raise ForbiddenException("Giảng viên chỉ có thể yêu cầu mở sổ điểm cho lớp do mình phụ trách.")

                # Kiểm tra xem sổ điểm có đang thực sự bị khóa không
                from app.modules.grades.service import GradeService
                is_locked, lock_msg = GradeService.check_and_update_class_grade_lock(db, cls)
                if not is_locked:
                    raise BusinessException("Sổ điểm của lớp học này hiện đang mở, không cần gửi yêu cầu mở lại.")

                category_upper = "GRADE_UNLOCK"
                receiver_role = RoleEnum.ACADEMIC_STAFF.value

        # --- 3. CÁC ROLE HOẶC LOẠI ĐƠN KHÁC ---
        else:
            if ticket_type == "COMPLAINT" and related_class_id:
                cls = db.query(Class).filter(Class.id == related_class_id, Class.is_deleted == False).first()
                if cls and cls.end_date:
                    window_days = DEFAULT_COMPLAINT_WINDOW_DAYS
                    deadline_date = cls.end_date + timedelta(days=window_days)
                    if date.today() > deadline_date:
                        raise BusinessException(
                            f"Đã quá thời hạn gửi khiếu nại ({window_days} ngày kể từ khi lớp học kết thúc ngày {cls.end_date}). "
                            f"Hạn chót khiếu nại là {deadline_date}. Hệ thống từ chối tiếp nhận đơn khiếu nại mới."
                        )
                    deadline_at = datetime.combine(deadline_date, time.max).replace(tzinfo=timezone.utc)

        # Tạo mã tạm duy nhất trong transaction, sau đó thay bằng mã chính thức
        # dựa trên khóa chính. Không commit mã tạm (tránh đụng unique khi 2 đơn
        # được tạo đồng thời trong cùng một giây - F-11).
        prefix = "KN" if ticket_type == "COMPLAINT" else "YC"
        temp_code = f"{prefix}-TMP-{uuid.uuid4().hex[:12].upper()}"

        ticket = Ticket(
            ticket_code=temp_code,
            ticket_type=ticket_type,
            sender_id=sender_id,
            receiver_id=receiver_id,
            receiver_role=receiver_role,
            category=category_upper,
            related_class_id=related_class_id,
            title=data.title.strip(),
            content=data.content.strip(),
            status="PENDING",
            deadline_at=deadline_at
        )
        db.add(ticket)
        db.flush()

        # Định dạng mã chuẩn KN-YYYYMM-XXXX
        official_code = f"{prefix}-{datetime.now().strftime('%Y%m')}-{ticket.id:04d}"
        ticket.ticket_code = official_code
        db.commit()
        db.refresh(ticket)

        return TicketService._format_ticket(db, ticket, include_messages=True)

    @staticmethod
    def list_sent_tickets(
        db: Session,
        sender_id: int,
        user_role: str = "",
        page: Optional[int] = None,
        limit: Optional[int] = None,
        q: Optional[str] = None,
        category: Optional[str] = None,
        status: Optional[str] = None,
        ticket_type: Optional[str] = None
    ):
        query = db.query(Ticket).filter(
            Ticket.sender_id == sender_id,
            Ticket.is_deleted == False
        )

        # ADMIN và ACADEMIC_STAFF tuyệt đối không có khiếu nại điểm (F-01, F-04)
        if user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]:
            query = query.filter(
                Ticket.ticket_type != "COMPLAINT",
                ~Ticket.category.in_(TicketService.SCORE_COMPLAINT_CATEGORIES)
            )

        if ticket_type and ticket_type.strip() and ticket_type.upper() != "ALL":
            tt = ticket_type.strip().upper()
            if user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"] and tt == "COMPLAINT":
                query = query.filter(Ticket.id == -1)
            else:
                query = query.filter(Ticket.ticket_type == tt)

        if category and category.strip() and category.upper() != "ALL":
            cat = category.strip().upper()
            if user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"] and cat in TicketService.SCORE_COMPLAINT_CATEGORIES:
                query = query.filter(Ticket.id == -1)
            elif cat in TicketService.UNLOCK_REQUEST_CATEGORIES:
                query = query.filter(Ticket.category.in_(TicketService.UNLOCK_REQUEST_CATEGORIES))
            else:
                query = query.filter(Ticket.category == cat)

        if status and status.strip() and status.upper() != "ALL":
            query = query.filter(Ticket.status == status.strip().upper())

        if q and q.strip():
            term = f"%{q.strip()}%"
            query = query.filter(or_(
                Ticket.ticket_code.ilike(term),
                Ticket.title.ilike(term),
                Ticket.content.ilike(term)
            ))

        query = query.order_by(Ticket.id.desc())

        # Phân trang phía server (F-06)
        if page is not None or limit is not None:
            p = max(1, page or 1)
            l = min(100, max(1, limit or 20))
            total = query.count()
            total_pages = math.ceil(total / l) if total > 0 else 1
            items = query.offset((p - 1) * l).limit(l).all()
            return {
                "items": [TicketService._format_ticket(db, t) for t in items],
                "total": total,
                "page": p,
                "limit": l,
                "total_pages": total_pages
            }

        items = query.all()
        return [TicketService._format_ticket(db, t) for t in items]

    @staticmethod
    def list_inbox_tickets(
        db: Session,
        user_id: int,
        user_role: str,
        page: Optional[int] = None,
        limit: Optional[int] = None,
        q: Optional[str] = None,
        category: Optional[str] = None,
        status: Optional[str] = None,
        ticket_type: Optional[str] = None
    ):
        query = db.query(Ticket).filter(Ticket.is_deleted == False)

        # 1. Scoping theo vai trò (F-01, F-04)
        if user_role == RoleEnum.ADMIN.value:
            # ADMIN chỉ xem Đơn yêu cầu (REQUEST), KHÔNG xem khiếu nại điểm (COMPLAINT / GRADE)
            # Chỉ thấy đơn gửi riêng cho Admin hoặc các yêu cầu mở sổ điểm
            query = query.filter(
                Ticket.ticket_type != "COMPLAINT",
                ~Ticket.category.in_(TicketService.SCORE_COMPLAINT_CATEGORIES),
                or_(
                    Ticket.receiver_id == user_id,
                    Ticket.receiver_role == RoleEnum.ADMIN.value,
                    Ticket.category.in_(TicketService.UNLOCK_REQUEST_CATEGORIES)
                )
            )
        elif user_role in [RoleEnum.ACADEMIC_STAFF.value, "STAFF"]:
            # ACADEMIC_STAFF chỉ xem Đơn yêu cầu (REQUEST), KHÔNG xem khiếu nại điểm
            query = query.filter(
                Ticket.ticket_type != "COMPLAINT",
                ~Ticket.category.in_(TicketService.SCORE_COMPLAINT_CATEGORIES),
                or_(
                    Ticket.receiver_id == user_id,
                    Ticket.receiver_role.in_([RoleEnum.ACADEMIC_STAFF.value, "STAFF"]),
                    Ticket.category.in_(TicketService.UNLOCK_REQUEST_CATEGORIES)
                )
            )
        elif user_role == RoleEnum.TEACHER.value:
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            teacher_class_ids = []
            if teacher:
                cls_rows = db.query(Class.id).filter(Class.teacher_id == teacher.id, Class.is_deleted == False).all()
                teacher_class_ids = [r[0] for r in cls_rows]

            filter_conds = [Ticket.receiver_id == user_id]
            if teacher_class_ids:
                filter_conds.append(and_(
                    Ticket.related_class_id.in_(teacher_class_ids),
                    or_(Ticket.receiver_role == RoleEnum.TEACHER.value, Ticket.receiver_role.is_(None))
                ))

            query = query.filter(or_(*filter_conds))
        elif user_role == RoleEnum.STUDENT.value:
            query = query.filter(Ticket.receiver_id == user_id)
        else:
            query = query.filter(or_(
                Ticket.receiver_id == user_id,
                Ticket.receiver_role == user_role
            ))

        # 2. Bộ lọc tùy chọn (F-06)
        if ticket_type and ticket_type.strip() and ticket_type.upper() != "ALL":
            tt = ticket_type.strip().upper()
            if user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"] and tt == "COMPLAINT":
                query = query.filter(Ticket.id == -1)
            else:
                query = query.filter(Ticket.ticket_type == tt)

        if category and category.strip() and category.upper() != "ALL":
            cat = category.strip().upper()
            if user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"] and cat in TicketService.SCORE_COMPLAINT_CATEGORIES:
                query = query.filter(Ticket.id == -1)
            elif cat in TicketService.UNLOCK_REQUEST_CATEGORIES:
                query = query.filter(Ticket.category.in_(TicketService.UNLOCK_REQUEST_CATEGORIES))
            else:
                query = query.filter(Ticket.category == cat)

        if status and status.strip() and status.upper() != "ALL":
            query = query.filter(Ticket.status == status.strip().upper())

        if q and q.strip():
            term = f"%{q.strip()}%"
            query = query.filter(or_(
                Ticket.ticket_code.ilike(term),
                Ticket.title.ilike(term),
                Ticket.content.ilike(term)
            ))

        query = query.order_by(Ticket.id.desc())

        # 3. Phân trang hoặc trả toàn bộ
        if page is not None or limit is not None:
            p = max(1, page or 1)
            l = min(100, max(1, limit or 20))
            total = query.count()
            total_pages = math.ceil(total / l) if total > 0 else 1
            items = query.offset((p - 1) * l).limit(l).all()
            return {
                "items": [TicketService._format_ticket(db, t) for t in items],
                "total": total,
                "page": p,
                "limit": l,
                "total_pages": total_pages
            }

        items = query.all()
        return [TicketService._format_ticket(db, t) for t in items]

    @staticmethod
    def get_stats(db: Session, user_id: int, user_role: str) -> dict:
        """
        N-03: Thống kê số lượng đơn theo quyền truy cập đầy đủ trên toàn bộ database,
        đồng bộ 100% với phạm vi inbox / sent tương ứng của từng vai trò.
        """
        query = db.query(Ticket).filter(Ticket.is_deleted == False)

        if user_role == RoleEnum.STUDENT.value:
            query = query.filter(
                or_(
                    Ticket.sender_id == user_id,
                    Ticket.receiver_id == user_id
                )
            )
        elif user_role == RoleEnum.TEACHER.value:
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            teacher_class_ids = []
            if teacher:
                cls_rows = db.query(Class.id).filter(Class.teacher_id == teacher.id, Class.is_deleted == False).all()
                teacher_class_ids = [r[0] for r in cls_rows]

            teacher_conds = [
                Ticket.sender_id == user_id,
                Ticket.receiver_id == user_id
            ]
            if teacher_class_ids:
                teacher_conds.append(and_(
                    Ticket.related_class_id.in_(teacher_class_ids),
                    or_(Ticket.receiver_role == RoleEnum.TEACHER.value, Ticket.receiver_role.is_(None))
                ))
            query = query.filter(or_(*teacher_conds))
        elif user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]:
            # Admin và Staff tuyệt đối không xem hoặc thống kê khiếu nại điểm (F-01, F-04, N-02)
            query = query.filter(
                Ticket.ticket_type != "COMPLAINT",
                ~Ticket.category.in_(TicketService.SCORE_COMPLAINT_CATEGORIES)
            )
            if user_role == RoleEnum.ADMIN.value:
                # N-03: Đồng bộ chính xác với list_inbox_tickets() của ADMIN (chỉ receiver_role == ADMIN hoặc UNLOCK_REQUEST)
                query = query.filter(
                    or_(
                        Ticket.receiver_id == user_id,
                        Ticket.receiver_role == RoleEnum.ADMIN.value,
                        Ticket.category.in_(TicketService.UNLOCK_REQUEST_CATEGORIES)
                    )
                )
            else:
                # N-03: Đồng bộ chính xác với list_inbox_tickets() của ACADEMIC_STAFF
                query = query.filter(
                    or_(
                        Ticket.receiver_id == user_id,
                        Ticket.receiver_role.in_([RoleEnum.ACADEMIC_STAFF.value, "STAFF"]),
                        Ticket.category.in_(TicketService.UNLOCK_REQUEST_CATEGORIES)
                    )
                )
        else:
            return {
                "total": 0,
                "pending": 0, "processing": 0, "approved": 0,
                "rejected": 0, "resolved": 0, "closed": 0,
                "unlock_requests": 0, "complaints": 0,
                "status_counts": {
                    "PENDING": 0, "PROCESSING": 0, "APPROVED": 0,
                    "REJECTED": 0, "RESOLVED": 0, "CLOSED": 0
                }
            }

        all_accessible = query.all()
        total = len(all_accessible)

        pending = sum(1 for t in all_accessible if t.status == "PENDING")
        processing = sum(1 for t in all_accessible if t.status == "PROCESSING")
        approved = sum(1 for t in all_accessible if t.status == "APPROVED")
        rejected = sum(1 for t in all_accessible if t.status == "REJECTED")
        resolved = sum(1 for t in all_accessible if t.status == "RESOLVED")
        closed = sum(1 for t in all_accessible if t.status == "CLOSED")

        unlock_requests = sum(1 for t in all_accessible if TicketService.is_unlock_request(t))
        complaints = sum(1 for t in all_accessible if TicketService.is_score_complaint(t))

        return {
            "total": total,
            "pending": pending,
            "processing": processing,
            "approved": approved,
            "rejected": rejected,
            "resolved": resolved,
            "closed": closed,
            "unlock_requests": unlock_requests,
            "complaints": complaints,
            "status_counts": {
                "PENDING": pending,
                "PROCESSING": processing,
                "APPROVED": approved,
                "REJECTED": rejected,
                "RESOLVED": resolved,
                "CLOSED": closed
            }
        }

    @staticmethod
    def get_ticket_detail(db: Session, ticket_id: int, user_id: int, user_role: str) -> dict:
        ticket = db.query(Ticket).filter(Ticket.id == ticket_id, Ticket.is_deleted == False).first()
        if not ticket:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        # QUY TẮC BẮT BUỘC: ADMIN và ACADEMIC_STAFF không được xem chi tiết khiếu nại điểm (F-01, F-04) -> 403 Forbidden
        if user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"] and TicketService.is_score_complaint(ticket):
            raise ForbiddenException("Quản trị viên và Nhân viên học vụ không có quyền truy cập dữ liệu khiếu nại điểm.")

        is_sender = ticket.sender_id == user_id
        is_receiver = ticket.receiver_id == user_id
        is_privileged = user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]

        is_teacher_of_class = False
        if user_role == RoleEnum.TEACHER.value and ticket.related_class_id:
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            if teacher and ticket.related_class and ticket.related_class.teacher_id == teacher.id:
                is_teacher_of_class = True

        # F-10: Ngăn chặn enumeration đối với người dùng không thuộc quyền (cross-student, cross-teacher, parent) -> 404
        if not (is_sender or is_receiver or is_teacher_of_class or (is_privileged and not TicketService.is_score_complaint(ticket))):
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        return TicketService._format_ticket(db, ticket, include_messages=True)

    @staticmethod
    def add_message(db: Session, ticket_id: int, sender_id: int, sender_role: str, data: TicketMessageCreate) -> dict:
        ticket = db.query(Ticket).filter(Ticket.id == ticket_id, Ticket.is_deleted == False).first()
        if not ticket:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        # QUY TẮC BẮT BUỘC: ADMIN và ACADEMIC_STAFF không được phản hồi khiếu nại điểm (F-01) -> 403 Forbidden
        if sender_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"] and TicketService.is_score_complaint(ticket):
            raise ForbiddenException("Quản trị viên và Nhân viên học vụ không có quyền phản hồi khiếu nại điểm.")

        is_sender = ticket.sender_id == sender_id
        is_receiver = ticket.receiver_id == sender_id
        is_privileged = sender_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]

        is_teacher_of_class = False
        if sender_role == RoleEnum.TEACHER.value and ticket.related_class_id:
            teacher = db.query(Teacher).filter(Teacher.user_id == sender_id, Teacher.is_deleted == False).first()
            if teacher and ticket.related_class and ticket.related_class.teacher_id == teacher.id:
                is_teacher_of_class = True

        # F-10: Người dùng không thuộc quyền thảo luận đơn -> 404
        if not (is_sender or is_receiver or is_teacher_of_class or (is_privileged and not TicketService.is_score_complaint(ticket))):
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        msg = TicketMessage(
            ticket_id=ticket_id,
            sender_id=sender_id,
            content=data.content.strip()
        )
        db.add(msg)

        # F-08: Nếu người phản hồi không phải là người gửi và đơn đang PENDING, tự động chuyển sang PROCESSING + ghi system audit log
        if not is_sender and ticket.status == "PENDING":
            old_status = ticket.status
            ticket.status = "PROCESSING"
            sender_user = db.query(User).filter(User.id == sender_id).first()
            performer_name = sender_user.full_name if sender_user else f"User #{sender_id}"
            sys_audit = TicketMessage(
                ticket_id=ticket_id,
                sender_id=sender_id,
                content=f"[HỆ THỐNG] Chuyển trạng thái từ {old_status} sang PROCESSING khi {performer_name} ({sender_role}) gửi phản hồi."
            )
            db.add(sys_audit)

        ticket.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(msg)
        return TicketService._format_message(msg)

    @staticmethod
    def update_status(db: Session, ticket_id: int, user_id: int, user_role: str, data: TicketStatusUpdate) -> dict:
        ticket = db.query(Ticket).filter(Ticket.id == ticket_id, Ticket.is_deleted == False).first()
        if not ticket:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        is_sender = ticket.sender_id == user_id
        is_receiver = ticket.receiver_id == user_id
        is_admin_or_staff = user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, "STAFF"]
        is_score_comp = TicketService.is_score_complaint(ticket)
        is_unlock_req = TicketService.is_unlock_request(ticket)

        is_teacher_of_class = False
        if user_role == RoleEnum.TEACHER.value and ticket.related_class_id:
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            if teacher and ticket.related_class and ticket.related_class.teacher_id == teacher.id:
                is_teacher_of_class = True

        # QUY TẮC BẮT BUỘC: Admin/Staff bị cấm thay đổi trạng thái khiếu nại điểm (F-01, audit test 2.7) -> 403 Forbidden
        if is_admin_or_staff and is_score_comp:
            raise ForbiddenException("Quản trị viên và Nhân viên học vụ không có quyền giải quyết hoặc thay đổi trạng thái khiếu nại điểm.")

        has_access = is_sender or is_receiver or is_teacher_of_class or (is_admin_or_staff and not is_score_comp)
        if not has_access:
            raise NotFoundException("Đơn khiếu nại/yêu cầu", ticket_id)

        # Kiểm tra tính hợp lệ của trạng thái yêu cầu
        valid_statuses = ["PENDING", "PROCESSING", "APPROVED", "REJECTED", "RESOLVED", "CLOSED"]
        new_status = (data.status or "").strip().upper()
        if new_status not in valid_statuses:
            raise BusinessException(f"Trạng thái '{new_status}' không hợp lệ. Các trạng thái hợp lệ: {', '.join(valid_statuses)}.")

        # Chặn xử lý lại đơn đã có kết quả cuối cùng (F-11)
        if ticket.status in ("APPROVED", "REJECTED", "RESOLVED", "CLOSED") and new_status in ("APPROVED", "REJECTED"):
            raise BusinessException(
                f"Đơn này đã được xử lý (trạng thái hiện tại: {ticket.status}). "
                "Không thể phê duyệt/từ chối lại một đơn đã có kết quả."
            )

        # Kiểm tra quyền cập nhật trạng thái chung của actor (role vs ticket)
        if user_role == RoleEnum.STUDENT.value:
            if new_status != "CLOSED" or not is_sender:
                raise ForbiddenException("Học viên không có quyền thay đổi trạng thái đơn này.")

        if is_unlock_req and is_sender and new_status in ("APPROVED", "REJECTED"):
            raise ForbiddenException("Người tạo đơn không được phép tự phê duyệt hoặc xử lý đơn của chính mình.")

        if is_score_comp:
            if not (is_teacher_of_class or is_receiver or (is_sender and new_status == "CLOSED")):
                raise ForbiddenException("Chỉ giảng viên phụ trách lớp mới có quyền xử lý khiếu nại điểm.")
        else:
            if not (is_admin_or_staff or is_teacher_of_class or is_receiver or (is_sender and new_status == "CLOSED")):
                raise ForbiddenException("Bạn không có quyền cập nhật trạng thái đơn này.")

        # N-01: Idempotency an toàn - Kiểm tra sau khi actor đã được xác thực có quyền cập nhật ticket
        old_status = ticket.status
        if old_status == new_status:
            return {
                "id": ticket.id,
                "ticket_code": ticket.ticket_code,
                "status": ticket.status,
                "message": "Trạng thái đơn không thay đổi."
            }

        performer_user = db.query(User).filter(User.id == user_id).first()
        performer_name = performer_user.full_name if performer_user else f"User #{user_id}"
        reason_clean = (data.reason or "").strip()

        # Kiểm tra chi tiết quy tắc chuyển trạng thái (khi old_status != new_status):
        if new_status == "APPROVED":
            if not is_admin_or_staff:
                raise ForbiddenException("Bạn không có quyền phê duyệt yêu cầu. Chỉ Quản trị viên hoặc Nhân viên học vụ mới có quyền phê duyệt yêu cầu.")
            if is_sender:
                raise ForbiddenException("Người tạo đơn không được phép tự phê duyệt đơn của chính mình.")
            if is_score_comp:
                raise BusinessException("Đơn khiếu nại không sử dụng trạng thái APPROVED. Vui lòng sử dụng RESOLVED.")

        elif new_status == "REJECTED":
            if not is_admin_or_staff:
                raise ForbiddenException("Bạn không có quyền từ chối yêu cầu. Chỉ Quản trị viên hoặc Nhân viên học vụ mới có quyền từ chối yêu cầu.")
            if is_score_comp:
                raise BusinessException("Đơn khiếu nại không sử dụng trạng thái REJECTED. Vui lòng sử dụng RESOLVED hoặc trao đổi phản hồi.")
            if not reason_clean:
                raise BusinessException("Vui lòng nhập lý do từ chối yêu cầu.")

        elif new_status == "RESOLVED":
            if is_score_comp:
                if not (is_teacher_of_class or is_receiver):
                    raise ForbiddenException("Chỉ giảng viên phụ trách lớp mới có quyền giải quyết khiếu nại điểm.")
            else:
                if not (is_admin_or_staff or is_teacher_of_class or is_receiver):
                    raise ForbiddenException("Bạn không có quyền cập nhật giải quyết đơn này.")

        elif new_status == "PROCESSING":
            if is_score_comp:
                if not (is_teacher_of_class or is_receiver):
                    raise ForbiddenException("Chỉ giảng viên phụ trách lớp mới có quyền chuyển khiếu nại sang đang xử lý.")
            else:
                if not (is_admin_or_staff or is_teacher_of_class or is_receiver):
                    raise ForbiddenException("Bạn không có quyền chuyển đơn sang trạng thái đang xử lý.")

        elif new_status == "CLOSED":
            if is_score_comp:
                if not (is_sender or is_teacher_of_class or is_receiver):
                    raise ForbiddenException("Bạn không có quyền đóng đơn khiếu nại này.")
            else:
                if not (is_sender or is_admin_or_staff or is_teacher_of_class or is_receiver):
                    raise ForbiddenException("Bạn không có quyền đóng đơn này.")

        elif new_status == "PENDING":
            if is_score_comp:
                raise ForbiddenException("Không thể đặt lại trạng thái chờ xử lý cho khiếu nại điểm.")
            if not is_admin_or_staff:
                raise ForbiddenException("Chỉ Quản trị viên hoặc Nhân viên học vụ mới có thể đặt lại trạng thái chờ xử lý.")

        # Nếu là APPROVED yêu cầu mở sổ điểm: kiểm tra 8 điều kiện mở sổ điểm (F-02)
        if new_status == "APPROVED" and is_unlock_req:
            if not ticket.related_class_id:
                raise BusinessException("Yêu cầu mở sổ điểm không gắn liền với lớp học hợp lệ.")
            cls = ticket.related_class or db.query(Class).filter(Class.id == ticket.related_class_id, Class.is_deleted == False).first()
            if not cls:
                raise NotFoundException("Lớp học", ticket.related_class_id)
            if not cls.teacher or cls.teacher.user_id != ticket.sender_id:
                raise BusinessException("Người gửi đơn không phải là giảng viên phụ trách lớp học phần này.")

            from app.modules.grades.service import GradeService
            is_locked, _ = GradeService.check_and_update_class_grade_lock(db, cls)
            if not is_locked:
                raise BusinessException("Sổ điểm của lớp học hiện tại đang mở, không thể phê duyệt yêu cầu mở khóa.")

            # Mở khóa sổ điểm với thời hạn 72 giờ và ghi log GradeLockHistory
            reason_text = f"Phê duyệt yêu cầu mở sổ điểm #{ticket.ticket_code}: {reason_clean}" if reason_clean else f"Phê duyệt yêu cầu mở sổ điểm #{ticket.ticket_code}"
            GradeService.unlock_grades(db, class_id=ticket.related_class_id, user_id=user_id, reason=reason_text)

        ticket.status = new_status

        # F-08: Ghi log kiểm toán cho TẤT CẢ các chuyển đổi trạng thái thực sự
        audit_note = f" Lý do / Ghi chú: {reason_clean}" if reason_clean else ""
        audit_msg = TicketMessage(
            ticket_id=ticket.id,
            sender_id=user_id,
            content=f"[HỆ THỐNG] Chuyển trạng thái từ {old_status} sang {new_status} bởi {performer_name} ({user_role}).{audit_note}"
        )
        db.add(audit_msg)

        ticket.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(ticket)
        return TicketService._format_ticket(db, ticket, include_messages=True)
