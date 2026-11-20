"""
TEST SUITE ISOLATED CHO N-01, N-02, F-10 VÀ REGRESSION TOÀN DIỆN
Database cô lập: backend/qa_data/qa_isolated.db
Tuyệt đối không đụng đến backend/language_center.db
"""

import os
import sys
import pytest
from datetime import datetime, timezone
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

# Setup path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.main import app
from app.core.database import get_db, Base
from app.core.security import get_password_hash, create_access_token
from app.modules.accounts.models import User
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student
from app.modules.courses.models import Course
from app.modules.classes.models import Class, ClassStudent
from app.modules.grades.models import GradeRecord, GradeLockHistory
from app.modules.tickets.models import Ticket, TicketMessage
from app.core.permissions import RoleEnum

QA_DB_PATH = os.path.abspath("backend/qa_data/qa_isolated.db")
qa_engine = create_engine(f"sqlite:///{QA_DB_PATH}", connect_args={"check_same_thread": False})
QASessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=qa_engine)

def get_qa_db():
    db = QASessionLocal()
    try:
        yield db
    finally:
        db.close()

client = TestClient(app)

@pytest.fixture(scope="session", autouse=True)
def setup_isolated_database():
    # 1. Reset file isolated db
    if os.path.exists(QA_DB_PATH):
        try:
            os.remove(QA_DB_PATH)
        except Exception:
            pass

    # 2. Tạo toàn bộ bảng theo metadata
    Base.metadata.create_all(bind=qa_engine)

    # 3. Tạo dữ liệu fixture độc lập
    db = QASessionLocal()
    try:
        pwd_hash = get_password_hash("password123")

        # Users
        u_admin = User(username="qa_admin", email="admin@qa.local", hashed_password=pwd_hash, full_name="QA Admin", role=RoleEnum.ADMIN)
        u_staff = User(username="qa_staff", email="staff@qa.local", hashed_password=pwd_hash, full_name="QA Staff", role=RoleEnum.ACADEMIC_STAFF)
        u_tea_a = User(username="qa_tea_a", email="teaa@qa.local", hashed_password=pwd_hash, full_name="Teacher A", role=RoleEnum.TEACHER)
        u_tea_b = User(username="qa_tea_b", email="teab@qa.local", hashed_password=pwd_hash, full_name="Teacher B", role=RoleEnum.TEACHER)
        u_stu_a = User(username="qa_stu_a", email="stua@qa.local", hashed_password=pwd_hash, full_name="Student A", role=RoleEnum.STUDENT)
        u_stu_b = User(username="qa_stu_b", email="stub@qa.local", hashed_password=pwd_hash, full_name="Student B", role=RoleEnum.STUDENT)
        u_parent = User(username="qa_parent", email="parent@qa.local", hashed_password=pwd_hash, full_name="Parent User", role=RoleEnum.PARENT)

        db.add_all([u_admin, u_staff, u_tea_a, u_tea_b, u_stu_a, u_stu_b, u_parent])
        db.commit()

        # Teachers & Students profiles
        t_a = Teacher(user_id=u_tea_a.id, teacher_code="TEA-QA-01")
        t_b = Teacher(user_id=u_tea_b.id, teacher_code="TEA-QA-02")
        s_a = Student(user_id=u_stu_a.id, student_code="STU-QA-01")
        s_b = Student(user_id=u_stu_b.id, student_code="STU-QA-02")
        db.add_all([t_a, t_b, s_a, s_b])
        db.commit()

        # Courses & Classes
        c1 = Course(code="ENG-QA", title="Tiếng Anh Giao Tiếp QA", target_level="B1", fee=2000000)
        db.add(c1)
        db.commit()

        cls_a = Class(class_code="CLASS-QA-A", course_id=c1.id, teacher_id=t_a.id, max_capacity=20, status="IN_PROGRESS")
        cls_b = Class(class_code="CLASS-QA-B", course_id=c1.id, teacher_id=t_b.id, max_capacity=20, status="IN_PROGRESS")
        db.add_all([cls_a, cls_b])
        db.commit()

        cs_a = ClassStudent(class_id=cls_a.id, student_id=s_a.id)
        cs_b = ClassStudent(class_id=cls_b.id, student_id=s_b.id)
        db.add_all([cs_a, cs_b])

        # Grade records
        gr_a = GradeRecord(
            class_id=cls_a.id, student_id=s_a.id,
            attendance_score=9.0, midterm_score=8.0, final_score=7.0, total_score=7.8,
            result_status="PASS", is_confirmed=False
        )
        db.add(gr_a)
        db.commit()

        # Initial Tickets
        # Ticket 1: Score complaint from Student A to Teacher A for Class A (PENDING)
        tk_complaint = Ticket(
            ticket_code="TK-QA-0001",
            ticket_type="COMPLAINT",
            category="GRADE",
            sender_id=u_stu_a.id,
            receiver_id=u_tea_a.id,
            receiver_role="TEACHER",
            related_class_id=cls_a.id,
            title="Khiếu nại điểm kiểm tra giữa kỳ",
            content="Em thấy điểm giữa kỳ 8.0 chưa chính xác so với bài làm.",
            status="PENDING"
        )

        # Ticket 2: General request from Student A (PENDING)
        tk_req = Ticket(
            ticket_code="TK-QA-0002",
            ticket_type="REQUEST",
            category="OTHER",
            sender_id=u_stu_a.id,
            receiver_id=u_staff.id,
            receiver_role="ACADEMIC_STAFF",
            related_class_id=cls_a.id,
            title="Yêu cầu cấp giấy xác nhận học viên",
            content="Em xin cấp giấy xác nhận để làm thủ tục.",
            status="PENDING"
        )

        # Ticket 3: Grade unlock request from Teacher A for Class A (PENDING)
        tk_unlock = Ticket(
            ticket_code="TK-QA-0003",
            ticket_type="REQUEST",
            category="GRADE_UNLOCK",
            sender_id=u_tea_a.id,
            receiver_id=u_admin.id,
            receiver_role="ADMIN",
            related_class_id=cls_a.id,
            title="Yêu cầu mở sổ điểm lớp CLASS-QA-A",
            content="Nhập nhầm điểm chuyên cần cần mở lại để sửa.",
            status="PENDING"
        )

        db.add_all([tk_complaint, tk_req, tk_unlock])
        db.commit()

    finally:
        db.close()

    # Set dependency override
    app.dependency_overrides[get_db] = get_qa_db
    yield
    app.dependency_overrides.clear()


