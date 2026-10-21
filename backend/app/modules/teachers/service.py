from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.accounts.models import User
from app.modules.teachers.models import Teacher
from app.modules.schedules.models import ScheduleSession
from app.core.security import get_password_hash
from app.core.permissions import RoleEnum
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.teachers.schemas import TeacherCreate, TeacherUpdate, TeacherScheduleItem

class TeacherService:
    @staticmethod
    def create_teacher(db: Session, data: TeacherCreate) -> dict:
        if db.query(User).filter((User.username == data.username) | (User.email == data.email)).first():
            raise BusinessException("Username hoặc email đã tồn tại.")
        
        user = User(
            username=data.username,
            email=data.email,
            full_name=data.full_name,
            hashed_password=get_password_hash(data.password),
            role=RoleEnum.TEACHER,
            phone=data.phone,
            is_active=True
        )
        db.add(user)
        db.flush()

        code = f"GV{user.id:04d}"
        teacher = Teacher(
            user_id=user.id,
            teacher_code=code,
            specialty=data.specialty,
            degree=data.degree,
            status="ACTIVE"
        )
        db.add(teacher)
        db.commit()
        db.refresh(teacher)
        return {
            "id": teacher.id,
            "user_id": user.id,
            "teacher_code": teacher.teacher_code,
            "full_name": user.full_name,
            "email": user.email,
            "phone": user.phone,
            "specialty": teacher.specialty,
            "degree": teacher.degree,
            "status": teacher.status
        }

    @staticmethod
    def update_teacher(db: Session, teacher_id: int, data: TeacherUpdate) -> dict:
        teacher = db.query(Teacher).filter(Teacher.id == teacher_id, Teacher.is_deleted == False).first()
        if not teacher:
            raise NotFoundException("Giáo viên", teacher_id)
        
        user = teacher.user
        if data.full_name is not None:
            user.full_name = data.full_name
        if data.phone is not None:
            user.phone = data.phone
        if data.specialty is not None:
            teacher.specialty = data.specialty
        if data.degree is not None:
            teacher.degree = data.degree
        if data.status is not None:
            teacher.status = data.status
        
        db.commit()
        return {
            "id": teacher.id,
            "user_id": user.id,
            "teacher_code": teacher.teacher_code,
            "full_name": user.full_name,
            "email": user.email,
            "phone": user.phone,
            "specialty": teacher.specialty,
            "degree": teacher.degree,
            "status": teacher.status
        }

    @staticmethod
    def get_teacher(db: Session, teacher_id: int) -> dict:
        teacher = db.query(Teacher).filter(Teacher.id == teacher_id, Teacher.is_deleted == False).first()
        if not teacher:
            raise NotFoundException("Giáo viên", teacher_id)
        user = teacher.user
        return {
            "id": teacher.id,
            "user_id": user.id,
            "teacher_code": teacher.teacher_code,
            "full_name": user.full_name,
            "email": user.email,
            "phone": user.phone,
            "specialty": teacher.specialty,
            "degree": teacher.degree,
            "status": teacher.status
        }

    @staticmethod
    def search_teachers(db: Session, q: Optional[str] = None, status: Optional[str] = None) -> List[dict]:
        query = db.query(Teacher).join(User).filter(Teacher.is_deleted == False)
        if q:
            query = query.filter(
                (Teacher.teacher_code.ilike(f"%{q}%")) |
                (User.full_name.ilike(f"%{q}%")) |
                (Teacher.specialty.ilike(f"%{q}%"))
            )
        if status:
            query = query.filter(Teacher.status == status)
        
        results = []
        for t in query.all():
            results.append({
                "id": t.id,
                "user_id": t.user.id,
                "teacher_code": t.teacher_code,
                "full_name": t.user.full_name,
                "email": t.user.email,
                "phone": t.user.phone,
                "specialty": t.specialty,
                "degree": t.degree,
                "status": t.status
            })
        return results

    @staticmethod
    def get_teacher_schedule(db: Session, teacher_id: int) -> List[TeacherScheduleItem]:
        teacher = db.query(Teacher).filter(Teacher.id == teacher_id, Teacher.is_deleted == False).first()
        if not teacher:
            raise NotFoundException("Giáo viên", teacher_id)
        
        sessions = db.query(ScheduleSession).filter(
            ScheduleSession.teacher_id == teacher_id,
            ScheduleSession.is_deleted == False
        ).order_by(ScheduleSession.session_date.asc(), ScheduleSession.start_time.asc()).all()

        results = []
        for s in sessions:
            results.append(TeacherScheduleItem(
                session_id=s.id,
                class_code=s.session_class.class_code if s.session_class else "",
                course_title=s.session_class.course.title if (s.session_class and s.session_class.course) else "",
                room_code=s.classroom.room_code if s.classroom else "",
                session_date=s.session_date,
                start_time=s.start_time,
                end_time=s.end_time,
                slot_name=s.slot_name,
                is_confirmed=s.is_confirmed
            ))
        return results

    @staticmethod
    def update_status(db: Session, teacher_id: int, new_status: str) -> bool:
        teacher = db.query(Teacher).filter(Teacher.id == teacher_id, Teacher.is_deleted == False).first()
        if not teacher:
            raise NotFoundException("Giáo viên", teacher_id)
        teacher.status = new_status
        db.commit()
        return True

    @staticmethod
    def delete_teacher(db: Session, teacher_id: int) -> bool:
        teacher = db.query(Teacher).filter(Teacher.id == teacher_id, Teacher.is_deleted == False).first()
        if not teacher:
            raise NotFoundException("Giáo viên", teacher_id)
        teacher.is_deleted = True
        teacher.user.is_active = False
        db.commit()
        return True

