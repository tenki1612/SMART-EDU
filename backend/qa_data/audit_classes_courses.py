import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

print("--- Classes and their courses ---")
classes = cur.execute("""
    SELECT l.MaLopHoc, l.MaSoLop, l.TrangThai, k.MaKhoaHoc, k.MaSoKhoaHoc, k.TenKhoaHoc, k.TrinhDoMucTieu
    FROM LOP_HOC l
    JOIN KHOA_HOC k ON l.MaKhoaHoc = k.MaKhoaHoc
    ORDER BY k.MaSoKhoaHoc, l.MaSoLop
""").fetchall()

for c in classes:
    print(c)

con.close()
