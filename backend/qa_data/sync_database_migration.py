import os
import shutil
import sqlite3
from datetime import datetime

DB_PATH = os.path.abspath("backend/language_center.db")
BACKUP_PATH = os.path.abspath("backend/qa_data/language_center_backup_pre_sync.db")

TABLES = [
    "NGUOI_DUNG",
    "GIANG_VIEN",
    "HOC_VIEN",
    "PHU_HUYNH_HOC_VIEN",
    "KHOA_HOC",
    "PHONG_HOC",
    "LOP_HOC",
    "HOC_VIEN_LOP_HOC",
    "YEU_CAU_DANG_KY",
    "BUOI_HOC",
    "BANG_DIEM",
    "TIEN_TRINH_KHOA_HOC",
    "DON_THU",
    "DON_THU_PHAN_HOI",
    "LICHSU_KHOA_DIEM",
]

def run_sync_migration():
    print("=============================================================")
    print("🚀 GIAI ĐOẠN 4: SAO LƯU VÀ THỰC HIỆN ĐỒNG BỘ CHUẨN HÓA DATABASE")
    print(f"📁 Target Database: {DB_PATH}")
    print(f"💾 Backup Target:   {BACKUP_PATH}")
    print("=============================================================\n")

    # 1. Tạo bản sao lưu an toàn
    print("📦 [1/5] Tạo bản sao lưu toàn vẹn...")
    shutil.copy2(DB_PATH, BACKUP_PATH)
    
    # Kiểm tra đọc bản sao lưu
    bk_conn = sqlite3.connect(BACKUP_PATH)
    bk_c = bk_conn.cursor()
    bk_c.execute("SELECT COUNT(*) FROM DON_THU")
    bk_tickets = bk_c.fetchone()[0]
    bk_conn.close()
    print(f"   ✓ Đã tạo và xác thực bản sao lưu: DON_THU = {bk_tickets} đơn.")

    # 2. Ghi nhận số lượng bản ghi trước migration
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("PRAGMA foreign_keys = ON")
    
    counts_before = {}
    for t in TABLES:
        c.execute(f"SELECT COUNT(*) FROM '{t}'")
        counts_before[t] = c.fetchone()[0]
    print("\n📊 [2/5] Số lượng bản ghi trước đồng bộ:")
    for t, cnt in counts_before.items():
        print(f"   - {t}: {cnt}")

    # 3. Thực hiện Additive Migration (Chỉ thêm indexes tối ưu hiệu năng FK, không sửa/xóa dữ liệu)
    print("\n⚡ [3/5] Thực hiện bổ sung chỉ mục FK (Additive Migration - 100% SAFE)...")
    additive_indexes = [
        # LOP_HOC
        ("ix_LOP_HOC_MaKhoaHoc", "LOP_HOC", "MaKhoaHoc"),
        ("ix_LOP_HOC_MaGiangVien", "LOP_HOC", "MaGiangVien"),
        
        # HOC_VIEN_LOP_HOC
        ("ix_HOC_VIEN_LOP_HOC_MaLopHoc", "HOC_VIEN_LOP_HOC", "MaLopHoc"),
        ("ix_HOC_VIEN_LOP_HOC_MaHocVien", "HOC_VIEN_LOP_HOC", "MaHocVien"),
        ("ix_HOC_VIEN_LOP_HOC_TrangThaiHoc", "HOC_VIEN_LOP_HOC", "TrangThaiHoc"),
        
        # BUOI_HOC
        ("ix_BUOI_HOC_MaLopHoc", "BUOI_HOC", "MaLopHoc"),
        ("ix_BUOI_HOC_MaPhongHoc", "BUOI_HOC", "MaPhongHoc"),
        ("ix_BUOI_HOC_MaGiangVien", "BUOI_HOC", "MaGiangVien"),
        ("ix_BUOI_HOC_NgayHoc", "BUOI_HOC", "NgayHoc"),
        
        # BANG_DIEM
        ("ix_BANG_DIEM_MaLopHoc", "BANG_DIEM", "MaLopHoc"),
        ("ix_BANG_DIEM_MaHocVien", "BANG_DIEM", "MaHocVien"),
        
        # YEU_CAU_DANG_KY
        ("ix_YEU_CAU_DANG_KY_MaLopHoc", "YEU_CAU_DANG_KY", "MaLopHoc"),
        ("ix_YEU_CAU_DANG_KY_MaHocVien", "YEU_CAU_DANG_KY", "MaHocVien"),
        ("ix_YEU_CAU_DANG_KY_TrangThai", "YEU_CAU_DANG_KY", "TrangThai"),
        
        # TIEN_TRINH_KHOA_HOC
        ("ix_TIEN_TRINH_KHOA_HOC_MaHocVien", "TIEN_TRINH_KHOA_HOC", "MaHocVien"),
        
        # PHU_HUYNH_HOC_VIEN
        ("ix_PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH", "PHU_HUYNH_HOC_VIEN", "MaNguoiDung_PH"),
        ("ix_PHU_HUYNH_HOC_VIEN_MaHocVien", "PHU_HUYNH_HOC_VIEN", "MaHocVien"),
    ]

    for idx_name, tbl, col in additive_indexes:
        c.execute(f"CREATE INDEX IF NOT EXISTS {idx_name} ON {tbl} ({col})")
        print(f"   ✓ Index: {idx_name} ON {tbl}({col}) [SAFE]")

    conn.commit()

    # 4. Kiểm tra toàn vẹn sau đồng bộ
    print("\n🔍 [4/5] Kiểm tra toàn vẹn sau đồng bộ...")
    c.execute("PRAGMA foreign_key_check")
    fk_errors = c.fetchall()
    print(f"   + Foreign key errors: {len(fk_errors)}")
    assert len(fk_errors) == 0, f"LỖI TOÀN VẸN: {fk_errors}"

    # 5. Đối chiếu số lượng bản ghi sau migration
    counts_after = {}
    for t in TABLES:
        c.execute(f"SELECT COUNT(*) FROM '{t}'")
        counts_after[t] = c.fetchone()[0]

    print("\n📋 [5/5] Đối chiếu bảo toàn dữ liệu (Trước vs Sau):")
    all_intact = True
    for t in TABLES:
        c_before = counts_before[t]
        c_after = counts_after[t]
        status = "BẢO TOÀN 100%" if c_before == c_after else "LỖI: BỊ THAY ĐỔI"
        if c_before != c_after:
            all_intact = False
        print(f"   - {t:22}: Trước = {c_before:4} | Sau = {c_after:4} -> {status}")

    assert all_intact, "LỖI BẢO MẬT DỮ LIỆU: Số lượng bản ghi bị biến động!"

    conn.close()
    print("\n🎉 ĐỒNG BỘ VÀ TỐI ƯU DATABASE THÀNH CÔNG RỰC RỠ! DỮ LIỆU BẢO TOÀN 100%!\n")

if __name__ == "__main__":
    run_sync_migration()
