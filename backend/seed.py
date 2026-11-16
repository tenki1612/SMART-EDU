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
        print("🌱 Seeding Users (5 Roles & Extended Accounts)...")
        # --- CORE USERS (IDs 1-6) ---
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
        # 3. Teacher 1 & 2
        user_teacher = User(
            username="teacher",
            email="teacher@center.edu.vn",
            full_name="ThS. Lê Hoàng Nam (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456789"
        )
        user_teacher2 = User(
            username="teacher2",
            email="teacher2@center.edu.vn",
            full_name="Cô Trần Thị Mai (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456788"
        )
        # 5. Core Student (Enrolled in cls1 only for strict isolation test)
        user_student = User(
            username="student",
            email="student@center.edu.vn",
            full_name="Phạm Minh Khang (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567890"
        )
        # 6. Core Parent
        user_parent = User(
            username="parent",
            email="parent@center.edu.vn",
            full_name="Phạm Quốc Hùng (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678901"
        )
        db.add_all([admin, staff, user_teacher, user_teacher2, user_student, user_parent])
        db.commit()

        # Core Profiles
        teacher_profile = Teacher(
            user_id=user_teacher.id,
            teacher_code="GV2026-001",
            specialty="IELTS 8.5 & Academic Writing",
            degree="Master of Applied Linguistics",
            status="ACTIVE"
        )
        teacher_profile2 = Teacher(
            user_id=user_teacher2.id,
            teacher_code="GV2026-002",
            specialty="TOEIC 900 & Giao tiếp phản xạ",
            degree="Bachelor of English Pedagogy",
            status="ACTIVE"
        )
        student_profile = Student(
            user_id=user_student.id,
            student_code="26-04001",
            date_of_birth=date(2005, 5, 15),
            address="123 Nguyễn Văn Cừ, Quận 5, TP.HCM",
            status="ACTIVE"
        )
        db.add_all([teacher_profile, teacher_profile2, student_profile])
        db.commit()

        # Core Parent-Student Link
        parent_link = ParentStudent(
            parent_user_id=user_parent.id,
            student_id=student_profile.id,
            relationship_type="Bố ruột"
        )
        db.add(parent_link)
        db.commit()

        # --- EXTENDED TEACHERS ---
        print("🌱 Seeding Extended Teachers...")
        user_teacher_david = User(
            username="teacher_david",
            email="david.wilson@center.edu.vn",
            full_name="ThS. David Wilson (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456781"
        )
        user_teacher_my = User(
            username="teacher_my",
            email="nguyen.thaomy@center.edu.vn",
            full_name="Cô Nguyễn Thảo My (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456782"
        )
        user_teacher_bao = User(
            username="teacher_bao",
            email="hoang.quocbao@center.edu.vn",
            full_name="Thầy Hoàng Quốc Bảo (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456783"
        )
        user_teacher_phuong = User(
            username="teacher_phuong",
            email="vu.bichphuong@center.edu.vn",
            full_name="ThS. Vũ Bích Phương (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456784"
        )
        user_teacher_an = User(
            username="teacher_an",
            email="dang.hoaian@center.edu.vn",
            full_name="Thầy Đặng Hoài An (Teacher)",
            hashed_password=get_password_hash("teacher123"),
            role=RoleEnum.TEACHER,
            phone="0923456785"
        )
        db.add_all([user_teacher_david, user_teacher_my, user_teacher_bao, user_teacher_phuong, user_teacher_an])
        db.commit()

        teacher_david = Teacher(
            user_id=user_teacher_david.id,
            teacher_code="GV2026-003",
            specialty="IELTS Speaking & Native Pronunciation",
            degree="MA TESOL - University of Melbourne",
            status="ACTIVE"
        )
        teacher_my = Teacher(
            user_id=user_teacher_my.id,
            teacher_code="GV2026-004",
            specialty="Tiếng Anh Trẻ em & Ngữ pháp Chuyên sâu",
            degree="Cử nhân Sư phạm Tiếng Anh - ĐH Ngoại Ngữ",
            status="ACTIVE"
        )
        teacher_bao = Teacher(
            user_id=user_teacher_bao.id,
            teacher_code="GV2026-005",
            specialty="TOEIC 4 Kỹ năng & Tiếng Anh Doanh Nghiệp",
            degree="Cử nhân Ngôn ngữ Anh - ĐH Sư Phạm TP.HCM",
            status="ACTIVE"
        )
        teacher_phuong = Teacher(
            user_id=user_teacher_phuong.id,
            teacher_code="GV2026-006",
            specialty="IELTS Reading & Listening 9.0",
            degree="Thạc sĩ Giảng dạy Tiếng Anh (TESOL)",
            status="ACTIVE"
        )
        teacher_an = Teacher(
            user_id=user_teacher_an.id,
            teacher_code="GV2026-007",
            specialty="Tiếng Anh Giao Tiếp Thương Mại (Business English)",
            degree="MBA - British University Vietnam",
            status="ACTIVE"
        )
        db.add_all([teacher_david, teacher_my, teacher_bao, teacher_phuong, teacher_an])
        db.commit()

        # --- EXTENDED STUDENTS ---
        print("🌱 Seeding Extended Students...")
        user_st_tuan = User(
            username="student_tuan",
            email="student_tuan@center.edu.vn",
            full_name="Nguyễn Anh Tuấn (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567891"
        )
        user_st_chau = User(
            username="student_chau",
            email="student_chau@center.edu.vn",
            full_name="Lê Bảo Châu (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567892"
        )
        user_st_phuc = User(
            username="student_phuc",
            email="student_phuc@center.edu.vn",
            full_name="Trần Hoàng Phúc (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567893"
        )
        user_st_linh = User(
            username="student_linh",
            email="student_linh@center.edu.vn",
            full_name="Hoàng Diệu Linh (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567894"
        )
        user_st_dung = User(
            username="student_dung",
            email="student_dung@center.edu.vn",
            full_name="Đỗ Trí Dũng (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567895"
        )
        user_st_anh = User(
            username="student_anh",
            email="student_anh@center.edu.vn",
            full_name="Vũ Phương Anh (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567896"
        )
        user_st_huy = User(
            username="student_huy",
            email="student_huy@center.edu.vn",
            full_name="Bùi Quang Huy (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567897"
        )
        user_st_ngoc = User(
            username="student_ngoc",
            email="student_ngoc@center.edu.vn",
            full_name="Phan Bảo Ngọc (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567898"
        )
        user_st_nam = User(
            username="student_nam",
            email="student_nam@center.edu.vn",
            full_name="Hồ Hải Nam (Student)",
            hashed_password=get_password_hash("student123"),
            role=RoleEnum.STUDENT,
            phone="0934567899"
        )
        db.add_all([
            user_st_tuan, user_st_chau, user_st_phuc, user_st_linh, user_st_dung,
            user_st_anh, user_st_huy, user_st_ngoc, user_st_nam
        ])
        db.commit()

        st_tuan = Student(
            user_id=user_st_tuan.id,
            student_code="26-04002",
            date_of_birth=date(2004, 8, 20),
            address="45 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM",
            status="ACTIVE"
        )
        st_chau = Student(
            user_id=user_st_chau.id,
            student_code="26-04003",
            date_of_birth=date(2006, 3, 12),
            address="78 Lê Duẩn, Phường Bến Nghé, Quận 1, TP.HCM",
            status="ACTIVE"
        )
        st_phuc = Student(
            user_id=user_st_phuc.id,
            student_code="26-04004",
            date_of_birth=date(2005, 11, 25),
            address="215 Điện Biên Phủ, Phường 15, Quận Bình Thạnh, TP.HCM",
            status="ACTIVE"
        )
        st_linh = Student(
            user_id=user_st_linh.id,
            student_code="26-04005",
            date_of_birth=date(2007, 9, 8),
            address="52 Võ Văn Ngân, Phường Linh Chiểu, TP. Thủ Đức, TP.HCM",
            status="ACTIVE"
        )
        st_dung = Student(
            user_id=user_st_dung.id,
            student_code="26-04006",
            date_of_birth=date(2004, 1, 14),
            address="102 Cộng Hòa, Phường 4, Quận Tân Bình, TP.HCM",
            status="ACTIVE"
        )
        st_anh = Student(
            user_id=user_st_anh.id,
            student_code="26-04007",
            date_of_birth=date(2006, 6, 30),
            address="88 Nam Kỳ Khởi Nghĩa, Phường Võ Thị Sáu, Quận 3, TP.HCM",
            status="ACTIVE"
        )
        st_huy = Student(
            user_id=user_st_huy.id,
            student_code="26-04008",
            date_of_birth=date(2005, 4, 18),
            address="36 Nguyễn Thị Thập, Phường Tân Hưng, Quận 7, TP.HCM",
            status="ACTIVE"
        )
        st_ngoc = Student(
            user_id=user_st_ngoc.id,
            student_code="26-04009",
            date_of_birth=date(2006, 10, 5),
            address="19 Hoàng Hoa Thám, Phường 13, Quận Tân Bình, TP.HCM",
            status="ACTIVE"
        )
        st_nam = Student(
            user_id=user_st_nam.id,
            student_code="26-04010",
            date_of_birth=date(2005, 12, 22),
            address="64 Bạch Đằng, Phường 24, Quận Bình Thạnh, TP.HCM",
            status="ACTIVE"
        )
        db.add_all([st_tuan, st_chau, st_phuc, st_linh, st_dung, st_anh, st_huy, st_ngoc, st_nam])
        db.commit()

        # --- EXTENDED PARENTS & LINKS ---
        print("🌱 Seeding Extended Parents & Family Links...")
        user_parent_huong = User(
            username="parent_huong",
            email="parent_huong@center.edu.vn",
            full_name="Nguyễn Thị Hương (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678902"
        )
        user_parent_trong = User(
            username="parent_trong",
            email="parent_trong@center.edu.vn",
            full_name="Lê Đình Trọng (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678903"
        )
        user_parent_nam = User(
            username="parent_nam",
            email="parent_nam@center.edu.vn",
            full_name="Trần Văn Nam (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678904"
        )
        user_parent_ha = User(
            username="parent_ha",
            email="parent_ha@center.edu.vn",
            full_name="Hoàng Thu Hà (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678905"
        )
        user_parent_lien = User(
            username="parent_lien",
            email="parent_lien@center.edu.vn",
            full_name="Vũ Thị Kim Liên (Parent)",
            hashed_password=get_password_hash("parent123"),
            role=RoleEnum.PARENT,
            phone="0945678906"
        )
        db.add_all([user_parent_huong, user_parent_trong, user_parent_nam, user_parent_ha, user_parent_lien])
        db.commit()

        link_huong = ParentStudent(
            parent_user_id=user_parent_huong.id,
            student_id=st_tuan.id,
            relationship_type="Mẹ ruột"
        )
        link_trong = ParentStudent(
            parent_user_id=user_parent_trong.id,
            student_id=st_chau.id,
            relationship_type="Bố ruột"
        )
        link_nam = ParentStudent(
            parent_user_id=user_parent_nam.id,
            student_id=st_phuc.id,
            relationship_type="Bố ruột"
        )
        link_ha = ParentStudent(
            parent_user_id=user_parent_ha.id,
            student_id=st_linh.id,
            relationship_type="Mẹ ruột"
        )
        link_lien = ParentStudent(
            parent_user_id=user_parent_lien.id,
            student_id=st_anh.id,
            relationship_type="Mẹ ruột"
        )
        db.add_all([link_huong, link_trong, link_nam, link_ha, link_lien])
        db.commit()

        # --- COURSES ---
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
        c4 = Course(
            code="COMM-A2-BASIC",
            title="Tiếng Anh Giao Tiếp Nền Tảng A2",
            description="Xây dựng nền tảng phát âm chuẩn IPA, bổ sung 1000 từ vựng đời sống và luyện phản xạ giao tiếp tự nhiên.",
            target_level="A2 Elementary",
            duration_weeks=8,
            fee=3800000.0,
            is_active=True
        )
        c5 = Course(
            code="COMM-B1-FLUENT",
            title="Tiếng Anh Giao Tiếp Tự Tin B1+",
            description="Nâng cao khả năng diễn đạt lưu loát, thuyết trình, đàm phán công việc và tự tin giao tiếp với người bản xứ.",
            target_level="B1 Intermediate",
            duration_weeks=10,
            fee=4800000.0,
            is_active=True
        )
        c6 = Course(
            code="IELTS-FOUNDATION-50",
            title="Luyện thi IELTS Nền Tảng 5.0+",
            description="Khóa học xây dựng nền móng ngữ pháp, từ vựng học thuật và phương pháp làm quen cấu trúc đề thi 4 kỹ năng.",
            target_level="IELTS 5.0",
            duration_weeks=10,
            fee=6800000.0,
            is_active=True
        )
        c7 = Course(
            code="TOEIC-STARTER-550",
            title="TOEIC Mục Tiêu 550+",
            description="Trang bị các bẫy đề thi phổ biến, chiến lược phân bổ thời gian và mẹo xử lý đề thi TOEIC Nghe - Đọc chuẩn xác.",
            target_level="TOEIC 550",
            duration_weeks=8,
            fee=4200000.0,
            is_active=True
        )
        c8 = Course(
            code="TEENS-ACADEMIC-B2",
            title="Tiếng Anh Học Thuật Thiếu Niên B2",
            description="Phát triển tư duy phản biện, kỹ năng viết luận học thuật và thuyết trình tiếng Anh tự tin cho học sinh THCS/THPT.",
            target_level="B2 Upper-Intermediate",
            duration_weeks=12,
            fee=7500000.0,
            is_active=True
        )
        db.add_all([c1, c2, c3, c4, c5, c6, c7, c8])
        db.commit()

        # --- CLASSROOMS ---
        print("🌱 Seeding Classrooms (FR-42 -> FR-49)...")
        r1 = Classroom(room_code="P.101", building="Tòa nhà A", capacity=30, status="AVAILABLE")
        r2 = Classroom(room_code="P.102", building="Tòa nhà A", capacity=25, status="AVAILABLE")
        r3 = Classroom(room_code="LAB.201", building="Tòa nhà B (Phòng máy)", capacity=35, status="AVAILABLE")
        r4 = Classroom(room_code="P.301", building="Tòa nhà C", capacity=20, status="MAINTENANCE")
        r5 = Classroom(room_code="P.103", building="Tòa nhà A", capacity=30, status="AVAILABLE")
        r6 = Classroom(room_code="P.201", building="Tòa nhà A", capacity=25, status="AVAILABLE")
        r7 = Classroom(room_code="LAB.202", building="Tòa nhà B (Phòng máy)", capacity=30, status="AVAILABLE")
        r8 = Classroom(room_code="HALL.101", building="Tòa nhà C", capacity=80, status="AVAILABLE")
        r9 = Classroom(room_code="P.302", building="Tòa nhà C", capacity=15, status="AVAILABLE")
        r10 = Classroom(room_code="P.303", building="Tòa nhà C", capacity=20, status="AVAILABLE")
        db.add_all([r1, r2, r3, r4, r5, r6, r7, r8, r9, r10])
        db.commit()

        # --- CLASSES ---
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
            class_code="IELTS-75-K26A",
            course_id=c2.id,
            teacher_id=teacher_profile.id,
            max_capacity=20,
            current_enrolled=0,
            start_date=date(2026, 11, 20),
            end_date=date(2027, 2, 20),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls3 = Class(
            class_code="TOEIC-750-K12",
            course_id=c3.id,
            teacher_id=teacher_profile2.id,
            max_capacity=25,
            current_enrolled=3,
            start_date=date(2026, 11, 15),
            end_date=date(2027, 1, 15),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls4 = Class(
            class_code="IELTS-65-K26B",
            course_id=c1.id,
            teacher_id=teacher_david.id,
            max_capacity=20,
            current_enrolled=3,
            start_date=date(2026, 11, 10),
            end_date=date(2027, 2, 10),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls5 = Class(
            class_code="COMM-A2-K08",
            course_id=c4.id,
            teacher_id=teacher_my.id,
            max_capacity=20,
            current_enrolled=3,
            start_date=date(2026, 11, 5),
            end_date=date(2027, 1, 5),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls6 = Class(
            class_code="COMM-B1-K09",
            course_id=c5.id,
            teacher_id=teacher_an.id,
            max_capacity=18,
            current_enrolled=2,
            start_date=date(2026, 11, 12),
            end_date=date(2027, 1, 22),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls7 = Class(
            class_code="IELTS-50-K15",
            course_id=c6.id,
            teacher_id=teacher_phuong.id,
            max_capacity=22,
            current_enrolled=2,
            start_date=date(2026, 11, 8),
            end_date=date(2027, 1, 18),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls8 = Class(
            class_code="TOEIC-550-K30",
            course_id=c7.id,
            teacher_id=teacher_bao.id,
            max_capacity=25,
            current_enrolled=2,
            start_date=date(2026, 11, 15),
            end_date=date(2027, 1, 15),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls9 = Class(
            class_code="TEENS-B2-K04",
            course_id=c8.id,
            teacher_id=teacher_phuong.id,
            max_capacity=16,
            current_enrolled=2,
            start_date=date(2026, 11, 18),
            end_date=date(2027, 2, 18),
            status="OPEN_FOR_ENROLLMENT"
        )
        cls10 = Class(
            class_code="IELTS-75-K26B",
            course_id=c2.id,
            teacher_id=teacher_david.id,
            max_capacity=15,
            current_enrolled=0,
            start_date=date(2026, 12, 1),
            end_date=date(2027, 3, 1),
            status="PLANNING"
        )
        db.add_all([cls1, cls2, cls3, cls4, cls5, cls6, cls7, cls8, cls9, cls10])
        db.commit()

        # --- CLASS ENROLLMENTS (ClassStudent) ---
        print("🌱 Seeding Class Student Rosters...")
        # Enroll primary student into cls1 (Only cls1 for isolation test!)
        db.add(ClassStudent(class_id=cls1.id, student_id=student_profile.id, status="ENROLLED"))

        # Enroll other students
        db.add_all([
            # Class 3: TOEIC-750-K12
            ClassStudent(class_id=cls3.id, student_id=st_tuan.id, status="ENROLLED"),
            ClassStudent(class_id=cls3.id, student_id=st_phuc.id, status="ENROLLED"),
            ClassStudent(class_id=cls3.id, student_id=st_dung.id, status="ENROLLED"),
            # Class 4: IELTS-65-K26B
            ClassStudent(class_id=cls4.id, student_id=st_chau.id, status="ENROLLED"),
            ClassStudent(class_id=cls4.id, student_id=st_anh.id, status="ENROLLED"),
            ClassStudent(class_id=cls4.id, student_id=st_ngoc.id, status="ENROLLED"),
            # Class 5: COMM-A2-K08
            ClassStudent(class_id=cls5.id, student_id=st_linh.id, status="ENROLLED"),
            ClassStudent(class_id=cls5.id, student_id=st_huy.id, status="ENROLLED"),
            ClassStudent(class_id=cls5.id, student_id=st_nam.id, status="ENROLLED"),
            # Class 6: COMM-B1-K09
            ClassStudent(class_id=cls6.id, student_id=st_chau.id, status="ENROLLED"),
            ClassStudent(class_id=cls6.id, student_id=st_dung.id, status="ENROLLED"),
            # Class 7: IELTS-50-K15
            ClassStudent(class_id=cls7.id, student_id=st_linh.id, status="ENROLLED"),
            ClassStudent(class_id=cls7.id, student_id=st_nam.id, status="ENROLLED"),
            # Class 8: TOEIC-550-K30
            ClassStudent(class_id=cls8.id, student_id=st_tuan.id, status="ENROLLED"),
            ClassStudent(class_id=cls8.id, student_id=st_huy.id, status="ENROLLED"),
            # Class 9: TEENS-B2-K04
            ClassStudent(class_id=cls9.id, student_id=st_linh.id, status="ENROLLED"),
            ClassStudent(class_id=cls9.id, student_id=st_anh.id, status="ENROLLED")
        ])
        db.commit()

        # --- ENROLLMENT REQUESTS (FR-50 -> FR-60) ---
        print("🌱 Seeding Enrollment Requests...")
        # Request 1 (Must be ID=1, APPROVED for student_profile in cls1)
        req1 = EnrollmentRequest(
            student_id=student_profile.id,
            class_id=cls1.id,
            status="APPROVED",
            note="Học viên đã nộp học phí qua chuyển khoản",
            reviewed_by=staff.id,
            reviewed_at=datetime.now(timezone.utc)
        )
        db.add(req1)
        db.commit()

        req2 = EnrollmentRequest(
            student_id=st_tuan.id,
            class_id=cls3.id,
            status="APPROVED",
            note="Đăng ký thành công khóa TOEIC 750+, thanh toán tiền mặt tại quầy",
            reviewed_by=staff.id,
            reviewed_at=datetime.now(timezone.utc)
        )
        req3 = EnrollmentRequest(
            student_id=st_chau.id,
            class_id=cls4.id,
            status="APPROVED",
            note="Học viên đạt bài thi test đầu vào 6.0, được chấp nhận vào lớp 6.5+",
            reviewed_by=staff.id,
            reviewed_at=datetime.now(timezone.utc)
        )
        req4 = EnrollmentRequest(
            student_id=st_linh.id,
            class_id=cls5.id,
            status="APPROVED",
            note="Học viên đăng ký học giao tiếp nền tảng, hoàn tất học phí",
            reviewed_by=staff.id,
            reviewed_at=datetime.now(timezone.utc)
        )
        req5 = EnrollmentRequest(
            student_id=st_phuc.id,
            class_id=cls2.id,
            status="PENDING",
            note="Học viên đang kiểm tra lại lịch học trước khi chuyển khoản học phí",
            reviewed_by=None,
            reviewed_at=None
        )
        req6 = EnrollmentRequest(
            student_id=st_ngoc.id,
            class_id=cls7.id,
            status="PENDING",
            note="Học viên chuyển khoản qua ngân hàng, đang chờ kế toán đối soát mã giao dịch",
            reviewed_by=None,
            reviewed_at=None
        )
        req7 = EnrollmentRequest(
            student_id=st_dung.id,
            class_id=cls1.id,
            status="REJECTED",
            note="Đăng ký không thành công do chưa đạt bài kiểm tra đầu vào",
            rejection_reason="Điểm thi đầu vào 4.5 chưa đủ điều kiện theo học lớp IELTS 6.5+. Đã tư vấn chuyển sang lớp IELTS 5.0+.",
            reviewed_by=staff.id,
            reviewed_at=datetime.now(timezone.utc)
        )
        db.add_all([req2, req3, req4, req5, req6, req7])
        db.commit()

        # --- SCHEDULE SESSIONS (FR-61 -> FR-68) ---
        print("🌱 Seeding Schedules (FR-61 -> FR-68)...")
        today = date.today()
        # Cls1 sessions (Carefully placed on today + 1 as earliest session on r1 P.101 & teacher_profile for conflict detection test)
        s1 = ScheduleSession(
            class_id=cls1.id,
            classroom_id=r1.id,
            teacher_id=teacher_profile.id,
            session_date=today + timedelta(days=1),
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
            session_date=today + timedelta(days=3),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s3 = ScheduleSession(
            class_id=cls1.id,
            classroom_id=r1.id,
            teacher_id=teacher_profile.id,
            session_date=today + timedelta(days=8),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s4 = ScheduleSession(
            class_id=cls1.id,
            classroom_id=r1.id,
            teacher_id=teacher_profile.id,
            session_date=today + timedelta(days=10),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls3 (TOEIC 750 - Cô Mai) - Thứ 3, Thứ 5 - Ca 2 (14:00 - 16:00) tại P.102
        s5 = ScheduleSession(
            class_id=cls3.id,
            classroom_id=r2.id,
            teacher_id=teacher_profile2.id,
            session_date=today + timedelta(days=2),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s6 = ScheduleSession(
            class_id=cls3.id,
            classroom_id=r2.id,
            teacher_id=teacher_profile2.id,
            session_date=today + timedelta(days=4),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s7 = ScheduleSession(
            class_id=cls3.id,
            classroom_id=r2.id,
            teacher_id=teacher_profile2.id,
            session_date=today + timedelta(days=9),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls4 (IELTS 6.5B - Thầy David) - Thứ 2, Thứ 4 - Ca 3 (18:00 - 20:00) tại P.103
        s8 = ScheduleSession(
            class_id=cls4.id,
            classroom_id=r5.id,
            teacher_id=teacher_david.id,
            session_date=today + timedelta(days=2),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s9 = ScheduleSession(
            class_id=cls4.id,
            classroom_id=r5.id,
            teacher_id=teacher_david.id,
            session_date=today + timedelta(days=4),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s10 = ScheduleSession(
            class_id=cls4.id,
            classroom_id=r5.id,
            teacher_id=teacher_david.id,
            session_date=today + timedelta(days=9),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls5 (Giao tiếp A2 - Cô My) - Thứ 3, Thứ 5 - Ca 1 (08:00 - 10:00) tại P.201
        s11 = ScheduleSession(
            class_id=cls5.id,
            classroom_id=r6.id,
            teacher_id=teacher_my.id,
            session_date=today + timedelta(days=3),
            start_time="08:00",
            end_time="10:00",
            slot_name="Ca 1 (08:00 - 10:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s12 = ScheduleSession(
            class_id=cls5.id,
            classroom_id=r6.id,
            teacher_id=teacher_my.id,
            session_date=today + timedelta(days=5),
            start_time="08:00",
            end_time="10:00",
            slot_name="Ca 1 (08:00 - 10:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls6 (Giao tiếp B1 - Thầy An) - Thứ 2, Thứ 6 - Ca 3 (18:00 - 20:00) tại P.302 VIP
        s13 = ScheduleSession(
            class_id=cls6.id,
            classroom_id=r9.id,
            teacher_id=teacher_an.id,
            session_date=today + timedelta(days=2),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s14 = ScheduleSession(
            class_id=cls6.id,
            classroom_id=r9.id,
            teacher_id=teacher_an.id,
            session_date=today + timedelta(days=7),
            start_time="18:00",
            end_time="20:00",
            slot_name="Ca 3 (18:00 - 20:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls7 (IELTS 5.0 - Cô Phương) - Thứ 4, Thứ 6 - Ca 2 (14:00 - 16:00) tại LAB.202
        s15 = ScheduleSession(
            class_id=cls7.id,
            classroom_id=r7.id,
            teacher_id=teacher_phuong.id,
            session_date=today + timedelta(days=4),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s16 = ScheduleSession(
            class_id=cls7.id,
            classroom_id=r7.id,
            teacher_id=teacher_phuong.id,
            session_date=today + timedelta(days=7),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls8 (TOEIC 550 - Thầy Bảo) - Thứ 7, Chủ Nhật - Ca 1 (08:00 - 10:00) tại LAB.201
        s17 = ScheduleSession(
            class_id=cls8.id,
            classroom_id=r3.id,
            teacher_id=teacher_bao.id,
            session_date=today + timedelta(days=5),
            start_time="08:00",
            end_time="10:00",
            slot_name="Ca 1 (08:00 - 10:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s18 = ScheduleSession(
            class_id=cls8.id,
            classroom_id=r3.id,
            teacher_id=teacher_bao.id,
            session_date=today + timedelta(days=6),
            start_time="08:00",
            end_time="10:00",
            slot_name="Ca 1 (08:00 - 10:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        # Cls9 (Thiếu niên B2 - Cô Phương) - Thứ 7, Chủ Nhật - Ca 2 (14:00 - 16:00) tại P.303
        s19 = ScheduleSession(
            class_id=cls9.id,
            classroom_id=r10.id,
            teacher_id=teacher_phuong.id,
            session_date=today + timedelta(days=5),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )
        s20 = ScheduleSession(
            class_id=cls9.id,
            classroom_id=r10.id,
            teacher_id=teacher_phuong.id,
            session_date=today + timedelta(days=6),
            start_time="14:00",
            end_time="16:00",
            slot_name="Ca 2 (14:00 - 16:00)",
            is_confirmed=True,
            status="SCHEDULED"
        )

        db.add_all([
            s1, s2, s3, s4, s5, s6, s7, s8, s9, s10,
            s11, s12, s13, s14, s15, s16, s17, s18, s19, s20
        ])
        db.commit()

        # --- GRADES (FR-69 -> FR-77) ---
        print("🌱 Seeding Grades (FR-69 -> FR-77)...")
        gr1 = GradeRecord(
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
        # Grades for cls3 (TOEIC 750)
        gr2 = GradeRecord(
            class_id=cls3.id,
            student_id=st_tuan.id,
            attendance_score=9.0,
            midterm_score=8.5,
            final_score=8.0,
            total_score=8.4,
            result_status="PASSED",
            is_confirmed=False,
            note="Nắm rất chắc từ vựng kinh tế, làm phần Part 7 đọc hiểu xuất sắc."
        )
        gr3 = GradeRecord(
            class_id=cls3.id,
            student_id=st_phuc.id,
            attendance_score=8.5,
            midterm_score=7.0,
            final_score=7.5,
            total_score=7.6,
            result_status="PASSED",
            is_confirmed=False,
            note="Tiến bộ rõ rệt ở kỹ năng nghe Part 3 và Part 4."
        )
        gr4 = GradeRecord(
            class_id=cls3.id,
            student_id=st_dung.id,
            attendance_score=7.5,
            midterm_score=6.5,
            final_score=6.0,
            total_score=6.5,
            result_status="PASSED",
            is_confirmed=False,
            note="Cần cải thiện ngữ pháp thì quá khứ hoàn thành và mệnh đề quan hệ."
        )
        # Grades for cls4 (IELTS 6.5B)
        gr5 = GradeRecord(
            class_id=cls4.id,
            student_id=st_chau.id,
            attendance_score=10.0,
            midterm_score=8.0,
            final_score=8.5,
            total_score=8.6,
            result_status="PASSED",
            is_confirmed=False,
            note="Khả năng Speaking trôi chảy, phản xạ tự nhiên, từ vựng phong phú."
        )
        gr6 = GradeRecord(
            class_id=cls4.id,
            student_id=st_anh.id,
            attendance_score=9.0,
            midterm_score=7.5,
            final_score=8.0,
            total_score=8.0,
            result_status="PASSED",
            is_confirmed=False,
            note="Bài luận Writing Task 2 mạch lạc, lập luận chặt chẽ."
        )
        # Grades for cls5 (COMM A2)
        gr7 = GradeRecord(
            class_id=cls5.id,
            student_id=st_linh.id,
            attendance_score=9.5,
            midterm_score=8.5,
            final_score=9.0,
            total_score=8.9,
            result_status="PASSED",
            is_confirmed=False,
            note="Tự tin tương tác nhóm, ngữ âm chuẩn và ghi nhớ từ vựng rất nhanh."
        )
        db.add_all([gr1, gr2, gr3, gr4, gr5, gr6, gr7])
        db.commit()

        # --- PROGRESSION (FR-78 -> FR-80) ---
        print("🌱 Seeding Progression (FR-78 -> FR-80)...")
        prog1 = CourseProgression(
            student_id=student_profile.id,
            current_course_id=c1.id,
            next_course_id=c2.id,
            is_eligible=True,
            is_confirmed=True,
            confirmed_by=staff.id,
            confirmed_at=datetime.now(timezone.utc),
            note="Học viên đã đạt 8.1 ở khóa IELTS 6.5, đủ điều kiện học lên lớp IELTS Master 7.5+."
        )
        prog2 = CourseProgression(
            student_id=st_tuan.id,
            current_course_id=c7.id,
            next_course_id=c3.id,
            is_eligible=True,
            is_confirmed=True,
            confirmed_by=staff.id,
            confirmed_at=datetime.now(timezone.utc),
            note="Học viên hoàn thành TOEIC 550 với điểm tổng kết 8.4, đủ điều kiện học TOEIC Cấp Tốc 750+."
        )
        prog3 = CourseProgression(
            student_id=st_chau.id,
            current_course_id=c6.id,
            next_course_id=c1.id,
            is_eligible=True,
            is_confirmed=True,
            confirmed_by=staff.id,
            confirmed_at=datetime.now(timezone.utc),
            note="Hoàn thành xuất sắc khóa IELTS Foundation 5.0, chuyển tiếp lên lớp IELTS 6.5+."
        )
        prog4 = CourseProgression(
            student_id=st_linh.id,
            current_course_id=c4.id,
            next_course_id=c5.id,
            is_eligible=True,
            is_confirmed=False,
            confirmed_by=None,
            confirmed_at=None,
            note="Học viên đạt kết quả xuất sắc ở lớp Giao tiếp A2, chờ xác nhận chuyển tiếp lớp B1+."
        )
        db.add_all([prog1, prog2, prog3, prog4])
        db.commit()

        print("✅ Seed database completed successfully!")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
