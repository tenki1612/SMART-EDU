from typing import Optional, List
from pydantic import BaseModel, Field

class GradeInputItem(BaseModel):
    student_id: int
    attendance_score: float = Field(..., ge=0.0, le=10.0, description="FR-73: Thang điểm 0 - 10")
    midterm_score: float = Field(..., ge=0.0, le=10.0, description="FR-73: Thang điểm 0 - 10")
    final_score: float = Field(..., ge=0.0, le=10.0, description="FR-73: Thang điểm 0 - 10")
    note: Optional[str] = None

class BatchGradeInputRequest(BaseModel):
    class_id: int
    grades: List[GradeInputItem]

class AddStudentGradeRequest(BaseModel):
    student_id: int
    attendance_score: Optional[float] = Field(0.0, ge=0.0, le=10.0, description="Điểm chuyên cần ban đầu")
    midterm_score: Optional[float] = Field(0.0, ge=0.0, le=10.0, description="Điểm giữa kỳ ban đầu")
    final_score: Optional[float] = Field(0.0, ge=0.0, le=10.0, description="Điểm cuối kỳ ban đầu")
    note: Optional[str] = None

class GradeRecordResponse(BaseModel):
    id: int
    class_id: int
    class_code: str
    course_title: str
    student_id: int
    student_code: str
    student_name: str
    attendance_score: float
    midterm_score: float
    final_score: float
    total_score: float
    result_status: str # PENDING, PASSED, FAILED
    is_confirmed: bool
    note: Optional[str] = None

    class Config:
        from_attributes = True

class ClassGradingSheetStudent(BaseModel):
    student_id: int
    student_code: str
    full_name: str
    avatar_url: Optional[str] = None
    attendance_score: float
    midterm_score: float
    final_score: float
    total_score: float
    result_status: str
    is_confirmed: bool
    note: Optional[str] = None

