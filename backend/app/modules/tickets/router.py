from typing import List, Optional, Any
from fastapi import APIRouter, Depends, Query, HTTPException, Path
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.permissions import require_roles, RoleEnum, get_current_user_payload
from app.common.response import ApiResponse
from app.modules.tickets.schemas import (
    TicketCreate, TicketMessageCreate, TicketStatusUpdate,
    TicketResponse, TicketDetailResponse, TicketMessageResponse
)
from app.modules.tickets.service import TicketService

router = APIRouter()

MAX_INT64 = 9223372036854775807

@router.post("/", response_model=ApiResponse[TicketDetailResponse], summary="Tạo mới Đơn khiếu nại / Đơn yêu cầu")
def create_ticket(
    data: TicketCreate,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    sender_id = int(payload["sub"])
    sender_role = payload.get("role", "")
    ticket = TicketService.create_ticket(db, sender_id, sender_role, data)
    return ApiResponse(data=ticket, message="Tạo đơn thành công")

@router.get("/sent", response_model=ApiResponse[Any], summary="Danh sách đơn đã gửi của người dùng")
def list_sent_tickets(
    page: Optional[int] = Query(None, ge=1, description="Số trang (bắt đầu từ 1)"),
    limit: Optional[int] = Query(None, ge=1, le=100, description="Số bản ghi mỗi trang"),
    q: Optional[str] = Query(None, description="Từ khóa tìm kiếm (mã đơn, tiêu đề, nội dung)"),
    category: Optional[str] = Query(None, description="Lọc theo lĩnh vực"),
    status: Optional[str] = Query(None, description="Lọc theo trạng thái"),
    ticket_type: Optional[str] = Query(None, description="Lọc theo loại đơn: COMPLAINT hoặc REQUEST"),
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    result = TicketService.list_sent_tickets(
        db, sender_id=user_id, user_role=user_role,
        page=page, limit=limit, q=q,
        category=category, status=status, ticket_type=ticket_type
    )
    return ApiResponse(data=result, message="Danh sách đơn đã gửi")

@router.get("/inbox", response_model=ApiResponse[Any], summary="Hộp thư đến: danh sách đơn nhận được")
def list_inbox_tickets(
    page: Optional[int] = Query(None, ge=1, description="Số trang (bắt đầu từ 1)"),
    limit: Optional[int] = Query(None, ge=1, le=100, description="Số bản ghi mỗi trang"),
    q: Optional[str] = Query(None, description="Từ khóa tìm kiếm (mã đơn, tiêu đề, nội dung)"),
    category: Optional[str] = Query(None, description="Lọc theo lĩnh vực"),
    status: Optional[str] = Query(None, description="Lọc theo trạng thái"),
    ticket_type: Optional[str] = Query(None, description="Lọc theo loại đơn: COMPLAINT hoặc REQUEST"),
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    result = TicketService.list_inbox_tickets(
        db, user_id=user_id, user_role=user_role,
        page=page, limit=limit, q=q,
        category=category, status=status, ticket_type=ticket_type
    )
    return ApiResponse(data=result, message="Hộp thư đến danh sách đơn")

@router.get("/check-deadline/{class_id}", response_model=ApiResponse[dict], summary="Kiểm tra thời hạn gửi khiếu nại cho một lớp học")
def check_complaint_deadline(
    class_id: int = Path(..., ge=1, le=MAX_INT64, description="ID lớp học hợp lệ (int64)"),
    db: Session = Depends(get_db),
    _ = Depends(get_current_user_payload)
):
    result = TicketService.check_complaint_deadline(db, class_id)
    return ApiResponse(data=result, message="Thông tin thời hạn khiếu nại")

@router.get("/stats", response_model=ApiResponse[dict], summary="Thống kê tổng hợp số lượng đơn theo vai trò và trạng thái (N-02, N-03)")
def get_ticket_stats(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    stats = TicketService.get_stats(db, user_id=user_id, user_role=user_role)
    return ApiResponse(data=stats, message="Thống kê đơn khiếu nại và yêu cầu")

@router.get("/{ticket_id}", response_model=ApiResponse[TicketDetailResponse], summary="Xem chi tiết đơn và lịch sử trao đổi")
def get_ticket_detail(
    ticket_id: int = Path(..., ge=1, le=MAX_INT64, description="ID đơn khiếu nại / yêu cầu hợp lệ (int64)"),
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    ticket = TicketService.get_ticket_detail(db, ticket_id, user_id, user_role)
    return ApiResponse(data=ticket, message="Chi tiết đơn khiếu nại / yêu cầu")

@router.post("/{ticket_id}/messages", response_model=ApiResponse[TicketMessageResponse], summary="Gửi phản hồi / trao đổi trong đơn")
def add_ticket_message(
    ticket_id: int = Path(..., ge=1, le=MAX_INT64, description="ID đơn khiếu nại / yêu cầu hợp lệ (int64)"),
    data: TicketMessageCreate = ...,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    sender_id = int(payload["sub"])
    sender_role = payload.get("role", "")
    msg = TicketService.add_message(db, ticket_id, sender_id, sender_role, data)
    return ApiResponse(data=msg, message="Gửi phản hồi thành công")

@router.patch("/{ticket_id}/status", response_model=ApiResponse[Any], summary="Cập nhật trạng thái xử lý đơn")
def update_ticket_status(
    ticket_id: int = Path(..., ge=1, le=MAX_INT64, description="ID đơn khiếu nại / yêu cầu hợp lệ (int64)"),
    data: TicketStatusUpdate = ...,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    ticket = TicketService.update_status(db, ticket_id, user_id, user_role, data)
    return ApiResponse(data=ticket, message="Cập nhật trạng thái đơn thành công")
