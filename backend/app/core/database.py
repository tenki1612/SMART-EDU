from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings, _DEFAULT_DB

# Chuẩn hóa URL kết nối cho SQLAlchemy (tránh lỗi nếu môi trường chứa chuỗi file: của Prisma)
db_url = settings.DATABASE_URL
if not db_url or db_url.startswith("file:"):
    db_url = f"sqlite:///{_DEFAULT_DB.as_posix()}"

# SQLite configuration
connect_args = {"check_same_thread": False} if db_url.startswith("sqlite") else {}

engine = create_engine(
    db_url,
    connect_args=connect_args,
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
