import psycopg2
import sqlite3
import os

PG_URL = "postgresql://postgres:postgrespassword2026@127.0.0.1:5432/language_center"
SQLITE_PATH = os.path.abspath("backend/language_center.db")

pg_conn = psycopg2.connect(PG_URL)
pg_cur = pg_conn.cursor()

sq_conn = sqlite3.connect(SQLITE_PATH)
sq_cur = sq_conn.cursor()

tables_pk = [
    ("NGUOI_DUNG", "MaNguoiDung"),
    ("GIANG_VIEN", "MaGiangVien"),
    ("HOC_VIEN", "MaHocVien"),
    ("PHU_HUYNH_HOC_VIEN", "MaPH_HV"),
    ("KHOA_HOC", "MaKhoaHoc"),
    ("PHONG_HOC", "MaPhongHoc"),
    ("LOP_HOC", "MaLopHoc"),
    ("HOC_VIEN_LOP_HOC", "MaHV_LH"),
    ("YEU_CAU_DANG_KY", "MaYeuCau"),
    ("BUOI_HOC", "MaBuoiHoc"),
    ("BANG_DIEM", "MaBangDiem"),
    ("TIEN_TRINH_KHOA_HOC", "MaTienTrinh"),
    ("DON_THU", "MaDon"),
    ("DON_THU_PHAN_HOI", "MaPhanHoi"),
    ("LICHSU_KHOA_DIEM", "MaLichSu")
]

print("=== CHECKING PK OVERLAP: PG vs SQLITE ===")
for t, pk in tables_pk:
    pg_cur.execute(f'SELECT "{pk}" FROM "{t}";')
    pg_ids = set(r[0] for r in pg_cur.fetchall())
    
    sq_cur.execute(f'SELECT "{pk}" FROM "{t}";')
    sq_ids = set(r[0] for r in sq_cur.fetchall())
    
    in_pg_not_sq = pg_ids - sq_ids
    in_sq_not_pg = sq_ids - pg_ids
    print(f"{t:<22} | PG: {len(pg_ids):<5} | SQ: {len(sq_ids):<5} | PG-not-SQ: {len(in_pg_not_sq):<3} | SQ-not-PG: {len(in_sq_not_pg):<5}")

pg_conn.close()
sq_conn.close()
