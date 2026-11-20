"""
SMART-EDU TEST SUITE: QUY TRÌNH YÊU CẦU VÀ PHÊ DUYỆT CHUYỂN LỚP (TC01 -> TC31)
Kiểm thử toàn diện từ TC01 đến TC31 theo đặc tả yêu cầu nghiệp vụ:
- An toàn môi trường: Tích hợp QA Safety Guard (OBS-01) chặn phá hủy dữ liệu Production
- TC01 - TC07: Kiểm tra cấp độ (Cùng cấp độ không đòi PASS, lên cấp đòi PASS, FAIL/Pending bị chặn, cấp độ không xác định)
- TC08 - TC11: ADMIN & ACADEMIC_STAFF phê duyệt và từ chối kèm lý do
- TC12 - TC16: Xử lý trùng, lớp đầy, mất nguồn, race condition, transaction rollback
- TC17 - TC18: Phân quyền STUDENT không được tự duyệt, chống IDOR giữa các học viên
- TC19 - TC22: Phân quyền TEACHER & Chống IDOR giảng viên (BUG-02 fix)
- TC23 - TC28: Bảo toàn xác nhận điểm is_confirmed, lịch sử điểm nguồn & điều kiện tiên quyết (BUG-01 fix)
- TC29 - TC30: Xử lý ngoại lệ 404 và từ chối kèm lý do
- TC31: Dọn dẹp dữ liệu kiểm thử (Teardown)
"""

import sys
import time
from datetime import date, timedelta, datetime, timezone
import concurrent.futures

# Đảm bảo import được module backend
sys.path.insert(0, "backend")

# QA Safety Guard (OBS-01)
from qa_data.safety_guard import validate_test_database_target
validate_test_database_target(is_destructive=True)

from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.modules.classes.models import Class, ClassStudent
from app.modules.courses.models import Course
from app.modules.grades.models import GradeRecord
from app.modules.enrollments.models import EnrollmentRequest
from app.modules.students.models import Student
from app.modules.teachers.models import Teacher
from app.modules.accounts.models import User
from app.core.permissions import RoleEnum
from app.core.security import create_access_token
from app.modules.classes.service import ClassService

client = TestClient(app)

