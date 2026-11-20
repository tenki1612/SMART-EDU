"""
POSTGRESQL SYNCHRONIZATION SCRIPT FOR SMART-EDU (V2)
Syncs schema optimizations (indexes), expanded courses, classes, conflict-free schedules,
student enrollments, grades, transfers, and preserves tickets 211-249.
Zero data deletion, zero DROP/TRUNCATE.
"""

import psycopg2
import sqlite3
import os
import sys
from datetime import datetime, date, timedelta
from psycopg2.extras import execute_batch

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = os.path.abspath("backend/language_center.db")

def run_sync():
    print("==================================================================")
    print("🚀 SYNCHRONIZING POSTGRESQL WITH SMART-EDU SOURCE CODE & EXPANDED MODEL")
    print("==================================================================")

    pg_conn = psycopg2.connect(PG_URL)
    pg_conn.autocommit = False
    pg_cur = pg_conn.cursor()

    sq_conn = sqlite3.connect(SQLITE_PATH)
    sq_cur = sq_conn.cursor()

    now_dt = datetime.now()

    # -------------------------------------------------------------
    # 1. OPTIMIZE SCHEMA: ADD MISSING FOREIGN KEY INDEXES TO POSTGRESQL
    # -------------------------------------------------------------
    print("\n⚡ [1/7] Adding missing foreign key indexes to PostgreSQL...")
    indexes_to_create = [
        ("ix_BUOI_HOC_MaLopHoc", "BUOI_HOC", "MaLopHoc"),
        ("ix_BUOI_HOC_MaPhongHoc", "BUOI_HOC", "MaPhongHoc"),
        ("ix_BUOI_HOC_MaGiangVien", "BUOI_HOC", "MaGiangVien"),
        ("ix_LOP_HOC_MaKhoaHoc", "LOP_HOC", "MaKhoaHoc"),
        ("ix_LOP_HOC_MaGiangVien", "LOP_HOC", "MaGiangVien"),
        ("ix_BANG_DIEM_MaLopHoc", "BANG_DIEM", "MaLopHoc"),
        ("ix_BANG_DIEM_MaHocVien", "BANG_DIEM", "MaHocVien"),
        ("ix_HOC_VIEN_LOP_HOC_MaLopHoc", "HOC_VIEN_LOP_HOC", "MaLopHoc"),
        ("ix_HOC_VIEN_LOP_HOC_MaHocVien", "HOC_VIEN_LOP_HOC", "MaHocVien"),
        ("ix_YEU_CAU_DANG_KY_MaLopHoc", "YEU_CAU_DANG_KY", "MaLopHoc"),
        ("ix_YEU_CAU_DANG_KY_MaHocVien", "YEU_CAU_DANG_KY", "MaHocVien"),
        ("ix_PHU_HUYNH_HOC_VIEN_MaHocVien", "PHU_HUYNH_HOC_VIEN", "MaHocVien"),
        ("ix_PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH", "PHU_HUYNH_HOC_VIEN", "MaNguoiDung_PH"),
        ("ix_TIEN_TRINH_KHOA_HOC_MaHocVien", "TIEN_TRINH_KHOA_HOC", "MaHocVien"),
        ("ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai", "TIEN_TRINH_KHOA_HOC", "MaKhoaHocHienTai"),
        ("ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo", "TIEN_TRINH_KHOA_HOC", "MaKhoaHocTiepTheo"),
        ("ix_LICHSU_KHOA_DIEM_MaNguoiThucHien", "LICHSU_KHOA_DIEM", "MaNguoiThucHien"),
    ]
    for idx_name, tbl, col in indexes_to_create:
        pg_cur.execute(f'CREATE INDEX IF NOT EXISTS "{idx_name}" ON "{tbl}" ("{col}");')
    pg_conn.commit()
    print(f"  ✓ Verified/created {len(indexes_to_create)} foreign key indexes.")

    # -------------------------------------------------------------
    # 2. SYNC PHONG_HOC (ROOMS)
    # -------------------------------------------------------------
    print("\n🏫 [2/7] Syncing PHONG_HOC (Rooms)...")
    new_classrooms = [
        ("P.104", "Tòa nhà A", 30),
        ("P.204", "Tòa nhà B", 30),
        ("P.304", "Tòa nhà C", 25),
        ("P.401", "Tòa nhà B", 35),
        ("P.402", "Tòa nhà B", 35),
        ("LAB.301", "Tòa nhà A (Phòng máy)", 30),
        ("LAB.302", "Tòa nhà B (Phòng máy)", 30),
    ]
    for code, loc, cap in new_classrooms:
        pg_cur.execute('SELECT "MaPhongHoc" FROM "PHONG_HOC" WHERE "MaSoPhong" = %s;', (code,))
        if not pg_cur.fetchone():
            pg_cur.execute("""
                INSERT INTO "PHONG_HOC" ("MaSoPhong", "ToaNha", "SucChua", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa")
                VALUES (%s, %s, %s, 'AVAILABLE', %s, %s, FALSE);
            """, (code, loc, cap, now_dt, now_dt))
            print(f"  + Added Room: {code} ({loc})")
    pg_conn.commit()

    pg_cur.execute('SELECT "MaPhongHoc" FROM "PHONG_HOC" WHERE "DaXoa" = FALSE ORDER BY "MaPhongHoc" ASC;')
    valid_room_ids = [r[0] for r in pg_cur.fetchall()]
    print(f"  ✓ Total Rooms: {len(valid_room_ids)}")

    pg_cur.execute('SELECT "MaGiangVien" FROM "GIANG_VIEN" WHERE "DaXoa" = FALSE ORDER BY "MaGiangVien" ASC;')
    valid_teacher_ids = [r[0] for r in pg_cur.fetchall()]
    print(f"  ✓ Total Valid Teachers: {len(valid_teacher_ids)}")

    # -------------------------------------------------------------
    # 3. SYNC KHOA_HOC (COURSES)
    # -------------------------------------------------------------
    print("\n📚 [3/7] Syncing KHOA_HOC (Courses)...")
    new_courses = [
        ("COMM-A1", "Tiếng Anh Giao Tiếp Sơ Cấp A1", "Khóa học nền tảng giao tiếp căn bản cho người mới bắt đầu", "A1", 10, 3200000),
        ("COMM-B2", "Tiếng Anh Giao Tiếp Chuyên Nghiệp B2", "Giao tiếp công sở, thuyết trình và đàm phán thương mại", "B2", 12, 4500000),
        ("IELTS-80", "Luyện thi IELTS Chinh Phục 8.0+", "Chiến thuật chuyên sâu 4 kỹ năng band điểm xuất sắc 8.0+", "C1", 14, 8500000),
        ("TOEIC-850", "TOEIC Xuất Sắc 850+", "Luyện đề nâng cao và làm chủ bẫy đề thi TOEIC 2 kỹ năng", "B2", 10, 4200000),
        ("TOEFL-IBT", "Luyện thi TOEFL iBT Quốc Tế", "Chương trình chuẩn khảo thí ETS du học Mỹ và Canada", "B2", 12, 6800000),
        ("SAT-DIGITAL", "Luyện thi Digital SAT Chiến Thuật", "Toán học & Đọc hiểu thích ứng cho học sinh săn học bổng", "B2", 14, 9200000),
        ("PTE-ACAD", "Tiếng Anh PTE Academic Cấp Tốc", "Luyện thi chứng chỉ PTE du học và định cư Úc/New Zealand", "B1", 8, 5500000),
        ("KIDS-MOVERS", "Tiếng Anh Trẻ Em Movers", "Chương trình Cambridge YLE cấp độ Movers cho học sinh tiểu học", "A1", 12, 3600000),
        ("KIDS-FLYERS", "Tiếng Anh Trẻ Em Flyers", "Chương trình Cambridge YLE cấp độ Flyers chuẩn bị lên cấp 2", "A2", 12, 3800000),
        ("TEENS-B1", "Tiếng Anh Thiếu Niên Khởi Động B1", "Rèn luyện tư duy phản biện và ngữ pháp học thuật cho THCS", "B1", 12, 4200000),
        ("BUS-WRITING", "Viết Email & Soạn Thảo Hợp Đồng Thương Mại", "Kỹ năng thư tín thương mại quốc tế cho người đi làm", "B1", 8, 3500000),
        ("PRONUNCIATION", "Luyện Phát Âm Chuẩn Quốc Tế & Ngữ Điệu", "Phát âm chuẩn IPA, ngữ điệu bản xứ và nối âm tự nhiên", "A1", 6, 2500000),
        ("VSTEP-B1B2", "Luyện thi Chứng chỉ VSTEP B1-B2 Quốc Gia", "Ôn thi chuẩn đầu ra Đại học & Cao học theo Bộ GD&ĐT", "B1", 10, 3900000),
        ("GRAMMAR-PRO", "Ngữ Pháp Tiếng Anh Ứng Dụng Chuyên Sâu", "Hệ thống hóa toàn bộ cấu trúc câu và từ loại học thuật", "A2", 8, 2800000),
        ("PUBLIC-SPEAKING", "Kỹ Năng Thuyết Trình & Hùng Biện Tiếng Anh", "Tự tin nói trước đám đông và tranh biện tiếng Anh", "B2", 8, 3900000),
        ("ACAD-WRITING", "Kỹ Năng Viết Học Thuật & Luận Văn Đại Học", "Phương pháp trích dẫn APA, viết luận văn và báo cáo khoa học", "B2", 10, 5200000),
    ]
    for code, title, desc, lvl, dur, fee in new_courses:
        pg_cur.execute('SELECT "MaKhoaHoc" FROM "KHOA_HOC" WHERE "MaSoKhoaHoc" = %s;', (code,))
        if not pg_cur.fetchone():
            pg_cur.execute("""
                INSERT INTO "KHOA_HOC" ("MaSoKhoaHoc", "TenKhoaHoc", "MoTa", "TrinhDoMucTieu", "ThoiLuongTuan", "HocPhi", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa")
                VALUES (%s, %s, %s, %s, %s, %s, TRUE, %s, %s, FALSE);
            """, (code, title, desc, lvl, dur, fee, now_dt, now_dt))
            print(f"  + Added Course: [{code}] {title}")
    pg_conn.commit()

    pg_cur.execute('SELECT "MaSoKhoaHoc", "MaKhoaHoc" FROM "KHOA_HOC" WHERE "DaXoa" = FALSE;')
    course_map = dict(pg_cur.fetchall())
    print(f"  ✓ Total Courses: {len(course_map)} courses.")

    # -------------------------------------------------------------
    # 4. SYNC LOP_HOC (CLASSES)
    # -------------------------------------------------------------
    print("\n🏫 [4/7] Syncing LOP_HOC (Classes)...")
    sq_cur.execute("""
        SELECT lh.MaSoLop, kh.MaSoKhoaHoc, lh.SiSoToiDa, lh.SiSoHienTai, 
               lh.NgayMoLop, lh.NgayBatDau, lh.NgayKetThuc, lh.TrangThai, lh.MoKhoaDiemThuCong
        FROM LOP_HOC lh
        JOIN KHOA_HOC kh ON lh.MaKhoaHoc = kh.MaKhoaHoc
        WHERE lh.DaXoa = 0
        ORDER BY lh.MaLopHoc ASC;
    """)
    sq_classes = sq_cur.fetchall()
    classes_added = 0
    default_teacher = valid_teacher_ids[0]
    for cls in sq_classes:
        c_code, course_code, max_s, cur_s, open_d, start_d, end_d, status, manual_lock = cls
        target_course_id = course_map.get(course_code)
        if not target_course_id:
            continue
        
        pg_cur.execute('SELECT "MaLopHoc" FROM "LOP_HOC" WHERE "MaSoLop" = %s;', (c_code,))
        if not pg_cur.fetchone():
            pg_cur.execute("""
                INSERT INTO "LOP_HOC" ("MaSoLop", "MaKhoaHoc", "MaGiangVien", "SiSoToiDa", "SiSoHienTai", 
                                      "NgayMoLop", "NgayBatDau", "NgayKetThuc", "TrangThai", "MoKhoaDiemThuCong", 
                                      "NgayTao", "NgayCapNhat", "DaXoa")
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, FALSE);
            """, (c_code, target_course_id, default_teacher, max_s, cur_s, open_d, start_d, end_d, status, bool(manual_lock), now_dt, now_dt))
            classes_added += 1
    pg_conn.commit()

    pg_cur.execute('SELECT COUNT(*) FROM "LOP_HOC" WHERE "DaXoa" = FALSE;')
    class_cnt = pg_cur.fetchone()[0]
    print(f"  ✓ Added {classes_added} new classes. Total Classes: {class_cnt}")

    # -------------------------------------------------------------
    # 5. ALLOCATE CONFLICT-FREE SCHEDULES (BUOI_HOC)
    # -------------------------------------------------------------
    print("\n📅 [5/7] Allocating Conflict-Free Schedule Sessions (BUOI_HOC)...")
    # Standardize slots for early sessions <= 36
    pg_cur.execute("""
        UPDATE "BUOI_HOC" SET "GioBatDau" = '18:00', "GioKetThuc" = '19:30'
        WHERE "GioBatDau" = '18:00' AND "GioKetThuc" = '20:00';
    """)
    pg_cur.execute("""
        UPDATE "BUOI_HOC" SET "GioBatDau" = '07:30', "GioKetThuc" = '09:00'
        WHERE "GioBatDau" = '08:00' AND "GioKetThuc" = '10:00';
    """)
    pg_cur.execute("""
        UPDATE "BUOI_HOC" SET "GioBatDau" = '13:30', "GioKetThuc" = '15:00'
        WHERE "GioBatDau" = '14:00' AND "GioKetThuc" = '16:00';
    """)
    pg_conn.commit()

    pg_cur.execute('SELECT "NgayHoc", "GioBatDau", "GioKetThuc", "MaPhongHoc", "MaGiangVien" FROM "BUOI_HOC" WHERE "DaXoa" = FALSE;')
    existing_sessions = pg_cur.fetchall()
    occupied_rooms = {}
    occupied_teachers = {}
    for r in existing_sessions:
        d_val, s_t, e_t, r_id, t_id = r
        d_str = str(d_val)[:10]
        key = (d_str, s_t)
        if key not in occupied_rooms:
            occupied_rooms[key] = set()
            occupied_teachers[key] = set()
        occupied_rooms[key].add(r_id)
        occupied_teachers[key].add(t_id)

    patterns = [
        ([0, 2], "T2-T4"),
        ([1, 3], "T3-T5"),
        ([4, 5], "T6-T7"),
        ([6], "CN")
    ]
    slots = [
        ("07:30", "09:00", "Ca sáng 1"),
        ("09:15", "10:45", "Ca sáng 2"),
        ("13:30", "15:00", "Ca chiều 1"),
        ("15:15", "16:45", "Ca chiều 2"),
        ("18:00", "19:30", "Ca tối 1"),
        ("19:45", "21:15", "Ca tối 2")
    ]
    windows = []
    for p, p_name in patterns:
        for s, e, l in slots:
            windows.append((p, p_name, s, e, l))

    pg_cur.execute('SELECT "MaLopHoc", "MaSoLop", "NgayBatDau", "NgayKetThuc", "TrangThai" FROM "LOP_HOC" WHERE "DaXoa" = FALSE ORDER BY "MaLopHoc" ASC;')
    all_pg_classes = pg_cur.fetchall()

    new_sessions_batch = []
    for idx, (cid, ccode, start_val, end_val, cstatus) in enumerate(all_pg_classes):
        if not start_val or not end_val:
            continue
        start_d = datetime.strptime(str(start_val)[:10], "%Y-%m-%d").date()
        end_d = datetime.strptime(str(end_val)[:10], "%Y-%m-%d").date()
        if (end_d - start_d).days < 70:
            end_d = start_d + timedelta(days=75)
            pg_cur.execute('UPDATE "LOP_HOC" SET "NgayKetThuc" = %s WHERE "MaLopHoc" = %s;', (end_d.isoformat(), cid))

        w_idx = idx % len(windows)
        pos_in_window = idx // len(windows)

        base_room = valid_room_ids[pos_in_window % len(valid_room_ids)]
        assigned_teacher = valid_teacher_ids[(pos_in_window * 7 + w_idx) % len(valid_teacher_ids)]
        p_days, p_name, s_time, e_time, slot_name = windows[w_idx]

        pg_cur.execute('UPDATE "LOP_HOC" SET "MaGiangVien" = %s WHERE "MaLopHoc" = %s;', (assigned_teacher, cid))

        cur_d = start_d
        while cur_d <= end_d:
            if cur_d.weekday() in p_days:
                d_str = cur_d.isoformat()
                pg_cur.execute('SELECT "MaBuoiHoc" FROM "BUOI_HOC" WHERE "MaLopHoc" = %s AND "NgayHoc" = %s AND "DaXoa" = FALSE;', (cid, d_str))
                if not pg_cur.fetchone():
                    key = (d_str, s_time)
                    occ_r = occupied_rooms.get(key, set())
                    chosen_room = base_room
                    if chosen_room in occ_r:
                        for alt_r in valid_room_ids:
                            if alt_r not in occ_r:
                                chosen_room = alt_r
                                break
                    occ_t = occupied_teachers.get(key, set())
                    chosen_t = assigned_teacher
                    if chosen_t in occ_t:
                        for alt_t in valid_teacher_ids:
                            if alt_t not in occ_t:
                                chosen_t = alt_t
                                break
                    if key not in occupied_rooms:
                        occupied_rooms[key] = set()
                        occupied_teachers[key] = set()
                    occupied_rooms[key].add(chosen_room)
                    occupied_teachers[key].add(chosen_t)

                    sess_status = "COMPLETED" if cur_d < date(2026, 11, 20) else "SCHEDULED"
                    new_sessions_batch.append((
                        cid, chosen_room, chosen_t, d_str, s_time, e_time, slot_name, True, sess_status, now_dt, now_dt, False
                    ))
            cur_d += timedelta(days=1)

    if new_sessions_batch:
        insert_sess_sql = """
            INSERT INTO "BUOI_HOC" ("MaLopHoc", "MaPhongHoc", "MaGiangVien", "NgayHoc", "GioBatDau", "GioKetThuc", 
                                   "CaHoc", "DaXacNhan", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa")
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        execute_batch(pg_cur, insert_sess_sql, new_sessions_batch, page_size=500)
    pg_conn.commit()

    pg_cur.execute('SELECT COUNT(*) FROM "BUOI_HOC" WHERE "DaXoa" = FALSE;')
    sess_cnt = pg_cur.fetchone()[0]
    print(f"  ✓ Added {len(new_sessions_batch)} sessions. Total Sessions: {sess_cnt}")

    # -------------------------------------------------------------
    # 6. ENROLLMENTS, GRADES & TRANSFERS
    # -------------------------------------------------------------
    print("\n🎒 [6/7] Allocating Enrollments, Grades & Transfers...")
    pg_cur.execute('SELECT "MaHocVien" FROM "HOC_VIEN" WHERE "DaXoa" = FALSE ORDER BY "MaHocVien" ASC;')
    pg_students = [r[0] for r in pg_cur.fetchall()]
    total_pg_students = len(pg_students)

    pg_cur.execute('SELECT "MaLopHoc", "MaKhoaHoc", "TrangThai" FROM "LOP_HOC" WHERE "DaXoa" = FALSE ORDER BY "MaLopHoc" ASC;')
    pg_classes_all = pg_cur.fetchall()

    enrolls_added = 0
    grades_added = 0
    for cls_idx, (cid, course_id, cstatus) in enumerate(pg_classes_all):
        pg_cur.execute('SELECT COUNT(*) FROM "HOC_VIEN_LOP_HOC" WHERE "MaLopHoc" = %s AND "DaXoa" = FALSE;', (cid,))
        cur_cnt = pg_cur.fetchone()[0]
        if cur_cnt >= 4:
            continue
        
        need = 4 - cur_cnt
        st_slice = [pg_students[(cls_idx * 5 + i) % total_pg_students] for i in range(need)]
        for hid in st_slice:
            pg_cur.execute('SELECT "MaHV_LH" FROM "HOC_VIEN_LOP_HOC" WHERE "MaHocVien" = %s AND "MaLopHoc" = %s;', (hid, cid))
            if not pg_cur.fetchone():
                learn_status = "COMPLETED" if cstatus == "COMPLETED" else "ENROLLED"
                pg_cur.execute("""
                    INSERT INTO "HOC_VIEN_LOP_HOC" ("MaLopHoc", "MaHocVien", "NgayVaoLop", "TrangThaiHoc", "NgayTao", "NgayCapNhat", "DaXoa")
                    VALUES (%s, %s, %s, %s, %s, %s, FALSE);
                """, (cid, hid, now_dt, learn_status, now_dt, now_dt))
                enrolls_added += 1

                # Grade
                pg_cur.execute('SELECT "MaBangDiem" FROM "BANG_DIEM" WHERE "MaHocVien" = %s AND "MaLopHoc" = %s;', (hid, cid))
                if not pg_cur.fetchone():
                    if cstatus == "COMPLETED":
                        att_s = round(8.0 + (hid % 21) * 0.1, 1)
                        mid_s = round(7.0 + (hid % 26) * 0.1, 1)
                        fin_s = round(7.0 + (hid % 30) * 0.1, 1)
                        tot_s = round(att_s * 0.2 + mid_s * 0.3 + fin_s * 0.5, 2)
                        p_status = "PASSED" if tot_s >= 5.0 else "FAILED"
                        pg_cur.execute("""
                            INSERT INTO "BANG_DIEM" ("MaLopHoc", "MaHocVien", "DiemChuyenCan", "DiemGiuaKy", "DiemCuoiKy", "DiemTongKet", "KetQua", "DaKhoaSo", "GhiChu", "NgayTao", "NgayCapNhat", "DaXoa")
                            VALUES (%s, %s, %s, %s, %s, %s, %s, TRUE, 'Hoàn thành khóa học đạt chuẩn', %s, %s, FALSE);
                        """, (cid, hid, att_s, mid_s, fin_s, tot_s, p_status, now_dt, now_dt))
                        grades_added += 1
                    elif cstatus == "IN_PROGRESS":
                        att_s = round(8.5 + (hid % 15) * 0.1, 1)
                        mid_s = round(7.5 + (hid % 20) * 0.1, 1)
                        tot_s = round(att_s * 0.2 + mid_s * 0.3, 2)
                        pg_cur.execute("""
                            INSERT INTO "BANG_DIEM" ("MaLopHoc", "MaHocVien", "DiemChuyenCan", "DiemGiuaKy", "DiemCuoiKy", "DiemTongKet", "KetQua", "DaKhoaSo", "GhiChu", "NgayTao", "NgayCapNhat", "DaXoa")
                            VALUES (%s, %s, %s, %s, NULL, %s, 'IN_PROGRESS', FALSE, 'Đang theo học kỳ hiện tại', %s, %s, FALSE);
                        """, (cid, hid, att_s, mid_s, tot_s, now_dt, now_dt))
                        grades_added += 1

    # Transfers
    pg_cur.execute('SELECT COUNT(*) FROM "HOC_VIEN_LOP_HOC" WHERE "TrangThaiHoc" = \'TRANSFERRED\' AND "DaXoa" = FALSE;')
    existing_transfers = pg_cur.fetchone()[0]
    if existing_transfers < 100:
        pg_cur.execute("""
            SELECT hvlh."MaHV_LH", hvlh."MaHocVien", hvlh."MaLopHoc", lh."MaKhoaHoc"
            FROM "HOC_VIEN_LOP_HOC" hvlh
            JOIN "LOP_HOC" lh ON hvlh."MaLopHoc" = lh."MaLopHoc"
            WHERE hvlh."TrangThaiHoc" = 'ENROLLED' AND hvlh."DaXoa" = FALSE
            LIMIT 115;
        """)
        candidates = pg_cur.fetchall()
        for m_hvlh, m_hv, m_lh, m_kh in candidates:
            pg_cur.execute("""
                SELECT "MaLopHoc" FROM "LOP_HOC" 
                WHERE "MaKhoaHoc" = %s AND "MaLopHoc" != %s AND "DaXoa" = FALSE
                LIMIT 1;
            """, (m_kh, m_lh))
            target_cls = pg_cur.fetchone()
            if target_cls:
                target_id = target_cls[0]
                pg_cur.execute('UPDATE "HOC_VIEN_LOP_HOC" SET "TrangThaiHoc" = \'TRANSFERRED\' WHERE "MaHV_LH" = %s;', (m_hvlh,))
                pg_cur.execute('SELECT "MaHV_LH" FROM "HOC_VIEN_LOP_HOC" WHERE "MaHocVien" = %s AND "MaLopHoc" = %s;', (m_hv, target_id))
                if not pg_cur.fetchone():
                    pg_cur.execute("""
                        INSERT INTO "HOC_VIEN_LOP_HOC" ("MaLopHoc", "MaHocVien", "NgayVaoLop", "TrangThaiHoc", "NgayTao", "NgayCapNhat", "DaXoa")
                        VALUES (%s, %s, %s, 'ENROLLED', %s, %s, FALSE);
                    """, (target_id, m_hv, now_dt, now_dt, now_dt))

    # Update SiSoHienTai
    pg_cur.execute("""
        UPDATE "LOP_HOC"
        SET "SiSoHienTai" = (
            SELECT COUNT(*) FROM "HOC_VIEN_LOP_HOC"
            WHERE "HOC_VIEN_LOP_HOC"."MaLopHoc" = "LOP_HOC"."MaLopHoc"
            AND "HOC_VIEN_LOP_HOC"."TrangThaiHoc" != 'TRANSFERRED'
            AND "HOC_VIEN_LOP_HOC"."DaXoa" = FALSE
        );
    """)
    pg_conn.commit()

    pg_cur.execute('SELECT COUNT(*) FROM "HOC_VIEN_LOP_HOC" WHERE "DaXoa" = FALSE;')
    total_enroll = pg_cur.fetchone()[0]
    pg_cur.execute('SELECT COUNT(*) FROM "BANG_DIEM" WHERE "DaXoa" = FALSE;')
    total_grades = pg_cur.fetchone()[0]
    pg_cur.execute('SELECT COUNT(*) FROM "HOC_VIEN_LOP_HOC" WHERE "TrangThaiHoc" = \'TRANSFERRED\' AND "DaXoa" = FALSE;')
    total_trans = pg_cur.fetchone()[0]
    print(f"  ✓ Total Enrollments: {total_enroll}, Total Grades: {total_grades}, Total Transfers: {total_trans}")

    # -------------------------------------------------------------
    # 7. SYNC TICKETS (DON_THU 211-249 & DON_THU_PHAN_HOI)
    # -------------------------------------------------------------
    print("\n📩 [7/7] Preserving and Syncing Tickets 211-249...")
    sq_cur.execute("SELECT * FROM DON_THU WHERE MaDon >= 211 ORDER BY MaDon ASC;")
    extra_tickets = sq_cur.fetchall()
    sq_ticket_cols = [d[0] for d in sq_cur.description]

    tickets_synced = 0
    for t_row in extra_tickets:
        t_dict = dict(zip(sq_ticket_cols, t_row))
        t_id = t_dict["MaDon"]
        pg_cur.execute('SELECT "MaDon" FROM "DON_THU" WHERE "MaDon" = %s;', (t_id,))
        if not pg_cur.fetchone():
            pg_cur.execute("""
                INSERT INTO "DON_THU" ("MaDon", "MaSoDon", "LoaiDon", "MaNguoiGui", "MaNguoiNhan", "VaiTroNguoiNhan", 
                                      "LinhVuc", "MaLopHoc", "TieuDe", "NoiDung", "TrangThai", "HanChotKhieuNai", 
                                      "NgayTao", "NgayCapNhat", "DaXoa")
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """, (
                t_dict["MaDon"], t_dict["MaSoDon"], t_dict["LoaiDon"], t_dict["MaNguoiGui"], t_dict["MaNguoiNhan"],
                t_dict["VaiTroNguoiNhan"], t_dict["LinhVuc"], t_dict["MaLopHoc"], t_dict["TieuDe"], t_dict["NoiDung"],
                t_dict["TrangThai"], t_dict["HanChotKhieuNai"], t_dict["NgayTao"], t_dict["NgayCapNhat"], bool(t_dict["DaXoa"])
            ))
            tickets_synced += 1

    # Sync responses
    sq_cur.execute("SELECT * FROM DON_THU_PHAN_HOI WHERE MaDon >= 211 ORDER BY MaPhanHoi ASC;")
    extra_resps = sq_cur.fetchall()
    sq_resp_cols = [d[0] for d in sq_cur.description]
    resps_synced = 0
    for r_row in extra_resps:
        r_dict = dict(zip(sq_resp_cols, r_row))
        r_id = r_dict["MaPhanHoi"]
        pg_cur.execute('SELECT "MaPhanHoi" FROM "DON_THU_PHAN_HOI" WHERE "MaPhanHoi" = %s;', (r_id,))
        if not pg_cur.fetchone():
            pg_cur.execute("""
                INSERT INTO "DON_THU_PHAN_HOI" ("MaPhanHoi", "MaDon", "MaNguoiGui", "NoiDung", "NgayTao", "NgayCapNhat", "DaXoa")
                VALUES (%s, %s, %s, %s, %s, %s, %s);
            """, (
                r_dict["MaPhanHoi"], r_dict["MaDon"], r_dict["MaNguoiGui"], r_dict["NoiDung"],
                r_dict["NgayTao"], r_dict["NgayCapNhat"], bool(r_dict["DaXoa"])
            ))
            resps_synced += 1

    # Fix sequences for all tables in PG
    tables_to_fix_seq = [
        ("BANG_DIEM", "MaBangDiem"),
        ("BUOI_HOC", "MaBuoiHoc"),
        ("DON_THU", "MaDon"),
        ("DON_THU_PHAN_HOI", "MaPhanHoi"),
        ("GIANG_VIEN", "MaGiangVien"),
        ("HOC_VIEN", "MaHocVien"),
        ("HOC_VIEN_LOP_HOC", "MaHV_LH"),
        ("KHOA_HOC", "MaKhoaHoc"),
        ("LICHSU_KHOA_DIEM", "MaLichSu"),
        ("LOP_HOC", "MaLopHoc"),
        ("NGUOI_DUNG", "MaNguoiDung"),
        ("PHONG_HOC", "MaPhongHoc"),
        ("PHU_HUYNH_HOC_VIEN", "MaPH_HV"),
        ("TIEN_TRINH_KHOA_HOC", "MaTienTrinh"),
        ("YEU_CAU_DANG_KY", "MaYeuCau"),
    ]
    for tbl, pk in tables_to_fix_seq:
        try:
            pg_cur.execute(f"""
                SELECT setval(pg_get_serial_sequence('"{tbl}"', '{pk}'), COALESCE((SELECT MAX("{pk}") FROM "{tbl}"), 1));
            """)
        except Exception as e:
            pg_conn.rollback()
            print(f"  Sequence note for {tbl}.{pk}: {e}")

    pg_conn.commit()

    pg_cur.execute('SELECT COUNT(*) FROM "DON_THU";')
    final_tickets = pg_cur.fetchone()[0]
    pg_cur.execute('SELECT COUNT(*) FROM "DON_THU_PHAN_HOI";')
    final_resps = pg_cur.fetchone()[0]
    print(f"  ✓ Synced {tickets_synced} tickets (Total: {final_tickets}) and {resps_synced} responses (Total: {final_resps}).")

    pg_conn.close()
    sq_conn.close()
    print("\n🎉 POSTGRESQL SYNCHRONIZATION COMPLETED SUCCESSFULLY!")

if __name__ == "__main__":
    run_sync()
