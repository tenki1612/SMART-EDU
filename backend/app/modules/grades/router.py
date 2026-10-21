from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.students.models import Student
from app.modules.grades.schemas import (
    BatchGradeInputRequest, AddStudentGradeRequest, ClassGradingSheetStudent, GradeRecordResponse
)
from app.modules.grades.service import GradeService

router = APIRouter()

@router.get("/classes/{class_id}/sheet", response_model=ApiResponse[List[ClassGradingSheetStudent]], summary="FR-69: Xem danh sách học viên phục vụ nhập điểm")
def get_class_grading_sheet(
    class_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.TEACHER]))
):
    sheet = GradeService.get_class_grading_sheet(db, class_id)
    return ApiResponse(data=sheet, message="Danh sách nhập điểm lớp học")

@router.post("/batch", response_model=ApiResponse[bool], summary="FR-70, FR-71, FR-73, FR-74: Nhập & Cập nhật điểm học viên")
def save_grades(
    data: BatchGradeInputRequest,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.TEACHER]))
):
    GradeService.save_grades(db, data)
    return ApiResponse(data=True, message="Lưu điểm và tổng hợp kết quả học tập thành công")

@router.patch("/classes/{class_id}/confirm", response_model=ApiResponse[bool], summary="FR-76 & FR-77: Xác nhận kết quả học tập chính thức")
def confirm_grades(
    class_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    GradeService.confirm_grades(db, class_id)
    return ApiResponse(data=True, message="Xác nhận kết quả học tập lớp học thành công")

@router.patch("/classes/{class_id}/unlock", response_model=ApiResponse[bool], summary="Mở khóa bảng điểm để giáo viên chỉnh sửa")
def unlock_grades(
    class_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.TEACHER]))
):
    GradeService.unlock_grades(db, class_id)
    return ApiResponse(data=True, message="Đã mở khóa bảng điểm lớp học")

@router.post("/classes/{class_id}/students", response_model=ApiResponse[ClassGradingSheetStudent], summary="Thêm học viên vào bảng điểm lớp")
def add_student_to_grading_sheet(
    class_id: int,
    data: AddStudentGradeRequest,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.TEACHER, RoleEnum.ACADEMIC_STAFF]))
):
    record = GradeService.add_student_to_grading_sheet(db, class_id, data)
    return ApiResponse(data=record, message="Đã thêm học viên vào bảng điểm thành công")

@router.delete("/classes/{class_id}/students/{student_id}", response_model=ApiResponse[bool], summary="Xóa học viên khỏi bảng điểm lớp")
def delete_student_from_grading_sheet(
    class_id: int,
    student_id: int,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.TEACHER, RoleEnum.ACADEMIC_STAFF]))
):
    GradeService.delete_student_from_grading_sheet(db, class_id, student_id)
    return ApiResponse(data=True, message="Đã xóa học viên khỏi bảng điểm lớp")

@router.get("/my-grades", response_model=ApiResponse[List[GradeRecordResponse]], summary="FR-72 & FR-75: Học viên tra cứu bảng điểm cá nhân")
def get_my_grades(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
    if not student:
        return ApiResponse(data=[], message="Chưa có hồ sơ học viên")
    
    grades = GradeService.get_student_grades(db, student.id)
    return ApiResponse(data=grades, message="Bảng điểm học viên")

