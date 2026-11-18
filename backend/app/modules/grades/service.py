from typing import List, Optional
from datetime import datetime, date, timezone
from sqlalchemy.orm import Session
from app.modules.grades.models import GradeRecord, GradeLockHistory
from app.modules.classes.models import Class, ClassStudent
from app.modules.students.models import Student
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.grades.schemas import (
    BatchGradeInputRequest, AddStudentGradeRequest, ClassGradingSheetStudent, GradeRecordResponse
)
from app.modules.grades.calculator import GradeCalculator

class GradeService:
    @staticmethod
    def _format_grade_record(gr: GradeRecord) -> dict:
        cls = gr.enrolled_class
        student = gr.student
        user = student.user if student else None
        return {
            "id": gr.id,
            "class_id": gr.class_id,
            "class_code": cls.class_code if cls else "",
            "course_title": cls.course.title if (cls and cls.course) else "",
            "student_id": gr.student_id,
            "student_code": student.student_code if student else "",
            "student_name": user.full_name if user else "",
            "attendance_score": gr.attendance_score,
            "midterm_score": gr.midterm_score,
            "final_score": gr.final_score,
            "total_score": gr.total_score,
            "result_status": gr.result_status,
            "is_confirmed": gr.is_confirmed,
            "note": gr.note
        }

    @staticmethod
    def check_and_update_class_grade_lock(db: Session, cls: Class) -> tuple[bool, str]:
        """
        Kiểm tra trạng thái khóa điểm của lớp học:
        - Nếu Admin/Staff đã mở khóa thủ công: cho phép sửa.
        - Nếu lớp học đã kết thúc (today > cls.end_date) hoặc status COMPLETED: tự động khóa sổ, chặn sửa điểm.
        - Nếu bảng điểm đã được xác nhận chính thức: khóa sổ.
        """
        today = date.today()
        # 1. Nếu Admin/Staff mở khóa thủ công thì cho phép giảng viên sửa
        if cls.is_grade_unlocked:
            return False, "Bảng điểm đang được mở khóa thủ công bởi Quản trị viên/Học vụ."

        # 2. Lớp học đã kết thúc dựa trên end_date của lớp (LOP_HOC)
        if cls.end_date and today > cls.end_date:
            # Tự động khóa các bản ghi điểm chưa khóa
            unlocked = db.query(GradeRecord).filter(
                GradeRecord.class_id == cls.id,
                GradeRecord.is_confirmed == False,
                GradeRecord.is_deleted == False
            ).all()
            if unlocked:
                for u in unlocked:
                    u.is_confirmed = True
                hist = GradeLockHistory(
                    class_id=cls.id,
                    action="AUTO_LOCK",
                    performed_by=None,
                    performed_at=datetime.now(timezone.utc),
                    reason=f"Hệ thống tự động khóa sổ điểm do lớp học đã kết thúc ngày {cls.end_date}."
                )
                db.add(hist)
                db.commit()
            return True, f"Bảng điểm đã được hệ thống tự động khóa do lớp học đã kết thúc ngày {cls.end_date}."

        if cls.status == "COMPLETED":
            return True, "Bảng điểm đã tự động khóa do lớp học đã hoàn thành."

        # 3. Bảng điểm đã được xác nhận/khóa sổ
        is_locked = db.query(GradeRecord).filter(
            GradeRecord.class_id == cls.id,
            GradeRecord.is_confirmed == True,
            GradeRecord.is_deleted == False
        ).first() is not None
        if is_locked:
            return True, "Bảng điểm của lớp học đã được khóa sổ chính thức."

        return False, "Bảng điểm đang mở cho giảng viên nhập điểm."

    @staticmethod
    def get_class_grading_sheet(db: Session, class_id: int) -> List[ClassGradingSheetStudent]:
        """FR-69: Xem danh sách học viên phục vụ nhập điểm"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

        # Tự động đồng bộ và kiểm tra khóa điểm nếu lớp học đã kết thúc
        GradeService.check_and_update_class_grade_lock(db, cls)

        # Lấy danh sách học viên trong lớp
        roster = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.is_deleted == False
        ).all()

        results = []
        for cs in roster:
            student = cs.student
            grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == class_id,
                GradeRecord.student_id == student.id,
                GradeRecord.is_deleted == False
            ).first()

            if not grade:
                # Tự động tạo bản ghi trống nếu chưa có
                grade = GradeRecord(class_id=class_id, student_id=student.id, result_status="PENDING")
                db.add(grade)
                db.commit()
                db.refresh(grade)

            results.append(ClassGradingSheetStudent(
                student_id=student.id,
                student_code=student.student_code,
                full_name=student.user.full_name if student.user else "",
                avatar_url=student.user.avatar_url if (student.user and student.user.avatar_url) else None,
                attendance_score=grade.attendance_score,
                midterm_score=grade.midterm_score,
                final_score=grade.final_score,
                total_score=grade.total_score,
                result_status=grade.result_status,
                is_confirmed=grade.is_confirmed,
                note=grade.note
            ))
        return results

    @staticmethod
    def save_grades(db: Session, data: BatchGradeInputRequest) -> bool:
        """FR-70, FR-71, FR-73, FR-74: Nhập, Cập nhật, Kiểm tra và Tổng hợp điểm"""
        cls = db.query(Class).filter(Class.id == data.class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", data.class_id)

        # Kiểm tra trạng thái khóa điểm (Tự động khóa khi lớp kết thúc, hoặc khóa chính thức)
        is_locked, lock_msg = GradeService.check_and_update_class_grade_lock(db, cls)
        if is_locked:
            raise BusinessException(f"Không thể lưu điểm: {lock_msg}")

        for item in data.grades:
            # FR-73: Kiểm tra tính hợp lệ của điểm (0 - 10)
            if not (0.0 <= item.attendance_score <= 10.0 and 
                    0.0 <= item.midterm_score <= 10.0 and 
                    0.0 <= item.final_score <= 10.0):
                raise BusinessException(f"Điểm số của học viên ID {item.student_id} phải nằm trong khoảng từ 0 đến 10.")

            grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == data.class_id,
                GradeRecord.student_id == item.student_id,
                GradeRecord.is_deleted == False
            ).first()

            if not grade:
                grade = GradeRecord(class_id=data.class_id, student_id=item.student_id)
                db.add(grade)

            if grade.is_confirmed and not cls.is_grade_unlocked:
                raise BusinessException("Điểm của lớp đã được khóa chính thức, không thể sửa đổi.")

            grade.attendance_score = item.attendance_score
            grade.midterm_score = item.midterm_score
            grade.final_score = item.final_score
            grade.note = item.note

            # FR-74: Tổng hợp kết quả học tập tự động
            total, status = GradeCalculator.calculate_total_and_status(
                item.attendance_score, item.midterm_score, item.final_score
            )
            grade.total_score = total
            grade.result_status = status

        db.commit()
        return True

    @staticmethod
    def confirm_grades(db: Session, class_id: int, user_id: Optional[int] = None, reason: Optional[str] = None) -> bool:
        """FR-76 & FR-77: Khóa sổ kết quả học tập chính thức & Ghi nhận lịch sử"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

        grades = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.is_deleted == False
        ).all()
        if not grades:
            raise BusinessException("Lớp học chưa có bảng điểm để xác nhận.")

        for g in grades:
            g.is_confirmed = True
        cls.is_grade_unlocked = False

        hist = GradeLockHistory(
            class_id=class_id,
            action="LOCK",
            performed_by=user_id,
            performed_at=datetime.now(timezone.utc),
            reason=reason or "Quản trị viên/Học vụ khóa sổ bảng điểm"
        )
        db.add(hist)
        db.commit()
        return True

    @staticmethod
    def unlock_grades(db: Session, class_id: int, user_id: Optional[int] = None, reason: Optional[str] = None) -> bool:
        """Mở khóa bảng điểm để giáo viên có thể chỉnh sửa lại điểm khi cần điều chỉnh & Ghi nhận lịch sử"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

        grades = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.is_deleted == False
        ).all()
        for g in grades:
            g.is_confirmed = False
        cls.is_grade_unlocked = True

        hist = GradeLockHistory(
            class_id=class_id,
            action="UNLOCK",
            performed_by=user_id,
            performed_at=datetime.now(timezone.utc),
            reason=reason or "Quản trị viên/Học vụ mở khóa điểm cho giảng viên điều chỉnh"
        )
        db.add(hist)
        db.commit()
        return True

    @staticmethod
    def get_lock_history(db: Session, class_id: int) -> List[dict]:
        """Lấy lịch sử khóa/mở khóa sổ điểm của lớp học"""
        from app.modules.accounts.models import User
        logs = db.query(GradeLockHistory).filter(
            GradeLockHistory.class_id == class_id
        ).order_by(GradeLockHistory.id.desc()).all()

        results = []
        for l in logs:
            user = db.query(User).filter(User.id == l.performed_by).first() if l.performed_by else None
            results.append({
                "id": l.id,
                "class_id": l.class_id,
                "action": l.action,
                "performed_by": l.performed_by,
                "performer_name": user.full_name if user else "Hệ thống tự động",
                "performed_at": l.performed_at,
                "reason": l.reason
            })
        return results

    @staticmethod
    def auto_lock_all_ended_classes(db: Session) -> int:
        """Kiểm tra và tự động khóa sổ điểm cho tất cả các lớp học đã kết thúc"""
        today = date.today()
        ended_classes = db.query(Class).filter(
            Class.end_date < today,
            Class.is_grade_unlocked == False,
            Class.is_deleted == False
        ).all()
        locked_count = 0
        for cls in ended_classes:
            is_locked, _ = GradeService.check_and_update_class_grade_lock(db, cls)
            if is_locked:
                locked_count += 1
        return locked_count

    @staticmethod
    def add_student_to_grading_sheet(
        db: Session, class_id: int, data: AddStudentGradeRequest
    ) -> ClassGradingSheetStudent:
        """Thêm học viên vào bảng điểm của lớp và khởi tạo điểm"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

        is_locked, lock_msg = GradeService.check_and_update_class_grade_lock(db, cls)
        if is_locked:
            raise BusinessException(f"Bảng điểm của lớp học đang bị khóa: {lock_msg}")

        student = db.query(Student).filter(Student.id == data.student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", data.student_id)

        # Đảm bảo học viên có trong danh sách thành viên lớp
        cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.student_id == data.student_id
        ).first()
        if not cs:
            cs = ClassStudent(class_id=class_id, student_id=data.student_id, status="ENROLLED")
            db.add(cs)
            cls.current_enrolled = (cls.current_enrolled or 0) + 1
        elif cs.is_deleted:
            cs.is_deleted = False
            cs.status = "ENROLLED"
            cls.current_enrolled = (cls.current_enrolled or 0) + 1

        # Khởi tạo hoặc cập nhật bản ghi điểm
        grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.student_id == data.student_id
        ).first()

        att = float(data.attendance_score if data.attendance_score is not None else 0.0)
        mid = float(data.midterm_score if data.midterm_score is not None else 0.0)
        fin = float(data.final_score if data.final_score is not None else 0.0)
        total, status = GradeCalculator.calculate_total_and_status(att, mid, fin)

        if not grade:
            grade = GradeRecord(
                class_id=class_id,
                student_id=data.student_id,
                attendance_score=att,
                midterm_score=mid,
                final_score=fin,
                total_score=total,
                result_status=status,
                is_confirmed=False,
                note=data.note
            )
            db.add(grade)
        else:
            grade.is_deleted = False
            grade.attendance_score = att
            grade.midterm_score = mid
            grade.final_score = fin
            grade.total_score = total
            grade.result_status = status
            grade.note = data.note
            grade.is_confirmed = False

        db.commit()
        db.refresh(grade)

        return ClassGradingSheetStudent(
            student_id=student.id,
            student_code=student.student_code,
            full_name=student.user.full_name if student.user else "",
            avatar_url=student.user.avatar_url if (student.user and student.user.avatar_url) else None,
            attendance_score=grade.attendance_score,
            midterm_score=grade.midterm_score,
            final_score=grade.final_score,
            total_score=grade.total_score,
            result_status=grade.result_status,
            is_confirmed=grade.is_confirmed,
            note=grade.note
        )

    @staticmethod
    def delete_student_from_grading_sheet(db: Session, class_id: int, student_id: int) -> bool:
        """Xóa học viên / bản ghi điểm khỏi bảng điểm của lớp"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

        is_locked, lock_msg = GradeService.check_and_update_class_grade_lock(db, cls)
        if is_locked:
            raise BusinessException(f"Không thể xóa học viên khỏi bảng điểm đã khóa: {lock_msg}")

        grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()

        if grade:
            grade.is_deleted = True

        cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.student_id == student_id,
            ClassStudent.is_deleted == False
        ).first()
        if cs:
            cs.is_deleted = True
            if cls.current_enrolled and cls.current_enrolled > 0:
                cls.current_enrolled -= 1

        db.commit()
        return True

    @staticmethod
    def get_student_grades(db: Session, student_id: int) -> List[dict]:
        """FR-72 & FR-75: Xem điểm & kết quả học tập của học viên"""
        grades = db.query(GradeRecord).filter(
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).all()
        return [GradeService._format_grade_record(g) for g in grades]

