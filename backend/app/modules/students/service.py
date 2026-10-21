import random
from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.accounts.models import User
from app.modules.students.models import Student
from app.modules.classes.models import Class, ClassStudent
from app.modules.courses.models import Course
from app.modules.grades.models import GradeRecord
from app.core.security import get_password_hash
from app.core.permissions import RoleEnum
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.students.schemas import StudentCreate, StudentUpdate, EnrolledClassHistoryItem

class StudentService:
    @staticmethod
    def create_student(db: Session, data: StudentCreate) -> dict:
        if db.query(User).filter((User.username == data.username) | (User.email == data.email)).first():
            raise BusinessException("Username hoặc email đã tồn tại.")
        
        user = User(
            username=data.username,
            email=data.email,
            full_name=data.full_name,
            hashed_password=get_password_hash(data.password),
            role=RoleEnum.STUDENT,
            phone=data.phone,
            is_active=True
        )
        db.add(user)
        db.flush()

        code = f"HV{user.id:04d}"
        student = Student(
            user_id=user.id,
            student_code=code,
            date_of_birth=data.date_of_birth,
            address=data.address,
            status="ACTIVE"
        )
        db.add(student)
        db.commit()
        db.refresh(student)
        return {
            "id": student.id,
            "user_id": user.id,
            "student_code": student.student_code,
            "full_name": user.full_name,
            "email": user.email,
            "phone": user.phone,
            "date_of_birth": student.date_of_birth,
            "address": student.address,
            "status": student.status
        }

    @staticmethod
    def update_student(db: Session, student_id: int, data: StudentUpdate) -> dict:
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)
        
        user = student.user
        if data.full_name is not None:
            user.full_name = data.full_name
        if data.phone is not None:
            user.phone = data.phone
        if data.date_of_birth is not None:
            student.date_of_birth = data.date_of_birth
        if data.address is not None:
            student.address = data.address
        if data.status is not None:
            student.status = data.status
        
        db.commit()
        return {
            "id": student.id,
            "user_id": user.id,
            "student_code": student.student_code,
            "full_name": user.full_name,
            "email": user.email,
            "phone": user.phone,
            "date_of_birth": student.date_of_birth,
            "address": student.address,
            "status": student.status
        }

    @staticmethod
    def get_student(db: Session, student_id: int) -> dict:
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)
        user = student.user
        return {
            "id": student.id,
            "user_id": user.id,
            "student_code": student.student_code,
            "full_name": user.full_name,
            "email": user.email,
            "phone": user.phone,
            "date_of_birth": student.date_of_birth,
            "address": student.address,
            "status": student.status
        }

    @staticmethod
    def search_students(db: Session, q: Optional[str] = None, status: Optional[str] = None) -> List[dict]:
        query = db.query(Student).join(User).filter(Student.is_deleted == False)
        if q:
            query = query.filter(
                (Student.student_code.ilike(f"%{q}%")) |
                (User.full_name.ilike(f"%{q}%")) |
                (User.email.ilike(f"%{q}%")) |
                (User.phone.ilike(f"%{q}%"))
            )
        if status:
            query = query.filter(Student.status == status)
        
        results = []
        for s in query.all():
            results.append({
                "id": s.id,
                "user_id": s.user.id,
                "student_code": s.student_code,
                "full_name": s.user.full_name,
                "email": s.user.email,
                "phone": s.user.phone,
                "date_of_birth": s.date_of_birth,
                "address": s.address,
                "status": s.status
            })
        return results

    @staticmethod
    def get_learning_history(db: Session, student_id: int) -> List[EnrolledClassHistoryItem]:
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)
        
        enrollments = db.query(ClassStudent).filter(ClassStudent.student_id == student_id, ClassStudent.is_deleted == False).all()
        history = []
        for en in enrollments:
            cls = en.enrolled_class
            grade = db.query(GradeRecord).filter(
                GradeRecord.class_id == cls.id,
                GradeRecord.student_id == student_id,
                GradeRecord.is_deleted == False
            ).first()

            history.append(EnrolledClassHistoryItem(
                class_id=cls.id,
                class_code=cls.class_code,
                course_title=cls.course.title if cls.course else "",
                target_level=cls.course.target_level if cls.course else "",
                enrolled_at=en.enrolled_at,
                class_status=cls.status,
                student_class_status=en.status,
                total_score=grade.total_score if grade else None,
                result_status=grade.result_status if grade else None
            ))
        return history

    @staticmethod
    def update_status(db: Session, student_id: int, new_status: str) -> bool:
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)
        student.status = new_status
        db.commit()
        return True

    @staticmethod
    def delete_student(db: Session, student_id: int) -> bool:
        student = db.query(Student).filter(Student.id == student_id, Student.is_deleted == False).first()
        if not student:
            raise NotFoundException("Học viên", student_id)
        student.is_deleted = True
        student.user.is_active = False
        db.commit()
        return True

