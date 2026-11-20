import sys
import os
import sqlite3

sys.path.insert(0, 'backend')
import app.models
from app.core.database import Base

conn = sqlite3.connect('backend/language_center.db')
c = conn.cursor()

print("==================================================================")
print("🔍 AUDIT: FOREIGN KEYS, CONSTRAINTS & DATA INTEGRITY")
print("==================================================================\n")

# 1. Foreign Key Check
c.execute("PRAGMA foreign_key_check")
fk_errors = c.fetchall()
print(f"1. PRAGMA foreign_key_check: {len(fk_errors)} errors")
for err in fk_errors:
    print(f"   ❌ FK Violation: table={err[0]}, rowid={err[1]}, target_table={err[2]}, fkid={err[3]}")

# 2. Check for NULL in NOT NULL columns according to Model
print("\n2. Checking NOT NULL constraints against actual data:")
null_violations = []
for table_name, model_table in Base.metadata.tables.items():
    for col in model_table.columns:
        if not col.nullable and not col.primary_key:
            c.execute(f"SELECT COUNT(*) FROM '{table_name}' WHERE \"{col.name}\" IS NULL")
            null_count = c.fetchone()[0]
            if null_count > 0:
                print(f"   ❌ Table {table_name}, Column {col.name} has {null_count} NULL rows (Model says nullable=False)")
                null_violations.append((table_name, col.name, null_count))

if not null_violations:
    print("   ✅ Zero NOT NULL violations in all tables.")

# 3. Check Unique Constraints against actual data
print("\n3. Checking Unique Constraints against actual data:")
unique_violations = []
for table_name, model_table in Base.metadata.tables.items():
    for col in model_table.columns:
        if col.unique and not col.primary_key:
            c.execute(f"""
                SELECT \"{col.name}\", COUNT(*) 
                FROM '{table_name}' 
                WHERE \"{col.name}\" IS NOT NULL 
                GROUP BY \"{col.name}\" 
                HAVING COUNT(*) > 1
            """)
            dups = c.fetchall()
            if dups:
                print(f"   ❌ Table {table_name}, Column {col.name} has duplicate values: {dups[:3]}")
                unique_violations.append((table_name, col.name, len(dups)))

if not unique_violations:
    print("   ✅ Zero Unique constraint violations in all tables.")

# 4. Check Composite Unique Constraints
# e.g., NGUOI_DUNG: (Email, VaiTro)
c.execute("SELECT Email, VaiTro, COUNT(*) FROM NGUOI_DUNG WHERE DaXoa = 0 GROUP BY Email, VaiTro HAVING COUNT(*) > 1")
dups = c.fetchall()
if dups:
    print(f"   ❌ NGUOI_DUNG duplicate (Email, VaiTro): {dups}")
else:
    print("   ✅ NGUOI_DUNG (Email, VaiTro) composite unique verified: 0 duplicates.")

# HOC_VIEN_LOP_HOC: (MaLopHoc, MaHocVien) active enrollments
c.execute("""
    SELECT MaLopHoc, MaHocVien, COUNT(*) 
    FROM HOC_VIEN_LOP_HOC 
    WHERE DaXoa = 0 AND TrangThaiHoc != 'TRANSFERRED'
    GROUP BY MaLopHoc, MaHocVien 
    HAVING COUNT(*) > 1
""")
dups = c.fetchall()
if dups:
    print(f"   ❌ HOC_VIEN_LOP_HOC duplicate active enrollments: {dups}")
else:
    print("   ✅ HOC_VIEN_LOP_HOC (MaLopHoc, MaHocVien) unique verified: 0 duplicates.")

# BANG_DIEM: (MaLopHoc, MaHocVien)
c.execute("""
    SELECT MaLopHoc, MaHocVien, COUNT(*) 
    FROM BANG_DIEM 
    WHERE DaXoa = 0 
    GROUP BY MaLopHoc, MaHocVien 
    HAVING COUNT(*) > 1
""")
dups = c.fetchall()
if dups:
    print(f"   ❌ BANG_DIEM duplicate (MaLopHoc, MaHocVien): {dups}")
else:
    print("   ✅ BANG_DIEM (MaLopHoc, MaHocVien) unique verified: 0 duplicates.")

# 5. Check missing indexes that are defined in models
print("\n4. Checking Model Indexes vs DB Indexes:")
missing_indexes = []
for table_name, model_table in Base.metadata.tables.items():
    c.execute(f"PRAGMA index_list('{table_name}')")
    db_indexes = {r[1]: r for r in c.fetchall()}
    
    # Check column indexes
    for col in model_table.columns:
        if col.index and not col.primary_key:
            expected_idx_name = f"ix_{table_name}_{col.name}"
            # Check if an index covers this column
            found = False
            for idx_name in db_indexes:
                c.execute(f"PRAGMA index_info('{idx_name}')")
                cols = [r[2] for r in c.fetchall()]
                if col.name in cols:
                    found = True
                    break
            if not found:
                print(f"   ⚠️ Table {table_name}: Index on '{col.name}' is missing in DB!")
                missing_indexes.append((table_name, col.name))

if not missing_indexes:
    print("   ✅ All Model-defined indexes exist in DB.")

conn.close()
