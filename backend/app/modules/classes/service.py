from typing import List, Optional
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
    def _format_class_response(cls: Class) -> dict:
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
        
        cls = Class(
            class_code=data.class_code,
            course_id=data.course_id,
            teacher_id=data.teacher_id,
            max_capacity=data.max_capacity,
            current_enrolled=0,
            start_date=data.start_date,
            end_date=data.end_date,
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
        student_id: Optional[int] = None
    ) -> List[dict]:
        query = db.query(Class).filter(Class.is_deleted == False)
        if student_id is not None:
            enrolled_class_ids = [
                cs.class_id for cs in db.query(ClassStudent).filter(
                    ClassStudent.student_id == student_id,
                    ClassStudent.is_deleted == False
                ).all()
            ]
            query = query.filter(Class.id.in_(enrolled_class_ids))
        if q:
            query = query.filter(Class.class_code.ilike(f"%{q}%"))
        if course_id:
            query = query.filter(Class.course_id == course_id)
        if status:
            if student_id is not None and status == "IN_PROGRESS":
                query = query.filter(Class.status.in_(["OPEN_FOR_ENROLLMENT", "IN_PROGRESS"]))
            else:
                query = query.filter(Class.status == status)
        
        return [ClassService._format_class_response(c) for c in query.all()]

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

