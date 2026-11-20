import os
import sys
from pathlib import Path
from datetime import date, timedelta

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

backend_dir = Path(__file__).resolve().parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

os.environ["DATABASE_URL"] = f"sqlite:///{(backend_dir / 'language_center.db').as_posix()}"

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.modules.accounts.models import User
from app.modules.classes.models import Class, ClassStudent
from app.modules.students.models import Student
from app.modules.teachers.models import Teacher
from app.modules.grades.models import GradeRecord, GradeLockHistory
from app.modules.tickets.models import Ticket

client = TestClient(app)

def get_token(username, password):
    res = client.post("/api/v1/auth/login", json={"username": username, "password": password})
    if res.status_code != 200:
        raise Exception(f"Không thể đăng nhập {username}: {res.text}")
    return res.json()["data"]["access_token"]

def auth_headers(token):
    return {"Authorization": f"Bearer {token}"}

def run_rbac_tests():
    print("==================================================================")
    print("🛡️ KIỂM THỬ PHÂN QUYỀN RBAC MODULE ĐƠN TỪ & KHIẾU NẠI SMART-EDU")
    print("==================================================================\n")

    db = SessionLocal()
    passed_tests = 0
    total_tests = 14

    try:
        # Prepare tokens
        admin_token = get_token("admin", "admin123")
        staff_token = get_token("staff", "staff123")
        teacher_token = get_token("teacher", "teacher123")
        student_token = get_token("student", "student123")

        # Find student and their enrolled class
        student_user = db.query(User).filter(User.username == "student").first()
        student_rec = db.query(Student).filter(Student.user_id == student_user.id).first()
        enrollment = db.query(ClassStudent).filter(
            ClassStudent.student_id == student_rec.id,
            ClassStudent.is_deleted == False
        ).first()

        assert enrollment, "Học viên student chưa ghi danh vào lớp nào!"
        cls = db.query(Class).filter(Class.id == enrollment.class_id).first()
        
        # Ensure class has an assigned teacher and is not expired past complaint window
        teacher_rec = db.query(Teacher).filter(Teacher.id == cls.teacher_id).first()
        teacher_user = db.query(User).filter(User.id == teacher_rec.user_id).first()
        teacher_user_token = get_token(teacher_user.username, "teacher123") if teacher_user.username != "teacher" else teacher_token

        # Extend class end_date to ensure within complaint window
        cls.end_date = date.today() + timedelta(days=10)
        db.commit()

        # Find a second student
        other_student_user = db.query(User).filter(
            User.role == "STUDENT",
            User.id != student_user.id
        ).first()
        other_student_token = get_token(other_student_user.username, "student123")

        # Find a second teacher who does NOT teach this class
        other_teacher_rec = db.query(Teacher).filter(
            Teacher.id != cls.teacher_id,
            Teacher.is_deleted == False
        ).first()
        other_teacher_user = db.query(User).filter(User.id == other_teacher_rec.user_id).first()
        other_teacher_token = get_token(other_teacher_user.username, "teacher123")

        print(f"📌 Thông tin môi trường test:")
        print(f"   • Học viên 1: {student_user.username} (ID: {student_user.id})")
        print(f"   • Học viên 2: {other_student_user.username} (ID: {other_student_user.id})")
        print(f"   • Giảng viên lớp ({cls.class_code}): {teacher_user.username} (ID: {teacher_user.id})")
        print(f"   • Giảng viên khác: {other_teacher_user.username} (ID: {other_teacher_user.id})\n")

        # -----------------------------------------------------------------
        # TEST CASE 1: Student creates grade complaint successfully
        # -----------------------------------------------------------------
        print("▶ [Test 1/14] Student tạo khiếu nại điểm lớp đã học gửi Giảng viên")
        res = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(student_token),
            json={
                "ticket_type": "COMPLAINT",
                "category": "GRADE",
                "related_class_id": cls.id,
                "title": "Khiếu nại điểm chuyên cần học kỳ 1",
                "content": "Em có mặt đầy đủ các buổi học nhưng điểm chuyên cần chỉ có 7.0, xin thầy kiểm tra lại."
            }
        )
        assert res.status_code == 200, f"Thất bại: {res.text}"
        ticket_data = res.json()["data"]
        complaint_ticket_id = ticket_data["id"]
        assert ticket_data["ticket_type"] == "COMPLAINT"
        assert ticket_data["receiver_role"] == "TEACHER"
        assert ticket_data["sender_id"] == student_user.id
        print(f"   ✅ [PASS] Tạo khiếu nại thành công! Mã đơn: {ticket_data['ticket_code']} (ID: {complaint_ticket_id})")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 2: Student cannot view another student's complaint
        # -----------------------------------------------------------------
        print("▶ [Test 2/14] Student khác không được xem chi tiết khiếu nại của bạn")
        res = client.get(
            f"/api/v1/tickets/{complaint_ticket_id}",
            headers=auth_headers(other_student_token)
        )
        assert res.status_code == 403, f"Thất bại: Mã phản hồi {res.status_code}, kỳ vọng 403"
        print(f"   ✅ [PASS] Bị chặn 403 Forbidden chính xác: {res.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 3: Teacher receives complaint for their class in inbox
        # -----------------------------------------------------------------
        print("▶ [Test 3/14] Giảng viên phụ trách nhận được khiếu nại trong Inbox")
        res = client.get(
            "/api/v1/tickets/inbox",
            headers=auth_headers(teacher_user_token)
        )
        assert res.status_code == 200, f"Thất bại: {res.text}"
        inbox_ids = [t["id"] for t in res.json()["data"]]
        assert complaint_ticket_id in inbox_ids, f"Đơn {complaint_ticket_id} không có trong hộp thư giảng viên!"
        print(f"   ✅ [PASS] Đơn khiếu nại xuất hiện chính xác trong hộp thư của giảng viên.")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 4: Teacher cannot view complaint for a class they don't teach
        # -----------------------------------------------------------------
        print("▶ [Test 4/14] Giảng viên không dạy lớp đó KHÔNG được xem chi tiết đơn")
        res = client.get(
            f"/api/v1/tickets/{complaint_ticket_id}",
            headers=auth_headers(other_teacher_token)
        )
        assert res.status_code == 403, f"Thất bại: Mã phản hồi {res.status_code}, kỳ vọng 403"
        print(f"   ✅ [PASS] Giảng viên ngoài lớp bị chặn 403 Forbidden: {res.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 5: Teacher replies to and resolves complaint
        # -----------------------------------------------------------------
        print("▶ [Test 5/14] Giảng viên phụ trách phản hồi và giải quyết khiếu nại")
        res_msg = client.post(
            f"/api/v1/tickets/{complaint_ticket_id}/messages",
            headers=auth_headers(teacher_user_token),
            json={"content": "Thầy đã rà soát lại sổ điểm danh, đúng là buổi số 3 có ghi nhận nhầm."}
        )
        assert res_msg.status_code == 200, f"Thất bại gửi tin nhắn: {res_msg.text}"

        res_res = client.patch(
            f"/api/v1/tickets/{complaint_ticket_id}/status",
            headers=auth_headers(teacher_user_token),
            json={
                "status": "RESOLVED",
                "reason": "Đã điều chỉnh điểm chuyên cần từ 7.0 lên 10.0 cho học viên."
            }
        )
        assert res_res.status_code == 200, f"Thất bại giải quyết đơn: {res_res.text}"
        assert res_res.json()["data"]["status"] == "RESOLVED"
        print("   ✅ [PASS] Giảng viên phản hồi và giải quyết khiếu nại thành công (status -> RESOLVED).")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 6: Teacher creates grade unlock request successfully
        # -----------------------------------------------------------------
        print("▶ [Test 6/14] Giảng viên tạo Yêu cầu mở sổ điểm gửi Phòng Học vụ")
        # Đảm bảo sổ điểm lớp học đang ở trạng thái khóa
        grade_rec = db.query(GradeRecord).filter(GradeRecord.class_id == cls.id, GradeRecord.is_deleted == False).first()
        if not grade_rec:
            grade_rec = GradeRecord(class_id=cls.id, student_id=student_rec.id, result_status="PENDING")
            db.add(grade_rec)
        grade_rec.is_confirmed = True
        cls.is_grade_unlocked = False
        db.commit()

        res_unlock = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(teacher_user_token),
            json={
                "ticket_type": "REQUEST",
                "category": "GRADE_UNLOCK",
                "related_class_id": cls.id,
                "title": f"Yêu cầu mở sổ điểm lớp {cls.class_code}",
                "content": "Cần mở sổ điểm để cập nhật điểm chuyên cần đã giải quyết khiếu nại cho học viên."
            }
        )
        assert res_unlock.status_code == 200, f"Thất bại: {res_unlock.text}"
        unlock_ticket_data = res_unlock.json()["data"]
        unlock_ticket_id = unlock_ticket_data["id"]
        assert unlock_ticket_data["ticket_type"] == "REQUEST"
        assert unlock_ticket_data["category"] == "GRADE_UNLOCK"
        assert unlock_ticket_data["receiver_role"] == "ACADEMIC_STAFF"
        print(f"   ✅ [PASS] Giảng viên tạo yêu cầu mở sổ điểm thành công! Mã đơn: {unlock_ticket_data['ticket_code']} (ID: {unlock_ticket_id})")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 7: Academic Staff views and approves grade unlock request
        # -----------------------------------------------------------------
        print("▶ [Test 7/14] Academic Staff xem và phê duyệt yêu cầu mở sổ điểm")
        res_staff_view = client.get(
            f"/api/v1/tickets/{unlock_ticket_id}",
            headers=auth_headers(staff_token)
        )
        assert res_staff_view.status_code == 200, f"Staff không xem được yêu cầu: {res_staff_view.text}"

        res_staff_approve = client.patch(
            f"/api/v1/tickets/{unlock_ticket_id}/status",
            headers=auth_headers(staff_token),
            json={
                "status": "APPROVED",
                "reason": "Chấp thuận mở sổ điểm trong vòng 48h để GV chỉnh sửa điểm."
            }
        )
        assert res_staff_approve.status_code == 200, f"Staff phê duyệt thất bại: {res_staff_approve.text}"
        assert res_staff_approve.json()["data"]["status"] == "APPROVED"

        # Verify grade lock state in DB is actually unlocked
        db.refresh(cls)
        assert cls.is_grade_unlocked is True, "Sổ điểm chưa được mở khóa trong cơ sở dữ liệu!"
        print("   ✅ [PASS] Academic Staff phê duyệt thành công, sổ điểm DB đã được mở khóa thực sự!")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 8: Admin views and rejects grade unlock request
        # -----------------------------------------------------------------
        print("▶ [Test 8/14] Admin xem và từ chối yêu cầu mở sổ điểm (bắt buộc lý do)")
        # Khóa lại sổ điểm để gửi yêu cầu thứ 2
        cls.is_grade_unlocked = False
        grade_rec.is_confirmed = True
        db.commit()

        res_unlock_2 = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(teacher_user_token),
            json={
                "ticket_type": "REQUEST",
                "category": "GRADE_UNLOCK",
                "related_class_id": cls.id,
                "title": f"Yêu cầu mở sổ điểm lần 2 lớp {cls.class_code}",
                "content": "Yêu cầu mở bổ sung."
            }
        )
        unlock_ticket_2_id = res_unlock_2.json()["data"]["id"]

        # Reject without reason -> Should fail 400
        res_reject_no_reason = client.patch(
            f"/api/v1/tickets/{unlock_ticket_2_id}/status",
            headers=auth_headers(admin_token),
            json={"status": "REJECTED"}
        )
        assert res_reject_no_reason.status_code == 400, "Từ chối không lý do phải trả về mã 400!"

        # Reject with reason -> Should succeed 200
        res_admin_reject = client.patch(
            f"/api/v1/tickets/{unlock_ticket_2_id}/status",
            headers=auth_headers(admin_token),
            json={
                "status": "REJECTED",
                "reason": "Đã quá thời hạn chỉnh sửa điểm cho phép của kỳ học."
            }
        )
        assert res_admin_reject.status_code == 200, f"Admin từ chối thất bại: {res_admin_reject.text}"
        assert res_admin_reject.json()["data"]["status"] == "REJECTED"
        print("   ✅ [PASS] Admin từ chối yêu cầu thành công với lý do bắt buộc.")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 9: Admin cannot view grade complaint detail via API
        # -----------------------------------------------------------------
        print("▶ [Test 9/14] Admin KHÔNG ĐƯỢC xem chi tiết khiếu nại điểm (403)")
        res_admin_view_complaint = client.get(
            f"/api/v1/tickets/{complaint_ticket_id}",
            headers=auth_headers(admin_token)
        )
        assert res_admin_view_complaint.status_code == 403, f"Kỳ vọng 403, nhận được {res_admin_view_complaint.status_code}"
        print(f"   ✅ [PASS] Admin bị chặn 403 chính xác: {res_admin_view_complaint.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 10: Academic Staff cannot view grade complaint detail via API
        # -----------------------------------------------------------------
        print("▶ [Test 10/14] Academic Staff KHÔNG ĐƯỢC xem chi tiết khiếu nại điểm (403)")
        res_staff_view_complaint = client.get(
            f"/api/v1/tickets/{complaint_ticket_id}",
            headers=auth_headers(staff_token)
        )
        assert res_staff_view_complaint.status_code == 403, f"Kỳ vọng 403, nhận được {res_staff_view_complaint.status_code}"
        print(f"   ✅ [PASS] Academic Staff bị chặn 403 chính xác: {res_staff_view_complaint.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 11: Admin cannot reply to grade complaint
        # -----------------------------------------------------------------
        print("▶ [Test 11/14] Admin KHÔNG ĐƯỢC gửi phản hồi vào khiếu nại điểm (403)")
        res_admin_reply = client.post(
            f"/api/v1/tickets/{complaint_ticket_id}/messages",
            headers=auth_headers(admin_token),
            json={"content": "Admin can thiệp vào đơn khiếu nại điểm."}
        )
        assert res_admin_reply.status_code == 403, f"Kỳ vọng 403, nhận được {res_admin_reply.status_code}"
        print(f"   ✅ [PASS] Admin can thiệp thảo luận bị chặn 403: {res_admin_reply.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 12: Academic Staff cannot resolve grade complaint
        # -----------------------------------------------------------------
        print("▶ [Test 12/14] Academic Staff KHÔNG ĐƯỢC giải quyết khiếu nại điểm (403)")
        res_staff_resolve = client.patch(
            f"/api/v1/tickets/{complaint_ticket_id}/status",
            headers=auth_headers(staff_token),
            json={"status": "RESOLVED", "reason": "Staff tự ý giải quyết khiếu nại điểm."}
        )
        assert res_staff_resolve.status_code == 403, f"Kỳ vọng 403, nhận được {res_staff_resolve.status_code}"
        print(f"   ✅ [PASS] Academic Staff giải quyết khiếu nại bị chặn 403: {res_staff_resolve.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 13: Admin and Academic Staff cannot create tickets via API
        # -----------------------------------------------------------------
        print("▶ [Test 13/14] Admin & Academic Staff KHÔNG ĐƯỢC tạo đơn mới (403)")
        res_admin_create = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(admin_token),
            json={
                "ticket_type": "REQUEST",
                "title": "Admin tự tạo đơn",
                "content": "Nội dung đơn thử nghiệm"
            }
        )
        assert res_admin_create.status_code == 403, f"Kỳ vọng Admin 403, nhận được {res_admin_create.status_code}"

        res_staff_create = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(staff_token),
            json={
                "ticket_type": "REQUEST",
                "title": "Staff tự tạo đơn",
                "content": "Nội dung đơn thử nghiệm"
            }
        )
        assert res_staff_create.status_code == 403, f"Kỳ vọng Staff 403, nhận được {res_staff_create.status_code}"
        print(f"   ✅ [PASS] Admin & Staff tạo đơn đều bị chặn 403 Forbidden: {res_admin_create.json().get('detail')}")
        passed_tests += 1

        # -----------------------------------------------------------------
        # TEST CASE 14: Student cannot send complaint directly to Admin or Staff
        # -----------------------------------------------------------------
        print("▶ [Test 14/14] Học viên KHÔNG ĐƯỢC gửi khiếu nại điểm trực tiếp cho Admin/Staff (400)")
        res_student_direct_admin = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(student_token),
            json={
                "ticket_type": "COMPLAINT",
                "category": "GRADE",
                "receiver_role": "ADMIN",
                "related_class_id": cls.id,
                "title": "Khiếu nại điểm gửi vượt cấp cho Admin",
                "content": "Em muốn khiếu nại trực tiếp lên Admin."
            }
        )
        assert res_student_direct_admin.status_code == 400, f"Kỳ vọng 400, nhận được {res_student_direct_admin.status_code}"

        res_student_direct_staff = client.post(
            "/api/v1/tickets/",
            headers=auth_headers(student_token),
            json={
                "ticket_type": "COMPLAINT",
                "category": "GRADE",
                "receiver_role": "ACADEMIC_STAFF",
                "related_class_id": cls.id,
                "title": "Khiếu nại điểm gửi vượt cấp cho Học vụ",
                "content": "Em muốn khiếu nại trực tiếp lên phòng Học vụ."
            }
        )
        assert res_student_direct_staff.status_code == 400, f"Kỳ vọng 400, nhận được {res_student_direct_staff.status_code}"
        print(f"   ✅ [PASS] Khiếu nại vượt cấp bị từ chối 400 Bad Request: {res_student_direct_admin.json().get('detail')}")
        passed_tests += 1

        print("\n==================================================================")
        print(f"🎉 TẤT CẢ {passed_tests}/{total_tests} TEST CASE RBAC ĐÃ VƯỢT QUA 100%!")
        print("==================================================================")

    finally:
        db.close()

if __name__ == "__main__":
    run_rbac_tests()
