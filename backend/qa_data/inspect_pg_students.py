import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

cur.execute('SELECT COUNT(*) FROM "HOC_VIEN";')
print("Total HOC_VIEN in PG:", cur.fetchone()[0])

cur.execute("""
    SELECT hv."MaHocVien", hv."MaSoHocVien", nd."TenDangNhap", nd."Email"
    FROM "HOC_VIEN" hv
    JOIN "NGUOI_DUNG" nd ON hv."MaNguoiDung" = nd."MaNguoiDung"
    ORDER BY hv."MaHocVien" DESC LIMIT 10;
""")
for r in cur.fetchall():
    print(" ", r)

conn.close()
