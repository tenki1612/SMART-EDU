from typing import List, Optional
from sqlalchemy.orm import Session
from app.modules.classrooms.models import Classroom
from app.modules.schedules.models import ScheduleSession
from app.core.exceptions import BusinessException, NotFoundException
from app.modules.classrooms.schemas import ClassroomCreate, ClassroomUpdate

class ClassroomService:
    @staticmethod
    def create_classroom(db: Session, data: ClassroomCreate) -> Classroom:
        if db.query(Classroom).filter(Classroom.room_code == data.room_code, Classroom.is_deleted == False).first():
            raise BusinessException(f"Phòng học '{data.room_code}' đã tồn tại.")
        
        room = Classroom(
            room_code=data.room_code,
            building=data.building,
            capacity=data.capacity,
            status=data.status
        )
        db.add(room)
        db.commit()
        db.refresh(room)
        return room

    @staticmethod
    def update_classroom(db: Session, room_id: int, data: ClassroomUpdate) -> Classroom:
        room = db.query(Classroom).filter(Classroom.id == room_id, Classroom.is_deleted == False).first()
        if not room:
            raise NotFoundException("Phòng học", room_id)
        
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(room, field, value)
        
        db.commit()
        db.refresh(room)
        return room

    @staticmethod
    def list_classrooms(db: Session, q: Optional[str] = None, status: Optional[str] = None) -> List[Classroom]:
        query = db.query(Classroom).filter(Classroom.is_deleted == False)
        if q:
            query = query.filter((Classroom.room_code.ilike(f"%{q}%")) | (Classroom.building.ilike(f"%{q}%")))
        if status:
            query = query.filter(Classroom.status == status)
        return query.all()

    @staticmethod
    def get_classroom_detail(db: Session, room_id: int) -> Classroom:
        room = db.query(Classroom).filter(Classroom.id == room_id, Classroom.is_deleted == False).first()
        if not room:
            raise NotFoundException("Phòng học", room_id)
        return room

    @staticmethod
    def update_capacity(db: Session, room_id: int, capacity: int) -> Classroom:
        room = db.query(Classroom).filter(Classroom.id == room_id, Classroom.is_deleted == False).first()
        if not room:
            raise NotFoundException("Phòng học", room_id)
        if capacity <= 0:
            raise BusinessException("Sức chứa phòng học phải lớn hơn 0.")
        room.capacity = capacity
        db.commit()
        db.refresh(room)
        return room

    @staticmethod
    def update_status(db: Session, room_id: int, status: str) -> Classroom:
        room = db.query(Classroom).filter(Classroom.id == room_id, Classroom.is_deleted == False).first()
        if not room:
            raise NotFoundException("Phòng học", room_id)
        room.status = status
        db.commit()
        db.refresh(room)
        return room

    @staticmethod
    def delete_classroom(db: Session, room_id: int) -> bool:
        room = db.query(Classroom).filter(Classroom.id == room_id, Classroom.is_deleted == False).first()
        if not room:
            raise NotFoundException("Phòng học", room_id)
        
        # Check active schedules
        has_schedules = db.query(ScheduleSession).filter(ScheduleSession.classroom_id == room_id, ScheduleSession.is_deleted == False).first()
        if has_schedules:
            raise BusinessException("Không thể xóa phòng học đã có lịch học được xếp. Vui lòng chuyển trạng thái sang 'Bảo trì'.")
        
        room.is_deleted = True
        db.commit()
        return True

