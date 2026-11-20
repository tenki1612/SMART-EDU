import psycopg2
import sqlite3

pg_conn = psycopg2.connect("postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center")
pg_cur = pg_conn.cursor()
pg_cur.execute('SELECT "MaSoGiangVien", "MaGiangVien" FROM "GIANG_VIEN";')
pg_code_to_teacher = dict(pg_cur.fetchall())

sq_conn = sqlite3.connect("backend/language_center.db")
sq_cur = sq_conn.cursor()
sq_cur.execute('SELECT MaGiangVien, MaSoGiangVien FROM GIANG_VIEN;')
sq_teacher_to_code = dict(sq_cur.fetchall())

print(f"PG teachers count: {len(pg_code_to_teacher)}")
print(f"SQ teachers count: {len(sq_teacher_to_code)}")

unmapped = []
for sq_id, code in sq_teacher_to_code.items():
    if code not in pg_code_to_teacher:
        unmapped.append((sq_id, code))

print(f"Unmapped teachers: {len(unmapped)}")
if unmapped:
    print(unmapped)
else:
    print("✓ All 40 teachers mapped perfectly between SQLite and PostgreSQL!")

pg_conn.close()
sq_conn.close()
