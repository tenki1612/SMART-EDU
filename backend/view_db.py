"""
Script xem và tra cứu nhanh toàn bộ dữ liệu trong Cơ sở dữ liệu SMART-EDU.
Hỗ trợ cả SQLite và PostgreSQL.
Chạy: python view_db.py
"""

import sys
import sqlite3
from pathlib import Path

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

db_file = Path(__file__).resolve().parent / "language_center.db"

if not db_file.exists():
    print("❌ Chưa tìm thấy file CSDL SQLite language_center.db.")
    print("👉 Hãy chạy lệnh: python create_database.py để tạo database!")
    sys.exit(1)

conn = sqlite3.connect(str(db_file))
conn.row_factory = sqlite3.Row
cur = conn.cursor()

cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")
tables = [r[0] for r in cur.fetchall()]

print("\n" + "=" * 70)
print(f"📊 THỐNG KÊ CƠ SỞ DỮ LIỆU SMART-EDU LMS ({db_file.name})")
print(f"Tổng số bảng: {len(tables)} bảng")
print("=" * 70)

total_records = 0
for t in tables:
    cur.execute(f'SELECT COUNT(*) FROM "{t}"')
    cnt = cur.fetchone()[0]
    total_records += cnt
    print(f" • {t:<30}: {cnt:>4} bản ghi")

print("-" * 70)
print(f"👉 Tổng cộng: {total_records} bản ghi trên toàn bộ hệ thống.")
print("=" * 70)

print("\n🔑 DANH SÁCH TÀI KHOẢN MẪU (5 VAI TRÒ):")
print("-" * 70)
print(f"{'ID':<4} | {'Username':<14} | {'Role':<16} | {'Họ và tên':<30} | {'Mật khẩu'}")
print("-" * 70)
cur.execute("SELECT MaNguoiDung, TenDangNhap, VaiTro, HoTen, SoDienThoai FROM NGUOI_DUNG ORDER BY MaNguoiDung LIMIT 10")
for row in cur.fetchall():
    pass_hint = "admin123" if row['TenDangNhap'] == "admin" else (row['TenDangNhap'] + "123")
    print(f"{row['MaNguoiDung']:<4} | {row['TenDangNhap']:<14} | {row['VaiTro']:<16} | {row['HoTen']:<30} | {pass_hint}")

print("\n📚 DANH MỤC KHÓA HỌC (KHOA_HOC):")
print("-" * 70)
cur.execute("SELECT MaKhoaHoc, TenKhoaHoc, TrinhDoMucTieu, ThoiLuongTuan, HocPhi FROM KHOA_HOC ORDER BY MaKhoaHoc")
for row in cur.fetchall():
    print(f"[{row['MaKhoaHoc']}] {row['TenKhoaHoc']:<35} | {row['TrinhDoMucTieu']:<10} | {row['HocPhi']:>11,.0f} VNĐ ({row['ThoiLuongTuan']} tuần)")

print("\n🏫 DANH SÁCH LỚP HỌC ĐANG MỞ (LOP_HOC):")
print("-" * 70)
cur.execute("SELECT MaLopHoc, MaSoLop, SiSoToiDa, SiSoHienTai, TrangThai FROM LOP_HOC ORDER BY MaLopHoc LIMIT 6")
for row in cur.fetchall():
    print(f"[{row['MaLopHoc']}] {row['MaSoLop']:<25} | Sĩ số: {row['SiSoHienTai']}/{row['SiSoToiDa']} | Trạng thái: {row['TrangThai']}")

print("\n" + "=" * 70)
print("💡 Mẹo: Mở giao diện web quản lý: npx prisma studio --schema=prisma/schema.sqlite.prisma")
print("=" * 70 + "\n")
