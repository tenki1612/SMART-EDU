import psycopg2

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

# 1. Teacher conflicts
cur.execute("""
    SELECT COUNT(*)
    FROM "BUOI_HOC" b1
    JOIN "BUOI_HOC" b2 ON b1."MaGiangVien" = b2."MaGiangVien" 
        AND b1."NgayHoc" = b2."NgayHoc" 
        AND b1."MaBuoiHoc" < b2."MaBuoiHoc"
        AND b1."DaXoa" = FALSE AND b2."DaXoa" = FALSE
        AND b1."GioBatDau" < b2."GioKetThuc" AND b1."GioKetThuc" > b2."GioBatDau";
""")
t_conflicts = cur.fetchone()[0]

# 2. Room conflicts
cur.execute("""
    SELECT COUNT(*)
    FROM "BUOI_HOC" b1
    JOIN "BUOI_HOC" b2 ON b1."MaPhongHoc" = b2."MaPhongHoc" 
        AND b1."NgayHoc" = b2."NgayHoc" 
        AND b1."MaBuoiHoc" < b2."MaBuoiHoc"
        AND b1."DaXoa" = FALSE AND b2."DaXoa" = FALSE
        AND b1."GioBatDau" < b2."GioKetThuc" AND b1."GioKetThuc" > b2."GioBatDau";
""")
r_conflicts = cur.fetchone()[0]

print(f"PostgreSQL Teacher conflicts: {t_conflicts}")
print(f"PostgreSQL Room conflicts: {r_conflicts}")

# 3. Foreign key integrity in PG
cur.execute("""
    SELECT COUNT(*) FROM "BUOI_HOC" b LEFT JOIN "LOP_HOC" l ON b."MaLopHoc" = l."MaLopHoc" WHERE l."MaLopHoc" IS NULL;
""")
orphan_b_l = cur.fetchone()[0]

cur.execute("""
    SELECT COUNT(*) FROM "BUOI_HOC" b LEFT JOIN "PHONG_HOC" p ON b."MaPhongHoc" = p."MaPhongHoc" WHERE p."MaPhongHoc" IS NULL;
""")
orphan_b_p = cur.fetchone()[0]

cur.execute("""
    SELECT COUNT(*) FROM "BUOI_HOC" b LEFT JOIN "GIANG_VIEN" g ON b."MaGiangVien" = g."MaGiangVien" WHERE g."MaGiangVien" IS NULL;
""")
orphan_b_g = cur.fetchone()[0]

cur.execute("""
    SELECT COUNT(*) FROM "DON_THU" d LEFT JOIN "NGUOI_DUNG" n ON d."MaNguoiGui" = n."MaNguoiDung" WHERE n."MaNguoiDung" IS NULL;
""")
orphan_d_n = cur.fetchone()[0]

print(f"Orphan BUOI_HOC -> LOP_HOC: {orphan_b_l}")
print(f"Orphan BUOI_HOC -> PHONG_HOC: {orphan_b_p}")
print(f"Orphan BUOI_HOC -> GIANG_VIEN: {orphan_b_g}")
print(f"Orphan DON_THU -> NGUOI_DUNG: {orphan_d_n}")

conn.close()
