import psycopg2
conn = psycopg2.connect('postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center')
cur = conn.cursor()
cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name='KHOA_HOC';")
for r in cur.fetchall():
    print(r)
cur.execute('SELECT * FROM "KHOA_HOC" LIMIT 1;')
cols = [d[0] for d in cur.description]
print('Sample row:', dict(zip(cols, cur.fetchone())))
conn.close()
