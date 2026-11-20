from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload, get_optional_user_payload
from app.common.response import ApiResponse
from app.modules.classes.schemas import (
    ClassCreate, ClassUpdate, ClassResponse, ClassRosterStudentItem, AddStudentToClassRequest,
    ClassTransferRequest, ClassTransferCreateRequest, ClassTransferRejectRequest,
    ClassTransferItemResponse, ClassTransferDetailResponse, ClassTransferTargetItem
)
from app.modules.classes.service import ClassService

router = APIRouter()

# =========================================================================
# CLASS TRANSFER REQUESTS (QUY TRÌNH YÊU CẦU VÀ PHÊ DUYỆT CHUYỂN LỚP)
# (Khai báo trước /{class_id} để tránh FastAPI path collision)
# =========================================================================

@router.post("/transfer-requests", response_model=ApiResponse[ClassTransferDetailResponse], summary="Tạo yêu cầu chuyển lớp (Học viên/Học vụ)")
def create_transfer_request(
    data: ClassTransferCreateRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.STUDENT]))
):
    role = payload.get("role")
    user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")
    student_id = data.student_id

    if role == RoleEnum.STUDENT.value:
        from app.modules.students.models import Student
        student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
        if not student:
            raise HTTPException(status_code=404, detail="Không tìm thấy hồ sơ học viên.")
        student_id = student.id
    elif not student_id:
        raise HTTPException(status_code=400, detail="Vui lòng chỉ định student_id để tạo yêu cầu chuyển lớp.")

    req = ClassService.create_transfer_request(
        db=db,
        student_id=student_id,
        current_class_id=data.current_class_id,
        target_class_id=data.target_class_id,
        reason=data.reason
    )
    return ApiResponse(data=req, message="Tạo yêu cầu chuyển lớp thành công. Yêu cầu đang ở trạng thái chờ phê duyệt.")

@router.get("/transfer-requests", response_model=ApiResponse[List[ClassTransferItemResponse]], summary="Xem danh sách yêu cầu chuyển lớp")
def list_transfer_requests(
    status: Optional[str] = Query(None, description="Lọc theo trạng thái: PENDING, APPROVED, REJECTED"),
    q: Optional[str] = Query(None, description="Tìm theo mã/tên học viên hoặc mã lớp"),
    class_id: Optional[int] = Query(None, description="Lọc theo lớp học đích"),
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.STUDENT, RoleEnum.TEACHER]))
):
    items = ClassService.list_transfer_requests(
        db=db,
        user_payload=payload,
        status=status,
        search=q,
        class_id=class_id
    )
    return ApiResponse(data=items, message="Danh sách yêu cầu chuyển lớp")

@router.get("/transfer-requests/{request_id}", response_model=ApiResponse[ClassTransferDetailResponse], summary="Xem chi tiết yêu cầu chuyển lớp & thẩm định điều kiện")
def get_transfer_request_detail(
    request_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.STUDENT, RoleEnum.TEACHER]))
):
    detail = ClassService.get_transfer_request_detail(
        db=db,
        request_id=request_id,
        user_payload=payload
    )
    return ApiResponse(data=detail, message="Chi tiết yêu cầu chuyển lớp")

