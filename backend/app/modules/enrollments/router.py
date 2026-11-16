from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.students.models import Student
from app.modules.enrollments.schemas import (
    EnrollmentCreateRequest, EnrollmentRejectRequest, EnrollmentRequestResponse
)
from app.modules.enrollments.service import EnrollmentService

router = APIRouter()

@router.post("/", response_model=ApiResponse[EnrollmentRequestResponse], summary="FR-52: Đăng ký lớp học (Học viên)")
def create_enrollment_request(
    data: EnrollmentCreateRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        from app.core.exceptions import BusinessException
        raise BusinessException("Tài khoản chưa được liên kết với hồ sơ học viên.")
    
    req = EnrollmentService.create_request(db, student.id, data)
    return ApiResponse(data=req, message="Gửi yêu cầu đăng ký lớp học thành công")

@router.get("/my-requests", response_model=ApiResponse[List[EnrollmentRequestResponse]], summary="FR-53: Xem trạng thái đăng ký của tôi")
def get_my_enrollment_requests(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        return ApiResponse(data=[], message="Chưa có hồ sơ học viên")
    
    requests = EnrollmentService.list_requests(db, student_id=student.id)
    return ApiResponse(data=requests, message="Danh sách yêu cầu đăng ký")

@router.patch("/{request_id}/cancel", response_model=ApiResponse[bool], summary="FR-54: Hủy yêu cầu đăng ký")
def cancel_enrollment_request(
    request_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        from app.core.exceptions import BusinessException
        raise BusinessException("Không tìm thấy hồ sơ học viên.")
    
    EnrollmentService.cancel_request(db, student.id, request_id)
    return ApiResponse(data=True, message="Hủy yêu cầu đăng ký thành công")

@router.get("/", response_model=ApiResponse[List[EnrollmentRequestResponse]], summary="FR-55: Xem danh sách yêu cầu đăng ký (Học vụ)")
def list_all_requests(
    status: Optional[str] = Query(None, description="Lọc theo PENDING, APPROVED, REJECTED, CANCELLED"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    requests = EnrollmentService.list_requests(db, status=status)
    return ApiResponse(data=requests, message="Danh sách toàn bộ yêu cầu đăng ký")

@router.patch("/{request_id}/approve", response_model=ApiResponse[EnrollmentRequestResponse], summary="FR-57 & FR-59: Duyệt đăng ký lớp học")
def approve_request(
    request_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    staff_id = int(payload["sub"])
    req = EnrollmentService.approve_request(db, request_id, staff_id)
    return ApiResponse(data=req, message="Đã phê duyệt yêu cầu đăng ký và thêm học viên vào lớp thành công")

@router.patch("/{request_id}/reject", response_model=ApiResponse[EnrollmentRequestResponse], summary="FR-58: Từ chối đăng ký lớp học")
def reject_request(
    request_id: int,
    data: EnrollmentRejectRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    staff_id = int(payload["sub"])
    req = EnrollmentService.reject_request(db, request_id, staff_id, data)
    return ApiResponse(data=req, message="Đã từ chối yêu cầu đăng ký")

