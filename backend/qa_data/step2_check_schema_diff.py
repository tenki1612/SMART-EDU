import os
import sys
import psycopg2
from pathlib import Path

# Add backend to sys.path
backend_path = Path("backend").resolve()
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

import app.models
from app.core.database import Base

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
conn = psycopg2.connect(PG_URL)
cur = conn.cursor()

print("=== CHECKING POSTGRESQL VS SQLALCHEMY MODELS ===")

# 1. Compare tables
orm_tables = set(Base.metadata.tables.keys())
cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='public';")
pg_tables = set(r[0] for r in cur.fetchall())

missing_in_pg = orm_tables - pg_tables
extra_in_pg = pg_tables - orm_tables
print(f"ORM Tables: {len(orm_tables)}")
print(f"PG Tables: {len(pg_tables)}")
if missing_in_pg:
    print(f"❌ Missing tables in PG: {missing_in_pg}")
else:
    print("✓ All ORM tables exist in PostgreSQL.")

# 2. Compare columns per table
print("\n--- COLUMN LEVEL COMPARISON ---")
diff_found = False
for t_name in sorted(orm_tables):
    orm_table = Base.metadata.tables[t_name]
    orm_cols = {c.name: c for c in orm_table.columns}
    
    cur.execute(f"""
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns 
        WHERE table_schema='public' AND table_name='{t_name}';
    """)
    pg_cols = {r[0]: {'type': r[1], 'nullable': r[2] == 'YES', 'default': r[3]} for r in cur.fetchall()}
    
    missing_cols = set(orm_cols.keys()) - set(pg_cols.keys())
    if missing_cols:
        print(f"❌ Table {t_name}: Missing columns in PG: {missing_cols}")
        diff_found = True
    
    extra_cols = set(pg_cols.keys()) - set(orm_cols.keys())
    if extra_cols:
        print(f"⚠️ Table {t_name}: Extra columns in PG: {extra_cols}")
        diff_found = True

if not diff_found:
    print("✓ All columns match perfectly between SQLAlchemy ORM and PostgreSQL!")

# 3. Check indexes in PostgreSQL
print("\n--- INDEXES IN POSTGRESQL ---")
cur.execute("""
    SELECT
        tablename,
        indexname,
        indexdef
    FROM pg_indexes
    WHERE schemaname = 'public'
    ORDER BY tablename, indexname;
""")
pg_indexes = cur.fetchall()
print(f"Total indexes in PG: {len(pg_indexes)}")
for idx in pg_indexes:
    print(f"  {idx[0]}: {idx[1]}")

conn.close()
