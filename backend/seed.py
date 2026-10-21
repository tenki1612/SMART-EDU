import sys
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")
from datetime import date, datetime, timedelta, timezone
from app.core.database import engine, SessionLocal, Base
from app.core.security import get_password_hash
from app.core.permissions import RoleEnum
from app.models import (
    User, Course, Student, Teacher, Classroom, Class, ClassStudent,
    EnrollmentRequest, ScheduleSession, GradeRecord
)
from app.modules.progression_parent.models import CourseProgression, ParentStudent

def seed_database():
    print("⏳ Creating database tables...")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        print("🌱 Seeding Users (5 Roles)...")
        # 1. Admin
        admin = User(
            username="admin",
            email="admin@center.edu.vn",
            full_name="Nguyễn Văn Quản Trị (Admin)",
            hashed_password=get_password_hash("admin123"),
            role=RoleEnum.ADMIN,
            phone="0901234567"
        )
        # 2. Academic Staff
        staff = User(
            username="staff",
            email="staff@center.edu.vn",
            full_name="Trần Thị Học Vụ (Staff)",
            hashed_password=get_password_hash("staff123"),
            role=RoleEnum.ACADEMIC_STAFF,
            phone="0912345678"
        )
        # 3. Teacher
        user_teacher = User(
            username="teacher",
            email="teacher@center.edu.vn",
            full_name="ThS. Lê Hoàng Nam (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456789"
        )
        # 4. Student
        user_student = User(
            username="student",
            email="student@center.edu.vn",
            full_name="Phạm Minh Khang (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567890"
        )
        # 5. Parent
        user_parent = User(
            username="parent",
            email="parent@center.edu.vn",
            full_name="Phạm Quốc Hùng (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678901"
        )
        db.add_all([admin, staff, user_teacher, user_student, user_parent])
        db.commit()

        # Profiles
        teacher_profile = Teacher(
            user_id=user_teacher.id,
            teacher_code="GV2026-001",
            specialty="IELTS 8.0 & Academic Writing",
            degree="Master of Applied Linguistics",
            status="ACTIVE"
        )
        student_profile = Student(
            user_id=user_student.id,
            student_code="HV2026-001",
            date_of_birth=date(2005, 5, 15),
            address="123 Nguyễn Văn Cừ, Quận 5, TP.HCM",
            status="ACTIVE"
        )
        db.add_all([teacher_profile, student_profile])
        db.commit()

        # Parent-Student Link (FR-81)
        parent_link = ParentStudent(
            parent_user_id=user_parent.id,
            student_id=student_profile.id,
            relationship_type="Bố ruột"
        )
        db.add(parent_link)

        print("🌱 Seeding Courses (FR-11 -> FR-17)...")
        c1 = Course(
            code="IELTS-PREP-65",
            title="Luyện thi IELTS Chuyên Sâu 6.5+",
            description="Khóa học tập trung rèn luyện 4 kỹ năng chuẩn học thuật với mục tiêu đầu ra IELTS 6.5.",
            target_level="IELTS 6.5",
            duration_weeks=12,
            fee=8500000.0,
            is_active=True
        )
        c2 = Course(
            code="IELTS-MASTER-75",
            title="Luyện thi IELTS Master 7.5+",
            description="Khóa học nâng cao dành cho học viên đã đạt IELTS 6.5 muốn bứt phá lên 7.5+.",
            target_level="IELTS 7.5",
            duration_weeks=12,
            fee=10500000.0,
            is_active=True
        )
        c3 = Course(
            code="TOEIC-INTENSIVE-750",
            title="TOEIC Cấp Tốc 750+",
            description="Chinh phục kỳ thi TOEIC 2 kỹ năng Nghe - Đọc đạt chuẩn đầu ra đại học và đi làm.",
            target_level="TOEIC 750",
            duration_weeks=8,
            fee=5200000.0,
            is_active=True
        )
        db.add_all([c1, c2, c3])
        db.commit()

        print("🌱 Seeding Classrooms (FR-42 -> FR-49)...")
        r1 = Classroom(room_code="P.101", building="Tòa nhà A", capacity=30, status="AVAILABLE")
        r2 = Classroom(room_code="P.102", building="Tòa nhà A", capacity=25, status="AVAILABLE")
        r3 = Classroom(room_code="LAB.201", building="Tòa nhà B (Phòng máy)", capacity=35, status="AVAILABLE")
        r4 = Classroom(room_code="P.301", building="Tòa nhà C", capacity=20, status="MAINTENANCE")
        db.add_all([r1, r2, r3, r4])
        db.commit()

        print("🌱 Seeding Classes (FR-32 -> FR-41)...")
        cls1 = Class(
            class_code="IELTS-65-K26A",
            course_id=c1.id,
            teacher_id=teacher_profile.id,
            max_capacity=20,
            current_enrolled=1,
            start_date=date(2026, 11, 1),
            end_date=date(2027, 1, 24),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls2 = Class(
            class_code="TOEIC-750-K12",
            course_id=c3.id,
            teacher_id=teacher_profile.id,
            max_capacity=25,
            current_enrolled=0,
            start_date=date(2026, 11, 15),
            end_date=date(2027, 1, 15),
            status="OPEN_FOR_ENROLLMENT"
        )
        db.add_all([cls1, cls2])
        db.commit()

        # Enroll student into cls1
        enrollment_member = ClassStudent(
            class_id=cls1.id,
            student_id=student_profile.id,
            status="ENROLLED"
        )
        db.add(enrollment_member)

        # Enrollment Request (FR-50 -> FR-60)
        req = EnrollmentRequest(
            student_id=student_profile.id,
            class_id=cls1.id,
            status="APPROVED",
            note="Học viên đã nộp học phí qua chuyển khoản",
            reviewed_by=staff.id,
            reviewed_at=datetime.now(timezone.utc)
        )
        db.add(req)

        print("🌱 Seeding Schedules (FR-61 -> FR-68)...")
        today = date.today()
        # Schedule next Monday and Wednesday
        s1 = ScheduleSession(
            class_id=cls1.id,
            classroom_id=r1.id,
            teacher_id=teacher_profile.id,
            session_date=today + timedelta(days=2),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s2 = ScheduleSession(
            class_id=cls1.id,
            classroom_id=r1.id,
            teacher_id=teacher_profile.id,
            session_date=today + timedelta(days=4),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        db.add_all([s1, s2])

        print("🌱 Seeding Grades (FR-69 -> FR-77)...")
        gr = GradeRecord(
            class_id=cls1.id,
            student_id=student_profile.id,
            attendance_score=9.5,
            midterm_score=7.5,
            final_score=8.0,
            total_score=8.1,
            result_status="PASSED",
            is_confirmed=False,
            note="Học viên tiếp thu tốt, phát âm chuẩn, hoàn thành xuất sắc mục tiêu đầu ra 6.5."
        )
        db.add(gr)

        print("🌱 Seeding Progression (FR-78 -> FR-80)...")
        prog = CourseProgression(
            student_id=student_profile.id,
            current_course_id=c1.id,
            next_course_id=c2.id,
            is_eligible=True,
            is_confirmed=True,
            confirmed_by=staff.id,
            confirmed_at=datetime.now(timezone.utc),
            note="Học viên đã đạt 8.1 ở khóa IELTS 6.5, đủ điều kiện học lên lớp IELTS Master 7.5+."
        )
        db.add(prog)

        db.commit()
        print("✅ Seed database completed successfully!")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
