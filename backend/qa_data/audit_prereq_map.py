import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

courses = cur.execute("SELECT MaKhoaHoc, MaSoKhoaHoc, TenKhoaHoc, TrinhDoMucTieu FROM KHOA_HOC").fetchall()
for c in courses:
    print(c)

con.close()
