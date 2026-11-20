import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

print("=== ALL KHOA_HOC ===")
for r in cur.execute("SELECT MaKhoaHoc, MaSoKhoaHoc, TenKhoaHoc, TrinhDoMucTieu FROM KHOA_HOC").fetchall():
    print(r)

print("\n=== ALL TIEN_TRINH_KHOA_HOC ===")
for r in cur.execute("""
    SELECT t.MaTienTrinh, t.MaHocVien, 
           c1.TenKhoaHoc AS CurrentCourse, c1.TrinhDoMucTieu,
           c2.TenKhoaHoc AS NextCourse, c2.TrinhDoMucTieu,
           t.DuDieuKien, t.DaXacNhan, t.GhiChu
    FROM TIEN_TRINH_KHOA_HOC t
    LEFT JOIN KHOA_HOC c1 ON t.MaKhoaHocHienTai = c1.MaKhoaHoc
    LEFT JOIN KHOA_HOC c2 ON t.MaKhoaHocTiepTheo = c2.MaKhoaHoc
""").fetchall():
    print(r)

con.close()
