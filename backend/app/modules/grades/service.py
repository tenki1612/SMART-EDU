from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.grades.models import GradeRecord
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
    def get_class_grading_sheet(db: Session, class_id: int) -> List[ClassGradingSheetStudent]:
        """FR-69: Xem danh sách học viên phục vụ nhập điểm"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

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

            if grade.is_confirmed:
                raise BusinessException("Điểm của lớp đã được xác nhận chính thức, không thể sửa đổi.")

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
    def confirm_grades(db: Session, class_id: int) -> bool:
        """FR-76 & FR-77: Xác nhận kết quả học tập chính thức & Cập nhật trạng thái"""
        grades = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.is_deleted == False
        ).all()
        if not grades:
            raise BusinessException("Lớp học chưa có bảng điểm để xác nhận.")

        for g in grades:
            g.is_confirmed = True
        db.commit()
        return True

    @staticmethod
    def unlock_grades(db: Session, class_id: int) -> bool:
        """Mở khóa bảng điểm để giáo viên có thể chỉnh sửa lại điểm khi cần điều chỉnh"""
        grades = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.is_deleted == False
        ).all()
        for g in grades:
            g.is_confirmed = False
        db.commit()
        return True

    @staticmethod
    def add_student_to_grading_sheet(
        db: Session, class_id: int, data: AddStudentGradeRequest
    ) -> ClassGradingSheetStudent:
        """Thêm học viên vào bảng điểm của lớp và khởi tạo điểm"""
        cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not cls:
            raise NotFoundException("Lớp học", class_id)

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

        grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == class_id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()

        if grade:
            if grade.is_confirmed:
                raise BusinessException("Không thể xóa điểm của lớp đã được khóa chính thức.")
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