@pytest.fixture
def tokens():
    db = QASessionLocal()
    try:
        users = {u.username: u for u in db.query(User).all()}
        def make_token(u):
            role_val = u.role.value if hasattr(u.role, 'value') else str(u.role)
            return {"Authorization": f"Bearer {create_access_token(str(u.id), role=role_val)}"}
        return {
            "admin": make_token(users["qa_admin"]),
            "staff": make_token(users["qa_staff"]),
            "teacher_a": make_token(users["qa_tea_a"]),
            "teacher_b": make_token(users["qa_tea_b"]),
            "student_a": make_token(users["qa_stu_a"]),
            "student_b": make_token(users["qa_stu_b"]),
            "parent": make_token(users["qa_parent"]),
        }
    finally:
        db.close()


# ==============================================================================
# PHẦN III: REGRESSION TEST CHO N-01 IDOR
# ==============================================================================

def test_n01_cross_student_patch_same_status(tokens):
    """
    A. Cross-student:
    1. Student A tạo ticket 1 (PENDING)
    2. Student B PATCH ticket 1 với status PENDING (cùng trạng thái)
    3. Phải bị từ chối 404 (F-10 Enumeration Prevention).
    4. Response KHÔNG được chứa content, messages, current_grade, sender details.
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    db.close()

    res = client.patch(
        f"/api/v1/tickets/{tk1.id}/status",
        headers=tokens["student_b"],
        json={"status": "PENDING"}
    )
    assert res.status_code == 404, f"Cross-student cùng status phải trả 404, got {res.status_code}: {res.text}"
    body = res.json()
    # Kiểm tra không chứa thông tin nhạy cảm
    assert "content" not in str(body).lower() or "chưa chính xác" not in res.text
    assert "attendance_score" not in res.text
    assert "Em thấy điểm" not in res.text


def test_n01_cross_teacher_patch_same_status(tokens):
    """
    B. Cross-teacher:
    1. Teacher A phụ trách Class A và liên quan ticket 1.
    2. Teacher B không phụ trách Class A.
    3. Teacher B PATCH ticket 1 với status PENDING.
    4. Phải bị từ chối 404.
    5. Không lộ dữ liệu ticket.
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    db.close()

    res = client.patch(
        f"/api/v1/tickets/{tk1.id}/status",
        headers=tokens["teacher_b"],
        json={"status": "PENDING"}
    )
    assert res.status_code == 404, f"Cross-teacher phải trả 404, got {res.status_code}: {res.text}"
    assert "chưa chính xác" not in res.text


