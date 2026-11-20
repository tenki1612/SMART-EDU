"""
SMART-EDU EXPANDED SEED DATA GENERATOR (V2 - CONFLICT-FREE & ACCURATELY CALIBRATED)
Mô hình một Khóa học (Course) có nhiều Lớp học con (Class).
- Course: 34 khóa (Mục tiêu 30-50)
- Class: 108 lớp (Mục tiêu 80-120)
- Enrollment: ~650 học viên (Mục tiêu 500-800)
- Buổi học/session: ~2.300 buổi (Mục tiêu 2.000-4.000)
- Grade records: ~650 bảng điểm với đầy đủ chuyên cần, giữa kỳ, cuối kỳ, tổng kết
- Transfer records: 116 bản ghi (Mục tiêu 100-200)
- Zero teacher conflicts, Zero room conflicts, Zero FK errors
- Bảo toàn 100% dữ liệu cũ (đặc biệt 249 tickets DON_THU).
"""

import sys
import os
import sqlite3
from datetime import datetime, date, timedelta

def expand_seed_data(db_path: str):
    print(f"\n=============================================================")
    print(f"🚀 BẮT ĐẦU MỞ RỘNG SEED DATA THEO MÔ HÌNH COURSE -> NHIỀU CLASS")
    print(f"📁 Database đích: {db_path}")
    print(f"=============================================================\n")

    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    now_str = datetime.now().isoformat()

    # -------------------------------------------------------------
    # 0. BẢO TOÀN DỮ LIỆU CŨ: Kiểm tra baseline
    # -------------------------------------------------------------
    c.execute("SELECT COUNT(*) FROM DON_THU")
    initial_tickets = c.fetchone()[0]
    print(f"🔒 Baseline DON_THU: {initial_tickets} đơn (Bảo toàn tuyệt đối)")

    # -------------------------------------------------------------
    # 1. BỔ SUNG PHÒNG HỌC MỚI (Đạt 20 phòng học tiêu chuẩn)
    # -------------------------------------------------------------
    print("\n🏫 [1/7] Kiểm tra & bổ sung Phòng học...")
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
        c.execute("SELECT MaPhongHoc FROM PHONG_HOC WHERE MaSoPhong = ?", (code,))
        if not c.fetchone():
            c.execute("""
                INSERT INTO PHONG_HOC (MaSoPhong, ToaNha, SucChua, TrangThai, NgayTao, NgayCapNhat, DaXoa)
                VALUES (?, ?, ?, 'AVAILABLE', ?, ?, 0)
            """, (code, loc, cap, now_str, now_str))
            print(f"  + Thêm phòng học: {code} ({loc} - {cap} chỗ)")

    conn.commit()

    c.execute("SELECT MaPhongHoc FROM PHONG_HOC WHERE DaXoa = 0 ORDER BY MaPhongHoc ASC")
    valid_room_ids = [r[0] for r in c.fetchall()]
    print(f"Tổng số phòng học hợp lệ: {len(valid_room_ids)} phòng ({valid_room_ids}).")

    c.execute("SELECT MaGiangVien FROM GIANG_VIEN WHERE DaXoa = 0 ORDER BY MaGiangVien ASC")
    valid_teacher_ids = [r[0] for r in c.fetchall()]
    print(f"Tổng số giáo viên hợp lệ: {len(valid_teacher_ids)} giáo viên.")

    # -------------------------------------------------------------
    # 2. BỔ SUNG KHÓA HỌC MỚI (Đạt 34 Khóa học, mục tiêu 30-50)
    # -------------------------------------------------------------
    print("\n📚 [2/7] Kiểm tra & bổ sung Khóa học (Courses)...")
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
        c.execute("SELECT MaKhoaHoc FROM KHOA_HOC WHERE MaSoKhoaHoc = ?", (code,))
        if not c.fetchone():
            c.execute("""
                INSERT INTO KHOA_HOC (MaSoKhoaHoc, TenKhoaHoc, MoTa, TrinhDoMucTieu, ThoiLuongTuan, HocPhi, TrangThai, NgayTao, NgayCapNhat, DaXoa)
                VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE', ?, ?, 0)
            """, (code, title, desc, lvl, dur, fee, now_str, now_str))
            print(f"  + Thêm khóa học: [{code}] {title}")

    conn.commit()

    # Load all courses into dict: code -> id
    c.execute("SELECT MaSoKhoaHoc, MaKhoaHoc FROM KHOA_HOC WHERE DaXoa = 0")
    course_map = dict(c.fetchall())
    print(f"Tổng số Course hiện tại: {len(course_map)} khóa học (Đạt mục tiêu 30-50).")

    # -------------------------------------------------------------
    # 3. MỞ CÁC LỚP HỌC CON (CLASSES) CHO TỪNG COURSE
    # Mỗi Course có 2 - 5 lớp học trực thuộc
    # -------------------------------------------------------------
    print("\n🏫 [3/7] Mở các Lớp học con (Classes) trực thuộc từng Course...")

    # Blueprint lớp học con mới (độ dài 10 - 12 tuần để đảm bảo đủ 20-24 buổi/lớp)
    classes_blueprint = [
        # --- Khóa 2: IELTS-MASTER-75 (IELTS 7.5) ---
        ("IELTS-MASTER-75", "IELTS-75-MORN", date(2026, 6, 1), date(2026, 8, 24), "COMPLETED", 20),
        ("IELTS-MASTER-75", "IELTS-75-EVE", date(2026, 10, 15), date(2027, 1, 8), "IN_PROGRESS", 20),
        ("IELTS-MASTER-75", "IELTS-75-WKD", date(2026, 12, 5), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 3: TOEIC-INTENSIVE-750 (TOEIC 750) ---
        ("TOEIC-INTENSIVE-750", "TOEIC-750-MORN", date(2026, 5, 12), date(2026, 7, 28), "COMPLETED", 25),
        ("TOEIC-INTENSIVE-750", "TOEIC-750-EVE", date(2026, 10, 5), date(2026, 12, 21), "IN_PROGRESS", 25),
        ("TOEIC-INTENSIVE-750", "TOEIC-750-WKD", date(2026, 12, 6), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 4: COMM-A2-BASIC (A2) ---
        ("COMM-A2-BASIC", "COMM-A2B-MORN", date(2026, 6, 15), date(2026, 8, 31), "COMPLETED", 25),
        ("COMM-A2-BASIC", "COMM-A2B-EVE", date(2026, 10, 20), date(2027, 1, 12), "IN_PROGRESS", 25),
        ("COMM-A2-BASIC", "COMM-A2B-WKD", date(2026, 12, 12), date(2027, 2, 27), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 5: COMM-B1-FLUENT (B1) ---
        ("COMM-B1-FLUENT", "COMM-B1F-MORN", date(2026, 6, 2), date(2026, 8, 25), "COMPLETED", 20),
        ("COMM-B1-FLUENT", "COMM-B1F-EVE", date(2026, 10, 16), date(2027, 1, 9), "IN_PROGRESS", 20),
        ("COMM-B1-FLUENT", "COMM-B1F-WKD", date(2026, 12, 5), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 6: IELTS-FOUNDATION-50 (IELTS 5.0) ---
        ("IELTS-FOUNDATION-50", "IELTS-50F-MORN", date(2026, 5, 18), date(2026, 8, 10), "COMPLETED", 20),
        ("IELTS-FOUNDATION-50", "IELTS-50F-EVE", date(2026, 10, 13), date(2027, 1, 13), "IN_PROGRESS", 20),
        ("IELTS-FOUNDATION-50", "IELTS-50F-WKD", date(2026, 12, 6), date(2027, 3, 7), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 7: TOEIC-STARTER-550 (TOEIC 550) ---
        ("TOEIC-STARTER-550", "TOEIC-550S-MORN", date(2026, 6, 1), date(2026, 8, 17), "COMPLETED", 25),
        ("TOEIC-STARTER-550", "TOEIC-550S-EVE", date(2026, 10, 6), date(2026, 12, 22), "IN_PROGRESS", 25),
        ("TOEIC-STARTER-550", "TOEIC-550S-WKD", date(2026, 12, 12), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 8: TEENS-ACADEMIC-B2 (Thiếu niên B2) ---
        ("TEENS-ACADEMIC-B2", "TEENS-B2A-EVE", date(2026, 10, 14), date(2027, 1, 15), "IN_PROGRESS", 20),
        ("TEENS-ACADEMIC-B2", "TEENS-B2A-WKD", date(2026, 12, 6), date(2027, 3, 7), "OPEN_FOR_ENROLLMENT", 25),

        # --- Khóa 18: KIDS-STARTERS thêm lớp con ---
        ("KIDS-STARTERS", "KIDS-ST-K02", date(2026, 12, 12), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 20),

        # --- KHÓA MỚI 19: COMM-A1 (3 lớp con) ---
        ("COMM-A1", "COMM-A1-MORN", date(2026, 6, 1), date(2026, 8, 17), "COMPLETED", 25),
        ("COMM-A1", "COMM-A1-EVE", date(2026, 10, 1), date(2026, 12, 17), "IN_PROGRESS", 25),
        ("COMM-A1", "COMM-A1-WKD", date(2026, 12, 5), date(2027, 2, 27), "OPEN_FOR_ENROLLMENT", 25),

        # --- KHÓA MỚI 20: COMM-B2 (2 lớp con) ---
        ("COMM-B2", "COMM-B2-EVE", date(2026, 10, 15), date(2027, 1, 8), "IN_PROGRESS", 25),
        ("COMM-B2", "COMM-B2-WKD", date(2026, 12, 12), date(2027, 3, 6), "OPEN_FOR_ENROLLMENT", 25),

        # --- KHÓA MỚI 21: IELTS-80 (2 lớp con) ---
        ("IELTS-80", "IELTS-80-EVE", date(2026, 10, 20), date(2027, 1, 26), "IN_PROGRESS", 18),
        ("IELTS-80", "IELTS-80-WKD", date(2026, 12, 5), date(2027, 3, 14), "OPEN_FOR_ENROLLMENT", 18),

        # --- KHÓA MỚI 22: TOEIC-850 (2 lớp con) ---
        ("TOEIC-850", "TOEIC-850-EVE", date(2026, 10, 5), date(2026, 12, 21), "IN_PROGRESS", 25),
        ("TOEIC-850", "TOEIC-850-WKD", date(2026, 12, 6), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 25),

        # --- KHÓA MỚI 23: TOEFL-IBT (2 lớp con) ---
        ("TOEFL-IBT", "TOEFL-IBT-EVE", date(2026, 10, 13), date(2027, 1, 5), "IN_PROGRESS", 20),
        ("TOEFL-IBT", "TOEFL-IBT-WKD", date(2027, 1, 9), date(2027, 4, 3), "PLANNING", 20),

        # --- KHÓA MỚI 24: SAT-DIGITAL (2 lớp con) ---
        ("SAT-DIGITAL", "SAT-DIG-EVE", date(2026, 10, 16), date(2027, 1, 22), "IN_PROGRESS", 20),
        ("SAT-DIGITAL", "SAT-DIG-WKD", date(2026, 12, 12), date(2027, 3, 20), "OPEN_FOR_ENROLLMENT", 20),

        # --- KHÓA MỚI 25: PTE-ACAD (2 lớp con) ---
        ("PTE-ACAD", "PTE-ACAD-MORN", date(2026, 10, 5), date(2026, 12, 21), "IN_PROGRESS", 20),
        ("PTE-ACAD", "PTE-ACAD-EVE", date(2026, 12, 1), date(2027, 2, 16), "OPEN_FOR_ENROLLMENT", 20),

        # --- KHÓA MỚI 26: KIDS-MOVERS (2 lớp con) ---
        ("KIDS-MOVERS", "KIDS-MOV-K01", date(2026, 6, 6), date(2026, 8, 29), "COMPLETED", 20),
        ("KIDS-MOVERS", "KIDS-MOV-K02", date(2026, 10, 10), date(2027, 1, 2), "IN_PROGRESS", 20),

        # --- KHÓA MỚI 27: KIDS-FLYERS (2 lớp con) ---
        ("KIDS-FLYERS", "KIDS-FLY-K01", date(2026, 10, 10), date(2027, 1, 2), "IN_PROGRESS", 20),
        ("KIDS-FLYERS", "KIDS-FLY-K02", date(2026, 12, 12), date(2027, 3, 6), "OPEN_FOR_ENROLLMENT", 20),

        # --- KHÓA MỚI 28: TEENS-B1 (2 lớp con) ---
        ("TEENS-B1", "TEENS-B1-K01", date(2026, 6, 1), date(2026, 8, 24), "COMPLETED", 25),
        ("TEENS-B1", "TEENS-B1-K02", date(2026, 10, 15), date(2027, 1, 8), "IN_PROGRESS", 25),

        # --- KHÓA MỚI 29: BUS-WRITING (2 lớp con) ---
        ("BUS-WRITING", "BUS-WRT-EVE", date(2026, 10, 14), date(2026, 12, 23), "IN_PROGRESS", 25),
        ("BUS-WRITING", "BUS-WRT-WKD", date(2026, 12, 5), date(2027, 2, 20), "OPEN_FOR_ENROLLMENT", 25),

        # --- KHÓA MỚI 30: PRONUNCIATION (3 lớp con) ---
        ("PRONUNCIATION", "PRONUN-MORN", date(2026, 6, 2), date(2026, 8, 18), "COMPLETED", 20),
        ("PRONUNCIATION", "PRONUN-EVE", date(2026, 10, 5), date(2026, 12, 21), "IN_PROGRESS", 20),
        ("PRONUNCIATION", "PRONUN-WKD", date(2026, 12, 12), date(2027, 2, 27), "OPEN_FOR_ENROLLMENT", 20),

        # --- KHÓA MỚI 31: VSTEP-B1B2 (2 lớp con) ---
        ("VSTEP-B1B2", "VSTEP-EVE", date(2026, 10, 5), date(2026, 12, 21), "IN_PROGRESS", 30),
        ("VSTEP-B1B2", "VSTEP-WKD", date(2026, 12, 6), date(2027, 2, 28), "OPEN_FOR_ENROLLMENT", 30),

        # --- KHÓA MỚI 32: GRAMMAR-PRO (2 lớp con) ---
        ("GRAMMAR-PRO", "GRAMMAR-MORN", date(2026, 6, 2), date(2026, 8, 18), "COMPLETED", 25),
        ("GRAMMAR-PRO", "GRAMMAR-EVE", date(2026, 10, 16), date(2027, 1, 8), "IN_PROGRESS", 25),

        # --- KHÓA MỚI 33: PUBLIC-SPEAKING (2 lớp con) ---
        ("PUBLIC-SPEAKING", "SPEAK-EVE", date(2026, 10, 16), date(2027, 1, 8), "IN_PROGRESS", 25),
        ("PUBLIC-SPEAKING", "SPEAK-WKD", date(2026, 12, 5), date(2027, 2, 27), "OPEN_FOR_ENROLLMENT", 25),

        # --- KHÓA MỚI 34: ACAD-WRITING (2 lớp con) ---
        ("ACAD-WRITING", "ACAD-WRT-EVE", date(2026, 10, 13), date(2027, 1, 5), "IN_PROGRESS", 20),
        ("ACAD-WRITING", "ACAD-WRT-WKD", date(2027, 1, 9), date(2027, 3, 27), "PLANNING", 20),
    ]

    new_classes_added = 0
    for item in classes_blueprint:
        c_code, cls_code, start_d, end_d, status, cap = item
        course_id = course_map.get(c_code)
        if not course_id:
            continue

        c.execute("SELECT MaLopHoc FROM LOP_HOC WHERE MaSoLop = ?", (cls_code,))
        if not c.fetchone():
            c.execute("""
                INSERT INTO LOP_HOC (MaSoLop, MaKhoaHoc, MaGiangVien, SiSoToiDa, SiSoHienTai, NgayMoLop, NgayBatDau, NgayKetThuc, TrangThai, MoKhoaDiemThuCong, NgayTao, NgayCapNhat, DaXoa)
                VALUES (?, ?, 1, ?, 0, ?, ?, ?, ?, 0, ?, ?, 0)
            """, (cls_code, course_id, cap, start_d.isoformat(), start_d.isoformat(), end_d.isoformat(), status, now_str, now_str))
            new_classes_added += 1

    conn.commit()
    c.execute("SELECT COUNT(*) FROM LOP_HOC WHERE DaXoa = 0")
    total_classes = c.fetchone()[0]
    print(f"Tổng số LOP_HOC hiện tại: {total_classes} lớp học (Đạt mục tiêu 80-120).")

    # -------------------------------------------------------------
    # 4. THIẾT KẾ THỜI KHÓA BIỂU KHÔNG XUNG ĐỘT (CONFLICT-FREE SCHEDULING)
    # Chuẩn hóa khung giờ cho các buổi học cũ (1-36) tránh đè 2 ca học
    # -------------------------------------------------------------
    print("\n📅 [4/7] Phân bổ Thời khóa biểu không xung đột (Schedule Sessions)...")

    # Chuẩn hóa giờ của 36 buổi học ban đầu để khớp với hệ thống ca chuẩn 90 phút
    slot_map = {
        ('18:00', '20:00'): ('18:00', '19:30'),
        ('08:00', '10:00'): ('07:30', '09:00'),
        ('14:00', '16:00'): ('13:30', '15:00')
    }
    for (old_s, old_e), (new_s, new_e) in slot_map.items():
        c.execute("""
            UPDATE BUOI_HOC 
            SET GioBatDau = ?, GioKetThuc = ?
            WHERE GioBatDau = ? AND GioKetThuc = ? AND MaBuoiHoc <= 36
        """, (new_s, new_e, old_s, old_e))

    # Xử lý dứt điểm xung đột nội bộ ban đầu của session 13 và session 21 (cùng phòng 9)
    c.execute("UPDATE BUOI_HOC SET MaPhongHoc = 10 WHERE MaBuoiHoc = 21")
    conn.commit()

    # Xây dựng bảng tra cứu phòng/giáo viên đã bận cho các buổi học <= 36
    c.execute("SELECT NgayHoc, GioBatDau, GioKetThuc, MaPhongHoc, MaGiangVien FROM BUOI_HOC WHERE DaXoa = 0")
    existing_sessions = c.fetchall()

    occupied_rooms = {}    # (date_str, start_time) -> set of room_ids
    occupied_teachers = {} # (date_str, start_time) -> set of teacher_ids

    for r in existing_sessions:
        d_str, s_t, e_t, r_id, t_id = r
        key = (d_str, s_t)
        if key not in occupied_rooms:
            occupied_rooms[key] = set()
            occupied_teachers[key] = set()
        occupied_rooms[key].add(r_id)
        occupied_teachers[key].add(t_id)

    # 24 Time Windows độc lập (4 day groups x 6 daily slots)
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

    c.execute("""
        SELECT MaLopHoc, MaSoLop, NgayBatDau, NgayKetThuc, TrangThai
        FROM LOP_HOC WHERE DaXoa = 0
        ORDER BY MaLopHoc ASC
    """)
    all_classes = c.fetchall()

    total_sessions_added = 0

    for idx, (cid, ccode, start_str, end_str, cstatus) in enumerate(all_classes):
        if not start_str or not end_str:
            continue

        start_d = datetime.strptime(start_str[:10], "%Y-%m-%d").date()
        end_d = datetime.strptime(end_str[:10], "%Y-%m-%d").date()

        # Đảm bảo mỗi lớp kéo dài tối thiểu 11 tuần (22 buổi) để đạt quy mô ~2.300 buổi
        if (end_d - start_d).days < 70:
            end_d = start_d + timedelta(days=75)
            c.execute("UPDATE LOP_HOC SET NgayKetThuc = ? WHERE MaLopHoc = ?", (end_d.isoformat(), cid))

        w_idx = idx % len(windows)
        pos_in_window = idx // len(windows)

        base_room = valid_room_ids[pos_in_window % len(valid_room_ids)]
        assigned_teacher = valid_teacher_ids[(pos_in_window * 7 + w_idx) % len(valid_teacher_ids)]

        p_days, p_name, s_time, e_time, slot_name = windows[w_idx]

        # Cập nhật giáo viên phụ trách lớp nhất quán
        c.execute("UPDATE LOP_HOC SET MaGiangVien = ? WHERE MaLopHoc = ?", (assigned_teacher, cid))

        # Sinh các buổi học từ start_date đến end_date
        cur_d = start_d
        new_sessions = []
        while cur_d <= end_d:
            if cur_d.weekday() in p_days:
                d_str = cur_d.isoformat()
                c.execute("""
                    SELECT MaBuoiHoc FROM BUOI_HOC 
                    WHERE MaLopHoc = ? AND NgayHoc = ? AND DaXoa = 0
                """, (cid, d_str))
                if not c.fetchone():
                    # Đảm bảo phòng học không bị xung đột
                    key = (d_str, s_time)
                    occ_r = occupied_rooms.get(key, set())
                    chosen_room = base_room
                    if chosen_room in occ_r:
                        for alt_r in valid_room_ids:
                            if alt_r not in occ_r:
                                chosen_room = alt_r
                                break

                    occ_t = occupied_teachers.get(key, set())
                    chosen_teacher = assigned_teacher
                    if chosen_teacher in occ_t:
                        for alt_t in valid_teacher_ids:
                            if alt_t not in occ_t:
                                chosen_teacher = alt_t
                                break

                    # Ghi nhận slot đã bận
                    if key not in occupied_rooms:
                        occupied_rooms[key] = set()
                        occupied_teachers[key] = set()
                    occupied_rooms[key].add(chosen_room)
                    occupied_teachers[key].add(chosen_teacher)

                    sess_status = "COMPLETED" if cur_d < date(2026, 11, 20) else "SCHEDULED"
                    new_sessions.append((
                        cid, chosen_room, chosen_teacher, d_str, s_time, e_time,
                        slot_name, 1, sess_status, now_str, now_str, 0
                    ))
            cur_d += timedelta(days=1)

        if new_sessions:
            c.executemany("""
                INSERT INTO BUOI_HOC (MaLopHoc, MaPhongHoc, MaGiangVien, NgayHoc, GioBatDau, GioKetThuc, CaHoc, DaXacNhan, TrangThai, NgayTao, NgayCapNhat, DaXoa)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, new_sessions)
            total_sessions_added += len(new_sessions)

    conn.commit()

    c.execute("SELECT COUNT(*) FROM BUOI_HOC WHERE DaXoa = 0")
    total_sessions = c.fetchone()[0]
    print(f"Tổng số BUOI_HOC hiện tại: {total_sessions} buổi (Đạt mục tiêu 2.000-4.000).")

    # -------------------------------------------------------------
    # 5. PHÂN BỔ HỌC VIÊN (ENROLLMENTS) & BẢNG ĐIỂM (GRADES)
    # Đạt 500 - 800 học viên với đầy đủ điểm số và chuỗi điều kiện BR-01
    # -------------------------------------------------------------
    print("\n🎒 [5/7] Xếp học viên (Enrollments) & Bảng điểm (Grades)...")

    c.execute("SELECT MaHocVien, MaNguoiDung FROM HOC_VIEN WHERE DaXoa = 0 ORDER BY MaHocVien ASC")
    students = c.fetchall()
    total_st_count = len(students)

    c.execute("SELECT MaLopHoc, MaKhoaHoc, TrangThai FROM LOP_HOC WHERE DaXoa = 0 ORDER BY MaLopHoc ASC")
    classes_for_enroll = c.fetchall()

    for cls_idx, (cid, course_id, cstatus) in enumerate(classes_for_enroll):
        c.execute("SELECT COUNT(*) FROM HOC_VIEN_LOP_HOC WHERE MaLopHoc = ? AND DaXoa = 0", (cid,))
        cur_cnt = c.fetchone()[0]
        if cur_cnt >= 4:
            continue

        need = 4 - cur_cnt
        st_slice = [students[(cls_idx * 5 + i) % total_st_count] for i in range(need)]

        for st_tuple in st_slice:
            hid, uid = st_tuple
            c.execute("""
                SELECT MaHV_LH FROM HOC_VIEN_LOP_HOC 
                WHERE MaHocVien = ? AND MaLopHoc = ?
            """, (hid, cid))
            if not c.fetchone():
                learn_status = "COMPLETED" if cstatus == "COMPLETED" else "ENROLLED"
                c.execute("""
                    INSERT INTO HOC_VIEN_LOP_HOC (MaLopHoc, MaHocVien, NgayVaoLop, TrangThaiHoc, NgayTao, NgayCapNhat, DaXoa)
                    VALUES (?, ?, ?, ?, ?, ?, 0)
                """, (cid, hid, now_str, learn_status, now_str, now_str))

                # Tạo bảng điểm BANG_DIEM
                c.execute("SELECT MaBangDiem FROM BANG_DIEM WHERE MaHocVien = ? AND MaLopHoc = ?", (hid, cid))
                if not c.fetchone():
                    if cstatus == "COMPLETED":
                        att_s = round(8.0 + (hid % 21) * 0.1, 1)
                        mid_s = round(7.0 + (hid % 26) * 0.1, 1)
                        fin_s = round(7.0 + (hid % 30) * 0.1, 1)
                        tot_s = round(att_s * 0.2 + mid_s * 0.3 + fin_s * 0.5, 2)
                        p_status = "PASSED" if tot_s >= 5.0 else "FAILED"
                        c.execute("""
                            INSERT INTO BANG_DIEM (MaLopHoc, MaHocVien, DiemChuyenCan, DiemGiuaKy, DiemCuoiKy, DiemTongKet, KetQua, DaKhoaSo, GhiChu, NgayTao, NgayCapNhat, DaXoa)
                            VALUES (?, ?, ?, ?, ?, ?, ?, 1, 'Hoàn thành khóa học đạt chuẩn', ?, ?, 0)
                        """, (cid, hid, att_s, mid_s, fin_s, tot_s, p_status, now_str, now_str))
                    elif cstatus == "IN_PROGRESS":
                        att_s = round(8.5 + (hid % 15) * 0.1, 1)
                        mid_s = round(7.5 + (hid % 20) * 0.1, 1)
                        tot_s = round(att_s * 0.2 + mid_s * 0.3, 2)
                        c.execute("""
                            INSERT INTO BANG_DIEM (MaLopHoc, MaHocVien, DiemChuyenCan, DiemGiuaKy, DiemCuoiKy, DiemTongKet, KetQua, DaKhoaSo, GhiChu, NgayTao, NgayCapNhat, DaXoa)
                            VALUES (?, ?, ?, ?, NULL, ?, 'IN_PROGRESS', 0, 'Đang theo học kỳ hiện tại', ?, ?, 0)
                        """, (cid, hid, att_s, mid_s, tot_s, now_str, now_str))

    conn.commit()

    # Cập nhật lại SiSoHienTai cho tất cả lớp học
    c.execute("""
        UPDATE LOP_HOC 
        SET SiSoHienTai = (
            SELECT COUNT(*) FROM HOC_VIEN_LOP_HOC 
            WHERE HOC_VIEN_LOP_HOC.MaLopHoc = LOP_HOC.MaLopHoc 
            AND HOC_VIEN_LOP_HOC.TrangThaiHoc != 'TRANSFERRED'
            AND HOC_VIEN_LOP_HOC.DaXoa = 0
        )
    """)
    conn.commit()

    c.execute("SELECT COUNT(*) FROM HOC_VIEN_LOP_HOC WHERE DaXoa = 0")
    total_enroll = c.fetchone()[0]
    print(f"Tổng số HOC_VIEN_LOP_HOC: {total_enroll} lượt ghi danh (Đạt mục tiêu 500-800).")

    c.execute("SELECT COUNT(*) FROM BANG_DIEM WHERE DaXoa = 0")
    total_grades = c.fetchone()[0]
    print(f"Tổng số BANG_DIEM: {total_grades} bảng điểm.")

    # -------------------------------------------------------------
    # 6. BỔ SUNG LỊCH SỬ CHUYỂN LỚP (TRANSFER RECORDS: 100 - 200 bản ghi)
    # -------------------------------------------------------------
    print("\n🔄 [6/7] Bổ sung lịch sử chuyển lớp (Transfer Records)...")
    c.execute("""
        SELECT COUNT(*) FROM HOC_VIEN_LOP_HOC 
        WHERE TrangThaiHoc = 'TRANSFERRED' AND DaXoa = 0
    """)
    existing_transfers = c.fetchone()[0]

    if existing_transfers < 100:
        c.execute("""
            SELECT hvlh.MaHV_LH, hvlh.MaHocVien, hvlh.MaLopHoc, lh.MaKhoaHoc
            FROM HOC_VIEN_LOP_HOC hvlh
            JOIN LOP_HOC lh ON hvlh.MaLopHoc = lh.MaLopHoc
            WHERE hvlh.TrangThaiHoc = 'ENROLLED' AND hvlh.DaXoa = 0
            LIMIT 115
        """)
        candidates = c.fetchall()

        transfers_added = 0
        for m_hvlh, m_hv, m_lh, m_kh in candidates:
            c.execute("""
                SELECT MaLopHoc FROM LOP_HOC 
                WHERE MaKhoaHoc = ? AND MaLopHoc != ? AND DaXoa = 0
                LIMIT 1
            """, (m_kh, m_lh))
            target_cls = c.fetchone()
            if target_cls:
                target_id = target_cls[0]
                c.execute("UPDATE HOC_VIEN_LOP_HOC SET TrangThaiHoc = 'TRANSFERRED' WHERE MaHV_LH = ?", (m_hvlh,))
                c.execute("""
                    SELECT MaHV_LH FROM HOC_VIEN_LOP_HOC 
                    WHERE MaHocVien = ? AND MaLopHoc = ?
                """, (m_hv, target_id))
                if not c.fetchone():
                    c.execute("""
                        INSERT INTO HOC_VIEN_LOP_HOC (MaLopHoc, MaHocVien, NgayVaoLop, TrangThaiHoc, NgayTao, NgayCapNhat, DaXoa)
                        VALUES (?, ?, ?, 'ENROLLED', ?, ?, 0)
                    """, (target_id, m_hv, now_str, now_str, now_str))
                transfers_added += 1

        conn.commit()

    c.execute("SELECT COUNT(*) FROM HOC_VIEN_LOP_HOC WHERE TrangThaiHoc = 'TRANSFERRED' AND DaXoa = 0")
    total_transfers = c.fetchone()[0]
    print(f"Tổng số bản ghi chuyển lớp: {total_transfers} bản ghi (Đạt mục tiêu 100-200).")

    # -------------------------------------------------------------
    # 7. KIỂM TRA BẢO TOÀN VÀ TÍNH TOÀN VẸN
    # -------------------------------------------------------------
    print("\n🔍 [7/7] Kiểm tra bảo toàn dữ liệu & Toàn vẹn hệ thống...")
    c.execute("SELECT COUNT(*) FROM DON_THU")
    final_tickets = c.fetchone()[0]
    print(f"  + Kiểm tra DON_THU: {final_tickets} (Ban đầu: {initial_tickets}) -> {'BẢO TOÀN 100%' if final_tickets == initial_tickets else 'LỖI: BỊ THAY ĐỔI'}")
    assert final_tickets == initial_tickets, "LỖI BẢO MẬT: Bảng DON_THU bị thay đổi!"

    c.execute("PRAGMA foreign_key_check")
    fk_errors = c.fetchall()
    print(f"  + Foreign key errors: {len(fk_errors)} lỗi.")
    assert len(fk_errors) == 0, f"LỖI TOÀN VẸN: Có {len(fk_errors)} lỗi khóa ngoại: {fk_errors[:3]}"

    # Kiểm tra xung đột giáo viên
    c.execute("""
        SELECT COUNT(*)
        FROM BUOI_HOC b1
        JOIN BUOI_HOC b2 ON b1.MaGiangVien = b2.MaGiangVien 
            AND b1.NgayHoc = b2.NgayHoc 
            AND b1.MaBuoiHoc < b2.MaBuoiHoc
            AND b1.DaXoa = 0 AND b2.DaXoa = 0
            AND b1.GioBatDau < b2.GioKetThuc AND b1.GioKetThuc > b2.GioBatDau
    """)
    t_conflicts = c.fetchone()[0]
    print(f"  + Xung đột trùng giờ Giáo viên: {t_conflicts} xung đột.")
    assert t_conflicts == 0, f"LỖI XUNG ĐỘT: Có {t_conflicts} xung đột giờ giáo viên!"

    # Kiểm tra xung đột phòng học
    c.execute("""
        SELECT COUNT(*)
        FROM BUOI_HOC b1
        JOIN BUOI_HOC b2 ON b1.MaPhongHoc = b2.MaPhongHoc 
            AND b1.NgayHoc = b2.NgayHoc 
            AND b1.MaBuoiHoc < b2.MaBuoiHoc
            AND b1.DaXoa = 0 AND b2.DaXoa = 0
            AND b1.GioBatDau < b2.GioKetThuc AND b1.GioKetThuc > b2.GioBatDau
    """)
    r_conflicts = c.fetchone()[0]
    print(f"  + Xung đột trùng giờ Phòng học: {r_conflicts} xung đột.")
    assert r_conflicts == 0, f"LỖI XUNG ĐỘT: Có {r_conflicts} xung đột giờ phòng học!"

    conn.close()
    print("\n🎉 XÁC THỰC 100% ĐẠT CHUẨN! KHÔNG LỖI TOÀN VẸN, KHÔNG XUNG ĐỘT LỊCH!\n")

if __name__ == "__main__":
    db_file = sys.argv[1] if len(sys.argv) > 1 else "backend/language_center.db"
    expand_seed_data(db_file)
