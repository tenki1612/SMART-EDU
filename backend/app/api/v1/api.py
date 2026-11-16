from fastapi import APIRouter
from app.modules.auth.router import router as auth_router
from app.modules.accounts.router import router as accounts_router
from app.modules.courses.router import router as courses_router
from app.modules.students.router import router as students_router
from app.modules.teachers.router import router as teachers_router
from app.modules.classes.router import router as classes_router
from app.modules.classrooms.router import router as classrooms_router
from app.modules.enrollments.router import router as enrollments_router
from app.modules.schedules.router import router as schedules_router
from app.modules.grades.router import router as grades_router
from app.modules.progression_parent.router import router as progression_router

api_router = APIRouter()

# 11 Modular Bounded Contexts
api_router.include_router(auth_router, prefix="/auth", tags=["01. Đăng nhập & Phân quyền (FR-01 -> FR-04)"])
api_router.include_router(accounts_router, prefix="/accounts", tags=["02. Quản lý tài khoản (FR-05 -> FR-10)"])
api_router.include_router(courses_router, prefix="/courses", tags=["03. Quản lý khóa học (FR-11 -> FR-17)"])
api_router.include_router(students_router, prefix="/students", tags=["04. Quản lý học viên (FR-18 -> FR-24)"])
api_router.include_router(teachers_router, prefix="/teachers", tags=["05. Quản lý giáo viên (FR-25 -> FR-31)"])
api_router.include_router(classes_router, prefix="/classes", tags=["06. Quản lý lớp học (FR-32 -> FR-41)"])
api_router.include_router(classrooms_router, prefix="/classrooms", tags=["07. Quản lý phòng học (FR-42 -> FR-49)"])
api_router.include_router(enrollments_router, prefix="/enrollments", tags=["08. Đăng ký & Xét duyệt lớp (FR-50 -> FR-60)"])
api_router.include_router(schedules_router, prefix="/schedules", tags=["09. Quản lý thời khóa biểu (FR-61 -> FR-68)"])
api_router.include_router(grades_router, prefix="/grades", tags=["10. Quản lý điểm & Kết quả (FR-69 -> FR-77)"])
api_router.include_router(progression_router, prefix="/progression", tags=["11. Chuyển khóa & Phụ huynh (FR-78 -> FR-82)"])

