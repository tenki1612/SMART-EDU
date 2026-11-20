import sqlite3

sq_conn = sqlite3.connect("backend/language_center.db")
sq_cur = sq_conn.cursor()
sq_cur.execute("""
    SELECT hv.MaHocVien, hv.MaSoHocVien, nd.MaNguoiDung, nd.TenDangNhap, nd.Email, nd.HoTen, nd.VaiTro
    FROM HOC_VIEN hv
    JOIN NGUOI_DUNG nd ON hv.MaNguoiDung = nd.MaNguoiDung
    WHERE hv.MaHocVien >= 361
    ORDER BY hv.MaHocVien ASC;
""")
rows = sq_cur.fetchall()
print(f"Extra students count: {len(rows)}")
for r in rows[:5]:
    print(" ", r)
sq_conn.close()
