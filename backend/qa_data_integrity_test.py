"""QA - Phase 6: Data & Integrity test suite (SMART-EDU LMS).

Run against a FRESHLY SEEDED isolated SQLite DB:
  $env:DATABASE_URL='sqlite:///D:/OOAD/backend/_qa_test.db'
  python seed.py
  python -m pytest qa_data_integrity_test.py -q

Covers: seed referential integrity, duplicate enrollment, capacity overflow,
orphan grades (cancel/transfer), explicit end_date handling, ticket-code
burst uniqueness, grade sheet capacity, confirmed-grade cancellation,
teacher grading non-roster students, invalid input and progression resubmit.
"""
import sys
import uuid
from concurrent.futures import ThreadPoolExecutor
from datetime import date, timedelta

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import func

from app.main import app
from app.core.database import SessionLocal
from app.models import User as UserModel
from app.models import Student, Class, ClassStudent, GradeRecord, EnrollmentRequest

BASE = "/api/v1"
client = TestClient(app)


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
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


def _db():
    return SessionLocal()


def register_student(prefix="dq"):
    """Self-register a STUDENT; returns (headers, student_id, user_id)."""
    suffix = uuid.uuid4().hex[:10]
    username = f"{prefix}_{suffix}"
    r = client.post(f"{BASE}/auth/register", json={
        "username": username,
        "email": f"{username}@student.edu.vn",
        "full_name": f"Data Quality {suffix}",
        "password": "Student123",
        "role": "STUDENT",
    })
    assert r.status_code == 200, r.text
    headers = {"Authorization": f"Bearer {r.json()['data']['access_token']}"}
    db = _db()
    try:
        user_id = db.query(UserModel.id).filter(UserModel.username == username).scalar()
        student_id = db.query(Student.id).filter(Student.user_id == user_id).scalar()
    finally:
        db.close()
    assert user_id and student_id
    return headers, student_id, user_id


def create_class(headers, code, capacity=20, course_id=1, teacher_id=1,
                 start_offset=10, end_offset=40, explicit_end=True):
    today = date.today()
    body = {
        "class_code": code,
        "course_id": course_id,
        "teacher_id": teacher_id,
        "max_capacity": capacity,
        "opening_date": str(today),
        "start_date": str(today + timedelta(days=start_offset)),
    }
    if explicit_end:
        body["end_date"] = str(today + timedelta(days=end_offset))
    r = client.post(f"{BASE}/classes/", json=body, headers=headers)
    assert r.status_code == 200, r.text
    return r.json()["data"]


def enroll(student_headers, class_id, note="Data integrity enrollment"):
    r = client.post(f"{BASE}/enrollments/", json={"class_id": class_id, "note": note},
                    headers=student_headers)
    return r


def class_counters(class_id):
    db = _db()
    try:
        cls = db.query(Class).filter(Class.id == class_id).first()
        roster = db.query(func.count(ClassStudent.id)).filter(
            ClassStudent.class_id == class_id,
            ClassStudent.is_deleted == False,  # noqa: E712
        ).scalar()
        return cls.current_enrolled, cls.max_capacity, roster
    finally:
        db.close()


