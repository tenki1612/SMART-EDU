import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

cur.execute("""
    SELECT nd."TenDangNhap"
    FROM "HOC_VIEN" hv
    JOIN "NGUOI_DUNG" nd ON hv."MaNguoiDung" = nd."MaNguoiDung";
""")
pg_student_unames = set(r[0] for r in cur.fetchall())
print(f"Total student usernames in PG: {len(pg_student_unames)}")

expected = {f"student_{i:04d}" for i in range(1, 351)}
diff = expected - pg_student_unames
print(f"Missing student_0001..student_0350: {len(diff)}")
if diff:
    print("Missing:", diff)

conn.close()
