from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException
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

@router.post("/", response_model=ApiResponse[TicketDetailResponse], summary="Tạo mới Đơn khiếu nại / Đơn yêu cầu")
def create_ticket(
    data: TicketCreate,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    sender_id = int(payload["sub"])
    ticket = TicketService.create_ticket(db, sender_id, data)
    return ApiResponse(data=ticket, message="Tạo đơn thành công")

@router.get("/sent", response_model=ApiResponse[List[TicketResponse]], summary="Danh sách đơn đã gửi của người dùng")
def list_sent_tickets(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    tickets = TicketService.list_sent_tickets(db, user_id)
    return ApiResponse(data=tickets, message="Danh sách đơn đã gửi")

@router.get("/inbox", response_model=ApiResponse[List[TicketResponse]], summary="Hộp thư đến: danh sách đơn nhận được")
def list_inbox_tickets(
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    tickets = TicketService.list_inbox_tickets(db, user_id, user_role)
    return ApiResponse(data=tickets, message="Hộp thư đến danh sách đơn")

@router.get("/check-deadline/{class_id}", response_model=ApiResponse[dict], summary="Kiểm tra thời hạn gửi khiếu nại cho một lớp học")
def check_complaint_deadline(
    class_id: int,
    db: Session = Depends(get_db),
    _ = Depends(get_current_user_payload)
):
    result = TicketService.check_complaint_deadline(db, class_id)
    return ApiResponse(data=result, message="Thông tin thời hạn khiếu nại")

@router.get("/{ticket_id}", response_model=ApiResponse[TicketDetailResponse], summary="Xem chi tiết đơn và lịch sử trao đổi")
def get_ticket_detail(
    ticket_id: int,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    ticket = TicketService.get_ticket_detail(db, ticket_id, user_id, user_role)
    return ApiResponse(data=ticket, message="Chi tiết đơn khiếu nại / yêu cầu")

@router.post("/{ticket_id}/messages", response_model=ApiResponse[TicketMessageResponse], summary="Gửi phản hồi / trao đổi trong đơn")
def add_ticket_message(
    ticket_id: int,
    data: TicketMessageCreate,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    sender_id = int(payload["sub"])
    sender_role = payload.get("role", "")
    msg = TicketService.add_message(db, ticket_id, sender_id, sender_role, data)
    return ApiResponse(data=msg, message="Gửi phản hồi thành công")

@router.patch("/{ticket_id}/status", response_model=ApiResponse[TicketDetailResponse], summary="Cập nhật trạng thái xử lý đơn")
def update_ticket_status(
    ticket_id: int,
    data: TicketStatusUpdate,
    payload: dict = Depends(get_current_user_payload),
    db: Session = Depends(get_db)
):
    user_id = int(payload["sub"])
    user_role = payload.get("role", "")
    ticket = TicketService.update_status(db, ticket_id, user_id, user_role, data)
    return ApiResponse(data=ticket, message="Cập nhật trạng thái đơn thành công")
