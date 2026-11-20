import sqlite3
import psycopg2

sq_conn = sqlite3.connect("backend/language_center.db")
sq_cur = sq_conn.cursor()
sq_cur.execute("SELECT * FROM TIEN_TRINH_KHOA_HOC WHERE MaTienTrinh > 7")
rows = sq_cur.fetchall()
cols = [d[0] for d in sq_cur.description]
print(f"Progression rows > 7: {len(rows)}")
for r in rows:
    print(dict(zip(cols, r)))
sq_conn.close()
