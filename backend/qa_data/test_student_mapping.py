import psycopg2
import sqlite3

pg_conn = psycopg2.connect("postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center")
pg_cur = pg_conn.cursor()
pg_cur.execute('SELECT "MaSoHocVien", "MaHocVien" FROM "HOC_VIEN";')
pg_code_to_student = dict(pg_cur.fetchall())

sq_conn = sqlite3.connect("backend/language_center.db")
sq_cur = sq_conn.cursor()
sq_cur.execute('SELECT MaHocVien, MaSoHocVien FROM HOC_VIEN;')
sq_student_to_code = dict(sq_cur.fetchall())

print(f"PG students count: {len(pg_code_to_student)}")
print(f"SQ students count: {len(sq_student_to_code)}")

unmapped = []
for sq_id, code in sq_student_to_code.items():
    if code not in pg_code_to_student:
        unmapped.append((sq_id, code))

print(f"Unmapped students from SQ to PG: {len(unmapped)}")
if unmapped:
    print("Sample unmapped:", unmapped[:10])

pg_conn.close()
sq_conn.close()
