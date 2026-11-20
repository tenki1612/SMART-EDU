from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.enrollments.models import EnrollmentRequest
from app.modules.accounts.models import User
from app.modules.classes.models import Class, ClassStudent
from app.modules.students.models import Student
from app.modules.grades.models import GradeRecord
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.enrollments.schemas import EnrollmentCreateRequest, EnrollmentRejectRequest

class EnrollmentService:
    @staticmethod
    def get_prerequisite_target_level(target_level: Optional[str]) -> Optional[str]:
        """
        BR-01: Xác định cấp độ tiên quyết dựa trên chuẩn đầu ra (Target Level)
        IELTS: 7.5 yêu cầu 6.5; 6.5 yêu cầu 5.0; 5.0 là entry level.
        TOEIC: 750 yêu cầu 550; 550 là entry level.
        COMM: B1 yêu cầu A2; A2 là entry level.
        """
        tl = (target_level or "").strip().upper()
        if "7.5" in tl:
            return "6.5"
        if "6.5" in tl:
            return "5.0"
        if "750" in tl:
            return "550"
        if "B1" in tl:
            return "A2"
        return None

    @staticmethod
    def check_prerequisite_eligibility(db: Session, student_id: int, class_id: int) -> tuple[bool, str]:
        """
        BR-01: Kiểm tra điều kiện tiên quyết khi đăng ký lớp học
        Học sinh chỉ được đăng ký lớp cấp độ cao hơn khi đã PASS lớp cấp độ hiện tại.
        """
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            return False, "Không tìm thấy lớp học."

        course = cls.course
        if not course:
            return True, "Lớp học không thuộc khóa học cụ thể."

        req_level = EnrollmentService.get_prerequisite_target_level(course.target_level)
        if not req_level:
            # Khóa học sơ cấp / không có tiên quyết
            return True, "Khóa học không yêu cầu điều kiện tiên quyết."

        # 1. Kiểm tra CourseProgression đã được nhân viên/admin xác nhận
        from app.modules.progression_parent.models import CourseProgression
        approved_prog = db.query(CourseProgression).filter(
            CourseProgression.student_id == student_id,
            CourseProgression.next_course_id == course.id,
            CourseProgression.is_eligible == True,
            CourseProgression.is_confirmed == True,
            CourseProgression.is_deleted == False
        ).first()
        if approved_prog:
            return True, "Bạn đã hoàn thành và PASS lớp học trước đó. Bạn đủ điều kiện đăng ký lớp học này."

        # 2. Tìm tất cả các khóa học thuộc cấp độ tiên quyết
        from app.modules.courses.models import Course
        prereq_courses = db.query(Course).filter(
            Course.target_level.ilike(f"%{req_level}%"),
            Course.is_deleted == False
        ).all()
        prereq_course_ids = [c.id for c in prereq_courses]
        if not prereq_course_ids:
            return True, "Khóa học không yêu cầu điều kiện tiên quyết."

        # 3. Tìm các lớp tiên quyết mà học viên đã học
        enrolled_prereq_classes = db.query(Class).join(
            ClassStudent, ClassStudent.class_id == Class.id
        ).filter(
            ClassStudent.student_id == student_id,
            Class.course_id.in_(prereq_course_ids),
            ClassStudent.is_deleted == False,
            Class.is_deleted == False
        ).all()

        if not enrolled_prereq_classes:
            return False, "Bạn chưa đạt yêu cầu của lớp học cấp độ hiện tại. Vui lòng hoàn thành và PASS lớp học trước khi đăng ký lớp cấp độ cao hơn."

        # 4. Kiểm tra điểm số và kết quả hoàn thành (GradeRecord)
        has_passed = False
        for pc in enrolled_prereq_classes:
            grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == pc.id,
                GradeRecord.student_id == student_id,
                GradeRecord.is_deleted == False
            ).first()
            if grade and grade.result_status == "PASSED" and grade.is_confirmed == True:
                has_passed = True
                break

        if has_passed:
            return True, "Bạn đã hoàn thành và PASS lớp học trước đó. Bạn đủ điều kiện đăng ký lớp học này."
        else:
            return False, "Bạn chưa đạt yêu cầu của lớp học cấp độ hiện tại. Vui lòng hoàn thành và PASS lớp học trước khi đăng ký lớp cấp độ cao hơn."

    @staticmethod
    def _format_enrollment_response(req: EnrollmentRequest) -> dict:
        student = req.student
        user = student.user if student else None
        cls = req.enrolled_class
        reviewer = req.reviewer
        return {
            "id": req.id,
            "student_id": req.student_id,
            "student_code": student.student_code if student else "",
            "student_name": user.full_name if user else "",
            "student_phone": user.phone if user else "",
            "class_id": req.class_id,
            "class_code": cls.class_code if cls else "",
            "course_title": cls.course.title if (cls and cls.course) else "",
            "target_level": cls.course.target_level if (cls and cls.course) else "",
            "request_date": req.request_date or req.created_at,
            "status": req.status,
            "note": req.note,
            "rejection_reason": req.rejection_reason,
            "reviewed_at": req.reviewed_at,
            "reviewer_name": reviewer.full_name if reviewer else None
        }

    @staticmethod
    def create_request(db: Session, student_id: int, data: EnrollmentCreateRequest) -> dict:
        cls = db.query(Class).filter(Class.id == data.class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", data.class_id)
        
        from app.modules.classes.service import ClassService
        if ClassService.sync_class_lifecycle(cls):
            db.commit()
            db.refresh(cls)

        if cls.status != "OPEN_FOR_ENROLLMENT":
            raise BusinessException("Lớp học hiện không trong trạng thái mở đăng ký.")
        
        # BR-01: Kiểm tra điều kiện tiên quyết (học sinh chỉ được đăng ký lớp cấp độ cao hơn khi đã PASS cấp độ hiện tại)
        is_eligible, prereq_msg = EnrollmentService.check_prerequisite_eligibility(db, student_id, data.class_id)
        if not is_eligible:
            raise BusinessException(prereq_msg)

        if cls.current_enrolled >= cls.max_capacity:
            raise BusinessException("Lớp học đã đủ sĩ số tối đa, không thể đăng ký.")

        already_enrolled = db.query(ClassStudent).filter(
            ClassStudent.student_id == student_id,
            ClassStudent.class_id == data.class_id,
            ClassStudent.is_deleted == False
        ).first()
        if already_enrolled:
            raise BusinessException("Bạn đã là thành viên chính thức của lớp học này.")

        # Cấp chỗ nguyên tử (conditional UPDATE) để hai request đồng thời không
        # thể cùng vượt sĩ số tối đa.
        claimed = db.query(Class).filter(
            Class.id == data.class_id,
            Class.is_deleted == False,
            Class.current_enrolled < Class.max_capacity
        ).update(
            {Class.current_enrolled: Class.current_enrolled + 1},
            synchronize_session="fetch"
        )
        if claimed == 0:
            raise BusinessException("Lớp học đã đủ sĩ số tối đa, không thể đăng ký.")

        # Kiểm tra trùng lặp SAU khi đã giữ chỗ (write lock) để chặn double-submit
        # đồng thời của cùng một học viên.
        duplicate = db.query(ClassStudent.id).filter(
            ClassStudent.student_id == student_id,
            ClassStudent.class_id == data.class_id,
            ClassStudent.is_deleted == False
        ).first()
        if duplicate:
            db.rollback()
            raise BusinessException("Bạn đã là thành viên chính thức của lớp học này.")

        # Ghi danh trực tiếp không cần phê duyệt thủ công (không tự tạo GradeRecord ở giai đoạn mở đăng ký)
        cs = ClassStudent(class_id=cls.id, student_id=student_id, status="ENROLLED")
        db.add(cs)

        # Lưu bản ghi lịch sử đăng ký trực tiếp
        req = EnrollmentRequest(
            student_id=student_id,
            class_id=data.class_id,
            note=data.note or "Đăng ký lớp học trực tiếp thành công",
            status="APPROVED",
            reviewed_at=datetime.now(timezone.utc)
        )
        db.add(req)
        db.commit()
        db.refresh(req)
        return EnrollmentService._format_enrollment_response(req)

    @staticmethod
    def cancel_request(db: Session, student_id: int, request_id: int) -> bool:
        req = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.id == request_id,
            EnrollmentRequest.student_id == student_id
        ).first()
        if not req:
            raise NotFoundException("Yêu cầu đăng ký", request_id)
        if req.status == "CANCELLED":
            raise BusinessException("Yêu cầu đăng ký này đã được hủy trước đó.")
        if req.note and ("[TRANSFER" in req.note or "Chuyển lớp" in req.note):
            raise BusinessException("Không thể hủy bản ghi audit chuyển lớp bằng thao tác hủy đăng ký thông thường.")
        
        # Hủy ghi danh: cập nhật trạng thái lớp học và giảm sĩ số
        cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == req.class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.is_deleted == False
        ).first()

        # Điểm đã khóa sổ là hồ sơ học vụ chính thức: không được hủy ghi danh
        # (nếu không sẽ tạo bản ghi điểm "mồ côi" ngoài sĩ số lớp).
        confirmed_grade = db.query(GradeRecord.id).filter(
            GradeRecord.class_id == req.class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_confirmed == True,
            GradeRecord.is_deleted == False
        ).first()
        if confirmed_grade:
            raise BusinessException(
                "Không thể hủy đăng ký vì bảng điểm của học viên đã được khóa sổ chính thức."
            )

        if cs:
            if cs.status == "TRANSFERRED":
                raise BusinessException("Không thể hủy đăng ký của học viên đã chuyển lớp.")

            cs.status = "DROPPED"
            cs.is_deleted = True
            cls = db.query(Class).filter(Class.id == req.class_id).first()
            if cls and cls.current_enrolled > 0:
                cls.current_enrolled -= 1

            # Xóa mềm bản ghi điểm chưa xác nhận nếu có (tránh rác dữ liệu điểm khi hủy ghi danh)
            unconfirmed_grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == req.class_id,
                GradeRecord.student_id == student_id,
                GradeRecord.is_confirmed == False,
                GradeRecord.is_deleted == False
            ).first()
            if unconfirmed_grade:
                unconfirmed_grade.is_deleted = True

        req.status = "CANCELLED"
        db.commit()
        return True

    @staticmethod
    def list_requests(
        db: Session, 
        student_id: Optional[int] = None, 
        status: Optional[str] = None
    ) -> List[dict]:
        q = db.query(EnrollmentRequest).filter(
            ~EnrollmentRequest.note.like("[TRANSFER_REQUEST:%") | (EnrollmentRequest.note == None)
        )
        if student_id:
            q = q.filter(EnrollmentRequest.student_id == student_id)
        if status:
            q = q.filter(EnrollmentRequest.status == status)
        q = q.order_by(EnrollmentRequest.request_date.desc())
        return [EnrollmentService._format_enrollment_response(r) for r in q.all()]

    @staticmethod
    def approve_request(db: Session, request_id: int, staff_user_id: int) -> dict:
        req = db.query(EnrollmentRequest).filter(EnrollmentRequest.id == request_id).first()
        if not req:
            raise NotFoundException("Yêu cầu đăng ký", request_id)
        if req.status != "PENDING":
            raise BusinessException(f"Không thể duyệt yêu cầu có trạng thái '{req.status}'.")

        # BR-01: Kiểm tra điều kiện tiên quyết trước khi duyệt
        is_eligible, prereq_msg = EnrollmentService.check_prerequisite_eligibility(db, req.student_id, req.class_id)
        if not is_eligible:
            raise BusinessException(prereq_msg)

        cls = req.enrolled_class
        if cls.current_enrolled >= cls.max_capacity:
            raise BusinessException("Lớp học đã đủ sĩ số, không thể duyệt thêm.")

        # Cập nhật danh sách học viên sau khi duyệt (FR-59)
        existing_cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == cls.id,
            ClassStudent.student_id == req.student_id,
            ClassStudent.is_deleted == False
        ).first()
        if not existing_cs:
            # Giữ chỗ nguyên tử trước khi tạo roster/grade.
            claimed = db.query(Class).filter(
                Class.id == cls.id,
                Class.is_deleted == False,
                Class.current_enrolled < Class.max_capacity
            ).update(
                {Class.current_enrolled: Class.current_enrolled + 1},
                synchronize_session="fetch"
            )
            if claimed == 0:
                raise BusinessException("Lớp học đã đủ sĩ số, không thể duyệt thêm.")

            # Double-check sau write lock: một request đồng thời có thể vừa duyệt.
            existing_after = db.query(ClassStudent.id).filter(
                ClassStudent.class_id == cls.id,
                ClassStudent.student_id == req.student_id,
                ClassStudent.is_deleted == False
            ).first()
            if existing_after:
                # Trả lại chỗ đã giữ vì roster đã tồn tại.
                db.query(Class).filter(
                    Class.id == cls.id,
                    Class.current_enrolled > 0
                ).update(
                    {Class.current_enrolled: Class.current_enrolled - 1},
                    synchronize_session="fetch"
                )
            else:
                cs = ClassStudent(class_id=cls.id, student_id=req.student_id, status="ENROLLED")
                db.add(cs)

                # Khởi tạo bản ghi điểm
                grade = GradeRecord(class_id=cls.id, student_id=req.student_id, result_status="PENDING")
                db.add(grade)

        req.status = "APPROVED"
        req.reviewed_by = staff_user_id
        req.reviewed_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(req)
        return EnrollmentService._format_enrollment_response(req)

    @staticmethod
    def reject_request(db: Session, request_id: int, staff_user_id: int, data: EnrollmentRejectRequest) -> dict:
        req = db.query(EnrollmentRequest).filter(EnrollmentRequest.id == request_id).first()
        if not req:
            raise NotFoundException("Yêu cầu đăng ký", request_id)
        if req.status != "PENDING":
            raise BusinessException(f"Không thể từ chối yêu cầu có trạng thái '{req.status}'.")

        req.status = "REJECTED"
        req.rejection_reason = data.rejection_reason
        req.reviewed_by = staff_user_id
        req.reviewed_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(req)
        return EnrollmentService._format_enrollment_response(req)

