import sys
import os

sys.path.insert(0, 'backend')
import app.models
from app.core.database import SessionLocal
from app.modules.accounts.models import User
from app.modules.teachers.models import Teacher
from app.modules.students.models import Student
from app.modules.courses.models import Course
from app.modules.classes.models import Class, ClassStudent
from app.modules.classrooms.models import Classroom
from app.modules.schedules.models import ScheduleSession
from app.modules.grades.models import GradeRecord, GradeLockHistory
from app.modules.enrollments.models import EnrollmentRequest
from app.modules.tickets.models import Ticket, TicketMessage
from app.modules.progression_parent.models import CourseProgression, ParentStudent

db = SessionLocal()

print("==================================================================")
print("🧪 VERIFYING ORM QUERIES ACROSS ALL 15 MODULES")
print("==================================================================")

modules = [
    ("User (NGUOI_DUNG)", User),
    ("Teacher (GIANG_VIEN)", Teacher),
    ("Student (HOC_VIEN)", Student),
    ("ParentStudent (PHU_HUYNH_HOC_VIEN)", ParentStudent),
    ("Course (KHOA_HOC)", Course),
    ("Classroom (PHONG_HOC)", Classroom),
    ("Class (LOP_HOC)", Class),
    ("ClassStudent (HOC_VIEN_LOP_HOC)", ClassStudent),
    ("EnrollmentRequest (YEU_CAU_DANG_KY)", EnrollmentRequest),
    ("ScheduleSession (BUOI_HOC)", ScheduleSession),
    ("GradeRecord (BANG_DIEM)", GradeRecord),
    ("GradeLockHistory (LICHSU_KHOA_DIEM)", GradeLockHistory),
    ("CourseProgression (TIEN_TRINH_KHOA_HOC)", CourseProgression),
    ("Ticket (DON_THU)", Ticket),
    ("TicketMessage (DON_THU_PHAN_HOI)", TicketMessage),
]

all_pass = True
for name, model in modules:
    try:
        cnt = db.query(model).filter(model.is_deleted == False).count()
        first = db.query(model).first()
        print(f"  ✅ {name:38}: {cnt:4} rows active. Query sample OK.")
    except Exception as e:
        print(f"  ❌ {name:38}: FAILED ({e})")
        all_pass = False

# Test relationships
print("\n--- Verifying Core ORM Relationships ---")
try:
    c = db.query(Class).first()
    print(f"  ✅ Class.course: {c.course.title if c.course else 'None'}")
    print(f"  ✅ Class.teacher: {c.teacher.user.full_name if c.teacher and c.teacher.user else 'None'}")
    print(f"  ✅ Class.students count: {len(c.students)}")
    print(f"  ✅ Class.schedules count: {len(c.schedules)}")
    print(f"  ✅ Class.grades count: {len(c.grades)}")
    
    st = db.query(Student).first()
    print(f"  ✅ Student.user: {st.user.full_name if st.user else 'None'}")
    print(f"  ✅ Student.grades count: {len(st.grades)}")
    print(f"  ✅ Student.enrollments count: {len(st.class_enrollments)}")
    
    t = db.query(Ticket).first()
    print(f"  ✅ Ticket.sender: {t.sender.full_name if t.sender else 'None'}")
    print(f"  ✅ Ticket.messages count: {len(t.messages)}")
except Exception as e:
    print(f"  ❌ Relationship error: {e}")
    all_pass = False

db.close()
assert all_pass, "ORM verification failed!"
print("\n🎉 ALL 15 ORM MODELS AND RELATIONSHIPS OPERATING 100% HEALTHY!\n")
