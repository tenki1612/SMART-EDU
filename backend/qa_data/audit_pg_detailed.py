import psycopg2
import json

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"

conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

# Get all tables in public schema
cur.execute("""
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    ORDER BY table_name;
""")
tables = [r[0] for r in cur.fetchall()]

print(f"Total tables in PostgreSQL public schema: {len(tables)}")
print("Tables:", tables)

print("\n--- TABLE ROW COUNTS ---")
row_counts = {}
for t in tables:
    cur.execute(f'SELECT COUNT(*) FROM "{t}";')
    cnt = cur.fetchone()[0]
    row_counts[t] = cnt
    print(f"{t}: {cnt} rows")

print("\n--- FOREIGN KEYS ---")
cur.execute("""
    SELECT
        tc.table_name, 
        kcu.column_name, 
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name 
    FROM information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema='public'
    ORDER BY tc.table_name, kcu.column_name;
""")
fks = cur.fetchall()
for fk in fks:
    print(f"{fk[0]}.{fk[1]} -> {fk[2]}.{fk[3]}")

conn.close()
