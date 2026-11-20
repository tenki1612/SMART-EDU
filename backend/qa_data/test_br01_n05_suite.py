import os
import sys
import shutil
import sqlite3
from datetime import date, timedelta

# Safety Assertion: Never run on real database!
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REAL_DB_PATH = os.path.join(BASE_DIR, "language_center.db")
TEST_DB_PATH = os.path.join(BASE_DIR, "qa_data", "test_br01_n05.db")

assert os.path.abspath(TEST_DB_PATH) != os.path.abspath(REAL_DB_PATH), "FATAL: Test DB must be isolated!"

# Copy real DB to test DB for mutation testing
shutil.copyfile(REAL_DB_PATH, TEST_DB_PATH)
print(f"Isolated test database created at: {TEST_DB_PATH}")

# Point DATABASE_URL to test DB
os.environ["DATABASE_URL"] = f"sqlite:///{TEST_DB_PATH.replace(os.sep, '/')}"

sys.path.insert(0, BASE_DIR)
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.database import Base
from app.modules.classes.models import Class, ClassStudent
from app.modules.courses.models import Course
from app.modules.grades.models import GradeRecord
from app.modules.students.models import Student
from app.modules.accounts.models import User
from app.modules.enrollments.models import EnrollmentRequest
from app.modules.enrollments.service import EnrollmentService
from app.modules.enrollments.schemas import EnrollmentCreateRequest
from app.modules.classes.service import ClassService
from app.modules.schedules.models import ScheduleSession
from app.modules.schedules.service import ScheduleService
from app.modules.schedules.schemas import ScheduleRecurringCreate
from app.modules.progression_parent.models import CourseProgression
from app.core.exceptions import BusinessException

engine = create_engine(f"sqlite:///{TEST_DB_PATH.replace(os.sep, '/')}", connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

passed_count = 0
failed_count = 0

def test(name, condition, detail=""):
    global passed_count, failed_count
    if condition:
        print(f"  [PASS] {name}")
        passed_count += 1
    else:
        print(f"  [FAIL] {name} - {detail}")
        failed_count += 1

print("\n=== TEST SUITE: BR-01 PREREQUISITE CONDITION & N-05 TIMETABLE ===")

EXACT_ERROR = "Bạn chưa đạt yêu cầu của lớp học cấp độ hiện tại. Vui lòng hoàn thành và PASS lớp học trước khi đăng ký lớp cấp độ cao hơn."
EXACT_SUCCESS = "Bạn đã hoàn thành và PASS lớp học trước đó. Bạn đủ điều kiện đăng ký lớp học này."

# --- BR-01 TESTS ---
print("\n--- Testing BR-01: Prerequisite Condition ---")

# 1. Target Level Prerequisite mapping
test("IELTS 7.5 requires 6.5", EnrollmentService.get_prerequisite_target_level("IELTS 7.5") == "6.5")
test("IELTS 6.5 requires 5.0", EnrollmentService.get_prerequisite_target_level("IELTS 6.5") == "5.0")
test("IELTS 5.0 is entry level", EnrollmentService.get_prerequisite_target_level("IELTS 5.0") is None)
test("TOEIC 750 requires 550", EnrollmentService.get_prerequisite_target_level("TOEIC 750") == "550")
test("TOEIC 550 is entry level", EnrollmentService.get_prerequisite_target_level("TOEIC 550") is None)
test("COMM B1 requires A2", EnrollmentService.get_prerequisite_target_level("CEFR B1") == "A2")
test("COMM A2 is entry level", EnrollmentService.get_prerequisite_target_level("CEFR A2") is None)

# Find student and classes for testing
student = db.query(Student).filter(Student.is_deleted == False).first()
assert student is not None, "Need at least one student in DB"

# Find IELTS 5.0, 6.5, 7.5 classes
class_ielts_50 = db.query(Class).join(Course, Class.course_id == Course.id).filter(
    Course.target_level.ilike("%5.0%"), Class.is_deleted == False
).first()

class_ielts_65 = db.query(Class).join(Course, Class.course_id == Course.id).filter(
    Course.target_level.ilike("%6.5%"), Class.is_deleted == False
).first()

class_ielts_75 = db.query(Class).join(Course, Class.course_id == Course.id).filter(
    Course.target_level.ilike("%7.5%"), Class.is_deleted == False
).first()

print(f"Test student ID: {student.id}")
print(f"IELTS 5.0 class: {class_ielts_50.class_code if class_ielts_50 else 'None'}")
print(f"IELTS 6.5 class: {class_ielts_65.class_code if class_ielts_65 else 'None'}")
print(f"IELTS 7.5 class: {class_ielts_75.class_code if class_ielts_75 else 'None'}")

# Clean existing records for test student in test DB
db.query(GradeRecord).filter(GradeRecord.student_id == student.id).delete()
db.query(ClassStudent).filter(ClassStudent.student_id == student.id).delete()
db.query(EnrollmentRequest).filter(EnrollmentRequest.student_id == student.id).delete()
db.query(CourseProgression).filter(CourseProgression.student_id == student.id).delete()
db.commit()

# Test 2: Student with NO records registers for Entry Level (IELTS 5.0) -> MUST SUCCEED
is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_50.id)
test("No prereq required for IELTS 5.0 (Entry Level)", is_elig is True, msg)

