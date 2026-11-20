import sqlite3

con = sqlite3.connect('backend/language_center.db')
cur = con.cursor()
tables = [row[0] for row in cur.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
print("Tables in language_center.db:", tables)
for t in tables:
    count = cur.execute(f"SELECT COUNT(*) FROM [{t}]").fetchone()[0]
    print(f"  {t}: {count}")
con.close()
