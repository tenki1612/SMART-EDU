import os
import shutil
import sys
import time
from pathlib import Path

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")
from datetime import date, timedelta, datetime
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

_BACKEND_DIR = Path(__file__).resolve().parent
ORIGINAL_DB_PATH = _BACKEND_DIR / "language_center.db"
TEST_DB_PATH = _BACKEND_DIR / "test_isolated.db"

# Create clean isolated copy of database for testing to ensure zero side-effects on dev DB
if TEST_DB_PATH.exists():
    try:
        TEST_DB_PATH.unlink()
    except Exception:
        pass
shutil.copyfile(ORIGINAL_DB_PATH, TEST_DB_PATH)

# Route entire backend configuration to the isolated database
os.environ["DATABASE_URL"] = f"sqlite:///{TEST_DB_PATH.as_posix()}"

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

test_engine = create_engine(
    f"sqlite:///{TEST_DB_PATH.as_posix()}",
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)

from app.core.database import get_db, engine as app_engine
from app.main import app

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

def _do_run_tests():
    client = TestClient(app)

    # 1. Health check
    res = client.get("/")
    assert res.status_code == 200, res.text
    print("✓ 1. Health check: PASSED")

    # 2. Login as admin
    login_res = client.post("/api/v1/auth/login", json={"username": "admin", "password": "admin123"})
    assert login_res.status_code == 200, login_res.text
    token = login_res.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✓ 2. Admin Login: PASSED")

    # 3. Get Courses
    courses_res = client.get("/api/v1/courses/", headers=headers)
    assert courses_res.status_code == 200
    courses = courses_res.json()["data"]
    print(f"✓ 3. Courses count: {len(courses)}: PASSED")

    # 4. Check schedule conflict detection
    sched_list = client.get("/api/v1/schedules/", headers=headers).json().get("data", [])
    seeded_date = sched_list[0]["session_date"] if sched_list else "2026-10-28"
    conflict_res = client.post("/api/v1/schedules/check-conflicts", json={
        "classroom_id": 1,
        "teacher_id": 1,
        "session_date": seeded_date,
        "start_time": "18:30",
        "end_time": "19:30"
    }, headers=headers)
    assert conflict_res.status_code == 200
    data = conflict_res.json()["data"]
    assert data["has_conflict"] is True
    print(f"✓ 4. Conflict Check API (Detected conflict): PASSED -> {data['message']}")

    # 5. Check Students & learning history
    students_res = client.get("/api/v1/students/", headers=headers)
    assert students_res.status_code == 200
    student_id = students_res.json()["data"][0]["id"]
    hist_res = client.get(f"/api/v1/students/{student_id}/history", headers=headers)
    assert hist_res.status_code == 200
    print(f"✓ 5. Student Learning History: PASSED (Enrolled classes: {len(hist_res.json()['data'])})")

    # 6. Check Parent Portal
    parent_login = client.post("/api/v1/auth/login", json={"username": "parent", "password": "parent123"})
    parent_token = parent_login.json()["data"]["access_token"]
    p_headers = {"Authorization": f"Bearer {parent_token}"}
    wards_res = client.get("/api/v1/progression/parent/my-wards", headers=p_headers)
    assert wards_res.status_code == 200
    print(f"✓ 6. Parent Portal (Wards found: {len(wards_res.json()['data'])}): PASSED")

    # 7. Check Teacher Grading Operations (Add, Save, Delete)
    teacher_login = client.post("/api/v1/auth/login", json={"username": "teacher", "password": "teacher123"})
    assert teacher_login.status_code == 200
    teacher_token = teacher_login.json()["data"]["access_token"]
    t_headers = {"Authorization": f"Bearer {teacher_token}"}

    # Add student to class 2 grading sheet
    add_grade_res = client.post("/api/v1/grades/classes/2/students", json={
        "student_id": 1,
        "attendance_score": 9.0,
        "midterm_score": 8.0,
        "final_score": 8.5
    }, headers=t_headers)
    assert add_grade_res.status_code == 200
    assert add_grade_res.json()["data"]["result_status"] == "PASSED"
    print("✓ 7.1. Teacher Add Student to Grade Sheet: PASSED")

    # Save grades batch
    save_grade_res = client.post("/api/v1/grades/batch", json={
        "class_id": 2,
        "grades": [{
            "student_id": 1,
            "attendance_score": 9.5,
            "midterm_score": 8.5,
            "final_score": 9.0
        }]
    }, headers=t_headers)
    assert save_grade_res.status_code == 200
    print("✓ 7.2. Teacher Save/Update Grades Batch: PASSED")

    # Delete student from grade sheet
    del_grade_res = client.delete("/api/v1/grades/classes/2/students/1", headers=t_headers)
    assert del_grade_res.status_code == 200
    print("✓ 7.3. Teacher Delete Student from Grade Sheet: PASSED")

    # 8. Staff Class & Classroom CRUD + Student Enrollment & Cancellation
    staff_login = client.post("/api/v1/auth/login", json={"username": "staff", "password": "staff123"})
    assert staff_login.status_code == 200
    staff_token = staff_login.json()["data"]["access_token"]
    staff_headers = {"Authorization": f"Bearer {staff_token}"}

    # Staff creates a new test class with unique code
    rand_suffix = int(time.time())
    cls_create_res = client.post("/api/v1/classes/", json={
        "class_code": f"TEST-CAN-{rand_suffix}",
        "course_id": 1,
        "max_capacity": 20
    }, headers=staff_headers)
    assert cls_create_res.status_code == 200
    test_cls_id = cls_create_res.json()["data"]["id"]

    # Student logs in and requests enrollment
    student_login = client.post("/api/v1/auth/login", json={"username": "student", "password": "student123"})
    assert student_login.status_code == 200
    student_token = student_login.json()["data"]["access_token"]
    s_headers = {"Authorization": f"Bearer {student_token}"}

    req_create = client.post("/api/v1/enrollments/", json={
        "class_id": test_cls_id,
        "note": "Kiểm thử đăng ký trực tiếp không chờ duyệt"
    }, headers=s_headers)
    assert req_create.status_code == 200
    req_id = req_create.json()["data"]["id"]
    assert req_create.json()["data"]["status"] == "APPROVED"
    print("✓ 8.1. Direct Student Enrollment (Req 3): PASSED (APPROVED)")

    # Student cancels the direct enrollment
    req_cancel = client.patch(f"/api/v1/enrollments/{req_id}/cancel", headers=s_headers)
    assert req_cancel.status_code == 200
    print("✓ 8.2. Student Enrollment Cancellation: PASSED")

    # Clean up test class
    del_cls = client.delete(f"/api/v1/classes/{test_cls_id}", headers=staff_headers)
    assert del_cls.status_code == 200

    # 9. Academic Staff & Schedule Session CRUD
    new_sess_date = (date.today() + timedelta(days=10)).isoformat()
    sess_create = client.post("/api/v1/schedules/", json={
        "class_id": 1,
        "classroom_id": 2,
        "teacher_id": 2,
        "session_date": new_sess_date,
        "start_time": "08:00",
        "end_time": "10:00",
        "slot_name": "Ca sáng (08:00 - 10:00)"
    }, headers=staff_headers)
    assert sess_create.status_code == 200
    new_sess_id = sess_create.json()["data"]["id"]

    # Staff updates the session
    sess_update = client.put(f"/api/v1/schedules/{new_sess_id}", json={
        "slot_name": "Ca sáng điều chỉnh (08:00 - 10:00)"
    }, headers=staff_headers)
    assert sess_update.status_code == 200

    # Staff deletes the session
    sess_delete = client.delete(f"/api/v1/schedules/{new_sess_id}", headers=staff_headers)
    assert sess_delete.status_code == 200
    print("✓ 9. Academic Staff Schedule Session (Create, Update, Delete): PASSED")

    # 10. Academic Staff Classroom CRUD
    room_create = client.post("/api/v1/classrooms/", json={
        "room_code": f"LAB-{rand_suffix}",
        "building": "Tòa nhà B",
        "capacity": 35,
        "status": "AVAILABLE"
    }, headers=staff_headers)
    assert room_create.status_code == 200
    new_room_id = room_create.json()["data"]["id"]

    room_update = client.put(f"/api/v1/classrooms/{new_room_id}", json={
        "capacity": 40
    }, headers=staff_headers)
    assert room_update.status_code == 200
    assert room_update.json()["data"]["capacity"] == 40

    room_delete = client.delete(f"/api/v1/classrooms/{new_room_id}", headers=staff_headers)
    assert room_delete.status_code == 200
    print("✓ 10. Academic Staff Classroom (Create, Update, Delete): PASSED")

    # 11. Strict RBAC Enforcement for Grades (Teacher-only mutations, Admin/Staff confirm/delete, Student/Parent Isolation)
    # 11.1 Admin & Staff forbidden from mutating grades directly via /batch
    admin_grade_attempt = client.post("/api/v1/grades/batch", json={
        "class_id": 1,
        "grades": [{"student_id": 1, "attendance_score": 10.0, "midterm_score": 10.0, "final_score": 10.0}]
    }, headers=headers)
    assert admin_grade_attempt.status_code == 403, f"Expected 403, got {admin_grade_attempt.status_code}"

    staff_grade_attempt = client.post("/api/v1/grades/batch", json={
        "class_id": 1,
        "grades": [{"student_id": 1, "attendance_score": 10.0, "midterm_score": 10.0, "final_score": 10.0}]
    }, headers=staff_headers)
    assert staff_grade_attempt.status_code == 403, f"Expected 403, got {staff_grade_attempt.status_code}"
    print("✓ 11.1. Admin & Staff Forbidden from Direct Grade Mutation: PASSED (403 Forbidden)")

    # 11.2 Admin/Staff can Confirm & Lock Grades
    staff_confirm_res = client.patch("/api/v1/grades/classes/1/confirm", headers=staff_headers)
    assert staff_confirm_res.status_code == 200
    print("✓ 11.2. Academic Staff Confirm & Lock Grade Sheet: PASSED")

    # 11.2a Teacher is strictly forbidden from unlocking grades
    teacher_unlock_attempt = client.patch("/api/v1/grades/classes/1/unlock", headers=t_headers)
    assert teacher_unlock_attempt.status_code == 403, f"Expected 403, got {teacher_unlock_attempt.status_code}"
    print("✓ 11.2a. Teacher Forbidden from Unlocking Grade Sheet: PASSED (403 Forbidden)")

    # 11.2b Teacher cannot save/modify grades while grade sheet is locked
    teacher_locked_attempt = client.post("/api/v1/grades/batch", json={
        "class_id": 1,
        "grades": [{"student_id": 1, "attendance_score": 9.0, "midterm_score": 9.0, "final_score": 9.0}]
    }, headers=t_headers)
    assert teacher_locked_attempt.status_code in (400, 422) or not teacher_locked_attempt.json().get("success", True)
    print("✓ 11.2b. Teacher Blocked from Modifying Locked Grade Sheet: PASSED")

    # 11.2c Teacher can only grade classes they teach (Forbidden from other teachers' classes)
    teacher2_login = client.post("/api/v1/auth/login", json={"username": "teacher2", "password": "teacher123"})
    assert teacher2_login.status_code == 200
    t2_token = teacher2_login.json()["data"]["access_token"]
    t2_headers = {"Authorization": f"Bearer {t2_token}"}
    # Teacher 2 (Cô Mai) attempts to grade Class 2 (taught by Thầy Nam)
    t2_unauthorized_attempt = client.post("/api/v1/grades/batch", json={
        "class_id": 2,
        "grades": [{"student_id": 1, "attendance_score": 9.0, "midterm_score": 9.0, "final_score": 9.0}]
    }, headers=t2_headers)
    assert t2_unauthorized_attempt.status_code == 403, f"Expected 403, got {t2_unauthorized_attempt.status_code}"
    print("✓ 11.2c. Teacher Forbidden from Grading Other Teachers' Classes: PASSED (403 Forbidden)")

    # 11.2d Academic Staff or Admin can unlock the grade sheet
    staff_unlock_res = client.patch("/api/v1/grades/classes/1/unlock", headers=staff_headers)
    assert staff_unlock_res.status_code == 200
    print("✓ 11.2d. Academic Staff Successfully Unlocks Grade Sheet: PASSED")

    # 11.3 Student can only view their own grades
    student_grades_res = client.get("/api/v1/grades/my-grades", headers=s_headers)
    assert student_grades_res.status_code == 200
    print("✓ 11.3. Student Personal Grade Isolation (/my-grades): PASSED")

    # 11.4 Parent can view ward grades but cannot view non-ward
    parent_ward_grades = client.get("/api/v1/progression/parent/wards/1/grades", headers=p_headers)
    assert parent_ward_grades.status_code == 200
    print("✓ 11.4. Parent Ward Grade Access: PASSED")

    parent_unauth_ward = client.get("/api/v1/progression/parent/wards/999/grades", headers=p_headers)
    assert parent_unauth_ward.status_code in (403, 404)
    print("✓ 11.5. Parent Unauthorized Ward Access Blocked: PASSED (403/404)")

    # 12. Security & Lockout: Failed Password Attempts (5 times) & Forgot/Reset Password
    # 12.1 Create a temporary test account for lockout testing
    test_user_name = f"locktest_{rand_suffix}"
    create_test_user = client.post("/api/v1/accounts/", json={
        "username": test_user_name,
        "email": f"locktest_{rand_suffix}@smartedu.edu.vn",
        "full_name": "Kiểm Thử Khóa Đăng Nhập",
        "password": "Password123",
        "role": "STUDENT"
    }, headers=headers)
    assert create_test_user.status_code == 200

    # 12.2 Wrong password attempts 1 to 4 should return warning with remaining attempts
    for attempt in range(1, 5):
        bad_login = client.post("/api/v1/auth/login", json={
            "username": test_user_name,
            "password": "WrongPassword999"
        })
        assert bad_login.status_code == 400
        assert "còn" in bad_login.json()["detail"].lower()
    print("✓ 12.1. Failed Password Warning with Remaining Attempts (1-4): PASSED")

    # 12.3 5th wrong password attempt should trigger temporary lockout
    fifth_attempt = client.post("/api/v1/auth/login", json={
        "username": test_user_name,
        "password": "WrongPassword999"
    })
    assert fifth_attempt.status_code == 400
    assert "khóa tạm thời" in fifth_attempt.json()["detail"].lower()
    print("✓ 12.2. Account Temporary Lockout Triggered on 5th Attempt: PASSED")

    # 12.4 Login with correct password while locked should be blocked
    locked_attempt = client.post("/api/v1/auth/login", json={
        "username": test_user_name,
        "password": "Password123"
    })
    assert locked_attempt.status_code == 400
    assert "khóa tạm thời" in locked_attempt.json()["detail"].lower()
    print("✓ 12.3. Prevent Login While Account is Temporarily Locked: PASSED")

    # 12.5 Request Forgot Password OTP
    forgot_res = client.post("/api/v1/auth/forgot-password", json={
        "identifier": test_user_name
    })
    assert forgot_res.status_code == 200
    # SECURITY: OTP must never be returned in the HTTP response.
    # Simulate out-of-band delivery (email/inbox) by reading it from the DB.
    from app.core.database import SessionLocal
    from app.models import User as _User
    assert "reset_code" not in forgot_res.json()["data"], "OTP leaked in HTTP response!"
    _otp_db = SessionLocal()
    try:
        otp_code = _otp_db.query(_User.reset_token).filter(_User.username == test_user_name).scalar()
    finally:
        _otp_db.close()
    assert otp_code and len(otp_code) == 6
    print(f"✓ 12.4. Forgot Password OTP Request: PASSED (OTP: {otp_code})")

    # 12.6 Reset Password with OTP & Unlock Account
    reset_res = client.post("/api/v1/auth/reset-password", json={
        "identifier": test_user_name,
        "reset_code": otp_code,
        "new_password": "NewSecretPassword888"
    })
    assert reset_res.status_code == 200
    print("✓ 12.5. Reset Password & Unlock Account with OTP: PASSED")

    # 12.7 Login with newly reset password succeeds
    success_login = client.post("/api/v1/auth/login", json={
        "username": test_user_name,
        "password": "NewSecretPassword888"
    })
    assert success_login.status_code == 200
    assert "access_token" in success_login.json()["data"]
    print("✓ 12.6. Login with New Password after Reset: PASSED")

    # ================= 13. ADMIN ROLE ELEVATION & ACCOUNT LOCKING RBAC =================
    # Create a fresh target account for testing admin controls
    managed_user_name = f"user_manage_{int(datetime.now().timestamp())}"
    create_target = client.post("/api/v1/accounts/", json={
        "username": managed_user_name,
        "email": f"{managed_user_name}@center.edu.vn",
        "full_name": "Nguyễn Quản Trị Mục Tiêu",
        "password": "TargetPassword123",
        "role": "STUDENT",
        "phone": "0988776655"
    }, headers=headers)
    assert create_target.status_code == 200
    managed_user_id = create_target.json()["data"]["id"]

    # 13.1. Admin promotes user from STUDENT to TEACHER
    promote_res = client.patch(f"/api/v1/accounts/{managed_user_id}/role", json={
        "role": "TEACHER"
    }, headers=headers)
    assert promote_res.status_code == 200
    assert promote_res.json()["data"]["role"] == "TEACHER"
    print("✓ 13.1. Admin Role Elevation (STUDENT -> TEACHER): PASSED")

    # 13.2. Academic Staff cannot promote role (Strict 403 Forbidden)
    staff_promote_res = client.patch(f"/api/v1/accounts/{managed_user_id}/role", json={
        "role": "ADMIN"
    }, headers=staff_headers)
    assert staff_promote_res.status_code == 403
    print("✓ 13.2. Academic Staff Forbidden from Role Elevation: PASSED (403 Forbidden)")

    # 13.3. Admin Locks the Account
    lock_res = client.patch(f"/api/v1/accounts/{managed_user_id}/toggle-lock", headers=headers)
    assert lock_res.status_code == 200
    assert lock_res.json()["data"]["is_active"] is False
    print("✓ 13.3. Admin Locks Account via Toggle Lock: PASSED")

    # 13.4. Locked User Cannot Login
    locked_user_login = client.post("/api/v1/auth/login", json={
        "username": managed_user_name,
        "password": "TargetPassword123"
    })
    assert locked_user_login.status_code == 400
    assert "khóa" in locked_user_login.json()["detail"].lower() or "vô hiệu hóa" in locked_user_login.json()["detail"].lower()
    print("✓ 13.4. Locked Account Login Denied: PASSED")

    # 13.5. Admin Unlocks the Account
    unlock_res = client.patch(f"/api/v1/accounts/{managed_user_id}/toggle-lock", headers=headers)
    assert unlock_res.status_code == 200
    assert unlock_res.json()["data"]["is_active"] is True
    print("✓ 13.5. Admin Unlocks Account via Toggle Lock: PASSED")

    # 13.6. Admin Resets User Password
    admin_reset_res = client.post(f"/api/v1/accounts/{managed_user_id}/reset-password", json={
        "new_password": "AdminAssignedPass999!"
    }, headers=headers)
    assert admin_reset_res.status_code == 200
    print("✓ 13.6. Admin Password Reset: PASSED")

    # 13.7. User Logs In with Admin-Reset Password
    admin_reset_login = client.post("/api/v1/auth/login", json={
        "username": managed_user_name,
        "password": "AdminAssignedPass999!"
    })
    assert admin_reset_login.status_code == 200
    assert "access_token" in admin_reset_login.json()["data"]
    print("✓ 13.7. Login with Admin-Reset Password: PASSED")

    # ================= 14. AUTHENTICATION ERROR DIFFERENTIATION & REGISTRATION =================
    # 14.1. Account Not Found returns explicit error
    not_found_login = client.post("/api/v1/auth/login", json={
        "username": f"nonexistent_{int(time.time())}",
        "password": "Password123"
    })
    assert not_found_login.status_code == 400
    assert "không tồn tại" in not_found_login.json()["detail"].lower()
    print("✓ 14.1. Account Not Found Login Returns Explicit Error: PASSED")

    # 14.2. Soft-deleted Account Login returns explicit error
    # Delete managed user
    del_res = client.delete(f"/api/v1/accounts/{managed_user_id}", headers=headers)
    assert del_res.status_code == 200
    deleted_login = client.post("/api/v1/auth/login", json={
        "username": managed_user_name,
        "password": "AdminAssignedPass999!"
    })
    assert deleted_login.status_code == 400
    assert "bị xóa" in deleted_login.json()["detail"].lower()
    print("✓ 14.2. Deleted Account Login Returns Explicit Error: PASSED")

    # 14.3. Student Self-Registration via POST /auth/register
    reg_username = f"new_student_{int(time.time())}"
    reg_email = f"{reg_username}@student.edu.vn"
    reg_res = client.post("/api/v1/auth/register", json={
        "username": reg_username,
        "email": reg_email,
        "full_name": "Học Viên Mới Đăng Ký",
        "password": "RegisterPass123",
        "phone": "0987654321",
        "role": "STUDENT"
    })
    assert reg_res.status_code == 200
    assert "access_token" in reg_res.json()["data"]
    assert reg_res.json()["data"]["role"] == "STUDENT"
    print("✓ 14.3. Student Self-Registration: PASSED")

    # 14.4. Duplicate Registration Blocked
    dup_reg_res = client.post("/api/v1/auth/register", json={
        "username": reg_username,
        "email": reg_email,
        "full_name": "Học Viên Trùng Lặp",
        "password": "RegisterPass123"
    })
    assert dup_reg_res.status_code == 400
    assert "đã được sử dụng" in dup_reg_res.json()["detail"].lower()
    print("✓ 14.4. Duplicate Registration Blocked: PASSED")

    # 14.5. Login with Newly Registered Account
    new_student_login = client.post("/api/v1/auth/login", json={
        "username": reg_username,
        "password": "RegisterPass123"
    })
    assert new_student_login.status_code == 200
    assert "access_token" in new_student_login.json()["data"]
    print("✓ 14.5. Newly Registered Student Login: PASSED")

    # ================= 15. AVATAR & PROFILE MANAGEMENT =================
    # 15.1. Update avatar via preset URL
    preset_avatar = "https://api.dicebear.com/7.x/adventurer/svg?seed=Felix"
    avatar_url_res = client.patch("/api/v1/accounts/me/avatar", json={
        "avatar_url": preset_avatar
    }, headers=headers)
    assert avatar_url_res.status_code == 200
    assert avatar_url_res.json()["data"]["avatar_url"] == preset_avatar
    print("✓ 15.1. Update Avatar via URL/Preset: PASSED")

    # 15.2. Upload avatar image file
    fake_png = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15c4\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82"
    upload_res = client.post(
        "/api/v1/accounts/me/avatar/upload",
        files={"file": ("test_avatar.png", fake_png, "image/png")},
        headers=headers
    )
    assert upload_res.status_code == 200
    uploaded_url = upload_res.json()["data"]["avatar_url"]
    assert "uploads/avatars/avatar_" in uploaded_url
    print("✓ 15.2. Upload Avatar Image File: PASSED")

    # 15.3. Update profile personal info
    update_prof_res = client.put("/api/v1/accounts/me", json={
        "full_name": "Nguyễn Văn Quản Trị Cập Nhật",
        "phone": "0999888777",
        "email": "admin_updated@center.edu.vn"
    }, headers=headers)
    assert update_prof_res.status_code == 200
    assert update_prof_res.json()["data"]["full_name"] == "Nguyễn Văn Quản Trị Cập Nhật"
    print("✓ 15.3. Update Personal Profile Info: PASSED")

    # 15.4. Remove avatar
    del_avatar_res = client.delete("/api/v1/accounts/me/avatar", headers=headers)
    assert del_avatar_res.status_code == 200
    assert del_avatar_res.json()["data"]["avatar_url"] is None
    print("✓ 15.4. Remove Avatar & Reset: PASSED")

    # ================= 16. RELATED STUDENTS BY ACCOUNT ROLE =================
    # 16.1. Get related students for Parent
    parent_related = client.get("/api/v1/accounts/5/related-students", headers=headers)
    assert parent_related.status_code == 200
    assert len(parent_related.json()["data"]) >= 1
    print("✓ 16.1. Get Related Students for Parent: PASSED")

    # 16.2. Get related students for Student
    student_related = client.get("/api/v1/accounts/3/related-students", headers=headers)
    assert student_related.status_code == 200
    assert len(student_related.json()["data"]) >= 1
    print("✓ 16.2. Get Related Students for Student: PASSED")

    # ================= 17. STUDENT ISOLATION: CLASSES, COURSES & ROSTER PRIVACY =================
    # 17.1. Student login
    st_login = client.post("/api/v1/auth/login", json={"username": "student", "password": "student123"})
    assert st_login.status_code == 200
    st_token = st_login.json()["data"]["access_token"]
    st_headers = {"Authorization": f"Bearer {st_token}"}

    # 17.2. Student can only see classes they are enrolled in
    st_classes = client.get("/api/v1/classes/", headers=st_headers)
    assert st_classes.status_code == 200
    st_cls_data = st_classes.json()["data"]
    # Seeded student is enrolled in exactly 1 class (IELTS-65-K26A)
    assert len(st_cls_data) == 1
    assert st_cls_data[0]["class_code"] == "IELTS-65-K26A"
    print("✓ 17.1. Student Class View Isolation: PASSED (Only enrolled classes returned)")

    # 17.3. Student can only see courses they are taking
    st_courses = client.get("/api/v1/courses/", headers=st_headers)
    assert st_courses.status_code == 200
    st_cou_data = st_courses.json()["data"]
    assert len(st_cou_data) == 1
    assert st_cou_data[0]["code"] in ["IELTS-PREP-65", "IELTS-65"]
    print("✓ 17.2. Student Course View Isolation: PASSED (Only enrolled courses returned)")

    # 17.4. Student forbidden from viewing class roster
    st_roster = client.get("/api/v1/classes/1/students", headers=st_headers)
    assert st_roster.status_code == 403
    print("✓ 17.3. Student Class Roster Blocked: PASSED (403 Forbidden)")

    # ================= 18. TEACHER SCHEDULE & TIMETABLE ISOLATION =================
    # 18.1. Teacher 1 only sees their own schedule/teaching timetable
    t1_schedules_res = client.get("/api/v1/schedules/", headers=t_headers)
    assert t1_schedules_res.status_code == 200
    t1_sessions = t1_schedules_res.json()["data"]
    assert len(t1_sessions) > 0
    # Every session returned must belong to teacher 1
    for sess in t1_sessions:
        assert sess["teacher_id"] == 1, f"Expected teacher_id 1, got {sess['teacher_id']}"
    print(f"✓ 18.1. Teacher 1 Schedule Isolation ({len(t1_sessions)} teaching sessions): PASSED")

    # 18.2. Teacher 2 only sees their own schedule
    t2_schedules_res = client.get("/api/v1/schedules/", headers=t2_headers)
    assert t2_schedules_res.status_code == 200
    t2_sessions = t2_schedules_res.json()["data"]
    assert len(t2_sessions) > 0
    for sess in t2_sessions:
        assert sess["teacher_id"] == 2, f"Expected teacher_id 2, got {sess['teacher_id']}"
    print(f"✓ 18.2. Teacher 2 Schedule Isolation ({len(t2_sessions)} teaching sessions): PASSED")

    # 18.3. Admin sees all teaching schedules across all teachers
    admin_schedules_res = client.get("/api/v1/schedules/", headers=headers)
    assert admin_schedules_res.status_code == 200
    all_sessions = admin_schedules_res.json()["data"]
    assert len(all_sessions) > len(t1_sessions) + len(t2_sessions)
    print(f"✓ 18.3. Admin Full Schedule Access ({len(all_sessions)} total sessions): PASSED")

    # ================= 19. MANDATORY COURSE PROGRESSION BEFORE CLASS ENROLLMENT =================
    # 19.1. Staff creates a class belonging to course 3 (TOEIC 750)
    rand_prog = int(time.time())
    new_toeic_res = client.post("/api/v1/classes/", json={
        "class_code": f"TOEIC-750-T{rand_prog}",
        "course_id": 3,
        "max_capacity": 20
    }, headers=staff_headers)
    assert new_toeic_res.status_code == 200
    new_toeic_cls_id = new_toeic_res.json()["data"]["id"]

    # 19.2. Direct Class Enrollment into Course 3 class succeeds without approval (Req 3)
    direct_enroll = client.post("/api/v1/enrollments/", json={
        "class_id": new_toeic_cls_id,
        "note": "Ghi danh trực tiếp không cần duyệt chuyển khóa"
    }, headers=s_headers)
    assert direct_enroll.status_code == 200
    enroll_id = direct_enroll.json()["data"]["id"]
    assert direct_enroll.json()["data"]["status"] == "APPROVED"
    print("✓ 19.1. Direct Class Enrollment Without Approval Requirement: PASSED (200 OK, APPROVED)")

    # Cancel enrollment so student is not currently studying Course 3
    client.patch(f"/api/v1/enrollments/{enroll_id}/cancel", headers=s_headers)

    # 19.3. Student submits Course Progression (direct progression)
    prog_req_res = client.post("/api/v1/progression/request", json={
        "next_course_id": 3,
        "note": "Học viên đăng ký chuyển từ IELTS sang TOEIC 750"
    }, headers=s_headers)
    assert prog_req_res.status_code == 200
    prog_data = prog_req_res.json()["data"]
    prog_id = prog_data["id"]
    print("✓ 19.2. Student Submit Course Progression Record: PASSED")

    # 19.4. Clean up test data
    client.delete(f"/api/v1/classes/{new_toeic_cls_id}", headers=staff_headers)
    client.delete(f"/api/v1/progression/{prog_id}", headers=staff_headers)
    print("✓ 19.3. Clean up Progression Test Class, Progression & Enrollment: PASSED")

    # ================= 20. TEACHER CLASS & GRADE ISOLATION =================
    # 20.1. Teacher 1 listing classes only returns classes taught by Teacher 1
    t1_classes_res = client.get("/api/v1/classes/", headers=t_headers)
    assert t1_classes_res.status_code == 200
    t1_classes = t1_classes_res.json()["data"]
    assert len(t1_classes) > 0
    for c in t1_classes:
        assert c["teacher_id"] == 1, f"Expected teacher_id 1, got {c['teacher_id']}"
    print(f"✓ 20.1. Teacher 1 Class List Isolation ({len(t1_classes)} classes): PASSED")

    # 20.2. Teacher 2 listing classes only returns classes taught by Teacher 2
    t2_classes_res = client.get("/api/v1/classes/", headers=t2_headers)
    assert t2_classes_res.status_code == 200
    t2_classes = t2_classes_res.json()["data"]
    assert len(t2_classes) > 0
    for c in t2_classes:
        assert c["teacher_id"] == 2, f"Expected teacher_id 2, got {c['teacher_id']}"
    print(f"✓ 20.2. Teacher 2 Class List Isolation ({len(t2_classes)} classes): PASSED")

    # 20.3. Teacher 2 forbidden from viewing Teacher 1 class details
    t1_cls_id = t1_classes[0]["id"]
    t2_cls_detail = client.get(f"/api/v1/classes/{t1_cls_id}", headers=t2_headers)
    assert t2_cls_detail.status_code == 403, f"Expected 403, got {t2_cls_detail.status_code}"
    print("✓ 20.3. Teacher Blocked from Viewing Other Teacher's Class Detail: PASSED (403 Forbidden)")

    # 20.4. Teacher 2 forbidden from viewing Teacher 1 class student roster
    t2_cls_roster = client.get(f"/api/v1/classes/{t1_cls_id}/students", headers=t2_headers)
    assert t2_cls_roster.status_code == 403, f"Expected 403, got {t2_cls_roster.status_code}"
    print("✓ 20.4. Teacher Blocked from Viewing Other Teacher's Class Roster: PASSED (403 Forbidden)")

    # 20.5. Teacher 2 forbidden from viewing Teacher 1 class grading sheet
    t2_grade_sheet = client.get(f"/api/v1/grades/classes/{t1_cls_id}/sheet", headers=t2_headers)
    assert t2_grade_sheet.status_code == 403, f"Expected 403, got {t2_grade_sheet.status_code}"
    print("✓ 20.5. Teacher Blocked from Viewing Other Teacher's Grading Sheet: PASSED (403 Forbidden)")

    # 20.6. Teacher 1 viewing own class detail and grading sheet
    t1_cls_detail = client.get(f"/api/v1/classes/{t1_cls_id}", headers=t_headers)
    assert t1_cls_detail.status_code == 200
    t1_grade_sheet = client.get(f"/api/v1/grades/classes/{t1_cls_id}/sheet", headers=t_headers)
    assert t1_grade_sheet.status_code == 200
    print("✓ 20.6. Teacher Own Class & Grade Access: PASSED (200 OK)")

    # ================= 21. SHARED EMAIL PARENT ACCOUNT CREATION FOR ADMIN & STAFF =================
    admin_parent_id = None
    staff_parent_id = None
    try:
        # 21.1. Admin creates a PARENT account using their own email and phone
        admin_parent_username = f"admin_p_{int(time.time())}"
        create_ap_res = client.post("/api/v1/accounts/", json={
            "username": admin_parent_username,
            "email": "admin@center.edu.vn",
            "full_name": "Nguyễn Văn Quản Trị (PH)",
            "password": "AdminParentPass123",
            "phone": "0901234567",
            "role": "PARENT"
        }, headers=headers)
        assert create_ap_res.status_code == 200, f"Expected 200, got {create_ap_res.status_code}: {create_ap_res.text}"
        admin_parent_id = create_ap_res.json()["data"]["id"]
        print("✓ 21.1. Admin Create Parent Account with Shared Email: PASSED (200 OK)")

        # 21.2. Academic Staff creates a PARENT account using their own email and phone
        staff_parent_username = f"staff_p_{int(time.time())}"
        create_sp_res = client.post("/api/v1/accounts/", json={
            "username": staff_parent_username,
            "email": "staff@center.edu.vn",
            "full_name": "Trần Thị Học Vụ (PH)",
            "password": "StaffParentPass123",
            "phone": "0912345678",
            "role": "PARENT"
        }, headers=staff_headers)
        assert create_sp_res.status_code == 200, f"Expected 200, got {create_sp_res.status_code}: {create_sp_res.text}"
        staff_parent_id = create_sp_res.json()["data"]["id"]
        print("✓ 21.2. Staff Create Parent Account with Shared Email: PASSED (200 OK)")

        # 21.3. Block creating another PARENT account with the same email (duplicate within same role)
        dup_parent_res = client.post("/api/v1/accounts/", json={
            "username": f"admin_p_dup_{int(time.time())}",
            "email": "admin@center.edu.vn",
            "full_name": "Admin Phụ Huynh 2",
            "password": "AdminParentPass123",
            "role": "PARENT"
        }, headers=headers)
        assert dup_parent_res.status_code == 400
        assert "đã được đăng ký cho một tài khoản" in dup_parent_res.json()["detail"].lower()
        print("✓ 21.3. Duplicate Parent Account with Same Email Blocked: PASSED (400 Bad Request)")

        # 21.4. Login with distinct usernames sharing same email
        ap_login = client.post("/api/v1/auth/login", json={
            "username": admin_parent_username,
            "password": "AdminParentPass123"
        })
        assert ap_login.status_code == 200
        assert ap_login.json()["data"]["role"] == "PARENT"

        adm_login = client.post("/api/v1/auth/login", json={
            "username": "admin",
            "password": "admin123"
        })
        assert adm_login.status_code == 200
        assert adm_login.json()["data"]["role"] == "ADMIN"
        print("✓ 21.4. Login with Shared Email Accounts via Username: PASSED")
    finally:
        # 21.5. Clean up created parent test accounts
        if admin_parent_id:
            client.delete(f"/api/v1/accounts/{admin_parent_id}", headers=headers)
        if staff_parent_id:
            client.delete(f"/api/v1/accounts/{staff_parent_id}", headers=headers)
        print("✓ 21.5. Clean Up Test Parent Accounts: PASSED")

    # ================= 22. NEW BUSINESS REQUIREMENTS (SMART-EDU) =================
    # 22.1. Class Opening Date Validation (Req 1)
    # Opening date cannot be in the past
    past_date = (date.today() - timedelta(days=2)).isoformat()
    future_opening = date.today().isoformat()
    future_start = (date.today() + timedelta(days=10)).isoformat()
    future_end = (date.today() + timedelta(days=40)).isoformat()
    rand_suffix = int(time.time())

    # Attempt to create class with opening date in the past -> must reject 400
    invalid_class_res = client.post("/api/v1/classes/", json={
        "class_code": f"TEST-PAST-{rand_suffix}",
        "course_id": 1,
        "teacher_id": 1,
        "max_capacity": 20,
        "opening_date": past_date,
        "start_date": future_start,
        "end_date": future_end
    }, headers=headers)
    assert invalid_class_res.status_code == 400, f"Expected 400, got {invalid_class_res.status_code}: {invalid_class_res.text}"
    assert "quá khứ" in invalid_class_res.json()["detail"].lower()
    print("✓ 22.1.1. Class Opening Date in Past Rejected: PASSED (400 Bad Request)")

    # Valid opening date (today or future) -> succeeds
    valid_class_res = client.post("/api/v1/classes/", json={
        "class_code": f"TEST-VALID-{rand_suffix}",
        "course_id": 1,
        "teacher_id": 1,
        "max_capacity": 20,
        "opening_date": future_opening,
        "start_date": future_start,
        "end_date": future_end
    }, headers=headers)
    assert valid_class_res.status_code == 200, f"Expected 200, got {valid_class_res.status_code}: {valid_class_res.text}"
    created_class_id = valid_class_res.json()["data"]["id"]
    print("✓ 22.1.2. Class Opening Date Today/Future Created: PASSED (200 OK)")

    # 22.2. Direct Class Enrollment without Approval (Req 3)
    student_login = client.post("/api/v1/auth/login", json={"username": "student", "password": "student123"})
    assert student_login.status_code == 200
    student_token = student_login.json()["data"]["access_token"]
    stu_headers = {"Authorization": f"Bearer {student_token}"}

    enroll_res = client.post("/api/v1/enrollments/", json={
        "class_id": created_class_id,
        "note": "Ghi danh trực tiếp không qua duyệt"
    }, headers=stu_headers)
    assert enroll_res.status_code == 200, f"Expected 200, got {enroll_res.status_code}: {enroll_res.text}"
    enroll_data = enroll_res.json()["data"]
    assert enroll_data["status"] == "APPROVED"
    print("✓ 22.2. Direct Enrollment (No Pending Approval): PASSED (Direct status: APPROVED)")

    # 22.3. Auto Grade Locking on Ended Class & Unlock/Lock by Admin/Staff (Req 4)
    # Class 11 is seeded with past dates (ended class: 2026-10-15)
    ended_cls_res = client.get("/api/v1/classes/?q=IELTS-65-PAST", headers=headers)
    assert ended_cls_res.status_code == 200
    ended_cls_id = ended_cls_res.json()["data"][0]["id"]

    # Check lock status for ended class
    lock_status_res = client.get(f"/api/v1/grades/classes/{ended_cls_id}/lock-status", headers=headers)
    assert lock_status_res.status_code == 200
    lock_data = lock_status_res.json()["data"]
    assert lock_data["is_locked"] is True
    print(f"✓ 22.3.1. Ended Class Grade Sheet Auto-Locked: PASSED (Locked: {lock_data['is_locked']})")

    # Teacher attempt to update grades in locked ended class -> rejected
    locked_edit_res = client.post("/api/v1/grades/batch", json={
        "class_id": ended_cls_id,
        "grades": [{
            "student_id": 1,
            "attendance_score": 10.0,
            "midterm_score": 10.0,
            "final_score": 10.0
        }]
    }, headers=t_headers)
    assert locked_edit_res.status_code == 400
    assert "khóa" in locked_edit_res.json()["detail"].lower()
    print("✓ 22.3.2. Teacher Modification on Locked Grades Blocked: PASSED (400 Bad Request)")

    # Admin unlocks grades with reason
    unlock_res = client.post(f"/api/v1/grades/classes/{ended_cls_id}/unlock", json={
        "reason": "Giảng viên báo nhập nhầm cột điểm giữa kỳ cần chỉnh sửa"
    }, headers=headers)
    assert unlock_res.status_code == 200
    print("✓ 22.3.3. Admin Unlock Grade Sheet with Reason: PASSED (200 OK)")

    # Check lock history for ended class
    history_res = client.get(f"/api/v1/grades/classes/{ended_cls_id}/lock-history", headers=headers)
    assert history_res.status_code == 200
    history_items = history_res.json()["data"]
    assert len(history_items) > 0
    assert history_items[0]["action"] == "UNLOCK"
    assert "nhập nhầm" in history_items[0]["reason"]
    print("✓ 22.3.4. Lock/Unlock Audit History Logged: PASSED")

    # Admin re-locks grades with reason
    relock_res = client.post(f"/api/v1/grades/classes/{ended_cls_id}/confirm", json={
        "reason": "Đã chỉnh sửa xong, khóa lại bảng điểm"
    }, headers=headers)
    assert relock_res.status_code == 200
    print("✓ 22.3.5. Admin Re-lock Grade Sheet with Reason: PASSED (200 OK)")

    # 22.4. Tickets & Complaints Module (Req 5)
    # Student sends complaint for ended class (which ended > 7 days ago) -> must be rejected due to deadline expired
    expired_complaint_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "COMPLAINT",
        "category": "GRADE",
        "title": "Khiếu nại điểm lớp kết thúc từ lâu",
        "content": "Em muốn khiếu nại điểm thi",
        "related_class_id": ended_cls_id,
        "receiver_role": "TEACHER"
    }, headers=stu_headers)
    assert expired_complaint_res.status_code == 400
    assert "quá thời hạn" in expired_complaint_res.json()["detail"].lower()
    print("✓ 22.4.1. Overdue Complaint (>7 days after class end) Rejected: PASSED (400 Bad Request)")

    # Student sends regular REQUEST to Staff (requests have no deadline)
    valid_request_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "ENROLLMENT",
        "title": "Yêu cầu hỗ trợ thông tin học phí",
        "content": "Kính gửi phòng đào tạo, em muốn hỏi về biểu phí đóng học phí",
        "receiver_role": "ACADEMIC_STAFF"
    }, headers=stu_headers)
    assert valid_request_res.status_code == 200, f"Expected 200, got {valid_request_res.status_code}: {valid_request_res.text}"
    ticket_id = valid_request_res.json()["data"]["id"]
    ticket_code = valid_request_res.json()["data"]["ticket_code"]
    assert ticket_code.startswith("YC-")
    print(f"✓ 22.4.2. Create Request Ticket ({ticket_code}): PASSED (200 OK)")

    # Staff views inbox and replies to the ticket
    reply_res = client.post(f"/api/v1/tickets/{ticket_id}/messages", json={
        "content": "Chào em, em có thể đến văn phòng P.102 để nhận biên lai học phí nhé."
    }, headers=staff_headers)
    assert reply_res.status_code == 200
    print("✓ 22.4.3. Staff Reply to Ticket: PASSED (200 OK)")

    # Staff updates ticket status to RESOLVED
    status_res = client.patch(f"/api/v1/tickets/{ticket_id}/status", json={
        "status": "RESOLVED"
    }, headers=staff_headers)
    assert status_res.status_code == 200
    assert status_res.json()["data"]["status"] == "RESOLVED"
    print("✓ 22.4.4. Ticket Status Update (RESOLVED): PASSED (200 OK)")

    # 22.5. Teacher Role Classroom Access Restriction (Req 6)
    # Teacher calling GET /api/v1/classrooms/ must receive 403 Forbidden
    teacher_classroom_res = client.get("/api/v1/classrooms/", headers=t_headers)
    assert teacher_classroom_res.status_code == 403, f"Expected 403, got {teacher_classroom_res.status_code}"
    print("✓ 22.5. Teacher Role Blocked from Classroom Management: PASSED (403 Forbidden)")

    # Clean up test class and enrollment
    enroll_id = enroll_data["id"]
    client.patch(f"/api/v1/enrollments/{enroll_id}/cancel", headers=stu_headers)
    client.delete(f"/api/v1/classes/{created_class_id}", headers=headers)
    print("✓ 22.6. Clean Up Test Class: PASSED")

    # =========================================================================
    # SECTION 23: TIMETABLE SCOPE & CLASS TRANSFER BUSINESS LOGIC
    # =========================================================================
    print("\n--- SECTION 23: Timetable Full Scope & Class Transfer ---")

    # 23.1: Student personal schedule returns full class date range without 12-week cutoff
    stu_sched_res = client.get("/api/v1/schedules/personal", headers=stu_headers)
    assert stu_sched_res.status_code == 200, f"Expected 200, got {stu_sched_res.status_code}: {stu_sched_res.text}"
    stu_sessions = stu_sched_res.json()["data"]
    assert len(stu_sessions) > 0, "Student should have active sessions"
    for s in stu_sessions:
        assert "class_start_date" in s
        assert "class_end_date" in s
        assert s["class_id"] is not None
    print(f"✓ 23.1. Student Full Timetable Scope ({len(stu_sessions)} sessions with start/end bounds): PASSED")

    # 23.2: Teacher personal schedule returns full assigned sessions
    t_sched_res = client.get("/api/v1/schedules/personal", headers=t_headers)
    assert t_sched_res.status_code == 200
    t_sessions = t_sched_res.json()["data"]
    assert len(t_sessions) > 0, "Teacher should have assigned sessions"
    for s in t_sessions:
        assert "class_start_date" in s
        assert "class_end_date" in s
    print(f"✓ 23.2. Teacher Full Timetable Scope ({len(t_sessions)} sessions with start/end bounds): PASSED")

    # 23.3: Query transfer targets for Class 1 (IELTS-65-K26A)
    # Target classes must have different teacher, different schedule, capacity, and active status
    targets_res = client.get("/api/v1/classes/1/transfer-targets", headers=stu_headers)
    assert targets_res.status_code == 200, f"Expected 200, got {targets_res.status_code}: {targets_res.text}"
    targets = targets_res.json()["data"]
    assert len(targets) > 0, "Expected at least one eligible transfer target"
    target_ids = [t["id"] for t in targets]
    assert 1 not in target_ids, "Current class 1 must not be in transfer targets"
    assert 2 not in target_ids, "Class 2 has same teacher as Class 1, must not be in targets"
    print(f"✓ 23.3. Get Transfer Targets for Class 1 (Found {len(targets)} eligible classes): PASSED")

    # 23.4: Class Transfer Validation: Reject transfer to same class
    same_cls_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": 1,
        "reason": "Muốn chuyển sang chính lớp này"
    }, headers=stu_headers)
    assert same_cls_res.status_code == 400
    assert "khác với lớp hiện tại" in same_cls_res.json()["detail"].lower()
    print("✓ 23.4. Reject Transfer to Same Class: PASSED (400 Bad Request)")

    # 23.5: Class Transfer Validation: Reject transfer to class with same teacher (in same course)
    same_t_code = f"IELTS-65-SAMET-{int(time.time())}"
    create_same_t = client.post("/api/v1/classes/", json={
        "class_code": same_t_code,
        "course_id": 1,
        "teacher_id": 1,
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": date.today().isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert create_same_t.status_code == 200
    same_t_cls_id = create_same_t.json()["data"]["id"]

    same_teacher_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": same_t_cls_id,
        "reason": "Lớp đích có cùng giảng viên với lớp 1"
    }, headers=stu_headers)
    assert same_teacher_res.status_code == 400
    assert "giảng viên khác" in same_teacher_res.json()["detail"].lower() or "cùng giảng viên" in same_teacher_res.json()["detail"].lower()
    client.delete(f"/api/v1/classes/{same_t_cls_id}", headers=headers)
    print("✓ 23.5. Reject Transfer to Class with Same Teacher: PASSED (400 Bad Request)")

    # 23.5b (H-02): Reject transfer to class with DIFFERENT course (Class 1 is IELTS-65, Class 3 is TOEIC-750)
    diff_course_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": 3,
        "reason": "Lớp 3 thuộc khóa TOEIC khác khóa IELTS của lớp 1"
    }, headers=stu_headers)
    assert diff_course_res.status_code == 400
    assert "cùng khóa học" in diff_course_res.json()["detail"].lower()
    print("✓ 23.5b. Reject Transfer to Class with Different Course: PASSED (400 Bad Request)")

    # 23.6: Successful Class Transfer: Student transfers from Class 1 to Class 4
    # Class 4 has teacher_david (different teacher) and different schedule
    cls1_info = client.get("/api/v1/classes/", headers=headers).json()["data"]
    cls1_before = next(c for c in cls1_info if c["id"] == 1)
    cls4_before = next(c for c in cls1_info if c["id"] == 4)
    enrolled_c1_before = cls1_before["current_enrolled"]
    enrolled_c4_before = cls4_before["current_enrolled"]

    transfer_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": 4,
        "reason": "Đổi ca học do vướng lịch công tác"
    }, headers=stu_headers)
    assert transfer_res.status_code == 200, f"Expected 200, got {transfer_res.status_code}: {transfer_res.text}"
    assert "thành công" in transfer_res.json()["message"].lower()
    print("✓ 23.6. Transfer from Class 1 to Class 4: PASSED (200 OK)")

    # 23.7: Verify roster and enrolled counts update immediately
    cls_after = client.get("/api/v1/classes/", headers=headers).json()["data"]
    cls1_after = next(c for c in cls_after if c["id"] == 1)
    cls4_after = next(c for c in cls_after if c["id"] == 4)
    assert cls1_after["current_enrolled"] == enrolled_c1_before - 1, "Old class enrolled count should decrease by 1"
    assert cls4_after["current_enrolled"] == enrolled_c4_before + 1, "New class enrolled count should increase by 1"

    # Verify student roster in class 4 has the student
    roster_c4 = client.get("/api/v1/classes/4/students", headers=headers).json()["data"]
    student_in_c4 = any(s["email"] == "student@center.edu.vn" for s in roster_c4)
    assert student_in_c4, "Transferred student must appear in Class 4 roster"

    # Verify student timetable now reflects Class 4 sessions instead of Class 1
    stu_sched_after = client.get("/api/v1/schedules/personal", headers=stu_headers).json()["data"]
    c4_sessions = [s for s in stu_sched_after if s["class_id"] == 4]
    c1_sessions = [s for s in stu_sched_after if s["class_id"] == 1]
    assert len(c4_sessions) > 0, "Student schedule must now include Class 4 sessions"
    assert len(c1_sessions) == 0, "Student schedule must not include Class 1 sessions"
    print("✓ 23.7. Verify Enrolled Counts, Roster & Timetable Immediate Sync: PASSED")

    # 23.8 (H-03): Idempotent Rollback: Transfer student back from Class 4 to Class 1
    rollback_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 4,
        "target_class_id": 1,
        "reason": "Hoàn tác chuyển lớp sau kiểm thử"
    }, headers=stu_headers)
    assert rollback_res.status_code == 200, f"Rollback failed: {rollback_res.text}"

    # Verify restored state
    cls_restored = client.get("/api/v1/classes/", headers=headers).json()["data"]
    cls1_restored = next(c for c in cls_restored if c["id"] == 1)
    cls4_restored = next(c for c in cls_restored if c["id"] == 4)
    assert cls1_restored["current_enrolled"] == enrolled_c1_before
    assert cls4_restored["current_enrolled"] == enrolled_c4_before
    print("✓ 23.8. Rollback Transfer & Verify Idempotency: PASSED (Restored initial state)")

    # =========================================================================
    # SECTION 24: GRADE COMPLAINTS & TEACHER UNLOCK REQUESTS BUSINESS LOGIC
    # =========================================================================
    print("\n--- SECTION 24: Grade Complaints & Teacher Unlock Requests ---")

    # Second student login for privacy isolation check
    stu2_res = client.post("/api/v1/auth/login", json={"username": "student_tuan", "password": "student123"})
    assert stu2_res.status_code == 200
    stu2_headers = {"Authorization": f"Bearer {stu2_res.json()['data']['access_token']}"}

    # 24.1. Student 1 creates grade complaint for Class 1 (enrolled class)
    complaint_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "COMPLAINT",
        "category": "GRADE",
        "title": "Khiếu nại kết quả điểm thi giữa kỳ lớp IELTS-65-K26A",
        "content": "Em muốn nhờ thầy xem xét lại điểm phần Speaking giữa kỳ vì em tự tin làm tốt.",
        "related_class_id": 1
    }, headers=stu_headers)
    assert complaint_res.status_code == 200, f"Expected 200, got {complaint_res.status_code}: {complaint_res.text}"
    complaint_data = complaint_res.json()["data"]
    complaint_id = complaint_data["id"]
    assert complaint_data["ticket_code"].startswith("KN-")
    assert complaint_data["receiver_role"] == "TEACHER"
    assert complaint_data["receiver_id"] == 3  # Teacher 1
    assert complaint_data["status"] == "PENDING"
    assert complaint_data["current_grade"] is not None
    print(f"✓ 24.1. Student 1 Create Grade Complaint ({complaint_data['ticket_code']}): PASSED (200 OK)")

    # 24.2. Student attempts to create grade complaint for class they are NOT enrolled in (Class 2)
    unauth_complaint_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "COMPLAINT",
        "category": "GRADE",
        "title": "Khiếu nại điểm lớp không học",
        "content": "Em muốn khiếu nại điểm lớp này",
        "related_class_id": 2
    }, headers=stu_headers)
    assert unauth_complaint_res.status_code == 400
    assert "đã tham gia" in unauth_complaint_res.json()["detail"].lower()
    print("✓ 24.2. Reject Grade Complaint for Non-Enrolled Class: PASSED (400 Bad Request)")

    # 24.3. Student forbidden from creating grade unlock request
    stu_unlock_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "GRADE_UNLOCK",
        "title": "Yêu cầu mở sổ điểm",
        "content": "Em muốn mở sổ điểm của lớp để xem",
        "related_class_id": 1
    }, headers=stu_headers)
    assert stu_unlock_res.status_code == 403
    assert "không có quyền" in stu_unlock_res.json()["detail"].lower()
    print("✓ 24.3. Student Forbidden from Requesting Grade Unlock: PASSED (403 Forbidden)")

    # 24.4. Student 2 forbidden from viewing Student 1's complaint
    s2_view_res = client.get(f"/api/v1/tickets/{complaint_id}", headers=stu2_headers)
    assert s2_view_res.status_code == 403
    print("✓ 24.4. Student 2 Forbidden from Viewing Other Student's Complaint: PASSED (403 Forbidden)")

    # 24.5. Teacher 1 views complaint in inbox (assigned teacher of Class 1)
    t1_inbox_res = client.get("/api/v1/tickets/inbox", headers=t_headers)
    assert t1_inbox_res.status_code == 200
    t1_inbox_ids = [t["id"] for t in t1_inbox_res.json()["data"]]
    assert complaint_id in t1_inbox_ids
    print("✓ 24.5. Teacher 1 Receives Grade Complaint in Inbox: PASSED (200 OK)")

    # 24.6. Teacher 1 replies to complaint
    reply_c_res = client.post(f"/api/v1/tickets/{complaint_id}/messages", json={
        "content": "Chào em, thầy đã nhận được khiếu nại và sẽ nghe lại file ghi âm bài nói Speaking của em nhé."
    }, headers=t_headers)
    assert reply_c_res.status_code == 200
    print("✓ 24.6. Teacher 1 Replies to Student Complaint: PASSED (200 OK)")

    # 24.7. Teacher 1 resolves student complaint
    resolve_c_res = client.patch(f"/api/v1/tickets/{complaint_id}/status", json={
        "status": "RESOLVED",
        "reason": "Thầy đã nghe lại file ghi âm và đồng ý nâng điểm Speaking lên 7.5. Thầy sẽ xin mở sổ điểm để cập nhật."
    }, headers=t_headers)
    assert resolve_c_res.status_code == 200
    assert resolve_c_res.json()["data"]["status"] == "RESOLVED"
    print("✓ 24.7. Teacher 1 Resolves Student Complaint: PASSED (200 OK)")

    # 24.8. Ensure Class 1 is locked before unlock request
    client.post("/api/v1/grades/classes/1/confirm", json={"reason": "Khóa sổ điểm phục vụ kiểm thử"}, headers=staff_headers)
    c1_lock_stat = client.get("/api/v1/grades/classes/1/lock-status", headers=headers).json()["data"]
    assert c1_lock_stat["is_locked"] is True

    # Teacher 1 creates unlock request for Class 1 (assigned class)
    unlock_req_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "GRADE_UNLOCK",
        "title": "Yêu cầu mở sổ điểm lớp IELTS-65-K26A để cập nhật sau phúc khảo",
        "content": "Kính gửi phòng Học vụ, giảng viên cần mở sổ điểm để cập nhật điểm giữa kỳ cho học viên sau khi phúc khảo.",
        "related_class_id": 1,
        "receiver_role": "ACADEMIC_STAFF"
    }, headers=t_headers)
    assert unlock_req_res.status_code == 200, f"Expected 200, got {unlock_req_res.status_code}: {unlock_req_res.text}"
    unlock_req_data = unlock_req_res.json()["data"]
    unlock_ticket_id = unlock_req_data["id"]
    assert unlock_req_data["ticket_code"].startswith("YC-")
    assert unlock_req_data["category"] == "GRADE_UNLOCK"
    assert unlock_req_data["status"] == "PENDING"
    print(f"✓ 24.8. Teacher 1 Create Grade Unlock Request ({unlock_req_data['ticket_code']}): PASSED (200 OK)")

    # 24.9. Teacher 2 forbidden from requesting unlock for Class 1 (taught by Teacher 1)
    t2_unlock_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "GRADE_UNLOCK",
        "title": "Yêu cầu mở sổ điểm lớp người khác",
        "content": "Mở điểm lớp 1 giúp tôi",
        "related_class_id": 1
    }, headers=t2_headers)
    assert t2_unlock_res.status_code == 403
    assert "phụ trách" in t2_unlock_res.json()["detail"].lower()
    print("✓ 24.9. Teacher 2 Forbidden from Requesting Unlock for Other Teacher's Class: PASSED (403 Forbidden)")

    # 24.10. Teacher 1 forbidden from self-approving or self-rejecting unlock request
    t1_self_app_res = client.patch(f"/api/v1/tickets/{unlock_ticket_id}/status", json={
        "status": "APPROVED"
    }, headers=t_headers)
    assert t1_self_app_res.status_code == 403
    assert "không có quyền" in t1_self_app_res.json()["detail"].lower()
    print("✓ 24.10. Teacher 1 Forbidden from Self-Approving Unlock Request: PASSED (403 Forbidden)")

    # 24.11. Academic Staff rejects unlock request WITHOUT reason -> must be rejected (reason required)
    staff_rej_no_reason = client.patch(f"/api/v1/tickets/{unlock_ticket_id}/status", json={
        "status": "REJECTED"
    }, headers=staff_headers)
    assert staff_rej_no_reason.status_code == 400
    assert "lý do từ chối" in staff_rej_no_reason.json()["detail"].lower()
    print("✓ 24.11. Reject Unlock Request Without Reason Fails: PASSED (400 Bad Request)")

    # 24.12. Academic Staff rejects unlock request WITH reason -> rejected, grade remains locked
    staff_rej_with_reason = client.patch(f"/api/v1/tickets/{unlock_ticket_id}/status", json={
        "status": "REJECTED",
        "reason": "Chưa đính kèm biên bản phúc khảo có chữ ký của Trưởng bộ môn."
    }, headers=staff_headers)
    assert staff_rej_with_reason.status_code == 200
    assert staff_rej_with_reason.json()["data"]["status"] == "REJECTED"
    c1_lock_stat_after_rej = client.get("/api/v1/grades/classes/1/lock-status", headers=headers).json()["data"]
    assert c1_lock_stat_after_rej["is_locked"] is True
    print("✓ 24.12. Academic Staff Rejects Unlock Request with Reason (Grades Remain Locked): PASSED (200 OK)")

    # 24.13. Teacher 1 creates second unlock request with full evidence
    unlock_req2_res = client.post("/api/v1/tickets/", json={
        "ticket_type": "REQUEST",
        "category": "GRADE_UNLOCK",
        "title": "Yêu cầu mở sổ điểm lớp IELTS-65-K26A (Kèm biên bản BB-01)",
        "content": "Đã bổ sung đầy đủ biên bản phúc khảo có chữ ký Trưởng bộ môn.",
        "related_class_id": 1,
        "receiver_role": "ACADEMIC_STAFF"
    }, headers=t_headers)
    assert unlock_req2_res.status_code == 200
    unlock_ticket2_id = unlock_req2_res.json()["data"]["id"]

    # 24.14. Academic Staff APPROVES unlock request -> ACTUALLY UNLOCKS GRADE SHEET
    staff_app_res = client.patch(f"/api/v1/tickets/{unlock_ticket2_id}/status", json={
        "status": "APPROVED",
        "reason": "Hồ sơ hợp lệ, phê duyệt mở sổ điểm cho giảng viên chỉnh sửa trong 48 giờ."
    }, headers=staff_headers)
    assert staff_app_res.status_code == 200
    assert staff_app_res.json()["data"]["status"] == "APPROVED"

    # Verify grade sheet of Class 1 is ACTUALLY unlocked
    c1_lock_stat_after_app = client.get("/api/v1/grades/classes/1/lock-status", headers=headers).json()["data"]
    assert c1_lock_stat_after_app["is_locked"] is False, "Grade sheet must actually be unlocked"

    # Verify Teacher 1 can successfully save grades now
    teacher_save_res = client.post("/api/v1/grades/batch", json={
        "class_id": 1,
        "grades": [{
            "student_id": 1,
            "attendance_score": 9.0,
            "midterm_score": 7.5,
            "final_score": 8.0
        }]
    }, headers=t_headers)
    assert teacher_save_res.status_code == 200
    print("✓ 24.14. Academic Staff Approves Request -> Grade Sheet Actually Unlocked & Teacher Edits Grades: PASSED (200 OK)")

    # 24.15. Student forbidden from resolving or approving tickets
    stu_res_status = client.patch(f"/api/v1/tickets/{complaint_id}/status", json={
        "status": "RESOLVED"
    }, headers=stu_headers)
    assert stu_res_status.status_code == 403
    print("✓ 24.15. Student Forbidden from Setting Ticket to RESOLVED: PASSED (403 Forbidden)")

    # =========================================================================
    # SECTION 25: REGRESSION TESTS FOR AUDIT 10 BUGS (H-04, H-05, M-01 to M-04, L-02)
    # =========================================================================
    print("\n--- SECTION 25: Audit Regression Tests (H-04, H-05, M-01 to M-04, L-02) ---")
    from app.core.database import SessionLocal as TestSessionLocal

    # 25.1 (M-04): Student forbidden from querying transfer targets of a class they do not belong to
    # Student is enrolled in Class 1, NOT Class 3
    targets_c3_stu = client.get("/api/v1/classes/3/transfer-targets", headers=stu_headers)
    assert targets_c3_stu.status_code == 403, f"Expected 403 for non-member student, got {targets_c3_stu.status_code}"
    assert "quyền" in targets_c3_stu.json()["detail"].lower()
    # But Admin can query Class 3 transfer targets
    targets_c3_admin = client.get("/api/v1/classes/3/transfer-targets", headers=headers)
    assert targets_c3_admin.status_code == 200
    print("✓ 25.1 (M-04). Student Forbidden from Querying Transfer Targets of Unenrolled Class: PASSED (403 Forbidden)")

    # 25.2 (M-02): Schedule overlap check rejects partially overlapping sessions (start1 < end2 and start2 < end1)
    # Class 1 has sessions on Wednesday (weekday 2) from 18:00 to 20:00
    # Create candidate class C_overlap with Wednesday 19:00 - 21:00 (1 hour overlap)
    c_overlap_code = f"IELTS-65-OVERLAP-{int(time.time())}"
    res_c_overlap = client.post("/api/v1/classes/", json={
        "class_code": c_overlap_code,
        "course_id": 1,
        "teacher_id": 2, # teacher_david
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": date.today().isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_overlap.status_code == 200
    c_overlap_id = res_c_overlap.json()["data"]["id"]

    # Add overlapping session on next Wednesday
    today_dt = date.today()
    days_to_wed = (2 - today_dt.weekday()) % 7
    if days_to_wed == 0:
        days_to_wed = 7
    wed_date = today_dt + timedelta(days=days_to_wed)
    db_sess = TestSessionLocal()
    try:
        from app.modules.schedules.models import ScheduleSession as SessModel
        new_sess = SessModel(
            class_id=c_overlap_id,
            classroom_id=2,
            teacher_id=2,
            session_date=wed_date,
            start_time="19:00",
            end_time="21:00",
            slot_name="Ca tối (19:00 - 21:00)",
            status="SCHEDULED"
        )
        db_sess.add(new_sess)
        db_sess.commit()
    finally:
        db_sess.close()

    # Query transfer targets for Class 1: C_overlap must NOT be present
    c1_targets = client.get("/api/v1/classes/1/transfer-targets", headers=stu_headers).json()["data"]
    c1_target_ids = [t["id"] for t in c1_targets]
    assert c_overlap_id not in c1_target_ids, "Overlapping class must not appear in transfer targets"

    # Direct transfer call to C_overlap must be rejected (400)
    transfer_overlap_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": c_overlap_id,
        "reason": "Thử chuyển vào lớp trùng một phần thời khóa biểu"
    }, headers=stu_headers)
    assert transfer_overlap_res.status_code == 400
    assert "trùng" in transfer_overlap_res.json()["detail"].lower() or "giao nhau" in transfer_overlap_res.json()["detail"].lower()
    print("✓ 25.2 (M-02). Partial Schedule Overlap Correctly Excluded from Targets & Rejected: PASSED (400 Bad Request)")

    # 25.3 (M-01 & M-03): Target class at full capacity cannot accept transfers
    # Create target class with max_capacity = 1 and current_enrolled = 1
    c_full_code = f"IELTS-65-FULL-{int(time.time())}"
    res_c_full = client.post("/api/v1/classes/", json={
        "class_code": c_full_code,
        "course_id": 1,
        "teacher_id": 2,
        "max_capacity": 1,
        "opening_date": date.today().isoformat(),
        "start_date": date.today().isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_full.status_code == 200
    c_full_id = res_c_full.json()["data"]["id"]

    # Directly set current_enrolled = 1 via database session to simulate full class
    db_check = TestSessionLocal()
    try:
        from app.modules.classes.models import Class as ClsModel
        cls_to_fill = db_check.query(ClsModel).filter(ClsModel.id == c_full_id).first()
        cls_to_fill.current_enrolled = 1
        db_check.commit()
    finally:
        db_check.close()

    # Query transfer targets for Class 1: C_full must have is_full == True
    c1_targets_full = client.get("/api/v1/classes/1/transfer-targets", headers=stu_headers).json()["data"]
    target_full_item = next((t for t in c1_targets_full if t["id"] == c_full_id), None)
    if target_full_item:
        assert target_full_item["is_full"] == True
        assert target_full_item["current_enrolled"] >= target_full_item["max_capacity"]

    # Transfer into full class must be rejected (400)
    transfer_full_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": c_full_id,
        "reason": "Thử chuyển vào lớp đã đầy chỗ"
    }, headers=stu_headers)
    assert transfer_full_res.status_code == 400
    assert "đủ sĩ số" in transfer_full_res.json()["detail"].lower()
    print("✓ 25.3 (M-01 & M-03). Full Capacity Class Transfer Rejected by Atomic Check: PASSED (400 Bad Request)")

    # 25.4 (H-04): Sổ điểm lớp đích đã khóa hoặc điểm đã xác nhận thì từ chối chuyển lớp
    # Test 25.4a: Locked target class grade sheet
    c_locked_code = f"IELTS-65-LOCKED-{int(time.time())}"
    res_c_locked = client.post("/api/v1/classes/", json={
        "class_code": c_locked_code,
        "course_id": 1,
        "teacher_id": 2,
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": date.today().isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_locked.status_code == 200
    c_locked_id = res_c_locked.json()["data"]["id"]

    # Set end_date to past date in DB so it is an ended class with auto-locked grades
    db_lock = TestSessionLocal()
    try:
        from app.modules.classes.models import Class as ClsModel
        cls_row = db_lock.query(ClsModel).filter(ClsModel.id == c_locked_id).first()
        cls_row.end_date = date.today() - timedelta(days=1)
        db_lock.commit()
    finally:
        db_lock.close()

    transfer_locked_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": c_locked_id,
        "reason": "Thử chuyển vào lớp đã kết thúc khóa sổ điểm"
    }, headers=stu_headers)
    assert transfer_locked_res.status_code == 400
    assert "khóa sổ điểm" in transfer_locked_res.json()["detail"].lower()
    print("✓ 25.4a (H-04). Transfer to Target Class with Locked Grade Sheet Rejected: PASSED (400 Bad Request)")

    # Test 25.4b: Student has confirmed grade in target class
    # Create target class, add student with is_confirmed = True
    c_conf_code = f"IELTS-65-CONF-{int(time.time())}"
    res_c_conf = client.post("/api/v1/classes/", json={
        "class_code": c_conf_code,
        "course_id": 1,
        "teacher_id": 2,
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": date.today().isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_conf.status_code == 200
    c_conf_id = res_c_conf.json()["data"]["id"]

    db_conf = TestSessionLocal()
    try:
        from app.modules.grades.models import GradeRecord as GrModel
        from app.modules.classes.models import Class as ClsModel
        cls_c = db_conf.query(ClsModel).filter(ClsModel.id == c_conf_id).first()
        cls_c.is_grade_unlocked = True

        gr_conf = GrModel(
            class_id=c_conf_id,
            student_id=1,
            attendance_score=9.0,
            midterm_score=8.5,
            final_score=9.0,
            total_score=8.8,
            result_status="PASSED",
            is_confirmed=True
        )
        db_conf.add(gr_conf)
        db_conf.commit()
    finally:
        db_conf.close()

    transfer_conf_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": c_conf_id,
        "reason": "Thử chuyển vào lớp đã có điểm xác nhận"
    }, headers=stu_headers)
    assert transfer_conf_res.status_code == 400, f"Expected 400: {transfer_conf_res.text}"
    assert "xác nhận" in transfer_conf_res.json().get("detail", "").lower(), f"Got unexpected detail: {transfer_conf_res.json()}"
    print("✓ 25.4b (H-04). Transfer with Confirmed Grade in Target Class Rejected: PASSED (400 Bad Request)")

    # 25.5 (H-05): Student cannot cancel transfer audit record via cancel_request
    # Perform a valid transfer from Class 1 to Class 4
    tf_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": 4,
        "reason": "Chuyển lớp để kiểm thử audit record không thể hủy"
    }, headers=stu_headers)
    assert tf_res.status_code == 200

    # Query enrollment requests of student
    my_en_res = client.get("/api/v1/enrollments/my-requests", headers=stu_headers)
    assert my_en_res.status_code == 200
    audit_req = next((r for r in my_en_res.json()["data"] if "[TRANSFER_AUDIT]" in (r.get("note") or "")), None)
    assert audit_req is not None, "Audit enrollment request with [TRANSFER_AUDIT] must exist"

    # Attempt to cancel this transfer audit record
    cancel_audit_res = client.patch(f"/api/v1/enrollments/{audit_req['id']}/cancel", headers=stu_headers)
    assert cancel_audit_res.status_code == 400
    assert "không thể hủy bản ghi audit chuyển lớp" in cancel_audit_res.json()["detail"].lower()
    print("✓ 25.5 (H-05). Student Blocked from Cancelling Transfer Audit Record: PASSED (400 Bad Request)")

    # Rollback transfer back to Class 1
    rb_res = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 4,
        "target_class_id": 1,
        "reason": "Hoàn tác chuyển lớp sau kiểm thử H-05"
    }, headers=stu_headers)
    assert rb_res.status_code == 200

    # 25.6 (L-02): Email reuse with soft-deleted accounts handles truncation safely
    long_email = f"verylongprefix_{int(time.time())}_{'a'*35}@center.edu.vn"
    user_data = {
        "username": f"user_l02_{int(time.time())}",
        "email": long_email,
        "password": "Password123!",
        "full_name": "Test Long Email User",
        "role": "STUDENT"
    }
    create_u1 = client.post("/api/v1/accounts/", json=user_data, headers=headers)
    assert create_u1.status_code == 200
    u1_id = create_u1.json()["data"]["id"]

    # Delete u1 (soft delete)
    del_u1 = client.delete(f"/api/v1/accounts/{u1_id}", headers=headers)
    assert del_u1.status_code == 200

    # Create u2 with the EXACT same email and same role
    user_data_2 = {
        "username": f"user_l02_b_{int(time.time())}",
        "email": long_email,
        "password": "Password123!",
        "full_name": "Test Long Email User 2",
        "role": "STUDENT"
    }
    create_u2 = client.post("/api/v1/accounts/", json=user_data_2, headers=headers)
    assert create_u2.status_code == 200, f"Expected 200, got {create_u2.status_code}: {create_u2.text}"
    u2_id = create_u2.json()["data"]["id"]

    # Verify soft-deleted user's email was renamed safely (<= 100 chars)
    db_u = TestSessionLocal()
    try:
        from app.modules.accounts.models import User as UserModel
        del_user_row = db_u.query(UserModel).filter(UserModel.id == u1_id).first()
        assert del_user_row.email.startswith(f"del_{u1_id}_")
        assert len(del_user_row.email) <= 100
    finally:
        db_u.close()

    # Clean up created accounts and classes
    client.delete(f"/api/v1/accounts/{u2_id}", headers=headers)
    client.delete(f"/api/v1/classes/{c_overlap_id}", headers=headers)
    client.delete(f"/api/v1/classes/{c_full_id}", headers=headers)
    client.delete(f"/api/v1/classes/{c_locked_id}", headers=headers)
    client.delete(f"/api/v1/classes/{c_conf_id}", headers=headers)
    print("✓ 25.6 (L-02). Safe Renaming of Soft-Deleted Long Email (<= 100 Chars): PASSED (200 OK)")

    # ================= 26. CLASS LIFECYCLE & STATE MACHINE NORMALIZATION =================
    print("\n--- SECTION 26: Class Lifecycle & State Machine Normalization ---")

    # 26.1: Date-driven auto transition: OPEN_FOR_ENROLLMENT -> IN_PROGRESS on start_date
    c_life_code = f"IELTS-LIFE-{int(time.time())}"
    res_c_life = client.post("/api/v1/classes/", json={
        "class_code": c_life_code,
        "course_id": 1,
        "teacher_id": 2,
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": (date.today() + timedelta(days=5)).isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_life.status_code == 200
    c_life_id = res_c_life.json()["data"]["id"]
    assert res_c_life.json()["data"]["status"] == "OPEN_FOR_ENROLLMENT"

    # Simulate start_date arriving: update start_date to today in DB
    db_life = TestSessionLocal()
    try:
        from app.modules.classes.models import Class as ClsModel
        cls_l = db_life.query(ClsModel).filter(ClsModel.id == c_life_id).first()
        cls_l.start_date = date.today()
        db_life.commit()
    finally:
        db_life.close()

    # Query class detail -> trigger lifecycle sync -> status must automatically be IN_PROGRESS
    detail_res = client.get(f"/api/v1/classes/{c_life_id}", headers=headers)
    assert detail_res.status_code == 200
    assert detail_res.json()["data"]["status"] == "IN_PROGRESS"
    print("✓ 26.1. Date-driven Auto Transition (OPEN_FOR_ENROLLMENT -> IN_PROGRESS on start_date): PASSED")

    # 26.2: State Machine Guard validations
    # 26.2a: Reject IN_PROGRESS -> OPEN_FOR_ENROLLMENT
    reopen_res = client.patch(f"/api/v1/classes/{c_life_id}/status?new_status=OPEN_FOR_ENROLLMENT", headers=headers)
    assert reopen_res.status_code == 400
    assert "không thể chuyển ngược" in reopen_res.json()["detail"].lower()
    print("✓ 26.2a. Reopen IN_PROGRESS to OPEN_FOR_ENROLLMENT Rejected: PASSED (400 Bad Request)")

    # 26.2b: Create future class, reject manual transition to IN_PROGRESS before start_date
    c_fut_code = f"IELTS-FUT-{int(time.time())}"
    res_c_fut = client.post("/api/v1/classes/", json={
        "class_code": c_fut_code,
        "course_id": 1,
        "teacher_id": 2,
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": (date.today() + timedelta(days=10)).isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_fut.status_code == 200
    c_fut_id = res_c_fut.json()["data"]["id"]

    early_in_progress = client.patch(f"/api/v1/classes/{c_fut_id}/status?new_status=IN_PROGRESS", headers=headers)
    assert early_in_progress.status_code == 400
    assert "chưa đến ngày bắt đầu" in early_in_progress.json()["detail"].lower()
    print("✓ 26.2b. Transition to IN_PROGRESS Before Start Date Rejected: PASSED (400 Bad Request)")

    # 26.2c: Reject manual transition to COMPLETED before end_date
    early_completed = client.patch(f"/api/v1/classes/{c_life_id}/status?new_status=COMPLETED", headers=headers)
    assert early_completed.status_code == 400
    assert "chưa đến ngày kết thúc" in early_completed.json()["detail"].lower()
    print("✓ 26.2c. Transition to COMPLETED Before End Date Rejected: PASSED (400 Bad Request)")

    # 26.2d: Reject modifying status of COMPLETED class (Class 11 is COMPLETED)
    mod_completed = client.patch(f"/api/v1/classes/11/status?new_status=IN_PROGRESS", headers=headers)
    assert mod_completed.status_code == 400
    assert "không thể thay đổi trạng thái" in mod_completed.json()["detail"].lower()
    print("✓ 26.2d. Status Modification on COMPLETED Class Rejected: PASSED (400 Bad Request)")

    # 26.3: Enrollment does NOT generate GradeRecord in OPEN_FOR_ENROLLMENT
    # Create open class
    c_open_code = f"IELTS-OPEN-{int(time.time())}"
    res_c_open = client.post("/api/v1/classes/", json={
        "class_code": c_open_code,
        "course_id": 1,
        "teacher_id": 2,
        "max_capacity": 20,
        "opening_date": date.today().isoformat(),
        "start_date": (date.today() + timedelta(days=7)).isoformat(),
        "end_date": (date.today() + timedelta(days=60)).isoformat()
    }, headers=headers)
    assert res_c_open.status_code == 200
    c_open_id = res_c_open.json()["data"]["id"]

    enroll_open_res = client.post("/api/v1/enrollments/", json={
        "class_id": c_open_id,
        "note": "Đăng ký lớp mở để kiểm thử không sinh GradeRecord"
    }, headers=stu_headers)
    assert enroll_open_res.status_code == 200
    enroll_req_id = enroll_open_res.json()["data"]["id"]

    # Verify in DB: Student enrolled in ClassStudent, but NO GradeRecord exists!
    db_chk = TestSessionLocal()
    try:
        from app.modules.grades.models import GradeRecord as GrModel
        from app.modules.classes.models import ClassStudent as CsModel
        cs_exists = db_chk.query(CsModel).filter(
            CsModel.class_id == c_open_id,
            CsModel.student_id == 1,
            CsModel.status == "ENROLLED",
            CsModel.is_deleted == False
        ).first()
        assert cs_exists is not None

        gr_exists = db_chk.query(GrModel).filter(
            GrModel.class_id == c_open_id,
            GrModel.student_id == 1,
            GrModel.is_deleted == False
        ).first()
        assert gr_exists is None, "GradeRecord must NOT be auto-created during registration for OPEN_FOR_ENROLLMENT class"
    finally:
        db_chk.close()
    print("✓ 26.3. Enrollment in OPEN_FOR_ENROLLMENT Does Not Auto-Create GradeRecord: PASSED")

    # 26.4: Enrollment cancellation soft-deletes unconfirmed GradeRecord if any existed
    # Add a mock unconfirmed grade record to test soft delete on drop
    db_mock = TestSessionLocal()
    try:
        gr_mock = GrModel(class_id=c_open_id, student_id=1, result_status="PENDING", is_confirmed=False)
        db_mock.add(gr_mock)
        db_mock.commit()
    finally:
        db_mock.close()

    cancel_enr = client.patch(f"/api/v1/enrollments/{enroll_req_id}/cancel", headers=stu_headers)
    assert cancel_enr.status_code == 200, f"Expected 200: {cancel_enr.text}"

    db_chk2 = TestSessionLocal()
    try:
        gr_active = db_chk2.query(GrModel).filter(
            GrModel.class_id == c_open_id,
            GrModel.student_id == 1,
            GrModel.is_deleted == False
        ).first()
        assert gr_active is None, "Pending/unconfirmed GradeRecord must be soft-deleted on enrollment cancel"
    finally:
        db_chk2.close()
    print("✓ 26.4. Enrollment Cancellation Soft-Deletes Unconfirmed GradeRecord: PASSED")

    # 26.5: Transfer blocked from COMPLETED source class
    tf_completed = client.post("/api/v1/classes/transfer", json={
        "current_class_id": 11,
        "target_class_id": 4,
        "reason": "Thử chuyển từ lớp đã hoàn thành"
    }, headers=stu_headers)
    assert tf_completed.status_code == 400
    assert "lớp hiện tại đang ở trạng thái" in tf_completed.json()["detail"].lower()
    print("✓ 26.5. Transfer Out of COMPLETED Class Rejected: PASSED (400 Bad Request)")

    # 26.6: Ended class locks grades without forcing is_confirmed = True on empty grades
    db_end = TestSessionLocal()
    try:
        from app.modules.classes.models import Class as ClsModel
        from app.modules.grades.service import GradeService as GrService
        cls_end = db_end.query(ClsModel).filter(ClsModel.id == c_life_id).first()
        cls_end.end_date = date.today() - timedelta(days=2)
        # Create unconfirmed grade record with no marks
        empty_gr = GrModel(class_id=c_life_id, student_id=2, result_status="PENDING", is_confirmed=False)
        db_end.add(empty_gr)
        db_end.commit()

        is_locked, msg = GrService.check_and_update_class_grade_lock(db_end, cls_end)
        assert is_locked is True
        # Verify empty_gr was NOT forced to is_confirmed = True!
        db_end.refresh(empty_gr)
        assert empty_gr.is_confirmed is False
    finally:
        db_end.close()
    print("✓ 26.6. Ended Class Locks Grades Without Forcing Confirmation on Empty Grades: PASSED")

    # 26.7: Accessing grading sheet on a class in PLANNING state is rejected
    # Class 10 is PLANNING
    plan_sheet = client.get("/api/v1/grades/classes/10/sheet", headers=headers)
    assert plan_sheet.status_code == 400, f"Expected 400: {plan_sheet.text}"
    assert "lập kế hoạch" in plan_sheet.json()["detail"].lower()
    print("✓ 26.7. Accessing Grading Sheet on PLANNING Class Rejected: PASSED (400 Bad Request)")

    # Clean up test classes
    client.delete(f"/api/v1/classes/{c_life_id}", headers=headers)
    client.delete(f"/api/v1/classes/{c_fut_id}", headers=headers)
    client.delete(f"/api/v1/classes/{c_open_id}", headers=headers)

    print("\n🎉 ALL BACKEND INTEGRATION TESTS PASSED (100% SUCCESS)!")

def run_tests():
    try:
        _do_run_tests()
    finally:
        app.dependency_overrides.clear()
        try:
            test_engine.dispose()
        except Exception:
            pass
        try:
            app_engine.dispose()
        except Exception:
            pass
        if TEST_DB_PATH.exists():
            try:
                TEST_DB_PATH.unlink()
            except Exception:
                pass

if __name__ == "__main__":
    run_tests()
