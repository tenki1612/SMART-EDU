from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.students.models import Student
from app.modules.progression_parent.schemas import (
    ProgressionCheckRequest, ProgressionResponse, ParentWardInfoResponse
)
from app.modules.progression_parent.service import ProgressionParentService

router = APIRouter()

@router.post("/check-eligibility", response_model=ApiResponse[ProgressionResponse], summary="FR-78: Kiểm tra điều kiện đăng ký khóa học tiếp theo")
def check_progression(
    data: ProgressionCheckRequest,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    res = ProgressionParentService.check_and_create_progression(db, data)
    return ApiResponse(data=res, message="Kiểm tra điều kiện chuyển khóa thành công")

@router.patch("/{progression_id}/confirm", response_model=ApiResponse[ProgressionResponse], summary="FR-79: Xác nhận học viên đủ điều kiện học khóa cao hơn")
def confirm_progression(
    progression_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    staff_id = int(payload["sub"])
    res = ProgressionParentService.confirm_progression(db, progression_id, staff_id)
    return ApiResponse(data=res, message="Đã xác nhận học viên đủ điều kiện học khóa cao hơn")

@router.post("/register-next", response_model=ApiResponse[dict], summary="FR-80: Đăng ký khóa học tiếp theo trong lộ trình")
def register_next_course(
    target_class_id: int = Query(..., description="ID lớp học thuộc khóa tiếp theo"),
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        from app.core.exceptions import BusinessException
        raise BusinessException("Không tìm thấy hồ sơ học viên.")
    
    res = ProgressionParentService.register_next_course(db, student.id, target_class_id)
    return ApiResponse(data=res, message="Đăng ký khóa học tiếp theo thành công")

@router.get("/parent/my-wards", response_model=ApiResponse[List[ParentWardInfoResponse]], summary="FR-81: Phụ huynh xem thông tin học viên được giám hộ")
def get_parent_wards(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.PARENT]))
):
    parent_user_id = int(payload["sub"])
    wards = ProgressionParentService.get_parent_wards(db, parent_user_id)
    return ApiResponse(data=wards, message="Danh sách học viên được giám hộ")

@router.get("/parent/wards/{student_id}/enrollment-status", response_model=ApiResponse[List[dict]], summary="FR-82: Phụ huynh xem trạng thái đăng ký của con")
def get_ward_enrollment_status(
    student_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.PARENT]))
):
    parent_user_id = int(payload["sub"])
    status_list = ProgressionParentService.get_ward_enrollment_status(db, parent_user_id, student_id)
    return ApiResponse(data=status_list, message="Trạng thái đăng ký khóa học của con")