# --------------------------------------------------------------------------
# 1. Seed data integrity (read-only)
# --------------------------------------------------------------------------
def test_seed_referential_and_counter_integrity(auth):
    db = _db()
    try:
        classes = db.query(Class).filter(Class.is_deleted == False).all()  # noqa: E712
        for cls in classes:
            roster = db.query(func.count(ClassStudent.id)).filter(
                ClassStudent.class_id == cls.id,
                ClassStudent.is_deleted == False,  # noqa: E712
            ).scalar()
            assert roster == cls.current_enrolled, (
                f"class {cls.class_code}: current_enrolled={cls.current_enrolled} "
                f"but active roster={roster}"
            )
            assert 0 <= cls.current_enrolled <= cls.max_capacity, (
                f"class {cls.class_code}: invalid capacity {cls.current_enrolled}/{cls.max_capacity}"
            )

        # No orphan active roster/grade rows.
        db_ids = {r[0] for r in db.query(Class.id).all()}
        stu_ids = {r[0] for r in db.query(Student.id).all()}
        for cs in db.query(ClassStudent).filter(ClassStudent.is_deleted == False).all():  # noqa: E712
            assert cs.class_id in db_ids, f"orphan roster class {cs.class_id}"
            assert cs.student_id in stu_ids, f"orphan roster student {cs.student_id}"

        # A grade must always belong to an enrolled student (no ghost grades).
        for g in db.query(GradeRecord).filter(GradeRecord.is_deleted == False).all():  # noqa: E712
            assert g.class_id in db_ids, f"orphan grade class {g.class_id}"
            assert g.student_id in stu_ids, f"orphan grade student {g.student_id}"
            enrolled = db.query(ClassStudent.id).filter(
                ClassStudent.class_id == g.class_id,
                ClassStudent.student_id == g.student_id,
                ClassStudent.is_deleted == False,  # noqa: E712
            ).first()
            assert enrolled, (
                f"ghost grade: class {g.class_id} / student {g.student_id} "
                "has no active roster entry"
            )

        # No duplicate active roster pairs.
        dup = db.query(
            ClassStudent.class_id, ClassStudent.student_id,
            func.count(ClassStudent.id).label("n")
        ).filter(ClassStudent.is_deleted == False).group_by(  # noqa: E712
            ClassStudent.class_id, ClassStudent.student_id
        ).having(func.count(ClassStudent.id) > 1).all()
        assert not dup, f"duplicate roster pairs: {dup}"
    finally:
        db.close()


# --------------------------------------------------------------------------
# 2. Class creation: explicit end_date and date ordering
# --------------------------------------------------------------------------
def test_create_class_preserves_explicit_end_date(auth):
    today = date.today()
    code = f"DQ-ENDDATE-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, start_offset=10, end_offset=30)
    assert cls["end_date"] == str(today + timedelta(days=30)), (
        f"explicit end_date was overwritten: got {cls['end_date']}"
    )


def test_create_class_rejects_end_date_before_start_date(auth):
    today = date.today()
    code = f"DQ-BADDATE-{uuid.uuid4().hex[:6].upper()}"
    r = client.post(f"{BASE}/classes/", json={
        "class_code": code,
        "course_id": 1,
        "teacher_id": 1,
        "max_capacity": 10,
        "opening_date": str(today),
        "start_date": str(today + timedelta(days=20)),
        "end_date": str(today + timedelta(days=10)),
    }, headers=auth["admin"])
    assert r.status_code in (400, 422), (
        f"end_date before start_date accepted: {r.status_code} {r.text}"
    )


# --------------------------------------------------------------------------
# 3. Ticket code burst uniqueness (same second)
# --------------------------------------------------------------------------
def test_ticket_codes_are_unique_under_burst(auth):
    def create_one(i):
        r = client.post(f"{BASE}/tickets/", json={
            "ticket_type": "REQUEST",
            "category": "ENROLLMENT",
            "title": f"Burst uniqueness probe {i}",
            "content": f"Burst content {i} for ticket-code uniqueness",
            "receiver_role": "ACADEMIC_STAFF",
        }, headers=auth["student"])
        return r.status_code, r.text, (r.json().get("data") or {}).get("ticket_code") if r.status_code == 200 else None

    with ThreadPoolExecutor(max_workers=4) as pool:
        results = list(pool.map(create_one, range(6)))

    failures = [(s, t) for s, t, _ in results if s != 200]
    assert not failures, f"concurrent ticket creation failed: {failures}"
    created = [code for _, _, code in results]
    assert all(created), f"missing ticket codes: {created}"
    assert len(created) == len(set(created)), f"duplicate ticket codes: {created}"


