import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

print("--- IELTS-65 classes ---")
for r in cur.execute("SELECT MaLopHoc, MaSoLop, MaKhoaHoc, NgayBatDau, NgayKetThuc, TrangThai FROM LOP_HOC WHERE MaSoLop LIKE '%IELTS-65%'").fetchall():
    print(r)

print("\n--- Sessions for Class 1 ---")
for s in cur.execute("SELECT MaBuoiHoc, NgayHoc, GioBatDau, GioKetThuc, CaHoc, TrangThai FROM BUOI_HOC WHERE MaLopHoc=1 ORDER BY NgayHoc").fetchall():
    print(s)

print("\n--- All distinct classes with sessions in BUOI_HOC ---")
for r in cur.execute("""
    SELECT l.MaLopHoc, l.MaSoLop, l.NgayBatDau, l.NgayKetThuc, COUNT(b.MaBuoiHoc), MIN(b.NgayHoc), MAX(b.NgayHoc)
    FROM LOP_HOC l
    JOIN BUOI_HOC b ON l.MaLopHoc = b.MaLopHoc
    GROUP BY l.MaLopHoc
""").fetchall():
    print(r)

con.close()
