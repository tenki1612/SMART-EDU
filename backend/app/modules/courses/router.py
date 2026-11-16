from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload, get_optional_user_payload
from app.common.response import ApiResponse
from app.modules.courses.schemas import CourseCreate, CourseUpdate, CourseResponse
from app.modules.courses.service import CourseService

router = APIRouter()

@router.post("/", response_model=ApiResponse[CourseResponse], summary="FR-11: Thêm khóa học")
def create_course(
    data: CourseCreate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    course = CourseService.create_course(db, data)
    return ApiResponse(data=course, message="Tạo khóa học thành công")

@router.put("/{course_id}", response_model=ApiResponse[CourseResponse], summary="FR-12: Cập nhật khóa học")
def update_course(
    course_id: int,
    data: CourseUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    course = CourseService.update_course(db, course_id, data)
    return ApiResponse(data=course, message="Cập nhật khóa học thành công")

@router.get("/", response_model=ApiResponse[List[CourseResponse]], summary="FR-13 & FR-15: Xem danh sách & Tìm kiếm khóa học")
def list_courses(
    q: Optional[str] = Query(None, description="Tìm theo tên hoặc cấp độ mục tiêu"),
    only_active: bool = Query(False, description="Chỉ lấy khóa đang hoạt động"),
    db: Session = Depends(get_db),
    payload: Optional[dict] = Depends(get_optional_user_payload)
):
    student_id = None
    if payload and payload.get("role") == RoleEnum.STUDENT.value:
        from app.modules.students.models import Student
        user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")
        student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
        if student:
            student_id = student.id
        else:
            return ApiResponse(data=[], message="Học viên chưa có hồ sơ học tập")

    courses = CourseService.list_courses(db, query=q, only_active=only_active, student_id=student_id)
    return ApiResponse(data=courses, message="Danh sách khóa học")

@router.get("/{course_id}", response_model=ApiResponse[CourseResponse], summary="FR-14: Xem chi tiết khóa học")
def get_course_detail(
    course_id: int,
    db: Session = Depends(get_db)
):
    course = CourseService.get_course_detail(db, course_id)
    return ApiResponse(data=course, message="Chi tiết khóa học")

@router.patch("/{course_id}/toggle-status", response_model=ApiResponse[CourseResponse], summary="FR-16: Kích hoạt / Ngừng sử dụng khóa học")
def toggle_course_status(
    course_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    course = CourseService.toggle_status(db, course_id)
    return ApiResponse(data=course, message="Thay đổi trạng thái khóa học thành công")

@router.delete("/{course_id}", response_model=ApiResponse[bool], summary="FR-17: Xóa khóa học")
def delete_course(
    course_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    CourseService.delete_course(db, course_id)
    return ApiResponse(data=True, message="Xóa khóa học thành công")

