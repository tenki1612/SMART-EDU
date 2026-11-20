import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()

for table in ['KHOA_HOC', 'TIEN_TRINH_KHOA_HOC', 'LOP_HOC', 'BUOI_HOC', 'BANG_DIEM', 'YEU_CAU_DANG_KY']:
    print(f"\n--- {table} columns ---")
    cols = cur.execute(f"PRAGMA table_info([{table}])").fetchall()
    for c in cols:
        print(f"  {c[1]} ({c[2]})")

print("\n=== TIEN_TRINH_KHOA_HOC data ===")
for r in cur.execute("SELECT * FROM TIEN_TRINH_KHOA_HOC").fetchall():
    print(r)

print("\n=== BUOI_HOC data ===")
for r in cur.execute("SELECT * FROM BUOI_HOC LIMIT 15").fetchall():
    print(r)

print("\n=== KHOA_HOC sample ===")
for r in cur.execute("SELECT * FROM KHOA_HOC LIMIT 5").fetchall():
    print(r)

con.close()