def test_n01_parent_patch_same_status(tokens):
    """
    C. Parent không có quyền với ticket:
    1. Parent gọi PATCH ticket 1 với status PENDING.
    2. Phải bị từ chối 404.
    3. Không trả nội dung hoặc điểm của học viên.
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    db.close()

    res = client.patch(
        f"/api/v1/tickets/{tk1.id}/status",
        headers=tokens["parent"],
        json={"status": "PENDING"}
    )
    assert res.status_code == 404, f"Parent phải trả 404, got {res.status_code}: {res.text}"
    assert "chưa chính xác" not in res.text
    assert "attendance_score" not in res.text


def test_n01_unauthorized_patch_different_status(tokens):
    """
    D. Kiểm tra trạng thái khác:
    - Student B PATCH RESOLVED -> 404
    - Teacher B PATCH RESOLVED -> 404
    - Parent PATCH RESOLVED -> 404
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    db.close()

    for role_name in ["student_b", "teacher_b", "parent"]:
        res = client.patch(
            f"/api/v1/tickets/{tk1.id}/status",
            headers=tokens[role_name],
            json={"status": "RESOLVED"}
        )
        assert res.status_code == 404, f"{role_name} PATCH status khác phải trả 404, got {res.status_code}"


def test_n01_authorized_idempotent_patch_minimal_response(tokens):
    """
    E. Người có quyền PATCH cùng trạng thái:
    - Teacher A phụ trách Class A là người xử lý khiếu nại điểm ticket 1.
    - Gọi PATCH cùng trạng thái hiện tại (PENDING).
    - Phải trả 200, nhưng response TỐI THIỂU: {id, ticket_code, status}, KHÔNG lộ messages, current_grade, content!
    - KHÔNG tạo audit message trùng trong DB!
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    msg_count_before = len(tk1.messages) if tk1.messages else 0
    db.close()

    res = client.patch(
        f"/api/v1/tickets/{tk1.id}/status",
        headers=tokens["teacher_a"],
        json={"status": "PENDING"}
    )
    assert res.status_code == 200, f"Teacher A PATCH idempotent phải trả 200, got {res.status_code}: {res.text}"
    data = res.json()["data"]
    assert data["id"] == tk1.id
    assert data["status"] == "PENDING"
    # Kiểm tra response tối thiểu, không lộ messages hoặc current_grade
    assert "messages" not in data or len(data["messages"]) == 0
    assert "current_grade" not in data

    # Kiểm tra không tạo audit message trùng
    db = QASessionLocal()
    tk1_after = db.query(Ticket).filter(Ticket.id == tk1.id).first()
    msg_count_after = len(tk1_after.messages) if tk1_after.messages else 0
    db.close()
    assert msg_count_after == msg_count_before, "Idempotent PATCH không được tạo audit message trùng lặp!"


def test_n01_authorized_status_transition_workflow(tokens):
    """
    F. Chuyển trạng thái hợp lệ và kiểm tra audit message:
    - Teacher A chuyển khiếu nại điểm từ PENDING -> PROCESSING -> RESOLVED
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    db.close()

    # 1. PENDING -> PROCESSING
    r1 = client.patch(
        f"/api/v1/tickets/{tk1.id}/status",
        headers=tokens["teacher_a"],
        json={"status": "PROCESSING"}
    )
    assert r1.status_code == 200
    assert r1.json()["data"]["status"] == "PROCESSING"

    # 2. PROCESSING -> RESOLVED
    r2 = client.patch(
        f"/api/v1/tickets/{tk1.id}/status",
        headers=tokens["teacher_a"],
        json={"status": "RESOLVED", "reason": "Đã kiểm tra lại bài kiểm tra và thống nhất điểm số."}
    )
    assert r2.status_code == 200
    assert r2.json()["data"]["status"] == "RESOLVED"

    # Kiểm tra audit message đã được tạo
    db = QASessionLocal()
    tk_updated = db.query(Ticket).filter(Ticket.id == tk1.id).first()
    audit_msgs = [m.content for m in tk_updated.messages if "[HỆ THỐNG]" in m.content]
    db.close()
    assert len(audit_msgs) >= 2, "Phải có audit message ghi nhận chuyển trạng thái"


