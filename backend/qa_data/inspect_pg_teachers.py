import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

cur.execute('SELECT "MaGiangVien", "MaSoGiangVien", "MaNguoiDung" FROM "GIANG_VIEN" ORDER BY "MaGiangVien" ASC;')
rows = cur.fetchall()
print(f"Total GIANG_VIEN in PG: {len(rows)}")
for r in rows:
    print(" ", r)

conn.close()
