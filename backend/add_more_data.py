"""
Script bổ sung thêm dữ liệu thực tế (Thêm học viên, giảng viên, khóa học, lớp học, lịch học, điểm số).
Chạy: python add_more_data.py
"""

import sys
from pathlib import Path
from datetime import date, datetime, timedelta, timezone

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

sys.path.insert(0, str(Path(__file__).resolve().parent))

from app.core.database import SessionLocal
from app.core.security import get_password_hash
from app.core.permissions import RoleEnum
from app.models import (
    User, Course, Student, Teacher, Classroom, Class, ClassStudent,
    EnrollmentRequest, ScheduleSession, GradeRecord
)
from app.modules.progression_parent.models import ParentStudent, CourseProgression


def add_more_data():
    db = SessionLocal()
    print("\n" + "=" * 65)
    print("🚀 BẮT ĐẦU BỔ SUNG DỮ LIỆU MỚI VÀO HỆ THỐNG SMART-EDU LMS")
    print("=" * 65)

    try:
        # 1. THÊM KHÓA HỌC MỚI
        print("📚 [1/6] Kiểm tra & bổ sung Khóa học mới...")
        new_courses = [
            {
                "code": "ENG-BIZ-01",
                "title": "Tiếng Anh Thương Mại & Giao Tiếp Đàm Phán",
                "desc": "Chương trình đào tạo kỹ năng thuyết trình, viết email thương mại và đàm phán quốc tế.",
                "level": "B2 Business",
                "weeks": 10,
                "fee": 6500000.0
            },
            {
                "code": "SAT-MASTER-01",
                "title": "Luyện thi SAT Toàn Diện 1450+",
                "desc": "Chiến thuật chinh phục điểm số SAT Digital chuẩn tuyển sinh đại học hàng đầu Mỹ và quốc tế.",
                "level": "SAT 1450+",
                "weeks": 14,
                "fee": 12000000.0
            },
            {
                "code": "PTE-ACAD-01",
                "title": "Luyện thi PTE Academic Cấp Tốc 65+",
                "desc": "Phương pháp mẹo và phản xạ máy tính giúp đạt target PTE phục vụ du học & định cư.",
                "level": "PTE 65+",
                "weeks": 8,
                "fee": 7200000.0
            }
        ]
        created_courses = []
        for c in new_courses:
            existing = db.query(Course).filter(Course.code == c["code"]).first()
            if not existing:
                course_obj = Course(
                    code=c["code"],
                    title=c["title"],
                    description=c["desc"],
                    target_level=c["level"],
                    duration_weeks=c["weeks"],
                    fee=c["fee"],
                    is_active=True
                )
                db.add(course_obj)
                db.flush()
                created_courses.append(course_obj)
                print(f"  + Đã thêm khóa học: [{course_obj.code}] {course_obj.title}")
            else:
                created_courses.append(existing)

        # 2. THÊM PHÒNG HỌC MỚI
        print("\n🏫 [2/6] Kiểm tra & bổ sung Phòng học mới...")
        new_rooms = [
            {"code": "LAB.301", "building": "Tòa A", "capacity": 30, "status": "AVAILABLE"},
            {"code": "P.402", "building": "Tòa B", "capacity": 40, "status": "AVAILABLE"},
            {"code": "P.403", "building": "Tòa B", "capacity": 35, "status": "AVAILABLE"}
        ]
        created_rooms = []
        for r in new_rooms:
            existing = db.query(Classroom).filter(Classroom.room_code == r["code"]).first()
            if not existing:
                room_obj = Classroom(
                    room_code=r["code"],
                    building=r["building"],
                    capacity=r["capacity"],
                    status=r["status"]
                )
                db.add(room_obj)
                db.flush()
                created_rooms.append(room_obj)
                print(f"  + Đã thêm phòng học: {room_obj.room_code} ({room_obj.building} - {room_obj.capacity} chỗ)")
            else:
                created_rooms.append(existing)

        # 3. THÊM GIẢNG VIÊN MỚI
        print("\n👨‍🏫 [3/6] Kiểm tra & bổ sung Giảng viên mới...")
        new_teachers = [
            {
                "username": "teacher_anna",
                "email": "anna.nguyen@center.edu.vn",
                "name": "Cô Anna Nguyễn (IELTS 8.5)",
                "phone": "0987111222",
                "code": "GV2026-008",
                "specialty": "IELTS Speaking & Business Writing",
                "degree": "Thạc sĩ Giảng dạy Tiếng Anh (TESOL)"
            },
            {
                "username": "teacher_tri",
                "email": "minhtri.dang@center.edu.vn",
                "name": "ThS. Đặng Minh Trí (SAT 1530)",
                "phone": "0987333444",
                "code": "GV2026-009",
                "specialty": "SAT Math & Advanced Reading",
                "degree": "Master of Science (Univ. of Melbourne)"
            }
        ]
        created_teachers = []
        for t in new_teachers:
            existing_user = db.query(User).filter(User.username == t["username"]).first()
            if not existing_user:
                t_user = User(
                    username=t["username"],
                    email=t["email"],
                    full_name=t["name"],
                    hashed_password=get_password_hash("teacher123"),
                    role=RoleEnum.TEACHER,
                    phone=t["phone"],
                    is_active=True
                )
                db.add(t_user)
                db.flush()
                t_profile = Teacher(
                    user_id=t_user.id,
                    teacher_code=t["code"],
                    specialty=t["specialty"],
                    degree=t["degree"],
                    status="ACTIVE"
                )
                db.add(t_profile)
                db.flush()
                created_teachers.append(t_profile)
                print(f"  + Đã thêm giảng viên: {t['name']} - Mã: {t['code']}")
            else:
                t_profile = db.query(Teacher).filter(Teacher.user_id == existing_user.id).first()
                if t_profile:
                    created_teachers.append(t_profile)

        # 4. THÊM 12 HỌC VIÊN MỚI
        print("\n🎒 [4/6] Kiểm tra & bổ sung 12 Học viên mới...")
        new_students = [
            ("student_chau", "chau.le@gmail.com", "Lê Bảo Châu", "0911000101", date(2005, 3, 12), "Quận 1, TP.HCM"),
            ("student_anh", "anh.nguyen@gmail.com", "Nguyễn Hoàng Anh", "0911000102", date(2006, 7, 25), "Quận 3, TP.HCM"),
            ("student_linh", "linh.vu@gmail.com", "Vũ Thùy Linh", "0911000103", date(2005, 11, 8), "Quận Bình Thạnh, TP.HCM"),
            ("student_kiet", "kiet.do@gmail.com", "Đỗ Tuấn Kiệt", "0911000104", date(2004, 9, 14), "Quận 10, TP.HCM"),
            ("student_vy", "vy.huynh@gmail.com", "Huỳnh Thảo Vy", "0911000105", date(2006, 1, 30), "Quận Tân Bình, TP.HCM"),
            ("student_huy", "huy.bui@gmail.com", "Bùi Quang Huy", "0911000106", date(2005, 6, 18), "Quận Phú Nhuận, TP.HCM"),
            ("student_ngoc", "ngoc.phan@gmail.com", "Phan Bích Ngọc", "0911000107", date(2004, 12, 5), "Quận 5, TP.HCM"),
            ("student_khoa", "khoa.trinh@gmail.com", "Trịnh Đăng Khoa", "0911000108", date(2006, 4, 22), "Quận 7, TP.HCM"),
            ("student_tram", "tram.nguyen@gmail.com", "Nguyễn Ngọc Trâm", "0911000109", date(2005, 8, 19), "Quận Gò Vấp, TP.HCM"),
            ("student_dung", "dung.dinh@gmail.com", "Đinh Quốc Dũng", "0911000110", date(2004, 2, 10), "Quận 11, TP.HCM"),
            ("student_yen", "yen.mai@gmail.com", "Mai Hải Yến", "0911000111", date(2006, 10, 15), "Quận Thủ Đức, TP.HCM"),
            ("student_phuc", "phuc.tran@gmail.com", "Trần Gia Phúc", "0911000112", date(2005, 5, 29), "Quận 4, TP.HCM"),
        ]

        created_students = []
        for i, (uname, uemail, ufullname, uphone, udob, uaddr) in enumerate(new_students, start=101):
            existing_user = db.query(User).filter(User.username == uname).first()
            if not existing_user:
                s_user = User(
                    username=uname,
                    email=uemail,
                    full_name=ufullname,
                    hashed_password=get_password_hash("student123"),
                    role=RoleEnum.STUDENT,
                    phone=uphone,
                    is_active=True
                )
                db.add(s_user)
                db.flush()
                s_profile = Student(
                    user_id=s_user.id,
                    student_code=f"26-05{i:03d}",
                    date_of_birth=udob,
                    address=uaddr,
                    status="ACTIVE"
                )
                db.add(s_profile)
                db.flush()
                created_students.append(s_profile)
                print(f"  + Đã thêm học viên: {ufullname} ({uname}) - Mã: {s_profile.student_code}")
            else:
                s_profile = db.query(Student).filter(Student.user_id == existing_user.id).first()
                if s_profile:
                    created_students.append(s_profile)

        # 5. THÊM LỚP HỌC MỚI VÀ GÁN HỌC VIÊN
        print("\n🏫 [5/6] Mở Lớp học mới & Xếp học viên...")
        classes_data = [
            {
                "code": "SAT-1450-K01",
                "course_code": "SAT-MASTER-01",
                "teacher_uname": "teacher_tri",
                "capacity": 20,
                "start": date(2026, 12, 1),
                "end": date(2027, 3, 15)
            },
            {
                "code": "BIZ-ENG-K02",
                "course_code": "ENG-BIZ-01",
                "teacher_uname": "teacher_anna",
                "capacity": 25,
                "start": date(2026, 11, 25),
                "end": date(2027, 2, 5)
            },
            {
                "code": "PTE-65-K02",
                "course_code": "PTE-ACAD-01",
                "teacher_uname": "teacher_anna",
                "capacity": 18,
                "start": date(2026, 12, 10),
                "end": date(2027, 2, 15)
            }
        ]

        created_classes = []
        for cdata in classes_data:
            existing_cls = db.query(Class).filter(Class.class_code == cdata["code"]).first()
            if not existing_cls:
                course = db.query(Course).filter(Course.code == cdata["course_code"]).first()
                t_user = db.query(User).filter(User.username == cdata["teacher_uname"]).first()
                teacher = db.query(Teacher).filter(Teacher.user_id == t_user.id).first() if t_user else None

                cls = Class(
                    class_code=cdata["code"],
                    course_id=course.id if course else 1,
                    teacher_id=teacher.id if teacher else 1,
                    max_capacity=cdata["capacity"],
                    current_enrolled=0,
                    start_date=cdata["start"],
                    end_date=cdata["end"],
                    status="OPEN_FOR_ENROLLMENT"
                )
                db.add(cls)
                db.flush()
                created_classes.append(cls)
                print(f"  + Đã mở lớp học: {cls.class_code} (Sức chứa: {cls.max_capacity})")
            else:
                created_classes.append(existing_cls)

        # Xếp học viên vào các lớp học mới
        for cls in created_classes:
            # Gán 3-4 học viên vào mỗi lớp
            assigned_students = created_students[:4] if cls.class_code.startswith("SAT") else created_students[4:8]
            count_enrolled = 0
            for st in assigned_students:
                existing_roster = db.query(ClassStudent).filter(
                    ClassStudent.class_id == cls.id,
                    ClassStudent.student_id == st.id
                ).first()
                if not existing_roster:
                    roster = ClassStudent(
                        class_id=cls.id,
                        student_id=st.id,
                        status="ENROLLED"
                    )
                    db.add(roster)
                    count_enrolled += 1

                    # Tạo bản ghi điểm số (GradeRecord)
                    existing_grade = db.query(GradeRecord).filter(
                        GradeRecord.class_id == cls.id,
                        GradeRecord.student_id == st.id
                    ).first()
                    if not existing_grade:
                        # Điểm số mẫu
                        att = 9.0
                        mid = 8.5
                        fin = 8.0
                        tot = round(0.2 * att + 0.3 * mid + 0.5 * fin, 2)
                        grade = GradeRecord(
                            class_id=cls.id,
                            student_id=st.id,
                            attendance_score=att,
                            midterm_score=mid,
                            final_score=fin,
                            total_score=tot,
                            result_status="PASSED",
                            is_confirmed=True,
                            note="Học viên tiếp thu tốt, phản xạ xuất sắc"
                        )
                        db.add(grade)

            cls.current_enrolled = db.query(ClassStudent).filter(ClassStudent.class_id == cls.id).count()

        # 6. THỜI KHÓA BIỂU BUỔI HỌC
        print("\n📅 [6/6] Thiết lập Thời khóa biểu buổi học...")
        today = date.today()
        sample_schedules = [
            (created_classes[0].id if len(created_classes) > 0 else 1, created_rooms[0].id if len(created_rooms) > 0 else 1, created_teachers[0].id if len(created_teachers) > 0 else 1, today + timedelta(days=1), "18:00", "20:00", "Ca tối 2-4-6"),
            (created_classes[0].id if len(created_classes) > 0 else 1, created_rooms[0].id if len(created_rooms) > 0 else 1, created_teachers[0].id if len(created_teachers) > 0 else 1, today + timedelta(days=3), "18:00", "20:00", "Ca tối 2-4-6"),
            (created_classes[1].id if len(created_classes) > 1 else 1, created_rooms[1].id if len(created_rooms) > 1 else 1, created_teachers[1].id if len(created_teachers) > 1 else 1, today + timedelta(days=2), "19:00", "21:00", "Ca tối 3-5-7"),
            (created_classes[1].id if len(created_classes) > 1 else 1, created_rooms[1].id if len(created_rooms) > 1 else 1, created_teachers[1].id if len(created_teachers) > 1 else 1, today + timedelta(days=4), "19:00", "21:00", "Ca tối 3-5-7"),
        ]

        for cid, rid, tid, sdate, stime, etime, sname in sample_schedules:
            existing_s = db.query(ScheduleSession).filter(
                ScheduleSession.class_id == cid,
                ScheduleSession.session_date == sdate,
                ScheduleSession.start_time == stime
            ).first()
            if not existing_s:
                session = ScheduleSession(
                    class_id=cid,
                    classroom_id=rid,
                    teacher_id=tid,
                    session_date=sdate,
                    start_time=stime,
                    end_time=etime,
                    slot_name=sname,
                    is_confirmed=True,
                    status="SCHEDULED"
                )
                db.add(session)
                print(f"  + Đã tạo buổi học ngày {sdate}: {stime} - {etime}")

        db.commit()
        print("\n" + "=" * 65)
        print("✅ ĐÃ BỔ SUNG TOÀN BỘ DỮ LIỆU MỚI THÀNH CÔNG VÀO DATABASE!")
        print("=" * 65 + "\n")

    except Exception as e:
        db.rollback()
        print(f"\n❌ Lỗi khi thêm dữ liệu: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()


if __name__ == "__main__":
    add_more_data()