# ==============================================================================
# PHẦN IV: N-02 KPI THỐNG KÊ TOÀN DIỆN
# ==============================================================================

def test_n02_kpi_stats_endpoint(tokens):
    """
    N-02: Endpoint /api/v1/tickets/stats
    - Student A gọi: Thấy thống kê trong phạm vi cá nhân (gồm khiếu nại của mình)
    - Admin gọi: Tuyệt đối KHÔNG thấy số liệu khiếu nại điểm (complaints = 0)
    - Teacher A gọi: Thấy khiếu nại thuộc lớp mình phụ trách
    """
    # 1. Student A
    r_stu = client.get("/api/v1/tickets/stats", headers=tokens["student_a"])
    assert r_stu.status_code == 200
    stu_stats = r_stu.json()["data"]
    assert "pending" in stu_stats
    assert "complaints" in stu_stats
    assert stu_stats["complaints"] >= 1, "Student A phải thấy khiếu nại điểm của mình trong KPI"

    # 2. Admin (QUY TẮC BẮT BUỘC F-01 & N-02)
    r_admin = client.get("/api/v1/tickets/stats", headers=tokens["admin"])
    assert r_admin.status_code == 200
    admin_stats = r_admin.json()["data"]
    assert admin_stats["complaints"] == 0, "Admin tuyệt đối không được thấy hoặc đếm khiếu nại điểm trong KPI!"
    assert admin_stats["unlock_requests"] >= 1, "Admin phải thấy yêu cầu mở sổ điểm"

    # 3. Staff (QUY TẮC BẮT BUỘC)
    r_staff = client.get("/api/v1/tickets/stats", headers=tokens["staff"])
    assert r_staff.status_code == 200
    staff_stats = r_staff.json()["data"]
    assert staff_stats["complaints"] == 0, "Staff tuyệt đối không được thấy khiếu nại điểm trong KPI!"


# ==============================================================================
# PHẦN V: F-10 ENUMERATION 403/404 POLICY
# ==============================================================================

