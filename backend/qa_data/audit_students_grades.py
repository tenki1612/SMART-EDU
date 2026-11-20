import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

print("--- Students and their grades in BANG_DIEM ---")
for r in cur.execute("""
    SELECT g.MaHocVien, u.HoTen, l.MaSoLop, k.TenKhoaHoc, k.TrinhDoMucTieu, 
           g.DiemTongKet, g.KetQua, g.DaKhoaSo
    FROM BANG_DIEM g
    JOIN HOC_VIEN h ON g.MaHocVien = h.MaHocVien
    JOIN NGUOI_DUNG u ON h.MaNguoiDung = u.MaNguoiDung
    JOIN LOP_HOC l ON g.MaLopHoc = l.MaLopHoc
    JOIN KHOA_HOC k ON l.MaKhoaHoc = k.MaKhoaHoc
    LIMIT 25
""").fetchall():
    print(r)

con.close()