# Test 3: Student with NO records registers for Higher Level (IELTS 6.5) -> MUST FAIL with exact message
is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_65.id)
test("Blocked from IELTS 6.5 with no prerequisite", is_elig is False and msg == EXACT_ERROR, f"Got: {msg}")

# Test 4: Student enrolled in IELTS 5.0 but NOT passed (e.g. FAILED) -> MUST FAIL with exact message
cs_50 = ClassStudent(class_id=class_ielts_50.id, student_id=student.id, status="ENROLLED")
db.add(cs_50)
grade_failed = GradeRecord(class_id=class_ielts_50.id, student_id=student.id, result_status="FAILED", is_confirmed=True)
db.add(grade_failed)
db.commit()

is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_65.id)
test("Blocked from IELTS 6.5 when failed IELTS 5.0", is_elig is False and msg == EXACT_ERROR, f"Got: {msg}")

# Test 5: Student studying IELTS 5.0 (grade unconfirmed / PENDING) -> MUST FAIL with exact message
grade_failed.result_status = "PASSED"
grade_failed.is_confirmed = False # Not yet locked / confirmed
db.commit()

is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_65.id)
test("Blocked from IELTS 6.5 when grade unconfirmed", is_elig is False and msg == EXACT_ERROR, f"Got: {msg}")

# Test 6: Student has completed & PASSED IELTS 5.0 (is_confirmed == True) -> MUST SUCCEED with exact message
grade_failed.result_status = "PASSED"
grade_failed.is_confirmed = True
db.commit()

is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_65.id)
test("Allowed to enroll IELTS 6.5 when PASSED IELTS 5.0", is_elig is True and msg == EXACT_SUCCESS, f"Got: {msg}")

# Test 7: Student passed 5.0 but wants to enroll in 7.5 directly -> MUST FAIL (needs 6.5)
is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_75.id)
test("Blocked from IELTS 7.5 when only passed IELTS 5.0", is_elig is False and msg == EXACT_ERROR, f"Got: {msg}")

# Test 8: CourseProgression approval bypass
cp = CourseProgression(
    student_id=student.id,
    current_course_id=class_ielts_65.course_id,
    next_course_id=class_ielts_75.course_id,
    is_eligible=True,
    is_confirmed=True
)
db.add(cp)
db.commit()

is_elig, msg = EnrollmentService.check_prerequisite_eligibility(db, student.id, class_ielts_75.id)
test("Allowed to enroll IELTS 7.5 with approved CourseProgression", is_elig is True and msg == EXACT_SUCCESS, f"Got: {msg}")

# Clean up CP for next test
db.delete(cp)
db.commit()

