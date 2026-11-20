import sys
import os
import sqlite3

sys.path.insert(0, 'backend')
import app.models
from app.core.database import Base

db_path = os.path.abspath('backend/language_center.db')
print(f"Target Database: {db_path}")

conn = sqlite3.connect(db_path)
c = conn.cursor()

# 1. DB Tables
c.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
db_tables = sorted([r[0] for r in c.fetchall()])

# 2. Model Tables
model_tables = sorted(list(Base.metadata.tables.keys()))

print("\n=== 1. TABLE LEVEL COMPARISON ===")
print(f"Total DB Tables: {len(db_tables)}")
print(f"Total Model Tables: {len(model_tables)}")

tables_in_model_not_db = [t for t in model_tables if t not in db_tables]
tables_in_db_not_model = [t for t in db_tables if t not in model_tables]

print(f"Tables in Model missing in DB: {tables_in_model_not_db}")
print(f"Tables in DB not in Model: {tables_in_db_not_model}")

# 3. Column & Constraint Comparison
print("\n=== 2. COLUMN & CONSTRAINT COMPARISON ===")
common_tables = [t for t in model_tables if t in db_tables]

comparison_results = {}

for t_name in common_tables:
    m_table = Base.metadata.tables[t_name]
    
    # DB Columns
    c.execute(f"PRAGMA table_info('{t_name}')")
    # cid, name, type, notnull, dflt_value, pk
    db_cols = {r[1]: {'type': r[2], 'notnull': r[3], 'dflt': r[4], 'pk': r[5]} for r in c.fetchall()}
    
    # Model Columns
    m_cols = {col.name: col for col in m_table.columns}
    
    missing_in_db = [col for col in m_cols if col not in db_cols]
    extra_in_db = [col for col in db_cols if col not in m_cols]
    
    # Check FKs in DB
    c.execute(f"PRAGMA foreign_key_list('{t_name}')")
    # id, seq, table, from, to, on_update, on_delete, match
    db_fks = c.fetchall()
    
    # Check Indexes in DB
    c.execute(f"PRAGMA index_list('{t_name}')")
    db_indexes = c.fetchall()
    
    # Count rows in DB
    c.execute(f"SELECT COUNT(*) FROM '{t_name}'")
    row_count = c.fetchone()[0]
    
    comparison_results[t_name] = {
        'row_count': row_count,
        'missing_in_db': missing_in_db,
        'extra_in_db': extra_in_db,
        'db_fks': db_fks,
        'db_indexes': db_indexes,
        'm_cols': m_cols,
        'db_cols': db_cols
    }

for t_name in common_tables:
    info = comparison_results[t_name]
    print(f"\n--- Table: {t_name} (Rows: {info['row_count']}) ---")
    if info['missing_in_db']:
        print(f"  ❌ Missing columns in DB: {info['missing_in_db']}")
        for col_name in info['missing_in_db']:
            col = info['m_cols'][col_name]
            print(f"     -> {col.name}: {col.type}, nullable={col.nullable}, default={col.default}")
    else:
        print("  ✅ All Model columns present in DB")
        
    if info['extra_in_db']:
        print(f"  ℹ️ Extra columns in DB (not in Model): {info['extra_in_db']}")
        
    # Check types and nullability for common columns
    common_cols = [c for c in info['m_cols'] if c in info['db_cols']]
    for c_name in common_cols:
        m_col = info['m_cols'][c_name]
        db_col = info['db_cols'][c_name]
        # check nullability mismatch
        m_notnull = not m_col.nullable
        if m_notnull != bool(db_col['notnull']):
            print(f"  ⚠️ Nullability mismatch on {c_name}: Model notnull={m_notnull}, DB notnull={bool(db_col['notnull'])}")

conn.close()
