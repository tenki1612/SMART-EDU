import sys
import psycopg2
import sqlite3
from pathlib import Path

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = Path("backend/language_center.db").resolve()

TABLES = [
    "NGUOI_DUNG",
    "GIANG_VIEN",
    "HOC_VIEN",
    "PHU_HUYNH_HOC_VIEN",
    "KHOA_HOC",
    "PHONG_HOC",
    "LOP_HOC",
    "HOC_VIEN_LOP_HOC",
    "YEU_CAU_DANG_KY",
    "BUOI_HOC",
    "BANG_DIEM",
    "TIEN_TRINH_KHOA_HOC",
    "DON_THU",
    "DON_THU_PHAN_HOI",
    "LICHSU_KHOA_DIEM",
]

def sync():
    print(f"🔄 Syncing PostgreSQL ({PG_URL}) -> SQLite ({SQLITE_PATH})...")
    pg_conn = psycopg2.connect(PG_URL)
    pg_cur = pg_conn.cursor()

    sq_conn = sqlite3.connect(str(SQLITE_PATH))
    sq_cur = sq_conn.cursor()

    for table in TABLES:
        # Get columns from PostgreSQL
        pg_cur.execute(f'SELECT * FROM "{table}" LIMIT 0;')
        col_names = [desc[0] for desc in pg_cur.description]
        col_list_str = ", ".join([f'"{c}"' for c in col_names])
        placeholders = ", ".join(["?"] * len(col_names))

        # Fetch all rows from PostgreSQL
        pg_cur.execute(f'SELECT {col_list_str} FROM "{table}";')
        rows = pg_cur.fetchall()

        # Clean table in SQLite and insert all rows
        sq_cur.execute(f'DELETE FROM "{table}";')
        # Convert any datetime or boolean to sqlite compatible format
        formatted_rows = []
        for r in rows:
            formatted_row = []
            for val in r:
                if isinstance(val, bool):
                    formatted_row.append(1 if val else 0)
                elif hasattr(val, 'isoformat'):
                    formatted_row.append(val.isoformat())
                else:
                    formatted_row.append(val)
            formatted_rows.append(tuple(formatted_row))

        sq_cur.executemany(
            f'INSERT INTO "{table}" ({col_list_str}) VALUES ({placeholders});',
            formatted_rows
        )
        print(f"   ✓ Synced {table}: {len(rows)} rows")

    sq_conn.commit()
    sq_conn.close()
    pg_conn.close()
    print("🎉 PostgreSQL to SQLite sync completed successfully!")

if __name__ == "__main__":
    sync()