# Test 9: Enforcement on EnrollmentService.create_request
# Reset class status for enrollment
class_ielts_75.status = "OPEN_FOR_ENROLLMENT"
class_ielts_75.current_enrolled = 0
db.commit()

try:
    EnrollmentService.create_request(db, student.id, EnrollmentCreateRequest(class_id=class_ielts_75.id, note="Test"))
    test("EnrollmentService.create_request blocks ineligible student", False, "Should have raised BusinessException")
except BusinessException as e:
    test("EnrollmentService.create_request blocks ineligible student", e.detail == EXACT_ERROR, str(e))

# Test 10: Enforcement on ClassService.add_student_to_roster
try:
    ClassService.add_student_to_roster(db, class_ielts_75.id, student.id)
    test("ClassService.add_student_to_roster blocks ineligible student", False, "Should have raised BusinessException")
except BusinessException as e:
    test("ClassService.add_student_to_roster blocks ineligible student", e.detail == EXACT_ERROR, str(e))


# --- N-05 TESTS: TIMETABLE RECURRING GENERATION ---
print("\n--- Testing N-05: Recurring Timetable Generation ---")

# Setup a clean test class with known date range
test_class = class_ielts_50
start_d = date(2026, 11, 2)  # Monday
end_d = date(2027, 1, 25)    # Monday (12 weeks)
test_class.start_date = start_d
test_class.end_date = end_d
db.commit()

# Delete existing sessions for test class in test DB
db.query(ScheduleSession).filter(ScheduleSession.class_id == test_class.id).delete()
db.commit()

# Teacher and classroom
teacher = test_class.teacher_id or 1
classroom_id = 1

recurring_req = ScheduleRecurringCreate(
    class_id=test_class.id,
    classroom_id=classroom_id,
    teacher_id=teacher,
    days_of_week=[0, 2],  # Monday and Wednesday (0=Mon, 2=Wed)
    start_time="18:00",
    end_time="19:30",
    slot_name="Ca tối (18:00 - 19:30)",
    start_date=start_d,
    end_date=end_d
)

res = ScheduleService.generate_recurring_sessions(db, recurring_req)
created_count = res["created_count"]
print(f"Generated {created_count} sessions across {res['start_date']} to {res['end_date']}")

test("Generated sessions count > 0", created_count > 0, f"Count: {created_count}")

# Verify session dates
sessions = db.query(ScheduleSession).filter(
    ScheduleSession.class_id == test_class.id,
    ScheduleSession.is_deleted == False
).order_by(ScheduleSession.session_date.asc()).all()

test("Session count in DB matches result", len(sessions) == created_count)
test("First session >= start_date", sessions[0].session_date >= start_d)
test("Last session <= end_date", sessions[-1].session_date <= end_d)

# Verify all sessions are either Monday or Wednesday
all_mon_wed = all(s.session_date.weekday() in [0, 2] for s in sessions)
test("All sessions fall strictly on Monday or Wednesday", all_mon_wed)

# Verify sessions span across December 2026 and January 2027 (full coverage)
has_nov = any(s.session_date.month == 11 for s in sessions)
has_dec = any(s.session_date.month == 12 for s in sessions)
has_jan = any(s.session_date.month == 1 for s in sessions)
test("Coverage includes November 2026", has_nov)
test("Coverage includes December 2026", has_dec)
test("Coverage includes January 2027", has_jan)

# Test idempotency: re-running recurring generation skips existing sessions
res_rerun = ScheduleService.generate_recurring_sessions(db, recurring_req)
test("Re-running generation skips existing sessions", res_rerun["created_count"] == 0 and res_rerun["skipped_count"] == created_count)

# Clean up test DB
db.close()
engine.dispose()
if os.path.exists(TEST_DB_PATH):
    try:
        os.remove(TEST_DB_PATH)
        print(f"\nCleaned up isolated test database: {TEST_DB_PATH}")
    except Exception as e:
        print(f"\nNote: Test database will be cleaned on next run ({e})")

print(f"\n=== SUMMARY: {passed_count} PASSED, {failed_count} FAILED ===")
assert failed_count == 0, f"{failed_count} tests failed!"
