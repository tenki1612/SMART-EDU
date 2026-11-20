import sys
sys.path.insert(0, 'backend')

from app.modules.courses.models import Course
from app.modules.classes.models import Class, ClassStudent
from app.modules.grades.models import GradeRecord
from app.modules.progression_parent.models import CourseProgression

def get_prerequisite_target_level(target_level: str) -> str:
    """
    Xác định cấp độ tiên quyết dựa trên chuẩn đầu ra (Target Level)
    """
    tl = (target_level or "").strip().upper()
    if "7.5" in tl:
        return "6.5"
    if "6.5" in tl:
        return "5.0"
    if "750" in tl:
        return "550"
    if "B1" in tl:
        return "A2"
    return None

def check_prerequisite_eligibility(db, student_id: int, class_id: int):
    cls = db.query(Class).filter(Class.id == class_id, Class.is_deleted == False).first()
    if not cls:
        return False, "Không tìm thấy lớp học."
    
    course = cls.course
    if not course:
        return True, "Lớp học không thuộc khóa học cụ thể."
    
    req_level = get_prerequisite_target_level(course.target_level)
    if not req_level:
        # Khóa học sơ cấp / không có tiên quyết
        return True, "Khóa học không yêu cầu điều kiện tiên quyết."
    
    # 1. Kiểm tra xem học viên đã được phê duyệt chuyển khóa học này qua CourseProgression chưa
    approved_prog = db.query(CourseProgression).filter(
        CourseProgression.student_id == student_id,
        CourseProgression.next_course_id == course.id,
        CourseProgression.is_eligible == True,
        CourseProgression.is_confirmed == True,
        CourseProgression.is_deleted == False
    ).first()
    if approved_prog:
        return True, "Bạn đã hoàn thành và PASS lớp học trước đó. Bạn đủ điều kiện đăng ký lớp học này."
    
    # 2. Tìm tất cả các khóa học thuộc cấp độ tiên quyết
    prereq_courses = db.query(Course).filter(
        Course.target_level.ilike(f"%{req_level}%"),
        Course.is_deleted == False
    ).all()
    prereq_course_ids = [c.id for c in prereq_courses]
    
    if not prereq_course_ids:
        return True, "Khóa học không yêu cầu điều kiện tiên quyết."
    
    # 3. Tìm các lớp tiên quyết mà học viên đã học
    enrolled_prereq_classes = db.query(Class).join(
        ClassStudent, ClassStudent.class_id == Class.id
    ).filter(
        ClassStudent.student_id == student_id,
        Class.course_id.in_(prereq_course_ids),
        ClassStudent.is_deleted == False,
        Class.is_deleted == False
    ).all()
    
    if not enrolled_prereq_classes:
        return False, "Bạn chưa đạt yêu cầu của lớp học cấp độ hiện tại. Vui lòng hoàn thành và PASS lớp học trước khi đăng ký lớp cấp độ cao hơn."
    
    # 4. Kiểm tra điểm số và kết quả hoàn thành (GradeRecord)
    has_passed = False
    for pc in enrolled_prereq_classes:
        grade = db.query(GradeRecord).filter(
            GradeRecord.class_id == pc.id,
            GradeRecord.student_id == student_id,
            GradeRecord.is_deleted == False
        ).first()
        if grade and grade.result_status == "PASSED" and grade.is_confirmed == True:
            has_passed = True
            break
            
    if has_passed:
        return True, "Bạn đã hoàn thành và PASS lớp học trước đó. Bạn đủ điều kiện đăng ký lớp học này."
    else:
        return False, "Bạn chưa đạt yêu cầu của lớp học cấp độ hiện tại. Vui lòng hoàn thành và PASS lớp học trước khi đăng ký lớp cấp độ cao hơn."

print("Logic loaded successfully")
