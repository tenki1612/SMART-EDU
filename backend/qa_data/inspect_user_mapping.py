import psycopg2
import sqlite3
import os

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = os.path.abspath("backend/language_center.db")

pg_conn = psycopg2.connect(PG_URL)
pg_cur = pg_conn.cursor()

sq_conn = sqlite3.connect(SQLITE_PATH)
sq_cur = sq_conn.cursor()

# Find username mapping
pg_cur.execute('SELECT "MaNguoiDung", "TenDangNhap", "Email" FROM "NGUOI_DUNG";')
pg_by_uname = {r[1]: (r[0], r[2]) for r in pg_cur.fetchall()}

sq_cur.execute('SELECT MaNguoiDung, TenDangNhap, Email FROM NGUOI_DUNG;')
sq_by_uname = {r[1]: (r[0], r[2]) for r in sq_cur.fetchall()}

print(f"Total distinct usernames in PG: {len(pg_by_uname)}")
print(f"Total distinct usernames in SQ: {len(sq_by_uname)}")

unames_in_both = set(pg_by_uname.keys()) & set(sq_by_uname.keys())
print(f"Usernames present in both: {len(unames_in_both)}")

id_diffs = []
for u in unames_in_both:
    if pg_by_uname[u][0] != sq_by_uname[u][0]:
        id_diffs.append((u, pg_by_uname[u][0], sq_by_uname[u][0]))

print(f"Usernames with DIFFERENT MaNguoiDung between PG and SQ: {len(id_diffs)}")
if id_diffs:
    print("Sample id diffs:", id_diffs[:10])

unames_in_sq_only = set(sq_by_uname.keys()) - set(pg_by_uname.keys())
print(f"Usernames only in SQ: {len(unames_in_sq_only)}")

unames_in_pg_only = set(pg_by_uname.keys()) - set(sq_by_uname.keys())
print(f"Usernames only in PG: {len(unames_in_pg_only)}")

pg_conn.close()
sq_conn.close()
