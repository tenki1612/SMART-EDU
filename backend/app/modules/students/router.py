from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.students.schemas import StudentCreate, StudentUpdate, StudentResponse, EnrolledClassHistoryItem
from app.modules.students.service import StudentService

router = APIRouter()

@router.post("/", response_model=ApiResponse[StudentResponse], summary="FR-18: Thêm học viên (Admin/Staff)")
def create_student(
    data: StudentCreate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    student = StudentService.create_student(db, data)
    return ApiResponse(data=student, message="Tạo hồ sơ học viên thành công")

@router.put("/{student_id}", response_model=ApiResponse[StudentResponse], summary="FR-19: Cập nhật thông tin học viên")
def update_student(
    student_id: int,
    data: StudentUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    student = StudentService.update_student(db, student_id, data)
    return ApiResponse(data=student, message="Cập nhật học viên thành công")

@router.get("/{student_id}", response_model=ApiResponse[StudentResponse], summary="FR-20: Xem thông tin học viên")
def get_student(
    student_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    student = StudentService.get_student(db, student_id)
    return ApiResponse(data=student, message="Thông tin chi tiết học viên")

@router.get("/", response_model=ApiResponse[List[StudentResponse]], summary="FR-21: Tìm kiếm & xem danh sách học viên")
def search_students(
    q: Optional[str] = Query(None, description="Tìm theo mã, tên, email, sđt"),
    status: Optional[str] = Query(None, description="Lọc theo trạng thái"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.TEACHER]))
):
    students = StudentService.search_students(db, q=q, status=status)
    return ApiResponse(data=students, message="Danh sách học viên")

@router.get("/{student_id}/history", response_model=ApiResponse[List[EnrolledClassHistoryItem]], summary="FR-22: Xem lịch sử học tập & các lớp tham gia")
def get_student_history(
    student_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    history = StudentService.get_learning_history(db, student_id)
    return ApiResponse(data=history, message="Lịch sử học tập của học viên")

@router.patch("/{student_id}/status", response_model=ApiResponse[bool], summary="FR-23: Quản lý trạng thái học viên")
def update_student_status(
    student_id: int,
    new_status: str = Query(..., description="Trạng thái mới: ACTIVE, INACTIVE, SUSPENDED, COMPLETED"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    StudentService.update_status(db, student_id, new_status)
    return ApiResponse(data=True, message="Cập nhật trạng thái học viên thành công")

@router.delete("/{student_id}", response_model=ApiResponse[bool], summary="FR-24: Xóa học viên")
def delete_student(
    student_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    StudentService.delete_student(db, student_id)
    return ApiResponse(data=True, message="Xóa học viên thành công")

