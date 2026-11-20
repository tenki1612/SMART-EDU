import sqlite3

conn = sqlite3.connect('backend/language_center.db')
c = conn.cursor()

def get_count(table):
    c.execute(f"SELECT COUNT(*) FROM {table}")
    return c.fetchone()[0]

print("=== BÁO CÁO DỮ LIỆU HIỆN TẠI (LANGUAGE_CENTER.DB) ===")
print(f"Tổng NGUOI_DUNG: {get_count('NGUOI_DUNG')}")
c.execute("SELECT VaiTro, COUNT(*) FROM NGUOI_DUNG GROUP BY VaiTro")
for r in c.fetchall():
    print(f"  - {r[0]:15}: {r[1]}")

print(f"\nGIANG_VIEN (Teacher): {get_count('GIANG_VIEN')}")
print(f"HOC_VIEN (Student): {get_count('HOC_VIEN')}")
print(f"PHU_HUYNH_HOC_VIEN (ParentLink): {get_count('PHU_HUYNH_HOC_VIEN')}")
print(f"KHOA_HOC (Course): {get_count('KHOA_HOC')}")
print(f"LOP_HOC (Class): {get_count('LOP_HOC')}")
print(f"HOC_VIEN_LOP_HOC (ClassStudent / Roster): {get_count('HOC_VIEN_LOP_HOC')}")
print(f"YEU_CAU_DANG_KY (EnrollmentRequest): {get_count('YEU_CAU_DANG_KY')}")
print(f"PHONG_HOC (Classroom): {get_count('PHONG_HOC')}")
print(f"BUOI_HOC (ScheduleSession): {get_count('BUOI_HOC')}")
print(f"BANG_DIEM (GradeRecord): {get_count('BANG_DIEM')}")
print(f"DON_THU (Ticket): {get_count('DON_THU')}")
print(f"TIEN_TRINH_KHOA_HOC (CourseProgression): {get_count('TIEN_TRINH_KHOA_HOC')}")

print("\n=== PHÂN BỐ LỚP THEO KHÓA HỌC HIỆN TẠI ===")
c.execute("""
    SELECT k.MaKhoaHoc, k.MaSoKhoaHoc, k.TenKhoaHoc, COUNT(l.MaLopHoc) as class_count
    FROM KHOA_HOC k
    LEFT JOIN LOP_HOC l ON k.MaKhoaHoc = l.MaKhoaHoc AND l.DaXoa = 0
    WHERE k.DaXoa = 0
    GROUP BY k.MaKhoaHoc
    ORDER BY class_count DESC
""")
courses_dist = c.fetchall()
for r in courses_dist:
    print(f"Khóa ID {r[0]:2d} [{r[1]:18}] {r[2][:35]:35}: {r[3]} lớp")

# Trạng thái các lớp
print("\n=== PHÂN BỐ TRẠNG THÁI LỚP HỌC ===")
c.execute("SELECT TrangThai, COUNT(*) FROM LOP_HOC WHERE DaXoa = 0 GROUP BY TrangThai")
for r in c.fetchall():
    print(f"  - {r[0]:20}: {r[1]} lớp")

conn.close()
