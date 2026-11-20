import psycopg2
import subprocess
import os
import sys

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
BACKUP_SQL = os.path.abspath("backend/qa_data/postgres_backup_pre_sync.sql")

print("--- STEP 1: BACKUP POSTGRESQL DATABASE ---")

# Try pg_dump via WSL or direct
wsl_cmd = f"wsl pg_dump -U postgres -h 127.0.0.1 -p 5432 -d language_center > \"{BACKUP_SQL}\""
print(f"Executing pg_dump via WSL...")
env = os.environ.copy()
env["PGPASSWORD"] = "postgrespassword2026"

# Run pg_dump command in WSL with PGPASSWORD
wsl_exec = [
    "wsl", "sh", "-c", 
    f"PGPASSWORD=postgrespassword2026 pg_dump -U postgres -h 127.0.0.1 -p 5432 -d language_center"
]

try:
    with open(BACKUP_SQL, "w", encoding="utf-8") as f:
        res = subprocess.run(wsl_exec, stdout=f, stderr=subprocess.PIPE, text=True, check=True)
    size = os.path.getsize(BACKUP_SQL)
    print(f"✓ Backup created successfully: {BACKUP_SQL} (Size: {size:,} bytes)")
except Exception as e:
    print(f"pg_dump failed: {e}. Falling back to Python exporter...")
    # Python-based dump fallback
    conn = psycopg2.connect(PG_URL)
    cur = conn.cursor()
    cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema='public';")
    tables = [r[0] for r in cur.fetchall()]
    with open(BACKUP_SQL, "w", encoding="utf-8") as f:
        f.write("-- POSTGRESQL BACKUP CREATED BY PYTHON\n\n")
        for t in tables:
            cur.execute(f'SELECT * FROM "{t}";')
            rows = cur.fetchall()
            cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name='{t}' ORDER BY ordinal_position;")
            cols = [r[0] for r in cur.fetchall()]
            col_str = ", ".join([f'"{c}"' for c in cols])
            f.write(f"-- TABLE {t}: {len(rows)} rows\n")
            for row in rows:
                val_strs = []
                for val in row:
                    if val is None:
                        val_strs.append("NULL")
                    elif isinstance(val, (int, float)):
                        val_strs.append(str(val))
                    elif isinstance(val, bool):
                        val_strs.append("TRUE" if val else "FALSE")
                    else:
                        clean_str = str(val).replace("'", "''")
                        val_strs.append(f"'{clean_str}'")
                f.write(f'INSERT INTO "{t}" ({col_str}) VALUES ({", ".join(val_strs)});\n')
            f.write("\n")
    conn.close()
    size = os.path.getsize(BACKUP_SQL)
    print(f"✓ Python backup created: {BACKUP_SQL} (Size: {size:,} bytes)")

# Verify backup is readable
if os.path.exists(BACKUP_SQL) and os.path.getsize(BACKUP_SQL) > 10000:
    with open(BACKUP_SQL, "r", encoding="utf-8") as f:
        sample = f.read(500)
    print("✓ Backup verification: file is readable and non-empty.")
    print("Sample:\n" + sample[:200] + "...")
else:
    print("❌ Backup failed or file too small!")
    sys.exit(1)
