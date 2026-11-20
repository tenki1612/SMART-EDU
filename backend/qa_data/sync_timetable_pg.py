import psycopg2
import sqlite3
import argparse
from datetime import datetime, date, timedelta

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = "backend/language_center.db"

CLASSES_CONFIG = [
    {
        "class_id": 1,
        "code": "IELTS-65-K26A",
        "room_id": 1,
        "teacher_id": 1,
        "days": [0, 2], # Mon, Wed
        "start_time": "18:00",
        "end_time": "20:00",
        "slot_name": "Ca 3 (18:00 - 20:00)"
    },
    {
        "class_id": 3,
        "code": "TOEIC-750-K12",
        "room_id": 2,
        "teacher_id": 2,
        "days": [1, 3], # Tue, Thu
        "start_time": "14:00",
        "end_time": "16:00",
        "slot_name": "Ca 2 (14:00 - 16:00)"
    },
    {
        "class_id": 4,
        "code": "IELTS-65-K26B",
        "room_id": 5,
        "teacher_id": 3,
        "days": [1, 3], # Tue, Thu
        "start_time": "18:00",
        "end_time": "20:00",
        "slot_name": "Ca 3 (18:00 - 20:00)"
    },
    {
        "class_id": 5,
        "code": "COMM-A2-K08",
        "room_id": 6,
        "teacher_id": 4,
        "days": [0, 2], # Mon, Wed
        "start_time": "08:00",
        "end_time": "10:00",
        "slot_name": "Ca 1 (08:00 - 10:00)"
    },
    {
        "class_id": 6,
        "code": "COMM-B1-K09",
        "room_id": 9,
        "teacher_id": 7,
        "days": [0, 4], # Mon, Fri
        "start_time": "18:00",
        "end_time": "20:00",
        "slot_name": "Ca 3 (18:00 - 20:00)"
    },
    {
        "class_id": 7,
        "code": "IELTS-50-K15",
        "room_id": 7,
        "teacher_id": 6,
        "days": [2, 4], # Wed, Fri
        "start_time": "14:00",
        "end_time": "16:00",
        "slot_name": "Ca 2 (14:00 - 16:00)"
    },
    {
        "class_id": 8,
        "code": "TOEIC-550-K30",
        "room_id": 3,
        "teacher_id": 5,
        "days": [5, 6], # Sat, Sun
        "start_time": "08:00",
        "end_time": "10:00",
        "slot_name": "Ca 1 (08:00 - 10:00)"
    },
    {
        "class_id": 9,
        "code": "TEENS-B2-K04",
        "room_id": 10,
        "teacher_id": 6,
        "days": [5, 6], # Sat, Sun
        "start_time": "14:00",
        "end_time": "16:00",
        "slot_name": "Ca 2 (14:00 - 16:00)"
    }
]

