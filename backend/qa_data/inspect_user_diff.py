import psycopg2
import sqlite3
import os

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = os.path.abspath("backend/language_center.db")

pg_conn = psycopg2.connect(PG_URL)
pg_cur = pg_conn.cursor()

sq_conn = sqlite3.connect(SQLITE_PATH)
sq_cur = sq_conn.cursor()

pg_cur.execute('SELECT "MaNguoiDung", "TenDangNhap", "Email", "VaiTro" FROM "NGUOI_DUNG";')
pg_users = {r[0]: r for r in pg_cur.fetchall()}

sq_cur.execute('SELECT MaNguoiDung, TenDangNhap, Email, VaiTro FROM NGUOI_DUNG;')
sq_users = {r[0]: r for r in sq_cur.fetchall()}

diff_ids = set(pg_users.keys()) - set(sq_users.keys())
print(f"Users in PG not in SQ ({len(diff_ids)}):")
for uid in sorted(diff_ids):
    print(" ", pg_users[uid])

diff_sq_ids = set(sq_users.keys()) - set(pg_users.keys())
print(f"Users in SQ not in PG ({len(diff_sq_ids)}):")
for uid in sorted(diff_sq_ids)[:10]:
    print(" ", sq_users[uid])

pg_conn.close()
sq_conn.close()
