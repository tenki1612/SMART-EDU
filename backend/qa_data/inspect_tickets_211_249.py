import sqlite3
import psycopg2

sq_conn = sqlite3.connect("backend/language_center.db")
sq_cur = sq_conn.cursor()

sq_cur.execute("SELECT * FROM DON_THU WHERE MaDon >= 211 ORDER BY MaDon ASC")
tickets_211_249 = sq_cur.fetchall()
col_names = [d[0] for d in sq_cur.description]
print(f"Tickets 211-249 count: {len(tickets_211_249)}")
print("Columns:", col_names)
print("Sample ticket 211:", dict(zip(col_names, tickets_211_249[0])))

# Check responses for tickets 211-249
sq_cur.execute("SELECT * FROM DON_THU_PHAN_HOI WHERE MaDon >= 211 ORDER BY MaPhanHoi ASC")
responses = sq_cur.fetchall()
resp_cols = [d[0] for d in sq_cur.description]
print(f"Responses for tickets >= 211 count: {len(responses)}")
if responses:
    print("Sample response:", dict(zip(resp_cols, responses[0])))

sq_conn.close()
