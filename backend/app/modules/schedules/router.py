from typing import List, Optional
from datetime import date
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.schedules.schemas import (
    ScheduleSessionCreate, ScheduleSessionUpdate, ScheduleSessionResponse,
    ConflictCheckRequest, ConflictCheckResponse
)
from app.modules.schedules.service import ScheduleService
from app.modules.schedules.conflict_checker import ScheduleConflictChecker

router = APIRouter()

@router.post("/check-conflicts", response_model=ApiResponse[ConflictCheckResponse], summary="FR-65: Kiểm tra xung đột thời khóa biểu")
def check_conflicts(
    data: ConflictCheckRequest,
    db: Session = Depends(get_db)
):
    has_conflict, c_type, msg = ScheduleConflictChecker.check_conflicts(
        db=db,
        classroom_id=data.classroom_id,
        teacher_id=data.teacher_id,
        session_date=data.session_date,
        start_time=data.start_time,
        end_time=data.end_time,
        exclude_session_id=data.exclude_session_id
    )
    return ApiResponse(
        data=ConflictCheckResponse(
            has_conflict=has_conflict,
            conflict_type=c_type,
            message=msg
        ),
        message="Kiểm tra xung đột hoàn tất"
    )

@router.post("/", response_model=ApiResponse[ScheduleSessionResponse], summary="FR-61: Tạo thời khóa biểu")
def create_schedule_session(
    data: ScheduleSessionCreate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    session = ScheduleService.create_session(db, data)
    return ApiResponse(data=session, message="Thêm buổi học vào thời khóa biểu thành công")

@router.put("/{session_id}", response_model=ApiResponse[ScheduleSessionResponse], summary="FR-62: Cập nhật/Điều chỉnh thời khóa biểu")
def update_schedule_session(
    session_id: int,
    data: ScheduleSessionUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    session = ScheduleService.update_session(db, session_id, data)
    return ApiResponse(data=session, message="Điều chỉnh lịch học thành công")

@router.get("/", response_model=ApiResponse[List[ScheduleSessionResponse]], summary="FR-63 & FR-64: Xem & Tìm kiếm thời khóa biểu")
def list_schedules(
    class_id: Optional[int] = Query(None, description="Lọc theo mã lớp"),
    teacher_id: Optional[int] = Query(None, description="Lọc theo giảng viên"),
    from_date: Optional[date] = Query(None, description="Từ ngày"),
    to_date: Optional[date] = Query(None, description="Đến ngày"),
    db: Session = Depends(get_db)
):
    sessions = ScheduleService.list_sessions(db, class_id=class_id, teacher_id=teacher_id, from_date=from_date, to_date=to_date)
    return ApiResponse(data=sessions, message="Thời khóa biểu")

@router.patch("/classes/{class_id}/confirm", response_model=ApiResponse[bool], summary="FR-66: Xác nhận thời khóa biểu chính thức")
def confirm_schedule(
    class_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    ScheduleService.confirm_schedule(db, class_id)
    return ApiResponse(data=True, message="Đã xác nhận thời khóa biểu chính thức cho lớp học")

@router.patch("/{session_id}/cancel", response_model=ApiResponse[bool], summary="FR-67: Hủy buổi học")
def cancel_session(
    session_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    ScheduleService.cancel_session(db, session_id)
    return ApiResponse(data=True, message="Đã hủy buổi học")

@router.delete("/{session_id}", response_model=ApiResponse[bool], summary="Xóa buổi học khỏi thời khóa biểu")
def delete_session(
    session_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    ScheduleService.delete_session(db, session_id)
    return ApiResponse(data=True, message="Đã xóa buổi học khỏi thời khóa biểu")

@router.get("/personal", response_model=ApiResponse[List[ScheduleSessionResponse]], summary="FR-68: Xem thời khóa biểu cá nhân")
def get_personal_schedule(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    role = payload.get("role", "")
    schedules = ScheduleService.get_personal_schedule(db, user_id=user_id, role=role)
    return ApiResponse(data=schedules, message="Thời khóa biểu cá nhân")

