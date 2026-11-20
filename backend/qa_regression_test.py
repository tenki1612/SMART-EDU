"""QA regression tests for confirmed security/logic findings.
Run against a FRESHLY SEEDED isolated SQLite DB:
  $env:DATABASE_URL='sqlite:///D:/OOAD/backend/_qa_test.db'
  python -m pytest qa_regression_test.py -q
"""
import sys
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models import User as UserModel

BASE = "/api/v1"
client = TestClient(app)


@pytest.fixture(scope="module")
def auth():
    def login(u, p):
        r = client.post(f"{BASE}/auth/login", json={"username": u, "password": p})
        assert r.status_code == 200, r.text
        return {"Authorization": f"Bearer {r.json()['data']['access_token']}"}
    return {
        "admin": login("admin", "admin123"),
        "staff": login("staff", "staff123"),
        "teacher": login("teacher", "teacher123"),
        "teacher2": login("teacher2", "teacher123"),
        "student": login("student", "student123"),
        "parent": login("parent", "parent123"),
    }


def test_otp_never_leaked_in_http_response(auth):
    r = client.post(f"{BASE}/auth/forgot-password", json={"identifier": "student"})
    assert r.status_code == 200
    assert "reset_code" not in r.json()["data"], "OTP must not be returned to the client"
    db = SessionLocal()
    try:
        otp = db.query(UserModel.reset_token).filter(UserModel.username == "student").scalar()
    finally:
        db.close()
    assert otp and len(otp) == 6


def test_hardcoded_jwt_secret_is_rejected():
    import jwt
    from datetime import datetime, timedelta, timezone
    token = jwt.encode(
        {"sub": "1", "role": "ADMIN", "exp": datetime.now(timezone.utc) + timedelta(days=1)},
        "super-secret-key-change-in-production-language-center-2026",
        algorithm="HS256",
    )
    r = client.get(f"{BASE}/accounts/", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 401, f"forged token accepted: {r.status_code}"


def test_student_cannot_read_another_students_pii(auth):
    assert client.get(f"{BASE}/students/2", headers=auth["student"]).status_code == 403
    assert client.get(f"{BASE}/students/2/history", headers=auth["student"]).status_code == 403


def test_parent_cannot_read_unrelated_class_roster(auth):
    # Parent's ward is in class 1; class 2 is unrelated.
    assert client.get(f"{BASE}/classes/2/students", headers=auth["parent"]).status_code == 403
    assert client.get(f"{BASE}/classes/1/students", headers=auth["parent"]).status_code == 200


def test_lock_status_and_history_are_scoped(auth):
    assert client.get(f"{BASE}/grades/classes/1/lock-history", headers=auth["teacher2"]).status_code == 403
    # Student 1 is enrolled in class 1, but not in class 2.
    assert client.get(f"{BASE}/grades/classes/2/lock-status", headers=auth["student"]).status_code == 403
    # teacher of class 1 still allowed
    assert client.get(f"{BASE}/grades/classes/1/lock-history", headers=auth["teacher"]).status_code == 200


def test_resolved_ticket_cannot_be_reprocessed(auth):
    # Ensure the sheet is locked so the unlock request can be created.
    client.post(f"{BASE}/grades/classes/1/confirm", json={"reason": "lock before test"}, headers=auth["staff"])
    req = client.post(f"{BASE}/tickets/", json={
        "ticket_type": "REQUEST", "category": "GRADE_UNLOCK",
        "title": "Regression unlock request", "content": "Regression test content",
        "related_class_id": 1, "receiver_role": "ACADEMIC_STAFF"
    }, headers=auth["teacher"])
    assert req.status_code == 200, req.text
    tid = req.json()["data"]["id"]
    ap1 = client.patch(f"{BASE}/tickets/{tid}/status", json={"status": "APPROVED"}, headers=auth["staff"])
    assert ap1.status_code == 200, ap1.text
    assert client.post(f"{BASE}/grades/classes/1/confirm", json={"reason": "relock"}, headers=auth["staff"]).status_code == 200
    ap2 = client.patch(f"{BASE}/tickets/{tid}/status", json={"status": "APPROVED"}, headers=auth["staff"])
    assert ap2.status_code == 400, f"re-processing was allowed: {ap2.text}"
    status = client.get(f"{BASE}/grades/classes/1/lock-status", headers=auth["staff"]).json()["data"]
    assert status["is_locked"] is True, "re-approval must not unlock the grade sheet"


def test_teacher_inbox_does_not_leak_other_teachers_complaints(auth):
    c = client.post(f"{BASE}/tickets/", json={
        "ticket_type": "COMPLAINT", "category": "GRADE",
        "title": "Regression grade complaint", "content": "Regression complaint content",
        "related_class_id": 1
    }, headers=auth["student"])
    assert c.status_code == 200, c.text
    t1 = client.get(f"{BASE}/tickets/inbox", headers=auth["teacher"]).json()["data"]
    t2 = client.get(f"{BASE}/tickets/inbox", headers=auth["teacher2"]).json()["data"]
    assert any(x["title"] == "Regression grade complaint" for x in t1)
    assert not any(x["title"] == "Regression grade complaint" for x in t2), "teacher2 leaked class-1 complaint"


def test_whitespace_only_ticket_content_rejected(auth):
    r = client.post(f"{BASE}/tickets/", json={
        "ticket_type": "REQUEST", "category": "ENROLLMENT",
        "title": "   ", "content": "     ", "receiver_role": "ACADEMIC_STAFF"
    }, headers=auth["student"])
    assert r.status_code == 422, f"whitespace accepted: {r.status_code}"


def test_progression_cannot_be_bypassed(auth):
    import time
    # Freshly registered student has no PASSED grade in any prior course.
    uname = f"noskill_{int(time.time())}"
    reg = client.post(f"{BASE}/auth/register", json={
        "username": uname, "email": f"{uname}@student.edu.vn",
        "full_name": "No Skill Student", "password": "Student123", "role": "STUDENT"
    })
    assert reg.status_code == 200, reg.text
    token = reg.json()["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    classes = client.get(f"{BASE}/classes/", headers=auth["admin"]).json()["data"]
    target = next((c["id"] for c in classes if c.get("course_id") == 2), classes[-1]["id"])
    r = client.post(f"{BASE}/progression/register-next", params={"target_class_id": target}, headers=headers)
    assert r.status_code == 400, f"progression bypass succeeded: {r.status_code} {r.text}"


def test_protected_endpoints_require_auth():
    assert client.post(f"{BASE}/schedules/check-conflicts", json={
        "classroom_id": 1, "teacher_id": 1, "session_date": "2026-12-01",
        "start_time": "08:00", "end_time": "10:00"
    }).status_code == 401
    assert client.get(f"{BASE}/courses/1").status_code == 401


def test_class_capacity_must_be_positive(auth):
    r = client.post(f"{BASE}/classes/", json={
        "class_code": "REG-ZERO-CAP", "course_id": 1, "teacher_id": 1,
        "max_capacity": 0, "opening_date": "2026-12-01"
    }, headers=auth["admin"])
    assert r.status_code == 422, f"zero capacity accepted: {r.status_code}"
