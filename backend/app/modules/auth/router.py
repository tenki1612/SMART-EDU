from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import get_current_user_payload
from app.common.response import ApiResponse
from app.modules.accounts.models import User
from app.modules.auth.schemas import (
    LoginRequest, TokenResponse, UserInfoResponse,
    ForgotPasswordRequest, ForgotPasswordResponse,
    ResetPasswordRequest, ResetPasswordResponse
)
from app.modules.auth.service import AuthService

router = APIRouter()

@router.post("/login", response_model=ApiResponse[TokenResponse], summary="FR-01: Đăng nhập")
def login(creds: LoginRequest, db: Session = Depends(get_db)):
    result = AuthService.authenticate_user(db, creds)
    return ApiResponse(data=result, message="Đăng nhập thành công")

@router.post("/logout", response_model=ApiResponse[dict], summary="FR-02: Đăng xuất")
def logout(payload: dict = Depends(get_current_user_payload)):
    return ApiResponse(data={"logged_out": True}, message="Đăng xuất khỏi hệ thống thành công")

@router.get("/me", response_model=ApiResponse[UserInfoResponse], summary="FR-04: Lấy thông tin phiên đăng nhập & quyền")
def get_me(payload: dict = Depends(get_current_user_payload), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == int(payload["sub"])).first()
    return ApiResponse(data=user, message="Lấy thông tin người dùng thành công")

@router.get("/roles-permissions", response_model=ApiResponse[list], summary="FR-03: Danh mục vai trò và ma trận phân quyền")
def get_roles_permissions(payload: dict = Depends(get_current_user_payload)):
    matrix = [
        {"role": "ADMIN", "description": "Toàn quyền quản trị hệ thống, tài khoản, khóa học, phòng học, lớp học"},
        {"role": "ACADEMIC_STAFF", "description": "Quản lý tuyển sinh, duyệt đăng ký, sắp xếp thời khóa biểu, xác nhận điểm, xét duyệt học tiếp"},
        {"role": "TEACHER", "description": "Xem lịch dạy, xem danh sách lớp, nhập và cập nhật điểm số học viên"},
        {"role": "STUDENT", "description": "Xem khóa học, đăng ký lớp, xem thời khóa biểu cá nhân, tra cứu điểm và kết quả"},
        {"role": "PARENT", "description": "Xem thông tin học viên được giám hộ, theo dõi thời khóa biểu và kết quả học tập của con"}
    ]
    return ApiResponse(data=matrix, message="Danh sách phân quyền theo vai trò")

@router.post("/forgot-password", response_model=ApiResponse[ForgotPasswordResponse], summary="Yêu cầu mã khôi phục mật khẩu OTP")
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    res = AuthService.forgot_password(db, req)
    return ApiResponse(data=res, message=res.message)

@router.post("/reset-password", response_model=ApiResponse[ResetPasswordResponse], summary="Đặt lại mật khẩu với mã OTP")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    res = AuthService.reset_password(db, req)
    return ApiResponse(data=res, message=res.message)
