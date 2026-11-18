from typing import List, Optional
from datetime import timedelta, date
from sqlalchemy.orm import Session
from app.modules.classes.models import Class, ClassStudent
from app.modules.courses.models import Course
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student
from app.modules.grades.models import GradeRecord
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.classes.schemas import ClassCreate, ClassUpdate, ClassRosterStudentItem

class ClassService:
    @staticmethod
    def _format_class_response(cls: Class, is_enrolled: bool = False) -> dict:
        teacher_name = cls.teacher.user.full_name if (cls.teacher and cls.teacher.user) else None
        course_title = cls.course.title if cls.course else None
        target_level = cls.course.target_level if cls.course else None
        return {
            "id": cls.id,
            "class_code": cls.class_code,
            "course_id": cls.course_id,
            "course_title": course_title,
            "target_level": target_level,
            "teacher_id": cls.teacher_id,
            "teacher_name": teacher_name,
            "max_capacity": cls.max_capacity,
            "current_enrolled": cls.current_enrolled,
            "is_full": cls.current_enrolled >= cls.max_capacity,
            "is_enrolled": is_enrolled,
            "opening_date": cls.opening_date or cls.start_date,
            "start_date": cls.start_date,
            "end_date": cls.end_date,
            "status": cls.status
        }

    @staticmethod
    def create_class(db: Session, data: ClassCreate) -> dict:
        if db.query(Class).filter(Class.class_code == data.class_code, Class.is_deleted == False).first():
            raise BusinessException(f"Mã lớp học '{data.class_code}' đã tồn tại.")
        
        course = db.query(Course).filter(Course.id == data.course_id, Course.is_deleted == False).first()
        if not course:
            raise NotFoundException("Khóa học", data.course_id)
        
        if data.teacher_id:
            teacher = db.query(Teacher).filter(Teacher.id == data.teacher_id, Teacher.is_deleted == False).first()
            if not teacher:
                raise NotFoundException("Giáo viên", data.teacher_id)

        today = date.today()
        # Quy tắc: Thời gian mở lớp không được nằm trong quá khứ (OpeningTime >= CurrentDateTime)
        target_opening = data.opening_date or data.start_date
        if target_opening and target_opening < today:
            raise BusinessException("Thời gian mở lớp không hợp lệ. Thời gian mở lớp không được nằm trong quá khứ.")
        
        if data.start_date and target_opening and data.start_date < target_opening:
            raise BusinessException("Thời gian bắt đầu học thực tế không được trước thời gian mở lớp.")
        
        # Tự động tính ngày kết thúc dựa vào số tuần của khóa học (duration_weeks)
        calculated_end_date = data.end_date
        if data.start_date:
            weeks = course.duration_weeks if (course.duration_weeks and course.duration_weeks > 0) else 12
            calculated_end_date = data.start_date + timedelta(weeks=weeks)

        cls = Class(
            class_code=data.class_code,
            course_id=data.course_id,
            teacher_id=data.teacher_id,
            max_capacity=data.max_capacity,
            current_enrolled=0,
            opening_date=target_opening,
            start_date=data.start_date,
            end_date=calculated_end_date,
            status="OPEN_FOR_ENROLLMENT"
        )
        db.add(cls)
        db.commit()
        db.refresh(cls)
        return ClassService._format_class_response(cls)

    @staticmethod
    def update_class(db: Session, class_id: int, data: ClassUpdate) -> dict:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        
        today = date.today()
        if data.opening_date is not None:
            if data.opening_date < today:
                raise BusinessException("Thời gian mở lớp không hợp lệ. Thời gian mở lớp không được nằm trong quá khứ.")
            cls.opening_date = data.opening_date

        if data.start_date is not None:
            effective_opening = data.opening_date or cls.opening_date or data.start_date
            if effective_opening and data.start_date < effective_opening:
                raise BusinessException("Thời gian bắt đầu học thực tế không được trước thời gian mở lớp.")
            cls.start_date = data.start_date
        
        if data.teacher_id is not None:
            if data.teacher_id > 0:
                teacher = db.query(Teacher).filter(Teacher.id == data.teacher_id, Teacher.is_deleted == False).first()
                if not teacher:
                    raise NotFoundException("Giáo viên", data.teacher_id)
                cls.teacher_id = data.teacher_id
            else:
                cls.teacher_id = None
        
        if data.max_capacity is not None:
            if data.max_capacity < cls.current_enrolled:
                raise BusinessException("Sức chứa tối đa không được nhỏ hơn sĩ số hiện tại của lớp.")
            cls.max_capacity = data.max_capacity
        
        if data.start_date is not None:
            cls.start_date = data.start_date
            # Tự động tính lại ngày kết thúc nếu không nhập thủ công end_date
            if data.end_date is None and cls.course:
                weeks = cls.course.duration_weeks if (cls.course.duration_weeks and cls.course.duration_weeks > 0) else 12
                cls.end_date = data.start_date + timedelta(weeks=weeks)
        if data.end_date is not None:
            cls.end_date = data.end_date
        if data.status is not None:
            cls.status = data.status
        
        db.commit()
        db.refresh(cls)
        return ClassService._format_class_response(cls)

    @staticmethod
    def list_classes(
        db: Session, 
        q: Optional[str] = None, 
        course_id: Optional[int] = None, 
        status: Optional[str] = None,
        student_id: Optional[int] = None,
        teacher_id: Optional[int] = None
    ) -> List[dict]:
        query = db.query(Class).filter(Class.is_deleted == False)
        enrolled_ids = set()
        if student_id is not None:
            enrolled_ids = {
                cs.class_id for cs in db.query(ClassStudent.class_id).filter(
                    ClassStudent.student_id == student_id,
                    ClassStudent.is_deleted == False
                ).all()
            }
            # When student explicitly filters for OPEN_FOR_ENROLLMENT (for transfer / enrollment),
            # allow seeing all open classes. Otherwise, isolate to their enrolled classes.
            if status != "OPEN_FOR_ENROLLMENT":
                query = query.filter(Class.id.in_(enrolled_ids))

        if teacher_id is not None:
            query = query.filter(Class.teacher_id == teacher_id)

        if q:
            query = query.filter(Class.class_code.ilike(f"%{q}%"))
        if course_id:
            query = query.filter(Class.course_id == course_id)
        if status:
            if student_id is not None and status == "IN_PROGRESS":
                query = query.filter(Class.status.in_(["OPEN_FOR_ENROLLMENT", "IN_PROGRESS"]))
            else:
                query = query.filter(Class.status == status)
        
        return [ClassService._format_class_response(c, is_enrolled=(c.id in enrolled_ids)) for c in query.all()]

    @staticmethod
    def get_class_detail(db: Session, class_id: int) -> dict:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        return ClassService._format_class_response(cls)

    @staticmethod
    def assign_teacher(db: Session, class_id: int, teacher_id: int) -> dict:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        
        teacher = db.query(Teacher).filter(Teacher.id == teacher_id, Teacher.is_deleted == False).first()
        if not teacher:
            raise NotFoundException("Giáo viên", teacher_id)
        
        cls.teacher_id = teacher_id
        db.commit()
        db.refresh(cls)
        return ClassService._format_class_response(cls)

    @staticmethod
    def get_class_roster(db: Session, class_id: int) -> List[ClassRosterStudentItem]:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        
        roster = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.is_deleted == False
        ).all()

        results = []
        for r in roster:
            student = r.student
            user = student.user
            results.append(ClassRosterStudentItem(
                student_id=student.id,
                student_code=student.student_code,
                full_name=user.full_name,
                email=user.email,
                phone=user.phone,
                enrolled_at=r.enrolled_at,
                status=r.status
            ))
        return results

    @staticmethod
    def add_student_to_roster(db: Session, class_id: int, student_id: int) -> bool:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        
        if cls.current_enrolled >= cls.max_capacity:
            raise BusinessException(f"Lớp học {cls.class_code} đã đủ sĩ số ({cls.current_enrolled}/{cls.max_capacity}).")
        
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)
        
        existing = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.is_deleted == False
        ).first()
        if existing:
            raise BusinessException("Học viên này đã có trong danh sách lớp.")
        
        enrollment = ClassStudent(class_id=class_id, student_id=student_id, status="ENROLLED")
        db.add(enrollment)
        
        # Tạo sẵn bản ghi điểm cho học viên trong lớp
        grade = GradeRecord(class_id=class_id, student_id=student_id, result_status="PENDING")
        db.add(grade)

        cls.current_enrolled += 1
        db.commit()
        return True

    @staticmethod
    def update_class_status(db: Session, class_id: int, new_status: str) -> dict:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        cls.status = new_status
        db.commit()
        db.refresh(cls)
        return ClassService._format_class_response(cls)

    @staticmethod
    def delete_class(db: Session, class_id: int) -> bool:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        if cls.current_enrolled > 0:
            raise BusinessException("Không thể xóa lớp đã có học viên đăng ký tham gia. Vui lòng chuyển trạng thái sang 'Đã hủy'.")
        
        cls.is_deleted = True
        db.commit()
        return True

    @staticmethod
    def get_transfer_targets(db: Session, class_id: int) -> List[dict]:
        """Lấy danh sách các lớp học hợp lệ để học viên có thể chuyển sang từ class_id:
        - Cùng khóa học (hoặc tương thích)
        - Khác lớp hiện tại (target.id != class_id)
        - Khác giảng viên phụ trách (target.teacher_id != curr.teacher_id)
        - Khác thời khóa biểu
        - Lớp đang mở hoặc đang diễn ra
        - Còn chỗ trống (current_enrolled < max_capacity)
        """
        from app.modules.schedules.models import ScheduleSession
        curr_cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not curr_cls:
            raise NotFoundException("Lớp học", class_id)

        curr_sessions = db.query(ScheduleSession).filter(
            ScheduleSession.class_id == class_id,
            ScheduleSession.status != "CANCELLED",
            ScheduleSession.is_deleted == False
        ).all()
        curr_pattern = {(s.session_date.weekday(), s.start_time, s.end_time) for s in curr_sessions}
        curr_dates = {(s.session_date, s.start_time, s.end_time) for s in curr_sessions}

        # Candidate classes cùng khóa học
        candidates = db.query(Class).filter(
            Class.course_id == curr_cls.course_id,
            Class.id != curr_cls.id,
            Class.status.in_(["OPEN_FOR_ENROLLMENT", "IN_PROGRESS"]),
            Class.is_deleted == False
        ).all()

        weekday_names = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"]
        valid_targets = []

        for cand in candidates:
            # 1. Điều kiện: Khác giảng viên
            if curr_cls.teacher_id and cand.teacher_id and curr_cls.teacher_id == cand.teacher_id:
                continue

            # 2. Điều kiện: Khác thời khóa biểu
            cand_sessions = db.query(ScheduleSession).filter(
                ScheduleSession.class_id == cand.id,
                ScheduleSession.status != "CANCELLED",
                ScheduleSession.is_deleted == False
            ).all()

            cand_pattern = {(s.session_date.weekday(), s.start_time, s.end_time) for s in cand_sessions}
            cand_dates = {(s.session_date, s.start_time, s.end_time) for s in cand_sessions}

            if curr_pattern and cand_pattern and curr_pattern == cand_pattern:
                continue
            if curr_dates and cand_dates and curr_dates == cand_dates:
                continue

            distinct_slots = sorted(list({(s.session_date.weekday(), s.start_time, s.end_time) for s in cand_sessions}))
            if distinct_slots:
                day_names = [weekday_names[slot[0]] for slot in distinct_slots]
                times = f"{distinct_slots[0][1]} - {distinct_slots[0][2]}"
                schedule_summary = f"{', '.join(day_names)} ({times})"
            else:
                schedule_summary = "Lịch học đang xếp"

            teacher_name = cand.teacher.user.full_name if (cand.teacher and cand.teacher.user) else "Chưa phân công"

            valid_targets.append({
                "id": cand.id,
                "class_code": cand.class_code,
                "course_id": cand.course_id,
                "course_title": cand.course.title if cand.course else "",
                "teacher_id": cand.teacher_id,
                "teacher_name": teacher_name,
                "max_capacity": cand.max_capacity,
                "current_enrolled": cand.current_enrolled or 0,
                "is_full": (cand.current_enrolled or 0) >= cand.max_capacity,
                "status": cand.status,
                "schedule_summary": schedule_summary
            })

        return valid_targets

    @staticmethod
    def transfer_class(
        db: Session,
        current_class_id: int,
        target_class_id: int,
        student_id: int,
        reason: Optional[str] = None
    ) -> dict:
        """Nghiệp vụ Chuyển lớp cho học viên:
        - Lớp đích != lớp hiện tại
        - Lớp đích có giảng viên khác lớp cũ
        - Lớp đích có thời khóa biểu khác lớp cũ
        - Lớp đích đang mở/hoạt động và còn sĩ số
        - Roster & Sĩ số cập nhật nhất quán
        """
        from datetime import timezone, datetime
        from app.modules.schedules.models import ScheduleSession
        from app.modules.enrollments.models import EnrollmentRequest

        if current_class_id == target_class_id:
            raise BusinessException("Không thể chuyển lớp: Lớp đích phải là một lớp khác với lớp hiện tại.")

        curr_cls = db.query(Class).filter(Class.id == current_class_id, Class.is_deleted == False).first()
        if not curr_cls:
            raise NotFoundException("Lớp học hiện tại", current_class_id)

        target_cls = db.query(Class).filter(Class.id == target_class_id, Class.is_deleted == False).first()
        if not target_cls:
            raise NotFoundException("Lớp học đích", target_class_id)

        # 1. Kiểm tra học viên đang là thành viên chính thức của lớp hiện tại
        curr_cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == current_class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if not curr_cs:
            raise BusinessException("Học viên hiện không đang theo học tại lớp học này.")

        # 2. Kiểm tra lớp đích hoạt động
        if target_cls.status not in ["OPEN_FOR_ENROLLMENT", "IN_PROGRESS"]:
            raise BusinessException(f"Lớp học đích đang ở trạng thái '{target_cls.status}', không thể tiếp nhận chuyển lớp.")

        # 3. Kiểm tra sĩ số lớp đích
        if (target_cls.current_enrolled or 0) >= target_cls.max_capacity:
            raise BusinessException("Lớp học đích đã đủ sĩ số tối đa, không thể tiếp nhận chuyển lớp.")

        # 4. Kiểm tra giảng viên khác nhau
        if curr_cls.teacher_id and target_cls.teacher_id and curr_cls.teacher_id == target_cls.teacher_id:
            raise BusinessException("Không thể chuyển lớp: Lớp đích phải có giảng viên khác với giảng viên phụ trách lớp hiện tại.")

        # 5. Kiểm tra thời khóa biểu khác nhau
        curr_sessions = db.query(ScheduleSession).filter(
            ScheduleSession.class_id == current_class_id,
            ScheduleSession.status != "CANCELLED",
            ScheduleSession.is_deleted == False
        ).all()
        target_sessions = db.query(ScheduleSession).filter(
            ScheduleSession.class_id == target_class_id,
            ScheduleSession.status != "CANCELLED",
            ScheduleSession.is_deleted == False
        ).all()

        if curr_sessions and target_sessions:
            set_curr = {(s.session_date, s.start_time, s.end_time) for s in curr_sessions}
            set_target = {(s.session_date, s.start_time, s.end_time) for s in target_sessions}
            pattern_curr = {(s.session_date.weekday(), s.start_time, s.end_time) for s in curr_sessions}
            pattern_target = {(s.session_date.weekday(), s.start_time, s.end_time) for s in target_sessions}

            if set_curr == set_target or pattern_curr == pattern_target:
                raise BusinessException("Không thể chuyển lớp: Lớp đích có thời khóa biểu giống với lớp hiện tại. Vui lòng chọn lớp có thời khóa biểu khác.")

        # 6. Kiểm tra không đăng ký trùng lặp ở lớp đích
        already_in_target = db.query(ClassStudent).filter(
            ClassStudent.class_id == target_class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if already_in_target:
            raise BusinessException("Học viên đã là thành viên chính thức của lớp học đích.")

        # THỰC HIỆN CHUYỂN LỚP
        # 1. Hủy tư cách thành viên lớp cũ
        curr_cs.status = "TRANSFERRED"
        curr_cs.is_deleted = True
        if curr_cls.current_enrolled and curr_cls.current_enrolled > 0:
            curr_cls.current_enrolled -= 1

        # 2. Ghi danh chính thức vào lớp mới
        new_cs = ClassStudent(class_id=target_class_id, student_id=student_id, status="ENROLLED")
        db.add(new_cs)
        target_cls.current_enrolled = (target_cls.current_enrolled or 0) + 1

        # 3. Đồng bộ sổ điểm sang lớp mới nếu chưa có
        curr_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == current_class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()
        
        target_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == target_class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()

        if not target_grade:
            new_grade = GradeRecord(
                class_id=target_class_id,
                student_id=student_id,
                attendance_score=curr_grade.attendance_score if curr_grade else 0.0,
                midterm_score=curr_grade.midterm_score if curr_grade else 0.0,
                final_score=curr_grade.final_score if curr_grade else 0.0,
                total_score=curr_grade.total_score if curr_grade else 0.0,
                result_status="PENDING",
                note=f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển lớp học'}"
            )
            db.add(new_grade)

        # 4. Ghi nhận lịch sử duyệt ghi danh
        transfer_audit = EnrollmentRequest(
            student_id=student_id,
            class_id=target_class_id,
            note=f"Chuyển lớp từ {curr_cls.class_code} sang {target_cls.class_code}. Lý do: {reason or 'Chuyển lớp học'}",
            status="APPROVED",
            reviewed_at=datetime.now(timezone.utc)
        )
        db.add(transfer_audit)

        db.commit()

        return {
            "success": True,
            "message": f"Chuyển lớp thành công từ {curr_cls.class_code} sang {target_cls.class_code}.",
            "old_class_id": current_class_id,
            "old_class_code": curr_cls.class_code,
            "new_class_id": target_class_id,
            "new_class_code": target_cls.class_code,
            "new_teacher_name": target_cls.teacher.user.full_name if (target_cls.teacher and target_cls.teacher.user) else ""
        }

