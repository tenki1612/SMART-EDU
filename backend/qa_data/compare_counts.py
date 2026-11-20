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
    'BANG_DIEM', 'BUOI_HOC', 'DON_THU', 'DON_THU_PHAN_HOI', 'GIANG_VIEN', 
    'HOC_VIEN', 'HOC_VIEN_LOP_HOC', 'KHOA_HOC', 'LICHSU_KHOA_DIEM', 'LOP_HOC', 
    'NGUOI_DUNG', 'PHONG_HOC', 'PHU_HUYNH_HOC_VIEN', 'TIEN_TRINH_KHOA_HOC', 'YEU_CAU_DANG_KY'
]

print(f"{'TABLE':<25} | {'POSTGRESQL':<12} | {'SQLITE':<12} | {'DIFF':<10}")
print("-" * 65)

for t in tables:
    pg_cur.execute(f'SELECT COUNT(*) FROM "{t}";')
    pg_cnt = pg_cur.fetchone()[0]
    
    sq_cur.execute(f'SELECT COUNT(*) FROM "{t}";')
    sq_cnt = sq_cur.fetchone()[0]
    
    diff = sq_cnt - pg_cnt
    print(f"{t:<25} | {pg_cnt:<12} | {sq_cnt:<12} | {diff:<+10}")

pg_conn.close()
sq_conn.close()
