from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.students.models import Student
from app.modules.students.schemas import StudentCreate, StudentUpdate, StudentResponse, EnrolledClassHistoryItem
from app.modules.students.service import StudentService

router = APIRouter()


def _assert_can_view_student(db: Session, payload: dict, student_id: int) -> None:
    """Scope student PII/history access to self, wards, or academic managers."""
    role = payload.get("role")
    if role in (RoleEnum.ADMIN.value, RoleEnum.ACADEMIC_STAFF.value, RoleEnum.TEACHER.value):
        return
    user_id = int(payload.get("sub", 0) or 0)
    if role == RoleEnum.STUDENT.value:
        own = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
        if not own or own.id != student_id:
            raise HTTPException(status_code=403, detail="Bạn chỉ được xem thông tin của chính mình.")
        return
    if role == RoleEnum.PARENT.value:
        from app.modules.progression_parent.models import ParentStudent
        link = db.query(ParentStudent).filter(
            ParentStudent.parent_user_id == user_id,
            ParentStudent.student_id == student_id
        ).first()
        if not link:
            raise HTTPException(status_code=403, detail="Bạn chỉ được xem thông tin của học viên mình giám hộ.")
        return
    raise HTTPException(status_code=403, detail="Vai trò không được phép xem thông tin học viên.")

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
    _assert_can_view_student(db, payload, student_id)
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
    _assert_can_view_student(db, payload, student_id)
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

