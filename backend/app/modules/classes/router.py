from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.classes.schemas import (
    ClassCreate, ClassUpdate, ClassResponse, ClassRosterStudentItem, AddStudentToClassRequest
)
from app.modules.classes.service import ClassService

router = APIRouter()

@router.post("/", response_model=ApiResponse[ClassResponse], summary="FR-32: Tạo lớp học")
def create_class(
    data: ClassCreate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    cls = ClassService.create_class(db, data)
    return ApiResponse(data=cls, message="Tạo lớp học thành công")

@router.put("/{class_id}", response_model=ApiResponse[ClassResponse], summary="FR-33: Cập nhật thông tin lớp học")
def update_class(
    class_id: int,
    data: ClassUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    cls = ClassService.update_class(db, class_id, data)
    return ApiResponse(data=cls, message="Cập nhật lớp học thành công")

@router.get("/", response_model=ApiResponse[List[ClassResponse]], summary="FR-34 & FR-36: Xem danh sách & Tìm kiếm lớp học")
def list_classes(
    q: Optional[str] = Query(None, description="Tìm theo mã lớp"),
    course_id: Optional[int] = Query(None, description="Lọc theo khóa học"),
    status: Optional[str] = Query(None, description="Lọc: OPEN_FOR_ENROLLMENT, IN_PROGRESS, COMPLETED..."),
    db: Session = Depends(get_db)
):
    classes = ClassService.list_classes(db, q=q, course_id=course_id, status=status)
    return ApiResponse(data=classes, message="Danh sách lớp học")

@router.get("/{class_id}", response_model=ApiResponse[ClassResponse], summary="FR-35: Xem chi tiết lớp học (gồm cấp độ mục tiêu)")
def get_class_detail(
    class_id: int,
    db: Session = Depends(get_db)
):
    cls = ClassService.get_class_detail(db, class_id)
    return ApiResponse(data=cls, message="Chi tiết lớp học")

@router.patch("/{class_id}/assign-teacher", response_model=ApiResponse[ClassResponse], summary="FR-39: Gán giáo viên cho lớp")
def assign_teacher_to_class(
    class_id: int,
    teacher_id: int = Query(..., description="ID của giáo viên"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    cls = ClassService.assign_teacher(db, class_id, teacher_id)
    return ApiResponse(data=cls, message="Phân công giáo viên cho lớp thành công")

@router.get("/{class_id}/students", response_model=ApiResponse[List[ClassRosterStudentItem]], summary="FR-38: Quản lý danh sách học viên trong lớp")
def get_class_students(
    class_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload)
):
    students = ClassService.get_class_roster(db, class_id)
    return ApiResponse(data=students, message="Danh sách học viên trong lớp")

@router.post("/{class_id}/students", response_model=ApiResponse[bool], summary="FR-38: Thêm học viên vào lớp")
def add_student_to_class(
    class_id: int,
    data: AddStudentToClassRequest,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    ClassService.add_student_to_roster(db, class_id, data.student_id)
    return ApiResponse(data=True, message="Thêm học viên vào lớp thành công")

@router.patch("/{class_id}/status", response_model=ApiResponse[ClassResponse], summary="FR-40: Cập nhật trạng thái lớp học (kết thúc lớp)")
def update_class_status(
    class_id: int,
    new_status: str = Query(..., description="Trạng thái mới (ví dụ: COMPLETED)"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    cls = ClassService.update_class_status(db, class_id, new_status)
    return ApiResponse(data=cls, message="Cập nhật trạng thái lớp học thành công")

@router.delete("/{class_id}", response_model=ApiResponse[bool], summary="FR-41: Xóa lớp học")
def delete_class(
    class_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    ClassService.delete_class(db, class_id)
    return ApiResponse(data=True, message="Xóa lớp học thành công")

