import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

print("=== KHOA_HOC sample ===")
for r in cur.execute("SELECT MaKhoaHoc, TenKhoaHoc, TrinhDoMucTieu, SoTuan FROM KHOA_HOC LIMIT 10"):
    print(r)

print("\n=== TIEN_TRINH_KHOA_HOC ===")
for r in cur.execute("SELECT * FROM TIEN_TRINH_KHOA_HOC"):
    print(r)

print("\n=== LOP_HOC sample ===")
for r in cur.execute("SELECT MaLop, KhoaHocId, NgayKhaiGiang, NgayKetThuc, TrangThai FROM LOP_HOC LIMIT 10"):
    print(r)

print("\n=== BUOI_HOC for class IELTS-65-K26A or similar ===")
for r in cur.execute("""
    SELECT b.Id, l.MaLop, b.NgayHoc, b.GioBatDau, b.GioKetThuc, b.ThuTrongTuan, b.TrangThai 
    FROM BUOI_HOC b
    JOIN LOP_HOC l ON b.LopHocId = l.Id
    ORDER BY l.MaLop, b.NgayHoc
"""):
    print(r)

con.close()