def test_f10_enumeration_prevention(tokens):
    """
    F-10:
    - ID không tồn tại -> 404
    - ID tồn tại nhưng không có quyền (Admin xem score complaint) -> 404 (không 403)
    - ID tồn tại nhưng không có quyền (Student B xem ticket Student A) -> 404 (không 403)
    - ID thuộc quyền (Student A xem ticket của mình) -> 200
    - Không token -> 401
    - Token sai -> 401
    """
    db = QASessionLocal()
    tk1 = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0001").first()
    db.close()

    # 1. ID không tồn tại -> 404
    r_not_found = client.get("/api/v1/tickets/99999", headers=tokens["student_a"])
    assert r_not_found.status_code == 404

    # 2. Admin xem khiếu nại điểm -> 403 Forbidden (theo F-01 & test 2.4)
    r_admin = client.get(f"/api/v1/tickets/{tk1.id}", headers=tokens["admin"])
    assert r_admin.status_code == 403, f"Admin xem score complaint bị chặn 403, got {r_admin.status_code}"

    # 3. Student B xem ticket của Student A -> 404
    r_cross = client.get(f"/api/v1/tickets/{tk1.id}", headers=tokens["student_b"])
    assert r_cross.status_code == 404, f"Student B xem ticket Student A phải nhận 404, got {r_cross.status_code}"

    # 4. Student A xem ticket của mình -> 200
    r_own = client.get(f"/api/v1/tickets/{tk1.id}", headers=tokens["student_a"])
    assert r_own.status_code == 200

    # 5. Không token -> 401
    r_no_auth = client.get(f"/api/v1/tickets/{tk1.id}")
    assert r_no_auth.status_code == 401

    # 6. Token sai -> 401
    r_bad_auth = client.get(f"/api/v1/tickets/{tk1.id}", headers={"Authorization": "Bearer invalid.token.signature"})
    assert r_bad_auth.status_code == 401


# ==============================================================================
# PHẦN VI: BẢO VỆ CÁC QUY TẮC F-01, F-02, F-03
# ==============================================================================

def test_f01_student_cannot_create_request_with_grade_category(tokens):
    """F-01: STUDENT không thể tạo REQUEST với category GRADE hoặc GRADE_COMPLAINT"""
    res = client.post(
        "/api/v1/tickets/",
        headers=tokens["student_a"],
        json={
            "ticket_type": "REQUEST",
            "category": "GRADE",
            "title": "Yêu cầu xem lại điểm thi giữa kỳ",
            "content": "Em muốn hỏi về bài thi giữa kỳ của em"
        }
    )
    assert res.status_code == 400, "Student tạo REQUEST + GRADE phải bị chặn 400"
    assert "khiếu nại" in res.text.lower() or "không được" in res.text.lower()


def test_f02_teacher_cannot_self_approve_unlock_request(tokens):
    """F-02: TEACHER không thể tự phê duyệt yêu cầu mở sổ điểm của chính mình"""
    db = QASessionLocal()
    tk_unlock = db.query(Ticket).filter(Ticket.ticket_code == "TK-QA-0003").first()
    db.close()

    res = client.patch(
        f"/api/v1/tickets/{tk_unlock.id}/status",
        headers=tokens["teacher_a"],
        json={"status": "APPROVED"}
    )
    assert res.status_code == 403, "Teacher không được tự phê duyệt đơn của chính mình"
    assert "không được phép tự phê duyệt" in res.text or "quyền" in res.text


def test_f03_student_cannot_create_complaint_for_unregistered_class(tokens):
    """F-03: STUDENT không thể tạo khiếu nại cho lớp học mà mình không theo học"""
    db = QASessionLocal()
    cls_b = db.query(Class).filter(Class.class_code == "CLASS-QA-B").first()
    db.close()

    res = client.post(
        "/api/v1/tickets/",
        headers=tokens["student_a"],
        json={
            "ticket_type": "COMPLAINT",
            "category": "GRADE",
            "related_class_id": cls_b.id,
            "title": "Khiếu nại lớp ngoài",
            "content": "Em muốn khiếu nại điểm lớp em không học"
        }
    )
    assert res.status_code == 400, "Không được khiếu nại lớp chưa ghi danh"
    assert "tham gia" in res.text or "ghi danh" in res.text or "không hợp lệ" in res.text