# --------------------------------------------------------------------------
# 4. Teacher cannot create grades for a student outside the class roster
# --------------------------------------------------------------------------
def test_teacher_cannot_grade_non_roster_student(auth):
    db = _db()
    try:
        roster_ids = {r[0] for r in db.query(ClassStudent.student_id).filter(
            ClassStudent.class_id == 1,
            ClassStudent.is_deleted == False,  # noqa: E712
        ).all()}
        outsider = db.query(Student.id).filter(Student.id.notin_(roster_ids)).first()[0]
        existing = db.query(GradeRecord).filter(
            GradeRecord.class_id == 1,
            GradeRecord.student_id == outsider,
            GradeRecord.is_deleted == False,  # noqa: E712
        ).first()
        assert existing is None
    finally:
        db.close()

    r = client.post(f"{BASE}/grades/batch", json={
        "class_id": 1,
        "grades": [{
            "student_id": outsider,
            "attendance_score": 8.0,
            "midterm_score": 8.0,
            "final_score": 8.0,
        }],
    }, headers=auth["teacher"])
    assert r.status_code == 400, (
        f"grade for non-roster student accepted: {r.status_code} {r.text}"
    )

    db = _db()
    try:
        ghost = db.query(GradeRecord.id).filter(
            GradeRecord.class_id == 1,
            GradeRecord.student_id == outsider,
            GradeRecord.is_deleted == False,  # noqa: E712
        ).first()
        assert ghost is None, "ghost grade row was persisted"
    finally:
        db.close()


# --------------------------------------------------------------------------
# 5. Transfer must not leave a stale active grade in the old class
# --------------------------------------------------------------------------
def test_transfer_moves_grade_out_of_old_class(auth):
    headers, sid, _ = register_student("dq_transfer")
    add = client.post(f"{BASE}/classes/1/students", json={"student_id": sid},
                      headers=auth["admin"])
    assert add.status_code == 200, add.text

    save = client.post(f"{BASE}/grades/batch", json={
        "class_id": 1,
        "grades": [{
            "student_id": sid,
            "attendance_score": 7.0,
            "midterm_score": 7.5,
            "final_score": 8.0,
        }],
    }, headers=auth["teacher"])
    assert save.status_code == 200, save.text

    tr = client.post(f"{BASE}/classes/transfer", json={
        "current_class_id": 1,
        "target_class_id": 4,
        "reason": "Data integrity transfer test",
    }, headers=headers)
    assert tr.status_code == 200, tr.text

    db = _db()
    try:
        old_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == 1,
            GradeRecord.student_id == sid,
            GradeRecord.is_deleted == False,  # noqa: E712
        ).first()
        new_grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == 4,
            GradeRecord.student_id == sid,
            GradeRecord.is_deleted == False,  # noqa: E712
        ).first()
        assert old_grade is None, "stale active grade remains in the old class"
        assert new_grade is not None, "grade was not moved to the target class"
        old_roster = db.query(ClassStudent).filter(
            ClassStudent.class_id == 1, ClassStudent.student_id == sid,
            ClassStudent.is_deleted == False,  # noqa: E712
        ).first()
        assert old_roster is None, "old roster entry still active"
    finally:
        db.close()

    mg = client.get(f"{BASE}/grades/my-grades", headers=headers)
    assert mg.status_code == 200, mg.text
    class_ids = [g["class_id"] for g in mg.json()["data"]]
    assert 4 in class_ids, f"target class grade missing from my-grades: {class_ids}"
    assert 1 not in class_ids, f"old class grade still visible after transfer: {class_ids}"

    _, _, roster = class_counters(4)
    assert roster >= 1


# --------------------------------------------------------------------------
# 6. Adding a student to the grading sheet must respect capacity
# --------------------------------------------------------------------------
def test_grading_sheet_add_cannot_overflow_capacity(auth):
    code = f"DQ-CAP-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, capacity=1)
    cid = cls["id"]

    h1, sid1, _ = register_student("dq_cap1")
    r1 = enroll(h1, cid)
    assert r1.status_code == 200, r1.text

    _, sid2, _ = register_student("dq_cap2")
    r2 = client.post(f"{BASE}/grades/classes/{cid}/students",
                     json={"student_id": sid2}, headers=auth["admin"])
    assert r2.status_code == 400, (
        f"grading-sheet add overflowed capacity: {r2.status_code} {r2.text}"
    )
    current, maximum, roster = class_counters(cid)
    assert current == 1 and maximum == 1 and roster == 1, (
        f"capacity drift after rejected add: {current}/{maximum}, roster={roster}"
    )


