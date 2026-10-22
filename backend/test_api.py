import sys
import time
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")
from datetime import date, timedelta, datetime
from fastapi.testclient import TestClient
from app.main import app

def run_tests():
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
    seeded_date = (date.today() + timedelta(days=2)).isoformat()
    conflict_res = client.post("/api/v1/schedules/check-conflicts", json={
        "classroom_id": 1,
        "teacher_id": 1,
        "session_date": seeded_date,
        "start_time": "18:30",
        "end_time": "19:30"
    })
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
        "note": "Kiểm thử đăng ký và hủy đơn khi PENDING"
    }, headers=s_headers)
    assert req_create.status_code == 200
    req_id = req_create.json()["data"]["id"]
    assert req_create.json()["data"]["status"] == "PENDING"

    # Student cancels the pending request
    req_cancel = client.patch(f"/api/v1/enrollments/{req_id}/cancel", headers=s_headers)
    assert req_cancel.status_code == 200
    print("✓ 8.1. Student Enrollment Cancellation when PENDING: PASSED")

    # Test that canceling an already APPROVED request fails (seeded request 1 is APPROVED)
    approved_cancel = client.patch("/api/v1/enrollments/1/cancel", headers=s_headers)
    assert approved_cancel.status_code in (400, 422) or not approved_cancel.json().get("success", True)
    print("✓ 8.2. Prevent Cancellation when APPROVED: PASSED")

    # Clean up test class
    client.delete(f"/api/v1/classes/{test_cls_id}", headers=staff_headers)

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
    otp_code = forgot_res.json()["data"]["reset_code"]
    assert len(otp_code) == 6
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

    print("\n🎉 ALL BACKEND INTEGRATION TESTS PASSED (100% SUCCESS)!")

if __name__ == "__main__":
    run_tests()
