from typing import List, Optional
from datetime import date, timedelta
from sqlalchemy.orm import Session
from app.modules.schedules.models import ScheduleSession
from app.modules.classes.models import Class, ClassStudent
from app.modules.classrooms.models import Classroom
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.schedules.schemas import ScheduleSessionCreate, ScheduleSessionUpdate, ScheduleRecurringCreate
from app.modules.schedules.conflict_checker import ScheduleConflictChecker

class ScheduleService:
    @staticmethod
    def _format_session(s: ScheduleSession) -> dict:
        teacher_name = s.teacher.user.full_name if (s.teacher and s.teacher.user) else ""
        class_code = s.session_class.class_code if s.session_class else ""
        course_title = s.session_class.course.title if (s.session_class and s.session_class.course) else ""
        room_code = s.classroom.room_code if s.classroom else ""
        class_start_date = s.session_class.start_date if s.session_class else None
        class_end_date = s.session_class.end_date if s.session_class else None
        return {
            "id": s.id,
            "class_id": s.class_id,
            "class_code": class_code,
            "course_title": course_title,
            "classroom_id": s.classroom_id,
            "room_code": room_code,
            "teacher_id": s.teacher_id,
            "teacher_name": teacher_name,
            "session_date": s.session_date,
            "start_time": s.start_time,
            "end_time": s.end_time,
            "slot_name": s.slot_name,
            "is_confirmed": s.is_confirmed,
            "status": s.status,
            "class_start_date": class_start_date,
            "class_end_date": class_end_date
        }

    @staticmethod
    def create_session(db: Session, data: ScheduleSessionCreate) -> dict:
        # Check conflicts first (FR-65)
        has_conflict, c_type, msg = ScheduleConflictChecker.check_conflicts(
            db=db,
            classroom_id=data.classroom_id,
            teacher_id=data.teacher_id,
            session_date=data.session_date,
            start_time=data.start_time,
            end_time=data.end_time
        )
        if has_conflict:
            raise BusinessException(msg)

        session = ScheduleSession(
            class_id=data.class_id,
            classroom_id=data.classroom_id,
            teacher_id=data.teacher_id,
            session_date=data.session_date,
            start_time=data.start_time,
            end_time=data.end_time,
            slot_name=data.slot_name,
            is_confirmed=False,
            status="SCHEDULED"
        )
        db.add(session)
        db.commit()
        db.refresh(session)
        return ScheduleService._format_session(session)

    @staticmethod
    def generate_recurring_sessions(db: Session, data: ScheduleRecurringCreate) -> dict:
        """
        N-05: Tự động sinh danh sách buổi học lặp lại theo tuần cho lớp học từ ngày bắt đầu đến ngày kết thúc
        """
        cls = db.query(Class).filter(Class.id == data.class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", data.class_id)

        effective_start = data.start_date or cls.start_date
        effective_end = data.end_date or cls.end_date

        if not effective_start:
            raise BusinessException("Lớp học chưa xác định ngày bắt đầu.")

        if not effective_end:
            duration = cls.course.duration_weeks if (cls.course and cls.course.duration_weeks) else 12
            effective_end = effective_start + timedelta(weeks=duration)

        if effective_end < effective_start:
            raise BusinessException("Ngày kết thúc không được trước ngày bắt đầu.")

        if not data.days_of_week:
            raise BusinessException("Vui lòng chọn ít nhất một thứ trong tuần để tạo lịch học lặp lại.")

        created_sessions = []
        conflicts = []
        skipped_count = 0

        cur_date = effective_start
        while cur_date <= effective_end:
            if cur_date.weekday() in data.days_of_week:
                # Kiểm tra trùng lặp buổi học đã tồn tại cho lớp vào ngày này
                existing = db.query(ScheduleSession).filter(
                    ScheduleSession.class_id == data.class_id,
                    ScheduleSession.session_date == cur_date,
                    ScheduleSession.is_deleted == False
                ).first()
                if existing:
                    skipped_count += 1
                else:
                    # Kiểm tra xung đột phòng học / giáo viên
                    has_conflict, c_type, msg = ScheduleConflictChecker.check_conflicts(
                        db=db,
                        classroom_id=data.classroom_id,
                        teacher_id=data.teacher_id,
                        session_date=cur_date,
                        start_time=data.start_time,
                        end_time=data.end_time
                    )
                    if has_conflict:
                        conflicts.append({
                            "date": str(cur_date),
                            "conflict_type": c_type,
                            "message": msg
                        })
                    else:
                        sess = ScheduleSession(
                            class_id=data.class_id,
                            classroom_id=data.classroom_id,
                            teacher_id=data.teacher_id,
                            session_date=cur_date,
                            start_time=data.start_time,
                            end_time=data.end_time,
                            slot_name=data.slot_name or "Ca học",
                            is_confirmed=data.is_confirmed if data.is_confirmed is not None else False,
                            status="SCHEDULED"
                        )
                        db.add(sess)
                        created_sessions.append(sess)
            cur_date += timedelta(days=1)

        db.commit()
        for s in created_sessions:
            db.refresh(s)

        return {
            "class_id": cls.id,
            "class_code": cls.class_code,
            "start_date": str(effective_start),
            "end_date": str(effective_end),
            "created_count": len(created_sessions),
            "skipped_count": skipped_count,
            "conflicts_count": len(conflicts),
            "conflicts": conflicts,
            "sessions": [ScheduleService._format_session(s) for s in created_sessions]
        }

    @staticmethod
    def update_session(db: Session, session_id: int, data: ScheduleSessionUpdate) -> dict:
        session = db.query(ScheduleSession).filter(ScheduleSession.id == session_id, ScheduleSession.is_deleted == False).first()
        if not session:
            raise NotFoundException("Buổi học", session_id)

        classroom_id = data.classroom_id or session.classroom_id
        teacher_id = data.teacher_id or session.teacher_id
        session_date = data.session_date or session.session_date
        start_time = data.start_time or session.start_time
        end_time = data.end_time or session.end_time

        # FR-62: Kiểm tra lại xung đột trước khi lưu điều chỉnh
        has_conflict, c_type, msg = ScheduleConflictChecker.check_conflicts(
            db=db,
            classroom_id=classroom_id,
            teacher_id=teacher_id,
            session_date=session_date,
            start_time=start_time,
            end_time=end_time,
            exclude_session_id=session_id
        )
        if has_conflict:
            raise BusinessException(msg)

        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(session, field, value)

        db.commit()
        db.refresh(session)
        return ScheduleService._format_session(session)

    @staticmethod
    def list_sessions(
        db: Session, 
        class_id: Optional[int] = None, 
        teacher_id: Optional[int] = None,
        from_date: Optional[date] = None,
        to_date: Optional[date] = None
    ) -> List[dict]:
        q = db.query(ScheduleSession).filter(ScheduleSession.is_deleted == False)
        if class_id:
            q = q.filter(ScheduleSession.class_id == class_id)
        if teacher_id:
            q = q.filter(ScheduleSession.teacher_id == teacher_id)
        if from_date:
            q = q.filter(ScheduleSession.session_date >= from_date)
        if to_date:
            q = q.filter(ScheduleSession.session_date <= to_date)
        q = q.order_by(ScheduleSession.session_date.asc(), ScheduleSession.start_time.asc())
        return [ScheduleService._format_session(s) for s in q.all()]

    @staticmethod
    def confirm_schedule(db: Session, class_id: int) -> bool:
        """FR-66: Xác nhận thời khóa biểu của lớp để đưa vào áp dụng chính thức"""
        sessions = db.query(ScheduleSession).filter(
            ScheduleSession.class_id == class_id,
            ScheduleSession.is_deleted == False
        ).all()
        if not sessions:
            raise BusinessException("Lớp học này chưa có buổi học nào trong thời khóa biểu.")
        
        for s in sessions:
            s.is_confirmed = True
        db.commit()
        return True

    @staticmethod
    def cancel_session(db: Session, session_id: int) -> bool:
        """FR-67: Hủy buổi học / thời khóa biểu"""
        session = db.query(ScheduleSession).filter(ScheduleSession.id == session_id, ScheduleSession.is_deleted == False).first()
        if not session:
            raise NotFoundException("Buổi học", session_id)
        session.status = "CANCELLED"
        db.commit()
        return True

    @staticmethod
    def delete_session(db: Session, session_id: int) -> bool:
        """Xóa buổi học khỏi thời khóa biểu"""
        session = db.query(ScheduleSession).filter(ScheduleSession.id == session_id).first()
        if not session:
            raise NotFoundException("Buổi học", session_id)
        session.is_deleted = True
        db.commit()
        return True

    @staticmethod
    def get_personal_schedule(db: Session, user_id: int, role: str) -> List[dict]:
        """FR-68: Xem thời khóa biểu cá nhân theo vai trò (Teacher / Student / Parent)
        Hiển thị toàn bộ lịch học/dạy trong phạm vi start_date -> end_date của lớp học, không giới hạn số tuần.
        """
        if role == "TEACHER":
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            if not teacher:
                return []
            sessions = db.query(ScheduleSession).join(Class, ScheduleSession.class_id == Class.id).filter(
                ScheduleSession.teacher_id == teacher.id,
                ScheduleSession.status != "CANCELLED",
                ScheduleSession.is_deleted == False,
                Class.is_deleted == False,
                (Class.start_date == None) | (ScheduleSession.session_date >= Class.start_date),
                (Class.end_date == None) | (ScheduleSession.session_date <= Class.end_date)
            ).order_by(ScheduleSession.session_date.asc(), ScheduleSession.start_time.asc()).all()
            return [ScheduleService._format_session(s) for s in sessions]

        elif role == "STUDENT":
            student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
            if not student:
                return []
            # Tìm các lớp học viên đang tham gia
            enrolled_classes = db.query(ClassStudent.class_id).filter(
                ClassStudent.student_id == student.id,
                ClassStudent.status == "ENROLLED",
                ClassStudent.is_deleted == False
            ).all()
            class_ids = [c[0] for c in enrolled_classes]
            if not class_ids:
                return []
            sessions = db.query(ScheduleSession).join(Class, ScheduleSession.class_id == Class.id).filter(
                ScheduleSession.class_id.in_(class_ids),
                ScheduleSession.status != "CANCELLED",
                ScheduleSession.is_deleted == False,
                Class.is_deleted == False,
                (Class.start_date == None) | (ScheduleSession.session_date >= Class.start_date),
                (Class.end_date == None) | (ScheduleSession.session_date <= Class.end_date)
            ).order_by(ScheduleSession.session_date.asc(), ScheduleSession.start_time.asc()).all()
            return [ScheduleService._format_session(s) for s in sessions]

        elif role == "PARENT":
            from app.modules.progression_parent.models import ParentStudent
            wards = db.query(ParentStudent.student_id).filter(
                ParentStudent.parent_user_id == user_id,
                ParentStudent.is_deleted == False
            ).all()
            ward_ids = [w[0] for w in wards]
            if not ward_ids:
                return []
            enrolled_classes = db.query(ClassStudent.class_id).filter(
                ClassStudent.student_id.in_(ward_ids),
                ClassStudent.status == "ENROLLED",
                ClassStudent.is_deleted == False
            ).all()
            class_ids = [c[0] for c in enrolled_classes]
            if not class_ids:
                return []
            sessions = db.query(ScheduleSession).join(Class, ScheduleSession.class_id == Class.id).filter(
                ScheduleSession.class_id.in_(class_ids),
                ScheduleSession.status != "CANCELLED",
                ScheduleSession.is_deleted == False,
                Class.is_deleted == False,
                (Class.start_date == None) | (ScheduleSession.session_date >= Class.start_date),
                (Class.end_date == None) | (ScheduleSession.session_date <= Class.end_date)
            ).order_by(ScheduleSession.session_date.asc(), ScheduleSession.start_time.asc()).all()
            return [ScheduleService._format_session(s) for s in sessions]
        
        return []

