import sys
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")
from datetime import date, timedelta
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

    # Staff creates a new test class
    cls_create_res = client.post("/api/v1/classes/", json={
        "class_code": "TEST-CANCEL-99",
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
        "room_code": "LAB-TEST-99",
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

    print("\n🎉 ALL BACKEND INTEGRATION TESTS PASSED (100% SUCCESS)!")

if __name__ == "__main__":
    run_tests()
