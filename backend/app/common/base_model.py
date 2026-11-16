from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, Boolean

class TimestampMixin:
    created_at = Column("NgayTao", DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column("NgayCapNhat", DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    is_deleted = Column("DaXoa", Boolean, default=False)
