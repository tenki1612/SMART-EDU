"""
Script sao chép toàn bộ dữ liệu từ SQLite (language_center.db) sang PostgreSQL.
Chạy: python backend/migrate_sqlite_to_pg.py
"""

import sys
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

import os
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))

import sqlite3
from sqlalchemy import create_engine, text, Boolean, Date, Time, DateTime
from app.core.config import settings, _DEFAULT_DB
from app.core.database import Base
import app.models  # load all models for metadata

def migrate_data():
    pg_url = settings.DATABASE_URL
    if not pg_url.startswith("postgresql"):
        print("❌ Lỗi: DATABASE_URL hiện tại không phải PostgreSQL.")
        print(f"DATABASE_URL hiện tại: {pg_url}")
        return False

    print(f"🔗 Đang kết nối tới PostgreSQL: {pg_url.split('@')[-1]}...")
    try:
        pg_engine = create_engine(pg_url)
        with pg_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        print("✓ Kết nối PostgreSQL thành công!")
    except Exception as e:
        print(f"❌ Không thể kết nối tới PostgreSQL: {e}")
        return False

    # 1. Tạo cấu trúc bảng trên PostgreSQL
    print("⏳ Đang tạo cấu trúc bảng trên PostgreSQL...")
    Base.metadata.create_all(bind=pg_engine)
    print("✓ Đã tạo xong cấu trúc 12 bảng.")

    # 2. Đọc dữ liệu từ SQLite
    sqlite_path = _DEFAULT_DB
    if not sqlite_path.exists():
        print(f"⚠️ Không tìm thấy file SQLite: {sqlite_path}. Sẽ chạy seed mới.")
        from seed import seed_database
        seed_database()
        return True

    print(f"📦 Đang đọc dữ liệu từ SQLite ({sqlite_path.name})...")
    sqlite_conn = sqlite3.connect(str(sqlite_path))
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cur = sqlite_conn.cursor()

    # Thứ tự chèn để thỏa mãn ràng buộc khóa ngoại (FK)
    tables_order = [
        "users",
        "courses",
        "classrooms",
        "students",
        "teachers",
        "classes",
        "course_progressions",
        "parent_students",
        "class_students",
        "enrollment_requests",
        "schedule_sessions",
        "grade_records"
    ]

    with pg_engine.begin() as pg_conn:
        # Xóa dữ liệu cũ nếu có
        for table in reversed(tables_order):
            try:
                pg_conn.execute(text(f'TRUNCATE TABLE "{table}" CASCADE'))
            except Exception:
                pass

        total_rows = 0
        for table_name in tables_order:
            if table_name not in Base.metadata.tables:
                print(f"⚠️ Bảng {table_name} không tìm thấy trong SQLAlchemy metadata!")
                continue

            sa_table = Base.metadata.tables[table_name]
            # Xác định các cột Boolean để chuyển đổi từ 0/1 của SQLite sang True/False của Postgres
            boolean_cols = {col.name for col in sa_table.columns if isinstance(col.type, Boolean)}

            try:
                sqlite_cur.execute(f'SELECT * FROM "{table_name}"')
                rows = sqlite_cur.fetchall()
                if not rows:
                    print(f"  - {table_name}: 0 bản ghi")
                    continue

                col_names = [col[0] for col in sqlite_cur.description]
                cols_str = ", ".join([f'"{c}"' for c in col_names])
                placeholders = ", ".join([f":{c}" for c in col_names])
                insert_sql = text(f'INSERT INTO "{table_name}" ({cols_str}) VALUES ({placeholders})')

                for r in rows:
                    data = dict(r)
                    for bcol in boolean_cols:
                        if bcol in data and data[bcol] is not None:
                            data[bcol] = bool(data[bcol])
                    pg_conn.execute(insert_sql, data)

                total_rows += len(rows)
                print(f"  ✓ {table_name}: đã sao chép {len(rows)} bản ghi")
            except Exception as e:
                print(f"  ❌ Lỗi bảng {table_name}: {e}")
                raise e

        # Đồng bộ lại sequences (Auto-increment PK) trên PostgreSQL
        print("🔄 Đang đồng bộ lại auto-increment sequences...")
        for table_name in tables_order:
            try:
                seq_fix = f"""
                SELECT setval(
                    pg_get_serial_sequence('"{table_name}"', 'id'),
                    coalesce(max(id), 1),
                    max(id) IS NOT null
                ) FROM "{table_name}";
                """
                pg_conn.execute(text(seq_fix))
            except Exception:
                pass

    sqlite_conn.close()
    print(f"\n🎉 HOÀN TẤT! ĐÃ DI CHUYỂN TOÀN BỘ {total_rows} BẢN GHI SANG POSTGRESQL THÀNH CÔNG!")
    return True

if __name__ == "__main__":
    migrate_data()
