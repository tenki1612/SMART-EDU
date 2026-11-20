import psycopg2
import sqlite3
import os

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = os.path.abspath("backend/language_center.db")

pg_conn = psycopg2.connect(PG_URL)
pg_cur = pg_conn.cursor()

sq_conn = sqlite3.connect(SQLITE_PATH)
sq_cur = sq_conn.cursor()

pg_cur.execute('SELECT "MaDon", "MaSoDon", "MaNguoiGui", "MaNguoiNhan", "MaLopHoc", "TieuDe" FROM "DON_THU" ORDER BY "MaDon";')
pg_tickets = {r[0]: r for r in pg_cur.fetchall()}

sq_cur.execute('SELECT MaDon, MaSoDon, MaNguoiGui, MaNguoiNhan, MaLopHoc, TieuDe FROM DON_THU ORDER BY MaDon;')
sq_tickets = {r[0]: r for r in sq_cur.fetchall()}

print(f"PG Tickets: {len(pg_tickets)} (IDs: {min(pg_tickets.keys())} - {max(pg_tickets.keys())})")
print(f"SQ Tickets: {len(sq_tickets)} (IDs: {min(sq_tickets.keys())} - {max(sq_tickets.keys())})")

# Check ticket 1-210 diffs
diff_count = 0
for tid in range(1, 211):
    pg_t = pg_tickets.get(tid)
    sq_t = sq_tickets.get(tid)
    if pg_t != sq_t:
        diff_count += 1
        if diff_count <= 5:
            print(f"Diff ticket {tid}:")
            print("  PG:", pg_t)
            print("  SQ:", sq_t)

print(f"Total diffs in tickets 1-210: {diff_count}")

# Check tickets 211-249 in SQ
print("Tickets 211-249 in SQ:")
for tid in range(211, 250):
    print(" ", sq_tickets.get(tid))

pg_conn.close()
sq_conn.close()