# --------------------------------------------------------------------------
# 7. Cancelling enrollment after grade seal must be blocked
# --------------------------------------------------------------------------
def test_cancel_enrollment_blocked_after_grade_confirmed(auth):
    code = f"DQ-SEAL-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, capacity=5)
    cid = cls["id"]

    h, sid, _ = register_student("dq_seal")
    er = enroll(h, cid)
    assert er.status_code == 200, er.text
    enrollment_id = er.json()["data"]["id"]

    save = client.post(f"{BASE}/grades/batch", json={
        "class_id": cid,
        "grades": [{
            "student_id": sid,
            "attendance_score": 9.0,
            "midterm_score": 8.0,
            "final_score": 8.5,
        }],
    }, headers=auth["teacher"])
    assert save.status_code == 200, save.text

    confirm = client.patch(f"{BASE}/grades/classes/{cid}/confirm",
                           json={"reason": "Data integrity seal"}, headers=auth["staff"])
    assert confirm.status_code == 200, confirm.text

    cancel = client.patch(f"{BASE}/enrollments/{enrollment_id}/cancel", headers=h)
    assert cancel.status_code == 400, (
        f"cancelled an enrollment whose grades are sealed: {cancel.status_code} {cancel.text}"
    )

    db = _db()
    try:
        grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == cid,
            GradeRecord.student_id == sid,
            GradeRecord.is_deleted == False,  # noqa: E712
        ).first()
        assert grade is not None and grade.is_confirmed, "sealed grade was removed/changed"
        cs = db.query(ClassStudent).filter(
            ClassStudent.class_id == cid, ClassStudent.student_id == sid,
            ClassStudent.is_deleted == False,  # noqa: E712
        ).first()
        assert cs is not None, "roster entry was dropped despite sealed grade"
        req = db.query(EnrollmentRequest).filter(EnrollmentRequest.id == enrollment_id).first()
        assert req.status == "APPROVED", f"enrollment status changed to {req.status}"
    finally:
        db.close()


# --------------------------------------------------------------------------
# 8. Cancel before grade seal must clean the unconfirmed grade (no orphan)
# --------------------------------------------------------------------------
def test_cancel_before_seal_removes_unconfirmed_grade(auth):
    code = f"DQ-ORPHAN-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, capacity=5)
    cid = cls["id"]

    h, sid, _ = register_student("dq_orphan")
    er = enroll(h, cid)
    assert er.status_code == 200, er.text
    enrollment_id = er.json()["data"]["id"]

    sheet = client.get(f"{BASE}/grades/classes/{cid}/sheet", headers=auth["teacher"])
    assert sheet.status_code == 200, sheet.text

    cancel = client.patch(f"{BASE}/enrollments/{enrollment_id}/cancel", headers=h)
    assert cancel.status_code == 200, cancel.text

    db = _db()
    try:
        active = db.query(GradeRecord).filter(
            GradeRecord.class_id == cid,
            GradeRecord.student_id == sid,
            GradeRecord.is_deleted == False,  # noqa: E712
        ).first()
        assert active is None, "unconfirmed grade left active after cancellation"
    finally:
        db.close()

    current, _, roster = class_counters(cid)
    assert current == 0 and roster == 0, f"capacity drift after cancel: {current}, roster={roster}"


# --------------------------------------------------------------------------
# 9. Rejected progression can be resubmitted
# --------------------------------------------------------------------------
def test_rejected_progression_can_be_resubmitted(auth):
    h, sid, _ = register_student("dq_prog")
    er = enroll(h, 2)  # course 2 (open class)
    assert er.status_code == 200, er.text

    payload = {"next_course_id": 1, "current_course_id": 2,
               "note": "Resubmission integrity test"}
    first = client.post(f"{BASE}/progression/request", json=payload, headers=h)
    assert first.status_code == 200, first.text
    prog = first.json()["data"]
    assert prog["is_confirmed"] is False, f"ineligible progression auto-confirmed: {prog}"

    rej = client.patch(f"{BASE}/progression/{prog['id']}/reject",
                       json={"reason": "Chưa đủ điều kiện"}, headers=auth["staff"])
    assert rej.status_code == 200, rej.text

    second = client.post(f"{BASE}/progression/request", json=payload, headers=h)
    assert second.status_code == 200, (
        f"rejected progression cannot be resubmitted: {second.status_code} {second.text}"
    )
    assert second.json()["data"]["id"] != prog["id"]


