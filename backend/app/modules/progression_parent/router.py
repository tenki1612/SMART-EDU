from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.students.models import Student
from app.modules.grades.schemas import GradeRecordResponse
from app.modules.progression_parent.schemas import (
    ProgressionCheckRequest, ProgressionResponse, ParentWardInfoResponse,
    StudentProgressionRequest, ProgressionRejectRequest, AvailableCourseResponse
)
from app.modules.progression_parent.service import ProgressionParentService
from app.core.exceptions import BusinessException

router = APIRouter()

@router.get("/", response_model=ApiResponse[List[ProgressionResponse]], summary="Danh sách hồ sơ chuyển khóa học (Admin/Học vụ)")
def list_progressions(
    status: Optional[str] = Query(None, description="Lọc trạng thái: ALL, PENDING, CONFIRMED"),
    student_id: Optional[int] = Query(None, description="Lọc theo mã học viên"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    results = ProgressionParentService.list_progressions(db, student_id=student_id, status=status)
    return ApiResponse(data=results, message="Danh sách hồ sơ chuyển khóa học")

@router.get("/my-progressions", response_model=ApiResponse[List[ProgressionResponse]], summary="Học viên xem hồ sơ chuyển khóa của mình")
def get_my_progressions(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.STUDENT]))
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        raise BusinessException("Không tìm thấy hồ sơ học viên.")
    results = ProgressionParentService.list_progressions(db, student_id=student.id)
    return ApiResponse(data=results, message="Hồ sơ chuyển khóa học của tôi")

@router.get("/available-courses", response_model=ApiResponse[List[dict]], summary="Danh sách các khóa học mở tiếp nhận chuyển khóa")
def get_available_courses(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role")
    student_id = None
    if user_role == RoleEnum.STUDENT.value:
        student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
        if student:
            student_id = student.id
    results = ProgressionParentService.get_available_courses(db, student_id=student_id)
    return ApiResponse(data=results, message="Danh sách khóa học tiếp nhận chuyển khóa")

@router.post("/request", response_model=ApiResponse[ProgressionResponse], summary="Học viên đăng ký chuyển khóa học")
def request_progression(
    data: StudentProgressionRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.STUDENT, RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    user_id = int(payload["sub"])
    user_role = payload.get("role")
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        raise BusinessException("Không tìm thấy hồ sơ học viên tương ứng với tài khoản.")
    
    res = ProgressionParentService.request_progression(
        db=db,
        student_id=student.id,
        next_course_id=data.next_course_id,
        current_course_id=data.current_course_id,
        note=data.note
    )
    return ApiResponse(data=res, message="Đã gửi yêu cầu đăng ký chuyển khóa học thành công! Vui lòng chờ Học vụ phê duyệt.")

@router.patch("/{progression_id}/cancel", response_model=ApiResponse[bool], summary="Học viên hủy yêu cầu chuyển khóa khi chưa duyệt")
def cancel_progression(
    progression_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.STUDENT]))
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        raise BusinessException("Không tìm thấy hồ sơ học viên.")
    
    ProgressionParentService.cancel_progression(db, student.id, progression_id)
    return ApiResponse(data=True, message="Đã hủy yêu cầu chuyển khóa học thành công.")

@router.patch("/{progression_id}/reject", response_model=ApiResponse[ProgressionResponse], summary="Học vụ từ chối yêu cầu chuyển khóa")
def reject_progression(
    progression_id: int,
    data: ProgressionRejectRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    staff_id = int(payload["sub"])
    res = ProgressionParentService.reject_progression(db, progression_id, staff_id, data.reason)
    return ApiResponse(data=res, message="Đã từ chối yêu cầu chuyển khóa học.")

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

@router.get("/parent/wards/{student_id}/grades", response_model=ApiResponse[List[GradeRecordResponse]], summary="Phụ huynh xem bảng điểm chi tiết của con")
def get_ward_grades(
    student_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.PARENT]))
):
    parent_user_id = int(payload["sub"])
    grades = ProgressionParentService.get_ward_grades(db, parent_user_id, student_id)
    return ApiResponse(data=grades, message="Bảng điểm chi tiết của con")
