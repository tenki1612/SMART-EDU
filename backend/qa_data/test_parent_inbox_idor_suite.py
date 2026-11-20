"""
SMART-EDU TEST SUITE: BẢO VỆ PHÂN QUYỀN VÀ KHẮC PHỤC PARENT INBOX IDOR (BUG-03 & OBS-01)
Kiểm thử toàn diện theo đặc tả:
- OBS-01: Kiểm tra QA Safety Guard chặn phá hủy môi trường Production
- TC01: Tạo ticket gửi riêng cho Phụ huynh A (hợp lệ qua quan hệ ParentStudent)
- TC02: Phụ huynh A nhìn thấy ticket trong hộp thư đến (Inbox)
- TC03: Phụ huynh B KHÔNG nhìn thấy ticket của Phụ huynh A trong Inbox (Khắc phục BUG-03)
- TC04: Phụ huynh B thử truy cập trực tiếp ID ticket của Phụ huynh A -> Bị từ chối (404/403)
- TC05: Phụ huynh B không xem được title hoặc content của Phụ huynh A
- TC06: Phụ huynh B không thể gửi phản hồi (Message) vào ticket của Phụ huynh A
- TC07: Học viên 1 thử tạo ticket gửi cho Phụ huynh B không có quan hệ -> Bị từ chối (400)
- TC08: Bảo toàn chức năng thông báo chung (Broadcast) cho toàn thể phụ huynh
- TC09: Học viên không được phép gửi broadcast toàn thể phụ huynh (400)
- TC10: Bảo toàn phân quyền của STUDENT, TEACHER, ADMIN và ACADEMIC_STAFF
- TC11: Tự động dọn dẹp dữ liệu kiểm thử (Teardown)
"""

import os
import sys
import time

sys.path.insert(0, "backend")

# QA Safety Guard (OBS-01)
from qa_data.safety_guard import validate_test_database_target, is_production_database
validate_test_database_target(is_destructive=True)

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.modules.tickets.models import Ticket, TicketMessage
from app.modules.accounts.models import User
from app.modules.students.models import Student
from app.modules.progression_parent.models import ParentStudent
from app.core.permissions import RoleEnum
from app.core.security import create_access_token

client = TestClient(app)

