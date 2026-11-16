"""
Đồng bộ toàn bộ dữ liệu từ SQLite sang PostgreSQL (database của Prisma).
"""

import sys
from pathlib import Path
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

import sqlite3
from sqlalchemy import create_engine, text, Boolean
from app.core.config import _DEFAULT_DB
from app.core.database import Base
import app.models

PG_URL = "postgresql://postgres:postgrespassword2026@localhost:5432/language_center"
SQLITE_PATH = _DEFAULT_DB

def sync_to_postgres():
    print("=" * 65)
    print("🐘 ĐỒNG BỘ DỮ LIỆU TỪ SQLITE SANG POSTGRESQL (PRISMA DATABASE)")
    print("=" * 65)

    pg_engine = create_engine(PG_URL)
    with pg_engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("✓ Đã kết nối PostgreSQL thành công!")

    # 1. Đảm bảo cấu trúc bảng
    Base.metadata.create_all(bind=pg_engine)

    # 2. Đọc từ SQLite
    sqlite_conn = sqlite3.connect(str(SQLITE_PATH))
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cur = sqlite_conn.cursor()

    # Danh sách bảng theo thứ tự ràng buộc khóa ngoại
    tables_order = [
        ("NGUOI_DUNG", "MaNguoiDung"),
        ("KHOA_HOC", "MaKhoaHoc"),
        ("PHONG_HOC", "MaPhongHoc"),
        ("HOC_VIEN", "MaHocVien"),
        ("GIANG_VIEN", "MaGiangVien"),
        ("LOP_HOC", "MaLopHoc"),
        ("TIEN_TRINH_KHOA_HOC", "MaTienTrinh"),
        ("PHU_HUYNH_HOC_VIEN", "MaLienKet"),
        ("HOC_VIEN_LOP_HOC", "MaHV_LH"),
        ("YEU_CAU_DANG_KY", "MaYeuCau"),
        ("BUOI_HOC", "MaBuoiHoc"),
        ("BANG_DIEM", "MaBangDiem")
    ]

    total_synced = 0
    with pg_engine.begin() as pg_conn:
        # Xóa dữ liệu cũ trên PostgreSQL
        for tname, _ in reversed(tables_order):
            try:
                pg_conn.execute(text(f'TRUNCATE TABLE "{tname}" CASCADE'))
            except Exception:
                pass

        for tname, pk_col in tables_order:
            if tname not in Base.metadata.tables:
                print(f"⚠️ Bảng {tname} không có trong metadata!")
                continue

            sa_table = Base.metadata.tables[tname]
            boolean_cols = {col.name for col in sa_table.columns if isinstance(col.type, Boolean)}

            sqlite_cur.execute(f'SELECT * FROM "{tname}"')
            rows = sqlite_cur.fetchall()
            if not rows:
                print(f" • {tname:<25}: 0 bản ghi")
                continue

            col_names = [col[0] for col in sqlite_cur.description]
            cols_str = ", ".join([f'"{c}"' for c in col_names])
            placeholders = ", ".join([f":{c}" for c in col_names])
            insert_sql = text(f'INSERT INTO "{tname}" ({cols_str}) VALUES ({placeholders})')

            for r in rows:
                data = dict(r)
                for bcol in boolean_cols:
                    if bcol in data and data[bcol] is not None:
                        data[bcol] = bool(data[bcol])
                # Chuyển đổi timestamp string sang datetime nếu cần
                for k, v in data.items():
                    if isinstance(v, str) and len(v) >= 19 and ("-" in v and ":" in v):
                        try:
                            from datetime import datetime
                            data[k] = datetime.fromisoformat(v)
                        except Exception:
                            pass
                try:
                    pg_conn.execute(insert_sql, data)
                except Exception as ex:
                    print(f"Lỗi dòng {data} tại bảng {tname}: {ex}")
                    raise ex

            total_synced += len(rows)
            print(f" ✓ {tname:<25}: đã đồng bộ {len(rows):>3} bản ghi")

            # Không chạy setval trong transaction đang mở
            pass

    # 3. Đồng bộ lại sequences (Auto-increment PK) sau khi transaction đã commit thành công
    print("\n🔄 Đang đồng bộ lại auto-increment sequences...")
    with pg_engine.connect() as seq_conn:
        for tname, pk_col in tables_order:
            try:
                seq_query = f"""
                DO $$
                DECLARE
                    seq_name text;
                BEGIN
                    seq_name := pg_get_serial_sequence('"{tname}"', '{pk_col}');
                    IF seq_name IS NOT NULL THEN
                        EXECUTE format('SELECT setval(%L, coalesce(max("%I"), 1), max("%I") IS NOT NULL) FROM "%I"', seq_name, '{pk_col}', '{pk_col}', '{tname}');
                    END IF;
                END $$;
                """
                seq_conn.execute(text(seq_query))
                seq_conn.commit()
            except Exception:
                pass

    sqlite_conn.close()
    print("=" * 65)
    print(f"🎉 THÀNH CÔNG! ĐÃ ĐỒNG BỘ ĐẦY ĐỦ {total_synced} BẢN GHI SANG POSTGRESQL (PRISMA)!")
    print("=" * 65 + "\n")

if __name__ == "__main__":
    sync_to_postgres()
