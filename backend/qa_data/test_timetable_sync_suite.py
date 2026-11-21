"""
Comprehensive Automated Test Suite for SMART-EDU Timetable Synchronization
Verifying Class -> Schedule -> Session -> Timetable across Start/End Bounds, Roles, and Filters.
"""

import os
import sys

# Safe test database validation (OBS-01)
sys.path.insert(0, 'backend')
from qa_data.safety_guard import validate_test_database_target
validate_test_database_target(is_destructive=True)
from datetime import date, timedelta
from fastapi.testclient import TestClient

from app.main import app
from app.core.database import SessionLocal
from app.modules.schedules.models import ScheduleSession
from app.modules.classes.models import Class
from app.modules.schedules.schemas import ScheduleRecurringCreate
from app.modules.schedules.service import ScheduleService

client = TestClient(app)

def run_suite():
    passed = 0
    failed = 0

    def test(desc, condition, detail=""):
        nonlocal passed, failed
        if condition:
            passed += 1
            print(f"  ✓ {desc}: PASSED {detail}")
        else:
            failed += 1
            print(f"  ✗ {desc}: FAILED {detail}")

    print("======================================================================")
    print("TEST SUITE: SMART-EDU TIMETABLE SYNCHRONIZATION & DATE BOUNDS VERIFICATION")
    print("======================================================================\n")

    # -------------------------------------------------------------
    # 1. Verification of Target Class IELTS-65-K26A in Database
    # -------------------------------------------------------------
    print("[1] Kiểm tra dữ liệu lớp học trọng điểm IELTS-65-K26A:")
    db = SessionLocal()
    c1 = db.query(Class).filter(Class.id == 1).first()
    test("Class 1 exists in DB", c1 is not None, f"Code: {c1.class_code if c1 else 'None'}")
    test("Class 1 start_date is 2026-11-01", c1.start_date == date(2026, 11, 1))
    test("Class 1 end_date is 2027-01-24", c1.end_date == date(2027, 1, 24))

    # All sessions of Class 1
    c1_sessions = db.query(ScheduleSession).filter(
        ScheduleSession.class_id == 1,
        ScheduleSession.is_deleted == False
    ).order_by(ScheduleSession.session_date.asc(), ScheduleSession.start_time.asc()).all()

    test("Class 1 has full recurring schedule (count = 24)", len(c1_sessions) == 24, f"Actual: {len(c1_sessions)} sessions")
    test("First session >= start_date", c1_sessions[0].session_date >= c1.start_date, f"First: {c1_sessions[0].session_date}")
    test("Last session <= end_date", c1_sessions[-1].session_date <= c1.end_date, f"Last: {c1_sessions[-1].session_date}")

    # Check monthly breakdown
    nov_count = sum(1 for s in c1_sessions if s.session_date.month == 11 and s.session_date.year == 2026)
    dec_count = sum(1 for s in c1_sessions if s.session_date.month == 12 and s.session_date.year == 2026)
    jan_count = sum(1 for s in c1_sessions if s.session_date.month == 1 and s.session_date.year == 2027)

    test("Coverage includes November 2026 (9 sessions)", nov_count == 9, f"Nov sessions: {nov_count}")
    test("Coverage includes December 2026 (9 sessions)", dec_count == 9, f"Dec sessions: {dec_count}")
    test("Coverage includes January 2027 (6 sessions)", jan_count == 6, f"Jan sessions: {jan_count}")

    # -------------------------------------------------------------
    # 2. Logic Test: Recurring Session Generation Engine
    # -------------------------------------------------------------
    print("\n[2] Kiểm tra logic engine sinh buổi học lặp lại (generate_recurring_sessions):")
    # Generate for an isolated test range in May-June 2027 (8 weeks x 2 sessions = 16)
    test_start = date(2027, 5, 3) # Monday
    test_end = date(2027, 6, 27)  # Sunday
    rec_req = ScheduleRecurringCreate(
        class_id=1,
        classroom_id=8, # HALL.101
        teacher_id=1,
        days_of_week=[0, 2], # Monday, Wednesday
        start_time="20:00",
        end_time="22:00",
        slot_name="Ca tối 2 (20:00 - 22:00)",
        start_date=test_start,
        end_date=test_end,
        is_confirmed=True
    )
    rec_result = ScheduleService.generate_recurring_sessions(db, rec_req)
    test("Engine successfully generated 8 weeks x 2 sessions = 16 sessions", rec_result["created_count"] == 16, f"Generated: {rec_result['created_count']}")

    # Idempotency test: calling again must skip already existing
    rec_rerun = ScheduleService.generate_recurring_sessions(db, rec_req)
    test("Idempotency: re-running generation skips existing sessions", rec_rerun["created_count"] == 0 and rec_rerun["skipped_count"] == 16)

    # Clean up test sessions
    db.query(ScheduleSession).filter(
        ScheduleSession.class_id == 1,
        ScheduleSession.session_date >= test_start,
        ScheduleSession.session_date <= test_end,
        ScheduleSession.classroom_id == 8
    ).delete()
    db.commit()

    # -------------------------------------------------------------
    # 3. API Test: Date Range Filtering & Pagination Safety
    # -------------------------------------------------------------
    print("\n[3] Kiểm tra API lọc thời khóa biểu theo khoảng ngày (from_date / to_date):")
    admin_login = client.post("/api/v1/auth/login", json={"username": "admin", "password": "admin123"})
    admin_token = admin_login.json()["data"]["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # Query December 2026
    dec_res = client.get("/api/v1/schedules/?class_id=1&from_date=2026-12-01&to_date=2026-12-31", headers=admin_headers)
    test("API query December 2026 returns status 200", dec_res.status_code == 200)
    dec_data = dec_res.json()["data"]
    test("All returned sessions fall strictly in December 2026", all(s["session_date"].startswith("2026-12") for s in dec_data) and len(dec_data) == dec_count, f"Count: {len(dec_data)}")

    # Query January 2027
    jan_res = client.get("/api/v1/schedules/?class_id=1&from_date=2027-01-01&to_date=2027-01-31", headers=admin_headers)
    test("API query January 2027 returns status 200", jan_res.status_code == 200)
    jan_data = jan_res.json()["data"]
    test("All returned sessions fall strictly in January 2027", all(s["session_date"].startswith("2027-01") for s in jan_data) and len(jan_data) == jan_count, f"Count: {len(jan_data)}")

    # -------------------------------------------------------------
    # 4. Role-based Access Control (RBAC) on Timetable
    # -------------------------------------------------------------
    print("\n[4] Kiểm tra phân quyền truy cập thời khóa biểu (RBAC):")
    # Admin sees all
    all_res = client.get("/api/v1/schedules/", headers=admin_headers)
    total_all = len(all_res.json()["data"])
    test("ADMIN sees total active timetable across all classes (>= 180)", total_all >= 180, f"Total sessions: {total_all}")

    # Teacher 1 sees only their teaching sessions
    t1_login = client.post("/api/v1/auth/login", json={"username": "teacher", "password": "teacher123"})
    t1_token = t1_login.json()["data"]["access_token"]
    t1_headers = {"Authorization": f"Bearer {t1_token}"}
    t1_res = client.get("/api/v1/schedules/", headers=t1_headers)
    test("TEACHER 1 schedules endpoint status 200", t1_res.status_code == 200)
    t1_data = t1_res.json()["data"]
    test("TEACHER 1 strictly sees teacher_id == 1", len(t1_data) > 0 and all(s["teacher_id"] == 1 for s in t1_data), f"Teacher 1 sessions: {len(t1_data)}")

    # Teacher 2 sees only teacher 2
    t2_login = client.post("/api/v1/auth/login", json={"username": "teacher2", "password": "teacher123"})
    if t2_login.status_code == 200:
        t2_token = t2_login.json()["data"]["access_token"]
        t2_res = client.get("/api/v1/schedules/", headers={"Authorization": f"Bearer {t2_token}"})
        t2_data = t2_res.json()["data"]
        test("TEACHER 2 strictly sees teacher_id == 2", all(s["teacher_id"] == 2 for s in t2_data), f"Teacher 2 sessions: {len(t2_data)}")

    # Student personal schedule
    stu_login = client.post("/api/v1/auth/login", json={"username": "student", "password": "student123"})
    stu_token = stu_login.json()["data"]["access_token"]
    stu_headers = {"Authorization": f"Bearer {stu_token}"}
    stu_res = client.get("/api/v1/schedules/personal", headers=stu_headers)
    test("STUDENT personal schedule returns status 200", stu_res.status_code == 200)
    stu_sessions = stu_res.json()["data"]
    test("STUDENT timetable spans the entire duration of Class IELTS-65-K26A", len(stu_sessions) >= 24, f"Student sessions: {len(stu_sessions)}")
    test("STUDENT sessions contain required bound attributes", all("class_start_date" in s and "class_end_date" in s for s in stu_sessions))

    # -------------------------------------------------------------
    # 5. Non-interference Check: Other classes session integrity
    # -------------------------------------------------------------
    print("\n[5] Kiểm tra bảo toàn dữ liệu và không ảnh hưởng tiêu cực tới các lớp khác:")
    other_classes = [3, 4, 5, 6, 7, 8, 9]
    for oc in other_classes:
        cnt = db.query(ScheduleSession).filter(ScheduleSession.class_id == oc, ScheduleSession.is_deleted == False).count()
        cls_obj = db.query(Class).filter(Class.id == oc).first()
        code_str = cls_obj.class_code if cls_obj else f"ID {oc}"
        test(f"Class {oc:2d} ({code_str:15s}) has complete schedule (> 15 sessions)", cnt >= 15, f"Count: {cnt}")

    db.close()

    print("\n======================================================================")
    print(f"RESULTS: {passed} PASSED, {failed} FAILED")
    print("======================================================================")
    return failed == 0

if __name__ == "__main__":
    success = run_suite()
    sys.exit(0 if success else 1)