@router.post("/transfer-requests/{request_id}/approve", response_model=ApiResponse[ClassTransferDetailResponse], summary="Phê duyệt yêu cầu chuyển lớp (Admin/Học vụ)")
def approve_transfer_request(
    request_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    reviewer_user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")
    res = ClassService.approve_transfer_request(
        db=db,
        request_id=request_id,
        reviewer_user_id=reviewer_user_id
    )
    return ApiResponse(data=res, message="Phê duyệt yêu cầu chuyển lớp thành công. Học viên đã được chuyển sang lớp mới.")

@router.post("/transfer-requests/{request_id}/reject", response_model=ApiResponse[ClassTransferDetailResponse], summary="Từ chối yêu cầu chuyển lớp (Admin/Học vụ)")
def reject_transfer_request(
    request_id: int,
    data: ClassTransferRejectRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    reviewer_user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")
    res = ClassService.reject_transfer_request(
        db=db,
        request_id=request_id,
        reviewer_user_id=reviewer_user_id,
        rejection_reason=data.reason
    )
    return ApiResponse(data=res, message="Đã từ chối yêu cầu chuyển lớp.")

# =========================================================================
# LỚP HỌC CRUD VÀ ROSTER
# =========================================================================

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
    teacher_id: Optional[int] = Query(None, description="Lọc theo giáo viên phụ trách"),
    my_classes: Optional[bool] = Query(False, description="Chỉ lấy các lớp do giảng viên phụ trách"),
    db: Session = Depends(get_db),
    payload: Optional[dict] = Depends(get_optional_user_payload)
):
    student_id = None
    if payload:
        user_role = payload.get("role")
        user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")
        if user_role == RoleEnum.STUDENT.value:
            from app.modules.students.models import Student
            student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
            if student:
                student_id = student.id
            else:
                return ApiResponse(data=[], message="Học viên chưa có hồ sơ học tập")
        elif user_role == RoleEnum.TEACHER.value:
            from app.modules.teachers.models import Teacher
            teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
            if teacher:
                teacher_id = teacher.id
            else:
                return ApiResponse(data=[], message="Chưa tìm thấy hồ sơ giảng viên")

    classes = ClassService.list_classes(
        db, q=q, course_id=course_id, status=status, student_id=student_id, teacher_id=teacher_id
    )
    return ApiResponse(data=classes, message="Danh sách lớp học")

@router.get("/{class_id}", response_model=ApiResponse[ClassResponse], summary="FR-35: Xem chi tiết lớp học (gồm cấp độ mục tiêu)")
def get_class_detail(
    class_id: int,
    db: Session = Depends(get_db),
    payload: Optional[dict] = Depends(get_optional_user_payload)
):
    if payload and payload.get("role") == RoleEnum.TEACHER.value:
        from app.modules.teachers.models import Teacher
        from app.modules.classes.models import Class
        user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")
        teacher = db.query(Teacher).filter(Teacher.user_id == user_id, Teacher.is_deleted == False).first()
        raw_cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
        if not raw_cls:
            raise HTTPException(status_code=404, detail="Không tìm thấy lớp học")
        if not teacher or raw_cls.teacher_id != teacher.id:
            raise HTTPException(
                status_code=403,
                detail="Giảng viên chỉ có quyền xem thông tin các lớp học do mình phụ trách/giảng dạy!"
            )
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
    role = payload.get("role")
    user_id = payload.get("user_id")

    # Học viên không có quyền xem danh sách học viên trong lớp học
    if role == RoleEnum.STUDENT.value:
        raise HTTPException(status_code=403, detail="Học viên không có quyền xem danh sách học viên trong lớp học!")

    user_id = int(payload.get("sub", 0)) if "sub" in payload else payload.get("user_id")

    # Giáo viên chỉ được xem danh sách học viên lớp học của mình
    if role == RoleEnum.TEACHER.value:
        from app.modules.teachers.models import Teacher
        from app.modules.classes.models import Class
        teacher = db.query(Teacher).filter(Teacher.user_id == user_id).first()
        cls = db.query(Class).filter(Class.id == class_id).first()
        if not cls:
            raise HTTPException(status_code=404, detail="Không tìm thấy lớp học")
        if not teacher or cls.teacher_id != teacher.id:
            raise HTTPException(status_code=403, detail="Giáo viên chỉ được phép xem danh sách học viên lớp học của mình!")

    # Phụ huynh chỉ được xem danh sách lớp có con mình theo học (chống IDOR)
    if role == RoleEnum.PARENT.value:
        from app.modules.progression_parent.models import ParentStudent
        from app.modules.classes.models import ClassStudent
        ward_ids = [r[0] for r in db.query(ParentStudent.student_id).filter(
            ParentStudent.parent_user_id == user_id
        ).all()]
        ward_in_class = None
        if ward_ids:
            ward_in_class = db.query(ClassStudent.id).filter(
                ClassStudent.class_id == class_id,
                ClassStudent.student_id.in_(ward_ids),
                ClassStudent.is_deleted == False
            ).first()
        if not ward_in_class:
            raise HTTPException(status_code=403, detail="Phụ huynh chỉ được xem danh sách lớp học của con mình!")

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

@router.get("/{class_id}/transfer-targets", response_model=ApiResponse[List[ClassTransferTargetItem]], summary="Lấy danh sách các lớp học hợp lệ để chuyển sang")
def get_transfer_targets(
    class_id: int,
    db: Session = Depends(get_db),
    payload: dict = Depends(get_current_user_payload),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.STUDENT]))
):
    role = payload.get("role")
    student_id = None
    if role == RoleEnum.STUDENT.value:
        user_id = int(payload["sub"])
        from app.modules.students.models import Student
        from app.modules.classes.models import ClassStudent
        student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
        if not student:
            raise HTTPException(status_code=403, detail="Không tìm thấy hồ sơ học viên hoặc không có quyền truy cập.")
        cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.student_id == student.id,
            ClassStudent.status == "ENROLLED",
            ClassStudent.is_deleted == False
        ).first()
        if not cs:
            raise HTTPException(status_code=403, detail="Bạn không có quyền xem thông tin chuyển lớp của lớp học này (chỉ dành cho học viên của lớp).")

        student_id = student.id

    targets = ClassService.get_transfer_targets(db, class_id, student_id=student_id)
    return ApiResponse(data=targets, message="Danh sách các lớp học hợp lệ để chuyển lớp")

@router.post("/transfer", response_model=ApiResponse[dict], summary="Thực hiện chuyển lớp cho học viên")
def transfer_class(
    data: ClassTransferRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF, RoleEnum.STUDENT]))
):
    user_id = int(payload["sub"])
    role = payload.get("role")
    student_id = data.student_id

    if role == RoleEnum.STUDENT.value:
        from app.modules.students.models import Student
        student = db.query(Student).filter(Student.user_id == user_id, Student.is_deleted == False).first()
        if not student:
            raise HTTPException(status_code=404, detail="Không tìm thấy hồ sơ học viên")
        student_id = student.id
    elif not student_id:
        raise HTTPException(status_code=400, detail="Vui lòng chỉ định student_id để chuyển lớp")

    res = ClassService.transfer_class(
        db=db,
        current_class_id=data.current_class_id,
        target_class_id=data.target_class_id,
        student_id=student_id,
        reason=data.reason
    )
    return ApiResponse(data=res, message="Chuyển lớp học thành công")

