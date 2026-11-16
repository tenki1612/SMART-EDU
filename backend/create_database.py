"""
Script khởi tạo và nạp dữ liệu mẫu toàn diện cho Hệ thống SMART-EDU LMS.
Hỗ trợ cả SQLite (Zero-config) và PostgreSQL (Docker container).
Chạy:
    python create_database.py           (Khởi tạo cho SQLite mặc định)
    python create_database.py --postgres (Khởi tạo trực tiếp cho PostgreSQL)
    python create_database.py --all      (Khởi tạo đồng bộ cả SQLite và PostgreSQL)
"""

import sys
import os
from pathlib import Path

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

# Thêm đường dẫn backend vào sys.path
sys.path.insert(0, str(Path(__file__).resolve().parent))

from sqlalchemy import create_engine, text
from app.core.database import Base
from app.core.config import _DEFAULT_DB
import app.models  # Nạp toàn bộ metadata 12 bảng
from seed import seed_database


def init_sqlite():
    print("\n" + "=" * 65)
    print("🚀 [1/2] KHỞI TẠO CƠ SỞ DỮ LIỆU SQLITE (backend/language_center.db)")
    print("=" * 65)
    
    sqlite_url = f"sqlite:///{_DEFAULT_DB.as_posix()}"
    engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})
    
    print("⏳ Đang tạo cấu trúc bảng trên SQLite...")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    print("✓ Đã tạo thành công cấu trúc toàn bộ các bảng trên SQLite!")
    
    print("🌱 Đang nạp dữ liệu mẫu (Seeding)...")
    from app.core import database
    orig_engine = database.engine
    orig_session = database.SessionLocal
    try:
        from sqlalchemy.orm import sessionmaker
        database.engine = engine
        database.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        seed_database()
        print("✅ Khởi tạo SQLite thành công 100%!")
    finally:
        database.engine = orig_engine
        database.SessionLocal = orig_session


def init_postgres():
    print("\n" + "=" * 65)
    print("🐘 [2/2] KHỞI TẠO CƠ SỞ DỮ LIỆU POSTGRESQL (Docker: port 5432)")
    print("=" * 65)
    
    pg_url = "postgresql://postgres:postgrespassword2026@localhost:5432/language_center"
    try:
        engine = create_engine(pg_url)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        print("✓ Đã kết nối thành công tới PostgreSQL container!")
    except Exception as e:
        print(f"⚠️ Không thể kết nối tới PostgreSQL (localhost:5432): {e}")
        print("💡 Hãy đảm bảo container đang chạy: docker start language_center_postgres")
        return False

    print("⏳ Đang xóa bảng cũ và tạo mới cấu trúc trên PostgreSQL...")
    try:
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)
        print("✓ Đã tạo thành công cấu trúc các bảng trên PostgreSQL!")
        
        print("🌱 Đang nạp dữ liệu mẫu vào PostgreSQL...")
        from app.core import database
        from sqlalchemy.orm import sessionmaker
        orig_engine = database.engine
        orig_session = database.SessionLocal
        try:
            database.engine = engine
            database.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
            seed_database()
            print("✅ Khởi tạo PostgreSQL thành công 100%!")
            return True
        finally:
            database.engine = orig_engine
            database.SessionLocal = orig_session
    except Exception as e:
        print(f"❌ Lỗi khi khởi tạo PostgreSQL: {e}")
        return False


if __name__ == "__main__":
    args = sys.argv[1:]
    
    if "--postgres" in args:
        init_postgres()
    elif "--all" in args:
        init_sqlite()
        init_postgres()
    else:
        # Mặc định khởi tạo SQLite và thử tự động khởi tạo luôn PostgreSQL nếu container đang chạy
        init_sqlite()
        print("\n🔍 Đang kiểm tra container PostgreSQL...")
        init_postgres()

    print("\n" + "=" * 65)
    print("🎉 HOÀN TẤT QUÁ TRÌNH TẠO CƠ SỞ DỮ LIỆU!")
    print("=" * 65)
    print("• Để xem dữ liệu bảng: python view_db.py")
    print("• Để mở giao diện web: npx prisma studio --schema=prisma/schema.sqlite.prisma")
    print("=" * 65 + "\n")