def sync_postgres(dry_run: bool = True):
    print(f"\n=== SYNCING TIMETABLE TO POSTGRESQL (dry_run={dry_run}) ===")
    conn = psycopg2.connect(PG_URL)
    cur = conn.cursor()

    total_added = 0
    today = date.today()

    for cfg in CLASSES_CONFIG:
        cid = cfg["class_id"]
        cur.execute('SELECT "MaSoLop", "NgayBatDau", "NgayKetThuc" FROM "LOP_HOC" WHERE "MaLopHoc" = %s AND "DaXoa" = false', (cid,))
        row = cur.fetchone()
        if not row:
            continue
        code, start_d, end_d = row
        
        cur.execute('SELECT "MaBuoiHoc", "NgayHoc", "GioBatDau" FROM "BUOI_HOC" WHERE "MaLopHoc" = %s AND "DaXoa" = false', (cid,))
        existing = cur.fetchall()
        existing_dates = {r[1] for r in existing}

        new_sessions = []
        cur_d = start_d
        while cur_d <= end_d:
            if cur_d.weekday() in cfg["days"]:
                if cur_d not in existing_dates:
                    status = "COMPLETED" if cur_d < today else "SCHEDULED"
                    new_sessions.append((
                        cid,
                        cfg["room_id"],
                        cfg["teacher_id"],
                        cur_d,
                        cfg["start_time"],
                        cfg["end_time"],
                        cfg["slot_name"],
                        True,
                        status,
                        datetime.now(),
                        datetime.now(),
                        False
                    ))
            cur_d += timedelta(days=1)

        print(f"PG: Class {cid:2d} ({code:15s}): Existing {len(existing):2d} | Adding {len(new_sessions):2d} | Total {len(existing) + len(new_sessions):2d}")
        total_added += len(new_sessions)

        if not dry_run and new_sessions:
            cur.executemany('''
                INSERT INTO "BUOI_HOC" (
                    "MaLopHoc", "MaPhongHoc", "MaGiangVien", "NgayHoc", "GioBatDau", "GioKetThuc", 
                    "CaHoc", "DaXacNhan", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa"
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ''', new_sessions)

    if not dry_run:
        conn.commit()
        print(f"✓ Committed {total_added} sessions to PostgreSQL.")
    conn.close()

def sync_sqlite(dry_run: bool = True):
    print(f"\n=== SYNCING TIMETABLE TO SQLITE (dry_run={dry_run}) ===")
    conn = sqlite3.connect(SQLITE_PATH)
    cur = conn.cursor()

    total_added = 0
    today = date.today()

    for cfg in CLASSES_CONFIG:
        cid = cfg["class_id"]
        cur.execute('SELECT MaSoLop, NgayBatDau, NgayKetThuc FROM LOP_HOC WHERE MaLopHoc = ? AND DaXoa = 0', (cid,))
        row = cur.fetchone()
        if not row:
            continue
        code, start_str, end_str = row
        start_d = datetime.strptime(start_str, "%Y-%m-%d").date() if isinstance(start_str, str) else start_str
        end_d = datetime.strptime(end_str, "%Y-%m-%d").date() if isinstance(end_str, str) else end_str

        cur.execute('SELECT MaBuoiHoc, NgayHoc, GioBatDau FROM BUOI_HOC WHERE MaLopHoc = ? AND DaXoa = 0', (cid,))
        existing = cur.fetchall()
        existing_dates = set()
        for r in existing:
            ed = datetime.strptime(r[1], "%Y-%m-%d").date() if isinstance(r[1], str) else r[1]
            existing_dates.add(ed)

        new_sessions = []
        cur_d = start_d
        while cur_d <= end_d:
            if cur_d.weekday() in cfg["days"]:
                if cur_d not in existing_dates:
                    status = "COMPLETED" if cur_d < today else "SCHEDULED"
                    new_sessions.append((
                        cid,
                        cfg["room_id"],
                        cfg["teacher_id"],
                        cur_d.strftime("%Y-%m-%d"),
                        cfg["start_time"],
                        cfg["end_time"],
                        cfg["slot_name"],
                        1,
                        status,
                        datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        0
                    ))
            cur_d += timedelta(days=1)

        print(f"SQLite: Class {cid:2d} ({code:15s}): Existing {len(existing):2d} | Adding {len(new_sessions):2d} | Total {len(existing) + len(new_sessions):2d}")
        total_added += len(new_sessions)

        if not dry_run and new_sessions:
            cur.executemany('''
                INSERT INTO BUOI_HOC (
                    MaLopHoc, MaPhongHoc, MaGiangVien, NgayHoc, GioBatDau, GioKetThuc, 
                    CaHoc, DaXacNhan, TrangThai, NgayTao, NgayCapNhat, DaXoa
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', new_sessions)

    if not dry_run:
        conn.commit()
        print(f"✓ Committed {total_added} sessions to SQLite.")
    conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="Apply changes to databases")
    args = parser.parse_args()

    sync_postgres(dry_run=not args.apply)
    sync_sqlite(dry_run=not args.apply)
