from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.classrooms.schemas import ClassroomCreate, ClassroomUpdate, ClassroomResponse
from app.modules.classrooms.service import ClassroomService

router = APIRouter()

@router.post("/", response_model=ApiResponse[ClassroomResponse], summary="FR-42: Thêm phòng học")
def create_classroom(
    data: ClassroomCreate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    room = ClassroomService.create_classroom(db, data)
    return ApiResponse(data=room, message="Tạo phòng học thành công")

@router.put("/{room_id}", response_model=ApiResponse[ClassroomResponse], summary="FR-43: Cập nhật thông tin phòng học")
def update_classroom(
    room_id: int,
    data: ClassroomUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    room = ClassroomService.update_classroom(db, room_id, data)
    return ApiResponse(data=room, message="Cập nhật phòng học thành công")

@router.get("/", response_model=ApiResponse[List[ClassroomResponse]], summary="FR-44 & FR-46: Danh sách & Tìm kiếm phòng học")
def list_classrooms(
    q: Optional[str] = Query(None, description="Tìm theo tên phòng, tòa nhà"),
    status: Optional[str] = Query(None, description="Lọc: AVAILABLE, MAINTENANCE, OCCUPIED"),
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    rooms = ClassroomService.list_classrooms(db, q=q, status=status)
    return ApiResponse(data=rooms, message="Danh sách phòng học")

@router.get("/{room_id}", response_model=ApiResponse[ClassroomResponse], summary="FR-45: Xem chi tiết phòng học")
def get_classroom_detail(
    room_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    room = ClassroomService.get_classroom_detail(db, room_id)
    return ApiResponse(data=room, message="Chi tiết phòng học")

@router.patch("/{room_id}/capacity", response_model=ApiResponse[ClassroomResponse], summary="FR-47: Quản lý sức chứa phòng học")
def update_classroom_capacity(
    room_id: int,
    capacity: int = Query(..., gt=0, description="Sức chứa mới"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    room = ClassroomService.update_capacity(db, room_id, capacity)
    return ApiResponse(data=room, message="Cập nhật sức chứa phòng học thành công")

@router.patch("/{room_id}/status", response_model=ApiResponse[ClassroomResponse], summary="FR-48: Quản lý trạng thái phòng học")
def update_classroom_status(
    room_id: int,
    status: str = Query(..., description="Trạng thái: AVAILABLE, MAINTENANCE, OCCUPIED"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    room = ClassroomService.update_status(db, room_id, status)
    return ApiResponse(data=room, message="Cập nhật trạng thái phòng học thành công")

@router.delete("/{room_id}", response_model=ApiResponse[bool], summary="FR-49: Xóa phòng học")
def delete_classroom(
    room_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    ClassroomService.delete_classroom(db, room_id)
    return ApiResponse(data=True, message="Xóa phòng học thành công")

