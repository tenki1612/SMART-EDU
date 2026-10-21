from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.teachers.schemas import TeacherCreate, TeacherUpdate, TeacherResponse, TeacherScheduleItem
from app.modules.teachers.service import TeacherService

router = APIRouter()

@router.post("/", response_model=ApiResponse[TeacherResponse], summary="FR-25: Thêm giáo viên (Admin/Staff)")
def create_teacher(
    data: TeacherCreate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    teacher = TeacherService.create_teacher(db, data)
    return ApiResponse(data=teacher, message="Tạo hồ sơ giáo viên thành công")

@router.put("/{teacher_id}", response_model=ApiResponse[TeacherResponse], summary="FR-26: Cập nhật thông tin giáo viên")
def update_teacher(
    teacher_id: int,
    data: TeacherUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    teacher = TeacherService.update_teacher(db, teacher_id, data)
    return ApiResponse(data=teacher, message="Cập nhật giáo viên thành công")

@router.get("/{teacher_id}", response_model=ApiResponse[TeacherResponse], summary="FR-27: Xem thông tin giáo viên")
def get_teacher(
    teacher_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    teacher = TeacherService.get_teacher(db, teacher_id)
    return ApiResponse(data=teacher, message="Thông tin giáo viên")

@router.get("/", response_model=ApiResponse[List[TeacherResponse]], summary="FR-28: Tìm kiếm giáo viên")
def search_teachers(
    q: Optional[str] = Query(None, description="Tìm theo tên, mã, chuyên môn"),
    status: Optional[str] = Query(None, description="Lọc trạng thái"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    teachers = TeacherService.search_teachers(db, q=q, status=status)
    return ApiResponse(data=teachers, message="Danh sách giáo viên")

@router.get("/{teacher_id}/schedule", response_model=ApiResponse[List[TeacherScheduleItem]], summary="FR-29: Xem lịch dạy của giáo viên")
def get_teacher_schedule(
    teacher_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    schedules = TeacherService.get_teacher_schedule(db, teacher_id)
    return ApiResponse(data=schedules, message="Lịch giảng dạy của giáo viên")

@router.patch("/{teacher_id}/status", response_model=ApiResponse[bool], summary="FR-30: Quản lý trạng thái giáo viên")
def update_teacher_status(
    teacher_id: int,
    new_status: str = Query(..., description="Trạng thái: ACTIVE, ON_LEAVE, INACTIVE"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    TeacherService.update_status(db, teacher_id, new_status)
    return ApiResponse(data=True, message="Cập nhật trạng thái thành công")

@router.delete("/{teacher_id}", response_model=ApiResponse[bool], summary="FR-31: Xóa giáo viên")
def delete_teacher(
    teacher_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    TeacherService.delete_teacher(db, teacher_id)
    return ApiResponse(data=True, message="Xóa giáo viên thành công")

