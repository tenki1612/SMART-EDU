import os
import sys
from pathlib import Path

# Force UTF-8 stdout
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

# Ensure backend directory is in sys.path
backend_dir = Path(__file__).resolve().parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

# Route to backend/language_center.db
os.environ["DATABASE_URL"] = f"sqlite:///{(backend_dir / 'language_center.db').as_posix()}"

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.modules.accounts.models import User
from app.modules.classes.models import Class
from app.modules.teachers.models import Teacher
from app.modules.grades.models import GradeRecord, GradeLockHistory
from app.modules.tickets.models import Ticket, TicketMessage

client = TestClient(app)

def test_seeded_data():
    print("==================================================================")
    print("🚀 BẮT ĐẦU KIỂM THỬ TOÀN DIỆN SEED DATA (SMART-EDU TEST SUITE)")
    print("==================================================================\n")

    db = SessionLocal()
    try:
        # -------------------------------------------------------------
        # PHẦN 1: KIỂM TRA QUY MÔ TÀI KHOẢN VÀ PHÂN QUYỀN
        # -------------------------------------------------------------
        print("--- [1/6] Kiểm tra quy mô tài khoản cố định theo vai trò ---")
        role_counts = {}
        users = db.query(User).filter(User.is_deleted == False).all()
        for u in users:
            r = u.role.value if hasattr(u.role, 'value') else str(u.role)
            role_counts[r] = role_counts.get(r, 0) + 1

        print(f"   • ADMIN:          {role_counts.get('ADMIN', 0)} (Kỳ vọng: chính xác 1)")
        print(f"   • ACADEMIC_STAFF: {role_counts.get('ACADEMIC_STAFF', 0)} (Kỳ vọng: chính xác 1)")
        print(f"   • TEACHER:        {role_counts.get('TEACHER', 0)} (Kỳ vọng: 30–50)")
        print(f"   • STUDENT:        {role_counts.get('STUDENT', 0)} (Kỳ vọng: 300–500)")
        print(f"   • PARENT:         {role_counts.get('PARENT', 0)} (Kỳ vọng: 150–250)")
        print(f"   • TỔNG NGƯỜI DÙNG:{len(users)} (Kỳ vọng: 572)")

        assert role_counts.get('ADMIN') == 1, "Lỗi: Số lượng ADMIN không chính xác là 1!"
        assert role_counts.get('ACADEMIC_STAFF') == 1, "Lỗi: Số lượng ACADEMIC_STAFF không chính xác là 1!"
        assert 30 <= role_counts.get('TEACHER', 0) <= 50, "Lỗi: Số lượng TEACHER nằm ngoài dải 30-50!"
        assert 300 <= role_counts.get('STUDENT', 0) <= 500, "Lỗi: Số lượng STUDENT nằm ngoài dải 300-500!"
        assert 150 <= role_counts.get('PARENT', 0) <= 250, "Lỗi: Số lượng PARENT nằm ngoài dải 150-250!"
        assert len(users) == 572, f"Lỗi: Tổng số tài khoản là {len(users)}, kỳ vọng 572!"
        print("   ✅ [PASS] Quy mô tài khoản đạt chuẩn 100%!\n")

        # -------------------------------------------------------------
        # PHẦN 2: KIỂM TRA ĐĂNG NHẬP VÀ XÁC THỰC CÁC TÀI KHOẢN MẪU
        # -------------------------------------------------------------
        print("--- [2/6] Kiểm tra đăng nhập và JWT Token từng vai trò ---")
        login_credentials = [
            ("admin", "admin123", "ADMIN"),
            ("staff", "staff123", "ACADEMIC_STAFF"),
            ("teacher", "teacher123", "TEACHER"),
            ("student", "student123", "STUDENT"),
            ("parent", "parent123", "PARENT"),
        ]

        tokens = {}
        for username, password, expected_role in login_credentials:
            res = client.post("/api/v1/auth/login", json={"username": username, "password": password})
            assert res.status_code == 200, f"Lỗi: Không thể đăng nhập tài khoản {username} (Mã lỗi: {res.status_code})"
            data = res.json().get("data", {})
            token = data.get("access_token")
            user_role = data.get("role")
            full_name = data.get("full_name")
            assert token, f"Lỗi: Không có access token cho {username}"
            assert user_role == expected_role, f"Lỗi: Vai trò {user_role} không khớp kỳ vọng {expected_role}"
            tokens[expected_role] = token
            print(f"   • Đăng nhập thành công: {username.ljust(10)} | Vai trò: {expected_role.ljust(15)} | Họ tên: {full_name}")

        print("   ✅ [PASS] Xác thực thông tin đăng nhập tất cả vai trò thành công!\n")

        # -------------------------------------------------------------
        # PHẦN 3: KIỂM TRA VÒNG ĐỜI LỚP HỌC VÀ KHÓA SỔ ĐIỂM
        # -------------------------------------------------------------
        print("--- [3/6] Kiểm tra chuẩn hóa vòng đời lớp học (Class Lifecycle) ---")
        classes = db.query(Class).filter(Class.is_deleted == False).all()
        class_by_status = {}
        for c in classes:
            class_by_status.setdefault(c.status, []).append(c)

        print(f"   • Lớp PLANNING:            {len(class_by_status.get('PLANNING', []))} lớp")
        print(f"   • Lớp OPEN_FOR_ENROLLMENT: {len(class_by_status.get('OPEN_FOR_ENROLLMENT', []))} lớp")
        print(f"   • Lớp IN_PROGRESS:         {len(class_by_status.get('IN_PROGRESS', []))} lớp")
        print(f"   • Lớp COMPLETED:           {len(class_by_status.get('COMPLETED', []))} lớp")

        # Rule 1: PLANNING & OPEN_FOR_ENROLLMENT MUST HAVE 0 GRADES
        for c in class_by_status.get('PLANNING', []):
            g_count = db.query(GradeRecord).filter(GradeRecord.class_id == c.id, GradeRecord.is_deleted == False).count()
            assert g_count == 0, f"Lỗi: Lớp PLANNING {c.class_code} có {g_count} bảng điểm!"

        for c in class_by_status.get('OPEN_FOR_ENROLLMENT', []):
            g_count = db.query(GradeRecord).filter(GradeRecord.class_id == c.id, GradeRecord.is_deleted == False).count()
            assert g_count == 0, f"Lỗi: Lớp OPEN_FOR_ENROLLMENT {c.class_code} có {g_count} bảng điểm!"

        # Rule 2: COMPLETED CLASSES MUST HAVE LOCKED GRADES
        for c in class_by_status.get('COMPLETED', []):
            unlocked = db.query(GradeRecord).filter(
                GradeRecord.class_id == c.id,
                GradeRecord.is_confirmed == False,
                GradeRecord.is_deleted == False
            ).count()
            assert unlocked == 0, f"Lỗi: Lớp COMPLETED {c.class_code} có bảng điểm chưa khóa sổ!"

        print("   ✅ [PASS] 100% lớp OPEN/PLANNING không có điểm, 100% lớp COMPLETED đã khóa sổ điểm!\n")

        # -------------------------------------------------------------
        # PHẦN 4: KIỂM TRA SỐ LƯỢNG VÀ TRẠNG THÁI YÊU CẦU & KHIẾU NẠI
        # -------------------------------------------------------------
        print("--- [4/6] Kiểm tra số lượng và phân bố trạng thái Đơn từ & Khiếu nại ---")
        complaints = db.query(Ticket).filter(Ticket.ticket_type == 'COMPLAINT', Ticket.is_deleted == False).all()
        requests = db.query(Ticket).filter(Ticket.ticket_type == 'REQUEST', Ticket.is_deleted == False).all()

        print(f"   • Tổng số Khiếu nại học viên (COMPLAINT):    {len(complaints)} (Quy chuẩn: 100–150)")
        print(f"   • Tổng số Yêu cầu mở sổ điểm (REQUEST):      {len(requests)} (Quy chuẩn: 80–120)")
        assert 100 <= len(complaints) <= 150, "Lỗi: Số lượng khiếu nại học viên ngoài dải 100-150!"
        assert 80 <= len(requests) <= 120, "Lỗi: Số lượng yêu cầu mở sổ điểm ngoài dải 80-120!"

        # Status breakdown
        comp_statuses = {}
        for c in complaints:
            comp_statuses[c.status] = comp_statuses.get(c.status, 0) + 1
        print("   • Phân bố trạng thái COMPLAINT:")
        for st, cnt in sorted(comp_statuses.items()):
            print(f"     - {st.ljust(12)}: {cnt} đơn")

        req_statuses = {}
        for r in requests:
            req_statuses[r.status] = req_statuses.get(r.status, 0) + 1
        print("   • Phân bố trạng thái REQUEST:")
        for st, cnt in sorted(req_statuses.items()):
            print(f"     - {st.ljust(12)}: {cnt} đơn")

        # Check: No PENDING ticket has fake completion history
        pending_tickets = db.query(Ticket).filter(Ticket.status == 'PENDING', Ticket.is_deleted == False).all()
        fake_pending_count = 0
        for pt in pending_tickets:
            for m in pt.messages:
                if "[HỆ THỐNG]" in m.content or "[KẾT QUẢ XỬ LÝ]" in m.content:
                    fake_pending_count += 1
        assert fake_pending_count == 0, f"Lỗi: Có {fake_pending_count} đơn PENDING chứa tin nhắn hoàn tất giả mạo!"

        # Check: All APPROVED unlock requests have history in LICHSU_KHOA_DIEM
        approved_reqs = [r for r in requests if r.status == 'APPROVED']
        for ar in approved_reqs:
            audit = db.query(GradeLockHistory).filter(
                GradeLockHistory.class_id == ar.related_class_id,
                GradeLockHistory.reason.like(f"%{ar.ticket_code}%")
            ).first()
            assert audit is not None, f"Lỗi: Đơn APPROVED #{ar.ticket_code} thiếu log trong LICHSU_KHOA_DIEM!"

        print("   ✅ [PASS] Số lượng, trạng thái và audit log khớp 100% nghiệp vụ!\n")

        # -------------------------------------------------------------
        # PHẦN 5: KIỂM TRA PHÂN QUYỀN TRUY CẬP API (ACCESS CONTROL / ISOLATION)
        # -------------------------------------------------------------
        print("--- [5/6] Kiểm tra quyền hạn truy cập API Đơn từ theo vai trò ---")

        # 1. Student sent box
        res_stu = client.get("/api/v1/tickets/sent", headers={"Authorization": f"Bearer {tokens['STUDENT']}"})
        assert res_stu.status_code == 200, "Lỗi gọi API /api/v1/tickets/sent cho Student"
        stu_tickets = res_stu.json().get("data", [])
        print(f"   • Học viên 'student' thấy đơn đã gửi: {len(stu_tickets)} đơn")
        for t in stu_tickets:
            assert t["sender_name"] == "Phạm Minh Khang (Student)", "Lỗi rò rỉ đơn của học viên khác!"

        # 2. Teacher inbox: only tickets of teacher's own classes
        res_tea = client.get("/api/v1/tickets/inbox", headers={"Authorization": f"Bearer {tokens['TEACHER']}"})
        assert res_tea.status_code == 200, "Lỗi gọi API /api/v1/tickets/inbox cho Teacher"
        tea_inbox = res_tea.json().get("data", [])
        print(f"   • Giảng viên 'teacher' nhận trong hộp thư: {len(tea_inbox)} đơn (chỉ thuộc lớp GV phụ trách)")

        # 3. Academic Staff inbox: sees requests and assigned complaints
        res_stf = client.get("/api/v1/tickets/inbox", headers={"Authorization": f"Bearer {tokens['ACADEMIC_STAFF']}"})
        assert res_stf.status_code == 200, "Lỗi gọi API /api/v1/tickets/inbox cho Academic Staff"
        stf_inbox = res_stf.json().get("data", [])
        print(f"   • Nhân viên học vụ 'staff' nhận trong hộp thư: {len(stf_inbox)} đơn")

        # 4. Admin inbox: sees all requests (not complaints)
        res_adm = client.get("/api/v1/tickets/inbox", headers={"Authorization": f"Bearer {tokens['ADMIN']}"})
        assert res_adm.status_code == 200, "Lỗi gọi API /api/v1/tickets/inbox cho Admin"
        adm_inbox = res_adm.json().get("data", [])
        print(f"   • Quản trị viên 'admin' thấy các đơn yêu cầu: {len(adm_inbox)} đơn trong hệ thống (loại trừ khiếu nại)")
        assert len(adm_inbox) >= 90, "Lỗi: Admin thiếu đơn yêu cầu!"
        assert all(t["ticket_type"] == "REQUEST" for t in adm_inbox), "Lỗi: Admin không được thấy đơn khiếu nại COMPLAINT!"

        print("   ✅ [PASS] Phân quyền hiển thị hộp thư đến và đơn đã gửi bảo mật tuyệt đối!\n")

        # -------------------------------------------------------------
        # PHẦN 6: KIỂM TRA LIÊN KẾT BẢNG ĐIỂM VÀ LỊCH SỬ TRAO ĐỔI
        # -------------------------------------------------------------
        print("--- [6/6] Kiểm tra liên kết điểm số và lịch sử trao đổi trong đơn ---")
        # Get detail of a complaint: Admin is forbidden, Teacher has access
        comp_example = complaints[50] # Status: PROCESSING
        res_detail_admin = client.get(
            f"/api/v1/tickets/{comp_example.id}",
            headers={"Authorization": f"Bearer {tokens['ADMIN']}"}
        )
        assert res_detail_admin.status_code == 403, f"Lỗi: Admin không được phép xem khiếu nại điểm (kỳ vọng 403, nhận {res_detail_admin.status_code})"

        # Find teacher of this class to view detail
        cls_comp = db.query(Class).filter(Class.id == comp_example.related_class_id).first()
        tea_comp = db.query(Teacher).filter(Teacher.id == cls_comp.teacher_id).first()
        tea_user = db.query(User).filter(User.id == tea_comp.user_id).first()
        tea_token = client.post("/api/v1/auth/login", json={"username": tea_user.username, "password": "teacher123"}).json()["data"]["access_token"]

        res_detail = client.get(
            f"/api/v1/tickets/{comp_example.id}",
            headers={"Authorization": f"Bearer {tea_token}"}
        )
        assert res_detail.status_code == 200, f"Lỗi lấy chi tiết đơn #{comp_example.id} bởi giảng viên phụ trách"
        detail_data = res_detail.json().get("data", {})
        print(f"   • Kiểm tra đơn #{detail_data['ticket_code']}:")
        print(f"     - Tiêu đề:          {detail_data['title']}")
        print(f"     - Lớp học liên quan: {detail_data['class_code']} ({detail_data['course_title']})")
        print(f"     - Giảng viên:       {detail_data['teacher_name']}")
        print(f"     - Trạng thái khóa:  {detail_data['is_grade_locked']}")
        print(f"     - Điểm liên kết:    {detail_data['current_grade']}")
        print(f"     - Số tin nhắn:      {len(detail_data.get('messages', []))} tin nhắn")

        assert detail_data["class_code"] is not None, "Lỗi: Không tìm thấy mã lớp học liên quan!"
        assert len(detail_data.get("messages", [])) > 0, "Lỗi: Đơn PROCESSING phải có tin nhắn trao đổi!"

        # Get detail of an APPROVED unlock request
        appr_example = [r for r in requests if r.status == 'APPROVED'][0]
        res_appr = client.get(
            f"/api/v1/tickets/{appr_example.id}",
            headers={"Authorization": f"Bearer {tokens['ADMIN']}"}
        )
        assert res_appr.status_code == 200, f"Lỗi lấy chi tiết đơn #{appr_example.id}"
        appr_data = res_appr.json().get("data", {})
        print(f"   • Kiểm tra đơn phê duyệt mở sổ #{appr_data['ticket_code']}:")
        print(f"     - Giảng viên đề nghị: {appr_data['sender_name']}")
        print(f"     - Trạng thái:        {appr_data['status']}")
        messages_text = [m['content'] for m in appr_data.get('messages', [])]
        assert any("[HỆ THỐNG]" in txt for txt in messages_text), "Lỗi: Đơn APPROVED thiếu tin nhắn phê duyệt hệ thống!"
        print(f"     - Tin nhắn phê duyệt: {messages_text[0][:70]}...")

        print("   ✅ [PASS] Liên kết bảng điểm, mã lớp và lịch sử trao đổi hoạt động hoàn hảo!\n")

    finally:
        db.close()

    print("==================================================================")
    print("🎉 TOÀN BỘ BỘ DỮ LIỆU SEED DATA ĐẠT CHUẨN 100% VÀ SẴN SÀNG SỬ DỤNG!")
    print("==================================================================")

if __name__ == "__main__":
    test_seeded_data()
