"""
SMART-EDU TEST SUITE: KIỂM THỬ TOÀN DIỆN VÀ KHẮC PHỤC LỖI PHÂN HỆ ĐƠN TỪ / KHIẾU NẠI (F-01 ĐẾN F-11)
Quy tắc an toàn tuyệt đối:
- Tạo bản sao temp_test_audit.db từ language_center.db.
- Sử dụng app.dependency_overrides để trỏ toàn bộ test vào database tạm.
- Không sửa đổi hoặc phá hủy database gốc language_center.db.
- Dọn dẹp temp_test_audit.db khi hoàn thành.
"""

import os
import sys
import shutil
from datetime import datetime, date, timedelta, timezone
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

# Setup path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

ORIGINAL_DB = os.path.abspath("backend/language_center.db")
TEMP_DB = os.path.abspath("backend/temp_test_audit.db")

# 1. Tạo bản sao DB tạm
if os.path.exists(TEMP_DB):
    os.remove(TEMP_DB)
shutil.copyfile(ORIGINAL_DB, TEMP_DB)

# 2. Setup engine và Session cho DB tạm
temp_engine = create_engine(f"sqlite:///{TEMP_DB}", connect_args={"check_same_thread": False})
TempSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=temp_engine)

from app.main import app
from app.core.database import get_db
from app.modules.accounts.models import User
from app.modules.classes.models import Class, ClassStudent
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student
from app.modules.grades.models import GradeRecord, GradeLockHistory
from app.modules.tickets.models import Ticket, TicketMessage
from app.modules.tickets.service import TicketService
from app.modules.grades.service import GradeService

def override_get_db():
    db = TempSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

