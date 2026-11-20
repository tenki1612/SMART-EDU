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
        
        # Ngày kết thúc do người dùng nhập phải được giữ nguyên; chỉ tự tính khi bỏ trống.
        calculated_end_date = data.end_date
        if data.start_date:
            if data.end_date and data.end_date < data.start_date:
                raise BusinessException("Ngày kết thúc lớp học không được trước ngày bắt đầu học.")
            if data.end_date is None:
                weeks = course.duration_weeks if (course.duration_weeks and course.duration_weeks > 0) else 12
                calculated_end_date = data.start_date + timedelta(weeks=weeks)
        elif data.end_date and target_opening and data.end_date < target_opening:
            raise BusinessException("Ngày kết thúc lớp học không được trước ngày mở lớp.")

        initial_status = "PLANNING" if (target_opening and target_opening > today) else "OPEN_FOR_ENROLLMENT"
        cls = Class(
            class_code=data.class_code,
            course_id=data.course_id,
            teacher_id=data.teacher_id,
            max_capacity=data.max_capacity,
            current_enrolled=0,
            opening_date=target_opening,
            start_date=data.start_date,
            end_date=calculated_end_date,
            status=initial_status
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
            ClassService.validate_class_status_transition(cls, data.status)
            cls.status = data.status
        
        db.commit()
        db.refresh(cls)
        return ClassService._format_class_response(cls)

    @staticmethod
    def validate_class_status_transition(cls: Class, new_status: str, today: Optional[date] = None):
        """Kiểm soát chuyển đổi trạng thái lớp học (State Machine Guard):
        - Chỉ chấp nhận các trạng thái hợp lệ trong vòng đời: PLANNING, OPEN_FOR_ENROLLMENT, IN_PROGRESS, COMPLETED, CANCELLED
        - Lớp đã COMPLETED hoặc CANCELLED thì không thể đổi trạng thái
        - Lớp IN_PROGRESS không được chuyển ngược về PLANNING hoặc OPEN_FOR_ENROLLMENT
        - Không thể chuyển sang IN_PROGRESS nếu chưa đến ngày bắt đầu (start_date)
        - Không thể chuyển sang COMPLETED nếu chưa đến ngày kết thúc (end_date)
        """
        valid_statuses = {"PLANNING", "OPEN_FOR_ENROLLMENT", "IN_PROGRESS", "COMPLETED", "CANCELLED"}
        if new_status not in valid_statuses:
            raise BusinessException(f"Trạng thái lớp học '{new_status}' không hợp lệ. Các trạng thái hợp lệ: {', '.join(sorted(valid_statuses))}")

        if cls.status == new_status:
            return

        if cls.status in ["COMPLETED", "CANCELLED"]:
            raise BusinessException(f"Không thể thay đổi trạng thái của lớp học đã ở trạng thái '{cls.status}'.")

        if cls.status == "IN_PROGRESS" and new_status in ["PLANNING", "OPEN_FOR_ENROLLMENT"]:
            raise BusinessException("Lớp đang học (IN_PROGRESS) không thể chuyển ngược về mở đăng ký hoặc lập kế hoạch.")

        if not today:
            today = date.today()

        if new_status == "IN_PROGRESS":
            if cls.start_date and today < cls.start_date:
                raise BusinessException(f"Lớp học chưa đến ngày bắt đầu ({cls.start_date}), không thể chuyển sang trạng thái đang học (IN_PROGRESS).")

        if new_status == "COMPLETED":
            if cls.end_date and today < cls.end_date:
                raise BusinessException(f"Lớp học chưa đến ngày kết thúc ({cls.end_date}), không thể chuyển sang trạng thái hoàn thành (COMPLETED).")

    @staticmethod
    def sync_class_lifecycle(cls: Class, today: Optional[date] = None) -> bool:
        """Tự động đồng bộ trạng thái lớp học theo ngày mà không phụ thuộc số lượng học viên:
        - PLANNING -> OPEN_FOR_ENROLLMENT nếu opening_date <= today < start_date
        - OPEN_FOR_ENROLLMENT -> IN_PROGRESS nếu today >= start_date và today <= end_date
        - OPEN_FOR_ENROLLMENT/IN_PROGRESS -> COMPLETED nếu today > end_date
        """
        if not cls or cls.is_deleted or cls.status in ["CANCELLED", "COMPLETED"]:
            return False

        if not today:
            today = date.today()

        changed = False
        if cls.status == "PLANNING":
            if cls.opening_date and today >= cls.opening_date:
                if cls.start_date and today >= cls.start_date:
                    if cls.end_date and today > cls.end_date:
                        cls.status = "COMPLETED"
                    else:
                        cls.status = "IN_PROGRESS"
                else:
                    cls.status = "OPEN_FOR_ENROLLMENT"
                changed = True
        elif cls.status == "OPEN_FOR_ENROLLMENT":
            if cls.start_date and today >= cls.start_date:
                if cls.end_date and today > cls.end_date:
                    cls.status = "COMPLETED"
                else:
                    cls.status = "IN_PROGRESS"
                changed = True
        elif cls.status == "IN_PROGRESS":
            if cls.end_date and today > cls.end_date:
                cls.status = "COMPLETED"
                changed = True

        return changed

    @staticmethod
    def list_classes(
        db: Session, 
        q: Optional[str] = None, 
        course_id: Optional[int] = None, 
        status: Optional[str] = None,
        student_id: Optional[int] = None,
        teacher_id: Optional[int] = None
    ) -> List[dict]:
        # Đồng bộ vòng đời các lớp học theo ngày thực tế trước khi lọc
        today = date.today()
        all_active = db.query(Class).filter(Class.is_deleted == False).all()
        any_changed = False
        for c in all_active:
            if ClassService.sync_class_lifecycle(c, today):
                any_changed = True
        if any_changed:
            db.commit()

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
            query = query.filter(Class.status == status)
        
        return [ClassService._format_class_response(c, is_enrolled=(c.id in enrolled_ids)) for c in query.all()]

    @staticmethod
    def get_class_detail(db: Session, class_id: int) -> dict:
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)
        if ClassService.sync_class_lifecycle(cls):
            db.commit()
            db.refresh(cls)
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
        
        # BR-01: Kiểm tra điều kiện tiên quyết trước khi thêm học viên vào lớp
        from app.modules.enrollments.service import EnrollmentService
        is_eligible, prereq_msg = EnrollmentService.check_prerequisite_eligibility(db, student_id, class_id)
        if not is_eligible:
            raise BusinessException(prereq_msg)

        existing = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.is_deleted == False
        ).first()
        if existing:
            raise BusinessException("Học viên này đã có trong danh sách lớp.")
        
        enrollment = ClassStudent(class_id=class_id, student_id=student_id, status="ENROLLED")
        db.add(enrollment)
        
        # Tạo sẵn bản ghi điểm nếu lớp đang học hoặc đã hoàn thành
        if cls.status in ["IN_PROGRESS", "COMPLETED"]:
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
        ClassService.validate_class_status_transition(cls, new_status)
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
    def check_classes_schedule_overlap(sessions1: list, sessions2: list) -> bool:
        """Kiểm tra xem 2 danh sách ca học có bị trùng lịch hoặc giao nhau thời gian (overlap) hay không.
        Giao nhau nếu cùng ngày (hoặc cùng thứ) và: max(start1, start2) < min(end1, end2) (tương đương start1 < end2 and start2 < end1).
        """
        if not sessions1 or not sessions2:
            return False

        for s1 in sessions1:
            for s2 in sessions2:
                # 1. Trùng ngày cụ thể và giao nhau khung giờ
                if s1.session_date and s2.session_date and s1.session_date == s2.session_date:
                    if str(s1.start_time) < str(s2.end_time) and str(s2.start_time) < str(s1.end_time):
                        return True
                # 2. Trùng thứ trong tuần (recurring schedule) và giao nhau khung giờ
                if s1.session_date and s2.session_date and s1.session_date.weekday() == s2.session_date.weekday():
                    if str(s1.start_time) < str(s2.end_time) and str(s2.start_time) < str(s1.end_time):
                        return True
        return False

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

        # Không cho phép chuyển lớp nếu lớp hiện tại đã kết thúc hoặc bị hủy
        ClassService.sync_class_lifecycle(curr_cls)
        if curr_cls.status in ["COMPLETED", "CANCELLED"]:
            return []

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

            # 2. Điều kiện: Khác thời khóa biểu và không giao nhau thời gian (M-02)
            cand_sessions = db.query(ScheduleSession).filter(
                ScheduleSession.class_id == cand.id,
                ScheduleSession.status != "CANCELLED",
                ScheduleSession.is_deleted == False
            ).all()

            if curr_sessions and cand_sessions and ClassService.check_classes_schedule_overlap(curr_sessions, cand_sessions):
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

        # 0. Đồng bộ vòng đời và kiểm tra trạng thái lớp hiện tại
        ClassService.sync_class_lifecycle(curr_cls)
        ClassService.sync_class_lifecycle(target_cls)
        if curr_cls.status in ["COMPLETED", "CANCELLED"]:
            raise BusinessException(f"Không thể chuyển lớp: Lớp hiện tại đang ở trạng thái '{curr_cls.status}'.")

        # 1. Kiểm tra cùng khóa học (H-02)
        if curr_cls.course_id != target_cls.course_id:
            raise BusinessException("Không thể chuyển lớp: Lớp đích phải thuộc cùng khóa học với lớp hiện tại.")

        # 2. Kiểm tra thông tin học viên tồn tại và hợp lệ
        from app.modules.students.models import Student
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)

        # 3. Kiểm tra học viên đang là thành viên chính thức của lớp hiện tại
        curr_cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == current_class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if not curr_cs:
            raise BusinessException("Học viên hiện không đang theo học tại lớp học này.")

        # 4. Kiểm tra trạng thái hoàn thành hoặc khóa sổ điểm của lớp đích (H-04)
        from app.modules.grades.service import GradeService
        is_locked, _ = GradeService.check_and_update_class_grade_lock(db, target_cls)
        if is_locked or target_cls.status == "COMPLETED":
            raise BusinessException(f"Không thể chuyển lớp: Lớp đích {target_cls.class_code} đã hoàn thành hoặc đã khóa sổ điểm.")

        if target_cls.status not in ["OPEN_FOR_ENROLLMENT", "IN_PROGRESS"]:
            raise BusinessException(f"Lớp học đích đang ở trạng thái '{target_cls.status}', không thể tiếp nhận chuyển lớp.")

        # 5. Kiểm tra sĩ số lớp đích
        if (target_cls.current_enrolled or 0) >= target_cls.max_capacity:
            raise BusinessException("Lớp học đích đã đủ sĩ số tối đa, không thể tiếp nhận chuyển lớp.")

        # 6. Kiểm tra giảng viên khác nhau
        if curr_cls.teacher_id and target_cls.teacher_id and curr_cls.teacher_id == target_cls.teacher_id:
            raise BusinessException("Không thể chuyển lớp: Lớp đích phải có giảng viên khác với giảng viên phụ trách lớp hiện tại (không được cùng giảng viên).")

        # 7. Kiểm tra thời khóa biểu khác nhau và không giao nhau thời gian (M-02)
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
            if ClassService.check_classes_schedule_overlap(curr_sessions, target_sessions):
                raise BusinessException("Không thể chuyển lớp: Lớp đích có thời khóa biểu trùng hoặc giao nhau với lớp hiện tại. Vui lòng chọn lớp có thời khóa biểu khác.")

        # 8. Kiểm tra không đăng ký trùng lặp ở lớp đích
        already_in_target = db.query(ClassStudent).filter(
            ClassStudent.class_id == target_class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if already_in_target:
            raise BusinessException("Học viên đã là thành viên chính thức của lớp học đích.")

        # 9. Kiểm tra điểm đã được xác nhận ở lớp đích (H-04)
        target_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == target_class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()
        if target_grade and target_grade.is_confirmed:
            raise BusinessException("Không thể chuyển lớp: Học viên đã có điểm được xác nhận ở lớp đích.")

        # 10. BR-01: Kiểm tra điều kiện tiên quyết đối với lớp đích
        from app.modules.enrollments.service import EnrollmentService
        is_eligible, prereq_msg = EnrollmentService.check_prerequisite_eligibility(db, student_id, target_class_id)
        if not is_eligible:
            raise BusinessException(prereq_msg)

        # THỰC HIỆN CHUYỂN LỚP NHẤT QUÁN:
        # a. Cập nhật sĩ số nguyên tử (Atomic Conditional Update) tránh race condition (M-03)
        res_target = db.query(Class).filter(
            Class.id == target_class_id,
            Class.is_deleted == False,
            Class.current_enrolled < Class.max_capacity
        ).update(
            {Class.current_enrolled: Class.current_enrolled + 1},
            synchronize_session="fetch"
        )
        if res_target == 0:
            raise BusinessException("Lớp học đích đã đủ sĩ số tối đa, không thể tiếp nhận chuyển lớp.")

        db.query(Class).filter(
            Class.id == current_class_id,
            Class.is_deleted == False,
            Class.current_enrolled > 0
        ).update(
            {Class.current_enrolled: Class.current_enrolled - 1},
            synchronize_session="fetch"
        )

        # b. Hủy tư cách thành viên lớp cũ
        curr_cs.status = "TRANSFERRED"
        curr_cs.is_deleted = True

        # c. Ghi danh chính thức vào lớp mới (tránh trùng khóa unique nếu có bản ghi cũ)
        existing_target_cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == target_class_id,
            ClassStudent.student_id == student_id
        ).first()
        if existing_target_cs:
            existing_target_cs.status = "ENROLLED"
            existing_target_cs.is_deleted = False
        else:
            new_cs = ClassStudent(class_id=target_class_id, student_id=student_id, status="ENROLLED")
            db.add(new_cs)

        # d. Bảo toàn và đồng bộ sổ điểm sang lớp mới
        curr_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == current_class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()

        if target_grade:
            if curr_grade:
                if curr_grade.attendance_score is not None:
                    target_grade.attendance_score = curr_grade.attendance_score
                if curr_grade.midterm_score is not None:
                    target_grade.midterm_score = curr_grade.midterm_score
                if curr_grade.final_score is not None:
                    target_grade.final_score = curr_grade.final_score
                if curr_grade.total_score is not None:
                    target_grade.total_score = curr_grade.total_score
                if curr_grade.result_status:
                    target_grade.result_status = curr_grade.result_status
            target_grade.note = f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển lớp học'}"
        else:
            new_grade = GradeRecord(
                class_id=target_class_id,
                student_id=student_id,
                attendance_score=curr_grade.attendance_score if curr_grade else 0.0,
                midterm_score=curr_grade.midterm_score if curr_grade else 0.0,
                final_score=curr_grade.final_score if curr_grade else 0.0,
                total_score=curr_grade.total_score if curr_grade else 0.0,
                result_status=curr_grade.result_status if curr_grade else "PENDING",
                note=f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển lớp học'}"
            )
            db.add(new_grade)

        # Không để bản ghi điểm cũ tiếp tục "active" ở lớp cũ sau khi chuyển lớp
        # (tránh my-grades/parent grades hiển thị trùng 2 lớp và sai tổng kết).
        if curr_grade:
            curr_grade.is_deleted = True

        # 4. Ghi nhận lịch sử duyệt ghi danh làm audit log (H-05)
        transfer_audit = EnrollmentRequest(
            student_id=student_id,
            class_id=target_class_id,
            note=f"[TRANSFER_AUDIT] Chuyển lớp từ {curr_cls.class_code} sang {target_cls.class_code}. Lý do: {reason or 'Chuyển lớp học'}",
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

