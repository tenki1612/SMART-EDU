import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()
cls = cur.execute("SELECT MaLopHoc, MaSoLop, NgayBatDau, NgayKetThuc, TrangThai FROM LOP_HOC WHERE NgayBatDau='2026-11-01' OR NgayKetThuc='2027-01-24'").fetchall()
print('Classes matching dates:', cls)
for c in cls:
    sessions = cur.execute('SELECT MaBuoiHoc, NgayHoc, GioBatDau, GioKetThuc FROM BUOI_HOC WHERE MaLopHoc=?', (c[0],)).fetchall()
    print(f'Class {c[1]} (id={c[0]}): {len(sessions)} sessions')
    for s in sessions:
        print('  Session:', s)

print("\n--- ALL CLASSES AND THEIR SESSIONS COUNT ---")
for c in cur.execute("SELECT MaLopHoc, MaSoLop, NgayBatDau, NgayKetThuc, TrangThai FROM LOP_HOC").fetchall():
    count = cur.execute("SELECT COUNT(*) FROM BUOI_HOC WHERE MaLopHoc=?", (c[0],)).fetchone()[0]
    if count > 0:
        print(f"Class {c[1]} (id={c[0]}): {count} sessions, start={c[2]}, end={c[3]}")

con.close()