def run_audit_suite():
    print("==================================================================")
    print("🛡️ BẮT ĐẦU KIỂM THỬ TOÀN DIỆN VÀ VERIFY CÁC FIX F-01 ĐẾN F-11")
    print("==================================================================\n")

    db = TempSessionLocal()
    passed_cases = 0
    total_cases = 0

    def assert_test(cond, msg):
        nonlocal passed_cases, total_cases
        total_cases += 1
        if cond:
            passed_cases += 1
            print(f"   ✅ [PASS] {msg}")
        else:
            print(f"   ❌ [FAIL] {msg}")
            assert False, msg

    try:
        # Lấy token xác thực cho từng vai trò
        roles_to_login = [
            ("ADMIN", "admin", "admin123"),
            ("ACADEMIC_STAFF", "staff", "staff123"),
            ("TEACHER", "teacher", "teacher123"),
            ("STUDENT", "student", "student123"),
        ]
        tokens = {}
        users = {}
        for role, username, password in roles_to_login:
            res = client.post("/api/v1/auth/login", json={"username": username, "password": password})
            assert res.status_code == 200, f"Không thể đăng nhập {username}: {res.text}"
            tokens[role] = res.json()["data"]["access_token"]
            users[role] = db.query(User).filter(User.username == username).first()

        teacher_user = users["TEACHER"]
        teacher_rec = db.query(Teacher).filter(Teacher.user_id == teacher_user.id).first()
        student_user = users["STUDENT"]
        student_rec = db.query(Student).filter(Student.user_id == student_user.id).first()

        # Tìm 1 lớp do teacher phụ trách mà student có theo học
        enrolled_class = (
            db.query(Class)
            .join(ClassStudent, ClassStudent.class_id == Class.id)
            .filter(
                Class.teacher_id == teacher_rec.id,
                ClassStudent.student_id == student_rec.id,
                Class.is_deleted == False,
                ClassStudent.is_deleted == False
            )
            .first()
        )
        assert enrolled_class is not None, "Cần ít nhất 1 lớp có quan hệ giữa teacher và student"

        # Tìm 1 lớp do giảng viên KHÁC phụ trách
        other_teacher_class = (
            db.query(Class)
            .filter(Class.teacher_id != teacher_rec.id, Class.is_deleted == False)
            .first()
        )
        assert other_teacher_class is not None, "Cần ít nhất 1 lớp do giảng viên khác phụ trách"

        print("\n--- NHÓM 1: BYPASS KHIẾU NẠI & KIỂM TRA ĐẦU VÀO (F-01, F-03) ---")
        
        # 1.1: STUDENT tạo REQUEST với category GRADE
        res_1_1 = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "GRADE",
            "title": "Yêu cầu xem lại điểm thi giữa kỳ",
            "content": "Em muốn hỏi về bài thi giữa kỳ của em",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_1.status_code == 400, "1.1a: Chặn Student ngụy tạo khiếu nại điểm dưới dạng REQUEST + GRADE")

        # 1.1b: STUDENT tạo REQUEST với category GRADE_COMPLAINT
        res_1_1b = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "GRADE_COMPLAINT",
            "title": "Yêu cầu xem lại điểm thi giữa kỳ",
            "content": "Em muốn hỏi về bài thi giữa kỳ của em",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_1b.status_code == 400, "1.1b: Chặn Student ngụy tạo khiếu nại điểm dưới dạng REQUEST + GRADE_COMPLAINT")

        # 1.2: STUDENT gửi khiếu nại điểm trực tiếp đến ADMIN
        res_1_2 = client.post("/api/v1/tickets/", json={
            "ticket_type": "COMPLAINT",
            "category": "GRADE",
            "receiver_role": "ADMIN",
            "title": "Khiếu nại điểm thi gửi Admin",
            "content": "Em gửi đơn cho Admin xem điểm",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_2.status_code == 400, "1.2a: Chặn Student gửi khiếu nại điểm trực tiếp đến ADMIN")

        # 1.2b: STUDENT gửi khiếu nại điểm trực tiếp đến ACADEMIC_STAFF
        res_1_2b = client.post("/api/v1/tickets/", json={
            "ticket_type": "COMPLAINT",
            "category": "GRADE",
            "receiver_role": "ACADEMIC_STAFF",
            "title": "Khiếu nại điểm thi gửi Học vụ",
            "content": "Em gửi đơn cho Học vụ xem điểm",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_2b.status_code == 400, "1.2b: Chặn Student gửi khiếu nại điểm trực tiếp đến ACADEMIC_STAFF")

        # 1.3: STUDENT tạo đơn GRADE_UNLOCK
        res_1_3 = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "GRADE_UNLOCK",
            "title": "Mở khóa sổ điểm lớp học",
            "content": "Cho em xin mở khóa sổ điểm",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_3.status_code == 403, "1.3: Chặn Student tạo yêu cầu GRADE_UNLOCK (403 Forbidden)")

        # 1.4: STUDENT chọn category không hợp lệ cho học viên
        res_1_4 = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "INVALID_CAT",
            "title": "Tiêu đề kiểm thử hợp lệ",
            "content": "Nội dung kiểm thử hợp lệ"
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_4.status_code == 400, "1.4: Chặn Student chọn category ngoài VALID_STUDENT_CATEGORIES")

        # 1.5: STUDENT khiếu nại lớp mình không tham gia
        res_1_5 = client.post("/api/v1/tickets/", json={
            "ticket_type": "COMPLAINT",
            "category": "GRADE",
            "title": "Khiếu nại điểm lớp không học",
            "content": "Em muốn khiếu nại điểm lớp này",
            "related_class_id": other_teacher_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_5.status_code == 400, "1.5a: Chặn Student khiếu nại lớp học phần mình không tham gia")

        # 1.5b: STUDENT khiếu nại lớp đã quá thời hạn (quá hạn 7 ngày)
        original_end_date = enrolled_class.end_date
        enrolled_class.end_date = date.today() - timedelta(days=30)
        db.commit()

        res_1_5b = client.post("/api/v1/tickets/", json={
            "ticket_type": "COMPLAINT",
            "category": "GRADE",
            "title": "Khiếu nại điểm lớp quá hạn",
            "content": "Em muốn khiếu nại điểm lớp này dù đã hết hạn",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_5b.status_code == 400, "1.5b: Chặn Student khiếu nại lớp học phần đã quá thời hạn 7 ngày")

        # Khôi phục lại ngày kết thúc
        enrolled_class.end_date = original_end_date
        db.commit()

        # 1.6: STUDENT gửi khiếu nại điểm hợp lệ
        res_1_6 = client.post("/api/v1/tickets/", json={
            "ticket_type": "COMPLAINT",
            "category": "GRADE",
            "title": "Khiếu nại điểm thi cuối kỳ",
            "content": "Em thấy điểm thi cuối kỳ chưa chính xác, xin thầy xem lại.",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_1_6.status_code == 200, "1.6: Student gửi khiếu nại điểm hợp lệ thành công")
        valid_comp_id = res_1_6.json()["data"]["id"]
        valid_comp_code = res_1_6.json()["data"]["ticket_code"]
        assert_test(valid_comp_code.startswith("KN-"), "1.6.1: Mã đơn có tiền tố chuẩn KN-YYYYMM-XXXX")
        assert_test(res_1_6.json()["data"]["receiver_id"] == teacher_user.id, "1.6.2: Người nhận tự động gán là Giảng viên phụ trách")

        print("\n--- NHÓM 2: BẢO MẬT & CÔ LẬP DỮ LIỆU ADMIN & STAFF (F-01, F-04, F-10) ---")

        # 2.1: Admin và Staff bị cấm tạo đơn mới
        res_2_1a = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST", "category": "OTHER", "title": "Admin tao don", "content": "Noi dung test"
        }, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_2_1a.status_code == 403, "2.1a: ADMIN bị cấm tạo đơn mới (403 Forbidden)")

        res_2_1b = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST", "category": "OTHER", "title": "Staff tao don", "content": "Noi dung test"
        }, headers={"Authorization": f"Bearer {tokens['ACADEMIC_STAFF']}"})
        assert_test(res_2_1b.status_code == 403, "2.1b: ACADEMIC_STAFF bị cấm tạo đơn mới (403 Forbidden)")

        # 2.2: Admin inbox KHÔNG chứa bất kỳ đơn khiếu nại điểm nào
        res_adm_inbox = client.get("/api/v1/tickets/inbox", headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        adm_tickets = res_adm_inbox.json()["data"]
        no_complaint_admin = all(not TicketService.is_score_complaint(t) for t in adm_tickets)
        assert_test(no_complaint_admin, "2.2: Hộp thư ADMIN 100% không rò rỉ đơn khiếu nại điểm")

        # 2.3: Staff inbox KHÔNG chứa bất kỳ đơn khiếu nại điểm nào
        res_stf_inbox = client.get("/api/v1/tickets/inbox", headers={"Authorization": f"Bearer {tokens['ACADEMIC_STAFF']}"})
        stf_tickets = res_stf_inbox.json()["data"]
        no_complaint_staff = all(not TicketService.is_score_complaint(t) for t in stf_tickets)
        assert_test(no_complaint_staff, "2.3: Hộp thư ACADEMIC_STAFF 100% không rò rỉ đơn khiếu nại điểm")

        # 2.4: Admin truy cập chi tiết đơn khiếu nại điểm -> 403
        res_2_4 = client.get(f"/api/v1/tickets/{valid_comp_id}", headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_2_4.status_code == 403, "2.4: ADMIN truy cập chi tiết khiếu nại điểm bị chặn 403 Forbidden")

        # 2.5: Staff truy cập chi tiết đơn khiếu nại điểm -> 403
        res_2_5 = client.get(f"/api/v1/tickets/{valid_comp_id}", headers={"Authorization": f"Bearer {tokens['ACADEMIC_STAFF']}"})
        assert_test(res_2_5.status_code == 403, "2.5: ACADEMIC_STAFF truy cập chi tiết khiếu nại điểm bị chặn 403 Forbidden")

        # 2.6: Admin gửi phản hồi vào khiếu nại điểm -> 403
        res_2_6 = client.post(f"/api/v1/tickets/{valid_comp_id}/messages", json={"content": "Admin tham gia"}, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_2_6.status_code == 403, "2.6: ADMIN gửi tin nhắn vào khiếu nại điểm bị chặn 403 Forbidden")

        # 2.7: Admin đổi trạng thái khiếu nại điểm -> 403
        res_2_7 = client.patch(f"/api/v1/tickets/{valid_comp_id}/status", json={"status": "RESOLVED"}, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_2_7.status_code == 403, "2.7: ADMIN đổi trạng thái khiếu nại điểm bị chặn 403 Forbidden")

        # 2.8: Kiểm tra Authentication (không token và token sai)
        res_no_tok = client.get("/api/v1/tickets/inbox")
        assert_test(res_no_tok.status_code == 401, "2.8a: Không có Authorization token trả về chính xác 401 Unauthorized")
        res_bad_tok = client.get("/api/v1/tickets/inbox", headers={"Authorization": "Bearer invalid_token_xyz"})
        assert_test(res_bad_tok.status_code == 401, "2.8b: Token giả mạo hoặc không hợp lệ trả về chính xác 401 Unauthorized")

        print("\n--- NHÓM 3: MỞ SỔ ĐIỂM CHUẨN XÁC & AUDIT LOG (F-02, F-07, F-08, F-11) ---")

        # Tạo 1 đơn REQUEST category OTHER có chữ "mở sổ điểm" trong title (Heuristic trap)
        res_trap = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "OTHER",
            "title": "Mở sổ điểm và xem lại lịch",
            "content": "Tôi gửi yêu cầu mở sổ điểm này nhưng category là OTHER",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        assert_test(res_trap.status_code == 200, "3.1a: Tạo đơn REQUEST có category OTHER thành công")
        trap_ticket_id = res_trap.json()["data"]["id"]

        # Đảm bảo lớp học bị khóa điểm trước khi test
        enrolled_class.is_grade_unlocked = False
        db.query(GradeRecord).filter(GradeRecord.class_id == enrolled_class.id).update({"is_confirmed": True})
        db.commit()

        # Admin phê duyệt đơn bẫy: duyệt đơn nhưng KHÔNG ĐƯỢC mở khóa sổ điểm vì không phải GRADE_UNLOCK
        res_trap_appr = client.patch(f"/api/v1/tickets/{trap_ticket_id}/status", json={"status": "APPROVED"}, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_trap_appr.status_code == 200, "3.1b: Phê duyệt đơn OTHER thành công")
        
        db.refresh(enrolled_class)
        assert_test(enrolled_class.is_grade_unlocked == False, "3.1c: Loại bỏ hoàn toàn heuristic! Không mở sổ điểm khi đơn không phải GRADE_UNLOCK")

        # 3.2: Giáo viên gửi GRADE_UNLOCK cho lớp mình KHÔNG giảng dạy -> Bị chặn 403
        res_3_2 = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "GRADE_UNLOCK",
            "title": "Yêu cầu mở sổ điểm",
            "content": "Mở sổ điểm lớp người khác",
            "related_class_id": other_teacher_class.id
        }, headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        assert_test(res_3_2.status_code == 403, "3.2: Giảng viên chỉ được yêu cầu mở sổ điểm cho lớp do mình phụ trách (403)")

        # 3.3: Giáo viên gửi GRADE_UNLOCK cho lớp do mình dạy
        res_3_3 = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "GRADE_UNLOCK",
            "title": "Yêu cầu mở sổ điểm nhập điểm bổ sung",
            "content": "Cần mở sổ điểm cho lớp để cập nhật điểm bổ sung cho sinh viên",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        assert_test(res_3_3.status_code == 200, "3.3: Giảng viên gửi yêu cầu mở sổ điểm hợp lệ thành công")
        unlock_ticket_id = res_3_3.json()["data"]["id"]

        # 3.4: Người tạo đơn không được tự duyệt đơn của mình
        res_3_4 = client.patch(f"/api/v1/tickets/{unlock_ticket_id}/status", json={"status": "APPROVED"}, headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        assert_test(res_3_4.status_code == 403, "3.4: Chặn người tạo đơn tự phê duyệt đơn của chính mình")

        # 3.5: Admin phê duyệt đơn mở sổ điểm hợp lệ -> Mở khóa và ghi audit log
        res_3_5 = client.patch(f"/api/v1/tickets/{unlock_ticket_id}/status", json={
            "status": "APPROVED",
            "reason": "Chấp thuận mở sổ điểm trong 72 giờ"
        }, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_3_5.status_code == 200, "3.5: ADMIN phê duyệt đơn GRADE_UNLOCK thành công")

        db.refresh(enrolled_class)
        assert_test(enrolled_class.is_grade_unlocked == True, "3.5.1: Sổ điểm của lớp đã được mở khóa thành công")

        # 3.5.1b: Khi sổ điểm đang mở, chặn giáo viên tạo thêm yêu cầu mở sổ trùng lặp
        res_already_open = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "GRADE_UNLOCK",
            "title": "Yêu cầu mở tiếp khi đã mở",
            "content": "Sổ điểm đã mở nhưng tôi vẫn gửi yêu cầu",
            "related_class_id": enrolled_class.id
        }, headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        assert_test(res_already_open.status_code == 400, "3.5.1b: Chặn tạo yêu cầu mở sổ điểm khi lớp học đang trong trạng thái mở sổ")

        # Kiểm tra audit log trong GradeLockHistory và TicketMessage
        lock_hist = db.query(GradeLockHistory).filter(GradeLockHistory.class_id == enrolled_class.id).order_by(GradeLockHistory.id.desc()).first()
        assert_test(lock_hist is not None and lock_hist.action == "UNLOCK", "3.5.2: Ghi log kiểm toán UNLOCK vào GradeLockHistory")

        ticket_msgs = db.query(TicketMessage).filter(TicketMessage.ticket_id == unlock_ticket_id).all()
        has_audit_msg = any("[HỆ THỐNG]" in m.content and "APPROVED" in m.content for m in ticket_msgs)
        assert_test(has_audit_msg, "3.5.3: Ghi log kiểm toán chuyển trạng thái vào TicketMessage")

        # 3.6: Chặn duyệt lại đơn đã APPROVED (F-11)
        res_3_6 = client.patch(f"/api/v1/tickets/{unlock_ticket_id}/status", json={"status": "APPROVED"}, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_3_6.status_code == 400, "3.6: Chặn phê duyệt lại đơn đã có kết quả (F-11)")

        # 3.7: Từ chối đơn REJECTED bắt buộc phải có lý do
        # Tạo thêm 1 request để test reject
        res_req2 = client.post("/api/v1/tickets/", json={
            "ticket_type": "REQUEST", "category": "SCHEDULE", "title": "Xin đổi phòng", "content": "Xin đổi phòng học"
        }, headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        req2_id = res_req2.json()["data"]["id"]

        res_3_7a = client.patch(f"/api/v1/tickets/{req2_id}/status", json={"status": "REJECTED", "reason": ""}, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_3_7a.status_code == 400, "3.7a: Từ chối yêu cầu không có lý do bị chặn 400")

        res_3_7b = client.patch(f"/api/v1/tickets/{req2_id}/status", json={"status": "REJECTED", "reason": "Phòng học bận lịch khác"}, headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_3_7b.status_code == 200, "3.7b: Từ chối kèm lý do thành công và lưu lý do")

        # 3.8: Kiểm tra giới hạn mở khóa 72 giờ (F-07)
        # Giả lập lùi thời gian UNLOCK về 73 giờ trước
        lock_hist.performed_at = datetime.now(timezone.utc) - timedelta(hours=73)
        db.commit()

        is_locked_now, lock_msg = GradeService.check_and_update_class_grade_lock(db, enrolled_class)
        assert_test(is_locked_now == True, "3.8a: Hết thời hạn 72 giờ, sổ điểm tự động khóa lại (is_grade_locked = True)")

        auto_lock_hist = db.query(GradeLockHistory).filter(
            GradeLockHistory.class_id == enrolled_class.id,
            GradeLockHistory.action == "AUTO_LOCK"
        ).first()
        assert_test(auto_lock_hist is not None, "3.8b: Tự động ghi nhận bản ghi AUTO_LOCK vào GradeLockHistory")

        print("\n--- NHÓM 4: CHỐNG ENUMERATION & IDOR (F-10) ---")

        # 4.1: Truy cập ID không tồn tại -> 404
        res_4_1 = client.get("/api/v1/tickets/9999999", headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_4_1.status_code == 404, "4.1: ID không tồn tại trả về chính xác 404 Not Found")

        # 4.2: Truy cập ID đơn của người khác không có quyền -> 403 Forbidden hoặc 404 Not Found (F-10 chuẩn hóa 404 chống enumeration)
        res_4_2 = client.get(f"/api/v1/tickets/{req2_id}", headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert_test(res_4_2.status_code in (403, 404), "4.2: ID đơn riêng tư của người khác bị từ chối truy cập (403/404)")

        print("\n--- NHÓM 5: PHÂN TRANG PHÍA SERVER & TÌM KIẾM (F-06, F-09) ---")

        # 5.1: Phân trang GET /inbox có page=1, limit=5
        res_5_1 = client.get("/api/v1/tickets/inbox?page=1&limit=5", headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_5_1.status_code == 200, "5.1a: Gọi API phân trang thành công")
        data_paged = res_5_1.json()["data"]
        assert_test(isinstance(data_paged, dict) and "items" in data_paged, "5.1b: Trả về cấu trúc phân trang chuẩn { items, total, page, limit, total_pages }")
        assert_test(data_paged["page"] == 1 and data_paged["limit"] == 5, "5.1c: Phản ánh đúng page=1, limit=5")
        assert_test(len(data_paged["items"]) <= 5, "5.1d: Số bản ghi trả về không vượt quá limit")
        assert_test(data_paged["total"] >= 90, "5.1e: Total phản ánh toàn bộ đơn trong phạm vi phân quyền")

        # 5.2: Tìm kiếm database q="YC-"
        res_5_2 = client.get("/api/v1/tickets/inbox?page=1&limit=5&q=YC-", headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_5_2.status_code == 200, "5.2a: Tìm kiếm từ khóa theo mã đơn thành công")
        data_search = res_5_2.json()["data"]
        assert_test(all("YC-" in item["ticket_code"] for item in data_search["items"]), "5.2b: Kết quả tìm kiếm khớp 100% từ khóa tìm kiếm")

        # 5.3: Backward compatibility (không truyền page/limit)
        res_5_3 = client.get("/api/v1/tickets/inbox", headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert_test(res_5_3.status_code == 200, "5.3a: Gọi không param thành công")
        assert_test(isinstance(res_5_3.json()["data"], list), "5.3b: Trả về danh sách phẳng tương thích test cũ")

        print("\n==================================================================")
        print(f"🎉 KẾT QUẢ KIỂM THỬ: {passed_cases}/{total_cases} TEST CASES ĐÃ ĐẠT (100% PASS)!")
        print("==================================================================")

    finally:
        db.close()
        temp_engine.dispose()
        # Dọn dẹp database tạm
        if os.path.exists(TEMP_DB):
            try:
                os.remove(TEMP_DB)
                print("🧹 Đã dọn dẹp sạch sẽ database kiểm thử tạm temp_test_audit.db!")
            except Exception as e:
                print(f"⚠️ Cảnh báo dọn dẹp file tạm: {e}")

if __name__ == "__main__":
    run_audit_suite()
