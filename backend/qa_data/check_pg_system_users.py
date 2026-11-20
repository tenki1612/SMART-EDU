import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

cur.execute('SELECT "MaNguoiDung", "TenDangNhap", "Email", "VaiTro" FROM "NGUOI_DUNG" WHERE "MaNguoiDung" IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);')
for r in cur.fetchall():
    print(r)

conn.close()
