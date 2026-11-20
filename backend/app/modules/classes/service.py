import re
from typing import List, Optional
from datetime import timedelta, date, datetime, timezone
from sqlalchemy.orm import Session
from app.modules.classes.models import Class, ClassStudent
from app.modules.courses.models import Course
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student
from app.modules.grades.models import GradeRecord
from app.modules.enrollments.models import EnrollmentRequest
from app.core.permissions import RoleEnum
from app.core.exceptions import BusinessException, NotFoundException, ForbiddenException
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
                enrolled_at=r.enrolled_at or r.created_at,
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
    def parse_course_level(course: Optional[Course]) -> tuple[str, Optional[float]]:
        """Phân tích chuẩn hóa phân hệ và xếp hạng cấp độ của Course:
        - IELTS: 5.0, 6.0, 6.5, 7.5, 8.0...
        - TOEIC: 550, 750, 850...
        - CEFR: A1 (1.0), A2 (2.0), B1 (3.0), B2 (4.0), C1 (5.0), C2 (6.0)
        - UNKNOWN: Cấp độ không xác định
        """
        if not course:
            return ("UNKNOWN", None)
        tl = (course.target_level or "").strip().upper()
        cd = (course.code or "").strip().upper()
        tt = (course.title or "").strip().upper()
        combined = f"{tl} {cd} {tt}"

        # 1. Phân hệ IELTS
        if "IELTS" in combined:
            match = re.search(r"IELTS\s*(\d+(?:\.\d+)?)", combined)
            if match:
                return ("IELTS", float(match.group(1)))
            if "80" in cd or "8.0" in combined or "C1" in tl:
                return ("IELTS", 8.0)
            if "75" in cd or "7.5" in combined:
                return ("IELTS", 7.5)
            if "65" in cd or "6.5" in combined:
                return ("IELTS", 6.5)
            if "50" in cd or "5.0" in combined:
                return ("IELTS", 5.0)
            return ("IELTS", None)

        # 2. Phân hệ TOEIC
        if "TOEIC" in combined:
            match = re.search(r"TOEIC\s*(\d+)", combined)
            if match:
                return ("TOEIC", float(match.group(1)))
            if "850" in combined:
                return ("TOEIC", 850.0)
            if "750" in combined:
                return ("TOEIC", 750.0)
            if "550" in combined:
                return ("TOEIC", 550.0)
            return ("TOEIC", None)

        # 3. Phân hệ CEFR (A1 -> C2)
        cefr_map = {
            "A1": 1.0, "STARTERS": 1.0, "MOVERS": 1.0,
            "A2": 2.0, "FLYERS": 2.0,
            "B1": 3.0,
            "B2": 4.0,
            "C1": 5.0,
            "C2": 6.0
        }
        for k, v in cefr_map.items():
            if re.search(rf"\b{k}\b", combined):
                return ("CEFR", v)

        return ("UNKNOWN", None)

    @staticmethod
    def get_level_relation(source_course: Optional[Course], target_course: Optional[Course]) -> str:
        """Xác định mối quan hệ cấp độ giữa hai khóa học:
        - SAME_LEVEL: Cùng cấp độ
        - HIGHER_LEVEL: Cấp độ cao hơn
        - LOWER_LEVEL: Cấp độ thấp hơn
        - UNKNOWN_LEVEL: Cấp độ không xác định hoặc không cùng thang đo
        """
        if not source_course or not target_course:
            return "UNKNOWN_LEVEL"
        if source_course.id == target_course.id:
            return "SAME_LEVEL"

        src_track, src_rank = ClassService.parse_course_level(source_course)
        tgt_track, tgt_rank = ClassService.parse_course_level(target_course)

        if src_track == "UNKNOWN" or tgt_track == "UNKNOWN" or src_track != tgt_track or src_rank is None or tgt_rank is None:
            return "UNKNOWN_LEVEL"

        if tgt_rank == src_rank:
            return "SAME_LEVEL"
        elif tgt_rank > src_rank:
            return "HIGHER_LEVEL"
        else:
            return "LOWER_LEVEL"

    @staticmethod
    def extract_source_class_id(note: Optional[str]) -> Optional[int]:
        if not note:
            return None
        match = re.search(r"\[TRANSFER_REQUEST:source_id=(\d+)\]", note)
        if match:
            return int(match.group(1))
        return None

    @staticmethod
    def extract_transfer_reason(note: Optional[str]) -> Optional[str]:
        if not note:
            return None
        clean = re.sub(r"\[TRANSFER_REQUEST:source_id=\d+\]\s*", "", note)
        return clean.strip() or None

    @staticmethod
    def check_transfer_conditions(
        db: Session,
        student_id: int,
        current_class_id: int,
        target_class_id: int,
        is_approval: bool = False
    ) -> dict:
        """Kiểm tra toàn diện 10 điều kiện chuyển lớp:
        1. Học viên thuộc lớp nguồn hợp lệ (ClassStudent ENROLLED).
        2. Lớp đích tồn tại.
        3. Lớp nguồn và đích khác nhau.
        4. Lớp đích cho phép tiếp nhận (chưa hoàn thành, chưa khóa sổ điểm).
        5. Lớp đích còn sức chứa.
        6. Lớp đích có trạng thái phù hợp (OPEN_FOR_ENROLLMENT hoặc IN_PROGRESS).
        7. Không bị đăng ký trùng lặp ở lớp đích.
        8. Không trùng thời khóa biểu giữa hai lớp.
        9. Giảng viên phụ trách khác nhau.
        10. Điều kiện cấp độ và PASS/FAIL:
            - Cùng cấp độ (SAME_LEVEL): Không yêu cầu PASS lớp hiện tại.
            - Cao hơn (HIGHER_LEVEL): Bắt buộc hoàn thành và PASS cấp độ trước.
            - Thấp hơn (LOWER_LEVEL): Được phép.
            - Không xác định (UNKNOWN_LEVEL): Từ chối an toàn.
        11. Không có yêu cầu chuyển lớp khác đang chờ xử lý (chỉ check khi tạo mới).
        """
        from app.modules.schedules.models import ScheduleSession
        from app.modules.grades.service import GradeService
        from app.modules.enrollments.service import EnrollmentService
        from app.modules.progression_parent.models import CourseProgression

        checklist = []
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            return {
                "is_eligible": False,
                "checklist": [{"code": "STUDENT_EXISTS", "name": "Hồ sơ học viên", "passed": False, "message": "Không tìm thấy hồ sơ học viên."}],
                "level_relation": "UNKNOWN_LEVEL",
                "failure_reason": "Không tìm thấy hồ sơ học viên."
            }

        curr_cls = db.query(Class).filter(Class.id == current_class_id, Class.is_deleted == False).first()
        target_cls = db.query(Class).filter(Class.id == target_class_id, Class.is_deleted == False).first()

        # Check 1: Lớp nguồn & đích hợp lệ, không cùng một lớp
        if not curr_cls:
            checklist.append({"code": "CLASS_VALIDITY", "name": "Lớp học hợp lệ", "passed": False, "message": f"Không tìm thấy lớp học hiện tại (ID: {current_class_id})."})
        elif not target_cls:
            checklist.append({"code": "CLASS_VALIDITY", "name": "Lớp học hợp lệ", "passed": False, "message": f"Không tìm thấy lớp học đích (ID: {target_class_id})."})
        elif current_class_id == target_class_id:
            checklist.append({"code": "CLASS_VALIDITY", "name": "Lớp học hợp lệ", "passed": False, "message": "Không thể chuyển lớp: Lớp đích phải là một lớp khác với lớp hiện tại."})
        else:
            checklist.append({"code": "CLASS_VALIDITY", "name": "Lớp học hợp lệ", "passed": True, "message": f"Chuyển từ lớp {curr_cls.class_code} sang {target_cls.class_code}."})

        # Check 2: Học viên là thành viên chính thức của lớp nguồn
        curr_cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == current_class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if not curr_cs:
            checklist.append({"code": "SOURCE_ENROLLMENT", "name": "Thành viên lớp nguồn", "passed": False, "message": "Học viên hiện không đang theo học (ENROLLED) tại lớp học này."})
        else:
            checklist.append({"code": "SOURCE_ENROLLMENT", "name": "Thành viên lớp nguồn", "passed": True, "message": f"Học viên đang học chính thức tại {curr_cls.class_code if curr_cls else ''}."})

        # Check 3: Trạng thái lớp nguồn
        if curr_cls:
            ClassService.sync_class_lifecycle(curr_cls)
            if curr_cls.status in ["COMPLETED", "CANCELLED"]:
                checklist.append({"code": "SOURCE_STATUS", "name": "Trạng thái lớp nguồn", "passed": False, "message": f"Không thể chuyển lớp: Lớp hiện tại đang ở trạng thái '{curr_cls.status}'."})
            else:
                checklist.append({"code": "SOURCE_STATUS", "name": "Trạng thái lớp nguồn", "passed": True, "message": f"Lớp nguồn đang hoạt động ({curr_cls.status})."})

        # Check 4: Trạng thái lớp đích và khóa sổ điểm
        if target_cls:
            ClassService.sync_class_lifecycle(target_cls)
            is_locked, _ = GradeService.check_and_update_class_grade_lock(db, target_cls)
            if is_locked or target_cls.status == "COMPLETED":
                checklist.append({"code": "TARGET_STATUS", "name": "Trạng thái lớp đích", "passed": False, "message": f"Không thể chuyển lớp: Lớp đích {target_cls.class_code} đã hoàn thành hoặc đã khóa sổ điểm."})
            elif target_cls.status not in ["OPEN_FOR_ENROLLMENT", "IN_PROGRESS"]:
                checklist.append({"code": "TARGET_STATUS", "name": "Trạng thái lớp đích", "passed": False, "message": f"Lớp học đích đang ở trạng thái '{target_cls.status}', không thể tiếp nhận chuyển lớp."})
            else:
                checklist.append({"code": "TARGET_STATUS", "name": "Trạng thái lớp đích", "passed": True, "message": f"Lớp đích sẵn sàng tiếp nhận ({target_cls.status})."})

        # Check 5: Sức chứa lớp đích
        if target_cls:
            curr_enrolled = target_cls.current_enrolled or 0
            if curr_enrolled >= target_cls.max_capacity:
                checklist.append({"code": "TARGET_CAPACITY", "name": "Sĩ số lớp đích", "passed": False, "message": f"Lớp học đích đã đủ sĩ số tối đa ({curr_enrolled}/{target_cls.max_capacity})."})
            else:
                checklist.append({"code": "TARGET_CAPACITY", "name": "Sĩ số lớp đích", "passed": True, "message": f"Lớp học đích còn {target_cls.max_capacity - curr_enrolled} chỗ ({curr_enrolled}/{target_cls.max_capacity})."})

        # Check 6: Giảng viên phụ trách
        if curr_cls and target_cls:
            if curr_cls.teacher_id and target_cls.teacher_id and curr_cls.teacher_id == target_cls.teacher_id:
                checklist.append({"code": "TEACHER_DIFFERENCE", "name": "Giảng viên phụ trách", "passed": False, "message": "Không thể chuyển lớp: Lớp đích phải có giảng viên khác với giảng viên phụ trách lớp hiện tại (không được cùng giảng viên)."})
            else:
                checklist.append({"code": "TEACHER_DIFFERENCE", "name": "Giảng viên phụ trách", "passed": True, "message": "Giảng viên lớp đích phù hợp."})

        # Check 7: Trùng thời khóa biểu
        if curr_cls and target_cls:
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
            if curr_sessions and target_sessions and ClassService.check_classes_schedule_overlap(curr_sessions, target_sessions):
                checklist.append({"code": "SCHEDULE_CONFLICT", "name": "Thời khóa biểu", "passed": False, "message": "Không thể chuyển lớp: Lớp đích có thời khóa biểu trùng hoặc giao nhau với lớp hiện tại. Vui lòng chọn lớp có thời khóa biểu khác."})
            else:
                checklist.append({"code": "SCHEDULE_CONFLICT", "name": "Thời khóa biểu", "passed": True, "message": "Thời khóa biểu lớp đích không bị trùng lặp."})

        # Check 8: Trùng đăng ký ở lớp đích
        already_in_target = db.query(ClassStudent).filter(
            ClassStudent.class_id == target_class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if already_in_target:
            checklist.append({"code": "DUPLICATE_ENROLLMENT", "name": "Đăng ký trùng lặp", "passed": False, "message": "Học viên đã là thành viên chính thức của lớp học đích."})
        else:
            checklist.append({"code": "DUPLICATE_ENROLLMENT", "name": "Đăng ký trùng lặp", "passed": True, "message": "Chưa từng ghi danh ở lớp đích."})

        # Check 9: Điểm đã xác nhận ở lớp đích
        target_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == target_class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()
        if target_grade and target_grade.is_confirmed:
            checklist.append({"code": "CONFIRMED_GRADE_TARGET", "name": "Điểm lớp đích", "passed": False, "message": "Không thể chuyển lớp: Học viên đã có điểm được xác nhận ở lớp đích."})
        else:
            checklist.append({"code": "CONFIRMED_GRADE_TARGET", "name": "Điểm lớp đích", "passed": True, "message": "Chưa có điểm xác nhận ở lớp đích."})

        # Check 10: Cấp độ & Điều kiện PASS/FAIL
        level_relation = "UNKNOWN_LEVEL"
        if curr_cls and target_cls:
            level_relation = ClassService.get_level_relation(curr_cls.course, target_cls.course)

        if level_relation == "SAME_LEVEL":
            checklist.append({
                "code": "LEVEL_AND_PREREQUISITE",
                "name": "Cấp độ & Tiên quyết",
                "passed": True,
                "message": "Chuyển sang lớp cùng cấp độ: Không yêu cầu hoàn thành hoặc PASS lớp hiện tại."
            })
        elif level_relation == "LOWER_LEVEL":
            checklist.append({
                "code": "LEVEL_AND_PREREQUISITE",
                "name": "Cấp độ & Tiên quyết",
                "passed": True,
                "message": "Chuyển xuống lớp cấp độ thấp hơn: Được phép theo chính sách chuyển lớp."
            })
        elif level_relation == "UNKNOWN_LEVEL":
            curr_grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == current_class_id,
                GradeRecord.student_id == student_id,
                GradeRecord.is_deleted == False
            ).first()

            has_passed = curr_grade is not None and curr_grade.result_status == "PASSED" and curr_grade.is_confirmed
            if has_passed:
                checklist.append({
                    "code": "LEVEL_AND_PREREQUISITE",
                    "name": "Cấp độ & Tiên quyết",
                    "passed": True,
                    "message": "Chuyển sang chương trình đào tạo khác: Học viên đã hoàn thành và PASS lớp hiện tại."
                })
            else:
                checklist.append({
                    "code": "LEVEL_AND_PREREQUISITE",
                    "name": "Cấp độ & Tiên quyết",
                    "passed": False,
                    "message": "Cấp độ không xác định hoặc khác lộ trình: Học viên chưa hoàn thành hoặc chưa đạt (PASS) ở lớp hiện tại."
                })
        elif level_relation == "HIGHER_LEVEL":
            has_passed = False
            fail_reason = ""

            curr_grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == current_class_id,
                GradeRecord.student_id == student_id,
                GradeRecord.is_deleted == False
            ).first()

            if curr_grade:
                if curr_grade.result_status == "PASSED" and curr_grade.is_confirmed:
                    has_passed = True
                elif curr_grade.result_status == "FAILED":
                    fail_reason = "Học viên chưa hoàn thành hoặc chưa đạt (PASS) ở lớp cấp độ hiện tại."
                elif not curr_grade.is_confirmed or curr_grade.result_status == "PENDING":
                    fail_reason = "Học viên chưa có điểm tổng kết được xác nhận ở lớp cấp độ hiện tại (chưa hoàn thành hoặc chưa đạt (PASS))."
                elif curr_cls.status == "IN_PROGRESS":
                    fail_reason = "Học viên chưa hoàn thành lớp học cấp độ hiện tại."
            else:
                approved_prog = db.query(CourseProgression).filter(
                    CourseProgression.student_id == student_id,
                    CourseProgression.next_course_id == target_cls.course_id,
                    CourseProgression.is_eligible == True,
                    CourseProgression.is_confirmed == True,
                    CourseProgression.is_deleted == False
                ).first()

                if approved_prog:
                    has_passed = True
                else:
                    is_elig, prereq_msg = EnrollmentService.check_prerequisite_eligibility(db, student_id, target_class_id)
                    if is_elig:
                        has_passed = True
                    else:
                        fail_reason = prereq_msg or "Học viên chưa hoàn thành lớp học cấp độ hiện tại."

            if has_passed:
                checklist.append({
                    "code": "LEVEL_AND_PREREQUISITE",
                    "name": "Cấp độ & Tiên quyết",
                    "passed": True,
                    "message": "Học viên đã hoàn thành và PASS cấp độ trước. Đủ điều kiện chuyển lên cấp độ cao hơn."
                })
            else:
                checklist.append({
                    "code": "LEVEL_AND_PREREQUISITE",
                    "name": "Cấp độ & Tiên quyết",
                    "passed": False,
                    "message": fail_reason or "Chưa đạt yêu cầu của lớp học cấp độ hiện tại. Vui lòng hoàn thành và PASS lớp học trước khi chuyển lên cấp độ cao hơn."
                })

        # Check 11: Yêu cầu chuyển lớp đang chờ xử lý
        if not is_approval:
            pending_req = db.query(EnrollmentRequest).filter(
                EnrollmentRequest.student_id == student_id,
                EnrollmentRequest.status == "PENDING",
                EnrollmentRequest.note.like(f"[TRANSFER_REQUEST:source_id={current_class_id}]%")
            ).first()
            if pending_req:
                checklist.append({
                    "code": "PENDING_REQUEST",
                    "name": "Đơn chờ xử lý",
                    "passed": False,
                    "message": "Học viên đã có yêu cầu chuyển lớp cho lớp học này đang chờ xử lý."
                })
            else:
                checklist.append({
                    "code": "PENDING_REQUEST",
                    "name": "Đơn chờ xử lý",
                    "passed": True,
                    "message": "Không có yêu cầu chuyển lớp nào đang chờ xử lý."
                })

        is_eligible = all(item["passed"] for item in checklist)
        failed_items = [item for item in checklist if not item["passed"]]
        failure_reason = failed_items[0]["message"] if failed_items else None

        return {
            "is_eligible": is_eligible,
            "checklist": checklist,
            "level_relation": level_relation,
            "failure_reason": failure_reason
        }

    @staticmethod
    def create_transfer_request(
        db: Session,
        student_id: int,
        current_class_id: int,
        target_class_id: int,
        reason: Optional[str] = None
    ) -> dict:
        """Tạo yêu cầu chuyển lớp ở trạng thái chờ phê duyệt (PENDING):
        Hệ thống tự động kiểm tra toàn diện điều kiện nghiệp vụ.
        Nếu không đủ điều kiện bắt buộc, từ chối tạo yêu cầu và hiển thị lý do cụ thể.
        Không tự động chuyển lớp ngay khi học viên gửi yêu cầu!
        """
        eval_result = ClassService.check_transfer_conditions(
            db, student_id, current_class_id, target_class_id, is_approval=False
        )
        if not eval_result["is_eligible"]:
            raise BusinessException(eval_result["failure_reason"])

        note_str = f"[TRANSFER_REQUEST:source_id={current_class_id}] {reason.strip() if reason else ''}".strip()
        req = EnrollmentRequest(
            student_id=student_id,
            class_id=target_class_id,
            status="PENDING",
            note=note_str,
            request_date=datetime.now(timezone.utc)
        )
        db.add(req)
        db.commit()
        db.refresh(req)
        return ClassService.format_transfer_request_detail(db, req, eval_result)

    @staticmethod
    def format_transfer_request_item(db: Session, req: EnrollmentRequest) -> dict:
        student = req.student
        user = student.user if student else None
        target_cls = req.enrolled_class
        source_class_id = ClassService.extract_source_class_id(req.note)
        curr_cls = db.query(Class).filter(Class.id == source_class_id).first() if source_class_id else None
        reviewer = req.reviewer

        level_relation = "UNKNOWN_LEVEL"
        if curr_cls and target_cls:
            level_relation = ClassService.get_level_relation(curr_cls.course, target_cls.course)

        return {
            "id": req.id,
            "student_id": req.student_id,
            "student_code": student.student_code if student else "",
            "student_name": user.full_name if user else "",
            "source_class_id": source_class_id or 0,
            "source_class_code": curr_cls.class_code if curr_cls else "Không rõ",
            "source_course_title": curr_cls.course.title if (curr_cls and curr_cls.course) else "",
            "source_target_level": curr_cls.course.target_level if (curr_cls and curr_cls.course) else "",
            "target_class_id": req.class_id,
            "target_class_code": target_cls.class_code if target_cls else "",
            "target_course_title": target_cls.course.title if (target_cls and target_cls.course) else "",
            "target_target_level": target_cls.course.target_level if (target_cls and target_cls.course) else "",
            "level_relation": level_relation,
            "status": req.status,
            "reason": ClassService.extract_transfer_reason(req.note),
            "rejection_reason": req.rejection_reason,
            "request_date": req.request_date or req.created_at,
            "reviewed_at": req.reviewed_at,
            "reviewer_name": reviewer.full_name if reviewer else None
        }

    @staticmethod
    def format_transfer_request_detail(db: Session, req: EnrollmentRequest, eval_result: Optional[dict] = None) -> dict:
        student = req.student
        user = student.user if student else None
        target_cls = req.enrolled_class
        source_class_id = ClassService.extract_source_class_id(req.note)
        curr_cls = db.query(Class).filter(Class.id == source_class_id).first() if source_class_id else None
        reviewer = req.reviewer

        if eval_result is None and source_class_id:
            eval_result = ClassService.check_transfer_conditions(
                db, req.student_id, source_class_id, req.class_id, is_approval=(req.status != "PENDING")
            )
        elif eval_result is None:
            eval_result = {"is_eligible": False, "checklist": [], "level_relation": "UNKNOWN_LEVEL"}

        level_relation = eval_result.get("level_relation") or "UNKNOWN_LEVEL"
        checklist = eval_result.get("checklist") or []

        target_teacher_name = target_cls.teacher.user.full_name if (target_cls and target_cls.teacher and target_cls.teacher.user) else "Chưa phân công"
        source_teacher_name = curr_cls.teacher.user.full_name if (curr_cls and curr_cls.teacher and curr_cls.teacher.user) else "Chưa phân công"

        cur_enr = target_cls.current_enrolled or 0 if target_cls else 0
        max_cap = target_cls.max_capacity if target_cls else 0
        avail = max(0, max_cap - cur_enr)

        return {
            "id": req.id,
            "student_id": req.student_id,
            "student_code": student.student_code if student else "",
            "student_name": user.full_name if user else "",
            "student_email": user.email if user else None,
            "student_phone": user.phone if user else None,
            "source_class_id": source_class_id or 0,
            "source_class_code": curr_cls.class_code if curr_cls else "Không rõ",
            "source_course_id": curr_cls.course_id if curr_cls else 0,
            "source_course_title": curr_cls.course.title if (curr_cls and curr_cls.course) else "",
            "source_target_level": curr_cls.course.target_level if (curr_cls and curr_cls.course) else "",
            "source_teacher_name": source_teacher_name,
            "target_class_id": req.class_id,
            "target_class_code": target_cls.class_code if target_cls else "",
            "target_course_id": target_cls.course_id if target_cls else 0,
            "target_course_title": target_cls.course.title if (target_cls and target_cls.course) else "",
            "target_target_level": target_cls.course.target_level if (target_cls and target_cls.course) else "",
            "target_teacher_name": target_teacher_name,
            "target_max_capacity": max_cap,
            "target_current_enrolled": cur_enr,
            "target_available_slots": avail,
            "target_status": target_cls.status if target_cls else "",
            "target_schedule_summary": None,
            "level_relation": level_relation,
            "status": req.status,
            "reason": ClassService.extract_transfer_reason(req.note),
            "rejection_reason": req.rejection_reason,
            "request_date": req.request_date or req.created_at,
            "reviewed_at": req.reviewed_at,
            "reviewer_name": reviewer.full_name if reviewer else None,
            "can_approve": (req.status == "PENDING" and eval_result.get("is_eligible", False)),
            "checklist": checklist
        }

    @staticmethod
    def list_transfer_requests(
        db: Session,
        user_payload: dict,
        status: Optional[str] = None,
        search: Optional[str] = None,
        class_id: Optional[int] = None
    ) -> List[dict]:
        user_role = user_payload.get("role")
        user_id = int(user_payload.get("sub", 0)) if "sub" in user_payload else user_payload.get("user_id")

        q = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.note.like("[TRANSFER_REQUEST:%")
        )

        if user_role == RoleEnum.STUDENT.value:
            from app.modules.students.models import Student
            student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
            if not student:
                return []
            q = q.filter(EnrollmentRequest.student_id == student.id)
        elif user_role == RoleEnum.TEACHER.value:
            from app.modules.teachers.models import Teacher
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            if not teacher:
                return []
            teacher_classes = [c.id for c in db.query(Class.id).filter(Class.teacher_id == teacher.id).all()]
            q = q.filter(EnrollmentRequest.class_id.in_(teacher_classes))

        if status:
            q = q.filter(EnrollmentRequest.status == status)

        if class_id:
            q = q.filter(EnrollmentRequest.class_id == class_id)

        q = q.order_by(EnrollmentRequest.id.desc())
        items = q.all()

        formatted_items = []
        for req in items:
            item = ClassService.format_transfer_request_item(db, req)
            if search:
                s = search.lower().strip()
                match = (
                    s in item["student_code"].lower()
                    or s in item["student_name"].lower()
                    or s in item["source_class_code"].lower()
                    or s in item["target_class_code"].lower()
                )
                if not match:
                    continue
            formatted_items.append(item)

        return formatted_items

    @staticmethod
    def get_transfer_request_detail(
        db: Session,
        request_id: int,
        user_payload: dict
    ) -> dict:
        req = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.id == request_id,
            EnrollmentRequest.note.like("[TRANSFER_REQUEST:%")
        ).first()
        if not req:
            raise NotFoundException("Yêu cầu chuyển lớp", request_id)

        user_role = user_payload.get("role")
        user_id = int(user_payload.get("sub", 0)) if "sub" in user_payload else user_payload.get("user_id")

        source_class_id = ClassService.extract_source_class_id(req.note)

        # 1. Học viên chỉ được xem yêu cầu của chính mình (chống IDOR)
        if user_role == RoleEnum.STUDENT.value:
            from app.modules.students.models import Student
            student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
            if not student or req.student_id != student.id:
                raise ForbiddenException("Bạn không có quyền truy cập yêu cầu chuyển lớp của học viên khác!")

        # 2. Giảng viên chỉ được xem yêu cầu trong phạm vi lớp được phân công (lớp đích hoặc lớp nguồn) (BUG-02 IDOR)
        elif user_role == RoleEnum.TEACHER.value:
            from app.modules.teachers.models import Teacher
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            if not teacher:
                raise ForbiddenException("Không tìm thấy thông tin giảng viên hoặc bạn không có quyền truy cập.")
            teacher_classes = [c.id for c in db.query(Class.id).filter(Class.teacher_id == teacher.id, Class.is_deleted == False).all()]
            has_permission = (req.class_id in teacher_classes) or (source_class_id and source_class_id in teacher_classes)
            if not has_permission:
                raise ForbiddenException("Giảng viên chỉ có quyền xem các yêu cầu chuyển lớp liên quan đến lớp học do mình phụ trách/giảng dạy.")

        # 3. Quản trị viên và Nhân viên học vụ có toàn quyền
        elif user_role in [RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value]:
            pass

        # 4. Các vai trò khác bị từ chối
        else:
            raise ForbiddenException("Bạn không có quyền truy cập chi tiết yêu cầu chuyển lớp.")

        return ClassService.format_transfer_request_detail(db, req)

    @staticmethod
    def approve_transfer_request(
        db: Session,
        request_id: int,
        reviewer_user_id: int
    ) -> dict:
        req = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.id == request_id,
            EnrollmentRequest.note.like("[TRANSFER_REQUEST:%")
        ).first()
        if not req:
            raise NotFoundException("Yêu cầu chuyển lớp", request_id)

        if req.status != "PENDING":
            raise BusinessException(f"Không thể phê duyệt: Yêu cầu chuyển lớp này đã được xử lý trước đó (trạng thái: {req.status}).")

        source_class_id = ClassService.extract_source_class_id(req.note)
        if not source_class_id:
            raise BusinessException("Yêu cầu chuyển lớp thiếu thông tin lớp học nguồn.")

        target_class_id = req.class_id

        # Kiểm tra lại toàn bộ điều kiện tại thời điểm phê duyệt
        eval_result = ClassService.check_transfer_conditions(
            db, req.student_id, source_class_id, target_class_id, is_approval=True
        )
        if not eval_result["is_eligible"]:
            raise BusinessException(f"Yêu cầu không còn đủ điều kiện phê duyệt: {eval_result['failure_reason']}")

        # Atomic concurrency lock (TC15): Đổi trạng thái sang PROCESSING
        claimed_req = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.id == request_id,
            EnrollmentRequest.status == "PENDING"
        ).update({EnrollmentRequest.status: "PROCESSING"}, synchronize_session="fetch")

        if claimed_req == 0:
            raise BusinessException("Yêu cầu chuyển lớp này đã được xử lý bởi người dùng khác hoặc không còn ở trạng thái chờ duyệt.")

        curr_cls = db.query(Class).filter(Class.id == source_class_id, Class.is_deleted == False).first()
        target_cls = db.query(Class).filter(Class.id == target_class_id, Class.is_deleted == False).first()

        try:
            # 1. Cập nhật sĩ số nguyên tử: Tăng sĩ số lớp đích
            res_target = db.query(Class).filter(
                Class.id == target_class_id,
                Class.is_deleted == False,
                Class.current_enrolled < Class.max_capacity
            ).update(
                {Class.current_enrolled: Class.current_enrolled + 1},
                synchronize_session="fetch"
            )
            if res_target == 0:
                raise BusinessException(f"Lớp học đích {target_cls.class_code} đã đủ sĩ số tối đa tại thời điểm phê duyệt.")

            # 2. Giảm sĩ số lớp nguồn
            db.query(Class).filter(
                Class.id == source_class_id,
                Class.is_deleted == False,
                Class.current_enrolled > 0
            ).update(
                {Class.current_enrolled: Class.current_enrolled - 1},
                synchronize_session="fetch"
            )

            # 3. Cập nhật ClassStudent lớp nguồn -> TRANSFERRED
            curr_cs = db.query(ClassStudent).filter(
                ClassStudent.class_id == source_class_id,
                ClassStudent.student_id == req.student_id,
                ClassStudent.status == "ENROLLED",
                ClassStudent.is_deleted == False
            ).first()
            if not curr_cs:
                raise BusinessException("Học viên không còn theo học tại lớp nguồn.")
            curr_cs.status = "TRANSFERRED"
            curr_cs.is_deleted = False

            # 4. Ghi danh chính thức vào lớp mới
            existing_target_cs = db.query(ClassStudent).filter(
                ClassStudent.class_id == target_class_id,
                ClassStudent.student_id == req.student_id
            ).first()
            if existing_target_cs:
                existing_target_cs.status = "ENROLLED"
                existing_target_cs.is_deleted = False
            else:
                new_cs = ClassStudent(class_id=target_class_id, student_id=req.student_id, status="ENROLLED")
                db.add(new_cs)

            # 5. Đồng bộ và bảo toàn sổ điểm (BUG-01)
            curr_grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == source_class_id,
                GradeRecord.student_id == req.student_id,
                GradeRecord.is_deleted == False
            ).first()

            target_grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == target_class_id,
                GradeRecord.student_id == req.student_id
            ).first()

            transfer_reason = ClassService.extract_transfer_reason(req.note)
            level_rel = ClassService.get_level_relation(curr_cls.course, target_cls.course)

            if level_rel == "SAME_LEVEL":
                # Chuyển ngang cấp / cùng khóa học: Bảo lưu tiến độ, điểm số và trạng thái xác nhận
                if target_grade:
                    target_grade.is_deleted = False
                    if curr_grade:
                        target_grade.attendance_score = curr_grade.attendance_score
                        target_grade.midterm_score = curr_grade.midterm_score
                        target_grade.final_score = curr_grade.final_score
                        target_grade.total_score = curr_grade.total_score
                        target_grade.result_status = curr_grade.result_status
                        target_grade.is_confirmed = curr_grade.is_confirmed
                    target_grade.note = f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {transfer_reason or 'Chuyển lớp cùng cấp độ'}"
                else:
                    new_grade = GradeRecord(
                        class_id=target_class_id,
                        student_id=req.student_id,
                        attendance_score=curr_grade.attendance_score if curr_grade else 0.0,
                        midterm_score=curr_grade.midterm_score if curr_grade else 0.0,
                        final_score=curr_grade.final_score if curr_grade else 0.0,
                        total_score=curr_grade.total_score if curr_grade else 0.0,
                        result_status=curr_grade.result_status if curr_grade else "PENDING",
                        is_confirmed=curr_grade.is_confirmed if curr_grade else False,
                        note=f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {transfer_reason or 'Chuyển lớp cùng cấp độ'}"
                    )
                    db.add(new_grade)

                # Bảo toàn lịch sử lớp nguồn: KHÔNG xóa mềm curr_grade
                if curr_grade:
                    curr_grade.note = (curr_grade.note or "") + f" [Đã chuyển sang lớp {target_cls.class_code}]"
                    curr_grade.is_deleted = False

            else:
                # Chuyển cấp độ khác (HIGHER_LEVEL hoặc LOWER_LEVEL):
                # Không biến điểm của lớp nguồn thành điểm của lớp đích. Lớp đích khởi tạo mới
                if target_grade:
                    target_grade.is_deleted = False
                    target_grade.attendance_score = 0.0
                    target_grade.midterm_score = 0.0
                    target_grade.final_score = 0.0
                    target_grade.total_score = 0.0
                    target_grade.result_status = "PENDING"
                    target_grade.is_confirmed = False
                    target_grade.note = f"Tiếp nhận học viên chuyển từ lớp {curr_cls.class_code}. Lý do: {transfer_reason or 'Chuyển cấp độ'}"
                else:
                    new_grade = GradeRecord(
                        class_id=target_class_id,
                        student_id=req.student_id,
                        attendance_score=0.0,
                        midterm_score=0.0,
                        final_score=0.0,
                        total_score=0.0,
                        result_status="PENDING",
                        is_confirmed=False,
                        note=f"Tiếp nhận học viên chuyển từ lớp {curr_cls.class_code}. Lý do: {transfer_reason or 'Chuyển cấp độ'}"
                    )
                    db.add(new_grade)

                # Bảo toàn tuyệt đối kết quả PASS và trạng thái xác nhận của lớp nguồn
                if curr_grade:
                    curr_grade.is_deleted = False

            # 6. Cập nhật yêu cầu sang APPROVED
            req.status = "APPROVED"
            req.reviewed_by = reviewer_user_id
            req.reviewed_at = datetime.now(timezone.utc)

            db.commit()
            db.refresh(req)
            return ClassService.format_transfer_request_detail(db, req)
        except Exception as e:
            db.rollback()
            try:
                db.query(EnrollmentRequest).filter(EnrollmentRequest.id == request_id).update(
                    {EnrollmentRequest.status: "PENDING"}
                )
                db.commit()
            except Exception:
                pass
            raise e

    @staticmethod
    def reject_transfer_request(
        db: Session,
        request_id: int,
        reviewer_user_id: int,
        rejection_reason: str
    ) -> dict:
        if not rejection_reason or not rejection_reason.strip():
            raise BusinessException("Vui lòng cung cấp lý do từ chối yêu cầu chuyển lớp (bắt buộc).")

        req = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.id == request_id,
            EnrollmentRequest.note.like("[TRANSFER_REQUEST:%")
        ).first()
        if not req:
            raise NotFoundException("Yêu cầu chuyển lớp", request_id)

        if req.status != "PENDING":
            raise BusinessException(f"Không thể từ chối: Yêu cầu chuyển lớp này đã được xử lý trước đó (trạng thái: {req.status}).")

        claimed = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.id == request_id,
            EnrollmentRequest.status == "PENDING"
        ).update({
            EnrollmentRequest.status: "REJECTED",
            EnrollmentRequest.rejection_reason: rejection_reason.strip(),
            EnrollmentRequest.reviewed_by: reviewer_user_id,
            EnrollmentRequest.reviewed_at: datetime.now(timezone.utc)
        }, synchronize_session="fetch")

        if claimed == 0:
            raise BusinessException("Yêu cầu chuyển lớp này đã được xử lý trước đó.")

        db.commit()
        db.refresh(req)
        return ClassService.format_transfer_request_detail(db, req)

    @staticmethod
    def get_transfer_targets(db: Session, class_id: int, student_id: Optional[int] = None) -> List[dict]:
        """Lấy danh sách các lớp học hợp lệ để học viên có thể chuyển sang từ class_id:
        - Khác lớp hiện tại (target.id != class_id)
        - Khác giảng viên phụ trách (target.teacher_id != curr.teacher_id)
        - Khác thời khóa biểu
        - Lớp đang mở hoặc đang diễn ra
        - Phân tích quan hệ cấp độ (SAME_LEVEL, HIGHER_LEVEL, LOWER_LEVEL, UNKNOWN_LEVEL)
        """
        from app.modules.schedules.models import ScheduleSession
        curr_cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not curr_cls:
            raise NotFoundException("Lớp học", class_id)

        ClassService.sync_class_lifecycle(curr_cls)
        if curr_cls.status in ["COMPLETED", "CANCELLED"]:
            return []

        curr_sessions = db.query(ScheduleSession).filter(
            ScheduleSession.class_id == class_id,
            ScheduleSession.status != "CANCELLED",
            ScheduleSession.is_deleted == False
        ).all()

        candidates = db.query(Class).filter(
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

            # 3. Xác định quan hệ cấp độ
            level_rel = ClassService.get_level_relation(curr_cls.course, cand.course)
            if level_rel == "UNKNOWN_LEVEL" and cand.course_id != curr_cls.course_id:
                # Nếu không cùng khóa học và không xác định được cấp độ -> không hiển thị trong danh sách đề xuất
                continue

            distinct_slots = sorted(list({(s.session_date.weekday(), s.start_time, s.end_time) for s in cand_sessions}))
            if distinct_slots:
                day_names = [weekday_names[slot[0]] for slot in distinct_slots]
                times = f"{distinct_slots[0][1]} - {distinct_slots[0][2]}"
                schedule_summary = f"{', '.join(day_names)} ({times})"
            else:
                schedule_summary = "Lịch học đang xếp"

            teacher_name = cand.teacher.user.full_name if (cand.teacher and cand.teacher.user) else "Chưa phân công"
            target_level = cand.course.target_level if cand.course else ""

            is_eligible = True
            ineligible_reason = None
            if student_id:
                eval_res = ClassService.check_transfer_conditions(db, student_id, class_id, cand.id, is_approval=False)
                is_eligible = eval_res["is_eligible"]
                ineligible_reason = eval_res["failure_reason"]

            valid_targets.append({
                "id": cand.id,
                "class_code": cand.class_code,
                "course_id": cand.course_id,
                "course_title": cand.course.title if cand.course else "",
                "target_level": target_level,
                "teacher_id": cand.teacher_id,
                "teacher_name": teacher_name,
                "max_capacity": cand.max_capacity,
                "current_enrolled": cand.current_enrolled or 0,
                "is_full": (cand.current_enrolled or 0) >= cand.max_capacity,
                "status": cand.status,
                "schedule_summary": schedule_summary,
                "level_relation": level_rel,
                "is_eligible": is_eligible,
                "ineligible_reason": ineligible_reason
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
        """Nghiệp vụ Chuyển lớp trực tiếp (dành cho Admin/Staff hoặc backward-compatibility):
        Thực hiện toàn bộ kiểm tra nghiệp vụ và chuyển lớp nguyên tử trong 1 transaction.
        """
        from app.modules.schedules.models import ScheduleSession

        if current_class_id == target_class_id:
            raise BusinessException("Không thể chuyển lớp: Lớp đích phải là một lớp khác với lớp hiện tại.")

        curr_cls = db.query(Class).filter(Class.id == current_class_id, Class.is_deleted == False).first()
        if not curr_cls:
            raise NotFoundException("Lớp học hiện tại", current_class_id)

        target_cls = db.query(Class).filter(Class.id == target_class_id, Class.is_deleted == False).first()
        if not target_cls:
            raise NotFoundException("Lớp học đích", target_class_id)

        ClassService.sync_class_lifecycle(curr_cls)
        ClassService.sync_class_lifecycle(target_cls)
        if curr_cls.status in ["COMPLETED", "CANCELLED"]:
            raise BusinessException(f"Không thể chuyển lớp: Lớp hiện tại đang ở trạng thái '{curr_cls.status}'.")

        # 1. Kiểm tra cùng khóa học hoặc cùng cấp độ hợp lệ (H-02)
        level_rel = ClassService.get_level_relation(curr_cls.course, target_cls.course)
        if curr_cls.course_id != target_cls.course_id and level_rel == "UNKNOWN_LEVEL":
            raise BusinessException("Không thể chuyển lớp: Lớp đích phải thuộc cùng khóa học hoặc cùng hệ thống cấp độ hợp lệ.")

        # 2. Kiểm tra thông tin học viên
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
        level_rel = ClassService.get_level_relation(curr_cls.course, target_cls.course)
        if level_rel == "HIGHER_LEVEL":
            from app.modules.enrollments.service import EnrollmentService
            is_eligible, prereq_msg = EnrollmentService.check_prerequisite_eligibility(db, student_id, target_class_id)
            if not is_eligible:
                raise BusinessException(prereq_msg)
        elif level_rel == "UNKNOWN_LEVEL":
            curr_grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == current_class_id,
                GradeRecord.student_id == student_id,
                GradeRecord.is_deleted == False
            ).first()
            if not (curr_grade and curr_grade.result_status == "PASSED" and curr_grade.is_confirmed):
                raise BusinessException("Không thể chuyển lớp: Học viên chưa hoàn thành và đạt (PASS) ở lớp hiện tại đối với khóa học khác lộ trình.")

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

        # b. Hủy tư cách thành viên lớp cũ (chuyển sang TRANSFERRED, bảo toàn lịch sử học tập)
        curr_cs.status = "TRANSFERRED"
        curr_cs.is_deleted = False

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

        # d. Bảo toàn và đồng bộ sổ điểm sang lớp mới (BUG-01)
        curr_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == current_class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()

        level_rel = ClassService.get_level_relation(curr_cls.course, target_cls.course)

        if level_rel == "SAME_LEVEL":
            if target_grade:
                target_grade.is_deleted = False
                if curr_grade:
                    target_grade.attendance_score = curr_grade.attendance_score
                    target_grade.midterm_score = curr_grade.midterm_score
                    target_grade.final_score = curr_grade.final_score
                    target_grade.total_score = curr_grade.total_score
                    target_grade.result_status = curr_grade.result_status
                    target_grade.is_confirmed = curr_grade.is_confirmed
                target_grade.note = f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển lớp cùng cấp độ'}"
            else:
                new_grade = GradeRecord(
                    class_id=target_class_id,
                    student_id=student_id,
                    attendance_score=curr_grade.attendance_score if curr_grade else 0.0,
                    midterm_score=curr_grade.midterm_score if curr_grade else 0.0,
                    final_score=curr_grade.final_score if curr_grade else 0.0,
                    total_score=curr_grade.total_score if curr_grade else 0.0,
                    result_status=curr_grade.result_status if curr_grade else "PENDING",
                    is_confirmed=curr_grade.is_confirmed if curr_grade else False,
                    note=f"Chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển lớp cùng cấp độ'}"
                )
                db.add(new_grade)

            if curr_grade:
                curr_grade.note = (curr_grade.note or "") + f" [Đã chuyển sang lớp {target_cls.class_code}]"
                curr_grade.is_deleted = False
        else:
            if target_grade:
                target_grade.is_deleted = False
                target_grade.attendance_score = 0.0
                target_grade.midterm_score = 0.0
                target_grade.final_score = 0.0
                target_grade.total_score = 0.0
                target_grade.result_status = "PENDING"
                target_grade.is_confirmed = False
                target_grade.note = f"Tiếp nhận học viên chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển cấp độ'}"
            else:
                new_grade = GradeRecord(
                    class_id=target_class_id,
                    student_id=student_id,
                    attendance_score=0.0,
                    midterm_score=0.0,
                    final_score=0.0,
                    total_score=0.0,
                    result_status="PENDING",
                    is_confirmed=False,
                    note=f"Tiếp nhận học viên chuyển từ lớp {curr_cls.class_code}. Lý do: {reason or 'Chuyển cấp độ'}"
                )
                db.add(new_grade)

            if curr_grade:
                curr_grade.is_deleted = False

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

