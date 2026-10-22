from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.accounts.schemas import (
    UserCreate, UserUpdate, UserResponse, ChangePasswordRequest, 
    RoleUpdateRequest, AdminResetPasswordRequest
)
from app.modules.accounts.service import AccountService

router = APIRouter()

@router.post("/", response_model=ApiResponse[UserResponse], summary="FR-05: Thêm tài khoản")
def create_account(
    data: UserCreate, 
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    user = AccountService.create_user(db, data)
    return ApiResponse(data=user, message="Tạo tài khoản thành công")

@router.post("/change-password", response_model=ApiResponse[bool], summary="FR-06: Đổi mật khẩu")
def change_password(
    data: ChangePasswordRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    AccountService.change_password(db, user_id, data)
    return ApiResponse(data=True, message="Đổi mật khẩu thành công")

@router.put("/{user_id}", response_model=ApiResponse[UserResponse], summary="FR-07: Cập nhật tài khoản")
def update_account(
    user_id: int,
    data: UserUpdate,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    user = AccountService.update_user(db, user_id, data)
    return ApiResponse(data=user, message="Cập nhật tài khoản thành công")

@router.patch("/{user_id}/role", response_model=ApiResponse[UserResponse], summary="Quản trị viên nâng quyền / đổi vai trò tài khoản")
def update_user_role(
    user_id: int,
    data: RoleUpdateRequest,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    current_admin_id = int(payload["sub"])
    user = AccountService.update_user_role(db, user_id, data.role, current_admin_id)
    return ApiResponse(data=user, message=f"Đã nâng/đổi quyền tài khoản thành công sang '{data.role.value}'")

@router.patch("/{user_id}/toggle-lock", response_model=ApiResponse[UserResponse], summary="Quản trị viên khóa hoặc mở khóa tài khoản")
def toggle_user_lock(
    user_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    current_admin_id = int(payload["sub"])
    user, msg = AccountService.toggle_user_lock(db, user_id, current_admin_id)
    return ApiResponse(data=user, message=msg)

@router.post("/{user_id}/reset-password", response_model=ApiResponse[bool], summary="Quản trị viên đặt lại mật khẩu cho tài khoản")
def admin_reset_password(
    user_id: int,
    data: AdminResetPasswordRequest,
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN]))
):
    AccountService.admin_reset_password(db, user_id, data.new_password)
    return ApiResponse(data=True, message="Đã đặt lại mật khẩu tài khoản thành công")

@router.get("/me", response_model=ApiResponse[UserResponse], summary="FR-08: Xem thông tin tài khoản cá nhân")
def get_my_account(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    from app.modules.accounts.models import User
    user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    return ApiResponse(data=user, message="Thông tin tài khoản")

@router.get("/", response_model=ApiResponse[List[UserResponse]], summary="FR-09: Tìm kiếm & xem danh sách tài khoản")
def search_accounts(
    q: Optional[str] = Query(None, description="Tìm kiếm theo tên, username, email"),
    role: Optional[str] = Query(None, description="Lọc theo role"),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    users = AccountService.search_users(db, query=q, role=role)
    return ApiResponse(data=users, message="Danh sách tài khoản")

@router.delete("/{user_id}", response_model=ApiResponse[bool], summary="FR-10: Xóa tài khoản")
def delete_account(
    user_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db),
    _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
):
    current_user_id = int(payload["sub"])
    AccountService.delete_user(db, user_id, current_user_id=current_user_id)
    return ApiResponse(data=True, message="Xóa tài khoản thành công")
