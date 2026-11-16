# Central models registration for SQLAlchemy metadata discovery
from app.core.database import Base
from app.modules.accounts.models import User
from app.modules.courses.models import Course
from app.modules.students.models import Student
from app.modules.teachers.models import Teacher
from app.modules.classrooms.models import Classroom
from app.modules.classes.models import Class, ClassStudent
from app.modules.enrollments.models import EnrollmentRequest
from app.modules.schedules.models import ScheduleSession
from app.modules.grades.models import GradeRecord
from app.modules.progression_parent import models as progression_models

__all__ = [
    "Base",
    "User",
    "Course",
    "Student",
    "Teacher",
    "Classroom",
    "Class",
    "ClassStudent",
    "EnrollmentRequest",
    "ScheduleSession",
    "GradeRecord",
    "progression_models"
]

