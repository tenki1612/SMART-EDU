import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

cur.execute("""
    SELECT b1."MaBuoiHoc", b1."MaLopHoc", b1."MaPhongHoc", b1."NgayHoc", b1."GioBatDau", b1."GioKetThuc",
           b2."MaBuoiHoc", b2."MaLopHoc", b2."MaPhongHoc", b2."NgayHoc", b2."GioBatDau", b2."GioKetThuc"
    FROM "BUOI_HOC" b1
    JOIN "BUOI_HOC" b2 ON b1."MaPhongHoc" = b2."MaPhongHoc" 
        AND b1."NgayHoc" = b2."NgayHoc" 
        AND b1."MaBuoiHoc" < b2."MaBuoiHoc"
        AND b1."DaXoa" = FALSE AND b2."DaXoa" = FALSE
        AND b1."GioBatDau" < b2."GioKetThuc" AND b1."GioKetThuc" > b2."GioBatDau";
""")
rows = cur.fetchall()
for r in rows:
    print(r)

conn.close()
