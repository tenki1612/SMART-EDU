from typing import Optional, Tuple
from datetime import date
from sqlalchemy.orm import Session
from app.modules.schedules.models import ScheduleSession

class ScheduleConflictChecker:
    @staticmethod
    def _is_time_overlap(start1: str, end1: str, start2: str, end2: str) -> bool:
        """Kiểm tra 2 khoảng thời gian HH:MM có bị giao nhau không"""
        return (start1 < end2) and (end1 > start2)

    @staticmethod
    def check_conflicts(
        db: Session,
        classroom_id: int,
        teacher_id: int,
        session_date: date,
        start_time: str,
        end_time: str,
        exclude_session_id: Optional[int] = None
    ) -> Tuple[bool, Optional[str], str]:
        """
        Kiểm tra xung đột phòng học hoặc giáo viên (FR-65).
        Trả về (has_conflict, conflict_type, message)
        """
        # 1. Kiểm tra xung đột phòng học
        room_sessions = db.query(ScheduleSession).filter(
            ScheduleSession.classroom_id == classroom_id,
            ScheduleSession.session_date == session_date,
            ScheduleSession.status != "CANCELLED",
            ScheduleSession.is_deleted == False
        )
        if exclude_session_id:
            room_sessions = room_sessions.filter(ScheduleSession.id != exclude_session_id)
        
        for s in room_sessions.all():
            if ScheduleConflictChecker._is_time_overlap(start_time, end_time, s.start_time, s.end_time):
                room_code = s.classroom.room_code if s.classroom else f"ID {classroom_id}"
                class_code = s.session_class.class_code if s.session_class else ""
                return (
                    True, 
                    "ROOM_CONFLICT", 
                    f"Xung đột phòng học: Phòng {room_code} đã có lớp {class_code} học từ {s.start_time} đến {s.end_time} vào ngày {session_date}."
                )

        # 2. Kiểm tra xung đột giáo viên
        teacher_sessions = db.query(ScheduleSession).filter(
            ScheduleSession.teacher_id == teacher_id,
            ScheduleSession.session_date == session_date,
            ScheduleSession.status != "CANCELLED",
            ScheduleSession.is_deleted == False
        )
        if exclude_session_id:
            teacher_sessions = teacher_sessions.filter(ScheduleSession.id != exclude_session_id)
            
        for s in teacher_sessions.all():
            if ScheduleConflictChecker._is_time_overlap(start_time, end_time, s.start_time, s.end_time):
                teacher_name = s.teacher.user.full_name if (s.teacher and s.teacher.user) else f"ID {teacher_id}"
                class_code = s.session_class.class_code if s.session_class else ""
                return (
                    True, 
                    "TEACHER_CONFLICT", 
                    f"Xung đột giáo viên: Giảng viên {teacher_name} đã có lịch dạy lớp {class_code} từ {s.start_time} đến {s.end_time} vào ngày {session_date}."
                )

        return (False, None, "Không có xung đột lịch. Thời khóa biểu hợp lệ.")

