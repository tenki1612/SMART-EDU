import sys
import os
import sqlite3

sys.path.insert(0, 'backend')
import app.models
from app.core.database import Base

conn = sqlite3.connect('backend/language_center.db')
c = conn.cursor()

print("==================================================================")
print("🔍 DEEP AUDIT: SQLALCHEMY MODELS VS REAL DATABASE TABLES")
print("==================================================================\n")

total_issues = 0

for table_name, model_table in Base.metadata.tables.items():
    print(f"📌 TABLE: {table_name}")
    c.execute(f"PRAGMA table_info('{table_name}')")
    # cid, name, type, notnull, dflt_value, pk
    db_cols = {r[1]: {'type': r[2], 'notnull': r[3], 'dflt': r[4], 'pk': r[5]} for r in c.fetchall()}
    
    # 1. Missing columns in DB
    missing_cols = []
    for col in model_table.columns:
        if col.name not in db_cols:
            missing_cols.append(col)
            total_issues += 1
            print(f"  ❌ MISSING COLUMN in DB: {col.name} ({col.type}, nullable={col.nullable}, default={col.default})")
            
    if not missing_cols:
        print("  ✅ All Model columns exist in DB.")
        
    # 2. Extra columns in DB
    extra_cols = [cname for cname in db_cols if cname not in model_table.columns]
    if extra_cols:
        print(f"  ℹ️ Extra columns in DB: {extra_cols}")
        
    # 3. Column properties & types
    for col in model_table.columns:
        if col.name in db_cols:
            db_info = db_cols[col.name]
            # Check PK
            if bool(col.primary_key) != bool(db_info['pk']):
                print(f"  ⚠️ PK mismatch on {col.name}: Model={col.primary_key}, DB={db_info['pk']}")
                total_issues += 1
            # Check nullable (only flag if model says NOT NULL but DB allows NULL or vice versa)
            model_notnull = 1 if not col.nullable else 0
            # Note: SQLite primary keys are implicitly not null
            if not col.primary_key and model_notnull != db_info['notnull']:
                print(f"  ⚠️ Nullable mismatch on {col.name}: Model notnull={model_notnull}, DB notnull={db_info['notnull']}")
                
    # 4. Check Foreign Keys
    c.execute(f"PRAGMA foreign_key_list('{table_name}')")
    db_fks = c.fetchall()
    # id, seq, table, from, to, on_update, on_delete, match
    db_fk_map = {r[3]: (r[2], r[4]) for r in db_fks}
    
    for col in model_table.columns:
        if col.foreign_keys:
            for fk in col.foreign_keys:
                target_table = fk.column.table.name
                target_col = fk.column.name
                if col.name in db_fk_map:
                    db_target_t, db_target_c = db_fk_map[col.name]
                    if db_target_t != target_table or (db_target_c and db_target_c != target_col):
                        print(f"  ⚠️ FK target mismatch on {col.name}: Model->{target_table}.{target_col}, DB->{db_target_t}.{db_target_c}")
                        total_issues += 1
                else:
                    print(f"  ⚠️ FK missing in DB on {col.name}: Model has FK to {target_table}.{target_col}")
                    
    # 5. Check Indexes
    c.execute(f"PRAGMA index_list('{table_name}')")
    db_indexes = c.fetchall()
    print(f"  📊 DB Indexes: {len(db_indexes)} indexes")
    for idx in db_indexes:
        c.execute(f"PRAGMA index_info('{idx[1]}')")
        idx_cols = [r[2] for r in c.fetchall()]
        print(f"     * {idx[1]} (unique={idx[2]}): {idx_cols}")
        
    print()

print(f"TOTAL CRITICAL ISSUES DETECTED: {total_issues}")
conn.close()
