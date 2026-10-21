from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.enrollments.models import EnrollmentRequest
from app.modules.classes.models import Class, ClassStudent
from app.modules.students.models import Student
from app.modules.grades.models import GradeRecord
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.enrollments.schemas import EnrollmentCreateRequest, EnrollmentRejectRequest

class EnrollmentService:
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
            "request_date": req.request_date,
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
        
        if cls.status != "OPEN_FOR_ENROLLMENT":
            raise BusinessException("Lớp học hiện không trong trạng thái mở đăng ký.")
        
        if cls.current_enrolled >= cls.max_capacity:
            raise BusinessException("Lớp học đã đủ sĩ số, không thể gửi yêu cầu đăng ký.")
        
        # Check if already requested or enrolled
        existing_req = db.query(EnrollmentRequest).filter(
            EnrollmentRequest.student_id == student_id,
            EnrollmentRequest.class_id == data.class_id,
            EnrollmentRequest.status == "PENDING"
        ).first()
        if existing_req:
            raise BusinessException("Bạn đã có yêu cầu đăng ký đang chờ xét duyệt cho lớp học này.")

        already_enrolled = db.query(ClassStudent).filter(
            ClassStudent.student_id == student_id,
            ClassStudent.class_id == data.class_id,
            ClassStudent.is_deleted == False
        ).first()
        if already_enrolled:
            raise BusinessException("Bạn đã là thành viên chính thức của lớp học này.")

        req = EnrollmentRequest(
            student_id=student_id,
            class_id=data.class_id,
            note=data.note,
            status="PENDING"
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
        if req.status != "PENDING":
            raise BusinessException("Chỉ có thể hủy yêu cầu khi đang ở trạng thái 'Chờ duyệt' (PENDING).")
        
        req.status = "CANCELLED"
        db.commit()
        return True

    @staticmethod
    def list_requests(
        db: Session, 
        student_id: Optional[int] = None, 
        status: Optional[str] = None
    ) -> List[dict]:
        q = db.query(EnrollmentRequest)
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
            cs = ClassStudent(class_id=cls.id, student_id=req.student_id, status="ENROLLED")
            db.add(cs)
            cls.current_enrolled += 1

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

