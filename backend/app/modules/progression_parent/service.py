from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.progression_parent.models import CourseProgression, ParentStudent
from app.modules.students.models import Student
from app.modules.courses.models import Course
from app.modules.classes.models import Class, ClassStudent
from app.modules.grades.models import GradeRecord
from app.modules.enrollments.models import EnrollmentRequest
from app.core.exceptions import BusinessException, NotFoundException, ForbiddenException
from app.modules.progression_parent.schemas import (
    ProgressionCheckRequest, ParentWardInfoResponse
)

class ProgressionParentService:
    @staticmethod
    def _format_progression(p: CourseProgression) -> dict:
        student = p.student
        user = student.user if student else None
        confirmer = p.confirmer
        return {
            "id": p.id,
            "student_id": p.student_id,
            "student_code": student.student_code if student else "",
            "student_name": user.full_name if user else "",
            "current_course_id": p.current_course_id,
            "current_course_title": p.current_course.title if p.current_course else "",
            "next_course_id": p.next_course_id,
            "next_course_title": p.next_course.title if p.next_course else "",
            "is_eligible": p.is_eligible,
            "is_confirmed": p.is_confirmed,
            "confirmed_by_name": confirmer.full_name if confirmer else None,
            "confirmed_at": p.confirmed_at,
            "note": p.note
        }

    @staticmethod
    def check_and_create_progression(db: Session, data: ProgressionCheckRequest) -> dict:
        """
        FR-78: Kiểm tra điều kiện đăng ký khóa học tiếp theo.
        Quy tắc: Học viên phải hoàn thành khóa học trước với kết quả Đạt (PASSED).
        """
        student = db.query(Student).filter(Student.id == data.student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", data.student_id)

        # Kiểm tra lớp của current_course_id mà học viên tham gia
        student_classes = db.query(Class).join(ClassStudent).filter(
            ClassStudent.student_id == data.student_id,
            Class.course_id == data.current_course_id,
            ClassStudent.is_deleted == False
        ).all()

        is_passed = False
        for c in student_classes:
            grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == c.id,
                GradeRecord.student_id == data.student_id,
                GradeRecord.result_status == "PASSED",
                GradeRecord.is_confirmed == True
            ).first()
            if grade:
                is_passed = True
                break

        prog = CourseProgression(
            student_id=data.student_id,
            current_course_id=data.current_course_id,
            next_course_id=data.next_course_id,
            is_eligible=is_passed,
            is_confirmed=False,
            note=data.note or ("Đủ điều kiện do đã đạt chuẩn đầu ra khóa trước." if is_passed else "Chưa đủ điều kiện: Chưa đạt kết quả hoàn thành khóa trước.")
        )
        db.add(prog)
        db.commit()
        db.refresh(prog)
        return ProgressionParentService._format_progression(prog)

    @staticmethod
    def confirm_progression(db: Session, progression_id: int, staff_user_id: int) -> dict:
        """FR-79: Nhân viên học vụ xác nhận học viên đủ điều kiện học khóa cao hơn"""
        prog = db.query(CourseProgression).filter(CourseProgression.id == progression_id).first()
        if not prog:
            raise NotFoundException("Hồ sơ chuyển khóa", progression_id)
        
        prog.is_confirmed = True
        prog.confirmed_by = staff_user_id
        prog.confirmed_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(prog)
        return ProgressionParentService._format_progression(prog)

    @staticmethod
    def register_next_course(db: Session, student_id: int, target_class_id: int) -> dict:
        """
        FR-80: Đăng ký khóa học tiếp theo trong lộ trình
        """
        target_class = db.query(Class).filter(Class.id == target_class_id, Class.is_deleted == False).first()
        if not target_class:
            raise NotFoundException("Lớp học tiếp theo", target_class_id)
        
        # Kiểm tra đã được xác nhận đủ điều kiện vào target_class.course_id chưa
        eligible_prog = db.query(CourseProgression).filter(
            CourseProgression.student_id == student_id,
            CourseProgression.next_course_id == target_class.course_id,
            CourseProgression.is_confirmed == True
        ).first()

        if not eligible_prog:
            raise BusinessException("Học viên chưa được xác nhận đủ điều kiện nâng khóa để đăng ký lớp học này.")

        # Tạo yêu cầu đăng ký
        from app.modules.enrollments.service import EnrollmentService
        from app.modules.enrollments.schemas import EnrollmentCreateRequest
        return EnrollmentService.create_request(
            db, student_id, EnrollmentCreateRequest(class_id=target_class_id, note="Đăng ký khóa học tiếp theo theo lộ trình nâng cấp độ")
        )

    @staticmethod
    def get_parent_wards(db: Session, parent_user_id: int) -> List[ParentWardInfoResponse]:
        """FR-81: Xem thông tin học viên được giám hộ"""
        links = db.query(ParentStudent).filter(ParentStudent.parent_user_id == parent_user_id).all()
        results = []
        for l in links:
            s = l.student
            user = s.user
            # Đếm số khóa đã tham gia
            enrollment_count = db.query(ClassStudent).filter(ClassStudent.student_id == s.id, ClassStudent.is_deleted == False).count()
            
            # Tính điểm trung bình
            grades = db.query(GradeRecord).filter(GradeRecord.student_id == s.id, GradeRecord.is_confirmed == True, GradeRecord.is_deleted == False).all()
            avg_score = round(sum(g.total_score for g in grades) / len(grades), 2) if grades else None

            results.append(ParentWardInfoResponse(
                student_id=s.id,
                student_code=s.student_code,
                full_name=user.full_name if user else "",
                date_of_birth=s.date_of_birth,
                relationship_type=l.relationship_type,
                enrolled_courses_count=enrollment_count,
                average_score=avg_score,
                latest_status=s.status
            ))
        return results

    @staticmethod
    def get_ward_enrollment_status(db: Session, parent_user_id: int, student_id: int) -> List[dict]:
        """FR-82: Phụ huynh xem trạng thái đăng ký của học viên được giám hộ"""
        # Kiểm tra quan hệ giám hộ
        link = db.query(ParentStudent).filter(
            ParentStudent.parent_user_id == parent_user_id,
            ParentStudent.student_id == student_id
        ).first()
        if not link:
            raise ForbiddenException("Bạn không có quyền giám hộ đối với học viên này.")
        
        from app.modules.enrollments.service import EnrollmentService
        return EnrollmentService.list_requests(db, student_id=student_id)

    @staticmethod
    def get_ward_grades(db: Session, parent_user_id: int, student_id: int) -> List[dict]:
        """Phụ huynh xem bảng điểm chi tiết của con mình (học viên được giám hộ)"""
        link = db.query(ParentStudent).filter(
            ParentStudent.parent_user_id == parent_user_id,
            ParentStudent.student_id == student_id
        ).first()
        if not link:
            raise ForbiddenException("Bạn chỉ có quyền xem bảng điểm của con mình được giám hộ.")
        
        from app.modules.grades.service import GradeService
        return GradeService.get_student_grades(db, student_id)
