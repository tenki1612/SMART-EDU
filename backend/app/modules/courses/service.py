from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.courses.models import Course
from app.modules.classes.models import Class
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.courses.schemas import CourseCreate, CourseUpdate

class CourseService:
    @staticmethod
    def create_course(db: Session, data: CourseCreate) -> Course:
        if db.query(Course).filter(Course.code == data.code, Course.is_deleted == False).first():
            raise BusinessException(f"Mã khóa học '{data.code}' đã tồn tại.")
        
        course = Course(
            code=data.code,
            title=data.title,
            description=data.description,
            target_level=data.target_level,
            duration_weeks=data.duration_weeks,
            fee=data.fee,
            is_active=True
        )
        db.add(course)
        db.commit()
        db.refresh(course)
        return course

    @staticmethod
    def update_course(db: Session, course_id: int, data: CourseUpdate) -> Course:
        course = db.query(Course).filter(Course.id == course_id, Course.is_deleted == False).first()
        if not course:
            raise NotFoundException("Khóa học", course_id)
        
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(course, field, value)
        
        db.commit()
        db.refresh(course)
        return course

    @staticmethod
    def list_courses(db: Session, query: Optional[str] = None, only_active: bool = False) -> List[Course]:
        q = db.query(Course).filter(Course.is_deleted == False)
        if only_active:
            q = q.filter(Course.is_active == True)
        if query:
            q = q.filter((Course.title.ilike(f"%{query}%")) | (Course.code.ilike(f"%{query}%")) | (Course.target_level.ilike(f"%{query}%")))
        return q.all()

    @staticmethod
    def get_course_detail(db: Session, course_id: int) -> Course:
        course = db.query(Course).filter(Course.id == course_id, Course.is_deleted == False).first()
        if not course:
            raise NotFoundException("Khóa học", course_id)
        return course

    @staticmethod
    def toggle_status(db: Session, course_id: int) -> Course:
        course = db.query(Course).filter(Course.id == course_id, Course.is_deleted == False).first()
        if not course:
            raise NotFoundException("Khóa học", course_id)
        course.is_active = not course.is_active
        db.commit()
        db.refresh(course)
        return course

    @staticmethod
    def delete_course(db: Session, course_id: int) -> bool:
        course = db.query(Course).filter(Course.id == course_id, Course.is_deleted == False).first()
        if not course:
            raise NotFoundException("Khóa học", course_id)
        
        # Check active classes constraint
        has_classes = db.query(Class).filter(Class.course_id == course_id, Class.is_deleted == False).first()
        if has_classes:
            raise BusinessException("Không thể xóa khóa học đã có lớp học liên kết. Vui lòng chuyển trạng thái sang 'Ngừng sử dụng'.")
        
        course.is_deleted = True
        db.commit()
        return True

