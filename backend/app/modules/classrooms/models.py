from sqlalchemy import Column, String, Integer
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.common.base_model import TimestampMixin

class Classroom(Base, TimestampMixin):
    __tablename__ = "PHONG_HOC"

    id = Column("MaPhongHoc", Integer, primary_key=True, index=True, autoincrement=True)
    room_code = Column("MaSoPhong", String(50), unique=True, index=True, nullable=False) # ví dụ: P.201
    building = Column("ToaNha", String(50), default="Tòa nhà A")
    capacity = Column("SucChua", Integer, default=30)
    status = Column("TrangThai", String(50), default="AVAILABLE") # AVAILABLE, MAINTENANCE, OCCUPIED

    # Relationships
    schedules = relationship("ScheduleSession", back_populates="classroom")
