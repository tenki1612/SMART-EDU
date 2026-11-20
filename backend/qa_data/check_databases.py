import os
import sys

print("=== CHECKING POSTGRESQL & SQLITE ===")

# 1. Try PostgreSQL
try:
    import psycopg2
    pg_url = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
    conn = psycopg2.connect(pg_url)
    cur = conn.cursor()
    cur.execute('SELECT COUNT(*) FROM "KHOA_HOC";')
    cnt_courses = cur.fetchone()[0]
    cur.execute('SELECT COUNT(*) FROM "DON_THU";')
    cnt_tickets = cur.fetchone()[0]
    cur.execute('SELECT COUNT(*) FROM "LOP_HOC";')
    cnt_classes = cur.fetchone()[0]
    conn.close()
    print(f"PostgreSQL CONNECTED! Courses: {cnt_courses}, Classes: {cnt_classes}, Tickets: {cnt_tickets}")
except Exception as e:
    print(f"PostgreSQL NOT CONNECTED or Error: {e}")

# 2. Try SQLite
try:
    import sqlite3
    sq_path = os.path.abspath("backend/language_center.db")
    conn = sqlite3.connect(sq_path)
    cur = conn.cursor()
    cur.execute('SELECT COUNT(*) FROM KHOA_HOC WHERE DaXoa = 0;')
    cnt_courses = cur.fetchone()[0]
    cur.execute('SELECT COUNT(*) FROM DON_THU WHERE DaXoa = 0;')
    cnt_tickets = cur.fetchone()[0]
    cur.execute('SELECT COUNT(*) FROM LOP_HOC WHERE DaXoa = 0;')
    cnt_classes = cur.fetchone()[0]
    conn.close()
    print(f"SQLite CONNECTED! Path: {sq_path}")
    print(f"  -> Courses: {cnt_courses}, Classes: {cnt_classes}, Tickets: {cnt_tickets}")
except Exception as e:
    print(f"SQLite Error: {e}")

# 3. Check what the running backend on 8000 is using
import requests
try:
    res = requests.get("http://127.0.0.1:8000/api/v1/courses/")
    data = res.json().get("data", [])
    print(f"Running Backend on 8000: returned {len(data)} courses.")
except Exception as e:
    print(f"Running Backend Error: {e}")
