"""
Backfill Script for N-05: Sinh thời khóa biểu đầy đủ cho các lớp học từ start_date đến end_date
Usage:
    python backend/qa_data/backfill_schedules.py --dry-run
    python backend/qa_data/backfill_schedules.py --db-path backend/qa_data/target.db
"""

import sys
import os
import argparse
import sqlite3
from datetime import datetime, date, timedelta

def run_backfill(db_path: str, dry_run: bool = True):
    print(f"=== BACKFILL SCHEDULE SESSIONS ===")
    print(f"Target DB: {db_path}")
    print(f"Mode: {'DRY RUN (No changes)' if dry_run else 'APPLY (Writing to DB)'}")

    conn = sqlite3.connect(db_path)
    c = conn.cursor()

    # Get classes with start_date and end_date
    c.execute("""
        SELECT l.MaLopHoc, l.MaSoLop, l.NgayBatDau, l.NgayKetThuc, l.MaGiangVien, k.ThoiLuongTuan, k.TenKhoaHoc
        FROM LOP_HOC l
        LEFT JOIN KHOA_HOC k ON l.MaKhoaHoc = k.MaKhoaHoc
        WHERE l.DaXoa = 0
    """)
    classes = c.fetchall()
    print(f"Total active classes: {len(classes)}")

    total_created = 0

    for cls in classes:
        cls_id, code, start_str, end_str, teacher_id, duration_weeks, course_name = cls
        if not start_str:
            continue

        start_d = datetime.strptime(start_str, "%Y-%m-%d").date()
        if end_str:
            end_d = datetime.strptime(end_str, "%Y-%m-%d").date()
        else:
            duration = duration_weeks or 12
            end_d = start_d + timedelta(weeks=duration)

        # Get existing sessions count for this class
        c.execute("SELECT COUNT(*) FROM BUOI_HOC WHERE MaLopHoc = ? AND DaXoa = 0", (cls_id,))
        existing_count = c.fetchone()[0]

        # Determine default schedule: Mon & Wed, 18:00 - 19:30
        cur_d = start_d
        new_sessions = []
        while cur_d <= end_d:
            if cur_d.weekday() in [0, 2]: # Mon, Wed
                # Check if exists
                c.execute("""
                    SELECT MaBuoiHoc FROM BUOI_HOC 
                    WHERE MaLopHoc = ? AND NgayHoc = ? AND GioBatDau = '18:00' AND DaXoa = 0
                """, (cls_id, cur_d.isoformat()))
                if not c.fetchone():
                    new_sessions.append((
                        cls_id,
                        1, # Default Classroom 1
                        teacher_id or 1,
                        cur_d.isoformat(),
                        "18:00",
                        "19:30",
                        "Ca tối (18:00 - 19:30)",
                        0, # Chưa xác nhận
                        "SCHEDULED",
                        datetime.now().isoformat(),
                        datetime.now().isoformat(),
                        0
                    ))
            cur_d += timedelta(days=1)

        print(f"Class {code}: current sessions={existing_count}, missing sessions to add={len(new_sessions)}")
        total_created += len(new_sessions)

        if not dry_run and new_sessions:
            c.executemany("""
                INSERT INTO BUOI_HOC (MaLopHoc, MaPhongHoc, MaGiangVien, NgayHoc, GioBatDau, GioKetThuc, CaHoc, DaXacNhan, TrangThai, NgayTao, NgayCapNhat, DaXoa)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, new_sessions)

    if not dry_run:
        conn.commit()
        print(f"\nSuccessfully committed {total_created} new sessions to {db_path}!")
    else:
        print(f"\nDry run complete. Total sessions that would be added: {total_created}")

    conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Backfill missing timetable sessions")
    parser.add_argument("--db-path", default="backend/language_center.db", help="Path to SQLite database")
    parser.add_argument("--apply", action="store_true", help="Actually insert data (defaults to dry-run)")
    args = parser.parse_args()

    run_backfill(args.db_path, dry_run=not args.apply)
