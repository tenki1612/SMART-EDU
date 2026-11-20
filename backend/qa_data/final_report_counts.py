import psycopg2
import sqlite3
import os

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = os.path.abspath("backend/language_center.db")

pg_conn = psycopg2.connect(PG_URL)
pg_cur = pg_conn.cursor()

sq_conn = sqlite3.connect(SQLITE_PATH)
sq_cur = sq_conn.cursor()

tables = [
    'NGUOI_DUNG', 'GIANG_VIEN', 'HOC_VIEN', 'PHU_HUYNH_HOC_VIEN',
    'KHOA_HOC', 'PHONG_HOC', 'LOP_HOC', 'HOC_VIEN_LOP_HOC',
    'YEU_CAU_DANG_KY', 'BUOI_HOC', 'BANG_DIEM', 'TIEN_TRINH_KHOA_HOC',
    'DON_THU', 'DON_THU_PHAN_HOI', 'LICHSU_KHOA_DIEM'
]

# Baseline row counts in PG before sync:
pg_before = {
    'NGUOI_DUNG': 572,
    'GIANG_VIEN': 40,
    'HOC_VIEN': 350,
    'PHU_HUYNH_HOC_VIEN': 180,
    'KHOA_HOC': 18,
    'PHONG_HOC': 13,
    'LOP_HOC': 24,
    'HOC_VIEN_LOP_HOC': 259,
    'YEU_CAU_DANG_KY': 247,
    'BUOI_HOC': 36,
    'BANG_DIEM': 249,
    'TIEN_TRINH_KHOA_HOC': 7,
    'DON_THU': 210,
    'DON_THU_PHAN_HOI': 250,
    'LICHSU_KHOA_DIEM': 42
}

print(f"{'TABLE':<22} | {'PG BEFORE':<10} | {'PG AFTER':<10} | {'PG DIFF':<10} | {'SQLITE NOW':<10}")
print("-" * 72)

for t in tables:
    pg_cur.execute(f'SELECT COUNT(*) FROM "{t}";')
    pg_now = pg_cur.fetchone()[0]
    
    sq_cur.execute(f'SELECT COUNT(*) FROM "{t}";')
    sq_now = sq_cur.fetchone()[0]
    
    b = pg_before[t]
    diff = pg_now - b
    print(f"{t:<22} | {b:<10} | {pg_now:<10} | {diff:<+10} | {sq_now:<10}")

pg_conn.close()
sq_conn.close()
