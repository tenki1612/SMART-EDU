"""sync_smart_edu_schema

Revision ID: 0e23e790063c
Revises: 
Create Date: 2026-11-20 16:05:56.038269

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0e23e790063c'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

INDEXES = [
    ("ix_BUOI_HOC_MaLopHoc", "BUOI_HOC", ["MaLopHoc"]),
    ("ix_BUOI_HOC_MaPhongHoc", "BUOI_HOC", ["MaPhongHoc"]),
    ("ix_BUOI_HOC_MaGiangVien", "BUOI_HOC", ["MaGiangVien"]),
    ("ix_LOP_HOC_MaKhoaHoc", "LOP_HOC", ["MaKhoaHoc"]),
    ("ix_LOP_HOC_MaGiangVien", "LOP_HOC", ["MaGiangVien"]),
    ("ix_BANG_DIEM_MaLopHoc", "BANG_DIEM", ["MaLopHoc"]),
    ("ix_BANG_DIEM_MaHocVien", "BANG_DIEM", ["MaHocVien"]),
    ("ix_HOC_VIEN_LOP_HOC_MaLopHoc", "HOC_VIEN_LOP_HOC", ["MaLopHoc"]),
    ("ix_HOC_VIEN_LOP_HOC_MaHocVien", "HOC_VIEN_LOP_HOC", ["MaHocVien"]),
    ("ix_YEU_CAU_DANG_KY_MaLopHoc", "YEU_CAU_DANG_KY", ["MaLopHoc"]),
    ("ix_YEU_CAU_DANG_KY_MaHocVien", "YEU_CAU_DANG_KY", ["MaHocVien"]),
    ("ix_PHU_HUYNH_HOC_VIEN_MaHocVien", "PHU_HUYNH_HOC_VIEN", ["MaHocVien"]),
    ("ix_PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH", "PHU_HUYNH_HOC_VIEN", ["MaNguoiDung_PH"]),
    ("ix_TIEN_TRINH_KHOA_HOC_MaHocVien", "TIEN_TRINH_KHOA_HOC", ["MaHocVien"]),
    ("ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai", "TIEN_TRINH_KHOA_HOC", ["MaKhoaHocHienTai"]),
    ("ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo", "TIEN_TRINH_KHOA_HOC", ["MaKhoaHocTiepTheo"]),
    ("ix_LICHSU_KHOA_DIEM_MaNguoiThucHien", "LICHSU_KHOA_DIEM", ["MaNguoiThucHien"]),
]

def upgrade() -> None:
    """Upgrade schema: ensure all 17 FK & performance indexes are created safely."""
    bind = op.get_bind()
    insp = sa.inspect(bind)
    
    for idx_name, tbl_name, cols in INDEXES:
        try:
            existing_indices = [idx["name"] for idx in insp.get_indexes(tbl_name)]
            if idx_name not in existing_indices:
                op.create_index(idx_name, tbl_name, cols, unique=False)
        except Exception:
            pass


def downgrade() -> None:
    """Downgrade schema: safely remove the indexes without dropping any table or data."""
    bind = op.get_bind()
    insp = sa.inspect(bind)
    
    for idx_name, tbl_name, _ in reversed(INDEXES):
        try:
            existing_indices = [idx["name"] for idx in insp.get_indexes(tbl_name)]
            if idx_name in existing_indices:
                op.drop_index(idx_name, table_name=tbl_name)
        except Exception:
            pass