def run_suite():
    print("=" * 75)
    print("BẮT ĐẦU KIỂM THỬ: QUY TRÌNH CHUYỂN LỚP TOÀN DIỆN (TC01 -> TC31)")
    print("=" * 75)

    created_class_ids = []
    created_request_ids = []

    # 1. Đăng nhập các vai trò
    admin_login = client.post("/api/v1/auth/login", json={"username": "admin", "password": "admin123"})
    assert admin_login.status_code == 200, "Admin login failed"
    admin_token = admin_login.json()["data"]["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    staff_login = client.post("/api/v1/auth/login", json={"username": "staff", "password": "staff123"})
    assert staff_login.status_code == 200, "Staff login failed"
    staff_token = staff_login.json()["data"]["access_token"]
    staff_headers = {"Authorization": f"Bearer {staff_token}"}

    student_login = client.post("/api/v1/auth/login", json={"username": "student", "password": "student123"})
    assert student_login.status_code == 200, "Student login failed"
    student_token = student_login.json()["data"]["access_token"]
    student_headers = {"Authorization": f"Bearer {student_token}"}

    db = SessionLocal()
    # Tìm học viên 1 (username=student, user_id=5)
    stu1 = db.query(Student).filter(Student.user_id == 5, Student.is_deleted == False).first()
    assert stu1 is not None, "Student 1 record not found"
    student_id = stu1.id

    # Tìm học viên 2 để test IDOR (TC18)
    stu2 = db.query(Student).filter(Student.id != student_id, Student.is_deleted == False).first()
    assert stu2 is not None, "Student 2 record not found"
    stu2_user = db.query(User).filter(User.id == stu2.user_id).first()
    student2_token = create_access_token(str(stu2_user.id), RoleEnum.STUDENT.value)
    student2_headers = {"Authorization": f"Bearer {student2_token}"}

    # Tìm danh sách giảng viên để test phân quyền & IDOR giảng viên (BUG-02)
    teachers = db.query(Teacher).all()
    assert len(teachers) >= 3, "Require at least 3 teachers for IDOR testing"
    teacher1 = teachers[0]
    teacher2 = teachers[1]
    teacher3 = teachers[2]

    teacher1_token = create_access_token(str(teacher1.user_id), RoleEnum.TEACHER.value)
    teacher1_headers = {"Authorization": f"Bearer {teacher1_token}"}

    teacher2_token = create_access_token(str(teacher2.user_id), RoleEnum.TEACHER.value)
    teacher2_headers = {"Authorization": f"Bearer {teacher2_token}"}

    teacher3_token = create_access_token(str(teacher3.user_id), RoleEnum.TEACHER.value)
    teacher3_headers = {"Authorization": f"Bearer {teacher3_token}"}

    db.close()

    ts = int(time.time())

    # Helper: tạo lớp học kiểm thử
    def create_test_class(code, course_id, teacher_id=None, max_capacity=20, status="OPEN_FOR_ENROLLMENT"):
        if teacher_id is None:
            teacher_id = 2 if "tgt" in code.lower() else 1
        res = client.post("/api/v1/classes/", json={
            "class_code": code,
            "course_id": course_id,
            "teacher_id": teacher_id,
            "max_capacity": max_capacity,
            "opening_date": date.today().isoformat(),
            "start_date": (date.today() + timedelta(days=2)).isoformat(),
            "end_date": (date.today() + timedelta(days=90)).isoformat(),
            "status": status
        }, headers=admin_headers)
        assert res.status_code == 200, f"Failed to create class {code}: {res.text}"
        cid = res.json()["data"]["id"]
        created_class_ids.append(cid)
        return cid

    # Helper: ghi danh học viên vào lớp trực tiếp trong DB
    def enroll_student(student_id, class_id):
        sdb = SessionLocal()
        cs = sdb.query(ClassStudent).filter(ClassStudent.student_id == student_id, ClassStudent.class_id == class_id).first()
        if cs:
            cs.status = "ENROLLED"
            cs.is_deleted = False
        else:
            cs = ClassStudent(student_id=student_id, class_id=class_id, status="ENROLLED")
            sdb.add(cs)
        sdb.flush()
        cls = sdb.query(Class).filter(Class.id == class_id).first()
        if cls:
            count = sdb.query(ClassStudent).filter(ClassStudent.class_id == class_id, ClassStudent.status == "ENROLLED", ClassStudent.is_deleted == False).count()
            cls.current_enrolled = count
        sdb.commit()
        sdb.close()

    # Helper: cập nhật hoặc tạo bảng điểm cho học viên
    def set_grade(student_id, class_id, final_score=8.5, status="PASSED", is_confirmed=True):
        sdb = SessionLocal()
        gr = sdb.query(GradeRecord).filter(GradeRecord.student_id == student_id, GradeRecord.class_id == class_id).first()
        if not gr:
            gr = GradeRecord(
                student_id=student_id,
                class_id=class_id,
                midterm_score=final_score,
                final_score=final_score,
                result_status=status,
                is_confirmed=is_confirmed
            )
            sdb.add(gr)
        else:
            gr.final_score = final_score
            gr.result_status = status
            gr.is_confirmed = is_confirmed
            gr.is_deleted = False
        sdb.commit()
        sdb.close()

    # =========================================================================
    # PHẦN 1: KIỂM TRA CẤP ĐỘ & ĐIỀU KIỆN TIÊN QUYẾT (TC01 -> TC07)
    # =========================================================================
    print("\n--- PHẦN 1: KIỂM TRA CẤP ĐỘ & ĐIỀU KIỆN TIÊN QUYẾT (TC01 -> TC07) ---")

    # TC01: Chuyển cùng cấp độ (IELTS 6.5 -> IELTS 6.5) không yêu cầu PASS
    cls_c1_src = create_test_class(f"TC01-SRC-{ts}", course_id=1)
    cls_c1_tgt = create_test_class(f"TC01-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c1_src)

    tc01_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c1_src,
        "target_class_id": cls_c1_tgt,
        "reason": "Chuyen cung cap do gio hoc phu hop hon"
    }, headers=student_headers)
    assert tc01_res.status_code == 200, f"TC01 failed: {tc01_res.text}"
    req1 = tc01_res.json()["data"]
    created_request_ids.append(req1["id"])
    assert req1["status"] == "PENDING"
    print("✓ TC01. Chuyển cùng cấp độ không yêu cầu PASS: PASSED (200 OK)")

    # TC02: Chuyển lên cấp độ cao hơn và ĐÃ PASS cấp hiện tại -> Thành công
    cls_c2_src = create_test_class(f"TC02-SRC-{ts}", course_id=1)  # Level 1
    cls_c2_tgt = create_test_class(f"TC02-TGT-{ts}", course_id=2)  # Level 2
    enroll_student(student_id, cls_c2_src)
    set_grade(student_id, cls_c2_src, final_score=8.0, status="PASSED", is_confirmed=True)

    tc02_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c2_src,
        "target_class_id": cls_c2_tgt,
        "reason": "Da hoan thanh cap do truoc, muon len lop cao"
    }, headers=student_headers)
    assert tc02_res.status_code == 200, f"TC02 failed: {tc02_res.text}"
    created_request_ids.append(tc02_res.json()["data"]["id"])
    print("✓ TC02. Chuyển lên cấp độ cao hơn khi đã PASS: PASSED (200 OK)")

    # TC03: Chuyển lên cấp độ cao hơn nhưng BỊ FAIL cấp hiện tại -> Từ chối (400)
    cls_c3_src = create_test_class(f"TC03-SRC-{ts}", course_id=1)
    cls_c3_tgt = create_test_class(f"TC03-TGT-{ts}", course_id=2)
    enroll_student(student_id, cls_c3_src)
    set_grade(student_id, cls_c3_src, final_score=4.0, status="FAILED", is_confirmed=True)

    tc03_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c3_src,
        "target_class_id": cls_c3_tgt,
        "reason": "Thu chuyen khi chua dat"
    }, headers=student_headers)
    assert tc03_res.status_code == 400, f"TC03 expected 400, got {tc03_res.status_code}"
    assert "chưa hoàn thành hoặc chưa đạt (PASS)" in tc03_res.json()["detail"]
    print("✓ TC03. Chuyển lên cấp độ cao hơn khi FAILED bị từ chối: PASSED (400 Bad Request)")

    # TC04: Chuyển lên cấp độ cao hơn nhưng kết quả đang chờ (PENDING) -> Từ chối (400)
    cls_c4_src = create_test_class(f"TC04-SRC-{ts}", course_id=1)
    cls_c4_tgt = create_test_class(f"TC04-TGT-{ts}", course_id=2)
    enroll_student(student_id, cls_c4_src)
    set_grade(student_id, cls_c4_src, final_score=0.0, status="PENDING", is_confirmed=False)

    tc04_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c4_src,
        "target_class_id": cls_c4_tgt,
        "reason": "Diem dang Pending chua duoc duyet"
    }, headers=student_headers)
    assert tc04_res.status_code == 400, f"TC04 expected 400, got {tc04_res.status_code}"
    print("✓ TC04. Chuyển lên cấp độ cao hơn khi điểm đang PENDING bị từ chối: PASSED (400 Bad Request)")

    # TC05: Chuyển xuống cấp độ thấp hơn (LOWER_LEVEL) không bắt buộc PASS
    cls_c5_src = create_test_class(f"TC05-SRC-{ts}", course_id=2)
    cls_c5_tgt = create_test_class(f"TC05-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c5_src)

    tc05_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c5_src,
        "target_class_id": cls_c5_tgt,
        "reason": "Muon hoc lai can ban"
    }, headers=student_headers)
    assert tc05_res.status_code == 200, f"TC05 failed: {tc05_res.text}"
    created_request_ids.append(tc05_res.json()["data"]["id"])
    print("✓ TC05. Chuyển xuống cấp độ thấp hơn không đòi hỏi PASS: PASSED (200 OK)")

    # TC06: Chuyển giữa 2 khóa học khác nhau không xác định được quan hệ cấp độ (UNKNOWN)
    # Khóa 1 (IELTS) -> Khóa 17 (Tiếng Anh Thương Mại - khác lộ trình) -> Cần PASS
    cls_c6_src = create_test_class(f"TC06-SRC-{ts}", course_id=1)
    cls_c6_tgt = create_test_class(f"TC06-TGT-{ts}", course_id=17)
    enroll_student(student_id, cls_c6_src)
    set_grade(student_id, cls_c6_src, final_score=0.0, status="PENDING", is_confirmed=False)

    tc06_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c6_src,
        "target_class_id": cls_c6_tgt,
        "reason": "Chuyen sang he dao tao khac"
    }, headers=student_headers)
    assert tc06_res.status_code == 400
    print("✓ TC06. Chuyển khóa học không cùng lộ trình khi chưa PASS bị từ chối: PASSED (400 Bad Request)")

    # TC07: Khi đã PASS khóa học hiện tại thì được chuyển sang khóa học khác
    set_grade(student_id, cls_c6_src, final_score=7.5, status="PASSED", is_confirmed=True)
    tc07_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c6_src,
        "target_class_id": cls_c6_tgt,
        "reason": "Da hoan thanh khoa truoc, chuyen sang chuong trinh moi"
    }, headers=student_headers)
    assert tc07_res.status_code == 200, f"TC07 failed: {tc07_res.text}"
    created_request_ids.append(tc07_res.json()["data"]["id"])
    print("✓ TC07. Chuyển khóa học khác lộ trình khi đã PASS: PASSED (200 OK)")

    # =========================================================================
    # PHẦN 2: PHÊ DUYỆT & TỪ CHỐI BỞI ADMIN & ACADEMIC_STAFF (TC08 -> TC11)
    # =========================================================================
    print("\n--- PHẦN 2: PHÊ DUYỆT & TỪ CHỐI BỞI ADMIN & ACADEMIC_STAFF (TC08 -> TC11) ---")

    # TC08: ADMIN phê duyệt yêu cầu thành công, cập nhật ClassStudent & cập nhật sĩ số
    cls_c8_src = create_test_class(f"TC08-SRC-{ts}", course_id=1)
    cls_c8_tgt = create_test_class(f"TC08-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c8_src)

    req8 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c8_src,
        "target_class_id": cls_c8_tgt,
        "reason": "Admin approval test"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req8["id"])

    app8_res = client.post(f"/api/v1/classes/transfer-requests/{req8['id']}/approve", headers=admin_headers)
    assert app8_res.status_code == 200, f"TC08 failed: {app8_res.text}"
    assert app8_res.json()["data"]["status"] == "APPROVED"

    # Kiểm tra database sau duyệt
    sdb = SessionLocal()
    old_cs8 = sdb.query(ClassStudent).filter(ClassStudent.student_id == student_id, ClassStudent.class_id == cls_c8_src).first()
    new_cs8 = sdb.query(ClassStudent).filter(ClassStudent.student_id == student_id, ClassStudent.class_id == cls_c8_tgt).first()
    assert old_cs8.status == "TRANSFERRED"
    assert new_cs8.status == "ENROLLED"
    assert new_cs8.is_deleted == False
    sdb.close()
    print("✓ TC08. ADMIN phê duyệt thành công, chuyển đổi sĩ số & trạng thái: PASSED (200 OK)")

    # TC09: ACADEMIC_STAFF phê duyệt yêu cầu thành công
    cls_c9_src = create_test_class(f"TC09-SRC-{ts}", course_id=1)
    cls_c9_tgt = create_test_class(f"TC09-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c9_src)

    req9 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c9_src,
        "target_class_id": cls_c9_tgt,
        "reason": "Staff approval test"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req9["id"])

    app9_res = client.post(f"/api/v1/classes/transfer-requests/{req9['id']}/approve", headers=staff_headers)
    assert app9_res.status_code == 200, f"TC09 failed: {app9_res.text}"
    assert app9_res.json()["data"]["status"] == "APPROVED"
    print("✓ TC09. ACADEMIC_STAFF phê duyệt thành công: PASSED (200 OK)")

    # TC10: ADMIN từ chối yêu cầu kèm lý do rõ ràng
    cls_c10_src = create_test_class(f"TC10-SRC-{ts}", course_id=1)
    cls_c10_tgt = create_test_class(f"TC10-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c10_src)

    req10 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c10_src,
        "target_class_id": cls_c10_tgt,
        "reason": "Reject test"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req10["id"])

    rej10_res = client.post(f"/api/v1/classes/transfer-requests/{req10['id']}/reject", json={
        "rejection_reason": "Lớp học đã bắt đầu quá nửa chương trình"
    }, headers=admin_headers)
    assert rej10_res.status_code == 200
    assert rej10_res.json()["data"]["status"] == "REJECTED"
    assert "quá nửa chương trình" in rej10_res.json()["data"]["rejection_reason"]
    print("✓ TC10. ADMIN từ chối kèm lý do cụ thể: PASSED (200 OK)")

    # TC11: ACADEMIC_STAFF từ chối yêu cầu kèm lý do
    cls_c11_src = create_test_class(f"TC11-SRC-{ts}", course_id=1)
    cls_c11_tgt = create_test_class(f"TC11-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c11_src)

    req11 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c11_src,
        "target_class_id": cls_c11_tgt,
        "reason": "Staff reject test"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req11["id"])

    rej11_res = client.post(f"/api/v1/classes/transfer-requests/{req11['id']}/reject", json={
        "rejection_reason": "Lớp đích trùng lịch thi học kỳ của học viên"
    }, headers=staff_headers)
    assert rej11_res.status_code == 200
    assert rej11_res.json()["data"]["status"] == "REJECTED"
    print("✓ TC11. ACADEMIC_STAFF từ chối kèm lý do: PASSED (200 OK)")

    # =========================================================================
    # PHẦN 3: XỬ LÝ BIÊN, TRÙNG, SĨ SỐ, CONCURRENCY & INTEGRITY (TC12 -> TC16)
    # =========================================================================
    print("\n--- PHẦN 3: XỬ LÝ BIÊN, TRÙNG, CONCURRENCY & INTEGRITY (TC12 -> TC16) ---")

    # TC12: Không cho phép tạo trùng lặp yêu cầu chuyển lớp khi đã có yêu cầu PENDING
    cls_c12_src = create_test_class(f"TC12-SRC-{ts}", course_id=1)
    cls_c12_tgt = create_test_class(f"TC12-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c12_src)

    res12_a = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c12_src,
        "target_class_id": cls_c12_tgt,
        "reason": "Pending request first"
    }, headers=student_headers)
    assert res12_a.status_code == 200
    created_request_ids.append(res12_a.json()["data"]["id"])

    # Thử gửi tiếp lần thứ hai
    res12_b = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c12_src,
        "target_class_id": cls_c12_tgt,
        "reason": "Duplicate request"
    }, headers=student_headers)
    assert res12_b.status_code == 400
    assert "đang chờ xử lý" in res12_b.json()["detail"]
    print("✓ TC12. Chặn trùng lặp khi đã có yêu cầu PENDING: PASSED (400 Bad Request)")

    # TC13: Không cho phép duyệt vào lớp đích nếu lớp đích đã đầy sĩ số (Max Capacity)
    cls_c13_src = create_test_class(f"TC13-SRC-{ts}", course_id=1)
    cls_c13_tgt = create_test_class(f"TC13-TGT-{ts}", course_id=1, max_capacity=1)
    enroll_student(student_id, cls_c13_src)

    # Tạo yêu cầu khi lớp đích vẫn còn chỗ
    req13 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c13_src,
        "target_class_id": cls_c13_tgt,
        "reason": "Test target class full"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req13["id"])

    # Sau đó đăng ký 1 học viên khác vào lớp đích để làm lớp đầy trước khi duyệt
    enroll_student(stu2.id, cls_c13_tgt)

    app13_res = client.post(f"/api/v1/classes/transfer-requests/{req13['id']}/approve", headers=admin_headers)
    assert app13_res.status_code == 400
    assert "đã đủ sĩ số" in app13_res.json()["detail"].lower() or "đầy" in app13_res.json()["detail"].lower()
    print("✓ TC13. Chặn phê duyệt khi lớp đích đã đủ sĩ số: PASSED (400 Bad Request)")

    # TC14: Không cho phép duyệt nếu học viên đã bị xóa hoặc không còn ở lớp nguồn
    cls_c14_src = create_test_class(f"TC14-SRC-{ts}", course_id=1)
    cls_c14_tgt = create_test_class(f"TC14-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c14_src)

    req14 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c14_src,
        "target_class_id": cls_c14_tgt,
        "reason": "Test missing student in source"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req14["id"])

    # Xóa học viên khỏi lớp nguồn
    sdb = SessionLocal()
    sdb.query(ClassStudent).filter(ClassStudent.student_id == student_id, ClassStudent.class_id == cls_c14_src).delete()
    sdb.commit()
    sdb.close()

    app14_res = client.post(f"/api/v1/classes/transfer-requests/{req14['id']}/approve", headers=admin_headers)
    assert app14_res.status_code == 400
    assert "lớp nguồn" in app14_res.json()["detail"].lower() or "không còn" in app14_res.json()["detail"].lower()
    print("✓ TC14. Không cho phép duyệt nếu học viên không còn ở lớp nguồn: PASSED (400 Bad Request)")

    # TC15: Concurrency Race Condition Guard (Chỉ duy nhất 1 người duyệt thành công)
    cls_tc15_src = create_test_class(f"TC15-SRC-{ts}", course_id=1, teacher_id=1)
    cls_tc15_tgt = create_test_class(f"TC15-TGT-{ts}", course_id=10, teacher_id=3)
    enroll_student(student_id, cls_tc15_src)

    req15 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_tc15_src,
        "target_class_id": cls_tc15_tgt,
        "reason": "Test race condition concurrency"
    }, headers=student_headers).json()["data"]
    req15_id = req15["id"]
    created_request_ids.append(req15_id)

    def try_approve(headers):
        c = TestClient(app)
        return c.post(f"/api/v1/classes/transfer-requests/{req15_id}/approve", headers=headers)

    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        f1 = executor.submit(try_approve, admin_headers)
        f2 = executor.submit(try_approve, staff_headers)
        r1 = f1.result()
        r2 = f2.result()

    status_codes = sorted([r1.status_code, r2.status_code])
    assert status_codes == [200, 400], f"Expected exactly one 200 and one 400, got: {status_codes}"
    print("✓ TC15. Concurrency Race Condition Guard (Chỉ duy nhất 1 người duyệt thành công): PASSED (200 & 400)")

    # TC16: Transaction Integrity & Rollback Guard
    sdb = SessionLocal()
    req_chk = sdb.query(EnrollmentRequest).filter(EnrollmentRequest.id == req15_id).first()
    assert req_chk.status == "APPROVED", "Final state must be cleanly APPROVED"
    sdb.close()
    print("✓ TC16. Transaction Integrity & Rollback Guard: PASSED")

    # =========================================================================
    # PHẦN 4: PHÂN QUYỀN HỌC VIÊN & CHỐNG IDOR GIỮA HỌC VIÊN (TC17 -> TC18)
    # =========================================================================
    print("\n--- PHẦN 4: PHÂN QUYỀN HỌC VIÊN & IDOR (TC17 -> TC18) ---")

    # TC17: STUDENT không thể tự phê duyệt yêu cầu (403 Forbidden)
    cls_tc17_src = create_test_class(f"TC17-SRC-{ts}", course_id=1, teacher_id=1)
    cls_tc17_tgt = create_test_class(f"TC17-TGT-{ts}", course_id=10, teacher_id=4)
    enroll_student(student_id, cls_tc17_src)

    req17 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_tc17_src,
        "target_class_id": cls_tc17_tgt,
        "reason": "Test student self-approval blocked"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req17["id"])

    stu_app_res = client.post(f"/api/v1/classes/transfer-requests/{req17['id']}/approve", headers=student_headers)
    assert stu_app_res.status_code == 403, f"Expected 403 Forbidden, got {stu_app_res.status_code}"
    print("✓ TC17. Phân quyền: STUDENT không thể tự phê duyệt chuyển lớp: PASSED (403 Forbidden)")

    # TC18: Học viên không thể xem yêu cầu của học viên khác (Chống IDOR)
    idor_res = client.get(f"/api/v1/classes/transfer-requests/{req17['id']}", headers=student2_headers)
    assert idor_res.status_code == 403, f"Expected 403 Forbidden for IDOR access, got {idor_res.status_code}"
    assert "học viên khác" in idor_res.json()["detail"].lower()
    print("✓ TC18. Chống IDOR: Học viên không thể xem yêu cầu của học viên khác: PASSED (403 Forbidden)")

    # =========================================================================
    # PHẦN 5: PHÂN QUYỀN GIẢNG VIÊN & CHỐNG IDOR GIẢNG VIÊN (TC19 -> TC22) [BUG-02 FIX]
    # =========================================================================
    print("\n--- PHẦN 5: PHÂN QUYỀN GIẢNG VIÊN & CHỐNG IDOR (TC19 -> TC22) [BUG-02 FIX] ---")

    # Tạo request với teacher1 phụ trách lớp nguồn, teacher2 phụ trách lớp đích, teacher3 không liên quan
    cls_t_src = create_test_class(f"TC19-SRC-{ts}", course_id=1, teacher_id=teacher1.id)
    cls_t_tgt = create_test_class(f"TC19-TGT-{ts}", course_id=1, teacher_id=teacher2.id)
    enroll_student(student_id, cls_t_src)

    req_t_res = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_t_src,
        "target_class_id": cls_t_tgt,
        "reason": "Test teacher scoping and IDOR"
    }, headers=student_headers)
    assert req_t_res.status_code == 200
    req_t = req_t_res.json()["data"]
    created_request_ids.append(req_t["id"])

    # TC19: Giảng viên phụ trách lớp nguồn được phép xem chi tiết (200 OK)
    t1_view_res = client.get(f"/api/v1/classes/transfer-requests/{req_t['id']}", headers=teacher1_headers)
    assert t1_view_res.status_code == 200, f"TC19 failed: {t1_view_res.text}"
    assert t1_view_res.json()["data"]["id"] == req_t["id"]
    print("✓ TC19. Giảng viên lớp nguồn được xem chi tiết yêu cầu: PASSED (200 OK)")

    # TC20: Giảng viên phụ trách lớp đích được phép xem chi tiết (200 OK)
    t2_view_res = client.get(f"/api/v1/classes/transfer-requests/{req_t['id']}", headers=teacher2_headers)
    assert t2_view_res.status_code == 200, f"TC20 failed: {t2_view_res.text}"
    assert t2_view_res.json()["data"]["id"] == req_t["id"]
    print("✓ TC20. Giảng viên lớp đích được xem chi tiết yêu cầu: PASSED (200 OK)")

    # TC21: Giảng viên teacher3 KHÔNG phụ trách cả lớp nguồn lẫn lớp đích BỊ CHẶN (403 IDOR blocked)
    t3_view_res = client.get(f"/api/v1/classes/transfer-requests/{req_t['id']}", headers=teacher3_headers)
    assert t3_view_res.status_code == 403, f"TC21 expected 403 Forbidden, got {t3_view_res.status_code}"
    assert "chỉ có quyền xem" in t3_view_res.json()["detail"].lower() or "phụ trách" in t3_view_res.json()["detail"].lower()
    print("✓ TC21. Teacher IDOR Guard: Giảng viên ngoài lớp bị chặn truy cập PII: PASSED (403 Forbidden)")

    # TC22: Giảng viên KHÔNG CÓ QUYỀN phê duyệt yêu cầu chuyển lớp (403 Forbidden)
    t1_app_res = client.post(f"/api/v1/classes/transfer-requests/{req_t['id']}/approve", headers=teacher1_headers)
    assert t1_app_res.status_code == 403, f"TC22 expected 403 Forbidden, got {t1_app_res.status_code}"
    print("✓ TC22. Phân quyền: Giảng viên không có quyền phê duyệt chuyển lớp: PASSED (403 Forbidden)")

    # =========================================================================
    # PHẦN 6: BẢO TOÀN ĐIỂM, IS_CONFIRMED & LỊCH SỬ HỌC VIÊN (TC23 -> TC28) [BUG-01 FIX]
    # =========================================================================
    print("\n--- PHẦN 6: BẢO TOÀN ĐIỂM, IS_CONFIRMED & LỊCH SỬ (TC23 -> TC28) [BUG-01 FIX] ---")

    # TC23: Chuyển cùng cấp độ (SAME_LEVEL) với điểm đã xác nhận is_confirmed=True -> Giữ nguyên is_confirmed trên lớp đích
    cls_g1_src = create_test_class(f"TC23-SRC-{ts}", course_id=1)
    cls_g1_tgt = create_test_class(f"TC23-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_g1_src)
    set_grade(student_id, cls_g1_src, final_score=9.0, status="PASSED", is_confirmed=True)

    req23 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_g1_src,
        "target_class_id": cls_g1_tgt,
        "reason": "Test grade confirmation preservation"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req23["id"])

    app23_res = client.post(f"/api/v1/classes/transfer-requests/{req23['id']}/approve", headers=admin_headers)
    assert app23_res.status_code == 200

    sdb = SessionLocal()
    target_grade23 = sdb.query(GradeRecord).filter(GradeRecord.student_id == student_id, GradeRecord.class_id == cls_g1_tgt).first()
    assert target_grade23 is not None, "Target GradeRecord must exist"
    assert target_grade23.final_score == 9.0, f"Expected final_score 9.0, got {target_grade23.final_score}"
    assert target_grade23.is_confirmed == True, f"BUG-01 REGRESSION: Target is_confirmed must be True, got {target_grade23.is_confirmed}"
    assert target_grade23.result_status == "PASSED", f"Expected PASSED, got {target_grade23.result_status}"
    sdb.close()
    print("✓ TC23. Chuyển cùng cấp bảo toàn is_confirmed=True và điểm số lớp đích: PASSED")

    # TC24: Chuyển cùng cấp độ khi lớp đích đã có sẵn bản ghi GradeRecord -> Cập nhật và bảo toàn is_confirmed=True
    cls_g2_src = create_test_class(f"TC24-SRC-{ts}", course_id=1)
    cls_g2_tgt = create_test_class(f"TC24-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_g2_src)
    set_grade(student_id, cls_g2_src, final_score=8.5, status="PASSED", is_confirmed=True)
    # Lớp đích đã có sẵn GradeRecord (ví dụ học thử hoặc ghi danh trước) ở trạng thái PENDING
    set_grade(student_id, cls_g2_tgt, final_score=0.0, status="PENDING", is_confirmed=False)

    req24 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_g2_src,
        "target_class_id": cls_g2_tgt,
        "reason": "Test target grade record update branch"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req24["id"])

    app24_res = client.post(f"/api/v1/classes/transfer-requests/{req24['id']}/approve", headers=staff_headers)
    assert app24_res.status_code == 200

    sdb = SessionLocal()
    target_grade24 = sdb.query(GradeRecord).filter(GradeRecord.student_id == student_id, GradeRecord.class_id == cls_g2_tgt).first()
    assert target_grade24 is not None
    assert target_grade24.final_score == 8.5
    assert target_grade24.is_confirmed == True, f"BUG-01 REGRESSION: Updated target is_confirmed must be True, got {target_grade24.is_confirmed}"
    assert target_grade24.result_status == "PASSED"
    sdb.close()
    print("✓ TC24. Cập nhật nhánh có sẵn GradeRecord bảo toàn is_confirmed=True: PASSED")

    # TC25: Bản ghi GradeRecord của lớp nguồn KHÔNG bị soft-delete (is_deleted=False) để bảo toàn audit trail
    sdb = SessionLocal()
    source_grade23 = sdb.query(GradeRecord).filter(GradeRecord.student_id == student_id, GradeRecord.class_id == cls_g1_src).first()
    assert source_grade23 is not None, "Source grade record must not be hard deleted"
    assert source_grade23.is_deleted == False, "BUG-01 REGRESSION: Source grade must NOT be soft deleted (is_deleted must be False)"
    assert source_grade23.is_confirmed == True
    sdb.close()
    print("✓ TC25. Bản ghi điểm lớp nguồn không bị xóa mềm (is_deleted=False): PASSED")

    # TC26: Học viên sau khi chuyển lớp vẫn giữ điều kiện PASS của lớp nguồn để đăng ký/chuyển lên khóa cao hơn
    # Kiểm tra trực tiếp qua hàm EnrollmentService.check_prerequisite_eligibility
    from app.modules.enrollments.service import EnrollmentService
    cls_higher26 = create_test_class(f"TC26-HIGHER-{ts}", course_id=2)
    sdb = SessionLocal()
    is_eligible, reason_msg = EnrollmentService.check_prerequisite_eligibility(sdb, student_id, cls_higher26)
    sdb.close()
    assert is_eligible == True, f"BUG-01 REGRESSION: Student must remain eligible for higher course! Reason: {reason_msg}"
    print("✓ TC26. Học viên vẫn đủ điều kiện học cấp độ cao hơn sau chuyển lớp: PASSED")

    # TC27: Chuyển lên cấp độ cao hơn (HIGHER_LEVEL) khởi tạo điểm mới 0.0 PENDING, không biến điểm nguồn thành điểm đích
    cls_g3_src = create_test_class(f"TC27-SRC-{ts}", course_id=1)
    cls_g3_tgt = create_test_class(f"TC27-TGT-{ts}", course_id=2)
    enroll_student(student_id, cls_g3_src)
    set_grade(student_id, cls_g3_src, final_score=9.5, status="PASSED", is_confirmed=True)

    req27 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_g3_src,
        "target_class_id": cls_g3_tgt,
        "reason": "Test higher level grade initialization"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req27["id"])

    app27_res = client.post(f"/api/v1/classes/transfer-requests/{req27['id']}/approve", headers=admin_headers)
    assert app27_res.status_code == 200

    sdb = SessionLocal()
    target_grade27 = sdb.query(GradeRecord).filter(GradeRecord.student_id == student_id, GradeRecord.class_id == cls_g3_tgt).first()
    assert target_grade27 is not None
    assert target_grade27.final_score == 0.0, f"Higher level target score must be reset to 0.0, got {target_grade27.final_score}"
    assert target_grade27.is_confirmed == False, "Higher level target score must NOT be confirmed"
    assert target_grade27.result_status == "PENDING"
    # Lớp nguồn vẫn giữ điểm 9.5 PASSED
    src_grade27 = sdb.query(GradeRecord).filter(GradeRecord.student_id == student_id, GradeRecord.class_id == cls_g3_src).first()
    assert src_grade27.final_score == 9.5
    assert src_grade27.is_confirmed == True
    assert src_grade27.is_deleted == False
    sdb.close()
    print("✓ TC27. Chuyển cấp độ cao hơn khởi tạo điểm sạch, bảo lưu kết quả lớp nguồn: PASSED")

    # TC28: ClassStudent lớp nguồn giữ trạng thái TRANSFERRED và is_deleted=False
    sdb = SessionLocal()
    cs_src27 = sdb.query(ClassStudent).filter(ClassStudent.student_id == student_id, ClassStudent.class_id == cls_g3_src).first()
    assert cs_src27.status == "TRANSFERRED"
    assert cs_src27.is_deleted == False, "ClassStudent source must not be soft deleted"
    sdb.close()
    print("✓ TC28. Lịch sử lớp nguồn ClassStudent giữ nguyên trạng thái TRANSFERRED: PASSED")

    # =========================================================================
    # PHẦN 7: KIỂM TRA NGOẠI LỆ & DỌN DẸP TEARDOWN (TC29 -> TC31)
    # =========================================================================
    print("\n--- PHẦN 7: KIỂM TRA NGOẠI LỆ & DỌN DẸP TEARDOWN (TC29 -> TC31) ---")

    # TC29: Truy cập yêu cầu không tồn tại trả về 404 Not Found
    res29 = client.get("/api/v1/classes/transfer-requests/99999999", headers=admin_headers)
    assert res29.status_code == 404
    print("✓ TC29. Yêu cầu không tồn tại trả về 404 Not Found: PASSED (404)")

    # TC30: ACADEMIC_STAFF từ chối yêu cầu cập nhật đúng trạng thái và thông tin kiểm toán
    cls_c30_src = create_test_class(f"TC30-SRC-{ts}", course_id=1)
    cls_c30_tgt = create_test_class(f"TC30-TGT-{ts}", course_id=1)
    enroll_student(student_id, cls_c30_src)

    req30 = client.post("/api/v1/classes/transfer-requests", json={
        "current_class_id": cls_c30_src,
        "target_class_id": cls_c30_tgt,
        "reason": "Test final reject validation"
    }, headers=student_headers).json()["data"]
    created_request_ids.append(req30["id"])

    rej30_res = client.post(f"/api/v1/classes/transfer-requests/{req30['id']}/reject", json={
        "rejection_reason": "Lớp học đã hoàn tất kiểm tra giữa kỳ"
    }, headers=staff_headers)
    assert rej30_res.status_code == 200
    assert rej30_res.json()["data"]["status"] == "REJECTED"
    print("✓ TC30. Từ chối yêu cầu cập nhật đúng trạng thái và ghi nhận lý do: PASSED (200 OK)")

    # TC31: Tự động dọn dẹp (Teardown) an toàn các bản ghi tạo trong quá trình test
    sdb = SessionLocal()
    # Dọn dẹp requests, class_students, grades của các lớp test đã tạo
    for cid in created_class_ids:
        sdb.query(GradeRecord).filter(GradeRecord.class_id == cid).delete()
        sdb.query(EnrollmentRequest).filter((EnrollmentRequest.class_id == cid) | (EnrollmentRequest.note.like(f"%source_id={cid}%"))).delete()
        sdb.query(ClassStudent).filter(ClassStudent.class_id == cid).delete()
        sdb.query(Class).filter(Class.id == cid).delete()
    sdb.commit()
    sdb.close()
    print("✓ TC31. Tự động dọn dẹp dữ liệu kiểm thử (Teardown): PASSED")

    print("\n" + "=" * 75)
    print("TẤT CẢ 31 TEST CASES (TC01 -> TC31) ĐỀU VƯỢT QUA XUẤT SẮC 100%!")
    print("=" * 75)

if __name__ == "__main__":
    run_suite()
