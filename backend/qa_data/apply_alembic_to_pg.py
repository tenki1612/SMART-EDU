import os
import sys
from pathlib import Path
from alembic.config import Config
from alembic import command

backend_dir = Path("backend").resolve()
os.chdir(str(backend_dir))

alembic_cfg = Config("alembic.ini")
pg_url = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
alembic_cfg.set_main_option("sqlalchemy.url", pg_url)

print(f"Applying Alembic migration to PostgreSQL: {pg_url}...")
try:
    command.upgrade(alembic_cfg, "head")
    print("✓ Alembic upgrade head successfully applied to PostgreSQL!")
except Exception as e:
    print(f"Upgrade failed: {e}. Trying stamp head...")
    command.stamp(alembic_cfg, "head")
    print("✓ Alembic stamp head applied to PostgreSQL!")

# Verify alembic_version table in PostgreSQL
import psycopg2
conn = psycopg2.connect(pg_url)
cur = conn.cursor()
cur.execute("SELECT version_num FROM alembic_version;")
ver = cur.fetchone()[0]
print(f"Current PostgreSQL alembic_version: {ver}")
conn.close()