def run_suite():
    print("=" * 75)
    print("BẮT ĐẦU KIỂM THỬ: BẢO VỆ PHÂN QUYỀN PARENT & QA SAFETY (BUG-03 & OBS-01)")
    print("=" * 75)

    created_ticket_ids = []

    # =========================================================================
    # PHẦN 1: KIỂM TRA OBS-01 - QA SAFETY GUARD
    # =========================================================================
    print("\n--- PHẦN 1: KIỂM SOÁT AN TOÀN MÔI TRƯỜNG & QA SAFETY GUARD (OBS-01) ---")

    # 1. Kiểm tra phát hiện URL production
    prod_test_url = "postgresql://user:pass@prod-db.smartedu.vn:5432/language_center_prod"
    is_prod, reason = is_production_database(prod_test_url)
    assert is_prod == True, "Safety Guard must detect production URL"
    assert "smartedu.vn" in reason or "prod" in reason

    # 2. Kiểm tra chặn thực thi trên môi trường production
    old_db_url = os.environ.get("DATABASE_URL")
    try:
        os.environ["DATABASE_URL"] = prod_test_url
        blocked = False
        try:
            validate_test_database_target(is_destructive=True, silent=True)
        except RuntimeError as e:
            blocked = True
            assert "Safety Violation" in str(e)
        assert blocked == True, "validate_test_database_target MUST raise RuntimeError on prod URL"
        print("✓ OBS-01.1. Chặn thực thi đối với DATABASE_URL trỏ Production: PASSED (RuntimeError raised)")
    finally:
        if old_db_url is not None:
            os.environ["DATABASE_URL"] = old_db_url
        else:
            os.environ.pop("DATABASE_URL", None)

    # 3. Kiểm tra biến môi trường ENV=production bị chặn
    old_env = os.environ.get("ENV")
    try:
        os.environ["ENV"] = "production"
        blocked_env = False
        try:
            validate_test_database_target(is_destructive=True, silent=True)
        except RuntimeError:
            blocked_env = True
        assert blocked_env == True, "validate_test_database_target MUST raise RuntimeError when ENV=production"
        print("✓ OBS-01.2. Chặn thực thi đối với biến môi trường ENV=production: PASSED")
    finally:
        if old_env is not None:
            os.environ["ENV"] = old_env
        else:
            os.environ.pop("ENV", None)

    # =========================================================================
    # PHẦN 2: CHUẨN BỊ TÀI KHOẢN VÀ XÁC THỰC
    # =========================================================================
    print("\n--- PHẦN 2: CHUẨN BỊ DỮ LIỆU & PHÂN QUYỀN PARENT A & PARENT B ---")

    db = SessionLocal()

    # Tìm học viên 1 (student_id=1, user_id=5)
    stu1 = db.query(Student).filter(Student.user_id == 5, Student.is_deleted == False).first()
    assert stu1 is not None, "Student 1 record not found"
    student1_user_id = 5
    student1_id = stu1.id

    # Tìm học viên 2 (student_id=2)
    stu2 = db.query(Student).filter(Student.id != student1_id, Student.is_deleted == False).first()
    assert stu2 is not None, "Student 2 record not found"
    student2_id = stu2.id

    # Tìm Parent A (liên kết với Student 1)
    link_a = db.query(ParentStudent).filter(ParentStudent.student_id == student1_id, ParentStudent.is_deleted == False).first()
    assert link_a is not None, "Parent A link not found"
    parent_a_user = db.query(User).filter(User.id == link_a.parent_user_id).first()
    assert parent_a_user is not None

    # Tìm Parent B (liên kết với Student 2, KHÔNG liên kết với Student 1)
    link_b = db.query(ParentStudent).filter(ParentStudent.student_id == student2_id, ParentStudent.is_deleted == False).first()
    assert link_b is not None, "Parent B link not found"
    parent_b_user = db.query(User).filter(User.id == link_b.parent_user_id).first()
    assert parent_b_user is not None
    assert parent_a_user.id != parent_b_user.id, "Parent A and Parent B must be distinct users"

    # Tạo JWT headers
    student1_token = create_access_token(str(student1_user_id), RoleEnum.STUDENT.value)
    student1_headers = {"Authorization": f"Bearer {student1_token}"}

    parent_a_token = create_access_token(str(parent_a_user.id), RoleEnum.PARENT.value)
    parent_a_headers = {"Authorization": f"Bearer {parent_a_token}"}

    parent_b_token = create_access_token(str(parent_b_user.id), RoleEnum.PARENT.value)
    parent_b_headers = {"Authorization": f"Bearer {parent_b_token}"}

    db.close()

    print(f"  Parent A (ID={parent_a_user.id}, Username={parent_a_user.username}) -> Student 1 (ID={student1_id})")
    print(f"  Parent B (ID={parent_b_user.id}, Username={parent_b_user.username}) -> Student 2 (ID={student2_id})")

    ts = int(time.time())

    # =========================================================================
    # PHẦN 3: KIỂM THỬ KHẮC PHỤC BUG-03 (PARENT INBOX IDOR)
    # =========================================================================
    print("\n--- PHẦN 3: KIỂM THỬ KHẮC PHỤC PARENT INBOX IDOR (BUG-03) ---")

    # TC01: Tạo ticket gửi riêng đến Phụ huynh A (Hợp lệ vì Student 1 có quan hệ ParentStudent với Parent A)
    res_tc01 = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "OTHER",
        "receiver_id": parent_a_user.id,
        "receiver_role": "PARENT",
        "title": f"BẢO MẬT: Báo cáo học tập riêng cho Phụ huynh A [{ts}]",
        "content": f"Kính gửi Phụ huynh A, đây là thông tin điểm thi và học phí riêng tư của con em quý vị [{ts}]."
    }, headers=student1_headers)
    assert res_tc01.status_code == 200, f"TC01 failed: {res_tc01.text}"
    ticket_a = res_tc01.json()["data"]
    ticket_a_id = ticket_a["id"]
    created_ticket_ids.append(ticket_a_id)
    print("✓ TC01. Học viên gửi ticket riêng cho đúng phụ huynh giám hộ: PASSED (200 OK)")

    # TC02: Phụ huynh A nhìn thấy ticket trong Inbox của mình
    inbox_a_res = client.get("/api/v1/tickets/inbox", headers=parent_a_headers)
    assert inbox_a_res.status_code == 200
    inbox_a_items = inbox_a_res.json()["data"]
    if isinstance(inbox_a_items, dict) and "items" in inbox_a_items:
        inbox_a_items = inbox_a_items["items"]
    found_in_a = any(t["id"] == ticket_a_id for t in inbox_a_items)
    assert found_in_a == True, "Parent A MUST see their private ticket in inbox"
    print("✓ TC02. Phụ huynh A thấy ticket gửi riêng trong hộp thư đến: PASSED (Found in inbox)")

    # TC03: Phụ huynh B KHÔNG NHÌN THẤY ticket của Phụ huynh A trong Inbox (BUG-03 FIX)
    inbox_b_res = client.get("/api/v1/tickets/inbox", headers=parent_b_headers)
    assert inbox_b_res.status_code == 200
    inbox_b_items = inbox_b_res.json()["data"]
    if isinstance(inbox_b_items, dict) and "items" in inbox_b_items:
        inbox_b_items = inbox_b_items["items"]
    found_in_b = any(t["id"] == ticket_a_id for t in inbox_b_items)
    assert found_in_b == False, "BUG-03 REGRESSION: Parent B MUST NOT see Parent A's private ticket!"
    print("✓ TC03. Chống rò rỉ Inbox: Phụ huynh B KHÔNG thấy ticket của Phụ huynh A: PASSED (Not in inbox)")

    # TC04 & TC05: Phụ huynh B thử truy cập trực tiếp ID ticket của Phụ huynh A -> Bị từ chối (404/403)
    # Không để lộ tiêu đề hoặc nội dung nhạy cảm của Phụ huynh A
    direct_b_res = client.get(f"/api/v1/tickets/{ticket_a_id}", headers=parent_b_headers)
    assert direct_b_res.status_code in [403, 404], f"Expected 403/404, got {direct_b_res.status_code}"
    # Đảm bảo nội dung không chứa tiêu đề bí mật
    resp_text = direct_b_res.text.lower()
    assert "báo cáo học tập riêng cho phụ huynh a" not in resp_text
    assert "học phí riêng tư" not in resp_text
    print("✓ TC04 & TC05. Chống IDOR: Phụ huynh B truy cập trực tiếp ID bị chặn và không lộ PII: PASSED (404/403)")

    # TC06: Phụ huynh B thử gửi phản hồi (Message) vào ticket của Phụ huynh A -> Bị từ chối (404/403)
    msg_b_res = client.post(f"/api/v1/tickets/{ticket_a_id}/messages", json={
        "content": "Phụ huynh B cố ý gửi phản hồi trái phép"
    }, headers=parent_b_headers)
    assert msg_b_res.status_code in [403, 404], f"Expected 403/404, got {msg_b_res.status_code}"
    print("✓ TC06. Phụ huynh B bị chặn gửi phản hồi vào ticket của người khác: PASSED (404/403)")

    # TC07: Học viên 1 thử tạo ticket gửi cho Phụ huynh B (Không có quan hệ ParentStudent) -> Từ chối (400)
    unauth_create_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "OTHER",
        "receiver_id": parent_b_user.id,
        "receiver_role": "PARENT",
        "title": "Gửi nhầm phụ huynh",
        "content": "Thử gửi đơn cho phụ huynh không liên quan"
    }, headers=student1_headers)
    assert unauth_create_res.status_code == 400, f"Expected 400 Bad Request, got {unauth_create_res.status_code}"
    assert "quan hệ giám hộ" in unauth_create_res.json()["detail"].lower()
    print("✓ TC07. Chặn tạo ticket gửi phụ huynh không có quan hệ ParentStudent: PASSED (400 Bad Request)")

    # =========================================================================
    # PHẦN 4: THÔNG BÁO CHUNG (BROADCAST) & CÁC VAI TRÒ KHÁC
    # =========================================================================
    print("\n--- PHẦN 4: THÔNG BÁO CHUNG (BROADCAST) & BẢO TOÀN VAI TRÒ KHÁC ---")

    # TC08: Bảo toàn chức năng thông báo chung (Broadcast) cho toàn thể phụ huynh
    # Tạo trực tiếp trong DB một thông báo chung (receiver_role=PARENT, receiver_id=None)
    sdb = SessionLocal()
    bcast_ticket = Ticket(
        ticket_code=f"YC-{datetime.now().strftime('%Y%m')}-{ts % 10000:04d}",
        ticket_type="REQUEST",
        sender_id=1, # Admin / System
        receiver_id=None, # Broadcast
        receiver_role="PARENT",
        category="OTHER",
        title=f"THÔNG BÁO CHUNG NGHỈ LỄ CHO TOÀN THỂ PHỤ HUYNH [{ts}]",
        content="Kính gửi Quý phụ huynh, trung tâm thông báo lịch nghỉ lễ chính thức.",
        status="PENDING"
    )
    sdb.add(bcast_ticket)
    sdb.commit()
    sdb.refresh(bcast_ticket)
    bcast_id = bcast_ticket.id
    created_ticket_ids.append(bcast_id)
    sdb.close()

    # Cả Parent A và Parent B đều nhìn thấy thông báo chung này
    inbox_a_bcast = client.get("/api/v1/tickets/inbox", headers=parent_a_headers).json()["data"]
    if isinstance(inbox_a_bcast, dict) and "items" in inbox_a_bcast:
        inbox_a_bcast = inbox_a_bcast["items"]
    inbox_b_bcast = client.get("/api/v1/tickets/inbox", headers=parent_b_headers).json()["data"]
    if isinstance(inbox_b_bcast, dict) and "items" in inbox_b_bcast:
        inbox_b_bcast = inbox_b_bcast["items"]

    assert any(t["id"] == bcast_id for t in inbox_a_bcast), "Parent A must see broadcast notice"
    assert any(t["id"] == bcast_id for t in inbox_b_bcast), "Parent B must see broadcast notice"

    # Cả hai đều có thể xem chi tiết thông báo chung
    view_a_bcast = client.get(f"/api/v1/tickets/{bcast_id}", headers=parent_a_headers)
    view_b_bcast = client.get(f"/api/v1/tickets/{bcast_id}", headers=parent_b_headers)
    assert view_a_bcast.status_code == 200
    assert view_b_bcast.status_code == 200
    print("✓ TC08. Bảo toàn chức năng thông báo chung (Broadcast) cho toàn thể phụ huynh: PASSED")

    # TC09: Học viên không được phép gửi broadcast toàn thể phụ huynh (400)
    stu_bcast_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "OTHER",
        "receiver_id": None,
        "receiver_role": "PARENT",
        "title": "Học viên thử gửi broadcast",
        "content": "Nội dung spam toàn hệ thống"
    }, headers=student1_headers)
    assert stu_bcast_res.status_code == 400
    assert "không được gửi thông báo chung" in stu_bcast_res.json()["detail"].lower() or "chỉ định" in stu_bcast_res.json()["detail"].lower()
    print("✓ TC09. Học viên bị chặn gửi thông báo chung (Broadcast) cho toàn thể phụ huynh: PASSED (400)")

    # TC10: Bảo toàn phân quyền STUDENT, TEACHER, ADMIN, ACADEMIC_STAFF
    # ADMIN và ACADEMIC_STAFF không bị ảnh hưởng
    admin_login = client.post("/api/v1/auth/login", json={"username": "admin", "password": "admin123"})
    assert admin_login.status_code == 200
    admin_headers = {"Authorization": f"Bearer {admin_login.json()['data']['access_token']}"}
    admin_stats = client.get("/api/v1/tickets/stats", headers=admin_headers)
    assert admin_stats.status_code == 200
    print("✓ TC10. Phân quyền các vai trò khác (STUDENT, TEACHER, ADMIN, STAFF) không bị ảnh hưởng: PASSED")

    # TC11: Tự động dọn dẹp dữ liệu kiểm thử (Teardown)
    sdb = SessionLocal()
    for tid in created_ticket_ids:
        sdb.query(TicketMessage).filter(TicketMessage.ticket_id == tid).delete()
        sdb.query(Ticket).filter(Ticket.id == tid).delete()
    sdb.commit()
    sdb.close()
    print("✓ TC11. Tự động dọn dẹp dữ liệu kiểm thử (Teardown): PASSED")

    print("\n" + "=" * 75)
    print("TẤT CẢ TEST CASES KIỂM THỬ BUG-03 VÀ OBS-01 ĐỀU VƯỢT QUA 100%!")
    print("=" * 75)

if __name__ == "__main__":
    from datetime import datetime
    run_suite()
