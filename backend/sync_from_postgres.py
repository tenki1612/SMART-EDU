"""
Đồng bộ ngược dữ liệu từ PostgreSQL (database của Prisma) về SQLite (database của Backend/FastAPI).
Chạy lệnh này sau khi sửa data trên Prisma Studio để Backend nhận dữ liệu mới.
"""

import sys
from pathlib import Path
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

import sqlite3
from sqlalchemy import create_engine, text
from app.core.config import _DEFAULT_DB
from app.core.database import Base
import app.models

PG_URL = "postgresql://postgres:postgrespassword2026@localhost:5432/language_center"
SQLITE_PATH = _DEFAULT_DB

def sync_from_postgres():
    print("=" * 65)
    print("📥 ĐỒNG BỘ DỮ LIỆU TỪ POSTGRESQL (PRISMA) VỀ SQLITE (BACKEND)")
    print("=" * 65)

    pg_engine = create_engine(PG_URL)
    with pg_engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("✓ Đã kết nối PostgreSQL thành công!")

    sqlite_conn = sqlite3.connect(str(SQLITE_PATH))
    sqlite_cur = sqlite_conn.cursor()

    tables_order = [
        ("NGUOI_DUNG", "MaNguoiDung"),
        ("KHOA_HOC", "MaKhoaHoc"),
        ("PHONG_HOC", "MaPhongHoc"),
        ("HOC_VIEN", "MaHocVien"),
        ("GIANG_VIEN", "MaGiangVien"),
        ("LOP_HOC", "MaLopHoc"),
        ("TIEN_TRINH_KHOA_HOC", "MaTienTrinh"),
        ("PHU_HUYNH_HOC_VIEN", "MaPH_HV"),
        ("HOC_VIEN_LOP_HOC", "MaHV_LH"),
        ("YEU_CAU_DANG_KY", "MaYeuCau"),
        ("BUOI_HOC", "MaBuoiHoc"),
        ("BANG_DIEM", "MaBangDiem")
    ]

    total_synced = 0
    try:
        # Tắt foreign keys tạm thời để cập nhật an toàn
        sqlite_cur.execute("PRAGMA foreign_keys = OFF;")

        with pg_engine.connect() as pg_conn:
            for tname, pk_col in tables_order:
                # Xóa dữ liệu cũ trong bảng SQLite
                sqlite_cur.execute(f'DELETE FROM "{tname}";')

                # Đọc toàn bộ dữ liệu mới nhất từ PostgreSQL
                result = pg_conn.execute(text(f'SELECT * FROM "{tname}" ORDER BY "{pk_col}" ASC'))
                rows = [dict(row._mapping) for row in result]

                if not rows:
                    print(f" • {tname:<25}: 0 bản ghi")
                    continue

                col_names = list(rows[0].keys())
                cols_str = ", ".join([f'"{c}"' for c in col_names])
                placeholders = ", ".join(["?" for _ in col_names])
                insert_sql = f'INSERT INTO "{tname}" ({cols_str}) VALUES ({placeholders})'

                for r in rows:
                    # Chuyển kiểu dữ liệu tương thích SQLite
                    vals = []
                    for c in col_names:
                        v = r[c]
                        if isinstance(v, bool):
                            vals.append(1 if v else 0)
                        elif v is not None and hasattr(v, 'isoformat'):
                            # Format date/datetime tương thích SQLite & SQLAlchemy
                            if hasattr(v, 'hour'):
                                vals.append(v.strftime("%Y-%m-%d %H:%M:%S.%f"))
                            else:
                                vals.append(v.strftime("%Y-%m-%d"))
                        else:
                            vals.append(v)
                    sqlite_cur.execute(insert_sql, vals)

                total_synced += len(rows)
                print(f" ✓ {tname:<25}: đã đồng bộ {len(rows):>3} bản ghi")

        sqlite_conn.commit()
    finally:
        sqlite_cur.execute("PRAGMA foreign_keys = ON;")
        sqlite_conn.close()

    print("=" * 65)
    print(f"🎉 THÀNH CÔNG! ĐÃ ĐỒNG BỘ ĐẦY ĐỦ {total_synced} BẢN GHI VỀ SQLITE (BACKEND)!")
    print("=" * 65 + "\n")

if __name__ == "__main__":
    sync_from_postgres()