# --------------------------------------------------------------------------
# 10. Sequential duplicate / capacity / invalid input guards
# --------------------------------------------------------------------------
def test_duplicate_and_invalid_enrollment_data(auth):
    h, sid, _ = register_student("dq_dupe")
    first = enroll(h, 2)
    assert first.status_code == 200, first.text
    second = enroll(h, 2)
    assert second.status_code == 400, f"duplicate enrollment accepted: {second.text}"

    # Non-existent class -> 404 (no ghost enrollment row)
    ghost = enroll(h, 999999)
    assert ghost.status_code == 404, f"ghost class enrollment: {ghost.status_code} {ghost.text}"

    db = _db()
    try:
        n = db.query(func.count(EnrollmentRequest.id)).filter(
            EnrollmentRequest.student_id == sid,
            EnrollmentRequest.class_id == 999999,
        ).scalar()
        assert n == 0, "ghost enrollment request persisted"
    finally:
        db.close()


def test_sequential_capacity_overflow_rejected(auth):
    code = f"DQ-FULL-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, capacity=1)
    cid = cls["id"]

    h1, _, _ = register_student("dq_full1")
    assert enroll(h1, cid).status_code == 200
    h2, _, _ = register_student("dq_full2")
    r2 = enroll(h2, cid)
    assert r2.status_code == 400, f"capacity overflow accepted: {r2.text}"
    current, maximum, roster = class_counters(cid)
    assert current == 1 and roster == 1 and maximum == 1


def test_invalid_scores_and_duplicate_class_code(auth):
    bad_score = client.post(f"{BASE}/grades/batch", json={
        "class_id": 1,
        "grades": [{
            "student_id": 1,
            "attendance_score": 11.0,
            "midterm_score": 8.0,
            "final_score": 8.0,
        }],
    }, headers=auth["teacher"])
    assert bad_score.status_code == 422, (
        f"out-of-range score accepted: {bad_score.status_code} {bad_score.text}"
    )

    dup_code = client.post(f"{BASE}/classes/", json={
        "class_code": "IELTS-65-K26A",
        "course_id": 1,
        "teacher_id": 1,
        "max_capacity": 10,
        "opening_date": str(date.today()),
    }, headers=auth["admin"])
    assert dup_code.status_code == 400, f"duplicate class_code accepted: {dup_code.text}"


# --------------------------------------------------------------------------
# 11. Concurrent capacity (double-submit race)
# --------------------------------------------------------------------------
def test_concurrent_enrollment_respects_capacity(auth):
    code = f"DQ-RACE-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, capacity=1)
    cid = cls["id"]

    h1, _, _ = register_student("dq_race1")
    h2, _, _ = register_student("dq_race2")

    def attempt(headers):
        r = enroll(headers, cid)
        return r.status_code

    with ThreadPoolExecutor(max_workers=2) as pool:
        statuses = list(pool.map(attempt, [h1, h2]))

    assert statuses.count(200) == 1, f"expected exactly one success, got {statuses}"
    current, maximum, roster = class_counters(cid)
    assert current == 1 and roster == 1 and maximum == 1, (
        f"capacity/roster drift under concurrency: {current}/{maximum}, roster={roster}, statuses={statuses}"
    )


def test_concurrent_duplicate_enrollment_creates_one_roster(auth):
    code = f"DQ-RACE2-{uuid.uuid4().hex[:6].upper()}"
    cls = create_class(auth["admin"], code, capacity=5)
    cid = cls["id"]
    h, sid, _ = register_student("dq_race_dupe")

    def attempt():
        return enroll(h, cid).status_code

    with ThreadPoolExecutor(max_workers=2) as pool:
        statuses = list(pool.map(lambda _: attempt(), range(2)))

    assert statuses.count(200) >= 1, f"no enrollment succeeded: {statuses}"
    db = _db()
    try:
        rows = db.query(func.count(ClassStudent.id)).filter(
            ClassStudent.class_id == cid,
            ClassStudent.student_id == sid,
            ClassStudent.is_deleted == False,  # noqa: E712
        ).scalar()
    finally:
        db.close()
    assert rows == 1, f"duplicate roster rows after concurrent double-submit: {rows}"
    current, _, roster = class_counters(cid)
    assert current == 1 and roster == 1, f"counter drift: {current}, roster={roster}"
