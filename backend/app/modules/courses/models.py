from sqlalchemy import Column, String, Integer, Float, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Course(Base, TimestampMixin):
    __tablename__ = "courses"

    code = Column(String(50), unique=True, index=True, nullable=False) # ví dụ: IELTS-6.5, TOEIC-750
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    target_level = Column(String(100), nullable=False) # ví dụ: "IELTS 6.5", "B2 Vstep"
    duration_weeks = Column(Integer, default=12)
    fee = Column(Float, default=0.0)
    is_active = Column(Boolean, default=True)

    # Relationships
    classes = relationship("Class", back_populates="course", cascade="all, delete-orphan")

