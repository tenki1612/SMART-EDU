--
-- PostgreSQL database dump
--

\restrict 6JoyCw8Bp52fPaJRZDch5oAjxe4lhnMeVao9UOzOl9qoMQfZjpTKzwMD06kmY46

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public."YEU_CAU_DANG_KY" DROP CONSTRAINT IF EXISTS "YEU_CAU_DANG_KY_MaNguoiDuyet_fkey";
ALTER TABLE IF EXISTS ONLY public."YEU_CAU_DANG_KY" DROP CONSTRAINT IF EXISTS "YEU_CAU_DANG_KY_MaLopHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."YEU_CAU_DANG_KY" DROP CONSTRAINT IF EXISTS "YEU_CAU_DANG_KY_MaHocVien_fkey";
ALTER TABLE IF EXISTS ONLY public."TIEN_TRINH_KHOA_HOC" DROP CONSTRAINT IF EXISTS "TIEN_TRINH_KHOA_HOC_MaNguoiXacNhan_fkey";
ALTER TABLE IF EXISTS ONLY public."TIEN_TRINH_KHOA_HOC" DROP CONSTRAINT IF EXISTS "TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo_fkey";
ALTER TABLE IF EXISTS ONLY public."TIEN_TRINH_KHOA_HOC" DROP CONSTRAINT IF EXISTS "TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai_fkey";
ALTER TABLE IF EXISTS ONLY public."TIEN_TRINH_KHOA_HOC" DROP CONSTRAINT IF EXISTS "TIEN_TRINH_KHOA_HOC_MaHocVien_fkey";
ALTER TABLE IF EXISTS ONLY public."PHU_HUYNH_HOC_VIEN" DROP CONSTRAINT IF EXISTS "PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH_fkey";
ALTER TABLE IF EXISTS ONLY public."PHU_HUYNH_HOC_VIEN" DROP CONSTRAINT IF EXISTS "PHU_HUYNH_HOC_VIEN_MaHocVien_fkey";
ALTER TABLE IF EXISTS ONLY public."LOP_HOC" DROP CONSTRAINT IF EXISTS "LOP_HOC_MaKhoaHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."LOP_HOC" DROP CONSTRAINT IF EXISTS "LOP_HOC_MaGiangVien_fkey";
ALTER TABLE IF EXISTS ONLY public."LICHSU_KHOA_DIEM" DROP CONSTRAINT IF EXISTS "LICHSU_KHOA_DIEM_MaNguoiThucHien_fkey";
ALTER TABLE IF EXISTS ONLY public."LICHSU_KHOA_DIEM" DROP CONSTRAINT IF EXISTS "LICHSU_KHOA_DIEM_MaLopHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."HOC_VIEN" DROP CONSTRAINT IF EXISTS "HOC_VIEN_MaNguoiDung_fkey";
ALTER TABLE IF EXISTS ONLY public."HOC_VIEN_LOP_HOC" DROP CONSTRAINT IF EXISTS "HOC_VIEN_LOP_HOC_MaLopHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."HOC_VIEN_LOP_HOC" DROP CONSTRAINT IF EXISTS "HOC_VIEN_LOP_HOC_MaHocVien_fkey";
ALTER TABLE IF EXISTS ONLY public."GIANG_VIEN" DROP CONSTRAINT IF EXISTS "GIANG_VIEN_MaNguoiDung_fkey";
ALTER TABLE IF EXISTS ONLY public."DON_THU_PHAN_HOI" DROP CONSTRAINT IF EXISTS "DON_THU_PHAN_HOI_MaNguoiGui_fkey";
ALTER TABLE IF EXISTS ONLY public."DON_THU_PHAN_HOI" DROP CONSTRAINT IF EXISTS "DON_THU_PHAN_HOI_MaDon_fkey";
ALTER TABLE IF EXISTS ONLY public."DON_THU" DROP CONSTRAINT IF EXISTS "DON_THU_MaNguoiNhan_fkey";
ALTER TABLE IF EXISTS ONLY public."DON_THU" DROP CONSTRAINT IF EXISTS "DON_THU_MaNguoiGui_fkey";
ALTER TABLE IF EXISTS ONLY public."DON_THU" DROP CONSTRAINT IF EXISTS "DON_THU_MaLopHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."BUOI_HOC" DROP CONSTRAINT IF EXISTS "BUOI_HOC_MaPhongHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."BUOI_HOC" DROP CONSTRAINT IF EXISTS "BUOI_HOC_MaLopHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."BUOI_HOC" DROP CONSTRAINT IF EXISTS "BUOI_HOC_MaGiangVien_fkey";
ALTER TABLE IF EXISTS ONLY public."BANG_DIEM" DROP CONSTRAINT IF EXISTS "BANG_DIEM_MaLopHoc_fkey";
ALTER TABLE IF EXISTS ONLY public."BANG_DIEM" DROP CONSTRAINT IF EXISTS "BANG_DIEM_MaHocVien_fkey";
DROP INDEX IF EXISTS public."ix_YEU_CAU_DANG_KY_MaYeuCau";
DROP INDEX IF EXISTS public."ix_YEU_CAU_DANG_KY_MaLopHoc";
DROP INDEX IF EXISTS public."ix_YEU_CAU_DANG_KY_MaHocVien";
DROP INDEX IF EXISTS public."ix_TIEN_TRINH_KHOA_HOC_MaTienTrinh";
DROP INDEX IF EXISTS public."ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo";
DROP INDEX IF EXISTS public."ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai";
DROP INDEX IF EXISTS public."ix_TIEN_TRINH_KHOA_HOC_MaHocVien";
DROP INDEX IF EXISTS public."ix_PHU_HUYNH_HOC_VIEN_MaPH_HV";
DROP INDEX IF EXISTS public."ix_PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH";
DROP INDEX IF EXISTS public."ix_PHU_HUYNH_HOC_VIEN_MaHocVien";
DROP INDEX IF EXISTS public."ix_PHONG_HOC_MaSoPhong";
DROP INDEX IF EXISTS public."ix_PHONG_HOC_MaPhongHoc";
DROP INDEX IF EXISTS public."ix_NGUOI_DUNG_TenDangNhap";
DROP INDEX IF EXISTS public."ix_NGUOI_DUNG_MaNguoiDung";
DROP INDEX IF EXISTS public."ix_NGUOI_DUNG_Email";
DROP INDEX IF EXISTS public."ix_LOP_HOC_MaSoLop";
DROP INDEX IF EXISTS public."ix_LOP_HOC_MaLopHoc";
DROP INDEX IF EXISTS public."ix_LOP_HOC_MaKhoaHoc";
DROP INDEX IF EXISTS public."ix_LOP_HOC_MaGiangVien";
DROP INDEX IF EXISTS public."ix_LICHSU_KHOA_DIEM_MaNguoiThucHien";
DROP INDEX IF EXISTS public."ix_LICHSU_KHOA_DIEM_MaLopHoc";
DROP INDEX IF EXISTS public."ix_LICHSU_KHOA_DIEM_MaLichSu";
DROP INDEX IF EXISTS public."ix_KHOA_HOC_MaSoKhoaHoc";
DROP INDEX IF EXISTS public."ix_KHOA_HOC_MaKhoaHoc";
DROP INDEX IF EXISTS public."ix_HOC_VIEN_MaSoHocVien";
DROP INDEX IF EXISTS public."ix_HOC_VIEN_MaHocVien";
DROP INDEX IF EXISTS public."ix_HOC_VIEN_LOP_HOC_MaLopHoc";
DROP INDEX IF EXISTS public."ix_HOC_VIEN_LOP_HOC_MaHocVien";
DROP INDEX IF EXISTS public."ix_HOC_VIEN_LOP_HOC_MaHV_LH";
DROP INDEX IF EXISTS public."ix_GIANG_VIEN_MaSoGiangVien";
DROP INDEX IF EXISTS public."ix_GIANG_VIEN_MaGiangVien";
DROP INDEX IF EXISTS public."ix_DON_THU_PHAN_HOI_MaPhanHoi";
DROP INDEX IF EXISTS public."ix_DON_THU_PHAN_HOI_MaDon";
DROP INDEX IF EXISTS public."ix_DON_THU_MaSoDon";
DROP INDEX IF EXISTS public."ix_DON_THU_MaNguoiNhan";
DROP INDEX IF EXISTS public."ix_DON_THU_MaNguoiGui";
DROP INDEX IF EXISTS public."ix_DON_THU_MaLopHoc";
DROP INDEX IF EXISTS public."ix_DON_THU_MaDon";
DROP INDEX IF EXISTS public."ix_BUOI_HOC_MaPhongHoc";
DROP INDEX IF EXISTS public."ix_BUOI_HOC_MaLopHoc";
DROP INDEX IF EXISTS public."ix_BUOI_HOC_MaGiangVien";
DROP INDEX IF EXISTS public."ix_BUOI_HOC_MaBuoiHoc";
DROP INDEX IF EXISTS public."ix_BANG_DIEM_MaLopHoc";
DROP INDEX IF EXISTS public."ix_BANG_DIEM_MaHocVien";
DROP INDEX IF EXISTS public."ix_BANG_DIEM_MaBangDiem";
ALTER TABLE IF EXISTS ONLY public."NGUOI_DUNG" DROP CONSTRAINT IF EXISTS uq_nguoidung_email_vaitro;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS ONLY public."YEU_CAU_DANG_KY" DROP CONSTRAINT IF EXISTS "YEU_CAU_DANG_KY_pkey";
ALTER TABLE IF EXISTS ONLY public."TIEN_TRINH_KHOA_HOC" DROP CONSTRAINT IF EXISTS "TIEN_TRINH_KHOA_HOC_pkey";
ALTER TABLE IF EXISTS ONLY public."PHU_HUYNH_HOC_VIEN" DROP CONSTRAINT IF EXISTS "PHU_HUYNH_HOC_VIEN_pkey";
ALTER TABLE IF EXISTS ONLY public."PHONG_HOC" DROP CONSTRAINT IF EXISTS "PHONG_HOC_pkey";
ALTER TABLE IF EXISTS ONLY public."NGUOI_DUNG" DROP CONSTRAINT IF EXISTS "NGUOI_DUNG_pkey";
ALTER TABLE IF EXISTS ONLY public."LOP_HOC" DROP CONSTRAINT IF EXISTS "LOP_HOC_pkey";
ALTER TABLE IF EXISTS ONLY public."LICHSU_KHOA_DIEM" DROP CONSTRAINT IF EXISTS "LICHSU_KHOA_DIEM_pkey";
ALTER TABLE IF EXISTS ONLY public."KHOA_HOC" DROP CONSTRAINT IF EXISTS "KHOA_HOC_pkey";
ALTER TABLE IF EXISTS ONLY public."HOC_VIEN" DROP CONSTRAINT IF EXISTS "HOC_VIEN_pkey";
ALTER TABLE IF EXISTS ONLY public."HOC_VIEN" DROP CONSTRAINT IF EXISTS "HOC_VIEN_MaNguoiDung_key";
ALTER TABLE IF EXISTS ONLY public."HOC_VIEN_LOP_HOC" DROP CONSTRAINT IF EXISTS "HOC_VIEN_LOP_HOC_pkey";
ALTER TABLE IF EXISTS ONLY public."GIANG_VIEN" DROP CONSTRAINT IF EXISTS "GIANG_VIEN_pkey";
ALTER TABLE IF EXISTS ONLY public."GIANG_VIEN" DROP CONSTRAINT IF EXISTS "GIANG_VIEN_MaNguoiDung_key";
ALTER TABLE IF EXISTS ONLY public."DON_THU" DROP CONSTRAINT IF EXISTS "DON_THU_pkey";
ALTER TABLE IF EXISTS ONLY public."DON_THU_PHAN_HOI" DROP CONSTRAINT IF EXISTS "DON_THU_PHAN_HOI_pkey";
ALTER TABLE IF EXISTS ONLY public."BUOI_HOC" DROP CONSTRAINT IF EXISTS "BUOI_HOC_pkey";
ALTER TABLE IF EXISTS ONLY public."BANG_DIEM" DROP CONSTRAINT IF EXISTS "BANG_DIEM_pkey";
ALTER TABLE IF EXISTS public."YEU_CAU_DANG_KY" ALTER COLUMN "MaYeuCau" DROP DEFAULT;
ALTER TABLE IF EXISTS public."TIEN_TRINH_KHOA_HOC" ALTER COLUMN "MaTienTrinh" DROP DEFAULT;
ALTER TABLE IF EXISTS public."PHU_HUYNH_HOC_VIEN" ALTER COLUMN "MaPH_HV" DROP DEFAULT;
ALTER TABLE IF EXISTS public."PHONG_HOC" ALTER COLUMN "MaPhongHoc" DROP DEFAULT;
ALTER TABLE IF EXISTS public."NGUOI_DUNG" ALTER COLUMN "MaNguoiDung" DROP DEFAULT;
ALTER TABLE IF EXISTS public."LOP_HOC" ALTER COLUMN "MaLopHoc" DROP DEFAULT;
ALTER TABLE IF EXISTS public."LICHSU_KHOA_DIEM" ALTER COLUMN "MaLichSu" DROP DEFAULT;
ALTER TABLE IF EXISTS public."KHOA_HOC" ALTER COLUMN "MaKhoaHoc" DROP DEFAULT;
ALTER TABLE IF EXISTS public."HOC_VIEN_LOP_HOC" ALTER COLUMN "MaHV_LH" DROP DEFAULT;
ALTER TABLE IF EXISTS public."HOC_VIEN" ALTER COLUMN "MaHocVien" DROP DEFAULT;
ALTER TABLE IF EXISTS public."GIANG_VIEN" ALTER COLUMN "MaGiangVien" DROP DEFAULT;
ALTER TABLE IF EXISTS public."DON_THU_PHAN_HOI" ALTER COLUMN "MaPhanHoi" DROP DEFAULT;
ALTER TABLE IF EXISTS public."DON_THU" ALTER COLUMN "MaDon" DROP DEFAULT;
ALTER TABLE IF EXISTS public."BUOI_HOC" ALTER COLUMN "MaBuoiHoc" DROP DEFAULT;
ALTER TABLE IF EXISTS public."BANG_DIEM" ALTER COLUMN "MaBangDiem" DROP DEFAULT;
DROP TABLE IF EXISTS public.alembic_version;
DROP SEQUENCE IF EXISTS public."YEU_CAU_DANG_KY_MaYeuCau_seq";
DROP TABLE IF EXISTS public."YEU_CAU_DANG_KY";
DROP SEQUENCE IF EXISTS public."TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq";
DROP TABLE IF EXISTS public."TIEN_TRINH_KHOA_HOC";
DROP SEQUENCE IF EXISTS public."PHU_HUYNH_HOC_VIEN_MaPH_HV_seq";
DROP TABLE IF EXISTS public."PHU_HUYNH_HOC_VIEN";
DROP SEQUENCE IF EXISTS public."PHONG_HOC_MaPhongHoc_seq";
DROP TABLE IF EXISTS public."PHONG_HOC";
DROP SEQUENCE IF EXISTS public."NGUOI_DUNG_MaNguoiDung_seq";
DROP TABLE IF EXISTS public."NGUOI_DUNG";
DROP SEQUENCE IF EXISTS public."LOP_HOC_MaLopHoc_seq";
DROP TABLE IF EXISTS public."LOP_HOC";
DROP SEQUENCE IF EXISTS public."LICHSU_KHOA_DIEM_MaLichSu_seq";
DROP TABLE IF EXISTS public."LICHSU_KHOA_DIEM";
DROP SEQUENCE IF EXISTS public."KHOA_HOC_MaKhoaHoc_seq";
DROP TABLE IF EXISTS public."KHOA_HOC";
DROP SEQUENCE IF EXISTS public."HOC_VIEN_MaHocVien_seq";
DROP SEQUENCE IF EXISTS public."HOC_VIEN_LOP_HOC_MaHV_LH_seq";
DROP TABLE IF EXISTS public."HOC_VIEN_LOP_HOC";
DROP TABLE IF EXISTS public."HOC_VIEN";
DROP SEQUENCE IF EXISTS public."GIANG_VIEN_MaGiangVien_seq";
DROP TABLE IF EXISTS public."GIANG_VIEN";
DROP SEQUENCE IF EXISTS public."DON_THU_PHAN_HOI_MaPhanHoi_seq";
DROP TABLE IF EXISTS public."DON_THU_PHAN_HOI";
DROP SEQUENCE IF EXISTS public."DON_THU_MaDon_seq";
DROP TABLE IF EXISTS public."DON_THU";
DROP SEQUENCE IF EXISTS public."BUOI_HOC_MaBuoiHoc_seq";
DROP TABLE IF EXISTS public."BUOI_HOC";
DROP SEQUENCE IF EXISTS public."BANG_DIEM_MaBangDiem_seq";
DROP TABLE IF EXISTS public."BANG_DIEM";
DROP TYPE IF EXISTS public.roleenum;
-- *not* dropping schema, since initdb creates it
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: roleenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.roleenum AS ENUM (
    'ADMIN',
    'ACADEMIC_STAFF',
    'TEACHER',
    'STUDENT',
    'PARENT'
);


ALTER TYPE public.roleenum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: BANG_DIEM; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BANG_DIEM" (
    "MaBangDiem" integer NOT NULL,
    "MaLopHoc" integer NOT NULL,
    "MaHocVien" integer NOT NULL,
    "DiemChuyenCan" double precision,
    "DiemGiuaKy" double precision,
    "DiemCuoiKy" double precision,
    "DiemTongKet" double precision,
    "KetQua" character varying(50),
    "DaKhoaSo" boolean,
    "GhiChu" text,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."BANG_DIEM" OWNER TO postgres;

--
-- Name: BANG_DIEM_MaBangDiem_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."BANG_DIEM_MaBangDiem_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."BANG_DIEM_MaBangDiem_seq" OWNER TO postgres;

--
-- Name: BANG_DIEM_MaBangDiem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."BANG_DIEM_MaBangDiem_seq" OWNED BY public."BANG_DIEM"."MaBangDiem";


--
-- Name: BUOI_HOC; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BUOI_HOC" (
    "MaBuoiHoc" integer NOT NULL,
    "MaLopHoc" integer NOT NULL,
    "MaPhongHoc" integer NOT NULL,
    "MaGiangVien" integer NOT NULL,
    "NgayHoc" date NOT NULL,
    "GioBatDau" character varying(10) NOT NULL,
    "GioKetThuc" character varying(10) NOT NULL,
    "CaHoc" character varying(100),
    "DaXacNhan" boolean,
    "TrangThai" character varying(50),
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."BUOI_HOC" OWNER TO postgres;

--
-- Name: BUOI_HOC_MaBuoiHoc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."BUOI_HOC_MaBuoiHoc_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."BUOI_HOC_MaBuoiHoc_seq" OWNER TO postgres;

--
-- Name: BUOI_HOC_MaBuoiHoc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."BUOI_HOC_MaBuoiHoc_seq" OWNED BY public."BUOI_HOC"."MaBuoiHoc";


--
-- Name: DON_THU; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DON_THU" (
    "MaDon" integer NOT NULL,
    "MaSoDon" character varying(50) NOT NULL,
    "LoaiDon" character varying(50) NOT NULL,
    "MaNguoiGui" integer NOT NULL,
    "MaNguoiNhan" integer,
    "VaiTroNguoiNhan" character varying(50),
    "LinhVuc" character varying(50) NOT NULL,
    "MaLopHoc" integer,
    "TieuDe" character varying(255) NOT NULL,
    "NoiDung" text NOT NULL,
    "TrangThai" character varying(50),
    "HanChotKhieuNai" timestamp without time zone,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."DON_THU" OWNER TO postgres;

--
-- Name: DON_THU_MaDon_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DON_THU_MaDon_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DON_THU_MaDon_seq" OWNER TO postgres;

--
-- Name: DON_THU_MaDon_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DON_THU_MaDon_seq" OWNED BY public."DON_THU"."MaDon";


--
-- Name: DON_THU_PHAN_HOI; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DON_THU_PHAN_HOI" (
    "MaPhanHoi" integer NOT NULL,
    "MaDon" integer NOT NULL,
    "MaNguoiGui" integer NOT NULL,
    "NoiDung" text NOT NULL,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."DON_THU_PHAN_HOI" OWNER TO postgres;

--
-- Name: DON_THU_PHAN_HOI_MaPhanHoi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DON_THU_PHAN_HOI_MaPhanHoi_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DON_THU_PHAN_HOI_MaPhanHoi_seq" OWNER TO postgres;

--
-- Name: DON_THU_PHAN_HOI_MaPhanHoi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DON_THU_PHAN_HOI_MaPhanHoi_seq" OWNED BY public."DON_THU_PHAN_HOI"."MaPhanHoi";


--
-- Name: GIANG_VIEN; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GIANG_VIEN" (
    "MaGiangVien" integer NOT NULL,
    "MaNguoiDung" integer NOT NULL,
    "MaSoGiangVien" character varying(50) NOT NULL,
    "ChuyenMon" character varying(100),
    "HocVi" character varying(100),
    "TrangThai" character varying(50),
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."GIANG_VIEN" OWNER TO postgres;

--
-- Name: GIANG_VIEN_MaGiangVien_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."GIANG_VIEN_MaGiangVien_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."GIANG_VIEN_MaGiangVien_seq" OWNER TO postgres;

--
-- Name: GIANG_VIEN_MaGiangVien_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."GIANG_VIEN_MaGiangVien_seq" OWNED BY public."GIANG_VIEN"."MaGiangVien";


--
-- Name: HOC_VIEN; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HOC_VIEN" (
    "MaHocVien" integer NOT NULL,
    "MaNguoiDung" integer NOT NULL,
    "MaSoHocVien" character varying(50) NOT NULL,
    "NgaySinh" date,
    "DiaChi" character varying(255),
    "TrangThai" character varying(50),
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."HOC_VIEN" OWNER TO postgres;

--
-- Name: HOC_VIEN_LOP_HOC; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HOC_VIEN_LOP_HOC" (
    "MaHV_LH" integer NOT NULL,
    "MaLopHoc" integer NOT NULL,
    "MaHocVien" integer NOT NULL,
    "NgayVaoLop" timestamp without time zone,
    "TrangThaiHoc" character varying(50),
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."HOC_VIEN_LOP_HOC" OWNER TO postgres;

--
-- Name: HOC_VIEN_LOP_HOC_MaHV_LH_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."HOC_VIEN_LOP_HOC_MaHV_LH_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."HOC_VIEN_LOP_HOC_MaHV_LH_seq" OWNER TO postgres;

--
-- Name: HOC_VIEN_LOP_HOC_MaHV_LH_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."HOC_VIEN_LOP_HOC_MaHV_LH_seq" OWNED BY public."HOC_VIEN_LOP_HOC"."MaHV_LH";


--
-- Name: HOC_VIEN_MaHocVien_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."HOC_VIEN_MaHocVien_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."HOC_VIEN_MaHocVien_seq" OWNER TO postgres;

--
-- Name: HOC_VIEN_MaHocVien_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."HOC_VIEN_MaHocVien_seq" OWNED BY public."HOC_VIEN"."MaHocVien";


--
-- Name: KHOA_HOC; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."KHOA_HOC" (
    "MaKhoaHoc" integer NOT NULL,
    "MaSoKhoaHoc" character varying(50) NOT NULL,
    "TenKhoaHoc" character varying(150) NOT NULL,
    "MoTa" text,
    "TrinhDoMucTieu" character varying(100) NOT NULL,
    "ThoiLuongTuan" integer,
    "HocPhi" double precision,
    "TrangThai" boolean,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."KHOA_HOC" OWNER TO postgres;

--
-- Name: KHOA_HOC_MaKhoaHoc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."KHOA_HOC_MaKhoaHoc_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."KHOA_HOC_MaKhoaHoc_seq" OWNER TO postgres;

--
-- Name: KHOA_HOC_MaKhoaHoc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."KHOA_HOC_MaKhoaHoc_seq" OWNED BY public."KHOA_HOC"."MaKhoaHoc";


--
-- Name: LICHSU_KHOA_DIEM; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LICHSU_KHOA_DIEM" (
    "MaLichSu" integer NOT NULL,
    "MaLopHoc" integer NOT NULL,
    "HanhDong" character varying(50) NOT NULL,
    "MaNguoiThucHien" integer,
    "ThoiGian" timestamp without time zone,
    "LyDo" text,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."LICHSU_KHOA_DIEM" OWNER TO postgres;

--
-- Name: LICHSU_KHOA_DIEM_MaLichSu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."LICHSU_KHOA_DIEM_MaLichSu_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."LICHSU_KHOA_DIEM_MaLichSu_seq" OWNER TO postgres;

--
-- Name: LICHSU_KHOA_DIEM_MaLichSu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."LICHSU_KHOA_DIEM_MaLichSu_seq" OWNED BY public."LICHSU_KHOA_DIEM"."MaLichSu";


--
-- Name: LOP_HOC; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LOP_HOC" (
    "MaLopHoc" integer NOT NULL,
    "MaSoLop" character varying(50) NOT NULL,
    "MaKhoaHoc" integer NOT NULL,
    "MaGiangVien" integer,
    "SiSoToiDa" integer,
    "SiSoHienTai" integer,
    "NgayMoLop" date,
    "NgayBatDau" date,
    "NgayKetThuc" date,
    "TrangThai" character varying(50),
    "MoKhoaDiemThuCong" boolean,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."LOP_HOC" OWNER TO postgres;

--
-- Name: LOP_HOC_MaLopHoc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."LOP_HOC_MaLopHoc_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."LOP_HOC_MaLopHoc_seq" OWNER TO postgres;

--
-- Name: LOP_HOC_MaLopHoc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."LOP_HOC_MaLopHoc_seq" OWNED BY public."LOP_HOC"."MaLopHoc";


--
-- Name: NGUOI_DUNG; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."NGUOI_DUNG" (
    "MaNguoiDung" integer NOT NULL,
    "TenDangNhap" character varying(50) NOT NULL,
    "Email" character varying(100) NOT NULL,
    "HoTen" character varying(100) NOT NULL,
    "MatKhau" character varying(255) NOT NULL,
    "VaiTro" public.roleenum NOT NULL,
    "SoDienThoai" character varying(20),
    "AnhDaiDien" character varying(500),
    "TrangThai" boolean,
    "SoLanDangNhapSai" integer NOT NULL,
    "ThoiGianKhoa" timestamp without time zone,
    "MaXacThucOTP" character varying(100),
    "HanXacThucOTP" timestamp without time zone,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."NGUOI_DUNG" OWNER TO postgres;

--
-- Name: NGUOI_DUNG_MaNguoiDung_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."NGUOI_DUNG_MaNguoiDung_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."NGUOI_DUNG_MaNguoiDung_seq" OWNER TO postgres;

--
-- Name: NGUOI_DUNG_MaNguoiDung_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."NGUOI_DUNG_MaNguoiDung_seq" OWNED BY public."NGUOI_DUNG"."MaNguoiDung";


--
-- Name: PHONG_HOC; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PHONG_HOC" (
    "MaPhongHoc" integer NOT NULL,
    "MaSoPhong" character varying(50) NOT NULL,
    "ToaNha" character varying(50),
    "SucChua" integer,
    "TrangThai" character varying(50),
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."PHONG_HOC" OWNER TO postgres;

--
-- Name: PHONG_HOC_MaPhongHoc_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."PHONG_HOC_MaPhongHoc_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."PHONG_HOC_MaPhongHoc_seq" OWNER TO postgres;

--
-- Name: PHONG_HOC_MaPhongHoc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."PHONG_HOC_MaPhongHoc_seq" OWNED BY public."PHONG_HOC"."MaPhongHoc";


--
-- Name: PHU_HUYNH_HOC_VIEN; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PHU_HUYNH_HOC_VIEN" (
    "MaPH_HV" integer NOT NULL,
    "MaNguoiDung_PH" integer NOT NULL,
    "MaHocVien" integer NOT NULL,
    "QuanHe" character varying(50),
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."PHU_HUYNH_HOC_VIEN" OWNER TO postgres;

--
-- Name: PHU_HUYNH_HOC_VIEN_MaPH_HV_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."PHU_HUYNH_HOC_VIEN_MaPH_HV_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."PHU_HUYNH_HOC_VIEN_MaPH_HV_seq" OWNER TO postgres;

--
-- Name: PHU_HUYNH_HOC_VIEN_MaPH_HV_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."PHU_HUYNH_HOC_VIEN_MaPH_HV_seq" OWNED BY public."PHU_HUYNH_HOC_VIEN"."MaPH_HV";


--
-- Name: TIEN_TRINH_KHOA_HOC; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TIEN_TRINH_KHOA_HOC" (
    "MaTienTrinh" integer NOT NULL,
    "MaHocVien" integer NOT NULL,
    "MaKhoaHocHienTai" integer NOT NULL,
    "MaKhoaHocTiepTheo" integer NOT NULL,
    "DuDieuKien" boolean,
    "DaXacNhan" boolean,
    "MaNguoiXacNhan" integer,
    "NgayXacNhan" timestamp without time zone,
    "GhiChu" text,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."TIEN_TRINH_KHOA_HOC" OWNER TO postgres;

--
-- Name: TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq" OWNER TO postgres;

--
-- Name: TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq" OWNED BY public."TIEN_TRINH_KHOA_HOC"."MaTienTrinh";


--
-- Name: YEU_CAU_DANG_KY; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."YEU_CAU_DANG_KY" (
    "MaYeuCau" integer NOT NULL,
    "MaHocVien" integer NOT NULL,
    "MaLopHoc" integer NOT NULL,
    "NgayYeuCau" timestamp without time zone,
    "TrangThai" character varying(50),
    "GhiChu" text,
    "LyDoTuChoi" text,
    "MaNguoiDuyet" integer,
    "NgayDuyet" timestamp without time zone,
    "NgayTao" timestamp without time zone,
    "NgayCapNhat" timestamp without time zone,
    "DaXoa" boolean
);


ALTER TABLE public."YEU_CAU_DANG_KY" OWNER TO postgres;

--
-- Name: YEU_CAU_DANG_KY_MaYeuCau_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."YEU_CAU_DANG_KY_MaYeuCau_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."YEU_CAU_DANG_KY_MaYeuCau_seq" OWNER TO postgres;

--
-- Name: YEU_CAU_DANG_KY_MaYeuCau_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."YEU_CAU_DANG_KY_MaYeuCau_seq" OWNED BY public."YEU_CAU_DANG_KY"."MaYeuCau";


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: BANG_DIEM MaBangDiem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BANG_DIEM" ALTER COLUMN "MaBangDiem" SET DEFAULT nextval('public."BANG_DIEM_MaBangDiem_seq"'::regclass);


--
-- Name: BUOI_HOC MaBuoiHoc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BUOI_HOC" ALTER COLUMN "MaBuoiHoc" SET DEFAULT nextval('public."BUOI_HOC_MaBuoiHoc_seq"'::regclass);


--
-- Name: DON_THU MaDon; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU" ALTER COLUMN "MaDon" SET DEFAULT nextval('public."DON_THU_MaDon_seq"'::regclass);


--
-- Name: DON_THU_PHAN_HOI MaPhanHoi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU_PHAN_HOI" ALTER COLUMN "MaPhanHoi" SET DEFAULT nextval('public."DON_THU_PHAN_HOI_MaPhanHoi_seq"'::regclass);


--
-- Name: GIANG_VIEN MaGiangVien; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GIANG_VIEN" ALTER COLUMN "MaGiangVien" SET DEFAULT nextval('public."GIANG_VIEN_MaGiangVien_seq"'::regclass);


--
-- Name: HOC_VIEN MaHocVien; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN" ALTER COLUMN "MaHocVien" SET DEFAULT nextval('public."HOC_VIEN_MaHocVien_seq"'::regclass);


--
-- Name: HOC_VIEN_LOP_HOC MaHV_LH; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN_LOP_HOC" ALTER COLUMN "MaHV_LH" SET DEFAULT nextval('public."HOC_VIEN_LOP_HOC_MaHV_LH_seq"'::regclass);


--
-- Name: KHOA_HOC MaKhoaHoc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KHOA_HOC" ALTER COLUMN "MaKhoaHoc" SET DEFAULT nextval('public."KHOA_HOC_MaKhoaHoc_seq"'::regclass);


--
-- Name: LICHSU_KHOA_DIEM MaLichSu; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LICHSU_KHOA_DIEM" ALTER COLUMN "MaLichSu" SET DEFAULT nextval('public."LICHSU_KHOA_DIEM_MaLichSu_seq"'::regclass);


--
-- Name: LOP_HOC MaLopHoc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LOP_HOC" ALTER COLUMN "MaLopHoc" SET DEFAULT nextval('public."LOP_HOC_MaLopHoc_seq"'::regclass);


--
-- Name: NGUOI_DUNG MaNguoiDung; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NGUOI_DUNG" ALTER COLUMN "MaNguoiDung" SET DEFAULT nextval('public."NGUOI_DUNG_MaNguoiDung_seq"'::regclass);


--
-- Name: PHONG_HOC MaPhongHoc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PHONG_HOC" ALTER COLUMN "MaPhongHoc" SET DEFAULT nextval('public."PHONG_HOC_MaPhongHoc_seq"'::regclass);


--
-- Name: PHU_HUYNH_HOC_VIEN MaPH_HV; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PHU_HUYNH_HOC_VIEN" ALTER COLUMN "MaPH_HV" SET DEFAULT nextval('public."PHU_HUYNH_HOC_VIEN_MaPH_HV_seq"'::regclass);


--
-- Name: TIEN_TRINH_KHOA_HOC MaTienTrinh; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIEN_TRINH_KHOA_HOC" ALTER COLUMN "MaTienTrinh" SET DEFAULT nextval('public."TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq"'::regclass);


--
-- Name: YEU_CAU_DANG_KY MaYeuCau; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YEU_CAU_DANG_KY" ALTER COLUMN "MaYeuCau" SET DEFAULT nextval('public."YEU_CAU_DANG_KY_MaYeuCau_seq"'::regclass);


--
-- Data for Name: BANG_DIEM; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BANG_DIEM" ("MaBangDiem", "MaLopHoc", "MaHocVien", "DiemChuyenCan", "DiemGiuaKy", "DiemCuoiKy", "DiemTongKet", "KetQua", "DaKhoaSo", "GhiChu", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
2	3	2	9	8.5	8	8.4	PASSED	f	Nắm rất chắc từ vựng kinh tế, làm phần Part 7 đọc hiểu xuất sắc.	2026-11-20 14:39:06.015656	2026-11-20 14:39:06.015657	f
3	3	4	8.5	7	7.5	7.6	PASSED	f	Tiến bộ rõ rệt ở kỹ năng nghe Part 3 và Part 4.	2026-11-20 14:39:06.015657	2026-11-20 14:39:06.015658	f
4	3	6	7.5	6.5	6	6.5	PASSED	f	Cần cải thiện ngữ pháp thì quá khứ hoàn thành và mệnh đề quan hệ.	2026-11-20 14:39:06.015658	2026-11-20 14:39:06.015658	f
5	4	3	10	8	8.5	8.6	PASSED	f	Khả năng Speaking trôi chảy, phản xạ tự nhiên, từ vựng phong phú.	2026-11-20 14:39:06.015659	2026-11-20 14:39:06.015659	f
6	4	7	9	7.5	8	8	PASSED	f	Bài luận Writing Task 2 mạch lạc, lập luận chặt chẽ.	2026-11-20 14:39:06.01566	2026-11-20 14:39:06.01566	f
7	5	5	9.5	8.5	9	8.9	PASSED	f	Tự tin tương tác nhóm, ngữ âm chuẩn và ghi nhớ từ vựng rất nhanh.	2026-11-20 14:39:06.015661	2026-11-20 14:39:06.015661	f
22	3	23	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
34	3	32	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
21	3	31	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
28	4	36	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
61	4	76	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
60	4	44	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
57	6	79	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
59	6	100	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
63	6	75	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
58	6	103	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
96	6	107	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
67	5	66	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
117	9	125	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
141	30	147	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
165	11	178	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
200	31	201	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
187	33	185	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
230	35	246	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
218	35	227	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
123	7	123	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
177	33	195	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
174	31	165	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
161	11	173	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
199	31	191	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
204	33	189	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
194	33	207	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
209	33	212	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
242	34	214	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
245	34	251	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
226	34	219	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
213	35	224	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
231	35	231	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
238	35	244	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
225	34	216	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
38	3	58	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
56	3	40	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
20	3	16	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
44	1	54	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
16	1	5	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
69	5	106	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
72	5	102	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
71	4	61	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
102	5	67	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
94	7	90	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
95	7	88	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
84	7	85	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
92	5	63	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
116	9	157	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
143	8	115	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
139	30	137	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
145	30	142	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
156	8	120	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
138	8	114	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
120	9	155	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
118	7	119	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
206	33	200	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
185	31	205	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
159	31	169	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
189	11	190	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
75	5	105	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
104	6	80	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
65	4	110	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
87	7	87	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
112	8	159	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
134	30	135	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
168	31	167	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
183	33	192	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
237	33	213	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
214	34	253	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
1	1	1	9.5	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	2026-11-20 14:39:06.015651	2026-11-20 14:39:06.015655	f
12	3	53	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
31	4	48	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
41	1	60	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
45	3	55	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
74	6	68	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
101	6	84	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
91	7	92	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
88	7	99	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
73	5	104	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
142	7	111	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
122	8	113	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
146	9	138	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
128	30	152	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
181	30	163	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
201	11	204	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
205	11	182	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
163	11	174	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
169	33	176	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
186	33	197	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
212	33	225	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
229	33	215	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
224	35	230	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
15	1	9	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
14	1	22	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
46	4	21	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
35	4	43	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
36	3	26	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
77	6	64	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
98	7	98	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
127	8	141	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
144	9	124	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
155	8	117	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
192	31	181	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
170	11	198	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
241	34	235	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
227	35	221	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
64	5	108	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
85	6	97	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
121	9	128	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
137	30	143	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
195	31	202	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
173	11	168	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
210	34	222	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
239	35	259	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
23	3	50	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
48	1	56	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
43	4	59	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
37	3	14	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
97	5	109	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
76	7	82	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
149	30	144	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
124	9	160	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
198	11	193	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
176	11	170	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
232	34	256	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
215	34	236	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
25	1	8	8.5	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
47	3	45	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
11	1	7	8.5	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
40	4	35	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
100	6	86	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
78	5	74	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
113	30	136	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
133	8	154	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
184	31	162	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
162	31	175	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
220	35	257	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
243	34	211	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
93	7	89	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
70	5	65	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
131	9	133	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
150	30	151	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
114	9	156	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
202	11	166	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
164	11	179	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
188	33	186	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
222	34	220	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
244	34	223	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
19	4	18	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
53	1	19	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
29	4	47	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
80	6	72	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
99	6	62	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
126	8	134	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
147	9	121	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
182	31	164	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
167	11	180	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
203	33	187	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
236	35	249	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
217	35	228	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
17	1	20	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
30	1	28	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
79	7	91	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
105	5	81	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
132	9	148	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
115	30	146	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
160	31	210	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
179	11	177	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
216	35	229	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
234	35	226	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
86	7	73	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
66	4	69	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
103	5	83	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
108	7	96	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
129	9	126	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
193	31	188	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
157	11	206	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
178	11	196	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
223	34	240	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
27	3	27	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
49	3	30	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
83	7	93	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
111	8	116	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
136	30	129	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
153	8	153	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
191	30	183	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
171	11	203	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
207	33	199	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
240	34	255	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
228	35	233	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
42	4	34	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
33	3	29	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
82	6	94	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
110	9	122	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
135	9	127	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
152	7	131	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
158	30	161	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
190	31	184	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
233	34	217	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
208	34	232	8	7.5	9	8.4	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
50	4	25	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
9	3	57	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
106	5	95	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
81	7	101	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
151	8	158	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
130	9	140	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
109	9	130	8	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
175	33	172	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
197	33	194	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
211	35	218	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
235	35	234	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
89	5	71	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
62	6	70	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
119	8	112	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
148	8	132	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
166	11	171	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
180	33	209	8.5	7.5	9	8.5	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
221	35	252	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
246	65	276	8.3	8.6	7.6	8.04	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
247	65	277	8.4	8.7	7.7	8.14	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
248	65	278	8.5	8.8	7.8	8.24	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
249	65	279	8.6	8.9	7.9	8.34	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
250	66	281	9.6	7.6	\N	4.2	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
251	66	282	9.7	7.7	\N	4.25	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
252	66	283	9.8	7.8	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
253	66	284	9.9	7.9	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
254	68	291	9.8	7.5	9.1	8.76	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
255	68	292	9.9	7.6	9.2	8.86	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
256	68	293	10	7.7	9.3	8.96	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
257	68	294	8	7.8	9.4	8.64	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
258	69	296	9.6	9.1	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
259	69	297	9.7	9.2	\N	4.7	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
260	69	298	9.8	9.3	\N	4.75	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
261	69	299	9.9	9.4	\N	4.8	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
262	71	306	9.2	9	7.6	8.34	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
263	71	307	9.3	9.1	7.7	8.44	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
264	71	308	9.4	9.2	7.8	8.54	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
265	71	309	9.5	9.3	7.9	8.64	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
266	72	311	9.6	8.6	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
267	72	312	9.7	8.7	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
268	72	313	9.8	8.8	\N	4.6	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
269	72	314	9.9	8.9	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
270	74	321	8.6	7.9	9.1	8.64	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
271	74	322	8.7	8	9.2	8.74	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
272	74	323	8.8	8.1	9.3	8.84	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
273	74	324	8.9	8.2	9.4	8.94	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
274	75	326	9.6	8.1	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
275	75	327	9.7	8.2	\N	4.4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
276	75	328	9.8	8.3	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
277	75	329	9.9	8.4	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
278	77	336	8	9.4	7.6	8.22	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
279	77	337	8.1	9.5	7.7	8.32	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
280	77	338	8.2	7	7.8	7.64	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
281	77	339	8.3	7.1	7.9	7.74	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
282	78	341	9.6	7.6	\N	4.2	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
283	78	342	9.7	7.7	\N	4.25	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
284	78	343	9.8	7.8	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
285	78	344	9.9	7.9	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
286	80	351	9.5	8.3	9.1	8.94	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
287	80	352	9.6	8.4	9.2	9.04	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
288	80	353	9.7	8.5	9.3	9.14	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
289	80	354	9.8	8.6	9.4	9.24	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
290	81	356	9.6	9.1	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
291	81	357	9.7	9.2	\N	4.7	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
292	81	358	9.8	9.3	\N	4.75	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
293	81	359	9.9	9.4	\N	4.8	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
294	83	6	9.1	8.1	\N	4.25	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
295	83	7	9.2	8.2	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
296	83	8	9.3	8.3	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
297	83	9	9.4	8.4	\N	4.4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
298	86	25	8.4	9.5	9.5	9.28	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
299	86	26	8.5	7	9.6	8.6	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
300	86	27	8.6	7.1	9.7	8.7	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
301	86	28	8.7	7.2	9.8	8.8	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
302	87	30	8.5	8.5	\N	4.25	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
303	87	31	8.6	8.6	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
304	87	32	8.7	8.7	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
305	87	34	8.9	8.9	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
306	89	43	9.8	7.8	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
307	89	44	9.9	7.9	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
308	89	45	8.5	8	\N	4.1	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
309	89	47	8.7	8.2	\N	4.2	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
310	91	56	9.6	9.1	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
311	91	57	9.7	9.2	\N	4.7	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
312	91	58	9.8	9.3	\N	4.75	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
313	91	59	9.9	9.4	\N	4.8	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
314	93	66	9.1	8.1	\N	4.25	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
315	93	67	9.2	8.2	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
316	93	68	9.3	8.3	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
317	93	69	9.4	8.4	\N	4.4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
318	95	76	8.6	9.1	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
319	95	77	8.7	9.2	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
320	95	78	8.8	9.3	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
321	95	79	8.9	9.4	\N	4.6	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
322	97	86	9.6	8.1	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
323	97	87	9.7	8.2	\N	4.4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
324	97	88	9.8	8.3	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
325	97	89	9.9	8.4	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
326	99	96	9.1	9.1	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
327	99	97	9.2	9.2	\N	4.6	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
328	99	98	9.3	9.3	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
329	99	99	9.4	9.4	\N	4.7	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
330	101	106	8.1	7.2	8.6	8.08	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
331	101	107	8.2	7.3	8.7	8.18	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
332	101	108	8.3	7.4	8.8	8.28	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
333	101	109	8.4	7.5	8.9	8.38	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
334	102	111	9.1	8.6	\N	4.4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
335	102	112	9.2	8.7	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
336	102	113	9.3	8.8	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
337	102	114	9.4	8.9	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
338	103	116	9.6	9.1	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
339	103	117	9.7	9.2	\N	4.7	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
340	103	118	9.8	9.3	\N	4.75	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
341	103	119	9.9	9.4	\N	4.8	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
342	105	126	8	9.2	7.6	8.16	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
343	105	127	8.1	9.3	7.7	8.26	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
344	105	128	8.2	9.4	7.8	8.36	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
345	105	129	8.3	9.5	7.9	8.46	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
346	106	131	9.6	8.6	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
347	106	132	9.7	8.7	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
348	106	133	9.8	8.8	\N	4.6	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
349	106	134	9.9	8.9	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
350	107	136	8.6	9.1	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
351	107	137	8.7	9.2	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
352	107	138	8.8	9.3	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
353	107	139	8.9	9.4	\N	4.6	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
354	109	146	10	8.6	9.6	9.38	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
355	109	147	8	8.7	9.7	9.06	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
90	6	78	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
68	5	77	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
140	8	150	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
107	8	139	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
125	8	118	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
154	8	149	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
172	30	145	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
196	31	208	9	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
219	35	254	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	\N	\N	f
356	109	148	8.1	8.8	9.8	9.16	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
357	109	149	8.2	8.9	9.9	9.26	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
358	110	151	8.6	8.6	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
359	110	152	8.7	8.7	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
360	110	153	8.8	8.8	\N	4.4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
361	110	154	8.9	8.9	\N	4.45	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
362	112	161	9.6	7.6	\N	4.2	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
363	112	162	9.7	7.7	\N	4.25	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
364	112	163	9.8	7.8	\N	4.3	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
365	112	164	9.9	7.9	\N	4.35	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
366	114	171	8.3	8.5	9.1	8.76	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
367	114	172	8.4	8.6	9.2	8.86	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
368	114	173	8.5	8.7	9.3	8.96	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
369	114	174	8.6	8.8	9.4	9.06	PASSED	t	Hoàn thành khóa học đạt chuẩn	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
370	115	176	9.6	9.1	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
371	115	177	9.7	9.2	\N	4.7	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
372	115	178	9.8	9.3	\N	4.75	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
373	115	179	9.9	9.4	\N	4.8	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
374	116	181	8.6	7.6	\N	4	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
375	116	182	8.7	7.7	\N	4.05	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
376	116	183	8.8	7.8	\N	4.1	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
377	116	184	8.9	7.9	\N	4.15	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
378	118	191	9.6	8.6	\N	4.5	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
379	118	192	9.7	8.7	\N	4.55	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
380	118	193	9.8	8.8	\N	4.6	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
381	118	194	9.9	8.9	\N	4.65	IN_PROGRESS	f	Đang theo học kỳ hiện tại	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
32	4	51	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
52	1	42	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
13	1	3	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
10	1	6	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
24	1	4	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
39	4	39	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
18	1	2	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
26	3	17	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
55	3	13	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
54	1	10	8.5	7.5	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
51	4	41	9.5	8	\N	\N	STUDYING	f	Đang học - Đánh giá quá trình	\N	\N	f
8	11	2	9.5	8	9.5	9.1	PASSED	t	Đã hoàn thành khóa học và cấp chứng chỉ	2026-11-20 14:39:06.015662	2026-11-20 14:39:06.015662	f
\.


--
-- Data for Name: BUOI_HOC; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BUOI_HOC" ("MaBuoiHoc", "MaLopHoc", "MaPhongHoc", "MaGiangVien", "NgayHoc", "GioBatDau", "GioKetThuc", "CaHoc", "DaXacNhan", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
2418	8	4	5	2026-11-26	08:00	10:00	Cuối tuần sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
2423	3	2	2	2026-11-22	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2428	9	10	6	2026-11-26	14:00	16:00	Cuối tuần chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
2433	7	16	6	2026-11-25	14:00	16:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
2419	6	15	7	2026-11-24	14:00	16:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
2424	8	4	5	2026-11-27	08:00	10:00	Cuối tuần sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
2429	6	15	7	2026-11-22	14:00	16:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
2434	3	2	2	2026-11-24	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2420	30	9	12	2026-11-23	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2425	4	6	3	2026-11-22	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2430	1	1	1	2026-11-23	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2435	9	10	6	2026-11-27	14:00	16:00	Cuối tuần chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
141	8	3	5	2026-11-21	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561776	2026-11-20 21:59:01.561777	f
142	8	3	5	2026-11-22	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561778	2026-11-20 21:59:01.561778	f
143	8	3	5	2026-11-28	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561781	2026-11-20 21:59:01.561781	f
144	8	3	5	2026-11-29	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561782	2026-11-20 21:59:01.561782	f
145	8	3	5	2026-12-05	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561785	2026-11-20 21:59:01.561785	f
146	8	3	5	2026-12-06	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561786	2026-11-20 21:59:01.561786	f
147	8	3	5	2026-12-12	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561789	2026-11-20 21:59:01.561789	f
148	8	3	5	2026-12-13	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.56179	2026-11-20 21:59:01.561791	f
149	8	3	5	2026-12-19	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561794	2026-11-20 21:59:01.561794	f
150	8	3	5	2026-12-20	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561795	2026-11-20 21:59:01.561795	f
151	8	3	5	2026-12-26	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561798	2026-11-20 21:59:01.561798	f
152	8	3	5	2026-12-27	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561799	2026-11-20 21:59:01.561799	f
153	8	3	5	2027-01-02	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561802	2026-11-20 21:59:01.561802	f
154	8	3	5	2027-01-03	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561803	2026-11-20 21:59:01.561804	f
155	8	3	5	2027-01-09	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561807	2026-11-20 21:59:01.561807	f
156	8	3	5	2027-01-10	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.561808	2026-11-20 21:59:01.561808	f
157	9	10	6	2026-11-21	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570129	2026-11-20 21:59:01.57013	f
158	9	10	6	2026-11-22	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570132	2026-11-20 21:59:01.570132	f
159	9	10	6	2026-11-28	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570136	2026-11-20 21:59:01.570136	f
160	9	10	6	2026-11-29	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570137	2026-11-20 21:59:01.570137	f
161	9	10	6	2026-12-05	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.57014	2026-11-20 21:59:01.57014	f
162	9	10	6	2026-12-06	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570141	2026-11-20 21:59:01.570141	f
163	9	10	6	2026-12-12	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570144	2026-11-20 21:59:01.570144	f
164	9	10	6	2026-12-13	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570145	2026-11-20 21:59:01.570145	f
165	9	10	6	2026-12-19	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570148	2026-11-20 21:59:01.570149	f
166	9	10	6	2026-12-20	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570149	2026-11-20 21:59:01.57015	f
167	9	10	6	2026-12-26	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570153	2026-11-20 21:59:01.570153	f
2421	5	5	4	2026-11-21	08:00	10:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
2426	1	1	1	2026-11-25	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2431	31	20	30	2026-11-22	08:00	10:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
2436	5	5	4	2026-11-23	08:00	10:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
1	1	1	1	2026-11-21	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972887	2026-11-20 14:39:05.972893	f
2	1	1	1	2026-11-23	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972894	2026-11-20 14:39:05.972895	f
3	1	1	1	2026-11-28	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972896	2026-11-20 14:39:05.972897	f
4	1	1	1	2026-11-30	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972898	2026-11-20 14:39:05.972898	f
8	4	5	3	2026-11-22	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972904	2026-11-20 14:39:05.972904	f
9	4	5	3	2026-11-24	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972905	2026-11-20 14:39:05.972906	f
10	4	5	3	2026-11-29	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972907	2026-11-20 14:39:05.972908	f
13	6	9	7	2026-11-22	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972912	2026-11-20 14:39:05.972913	f
14	6	9	7	2026-11-27	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 14:39:05.972914	2026-11-20 14:39:05.972915	f
21	1	1	1	2026-11-02	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.490094	2026-11-20 21:59:01.490097	f
22	1	1	1	2026-11-04	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.490103	2026-11-20 21:59:01.490104	f
23	1	1	1	2026-11-09	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.490109	2026-11-20 21:59:01.490109	f
24	1	1	1	2026-11-11	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.490112	2026-11-20 21:59:01.490112	f
25	1	1	1	2026-11-16	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.490116	2026-11-20 21:59:01.490117	f
26	1	1	1	2026-11-18	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.490119	2026-11-20 21:59:01.490119	f
27	1	1	1	2026-11-25	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490125	2026-11-20 21:59:01.490125	f
28	1	1	1	2026-12-02	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.49013	2026-11-20 21:59:01.490131	f
29	1	1	1	2026-12-07	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490135	2026-11-20 21:59:01.490135	f
248	30	9	12	2026-11-21	18:00	19:30	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
250	30	9	12	2026-11-23	18:00	19:30	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
252	3	2	2	2026-11-22	18:00	19:30	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
255	3	2	2	2026-11-24	18:00	19:30	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
251	5	5	4	2026-11-21	07:30	09:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
256	8	4	5	2026-11-27	07:30	09:00	Cuối tuần sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
257	31	20	30	2026-11-22	07:30	09:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
258	31	20	30	2026-11-24	07:30	09:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
249	7	16	6	2026-11-21	13:30	15:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
254	9	10	6	2026-11-27	13:30	15:00	Cuối tuần chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
253	6	15	7	2026-11-24	13:30	15:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
247	6	15	7	2026-11-22	13:30	15:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
30	1	1	1	2026-12-09	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490138	2026-11-20 21:59:01.490138	f
31	1	1	1	2026-12-14	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490142	2026-11-20 21:59:01.490142	f
32	1	1	1	2026-12-16	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490144	2026-11-20 21:59:01.490145	f
33	1	1	1	2026-12-21	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490149	2026-11-20 21:59:01.490149	f
34	1	1	1	2026-12-23	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490151	2026-11-20 21:59:01.490151	f
35	1	1	1	2026-12-28	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490155	2026-11-20 21:59:01.490155	f
36	1	1	1	2026-12-30	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490157	2026-11-20 21:59:01.490158	f
37	1	1	1	2027-01-04	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490162	2026-11-20 21:59:01.490162	f
38	1	1	1	2027-01-06	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490165	2026-11-20 21:59:01.490165	f
39	1	1	1	2027-01-11	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490169	2026-11-20 21:59:01.490169	f
40	1	1	1	2027-01-13	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490171	2026-11-20 21:59:01.490172	f
41	1	1	1	2027-01-18	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490181	2026-11-20 21:59:01.490182	f
42	1	1	1	2027-01-20	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.490184	2026-11-20 21:59:01.490184	f
60	4	5	3	2026-11-10	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.514386	2026-11-20 21:59:01.514387	f
61	4	5	3	2026-11-12	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.514394	2026-11-20 21:59:01.514395	f
62	4	5	3	2026-11-17	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.514397	2026-11-20 21:59:01.514398	f
63	4	5	3	2026-11-19	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.514399	2026-11-20 21:59:01.514399	f
64	4	5	3	2026-11-26	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514403	2026-11-20 21:59:01.514403	f
65	4	5	3	2026-12-01	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514406	2026-11-20 21:59:01.514406	f
66	4	5	3	2026-12-03	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514407	2026-11-20 21:59:01.514407	f
67	4	5	3	2026-12-08	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.51441	2026-11-20 21:59:01.51441	f
68	4	5	3	2026-12-10	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514411	2026-11-20 21:59:01.514412	f
69	4	5	3	2026-12-15	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514414	2026-11-20 21:59:01.514415	f
70	4	5	3	2026-12-17	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514416	2026-11-20 21:59:01.514416	f
71	4	5	3	2026-12-22	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514418	2026-11-20 21:59:01.514419	f
72	4	5	3	2026-12-24	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.51442	2026-11-20 21:59:01.51442	f
73	4	5	3	2026-12-29	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514423	2026-11-20 21:59:01.514423	f
74	4	5	3	2026-12-31	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514424	2026-11-20 21:59:01.514424	f
75	4	5	3	2027-01-05	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514427	2026-11-20 21:59:01.514427	f
76	4	5	3	2027-01-07	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514429	2026-11-20 21:59:01.514429	f
77	4	5	3	2027-01-12	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514432	2026-11-20 21:59:01.514432	f
78	4	5	3	2027-01-14	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514435	2026-11-20 21:59:01.514435	f
79	4	5	3	2027-01-19	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514438	2026-11-20 21:59:01.514438	f
80	4	5	3	2027-01-21	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514439	2026-11-20 21:59:01.51444	f
81	4	5	3	2027-01-26	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514442	2026-11-20 21:59:01.514442	f
82	4	5	3	2027-01-28	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514443	2026-11-20 21:59:01.514444	f
83	4	5	3	2027-02-02	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514446	2026-11-20 21:59:01.514446	f
84	4	5	3	2027-02-04	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514448	2026-11-20 21:59:01.514448	f
85	4	5	3	2027-02-09	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.514451	2026-11-20 21:59:01.514451	f
101	6	9	7	2026-11-13	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.537342	2026-11-20 21:59:01.537343	f
102	6	9	7	2026-11-16	18:00	19:30	Ca 3 (18:00 - 20:00)	t	COMPLETED	2026-11-20 21:59:01.537346	2026-11-20 21:59:01.537346	f
103	6	9	7	2026-11-20	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537348	2026-11-20 21:59:01.537348	f
104	6	9	7	2026-11-23	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.53735	2026-11-20 21:59:01.53735	f
105	6	9	7	2026-11-30	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537354	2026-11-20 21:59:01.537354	f
106	6	9	7	2026-12-04	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537356	2026-11-20 21:59:01.537357	f
107	6	9	7	2026-12-07	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537358	2026-11-20 21:59:01.537358	f
108	6	9	7	2026-12-11	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537361	2026-11-20 21:59:01.537361	f
109	6	9	7	2026-12-14	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537362	2026-11-20 21:59:01.537362	f
110	6	9	7	2026-12-18	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537365	2026-11-20 21:59:01.537365	f
111	6	9	7	2026-12-21	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537367	2026-11-20 21:59:01.537367	f
112	6	9	7	2026-12-25	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537369	2026-11-20 21:59:01.537369	f
113	6	9	7	2026-12-28	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537371	2026-11-20 21:59:01.537371	f
114	6	9	7	2027-01-01	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537373	2026-11-20 21:59:01.537373	f
115	6	9	7	2027-01-04	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537375	2026-11-20 21:59:01.537375	f
116	6	9	7	2027-01-08	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537377	2026-11-20 21:59:01.537378	f
117	6	9	7	2027-01-11	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537379	2026-11-20 21:59:01.537379	f
118	6	9	7	2027-01-15	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537382	2026-11-20 21:59:01.537382	f
119	6	9	7	2027-01-18	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537384	2026-11-20 21:59:01.537384	f
120	6	9	7	2027-01-22	18:00	19:30	Ca 3 (18:00 - 20:00)	t	SCHEDULED	2026-11-20 21:59:01.537386	2026-11-20 21:59:01.537386	f
11	5	6	4	2026-11-23	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 14:39:05.972909	2026-11-20 14:39:05.97291	f
12	5	6	4	2026-11-25	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 14:39:05.97291	2026-11-20 14:39:05.972911	f
17	8	3	5	2026-11-25	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 14:39:05.972919	2026-11-20 14:39:05.972919	f
18	8	3	5	2026-11-26	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 14:39:05.972921	2026-11-20 14:39:05.972922	f
86	5	6	4	2026-11-09	07:30	09:00	Ca 1 (08:00 - 10:00)	t	COMPLETED	2026-11-20 21:59:01.530279	2026-11-20 21:59:01.530281	f
87	5	6	4	2026-11-11	07:30	09:00	Ca 1 (08:00 - 10:00)	t	COMPLETED	2026-11-20 21:59:01.530283	2026-11-20 21:59:01.530283	f
88	5	6	4	2026-11-16	07:30	09:00	Ca 1 (08:00 - 10:00)	t	COMPLETED	2026-11-20 21:59:01.530286	2026-11-20 21:59:01.530287	f
89	5	6	4	2026-11-18	07:30	09:00	Ca 1 (08:00 - 10:00)	t	COMPLETED	2026-11-20 21:59:01.530288	2026-11-20 21:59:01.530288	f
90	5	6	4	2026-11-30	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530294	2026-11-20 21:59:01.530294	f
91	5	6	4	2026-12-02	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530295	2026-11-20 21:59:01.530296	f
92	5	6	4	2026-12-07	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530298	2026-11-20 21:59:01.530298	f
93	5	6	4	2026-12-09	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.5303	2026-11-20 21:59:01.5303	f
94	5	6	4	2026-12-14	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530302	2026-11-20 21:59:01.530302	f
95	5	6	4	2026-12-16	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530304	2026-11-20 21:59:01.530304	f
96	5	6	4	2026-12-21	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530307	2026-11-20 21:59:01.530307	f
97	5	6	4	2026-12-23	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530308	2026-11-20 21:59:01.530308	f
98	5	6	4	2026-12-28	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530311	2026-11-20 21:59:01.530311	f
99	5	6	4	2026-12-30	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530312	2026-11-20 21:59:01.530312	f
100	5	6	4	2027-01-04	07:30	09:00	Ca 1 (08:00 - 10:00)	t	SCHEDULED	2026-11-20 21:59:01.530315	2026-11-20 21:59:01.530315	f
140	8	3	5	2026-11-15	07:30	09:00	Ca 1 (08:00 - 10:00)	t	COMPLETED	2026-11-20 21:59:01.561764	2026-11-20 21:59:01.561766	f
5	3	2	2	2026-11-22	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972899	2026-11-20 14:39:05.9729	f
6	3	2	2	2026-11-24	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972901	2026-11-20 14:39:05.972901	f
7	3	2	2	2026-11-29	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972902	2026-11-20 14:39:05.972903	f
15	7	7	6	2026-11-24	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972915	2026-11-20 14:39:05.972916	f
16	7	7	6	2026-11-27	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972917	2026-11-20 14:39:05.972918	f
19	9	10	6	2026-11-25	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972923	2026-11-20 14:39:05.972923	f
20	9	10	6	2026-11-26	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 14:39:05.972924	2026-11-20 14:39:05.972925	f
43	3	2	2	2026-11-17	13:30	15:00	Ca 2 (14:00 - 16:00)	t	COMPLETED	2026-11-20 21:59:01.503752	2026-11-20 21:59:01.503754	f
44	3	2	2	2026-11-19	13:30	15:00	Ca 2 (14:00 - 16:00)	t	COMPLETED	2026-11-20 21:59:01.503757	2026-11-20 21:59:01.503757	f
45	3	2	2	2026-11-26	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503761	2026-11-20 21:59:01.503761	f
46	3	2	2	2026-12-01	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503764	2026-11-20 21:59:01.503764	f
47	3	2	2	2026-12-03	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503766	2026-11-20 21:59:01.503766	f
48	3	2	2	2026-12-08	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503768	2026-11-20 21:59:01.503769	f
49	3	2	2	2026-12-10	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.50377	2026-11-20 21:59:01.50377	f
50	3	2	2	2026-12-15	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503773	2026-11-20 21:59:01.503773	f
51	3	2	2	2026-12-17	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503774	2026-11-20 21:59:01.503774	f
52	3	2	2	2026-12-22	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503777	2026-11-20 21:59:01.503777	f
53	3	2	2	2026-12-24	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503779	2026-11-20 21:59:01.503779	f
54	3	2	2	2026-12-29	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503781	2026-11-20 21:59:01.503781	f
55	3	2	2	2026-12-31	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503783	2026-11-20 21:59:01.503783	f
56	3	2	2	2027-01-05	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503786	2026-11-20 21:59:01.503786	f
57	3	2	2	2027-01-07	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503787	2026-11-20 21:59:01.503787	f
58	3	2	2	2027-01-12	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.50379	2026-11-20 21:59:01.50379	f
59	3	2	2	2027-01-14	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.503791	2026-11-20 21:59:01.503791	f
121	7	7	6	2026-11-11	13:30	15:00	Ca 2 (14:00 - 16:00)	t	COMPLETED	2026-11-20 21:59:01.549638	2026-11-20 21:59:01.54964	f
122	7	7	6	2026-11-13	13:30	15:00	Ca 2 (14:00 - 16:00)	t	COMPLETED	2026-11-20 21:59:01.549642	2026-11-20 21:59:01.549642	f
123	7	7	6	2026-11-18	13:30	15:00	Ca 2 (14:00 - 16:00)	t	COMPLETED	2026-11-20 21:59:01.549645	2026-11-20 21:59:01.549645	f
124	7	7	6	2026-11-20	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549647	2026-11-20 21:59:01.549647	f
125	7	7	6	2026-11-25	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549649	2026-11-20 21:59:01.54965	f
126	7	7	6	2026-12-02	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549654	2026-11-20 21:59:01.549654	f
127	7	7	6	2026-12-04	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549655	2026-11-20 21:59:01.549656	f
128	7	7	6	2026-12-09	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549658	2026-11-20 21:59:01.549658	f
129	7	7	6	2026-12-11	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.54966	2026-11-20 21:59:01.54966	f
130	7	7	6	2026-12-16	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549663	2026-11-20 21:59:01.549663	f
131	7	7	6	2026-12-18	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549664	2026-11-20 21:59:01.549664	f
132	7	7	6	2026-12-23	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549667	2026-11-20 21:59:01.549667	f
133	7	7	6	2026-12-25	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549668	2026-11-20 21:59:01.549668	f
134	7	7	6	2026-12-30	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549671	2026-11-20 21:59:01.549671	f
135	7	7	6	2027-01-01	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549673	2026-11-20 21:59:01.549673	f
136	7	7	6	2027-01-06	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549676	2026-11-20 21:59:01.549676	f
137	7	7	6	2027-01-08	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549677	2026-11-20 21:59:01.549677	f
138	7	7	6	2027-01-13	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.54968	2026-11-20 21:59:01.54968	f
139	7	7	6	2027-01-15	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.549681	2026-11-20 21:59:01.549682	f
168	9	10	6	2026-12-27	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570154	2026-11-20 21:59:01.570154	f
169	9	10	6	2027-01-02	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570157	2026-11-20 21:59:01.570157	f
170	9	10	6	2027-01-03	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570158	2026-11-20 21:59:01.570158	f
171	9	10	6	2027-01-09	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570161	2026-11-20 21:59:01.570161	f
172	9	10	6	2027-01-10	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570162	2026-11-20 21:59:01.570162	f
173	9	10	6	2027-01-16	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570165	2026-11-20 21:59:01.570165	f
174	9	10	6	2027-01-17	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570166	2026-11-20 21:59:01.570166	f
175	9	10	6	2027-01-23	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570169	2026-11-20 21:59:01.570169	f
176	9	10	6	2027-01-24	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.57017	2026-11-20 21:59:01.57017	f
177	9	10	6	2027-01-30	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570174	2026-11-20 21:59:01.570174	f
178	9	10	6	2027-01-31	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570175	2026-11-20 21:59:01.570175	f
179	9	10	6	2027-02-06	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570178	2026-11-20 21:59:01.570178	f
180	9	10	6	2027-02-07	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570179	2026-11-20 21:59:01.570179	f
181	9	10	6	2027-02-13	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570188	2026-11-20 21:59:01.570188	f
182	9	10	6	2027-02-14	13:30	15:00	Ca 2 (14:00 - 16:00)	t	SCHEDULED	2026-11-20 21:59:01.570189	2026-11-20 21:59:01.57019	f
259	2	1	2	2026-11-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
260	2	1	2	2026-11-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
261	2	1	2	2026-12-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
262	2	1	2	2026-12-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
263	2	1	2	2026-12-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
264	2	1	2	2026-12-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
265	2	1	2	2026-12-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
266	2	1	2	2026-12-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
267	2	1	2	2026-12-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
268	2	1	2	2026-12-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
269	2	1	2	2026-12-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
270	2	1	2	2027-01-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
271	2	1	2	2027-01-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
272	2	1	2	2027-01-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
273	2	1	2	2027-01-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
274	2	1	2	2027-01-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
275	2	1	2	2027-01-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
276	2	1	2	2027-01-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
277	2	1	2	2027-01-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
278	2	1	2	2027-02-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
279	2	1	2	2027-02-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
280	2	1	2	2027-02-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
281	2	1	2	2027-02-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
282	2	1	2	2027-02-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
283	2	1	2	2027-02-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
284	3	1	3	2026-11-09	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
285	3	1	3	2026-11-11	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
286	3	1	3	2026-11-16	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
287	3	1	3	2026-11-18	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
288	3	1	3	2026-11-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
289	3	1	3	2026-11-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
290	3	1	3	2026-11-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
291	3	1	3	2026-12-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
292	3	1	3	2026-12-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
293	3	1	3	2026-12-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
294	3	1	3	2026-12-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
295	3	1	3	2026-12-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
296	3	1	3	2026-12-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
297	3	1	3	2026-12-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
298	3	1	3	2026-12-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
299	3	1	3	2026-12-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
300	3	1	3	2027-01-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
301	3	1	3	2027-01-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
302	3	1	3	2027-01-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
303	3	1	3	2027-01-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
304	4	1	4	2026-11-11	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
305	4	1	4	2026-11-16	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
306	4	1	4	2026-11-18	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
307	4	1	4	2026-11-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
308	4	1	4	2026-11-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
309	4	1	4	2026-11-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
310	4	1	4	2026-12-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
311	4	1	4	2026-12-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
312	4	1	4	2026-12-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
313	4	1	4	2026-12-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
314	4	1	4	2026-12-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
315	4	1	4	2026-12-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
316	4	1	4	2026-12-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
317	4	1	4	2026-12-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
318	4	1	4	2026-12-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
319	4	1	4	2027-01-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
320	4	1	4	2027-01-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
321	4	1	4	2027-01-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
322	4	1	4	2027-01-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
323	4	1	4	2027-01-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
324	4	1	4	2027-01-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
325	4	1	4	2027-01-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
326	4	1	4	2027-01-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
327	4	1	4	2027-02-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
328	4	1	4	2027-02-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
329	4	1	4	2027-02-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
330	4	1	4	2027-02-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
331	5	2	5	2027-01-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
332	5	2	5	2027-01-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
333	5	2	5	2027-01-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
334	5	2	5	2027-01-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
335	6	1	6	2026-11-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
336	6	1	6	2026-11-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
337	6	1	6	2026-12-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
338	6	1	6	2026-12-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
339	6	1	6	2026-12-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
340	6	1	6	2026-12-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
341	6	1	6	2026-12-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
342	6	1	6	2027-01-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
343	6	1	6	2027-01-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
344	6	1	6	2027-01-20	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
345	7	1	7	2026-11-10	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
346	7	1	7	2026-11-12	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
347	7	1	7	2026-11-17	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
348	7	1	7	2026-11-19	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
349	7	1	7	2026-11-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
350	7	1	7	2026-12-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
351	7	1	7	2026-12-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
352	7	1	7	2026-12-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
353	7	1	7	2026-12-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
354	7	1	7	2026-12-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
355	7	1	7	2026-12-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
356	7	1	7	2026-12-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
357	7	1	7	2026-12-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
358	7	1	7	2026-12-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
359	7	1	7	2026-12-31	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
360	7	1	7	2027-01-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
361	7	1	7	2027-01-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
362	7	1	7	2027-01-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
363	7	1	7	2027-01-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
364	8	1	8	2026-11-17	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
365	8	1	8	2026-11-19	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
366	8	1	8	2026-11-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
367	8	1	8	2026-12-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
368	8	1	8	2026-12-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
369	8	1	8	2026-12-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
370	8	1	8	2026-12-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
371	8	1	8	2026-12-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
372	8	1	8	2026-12-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
373	8	1	8	2026-12-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
374	8	1	8	2026-12-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
375	8	1	8	2026-12-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
376	8	1	8	2026-12-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
377	8	1	8	2027-01-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
378	8	1	8	2027-01-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
379	8	1	8	2027-01-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
380	8	1	8	2027-01-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
381	8	1	8	2027-01-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
382	8	1	8	2027-01-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
383	8	1	8	2027-01-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
384	8	1	8	2027-01-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
385	9	1	10	2026-11-19	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
386	9	1	10	2026-11-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
387	9	1	10	2026-12-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
388	9	1	10	2026-12-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
389	9	1	10	2026-12-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
390	9	1	10	2026-12-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
391	9	1	10	2026-12-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
392	9	1	10	2026-12-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
393	9	1	10	2026-12-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
394	9	1	10	2026-12-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
395	9	1	10	2026-12-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
396	9	1	10	2026-12-31	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
397	9	1	10	2027-01-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
398	9	1	10	2027-01-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
399	9	1	10	2027-01-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
400	9	1	10	2027-01-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
401	9	1	10	2027-01-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
402	9	1	10	2027-01-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
403	9	1	10	2027-01-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
404	9	1	10	2027-01-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
405	9	1	10	2027-02-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
406	9	1	10	2027-02-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
407	9	1	10	2027-02-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
408	9	1	10	2027-02-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
409	9	1	10	2027-02-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
410	9	1	10	2027-02-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
411	10	1	12	2026-12-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
412	10	1	12	2026-12-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
413	10	1	12	2026-12-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
414	10	1	12	2026-12-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
415	10	1	12	2026-12-29	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
416	10	1	12	2026-12-31	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
417	10	1	12	2027-01-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
418	10	1	12	2027-01-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
419	10	1	12	2027-01-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
420	10	1	12	2027-01-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
421	10	1	12	2027-01-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
422	10	1	12	2027-01-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
423	10	1	12	2027-01-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
424	10	1	12	2027-01-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
425	10	1	12	2027-02-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
426	10	1	12	2027-02-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
427	10	1	12	2027-02-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
428	10	1	12	2027-02-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
429	10	1	12	2027-02-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
430	10	1	12	2027-02-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
431	10	1	12	2027-02-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
432	10	1	12	2027-02-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
433	10	1	12	2027-03-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
434	10	1	12	2027-03-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
435	10	1	12	2027-03-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
436	10	1	12	2027-03-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
437	11	1	13	2026-08-18	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
438	11	1	13	2026-08-20	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
439	11	1	13	2026-08-25	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
440	11	1	13	2026-08-27	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
441	11	1	13	2026-09-01	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
442	11	1	13	2026-09-03	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
443	11	1	13	2026-09-08	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
444	11	1	13	2026-09-10	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
445	11	1	13	2026-09-15	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
446	11	1	13	2026-09-17	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
447	11	1	13	2026-09-22	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
448	11	1	13	2026-09-24	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
449	11	1	13	2026-09-29	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
450	11	1	13	2026-10-01	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
451	11	1	13	2026-10-06	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
452	11	1	13	2026-10-08	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
453	11	1	13	2026-10-13	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
454	11	1	13	2026-10-15	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
455	11	1	13	2026-10-20	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
456	11	1	13	2026-10-22	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
457	11	1	13	2026-10-27	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
458	11	1	13	2026-10-29	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
459	13	1	14	2026-12-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
460	13	1	14	2026-12-24	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
461	13	1	14	2026-12-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
462	13	1	14	2026-12-31	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
463	13	1	14	2027-01-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
464	13	1	14	2027-01-07	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
465	13	1	14	2027-01-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
466	13	1	14	2027-01-14	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
467	13	1	14	2027-01-19	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
468	13	1	14	2027-01-21	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
469	13	1	14	2027-01-26	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
470	13	1	14	2027-01-28	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
471	13	1	14	2027-02-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
472	13	1	14	2027-02-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
473	13	1	14	2027-02-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
474	13	1	14	2027-02-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
475	13	1	14	2027-02-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
476	13	1	14	2027-02-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
477	13	1	14	2027-02-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
478	13	1	14	2027-02-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
479	13	1	14	2027-03-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
480	13	1	14	2027-03-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
481	14	1	16	2027-01-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
482	14	1	16	2027-01-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
483	14	1	16	2027-01-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
484	14	1	16	2027-01-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
485	14	1	16	2027-01-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
486	14	1	16	2027-01-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
487	14	1	16	2027-01-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
488	14	1	16	2027-01-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
489	14	1	16	2027-02-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
490	14	1	16	2027-02-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
491	14	1	16	2027-02-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
492	14	1	16	2027-02-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
493	14	1	16	2027-02-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
494	14	1	16	2027-02-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
495	14	1	16	2027-02-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
496	14	1	16	2027-02-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
497	14	1	16	2027-03-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
498	14	1	16	2027-03-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
499	14	1	16	2027-03-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
500	14	1	16	2027-03-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
501	14	1	16	2027-03-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
502	14	1	16	2027-03-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
503	15	1	17	2027-01-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
504	15	1	17	2027-01-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
505	15	1	17	2027-01-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
506	15	1	17	2027-01-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
507	15	1	17	2027-01-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
508	15	1	17	2027-01-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
509	15	1	17	2027-02-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
510	15	1	17	2027-02-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
511	15	1	17	2027-02-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
512	15	1	17	2027-02-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
513	15	1	17	2027-02-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
514	15	1	17	2027-02-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
515	15	1	17	2027-02-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
516	15	1	17	2027-02-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
517	15	1	17	2027-03-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
518	15	1	17	2027-03-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
519	15	1	17	2027-03-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
520	15	1	17	2027-03-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
521	15	1	17	2027-03-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
522	15	1	17	2027-03-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
523	15	1	17	2027-03-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
524	17	1	18	2026-11-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
525	17	1	18	2026-12-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
526	17	1	18	2026-12-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
527	17	1	18	2026-12-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
528	17	1	18	2026-12-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
529	17	1	18	2026-12-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
530	17	1	18	2026-12-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
531	17	1	18	2026-12-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
532	17	1	18	2026-12-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
533	17	1	18	2027-01-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
534	17	1	18	2027-01-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
535	17	1	18	2027-01-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
536	17	1	18	2027-01-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
537	17	1	18	2027-01-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
538	17	1	18	2027-01-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
539	17	1	18	2027-01-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
540	17	1	18	2027-01-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
541	17	1	18	2027-01-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
542	17	1	18	2027-01-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
543	17	1	18	2027-02-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
544	17	1	18	2027-02-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
545	18	1	19	2026-12-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
546	18	1	19	2026-12-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
547	18	1	19	2026-12-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
548	18	1	19	2026-12-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
549	18	1	19	2026-12-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
550	18	1	19	2026-12-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
551	18	1	19	2026-12-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
552	18	1	19	2026-12-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
553	18	1	19	2027-01-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
554	18	1	19	2027-01-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
555	18	1	19	2027-01-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
556	18	1	19	2027-01-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
557	18	1	19	2027-01-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
558	18	1	19	2027-01-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
559	18	1	19	2027-01-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
560	18	1	19	2027-01-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
561	18	1	19	2027-01-29	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
562	18	1	19	2027-01-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
563	18	1	19	2027-02-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
564	18	1	19	2027-02-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
565	18	1	19	2027-02-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
566	18	1	19	2027-02-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
567	19	1	21	2026-12-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
568	19	1	21	2026-12-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
569	19	1	21	2026-12-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
570	19	1	21	2026-12-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
571	19	1	21	2026-12-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
572	19	1	21	2026-12-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
573	19	1	21	2026-12-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
574	19	1	21	2027-01-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
575	19	1	21	2027-01-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
576	19	1	21	2027-01-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
577	19	1	21	2027-01-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
578	19	1	21	2027-01-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
579	19	1	21	2027-01-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
580	19	1	21	2027-01-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
581	19	1	21	2027-01-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
582	19	1	21	2027-01-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
583	19	1	21	2027-01-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
584	19	1	21	2027-02-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
585	19	1	21	2027-02-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
586	19	1	21	2027-02-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
587	19	1	21	2027-02-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
588	20	1	22	2026-12-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
589	20	1	22	2026-12-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
590	20	1	22	2026-12-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
591	20	1	22	2026-12-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
592	20	1	22	2026-12-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
593	20	1	22	2026-12-19	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
594	20	1	22	2026-12-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
595	20	1	22	2026-12-26	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
596	20	1	22	2027-01-01	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
597	20	1	22	2027-01-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
598	20	1	22	2027-01-08	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
599	20	1	22	2027-01-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
600	20	1	22	2027-01-15	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
601	20	1	22	2027-01-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
602	20	1	22	2027-01-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
603	20	1	22	2027-01-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
604	20	1	22	2027-01-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
605	20	1	22	2027-01-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
606	20	1	22	2027-02-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
607	20	1	22	2027-02-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
608	20	1	22	2027-02-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
609	20	1	22	2027-02-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
610	21	1	23	2026-12-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
611	21	1	23	2026-12-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
612	21	1	23	2026-12-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
613	21	1	23	2027-01-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
614	21	1	23	2027-01-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
615	21	1	23	2027-01-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
616	21	1	23	2027-01-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
617	21	1	23	2027-01-31	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
618	21	1	23	2027-02-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
619	21	1	23	2027-02-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
620	21	1	23	2027-02-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
621	21	1	23	2027-02-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
622	21	1	23	2027-03-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
623	30	1	24	2026-11-08	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
624	30	1	24	2026-11-15	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
625	30	1	24	2026-11-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
626	30	1	24	2026-11-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
627	30	1	24	2026-12-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
628	30	1	24	2026-12-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
629	30	1	24	2026-12-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
630	30	1	24	2026-12-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
631	30	1	24	2027-01-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
632	30	1	24	2027-01-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
633	31	1	25	2026-11-08	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
634	31	1	25	2026-11-15	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
635	31	1	25	2026-11-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
636	31	1	25	2026-12-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
637	31	1	25	2026-12-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
638	31	1	25	2026-12-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
639	31	1	25	2026-12-27	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
640	31	1	25	2027-01-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
641	31	1	25	2027-01-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
642	31	1	25	2027-01-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
643	33	1	26	2026-08-02	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
644	33	1	26	2026-08-09	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
645	33	1	26	2026-08-16	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
646	33	1	26	2026-08-23	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
647	33	1	26	2026-08-30	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
648	33	1	26	2026-09-06	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
649	33	1	26	2026-09-13	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
650	33	1	26	2026-09-20	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
651	33	1	26	2026-09-27	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
652	33	1	26	2026-10-04	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
653	33	1	26	2026-10-11	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
654	34	1	27	2026-08-16	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
655	34	1	27	2026-08-23	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
656	34	1	27	2026-08-30	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
657	34	1	27	2026-09-06	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
658	34	1	27	2026-09-13	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
659	34	1	27	2026-09-20	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
660	34	1	27	2026-09-27	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
661	34	1	27	2026-10-04	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
662	34	1	27	2026-10-11	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
663	34	1	27	2026-10-18	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
664	35	1	29	2026-07-26	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
665	35	1	29	2026-08-02	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
666	35	1	29	2026-08-09	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
667	35	1	29	2026-08-16	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
668	35	1	29	2026-08-23	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
669	35	1	29	2026-08-30	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
670	35	1	29	2026-09-06	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
671	35	1	29	2026-09-13	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
672	35	1	29	2026-09-20	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
673	35	1	29	2026-09-27	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
674	36	2	8	2026-11-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
675	36	2	8	2026-12-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
676	36	2	8	2026-12-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
677	36	2	8	2026-12-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
678	36	2	8	2026-12-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
679	36	2	8	2026-12-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
680	36	2	8	2026-12-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
681	36	2	8	2026-12-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
682	36	2	8	2026-12-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
683	36	2	8	2026-12-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
684	36	2	8	2027-01-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
685	36	2	8	2027-01-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
686	36	2	8	2027-01-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
687	36	2	8	2027-01-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
688	36	2	8	2027-01-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
689	36	2	8	2027-01-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
690	36	2	8	2027-01-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
691	36	2	8	2027-01-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
692	36	2	8	2027-02-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
693	36	2	8	2027-02-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
694	36	2	8	2027-02-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
695	36	2	8	2027-02-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
696	37	2	10	2026-11-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
697	37	2	10	2026-12-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
698	37	2	10	2026-12-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
699	37	2	10	2026-12-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
700	37	2	10	2026-12-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
701	37	2	10	2026-12-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
702	37	2	10	2026-12-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
703	37	2	10	2026-12-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
704	37	2	10	2026-12-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
705	37	2	10	2026-12-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
706	37	2	10	2027-01-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
707	37	2	10	2027-01-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
708	37	2	10	2027-01-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
709	37	2	10	2027-01-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
710	37	2	10	2027-01-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
711	37	2	10	2027-01-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
712	37	2	10	2027-01-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
713	37	2	10	2027-01-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
714	37	2	10	2027-02-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
715	37	2	10	2027-02-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
716	37	2	10	2027-02-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
717	37	2	10	2027-02-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
718	38	2	12	2026-11-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
719	38	2	12	2026-12-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
720	38	2	12	2026-12-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
721	38	2	12	2026-12-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
722	38	2	12	2026-12-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
723	38	2	12	2026-12-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
724	38	2	12	2026-12-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
725	38	2	12	2026-12-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
726	38	2	12	2026-12-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
727	38	2	12	2026-12-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
728	38	2	12	2027-01-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
729	38	2	12	2027-01-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
730	38	2	12	2027-01-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
731	38	2	12	2027-01-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
732	38	2	12	2027-01-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
733	38	2	12	2027-01-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
734	38	2	12	2027-01-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
735	38	2	12	2027-01-27	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
736	38	2	12	2027-02-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
737	38	2	12	2027-02-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
738	38	2	12	2027-02-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
739	38	2	12	2027-02-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
740	39	2	13	2026-11-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
741	39	2	13	2026-12-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
742	39	2	13	2026-12-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
743	39	2	13	2026-12-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
744	39	2	13	2026-12-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
745	39	2	13	2026-12-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
746	39	2	13	2026-12-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
747	39	2	13	2026-12-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
748	39	2	13	2026-12-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
749	39	2	13	2026-12-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
750	39	2	13	2027-01-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
751	39	2	13	2027-01-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
752	39	2	13	2027-01-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
753	39	2	13	2027-01-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
754	39	2	13	2027-01-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
755	39	2	13	2027-01-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
756	39	2	13	2027-01-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
757	39	2	13	2027-01-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
758	39	2	13	2027-02-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
759	39	2	13	2027-02-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
760	39	2	13	2027-02-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
761	39	2	13	2027-02-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
762	40	2	14	2026-11-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
763	40	2	14	2026-12-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
764	40	2	14	2026-12-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
765	40	2	14	2026-12-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
766	40	2	14	2026-12-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
767	40	2	14	2026-12-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
768	40	2	14	2026-12-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
769	40	2	14	2026-12-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
770	40	2	14	2026-12-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
771	40	2	14	2026-12-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
772	40	2	14	2027-01-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
773	40	3	14	2027-01-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
774	40	3	14	2027-01-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
775	40	3	14	2027-01-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
776	40	3	14	2027-01-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
777	40	2	14	2027-01-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
778	40	2	14	2027-01-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
779	40	2	14	2027-01-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
780	40	2	14	2027-02-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
781	40	2	14	2027-02-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
782	40	2	14	2027-02-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
783	40	2	14	2027-02-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
784	41	2	16	2026-11-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
785	41	2	16	2026-12-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
786	41	2	16	2026-12-07	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
787	41	2	16	2026-12-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
788	41	2	16	2026-12-14	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
789	41	2	16	2026-12-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
790	41	2	16	2026-12-21	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
791	41	2	16	2026-12-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
792	41	2	16	2026-12-28	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
793	41	2	16	2026-12-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
794	41	2	16	2027-01-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
795	41	2	16	2027-01-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
796	41	2	16	2027-01-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
797	41	2	16	2027-01-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
798	41	2	16	2027-01-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
799	41	2	16	2027-01-20	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
800	41	2	16	2027-01-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
801	41	2	16	2027-01-27	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
802	41	2	16	2027-02-01	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
803	41	2	16	2027-02-03	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
804	41	2	16	2027-02-08	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
805	41	2	16	2027-02-10	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
806	42	2	17	2026-12-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
807	42	2	17	2026-12-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
808	42	2	17	2026-12-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
809	42	2	17	2026-12-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
810	42	2	17	2026-12-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
811	42	2	17	2026-12-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
812	42	2	17	2026-12-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
813	42	2	17	2026-12-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
814	42	2	17	2026-12-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
815	42	2	17	2026-12-31	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
816	42	2	17	2027-01-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
817	42	2	17	2027-01-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
818	42	2	17	2027-01-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
819	42	2	17	2027-01-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
820	42	2	17	2027-01-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
821	42	2	17	2027-01-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
822	42	2	17	2027-01-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
823	42	2	17	2027-01-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
824	42	2	17	2027-02-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
825	42	2	17	2027-02-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
826	42	2	17	2027-02-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
827	42	2	17	2027-02-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
828	43	2	18	2026-12-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
829	43	2	18	2026-12-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
830	43	2	18	2026-12-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
831	43	2	18	2026-12-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
832	43	2	18	2026-12-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
833	43	2	18	2026-12-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
834	43	2	18	2026-12-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
835	43	2	18	2026-12-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
836	43	2	18	2026-12-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
837	43	2	18	2026-12-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
838	43	2	18	2027-01-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
839	43	2	18	2027-01-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
840	43	2	18	2027-01-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
841	43	2	18	2027-01-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
842	43	2	18	2027-01-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
843	43	2	18	2027-01-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
844	43	2	18	2027-01-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
845	43	2	18	2027-01-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
846	43	2	18	2027-02-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
847	43	2	18	2027-02-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
848	43	2	18	2027-02-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
849	43	2	18	2027-02-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
850	44	3	19	2026-12-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
851	44	3	19	2026-12-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
852	44	3	19	2026-12-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
853	44	3	19	2026-12-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
854	44	3	19	2026-12-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
855	44	3	19	2026-12-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
856	44	3	19	2026-12-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
857	44	3	19	2026-12-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
858	44	3	19	2026-12-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
859	44	3	19	2026-12-31	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
860	44	3	19	2027-01-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
861	44	3	19	2027-01-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
862	44	3	19	2027-01-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
863	44	3	19	2027-01-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
864	44	2	19	2027-01-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
865	44	2	19	2027-01-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
866	44	2	19	2027-01-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
867	44	2	19	2027-01-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
868	44	2	19	2027-02-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
869	44	2	19	2027-02-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
870	44	2	19	2027-02-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
871	44	2	19	2027-02-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
872	45	2	21	2026-12-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
873	45	2	21	2026-12-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
874	45	2	21	2026-12-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
875	45	2	21	2026-12-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
876	45	2	21	2026-12-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
877	45	2	21	2026-12-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
878	45	2	21	2026-12-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
879	45	2	21	2026-12-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
880	45	2	21	2026-12-29	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
881	45	2	21	2026-12-31	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
882	45	2	21	2027-01-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
883	45	2	21	2027-01-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
884	45	2	21	2027-01-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
885	45	2	21	2027-01-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
886	45	2	21	2027-01-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
887	45	2	21	2027-01-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
888	45	2	21	2027-01-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
889	45	2	21	2027-01-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
890	45	2	21	2027-02-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
891	45	2	21	2027-02-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
892	45	2	21	2027-02-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
893	45	2	21	2027-02-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
894	46	2	22	2026-12-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
895	46	2	22	2026-12-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
896	46	2	22	2026-12-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
897	46	2	22	2026-12-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
898	46	2	22	2026-12-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
899	46	2	22	2026-12-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
900	46	2	22	2026-12-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
901	46	2	22	2026-12-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
902	46	2	22	2026-12-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
903	46	2	22	2026-12-31	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
904	46	2	22	2027-01-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
905	46	2	22	2027-01-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
906	46	2	22	2027-01-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
907	46	2	22	2027-01-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
908	46	2	22	2027-01-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
909	46	2	22	2027-01-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
910	46	2	22	2027-01-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
911	46	2	22	2027-01-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
912	46	2	22	2027-02-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
913	46	2	22	2027-02-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
914	46	2	22	2027-02-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
915	46	2	22	2027-02-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
916	47	2	23	2026-12-01	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
917	47	2	23	2026-12-03	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
918	47	2	23	2026-12-08	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
919	47	2	23	2026-12-10	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
920	47	2	23	2026-12-15	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
921	47	2	23	2026-12-17	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
922	47	2	23	2026-12-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
923	47	2	23	2026-12-24	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
924	47	2	23	2026-12-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
925	47	2	23	2026-12-31	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
926	47	2	23	2027-01-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
927	47	2	23	2027-01-07	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
928	47	2	23	2027-01-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
929	47	2	23	2027-01-14	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
930	47	2	23	2027-01-19	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
931	47	2	23	2027-01-21	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
932	47	2	23	2027-01-26	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
933	47	2	23	2027-01-28	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
934	47	2	23	2027-02-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
935	47	2	23	2027-02-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
936	47	2	23	2027-02-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
937	47	2	23	2027-02-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
938	48	2	24	2026-12-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
939	48	2	24	2026-12-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
940	48	2	24	2026-12-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
941	48	2	24	2026-12-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
942	48	2	24	2026-12-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
943	48	2	24	2026-12-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
944	48	2	24	2026-12-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
945	48	2	24	2026-12-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
946	48	2	24	2027-01-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
947	48	2	24	2027-01-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
948	48	2	24	2027-01-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
949	48	2	24	2027-01-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
950	48	2	24	2027-01-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
951	48	2	24	2027-01-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
952	48	2	24	2027-01-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
953	48	2	24	2027-01-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
954	48	2	24	2027-01-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
955	48	2	24	2027-01-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
956	48	2	24	2027-02-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
957	48	2	24	2027-02-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
958	48	2	24	2027-02-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
959	48	2	24	2027-02-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
960	49	2	25	2026-12-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
961	49	2	25	2026-12-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
962	49	2	25	2026-12-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
963	49	2	25	2026-12-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
964	49	2	25	2026-12-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
965	49	2	25	2026-12-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
966	49	2	25	2026-12-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
967	49	2	25	2026-12-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
968	49	2	25	2027-01-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
969	49	2	25	2027-01-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
970	49	2	25	2027-01-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
971	49	2	25	2027-01-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
972	49	2	25	2027-01-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
973	49	2	25	2027-01-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
974	49	2	25	2027-01-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
975	49	2	25	2027-01-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
976	49	2	25	2027-01-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
977	49	2	25	2027-01-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
978	49	2	25	2027-02-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
979	49	2	25	2027-02-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
980	49	2	25	2027-02-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
981	49	2	25	2027-02-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
982	50	2	26	2026-12-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
983	50	2	26	2026-12-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
984	50	2	26	2026-12-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
985	50	2	26	2026-12-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
986	50	2	26	2026-12-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
987	50	2	26	2026-12-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
988	50	2	26	2026-12-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
989	50	2	26	2026-12-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
990	50	2	26	2027-01-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
991	50	2	26	2027-01-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
992	50	2	26	2027-01-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
993	50	2	26	2027-01-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
994	50	2	26	2027-01-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
995	50	2	26	2027-01-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
996	50	2	26	2027-01-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
997	50	2	26	2027-01-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
998	50	2	26	2027-01-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
999	50	2	26	2027-01-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1000	50	2	26	2027-02-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1001	50	2	26	2027-02-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1002	50	2	26	2027-02-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1003	50	2	26	2027-02-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1004	51	2	27	2026-12-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1005	51	2	27	2026-12-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1006	51	2	27	2026-12-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1007	51	2	27	2026-12-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1008	51	2	27	2026-12-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1009	51	2	27	2026-12-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1010	51	2	27	2026-12-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1011	51	2	27	2026-12-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1012	51	2	27	2027-01-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1013	51	2	27	2027-01-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1014	51	2	27	2027-01-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1015	51	2	27	2027-01-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1016	51	2	27	2027-01-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1017	51	2	27	2027-01-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1018	51	2	27	2027-01-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1019	51	2	27	2027-01-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1020	51	2	27	2027-01-29	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1021	51	2	27	2027-01-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1022	51	2	27	2027-02-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1023	51	2	27	2027-02-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1024	51	2	27	2027-02-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1025	51	2	27	2027-02-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1026	52	2	29	2026-12-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1027	52	2	29	2026-12-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1028	52	2	29	2026-12-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1029	52	2	29	2026-12-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1030	52	2	29	2026-12-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1031	52	2	29	2026-12-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1032	52	2	29	2026-12-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1033	52	2	29	2026-12-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1034	52	2	29	2027-01-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1035	52	2	29	2027-01-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1036	52	2	29	2027-01-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1037	52	2	29	2027-01-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1038	52	2	29	2027-01-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1039	52	2	29	2027-01-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1040	52	2	29	2027-01-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1041	52	2	29	2027-01-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1042	52	2	29	2027-01-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1043	52	2	29	2027-01-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1044	52	2	29	2027-02-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1045	52	2	29	2027-02-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1046	52	2	29	2027-02-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1047	52	2	29	2027-02-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1048	53	2	30	2026-12-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1049	53	2	30	2026-12-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1050	53	2	30	2026-12-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1051	53	2	30	2026-12-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1052	53	2	30	2026-12-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1053	53	2	30	2026-12-19	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1054	53	2	30	2026-12-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1055	53	2	30	2026-12-26	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1056	53	2	30	2027-01-01	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1057	53	2	30	2027-01-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1058	53	2	30	2027-01-08	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1059	53	2	30	2027-01-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1060	53	2	30	2027-01-15	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1061	53	2	30	2027-01-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1062	53	2	30	2027-01-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1063	53	2	30	2027-01-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1064	53	2	30	2027-01-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1065	53	2	30	2027-01-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1066	53	2	30	2027-02-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1067	53	2	30	2027-02-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1068	53	2	30	2027-02-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1069	53	2	30	2027-02-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1070	54	2	31	2026-12-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1071	54	2	31	2026-12-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1072	54	2	31	2026-12-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1073	54	2	31	2026-12-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1074	54	2	31	2027-01-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1075	54	2	31	2027-01-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1076	54	2	31	2027-01-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1077	54	2	31	2027-01-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1078	54	2	31	2027-01-31	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1079	54	2	31	2027-02-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1080	55	2	32	2026-12-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1081	55	2	32	2026-12-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1082	55	2	32	2026-12-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1083	55	2	32	2026-12-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1084	55	2	32	2027-01-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1085	55	2	32	2027-01-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1086	55	2	32	2027-01-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1087	55	2	32	2027-01-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1088	55	2	32	2027-01-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1089	55	2	32	2027-02-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1090	56	2	33	2026-12-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1091	56	2	33	2026-12-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1092	56	2	33	2026-12-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1093	56	2	33	2026-12-27	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1094	56	2	33	2027-01-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1095	56	2	33	2027-01-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1096	56	2	33	2027-01-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1097	56	2	33	2027-01-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1098	56	2	33	2027-01-31	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1099	56	2	33	2027-02-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1100	57	2	34	2026-12-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1101	57	2	34	2026-12-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1102	57	2	34	2026-12-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1103	57	2	34	2026-12-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1104	57	2	34	2027-01-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1105	57	2	34	2027-01-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1106	57	2	34	2027-01-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1107	57	2	34	2027-01-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1108	57	2	34	2027-01-31	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1109	57	2	34	2027-02-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1110	58	2	35	2026-12-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1111	58	2	35	2026-12-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1112	58	2	35	2026-12-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1113	58	2	35	2026-12-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1114	58	2	35	2027-01-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1115	58	2	35	2027-01-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1116	58	2	35	2027-01-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1117	58	2	35	2027-01-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1118	58	2	35	2027-01-31	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1119	58	2	35	2027-02-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1120	59	2	38	2026-12-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1121	59	2	38	2026-12-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1122	59	2	38	2026-12-20	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1123	59	2	38	2026-12-27	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1124	59	2	38	2027-01-03	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1125	59	2	38	2027-01-10	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1126	59	2	38	2027-01-17	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1127	59	2	38	2027-01-24	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1128	59	2	38	2027-01-31	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1129	59	2	38	2027-02-07	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1130	60	3	18	2026-11-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1131	60	3	18	2026-12-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1132	60	3	18	2026-12-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1133	60	3	18	2026-12-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1134	60	3	18	2026-12-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1135	60	3	18	2026-12-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1136	60	3	18	2026-12-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1137	60	3	18	2026-12-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1138	60	3	18	2026-12-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1139	60	3	18	2026-12-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1140	60	3	18	2027-01-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1141	60	3	18	2027-01-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1142	60	3	18	2027-01-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1143	60	3	18	2027-01-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1144	60	3	18	2027-01-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1145	60	3	18	2027-01-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1146	60	3	18	2027-01-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1147	60	3	18	2027-01-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1148	60	3	18	2027-02-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1149	60	3	18	2027-02-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1150	60	3	18	2027-02-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1151	60	3	18	2027-02-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1152	61	3	19	2026-11-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1153	61	3	19	2026-12-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1154	61	3	19	2026-12-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1155	61	3	19	2026-12-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1156	61	3	19	2026-12-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1157	61	3	19	2026-12-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1158	61	3	19	2026-12-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1159	61	3	19	2026-12-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1160	61	3	19	2026-12-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1161	61	3	19	2026-12-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1162	61	3	19	2027-01-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1163	61	3	19	2027-01-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1164	61	3	19	2027-01-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1165	61	3	19	2027-01-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1166	61	3	19	2027-01-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1167	61	3	19	2027-01-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1168	61	3	19	2027-01-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1169	61	3	19	2027-01-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1170	61	3	19	2027-02-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1171	61	3	19	2027-02-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1172	61	3	19	2027-02-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1173	61	3	19	2027-02-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1174	62	3	21	2026-11-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1175	62	3	21	2026-12-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1176	62	3	21	2026-12-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1177	62	3	21	2026-12-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1178	62	3	21	2026-12-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1179	62	3	21	2026-12-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1180	62	3	21	2026-12-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1181	62	3	21	2026-12-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1182	62	3	21	2026-12-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1183	62	3	21	2026-12-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1184	62	3	21	2027-01-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1185	62	3	21	2027-01-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1186	62	3	21	2027-01-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1187	62	3	21	2027-01-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1188	62	3	21	2027-01-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1189	62	3	21	2027-01-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1190	62	3	21	2027-01-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1191	62	3	21	2027-01-27	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1192	62	3	21	2027-02-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1193	62	3	21	2027-02-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1194	62	3	21	2027-02-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1195	62	3	21	2027-02-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1196	63	3	22	2026-11-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1197	63	3	22	2026-12-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1198	63	3	22	2026-12-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1199	63	3	22	2026-12-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1200	63	3	22	2026-12-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1201	63	3	22	2026-12-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1202	63	3	22	2026-12-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1203	63	3	22	2026-12-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1204	63	3	22	2026-12-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1205	63	3	22	2026-12-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1206	63	3	22	2027-01-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1207	63	3	22	2027-01-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1208	63	3	22	2027-01-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1209	63	3	22	2027-01-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1210	63	3	22	2027-01-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1211	63	3	22	2027-01-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1212	63	3	22	2027-01-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1213	63	3	22	2027-01-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1214	63	3	22	2027-02-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1215	63	3	22	2027-02-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1216	63	3	22	2027-02-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1217	63	3	22	2027-02-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1218	64	3	23	2026-11-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1219	64	3	23	2026-12-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1220	64	3	23	2026-12-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1221	64	3	23	2026-12-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1222	64	3	23	2026-12-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1223	64	3	23	2026-12-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1224	64	3	23	2026-12-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1225	64	3	23	2026-12-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1226	64	3	23	2026-12-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1227	64	3	23	2026-12-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1228	64	3	23	2027-01-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1229	64	4	23	2027-01-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1230	64	4	23	2027-01-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1231	64	4	23	2027-01-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1232	64	4	23	2027-01-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1233	64	3	23	2027-01-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1234	64	3	23	2027-01-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1235	64	3	23	2027-01-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1236	64	3	23	2027-02-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1237	64	3	23	2027-02-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1238	64	3	23	2027-02-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1239	64	3	23	2027-02-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1240	65	3	24	2026-06-01	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1241	65	3	24	2026-06-03	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1242	65	3	24	2026-06-08	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1243	65	3	24	2026-06-10	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1244	65	3	24	2026-06-15	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1245	65	3	24	2026-06-17	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1246	65	3	24	2026-06-22	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1247	65	3	24	2026-06-24	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1248	65	3	24	2026-06-29	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1249	65	3	24	2026-07-01	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1250	65	3	24	2026-07-06	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1251	65	3	24	2026-07-08	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1252	65	3	24	2026-07-13	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1253	65	3	24	2026-07-15	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1254	65	3	24	2026-07-20	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1255	65	3	24	2026-07-22	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1256	65	3	24	2026-07-27	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1257	65	3	24	2026-07-29	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1258	65	3	24	2026-08-03	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1259	65	3	24	2026-08-05	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1260	65	3	24	2026-08-10	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1261	65	3	24	2026-08-12	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1262	65	3	24	2026-08-17	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1263	65	3	24	2026-08-19	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1264	65	3	24	2026-08-24	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1265	66	3	25	2026-10-15	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1266	66	3	25	2026-10-20	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1267	66	3	25	2026-10-22	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1268	66	3	25	2026-10-27	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1269	66	3	25	2026-10-29	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1270	66	3	25	2026-11-03	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1271	66	3	25	2026-11-05	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1272	66	3	25	2026-11-10	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1273	66	3	25	2026-11-12	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1274	66	3	25	2026-11-17	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1275	66	3	25	2026-11-19	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1276	66	3	25	2026-11-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1277	66	2	25	2026-11-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1278	66	3	25	2026-12-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1279	66	3	25	2026-12-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1280	66	3	25	2026-12-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1281	66	3	25	2026-12-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1282	66	3	25	2026-12-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1283	66	3	25	2026-12-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1284	66	3	25	2026-12-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1285	66	3	25	2026-12-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1286	66	3	25	2026-12-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1287	66	3	25	2026-12-31	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1288	66	3	25	2027-01-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1289	66	3	25	2027-01-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1290	67	3	26	2026-12-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1291	67	3	26	2026-12-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1292	67	3	26	2026-12-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1293	67	3	26	2026-12-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1294	67	3	26	2026-12-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1295	67	3	26	2026-12-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1296	67	3	26	2026-12-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1297	67	3	26	2026-12-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1298	67	3	26	2027-01-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1299	67	3	26	2027-01-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1300	67	3	26	2027-01-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1301	67	3	26	2027-01-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1302	67	3	26	2027-01-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1303	67	3	26	2027-01-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1304	67	3	26	2027-01-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1305	67	3	26	2027-01-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1306	67	3	26	2027-02-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1307	67	3	26	2027-02-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1308	67	3	26	2027-02-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1309	67	3	26	2027-02-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1310	67	3	26	2027-02-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1311	67	3	26	2027-02-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1312	67	3	26	2027-02-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1313	67	3	26	2027-02-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1314	68	3	27	2026-05-12	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1315	68	3	27	2026-05-14	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1316	68	3	27	2026-05-19	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1317	68	3	27	2026-05-21	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1318	68	3	27	2026-05-26	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1319	68	3	27	2026-05-28	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1320	68	3	27	2026-06-02	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1321	68	3	27	2026-06-04	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1322	68	3	27	2026-06-09	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1323	68	3	27	2026-06-11	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1324	68	3	27	2026-06-16	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1325	68	3	27	2026-06-18	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1326	68	3	27	2026-06-23	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1327	68	3	27	2026-06-25	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1328	68	3	27	2026-06-30	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1329	68	3	27	2026-07-02	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1330	68	3	27	2026-07-07	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1331	68	3	27	2026-07-09	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1332	68	3	27	2026-07-14	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1333	68	3	27	2026-07-16	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1334	68	3	27	2026-07-21	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1335	68	3	27	2026-07-23	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1336	68	3	27	2026-07-28	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1337	69	3	29	2026-10-06	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1338	69	3	29	2026-10-08	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1339	69	3	29	2026-10-13	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1340	69	3	29	2026-10-15	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1341	69	3	29	2026-10-20	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1342	69	3	29	2026-10-22	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1343	69	3	29	2026-10-27	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1344	69	3	29	2026-10-29	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1345	69	3	29	2026-11-03	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1346	69	3	29	2026-11-05	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1347	69	3	29	2026-11-10	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1348	69	3	29	2026-11-12	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1349	69	3	29	2026-11-17	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1350	69	3	29	2026-11-19	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1351	69	3	29	2026-11-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1352	69	3	29	2026-11-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1353	69	3	29	2026-12-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1354	69	3	29	2026-12-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1355	69	3	29	2026-12-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1356	69	3	29	2026-12-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1357	69	3	29	2026-12-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1358	69	3	29	2026-12-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1359	70	3	30	2026-12-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1360	70	3	30	2026-12-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1361	70	3	30	2026-12-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1362	70	3	30	2026-12-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1363	70	3	30	2026-12-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1364	70	3	30	2026-12-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1365	70	3	30	2026-12-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1366	70	3	30	2026-12-31	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1367	70	3	30	2027-01-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1368	70	3	30	2027-01-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1369	70	3	30	2027-01-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1370	70	3	30	2027-01-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1371	70	3	30	2027-01-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1372	70	3	30	2027-01-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1373	70	3	30	2027-01-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1374	70	3	30	2027-01-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1375	70	3	30	2027-02-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1376	70	3	30	2027-02-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1377	70	3	30	2027-02-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1378	70	3	30	2027-02-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1379	70	3	30	2027-02-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1380	70	3	30	2027-02-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1381	70	3	30	2027-02-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1382	70	3	30	2027-02-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1383	71	3	31	2026-06-16	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1384	71	3	31	2026-06-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1385	71	3	31	2026-06-23	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1386	71	3	31	2026-06-25	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1387	71	3	31	2026-06-30	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1388	71	3	31	2026-07-02	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1389	71	3	31	2026-07-07	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1390	71	3	31	2026-07-09	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1391	71	3	31	2026-07-14	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1392	71	3	31	2026-07-16	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1393	71	3	31	2026-07-21	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1394	71	3	31	2026-07-23	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1395	71	3	31	2026-07-28	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1396	71	3	31	2026-07-30	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1397	71	3	31	2026-08-04	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1398	71	3	31	2026-08-06	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1399	71	3	31	2026-08-11	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1400	71	3	31	2026-08-13	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1401	71	3	31	2026-08-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1402	71	3	31	2026-08-20	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1403	71	3	31	2026-08-25	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1404	71	3	31	2026-08-27	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1405	72	3	32	2026-10-23	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1406	72	3	32	2026-10-24	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1407	72	3	32	2026-10-30	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1408	72	3	32	2026-10-31	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1409	72	3	32	2026-11-06	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1410	72	3	32	2026-11-07	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1411	72	3	32	2026-11-13	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1412	72	3	32	2026-11-14	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1413	72	3	32	2026-11-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1414	72	1	32	2026-11-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1415	72	3	32	2026-11-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1416	72	1	32	2026-11-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1417	72	3	32	2026-12-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1418	72	1	32	2026-12-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1419	72	3	32	2026-12-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1420	72	1	32	2026-12-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1421	72	3	32	2026-12-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1422	72	1	32	2026-12-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1423	72	3	32	2026-12-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1424	72	1	32	2026-12-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1425	72	3	32	2027-01-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1426	72	1	32	2027-01-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1427	72	3	32	2027-01-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1428	72	4	32	2027-01-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1429	73	3	33	2026-12-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1430	73	3	33	2026-12-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1431	73	3	33	2026-12-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1432	73	3	33	2026-12-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1433	73	3	33	2026-12-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1434	73	3	33	2027-01-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1435	73	3	33	2027-01-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1436	73	3	33	2027-01-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1437	73	3	33	2027-01-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1438	73	3	33	2027-01-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1439	73	3	33	2027-01-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1440	73	3	33	2027-01-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1441	73	3	33	2027-01-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1442	73	3	33	2027-01-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1443	73	3	33	2027-01-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1444	73	3	33	2027-02-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1445	73	3	33	2027-02-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1446	73	3	33	2027-02-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1447	73	3	33	2027-02-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1448	73	3	33	2027-02-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1449	73	3	33	2027-02-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1450	73	3	33	2027-02-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1451	73	3	33	2027-02-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1452	74	3	34	2026-06-05	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1453	74	3	34	2026-06-06	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1454	74	3	34	2026-06-12	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1455	74	3	34	2026-06-13	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1456	74	3	34	2026-06-19	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1457	74	3	34	2026-06-20	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1458	74	3	34	2026-06-26	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1459	74	3	34	2026-06-27	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1460	74	3	34	2026-07-03	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1461	74	3	34	2026-07-04	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1462	74	3	34	2026-07-10	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1463	74	3	34	2026-07-11	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1464	74	3	34	2026-07-17	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1465	74	3	34	2026-07-18	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1466	74	3	34	2026-07-24	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1467	74	3	34	2026-07-25	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1468	74	3	34	2026-07-31	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1469	74	3	34	2026-08-01	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1470	74	3	34	2026-08-07	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1471	74	3	34	2026-08-08	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1472	74	3	34	2026-08-14	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1473	74	3	34	2026-08-15	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1474	74	3	34	2026-08-21	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1475	74	3	34	2026-08-22	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1476	75	3	35	2026-10-16	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1477	75	3	35	2026-10-17	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1478	75	3	35	2026-10-23	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1479	75	3	35	2026-10-24	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1480	75	3	35	2026-10-30	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1481	75	3	35	2026-10-31	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1482	75	3	35	2026-11-06	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1483	75	3	35	2026-11-07	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1484	75	3	35	2026-11-13	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1485	75	3	35	2026-11-14	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1486	75	3	35	2026-11-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1487	75	3	35	2026-11-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1488	75	3	35	2026-11-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1489	75	3	35	2026-11-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1490	75	3	35	2026-12-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1491	75	3	35	2026-12-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1492	75	3	35	2026-12-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1493	75	3	35	2026-12-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1494	75	3	35	2026-12-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1495	75	3	35	2026-12-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1496	75	3	35	2026-12-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1497	75	3	35	2026-12-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1498	75	3	35	2027-01-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1499	75	3	35	2027-01-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1500	75	3	35	2027-01-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1501	75	3	35	2027-01-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1502	76	3	38	2026-12-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1503	76	3	38	2026-12-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1504	76	3	38	2026-12-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1505	76	3	38	2026-12-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1506	76	3	38	2026-12-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1507	76	3	38	2026-12-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1508	76	3	38	2026-12-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1509	76	3	38	2027-01-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1510	76	3	38	2027-01-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1511	76	3	38	2027-01-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1512	76	3	38	2027-01-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1513	76	3	38	2027-01-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1514	76	3	38	2027-01-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1515	76	3	38	2027-01-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1516	76	3	38	2027-01-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1517	76	3	38	2027-01-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1518	76	3	38	2027-01-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1519	76	3	38	2027-02-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1520	76	3	38	2027-02-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1521	76	3	38	2027-02-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1522	76	3	38	2027-02-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1523	76	3	38	2027-02-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1524	76	3	38	2027-02-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1525	76	3	38	2027-02-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1526	76	3	38	2027-02-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1527	77	3	39	2026-05-22	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1528	77	3	39	2026-05-23	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1529	77	3	39	2026-05-29	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1530	77	3	39	2026-05-30	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1531	77	3	39	2026-06-05	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1532	77	3	39	2026-06-06	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1533	77	3	39	2026-06-12	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1534	77	3	39	2026-06-13	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1535	77	3	39	2026-06-19	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1536	77	3	39	2026-06-20	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1537	77	3	39	2026-06-26	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1538	77	3	39	2026-06-27	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1539	77	3	39	2026-07-03	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1540	77	3	39	2026-07-04	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1541	77	3	39	2026-07-10	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1542	77	3	39	2026-07-11	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1543	77	3	39	2026-07-17	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1544	77	3	39	2026-07-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1545	77	3	39	2026-07-24	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1546	77	3	39	2026-07-25	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1547	77	3	39	2026-07-31	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1548	77	3	39	2026-08-01	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1549	77	3	39	2026-08-07	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1550	77	3	39	2026-08-08	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1551	78	3	40	2026-10-18	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1552	78	3	40	2026-10-25	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1553	78	3	40	2026-11-01	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1554	78	3	40	2026-11-08	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1555	78	1	40	2026-11-15	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1556	78	1	40	2026-11-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1557	78	1	40	2026-11-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1558	78	1	40	2026-12-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1559	78	4	40	2026-12-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1560	78	4	40	2026-12-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1561	78	4	40	2026-12-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1562	78	4	40	2027-01-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1563	78	4	40	2027-01-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1564	79	3	41	2026-12-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1565	79	3	41	2026-12-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1566	79	3	41	2026-12-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1567	79	3	41	2026-12-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1568	79	3	41	2027-01-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1569	79	3	41	2027-01-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1570	79	3	41	2027-01-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1571	79	3	41	2027-01-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1572	79	3	41	2027-01-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1573	79	3	41	2027-02-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1574	79	3	41	2027-02-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1575	79	3	41	2027-02-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1576	79	3	41	2027-02-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1577	79	3	41	2027-03-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1578	80	3	42	2026-06-07	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1579	80	3	42	2026-06-14	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1580	80	3	42	2026-06-21	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1581	80	3	42	2026-06-28	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1582	80	3	42	2026-07-05	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1583	80	3	42	2026-07-12	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1584	80	3	42	2026-07-19	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1585	80	3	42	2026-07-26	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1586	80	3	42	2026-08-02	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1587	80	3	42	2026-08-09	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1588	80	3	42	2026-08-16	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1589	81	3	43	2026-10-11	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1590	81	3	43	2026-10-18	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1591	81	3	43	2026-10-25	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1592	81	3	43	2026-11-01	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1593	81	3	43	2026-11-08	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1594	81	3	43	2026-11-15	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1595	81	3	43	2026-11-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1596	81	3	43	2026-11-29	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1597	81	3	43	2026-12-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1598	81	3	43	2026-12-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1599	81	3	43	2026-12-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1600	82	3	44	2026-12-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1601	82	3	44	2026-12-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1602	82	3	44	2026-12-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1603	82	3	44	2027-01-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1604	82	3	44	2027-01-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1605	82	3	44	2027-01-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1606	82	3	44	2027-01-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1607	82	3	44	2027-01-31	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1608	82	3	44	2027-02-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1609	82	3	44	2027-02-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1610	82	3	44	2027-02-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1611	82	3	44	2027-02-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1612	83	3	45	2026-10-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1613	83	3	45	2026-10-25	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1614	83	3	45	2026-11-01	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1615	83	3	45	2026-11-08	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1616	83	3	45	2026-11-15	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1617	83	3	45	2026-11-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1618	83	3	45	2026-11-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1619	83	3	45	2026-12-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1620	83	3	45	2026-12-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1621	83	3	45	2026-12-20	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1622	83	3	45	2026-12-27	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1623	83	3	45	2027-01-03	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1624	83	3	45	2027-01-10	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1625	84	4	26	2026-12-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1626	84	4	26	2026-12-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1627	84	4	26	2026-12-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1628	84	4	26	2026-12-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1629	84	4	26	2026-12-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1630	84	4	26	2026-12-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1631	84	4	26	2026-12-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1632	84	4	26	2026-12-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1633	84	4	26	2027-01-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1634	84	4	26	2027-01-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1635	84	4	26	2027-01-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1636	84	4	26	2027-01-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1637	84	4	26	2027-01-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1638	84	4	26	2027-01-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1639	84	4	26	2027-01-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1640	84	4	26	2027-01-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1641	84	4	26	2027-02-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1642	84	4	26	2027-02-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1643	84	4	26	2027-02-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1644	84	4	26	2027-02-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1645	84	4	26	2027-02-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1646	84	4	26	2027-02-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1647	84	4	26	2027-02-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1648	84	4	26	2027-02-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1649	84	4	26	2027-03-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1650	84	4	26	2027-03-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1651	85	4	27	2026-12-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1652	85	4	27	2026-12-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1653	85	4	27	2026-12-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1654	85	4	27	2026-12-23	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1655	85	4	27	2026-12-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1656	85	4	27	2026-12-30	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1657	85	4	27	2027-01-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1658	85	4	27	2027-01-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1659	85	4	27	2027-01-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1660	85	4	27	2027-01-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1661	85	4	27	2027-01-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1662	85	4	27	2027-01-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1663	85	4	27	2027-01-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1664	85	4	27	2027-01-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1665	85	4	27	2027-02-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1666	85	4	27	2027-02-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1667	85	4	27	2027-02-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1668	85	4	27	2027-02-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1669	85	4	27	2027-02-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1670	85	4	27	2027-02-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1671	85	4	27	2027-02-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1672	85	4	27	2027-02-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1673	86	4	29	2026-06-01	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1674	86	4	29	2026-06-03	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1675	86	4	29	2026-06-08	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1676	86	4	29	2026-06-10	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1677	86	4	29	2026-06-15	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1678	86	4	29	2026-06-17	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1679	86	4	29	2026-06-22	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1680	86	4	29	2026-06-24	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1681	86	4	29	2026-06-29	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1682	86	4	29	2026-07-01	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1683	86	4	29	2026-07-06	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1684	86	4	29	2026-07-08	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1685	86	4	29	2026-07-13	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1686	86	4	29	2026-07-15	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1687	86	4	29	2026-07-20	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1688	86	4	29	2026-07-22	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1689	86	4	29	2026-07-27	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1690	86	4	29	2026-07-29	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1691	86	4	29	2026-08-03	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1692	86	4	29	2026-08-05	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1693	86	4	29	2026-08-10	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1694	86	4	29	2026-08-12	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1695	86	4	29	2026-08-17	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1696	87	4	30	2026-10-05	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1697	87	4	30	2026-10-07	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1698	87	4	30	2026-10-12	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1699	87	4	30	2026-10-14	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1700	87	4	30	2026-10-19	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1701	87	4	30	2026-10-21	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1702	87	4	30	2026-10-26	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1703	87	4	30	2026-10-28	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1704	87	4	30	2026-11-02	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1705	87	4	30	2026-11-04	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1706	87	4	30	2026-11-09	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1707	87	4	30	2026-11-11	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1708	87	4	30	2026-11-16	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1709	87	4	30	2026-11-18	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1710	87	4	30	2026-11-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1711	87	4	30	2026-11-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1712	87	4	30	2026-11-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1713	87	4	30	2026-12-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1714	87	4	30	2026-12-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1715	87	4	30	2026-12-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1716	87	4	30	2026-12-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1717	87	4	30	2026-12-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1718	88	4	31	2026-12-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1719	88	4	31	2026-12-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1720	88	4	31	2026-12-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1721	88	4	31	2026-12-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1722	88	4	31	2026-12-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1723	88	4	31	2026-12-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1724	88	4	31	2026-12-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1725	88	4	31	2026-12-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1726	88	4	31	2027-01-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1727	88	5	31	2027-01-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1728	88	5	31	2027-01-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1729	88	5	31	2027-01-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1730	88	5	31	2027-01-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1731	88	4	31	2027-01-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1732	88	4	31	2027-01-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1733	88	4	31	2027-01-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1734	88	4	31	2027-02-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1735	88	4	31	2027-02-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1736	88	4	31	2027-02-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1737	88	4	31	2027-02-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1738	88	4	31	2027-02-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1739	88	4	31	2027-02-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1740	88	4	31	2027-02-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1741	88	4	31	2027-02-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1742	89	4	32	2026-10-19	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1743	89	4	32	2026-10-21	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1744	89	4	32	2026-10-26	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1745	89	4	32	2026-10-28	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1746	89	4	32	2026-11-02	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1747	89	4	32	2026-11-04	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1748	89	4	32	2026-11-09	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1749	89	4	32	2026-11-11	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1750	89	4	32	2026-11-16	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1751	89	4	32	2026-11-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1752	89	4	32	2026-11-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1753	89	4	32	2026-11-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1754	89	4	32	2026-11-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1755	89	4	32	2026-12-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1756	89	4	32	2026-12-07	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1757	89	4	32	2026-12-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1758	89	4	32	2026-12-14	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1759	89	4	32	2026-12-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1760	89	4	32	2026-12-21	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1761	89	4	32	2026-12-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1762	89	4	32	2026-12-28	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1763	89	4	32	2026-12-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1764	89	4	32	2027-01-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1765	89	4	32	2027-01-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1766	90	4	33	2026-12-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1767	90	4	33	2026-12-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1768	90	4	33	2026-12-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1769	90	4	33	2026-12-24	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1770	90	4	33	2026-12-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1771	90	4	33	2026-12-31	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1772	90	4	33	2027-01-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1773	90	4	33	2027-01-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1774	90	4	33	2027-01-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1775	90	4	33	2027-01-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1776	90	4	33	2027-01-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1777	90	4	33	2027-01-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1778	90	4	33	2027-01-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1779	90	4	33	2027-01-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1780	90	4	33	2027-02-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1781	90	4	33	2027-02-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1782	90	4	33	2027-02-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1783	90	4	33	2027-02-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1784	90	4	33	2027-02-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1785	90	4	33	2027-02-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1786	90	4	33	2027-02-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1787	90	4	33	2027-02-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1788	90	4	33	2027-03-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1789	90	4	33	2027-03-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1790	91	4	34	2026-10-20	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1791	91	4	34	2026-10-22	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1792	91	4	34	2026-10-27	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1793	91	4	34	2026-10-29	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1794	91	4	34	2026-11-03	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1795	91	4	34	2026-11-05	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1796	91	4	34	2026-11-10	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1797	91	4	34	2026-11-12	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1798	91	4	34	2026-11-17	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1799	91	4	34	2026-11-19	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1800	91	4	34	2026-11-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1801	91	4	34	2026-11-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1802	91	4	34	2026-12-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1803	91	4	34	2026-12-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1804	91	4	34	2026-12-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1805	91	4	34	2026-12-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1806	91	4	34	2026-12-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1807	91	4	34	2026-12-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1808	91	4	34	2026-12-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1809	91	4	34	2026-12-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1810	91	4	34	2026-12-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1811	91	4	34	2026-12-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1812	91	4	34	2027-01-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1813	91	4	34	2027-01-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1814	91	4	34	2027-01-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1815	91	4	34	2027-01-14	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1816	91	4	34	2027-01-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1817	91	4	34	2027-01-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1818	91	4	34	2027-01-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1819	92	4	35	2026-12-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1820	92	4	35	2026-12-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1821	92	4	35	2026-12-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1822	92	4	35	2026-12-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1823	92	4	35	2026-12-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1824	92	4	35	2026-12-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1825	92	4	35	2026-12-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1826	92	4	35	2026-12-31	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1827	92	4	35	2027-01-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1828	92	4	35	2027-01-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1829	92	4	35	2027-01-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1830	92	4	35	2027-01-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1831	92	4	35	2027-01-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1832	92	4	35	2027-01-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1833	92	4	35	2027-01-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1834	92	4	35	2027-01-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1835	92	4	35	2027-02-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1836	92	4	35	2027-02-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1837	92	4	35	2027-02-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1838	92	4	35	2027-02-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1839	92	4	35	2027-02-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1840	92	4	35	2027-02-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1841	92	4	35	2027-02-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1842	92	4	35	2027-02-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1843	92	4	35	2027-03-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1844	92	4	35	2027-03-04	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1845	92	4	35	2027-03-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1846	92	4	35	2027-03-11	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1847	93	4	38	2026-10-06	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1848	93	4	38	2026-10-08	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1849	93	4	38	2026-10-13	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1850	93	4	38	2026-10-15	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1851	93	4	38	2026-10-20	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1852	93	4	38	2026-10-22	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1853	93	4	38	2026-10-27	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1854	93	4	38	2026-10-29	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1855	93	4	38	2026-11-03	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1856	93	4	38	2026-11-05	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1857	93	4	38	2026-11-10	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1858	93	4	38	2026-11-12	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1859	93	4	38	2026-11-17	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1860	93	4	38	2026-11-19	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1861	93	4	38	2026-11-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1862	93	4	38	2026-11-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1863	93	4	38	2026-12-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1864	93	4	38	2026-12-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1865	93	4	38	2026-12-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1866	93	4	38	2026-12-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1867	93	4	38	2026-12-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1868	93	4	38	2026-12-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1869	94	4	39	2026-12-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1870	94	4	39	2026-12-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1871	94	4	39	2026-12-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1872	94	4	39	2026-12-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1873	94	4	39	2026-12-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1874	94	4	39	2026-12-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1875	94	4	39	2026-12-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1876	94	4	39	2026-12-31	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1877	94	4	39	2027-01-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1878	94	4	39	2027-01-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1879	94	4	39	2027-01-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1880	94	4	39	2027-01-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1881	94	4	39	2027-01-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1882	94	4	39	2027-01-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1883	94	4	39	2027-01-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1884	94	4	39	2027-01-28	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1885	94	4	39	2027-02-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1886	94	4	39	2027-02-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1887	94	4	39	2027-02-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1888	94	4	39	2027-02-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1889	94	4	39	2027-02-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1890	94	4	39	2027-02-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1891	94	4	39	2027-02-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1892	94	4	39	2027-02-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1893	95	4	40	2026-10-13	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1894	95	4	40	2026-10-15	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1895	95	4	40	2026-10-20	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1896	95	4	40	2026-10-22	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1897	95	4	40	2026-10-27	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1898	95	4	40	2026-10-29	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1899	95	4	40	2026-11-03	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1900	95	4	40	2026-11-05	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1901	95	4	40	2026-11-10	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1902	95	4	40	2026-11-12	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1903	95	4	40	2026-11-17	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1904	95	4	40	2026-11-19	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1905	95	4	40	2026-11-24	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1906	95	4	40	2026-11-26	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1907	95	4	40	2026-12-01	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1908	95	4	40	2026-12-03	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1909	95	4	40	2026-12-08	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1910	95	4	40	2026-12-10	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1911	95	4	40	2026-12-15	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1912	95	4	40	2026-12-17	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1913	95	4	40	2026-12-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1914	95	4	40	2026-12-24	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1915	95	4	40	2026-12-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1916	95	4	40	2026-12-31	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1917	95	4	40	2027-01-05	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1918	96	5	41	2027-01-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1919	96	4	41	2027-01-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1920	96	4	41	2027-01-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1921	96	4	41	2027-01-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1922	96	4	41	2027-01-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1923	96	4	41	2027-01-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1924	96	4	41	2027-01-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1925	96	4	41	2027-02-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1926	96	4	41	2027-02-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1927	96	4	41	2027-02-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1928	96	4	41	2027-02-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1929	96	4	41	2027-02-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1930	96	4	41	2027-02-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1931	96	4	41	2027-02-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1932	96	4	41	2027-02-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1933	96	4	41	2027-03-05	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1934	96	4	41	2027-03-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1935	96	4	41	2027-03-12	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1936	96	4	41	2027-03-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1937	96	4	41	2027-03-19	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1938	96	4	41	2027-03-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1939	96	4	41	2027-03-26	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1940	96	4	41	2027-03-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1941	96	4	41	2027-04-02	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1942	96	4	41	2027-04-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1943	97	4	42	2026-10-16	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1944	97	4	42	2026-10-17	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1945	97	4	42	2026-10-23	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1946	97	4	42	2026-10-24	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1947	97	4	42	2026-10-30	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1948	97	4	42	2026-10-31	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1949	97	4	42	2026-11-06	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1950	97	4	42	2026-11-07	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1951	97	4	42	2026-11-13	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1952	97	4	42	2026-11-14	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1953	97	4	42	2026-11-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1954	97	4	42	2026-11-21	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1955	97	4	42	2026-11-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1956	97	4	42	2026-11-28	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1957	97	4	42	2026-12-04	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1958	97	4	42	2026-12-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1959	97	4	42	2026-12-11	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1960	97	4	42	2026-12-12	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1961	97	4	42	2026-12-18	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1962	97	4	42	2026-12-19	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1963	97	4	42	2026-12-25	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1964	97	4	42	2026-12-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1965	97	4	42	2027-01-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1966	97	4	42	2027-01-02	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1967	97	4	42	2027-01-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1968	97	4	42	2027-01-09	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1969	97	4	42	2027-01-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1970	97	4	42	2027-01-16	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1971	97	4	42	2027-01-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1972	98	4	43	2026-12-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1973	98	4	43	2026-12-18	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1974	98	4	43	2026-12-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1975	98	4	43	2026-12-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1976	98	4	43	2026-12-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1977	98	4	43	2027-01-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1978	98	4	43	2027-01-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1979	98	4	43	2027-01-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1980	98	4	43	2027-01-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1981	98	4	43	2027-01-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1982	98	4	43	2027-01-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1983	98	4	43	2027-01-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1984	98	4	43	2027-01-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1985	98	4	43	2027-01-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1986	98	4	43	2027-01-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1987	98	4	43	2027-02-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1988	98	4	43	2027-02-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1989	98	4	43	2027-02-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1990	98	4	43	2027-02-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1991	98	4	43	2027-02-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1992	98	4	43	2027-02-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1993	98	4	43	2027-02-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1994	98	4	43	2027-02-27	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1995	98	4	43	2027-03-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1996	98	4	43	2027-03-06	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1997	98	4	43	2027-03-12	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1998	98	4	43	2027-03-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1999	98	4	43	2027-03-19	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2000	98	4	43	2027-03-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2001	99	4	44	2026-10-09	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2002	99	4	44	2026-10-10	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2003	99	4	44	2026-10-16	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2004	99	4	44	2026-10-17	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2005	99	4	44	2026-10-23	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2006	99	4	44	2026-10-24	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2007	99	4	44	2026-10-30	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2008	99	4	44	2026-10-31	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2009	99	4	44	2026-11-06	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2010	99	4	44	2026-11-07	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2011	99	4	44	2026-11-13	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2012	99	4	44	2026-11-14	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2013	99	4	44	2026-11-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2014	99	4	44	2026-11-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2015	99	4	44	2026-11-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2016	99	4	44	2026-11-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2017	99	4	44	2026-12-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2018	99	4	44	2026-12-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2019	99	4	44	2026-12-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2020	99	4	44	2026-12-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2021	99	4	44	2026-12-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2022	99	4	44	2026-12-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2023	100	4	45	2026-12-04	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2024	100	4	45	2026-12-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2025	100	4	45	2026-12-11	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2026	100	4	45	2026-12-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2027	100	4	45	2026-12-18	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2028	100	4	45	2026-12-19	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2029	100	4	45	2026-12-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2030	100	4	45	2026-12-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2031	100	4	45	2027-01-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2032	100	4	45	2027-01-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2033	100	4	45	2027-01-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2034	100	4	45	2027-01-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2035	100	4	45	2027-01-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2036	100	4	45	2027-01-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2037	100	4	45	2027-01-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2038	100	4	45	2027-01-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2039	100	4	45	2027-01-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2040	100	4	45	2027-01-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2041	100	4	45	2027-02-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2042	100	4	45	2027-02-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2043	100	4	45	2027-02-12	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2044	100	4	45	2027-02-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2045	101	4	46	2026-06-06	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2046	101	4	46	2026-06-12	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2047	101	4	46	2026-06-13	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2048	101	4	46	2026-06-19	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2049	101	4	46	2026-06-20	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2050	101	4	46	2026-06-26	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2051	101	4	46	2026-06-27	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2052	101	4	46	2026-07-03	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2053	101	4	46	2026-07-04	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2054	101	4	46	2026-07-10	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2055	101	4	46	2026-07-11	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2056	101	4	46	2026-07-17	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2057	101	4	46	2026-07-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2058	101	4	46	2026-07-24	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2059	101	4	46	2026-07-25	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2060	101	4	46	2026-07-31	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2061	101	4	46	2026-08-01	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2062	101	4	46	2026-08-07	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2063	101	4	46	2026-08-08	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2064	101	4	46	2026-08-14	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2065	101	4	46	2026-08-15	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2066	101	4	46	2026-08-21	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2067	101	4	46	2026-08-22	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2068	101	4	46	2026-08-28	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2069	101	4	46	2026-08-29	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2070	102	4	47	2026-10-11	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2071	102	4	47	2026-10-18	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2072	102	4	47	2026-10-25	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2073	102	4	47	2026-11-01	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2074	102	4	47	2026-11-08	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2075	102	4	47	2026-11-15	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2076	102	4	47	2026-11-22	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2077	102	4	47	2026-11-29	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2078	102	4	47	2026-12-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2079	102	5	47	2026-12-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2080	102	5	47	2026-12-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2081	102	5	47	2026-12-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2082	103	4	1	2026-10-11	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2083	103	4	1	2026-10-18	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2084	103	4	1	2026-10-25	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2085	103	4	1	2026-11-01	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2086	103	4	1	2026-11-08	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2087	103	4	1	2026-11-15	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2088	103	4	1	2026-11-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2089	103	4	1	2026-11-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2090	103	4	1	2026-12-06	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2091	103	4	1	2026-12-13	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2092	103	4	1	2026-12-20	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2093	103	4	1	2026-12-27	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2094	104	4	2	2026-12-13	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2095	104	4	2	2026-12-20	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2096	104	4	2	2026-12-27	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2097	104	4	2	2027-01-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2098	104	4	2	2027-01-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2099	104	4	2	2027-01-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2100	104	4	2	2027-01-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2101	104	4	2	2027-01-31	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2102	104	4	2	2027-02-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2103	104	4	2	2027-02-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2104	104	4	2	2027-02-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2105	104	4	2	2027-02-28	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2106	105	4	3	2026-06-07	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2107	105	4	3	2026-06-14	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2108	105	4	3	2026-06-21	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2109	105	4	3	2026-06-28	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2110	105	4	3	2026-07-05	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2111	105	4	3	2026-07-12	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2112	105	4	3	2026-07-19	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2113	105	4	3	2026-07-26	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2114	105	4	3	2026-08-02	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2115	105	4	3	2026-08-09	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2116	105	4	3	2026-08-16	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2117	105	4	3	2026-08-23	15:15	16:45	Ca chiều 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2118	106	4	4	2026-10-18	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2119	106	4	4	2026-10-25	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2120	106	4	4	2026-11-01	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2121	106	4	4	2026-11-08	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2122	106	4	4	2026-11-15	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2123	106	4	4	2026-11-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2124	106	4	4	2026-11-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2125	106	4	4	2026-12-06	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2126	106	4	4	2026-12-13	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2127	106	4	4	2026-12-20	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2128	106	4	4	2026-12-27	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2129	106	4	4	2027-01-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2130	107	4	5	2026-10-18	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2131	107	4	5	2026-10-25	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2132	107	4	5	2026-11-01	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2133	107	4	5	2026-11-08	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2134	107	4	5	2026-11-15	19:45	21:15	Ca tối 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2135	107	4	5	2026-11-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2136	107	4	5	2026-11-29	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2137	107	4	5	2026-12-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2138	107	4	5	2026-12-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2139	107	4	5	2026-12-20	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2140	108	5	34	2026-12-07	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2141	108	5	34	2026-12-09	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2142	108	5	34	2026-12-14	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2143	108	5	34	2026-12-16	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2144	108	5	34	2026-12-21	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2145	108	5	34	2026-12-23	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2146	108	5	34	2026-12-28	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2147	108	5	34	2026-12-30	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2148	108	5	34	2027-01-04	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2149	108	5	34	2027-01-06	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2150	108	5	34	2027-01-11	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2151	108	5	34	2027-01-13	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2152	108	5	34	2027-01-18	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2153	108	5	34	2027-01-20	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2154	108	5	34	2027-01-25	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2155	108	5	34	2027-01-27	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2156	108	5	34	2027-02-01	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2157	108	5	34	2027-02-03	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2158	108	5	34	2027-02-08	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2159	108	5	34	2027-02-10	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2160	108	5	34	2027-02-15	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2161	108	5	34	2027-02-17	07:30	09:00	Ca sáng 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2162	109	5	35	2026-06-03	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2163	109	5	35	2026-06-08	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2164	109	5	35	2026-06-10	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2165	109	5	35	2026-06-15	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2166	109	5	35	2026-06-17	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2167	109	5	35	2026-06-22	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2168	109	5	35	2026-06-24	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2169	109	5	35	2026-06-29	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2170	109	5	35	2026-07-01	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2171	109	5	35	2026-07-06	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2172	109	5	35	2026-07-08	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2173	109	5	35	2026-07-13	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2174	109	5	35	2026-07-15	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2175	109	5	35	2026-07-20	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2176	109	5	35	2026-07-22	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2177	109	5	35	2026-07-27	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2178	109	5	35	2026-07-29	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2179	109	5	35	2026-08-03	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2180	109	5	35	2026-08-05	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2181	109	5	35	2026-08-10	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2182	109	5	35	2026-08-12	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2183	109	5	35	2026-08-17	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2184	110	5	38	2026-10-05	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2185	110	5	38	2026-10-07	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2186	110	5	38	2026-10-12	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2187	110	5	38	2026-10-14	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2188	110	5	38	2026-10-19	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2189	110	5	38	2026-10-21	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2190	110	5	38	2026-10-26	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2191	110	5	38	2026-10-28	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2192	110	5	38	2026-11-02	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2193	110	5	38	2026-11-04	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2194	110	5	38	2026-11-09	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2195	110	5	38	2026-11-11	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2196	110	5	38	2026-11-16	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2197	110	5	38	2026-11-18	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2198	110	5	38	2026-11-23	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2199	110	5	38	2026-11-25	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2200	110	5	38	2026-11-30	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2201	110	5	38	2026-12-02	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2202	110	5	38	2026-12-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2203	110	5	38	2026-12-09	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2204	110	5	38	2026-12-14	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2205	110	5	38	2026-12-16	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2206	110	5	38	2026-12-21	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2207	111	5	39	2026-12-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2208	111	5	39	2026-12-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2209	111	5	39	2026-12-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2210	111	5	39	2026-12-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2211	111	5	39	2026-12-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2212	111	5	39	2026-12-30	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2213	111	5	39	2027-01-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2214	111	5	39	2027-01-06	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2215	111	5	39	2027-01-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2216	111	5	39	2027-01-13	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2217	111	5	39	2027-01-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2218	111	5	39	2027-01-20	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2219	111	5	39	2027-01-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2220	111	5	39	2027-01-27	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2221	111	5	39	2027-02-01	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2222	111	5	39	2027-02-03	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2223	111	5	39	2027-02-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2224	111	5	39	2027-02-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2225	111	5	39	2027-02-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2226	111	5	39	2027-02-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2227	111	5	39	2027-02-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2228	111	5	39	2027-02-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2229	112	5	40	2026-10-05	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2230	112	5	40	2026-10-07	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2231	112	5	40	2026-10-12	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2232	112	5	40	2026-10-14	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2233	112	5	40	2026-10-19	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2234	112	5	40	2026-10-21	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2235	112	5	40	2026-10-26	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2236	112	5	40	2026-10-28	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2237	112	5	40	2026-11-02	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2238	112	5	40	2026-11-04	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2239	112	5	40	2026-11-09	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2240	112	5	40	2026-11-11	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2241	112	5	40	2026-11-16	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2242	112	5	40	2026-11-18	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2243	112	5	40	2026-11-23	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2244	112	5	40	2026-11-25	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2245	112	5	40	2026-11-30	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2246	112	5	40	2026-12-02	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2247	112	5	40	2026-12-07	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2248	112	5	40	2026-12-09	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2249	112	5	40	2026-12-14	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2250	112	5	40	2026-12-16	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2251	112	5	40	2026-12-21	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2252	113	5	41	2026-12-07	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2253	113	5	41	2026-12-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2254	113	5	41	2026-12-14	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2255	113	5	41	2026-12-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2256	113	5	41	2026-12-21	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2257	113	5	41	2026-12-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2258	113	5	41	2026-12-28	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2259	113	5	41	2026-12-30	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2260	113	5	41	2027-01-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2261	113	5	41	2027-01-06	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2262	113	5	41	2027-01-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2263	113	5	41	2027-01-13	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2264	113	5	41	2027-01-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2265	113	5	41	2027-01-20	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2266	113	5	41	2027-01-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2267	113	5	41	2027-01-27	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2268	113	5	41	2027-02-01	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2269	113	5	41	2027-02-03	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2270	113	5	41	2027-02-08	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2271	113	5	41	2027-02-10	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2272	113	5	41	2027-02-15	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2273	113	5	41	2027-02-17	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2274	113	5	41	2027-02-22	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2275	113	5	41	2027-02-24	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2276	114	5	42	2026-06-02	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2277	114	5	42	2026-06-04	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2278	114	5	42	2026-06-09	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2279	114	5	42	2026-06-11	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2280	114	5	42	2026-06-16	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2281	114	5	42	2026-06-18	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2282	114	5	42	2026-06-23	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2283	114	5	42	2026-06-25	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2284	114	5	42	2026-06-30	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2285	114	5	42	2026-07-02	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2286	114	5	42	2026-07-07	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2287	114	5	42	2026-07-09	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2288	114	5	42	2026-07-14	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2289	114	5	42	2026-07-16	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2290	114	5	42	2026-07-21	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2291	114	5	42	2026-07-23	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2292	114	5	42	2026-07-28	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2293	114	5	42	2026-07-30	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2294	114	5	42	2026-08-04	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2295	114	5	42	2026-08-06	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2296	114	5	42	2026-08-11	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2297	114	5	42	2026-08-13	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2298	114	5	42	2026-08-18	07:30	09:00	Ca sáng 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2299	115	5	43	2026-10-20	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2300	115	5	43	2026-10-22	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2301	115	5	43	2026-10-27	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2302	115	5	43	2026-10-29	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2303	115	5	43	2026-11-03	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2304	115	5	43	2026-11-05	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2305	115	5	43	2026-11-10	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2306	115	5	43	2026-11-12	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2307	115	5	43	2026-11-17	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2308	115	5	43	2026-11-19	09:15	10:45	Ca sáng 2	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2309	115	5	43	2026-11-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2310	115	5	43	2026-11-26	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2311	115	5	43	2026-12-01	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2312	115	5	43	2026-12-03	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2313	115	5	43	2026-12-08	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2314	115	5	43	2026-12-10	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2315	115	5	43	2026-12-15	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2316	115	5	43	2026-12-17	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2317	115	5	43	2026-12-22	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2318	115	5	43	2026-12-24	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2319	115	5	43	2026-12-29	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2320	115	5	43	2026-12-31	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2321	115	5	43	2027-01-05	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2322	115	5	43	2027-01-07	09:15	10:45	Ca sáng 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2323	116	5	44	2026-10-20	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2324	116	5	44	2026-10-22	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2325	116	5	44	2026-10-27	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2326	116	5	44	2026-10-29	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2327	116	5	44	2026-11-03	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2328	116	5	44	2026-11-05	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2329	116	5	44	2026-11-10	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2330	116	5	44	2026-11-12	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2331	116	5	44	2026-11-17	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2332	116	5	44	2026-11-19	13:30	15:00	Ca chiều 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2333	116	5	44	2026-11-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2334	116	5	44	2026-11-26	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2335	116	5	44	2026-12-01	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2336	116	5	44	2026-12-03	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2337	116	5	44	2026-12-08	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2338	116	5	44	2026-12-10	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2339	116	5	44	2026-12-15	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2340	116	5	44	2026-12-17	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2341	116	5	44	2026-12-22	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2342	116	5	44	2026-12-24	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2343	116	5	44	2026-12-29	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2344	116	5	44	2026-12-31	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2345	116	5	44	2027-01-05	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2346	116	5	44	2027-01-07	13:30	15:00	Ca chiều 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2347	117	5	45	2026-12-08	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2348	117	5	45	2026-12-10	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2349	117	5	45	2026-12-15	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2350	117	5	45	2026-12-17	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2351	117	5	45	2026-12-22	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2352	117	5	45	2026-12-24	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2353	117	5	45	2026-12-29	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2354	117	5	45	2026-12-31	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2355	117	5	45	2027-01-05	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2356	117	5	45	2027-01-07	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2357	117	5	45	2027-01-12	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2358	117	5	45	2027-01-14	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2359	117	5	45	2027-01-19	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2360	117	5	45	2027-01-21	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2361	117	5	45	2027-01-26	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2362	117	5	45	2027-01-28	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2363	117	5	45	2027-02-02	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2364	117	5	45	2027-02-04	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2365	117	5	45	2027-02-09	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2366	117	5	45	2027-02-11	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2367	117	5	45	2027-02-16	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2368	117	5	45	2027-02-18	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2369	117	5	45	2027-02-23	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2370	117	5	45	2027-02-25	15:15	16:45	Ca chiều 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2371	118	5	46	2026-10-13	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2372	118	5	46	2026-10-15	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2373	118	5	46	2026-10-20	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2374	118	5	46	2026-10-22	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2375	118	5	46	2026-10-27	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2376	118	5	46	2026-10-29	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2377	118	5	46	2026-11-03	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2378	118	5	46	2026-11-05	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2379	118	1	46	2026-11-10	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2380	118	1	46	2026-11-12	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2381	118	1	46	2026-11-17	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2382	118	1	46	2026-11-19	18:00	19:30	Ca tối 1	t	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2383	118	1	46	2026-11-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2384	118	1	46	2026-11-26	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2385	118	1	46	2026-12-01	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2386	118	1	46	2026-12-03	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2387	118	1	46	2026-12-08	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2388	118	1	46	2026-12-10	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2389	118	1	46	2026-12-15	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2390	118	1	46	2026-12-17	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2391	118	1	46	2026-12-22	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2392	118	1	46	2026-12-24	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2393	118	1	46	2026-12-29	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2394	118	1	46	2026-12-31	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2395	118	1	46	2027-01-05	18:00	19:30	Ca tối 1	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2396	119	5	47	2027-01-12	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2397	119	5	47	2027-01-14	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2398	119	5	47	2027-01-19	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2399	119	5	47	2027-01-21	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2400	119	5	47	2027-01-26	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2401	119	5	47	2027-01-28	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2402	119	5	47	2027-02-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2403	119	5	47	2027-02-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2404	119	5	47	2027-02-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2405	119	5	47	2027-02-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2406	119	5	47	2027-02-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2407	119	5	47	2027-02-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2408	119	5	47	2027-02-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2409	119	5	47	2027-02-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2410	119	5	47	2027-03-02	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2411	119	5	47	2027-03-04	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2412	119	5	47	2027-03-09	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2413	119	5	47	2027-03-11	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2414	119	5	47	2027-03-16	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2415	119	5	47	2027-03-18	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2416	119	5	47	2027-03-23	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2417	119	5	47	2027-03-25	19:45	21:15	Ca tối 2	t	SCHEDULED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2422	1	1	1	2026-11-21	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2427	30	9	12	2026-11-21	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2432	4	6	3	2026-11-24	18:00	20:00	Ca tối (18:00 - 20:00)	t	SCHEDULED	\N	\N	f
2437	7	16	6	2026-11-21	14:00	16:00	Ca chiều (14:00 - 16:00)	t	SCHEDULED	\N	\N	f
2438	31	20	30	2026-11-24	08:00	10:00	Ca sáng (08:00 - 10:00)	t	SCHEDULED	\N	\N	f
\.


--
-- Data for Name: DON_THU; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DON_THU" ("MaDon", "MaSoDon", "LoaiDon", "MaNguoiGui", "MaNguoiNhan", "VaiTroNguoiNhan", "LinhVuc", "MaLopHoc", "TieuDe", "NoiDung", "TrangThai", "HanChotKhieuNai", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
6	KN-202611-0001	COMPLAINT	5	3	TEACHER	GRADE	1	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-65-K26A	Kính gửi thầy/cô lớp IELTS-65-K26A, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
42	KN-202611-0031	COMPLAINT	87	4	TEACHER	GRADE	3	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp TOEIC-750-K12	Kính gửi thầy/cô lớp TOEIC-750-K12, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PROCESSING	2027-01-22 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
47	KN-202611-0043	COMPLAINT	100	7	TEACHER	GRADE	4	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-65-K26B	Kính gửi thầy/cô lớp IELTS-65-K26B, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
59	KN-202611-0060	COMPLAINT	129	8	TEACHER	GRADE	5	Khiếu nại điểm chuyên cần buổi học thứ 5 - Lớp COMM-A2-K08	Kính chào thầy/cô phụ trách lớp COMM-A2-K08, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 5, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PROCESSING	2027-01-12 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
100	KN-202611-0098	COMPLAINT	162	10	TEACHER	GRADE	7	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-50-K15	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-50-K15. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
97	KN-202611-0115	COMPLAINT	185	9	TEACHER	GRADE	8	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp TOEIC-550-K30	Kính gửi thầy/cô lớp TOEIC-550-K30, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
141	YC-202611-0008	REQUEST	74	2	ACADEMIC_STAFF	GRADE_UNLOCK	30	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp BUS-ENG-K01	Kính gửi Phòng Học vụ, lớp BUS-ENG-K01 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
134	YC-202611-0010	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	11	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-65-PAST	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-65-PAST đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
70	KN-202611-0068	COMPLAINT	150	8	TEACHER	GRADE	5	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp COMM-A2-K08	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp COMM-A2-K08. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
66	KN-202611-0061	COMPLAINT	152	8	TEACHER	GRADE	5	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp COMM-A2-K08	Kính gửi thầy/cô lớp COMM-A2-K08, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
89	KN-202611-0090	COMPLAINT	154	10	TEACHER	GRADE	7	Khiếu nại điểm chuyên cần buổi học thứ 3 - Lớp IELTS-50-K15	Kính chào thầy/cô phụ trách lớp IELTS-50-K15, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 3, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
127	YC-202611-0017	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp COMM-A2-K08	Kính gửi Ban Học vụ, giảng viên phụ trách lớp COMM-A2-K08 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
25	KN-202611-0016	COMPLAINT	79	3	TEACHER	GRADE	1	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-65-K26A	Trong buổi sửa bài cuối khóa trên lớp IELTS-65-K26A, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
2	KN-202611-0004	COMPLAINT	14	3	TEACHER	GRADE	1	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-65-K26A	Trong buổi sửa bài cuối khóa trên lớp IELTS-65-K26A, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
48	KN-202611-0054	COMPLAINT	115	7	TEACHER	GRADE	4	Khiếu nại điểm chuyên cần buổi học thứ 7 - Lớp IELTS-65-K26B	Kính chào thầy/cô phụ trách lớp IELTS-65-K26B, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 7, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
64	KN-202611-0062	COMPLAINT	126	8	TEACHER	GRADE	5	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp COMM-A2-K08	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp COMM-A2-K08. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
164	YC-202611-0035	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	9	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp TEENS-B2-K04	Kính gửi Phòng Đào tạo & Học vụ, lớp TEENS-B2-K04 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PROCESSING	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
188	YC-202611-0075	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-50-K15	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-50-K15 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
90	KN-202611-0085	COMPLAINT	137	11	TEACHER	GRADE	6	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp COMM-B1-K09	Kính gửi thầy/cô lớp COMM-B1-K09, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
99	KN-202611-0117	COMPLAINT	223	9	TEACHER	GRADE	8	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp TOEIC-550-K30	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
104	KN-202611-0106	COMPLAINT	168	9	TEACHER	GRADE	8	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp TOEIC-550-K30	Trong buổi sửa bài cuối khóa trên lớp TOEIC-550-K30, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
115	KN-202611-0119	COMPLAINT	191	9	TEACHER	GRADE	8	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp TOEIC-550-K30	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
209	YC-202611-0068	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	34	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp COMM-A2-PAST	Kính gửi Phòng Học vụ, lớp COMM-A2-PAST có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
200	YC-202611-0076	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TOEIC-550-K30	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TOEIC-550-K30, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
10	KN-202611-0012	COMPLAINT	113	3	TEACHER	GRADE	1	Khiếu nại điểm chuyên cần buổi học thứ 5 - Lớp IELTS-65-K26A	Kính chào thầy/cô phụ trách lớp IELTS-65-K26A, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 5, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
3	KN-202611-0022	COMPLAINT	95	4	TEACHER	GRADE	3	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp TOEIC-750-K12	Trong buổi sửa bài cuối khóa trên lớp TOEIC-750-K12, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
20	KN-202611-0028	COMPLAINT	114	4	TEACHER	GRADE	3	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp TOEIC-750-K12	Trong buổi sửa bài cuối khóa trên lớp TOEIC-750-K12, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
33	KN-202611-0042	COMPLAINT	106	7	TEACHER	GRADE	4	Khiếu nại điểm chuyên cần buổi học thứ 3 - Lớp IELTS-65-K26B	Kính chào thầy/cô phụ trách lớp IELTS-65-K26B, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 3, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
73	KN-202611-0071	COMPLAINT	141	11	TEACHER	GRADE	6	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp COMM-B1-K09	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
83	KN-202611-0083	COMPLAINT	175	11	TEACHER	GRADE	6	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp COMM-B1-K09	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
137	YC-202611-0004	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp COMM-B1-K09	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp COMM-B1-K09, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
159	YC-202611-0038	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	11	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp IELTS-65-PAST	Kính gửi Phòng Học vụ, lớp IELTS-65-PAST có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
9	KN-202611-0019	COMPLAINT	117	4	TEACHER	GRADE	3	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp TOEIC-750-K12	Kính gửi thầy/cô lớp TOEIC-750-K12, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
35	KN-202611-0034	COMPLAINT	96	4	TEACHER	GRADE	3	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp TOEIC-750-K12	Trong buổi sửa bài cuối khóa trên lớp TOEIC-750-K12, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PROCESSING	2027-01-22 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
31	KN-202611-0044	COMPLAINT	99	7	TEACHER	GRADE	4	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-65-K26B	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-65-K26B. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
13	KN-202611-0018	COMPLAINT	77	3	TEACHER	GRADE	1	Khiếu nại điểm chuyên cần buổi học thứ 3 - Lớp IELTS-65-K26A	Kính chào thầy/cô phụ trách lớp IELTS-65-K26A, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 3, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
32	KN-202611-0032	COMPLAINT	103	4	TEACHER	GRADE	3	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp TOEIC-750-K12	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp TOEIC-750-K12. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PROCESSING	2027-01-22 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
34	KN-202611-0048	COMPLAINT	101	7	TEACHER	GRADE	4	Khiếu nại điểm chuyên cần buổi học thứ 1 - Lớp IELTS-65-K26B	Kính chào thầy/cô phụ trách lớp IELTS-65-K26B, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 1, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
37	KN-202611-0033	COMPLAINT	81	4	TEACHER	GRADE	3	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp TOEIC-750-K12	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PROCESSING	2027-01-22 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
206	YC-202611-0071	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TOEIC-750-K12	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TOEIC-750-K12, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
193	YC-202611-0078	REQUEST	74	2	ACADEMIC_STAFF	GRADE_UNLOCK	30	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp BUS-ENG-K01	Kính gửi Phòng Học vụ, lớp BUS-ENG-K01 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
7	KN-202611-0010	COMPLAINT	20	3	TEACHER	GRADE	1	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-65-K26A	Trong buổi sửa bài cuối khóa trên lớp IELTS-65-K26A, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
39	KN-202611-0055	COMPLAINT	116	8	TEACHER	GRADE	5	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp COMM-A2-K08	Kính gửi thầy/cô lớp COMM-A2-K08, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PROCESSING	2027-01-12 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
63	KN-202611-0066	COMPLAINT	140	8	TEACHER	GRADE	5	Khiếu nại điểm chuyên cần buổi học thứ 3 - Lớp COMM-A2-K08	Kính chào thầy/cô phụ trách lớp COMM-A2-K08, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 3, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
111	KN-202611-0105	COMPLAINT	163	9	TEACHER	GRADE	8	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp TOEIC-550-K30	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
147	YC-202611-0019	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-50-K15	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-50-K15, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
138	YC-202611-0003	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp COMM-A2-K08	Kính gửi Phòng Học vụ, lớp COMM-A2-K08 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
158	YC-202611-0041	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	35	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp IELTS-50-PAST	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp IELTS-50-PAST, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
173	YC-202611-0056	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	1	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp IELTS-65-K26A	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp IELTS-65-K26A, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
24	KN-202611-0005	COMPLAINT	15	3	TEACHER	GRADE	1	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-65-K26A	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
40	KN-202611-0038	COMPLAINT	122	7	TEACHER	GRADE	4	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-65-K26B	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-65-K26B. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
71	KN-202611-0073	COMPLAINT	133	11	TEACHER	GRADE	6	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp COMM-B1-K09	Kính gửi thầy/cô lớp COMM-B1-K09, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
85	KN-202611-0089	COMPLAINT	157	10	TEACHER	GRADE	7	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-50-K15	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
106	KN-202611-0102	COMPLAINT	156	10	TEACHER	GRADE	7	Khiếu nại điểm chuyên cần buổi học thứ 7 - Lớp IELTS-50-K15	Kính chào thầy/cô phụ trách lớp IELTS-50-K15, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 7, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
123	YC-202611-0021	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	9	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TEENS-B2-K04	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TEENS-B2-K04, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
157	YC-202611-0036	REQUEST	74	2	ACADEMIC_STAFF	GRADE_UNLOCK	30	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp BUS-ENG-K01	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp BUS-ENG-K01, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
201	YC-202611-0070	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-65-K26A	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-65-K26A đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
208	YC-202611-0077	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	9	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp TEENS-B2-K04	Kính gửi Ban Học vụ, giảng viên phụ trách lớp TEENS-B2-K04 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
19	KN-202611-0009	COMPLAINT	19	3	TEACHER	GRADE	1	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-65-K26A	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
49	KN-202611-0053	COMPLAINT	119	7	TEACHER	GRADE	4	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-65-K26B	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
52	KN-202611-0056	COMPLAINT	120	8	TEACHER	GRADE	5	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp COMM-A2-K08	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp COMM-A2-K08. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PROCESSING	2027-01-12 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
55	KN-202611-0058	COMPLAINT	124	8	TEACHER	GRADE	5	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp COMM-A2-K08	Trong buổi sửa bài cuối khóa trên lớp COMM-A2-K08, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PROCESSING	2027-01-12 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
57	KN-202611-0059	COMPLAINT	134	8	TEACHER	GRADE	5	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp COMM-A2-K08	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PROCESSING	2027-01-12 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
179	YC-202611-0047	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp IELTS-50-K15	Kính gửi Ban Học vụ, giảng viên phụ trách lớp IELTS-50-K15 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
1	KN-202611-0025	COMPLAINT	80	4	TEACHER	GRADE	3	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp TOEIC-750-K12	Kính gửi thầy/cô lớp TOEIC-750-K12, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
38	KN-202611-0047	COMPLAINT	112	7	TEACHER	GRADE	4	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-65-K26B	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
74	KN-202611-0079	COMPLAINT	143	11	TEACHER	GRADE	6	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp COMM-B1-K09	Kính gửi thầy/cô lớp COMM-B1-K09, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
101	KN-202611-0110	COMPLAINT	192	9	TEACHER	GRADE	8	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp TOEIC-550-K30	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp TOEIC-550-K30. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
121	YC-202611-0001	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TOEIC-750-K12	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TOEIC-750-K12, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
153	YC-202611-0032	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp COMM-B1-K09	Kính gửi Ban Học vụ, giảng viên phụ trách lớp COMM-B1-K09 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PROCESSING	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
191	YC-202611-0085	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp TOEIC-750-K12	Kính gửi Phòng Đào tạo & Học vụ, lớp TOEIC-750-K12 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
143	YC-202611-0026	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	34	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp COMM-A2-PAST	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp COMM-A2-PAST, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
18	KN-202611-0024	COMPLAINT	125	4	TEACHER	GRADE	3	Khiếu nại điểm chuyên cần buổi học thứ 1 - Lớp TOEIC-750-K12	Kính chào thầy/cô phụ trách lớp TOEIC-750-K12, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 1, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
56	KN-202611-0052	COMPLAINT	121	7	TEACHER	GRADE	4	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-65-K26B	Trong buổi sửa bài cuối khóa trên lớp IELTS-65-K26B, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
69	KN-202611-0065	COMPLAINT	128	8	TEACHER	GRADE	5	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp COMM-A2-K08	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
107	KN-202611-0094	COMPLAINT	144	10	TEACHER	GRADE	7	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-50-K15	Trong buổi sửa bài cuối khóa trên lớp IELTS-50-K15, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
129	YC-202611-0022	REQUEST	74	2	ACADEMIC_STAFF	GRADE_UNLOCK	30	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp BUS-ENG-K01	Kính gửi Ban Học vụ, giảng viên phụ trách lớp BUS-ENG-K01 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
144	YC-202611-0028	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	1	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp IELTS-65-K26A	Kính gửi Phòng Học vụ, lớp IELTS-65-K26A có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
166	YC-202611-0049	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	9	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp TEENS-B2-K04	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp TEENS-B2-K04, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
196	YC-202611-0084	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	1	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-65-K26A	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-65-K26A, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
11	KN-202611-0017	COMPLAINT	105	3	TEACHER	GRADE	1	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-65-K26A	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
60	KN-202611-0049	COMPLAINT	107	7	TEACHER	GRADE	4	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-65-K26B	Kính gửi thầy/cô lớp IELTS-65-K26B, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
81	KN-202611-0076	COMPLAINT	130	11	TEACHER	GRADE	6	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp COMM-B1-K09	Trong buổi sửa bài cuối khóa trên lớp COMM-B1-K09, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
105	KN-202611-0111	COMPLAINT	180	9	TEACHER	GRADE	8	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp TOEIC-550-K30	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
125	YC-202611-0014	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	1	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-65-K26A	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-65-K26A, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
154	YC-202611-0031	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp COMM-A2-K08	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp COMM-A2-K08, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PROCESSING	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
172	YC-202611-0055	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	35	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-50-PAST	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-50-PAST đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
194	YC-202611-0083	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	35	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp IELTS-50-PAST	Kính gửi Phòng Học vụ, lớp IELTS-50-PAST có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
17	KN-202611-0027	COMPLAINT	89	4	TEACHER	GRADE	3	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp TOEIC-750-K12	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
62	KN-202611-0063	COMPLAINT	139	8	TEACHER	GRADE	5	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp COMM-A2-K08	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
82	KN-202611-0082	COMPLAINT	145	11	TEACHER	GRADE	6	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp COMM-B1-K09	Trong buổi sửa bài cuối khóa trên lớp COMM-B1-K09, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
95	KN-202611-0099	COMPLAINT	166	10	TEACHER	GRADE	7	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-50-K15	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
124	YC-202611-0009	REQUEST	54	2	ACADEMIC_STAFF	GRADE_UNLOCK	31	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp COMM-B1-K10	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp COMM-B1-K10, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
145	YC-202611-0007	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	9	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp TEENS-B2-K04	Kính gửi Ban Học vụ, giảng viên phụ trách lớp TEENS-B2-K04 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
161	YC-202611-0034	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp TOEIC-550-K30	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp TOEIC-550-K30, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PROCESSING	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
195	YC-202611-0087	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp COMM-A2-K08	Kính gửi Ban Học vụ, giảng viên phụ trách lớp COMM-A2-K08 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
170	YC-202611-0039	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	33	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp TOEIC-550-PAST	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp TOEIC-550-PAST, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
181	YC-202611-0061	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp IELTS-50-K15	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp IELTS-50-K15, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
22	KN-202611-0029	COMPLAINT	86	4	TEACHER	GRADE	3	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp TOEIC-750-K12	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
61	KN-202611-0067	COMPLAINT	131	8	TEACHER	GRADE	5	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp COMM-A2-K08	Kính gửi thầy/cô lớp COMM-A2-K08, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
84	KN-202611-0086	COMPLAINT	151	11	TEACHER	GRADE	6	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp COMM-B1-K09	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp COMM-B1-K09. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
108	KN-202611-0113	COMPLAINT	210	9	TEACHER	GRADE	8	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp TOEIC-550-K30	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
132	YC-202611-0005	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-50-K15	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-50-K15 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
207	YC-202611-0069	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	35	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-50-PAST	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-50-PAST, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
148	YC-202611-0029	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp TOEIC-750-K12	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp TOEIC-750-K12, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
27	KN-202611-0030	COMPLAINT	93	4	TEACHER	GRADE	3	Khiếu nại điểm chuyên cần buổi học thứ 7 - Lớp TOEIC-750-K12	Kính chào thầy/cô phụ trách lớp TOEIC-750-K12, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 7, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
65	KN-202611-0064	COMPLAINT	161	8	TEACHER	GRADE	5	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp COMM-A2-K08	Trong buổi sửa bài cuối khóa trên lớp COMM-A2-K08, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
102	KN-202611-0095	COMPLAINT	153	10	TEACHER	GRADE	7	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-50-K15	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
113	KN-202611-0120	COMPLAINT	194	9	TEACHER	GRADE	8	Khiếu nại điểm chuyên cần buổi học thứ 1 - Lớp TOEIC-550-K30	Kính chào thầy/cô phụ trách lớp TOEIC-550-K30, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 1, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
149	YC-202611-0015	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp TOEIC-750-K12	Kính gửi Phòng Đào tạo & Học vụ, lớp TOEIC-750-K12 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
135	YC-202611-0013	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	35	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp IELTS-50-PAST	Kính gửi Phòng Học vụ, lớp IELTS-50-PAST có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
156	YC-202611-0033	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp IELTS-50-K15	Kính gửi Phòng Học vụ, lớp IELTS-50-K15 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PROCESSING	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
190	YC-202611-0086	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp IELTS-65-K26B	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp IELTS-65-K26B, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
77	KN-202611-0069	COMPLAINT	165	8	TEACHER	GRADE	5	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp COMM-A2-K08	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
118	KN-202611-0093	COMPLAINT	146	10	TEACHER	GRADE	7	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-50-K15	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
92	KN-202611-0092	COMPLAINT	164	10	TEACHER	GRADE	7	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-50-K15	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-50-K15. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
98	KN-202611-0108	COMPLAINT	159	9	TEACHER	GRADE	8	Khiếu nại điểm chuyên cần buổi học thứ 5 - Lớp TOEIC-550-K30	Kính chào thầy/cô phụ trách lớp TOEIC-550-K30, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 5, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
126	YC-202611-0020	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp TOEIC-550-K30	Kính gửi Phòng Đào tạo & Học vụ, lớp TOEIC-550-K30 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
133	YC-202611-0002	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp IELTS-65-K26B	Kính gửi Ban Học vụ, giảng viên phụ trách lớp IELTS-65-K26B phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
122	YC-202611-0018	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp COMM-B1-K09	Kính gửi Phòng Học vụ, lớp COMM-B1-K09 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
165	YC-202611-0046	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp COMM-B1-K09	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp COMM-B1-K09, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
167	YC-202611-0052	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	11	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp IELTS-65-PAST	Kính gửi Ban Học vụ, giảng viên phụ trách lớp IELTS-65-PAST phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
67	KN-202611-0077	COMPLAINT	135	11	TEACHER	GRADE	6	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp COMM-B1-K09	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
91	KN-202611-0091	COMPLAINT	138	10	TEACHER	GRADE	7	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-50-K15	Kính gửi thầy/cô lớp IELTS-50-K15, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
112	KN-202611-0097	COMPLAINT	148	10	TEACHER	GRADE	7	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-50-K15	Kính gửi thầy/cô lớp IELTS-50-K15, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
136	YC-202611-0011	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	33	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TOEIC-550-PAST	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TOEIC-550-PAST, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
160	YC-202611-0053	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	33	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp TOEIC-550-PAST	Kính gửi Phòng Học vụ, lớp TOEIC-550-PAST có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
186	YC-202611-0073	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp COMM-A2-K08	Kính gửi Phòng Học vụ, lớp COMM-A2-K08 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
204	YC-202611-0090	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp TOEIC-550-K30	Kính gửi Phòng Đào tạo & Học vụ, lớp TOEIC-550-K30 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
109	KN-202611-0114	COMPLAINT	222	9	TEACHER	GRADE	8	Khiếu nại điểm chuyên cần buổi học thứ 3 - Lớp TOEIC-550-K30	Kính chào thầy/cô phụ trách lớp TOEIC-550-K30, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 3, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
103	KN-202611-0116	COMPLAINT	217	9	TEACHER	GRADE	8	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp TOEIC-550-K30	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp TOEIC-550-K30. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
139	YC-202611-0024	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	11	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-65-PAST	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-65-PAST, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
130	YC-202611-0006	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TOEIC-550-K30	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TOEIC-550-K30, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
199	YC-202611-0074	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp COMM-B1-K09	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp COMM-B1-K09, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
198	YC-202611-0080	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	11	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-65-PAST	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-65-PAST đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
162	YC-202611-0045	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp COMM-A2-K08	Kính gửi Phòng Đào tạo & Học vụ, lớp COMM-A2-K08 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
178	YC-202611-0040	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	34	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp COMM-A2-PAST	Kính gửi Phòng Đào tạo & Học vụ, lớp COMM-A2-PAST đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
163	YC-202611-0044	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-65-K26B	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-65-K26B, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
185	YC-202611-0065	REQUEST	54	2	ACADEMIC_STAFF	GRADE_UNLOCK	31	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp COMM-B1-K10	Kính gửi Phòng Đào tạo & Học vụ, lớp COMM-B1-K10 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
68	KN-202611-0075	COMPLAINT	174	11	TEACHER	GRADE	6	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp COMM-B1-K09	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
87	KN-202611-0088	COMPLAINT	147	10	TEACHER	GRADE	7	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-50-K15	Trong buổi sửa bài cuối khóa trên lớp IELTS-50-K15, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
96	KN-202611-0104	COMPLAINT	158	10	TEACHER	GRADE	7	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-50-K15	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-50-K15. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
114	KN-202611-0109	COMPLAINT	176	9	TEACHER	GRADE	8	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp TOEIC-550-K30	Kính gửi thầy/cô lớp TOEIC-550-K30, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
131	YC-202611-0016	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp IELTS-65-K26B	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp IELTS-65-K26B, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
152	YC-202611-0037	REQUEST	54	2	ACADEMIC_STAFF	GRADE_UNLOCK	31	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp COMM-B1-K10	Kính gửi Ban Học vụ, giảng viên phụ trách lớp COMM-B1-K10 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
187	YC-202611-0081	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	33	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp TOEIC-550-PAST	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp TOEIC-550-PAST, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
16	KN-202611-0002	COMPLAINT	12	3	TEACHER	GRADE	1	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-65-K26A	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-65-K26A. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
8	KN-202611-0003	COMPLAINT	13	3	TEACHER	GRADE	1	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-65-K26A	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
94	KN-202611-0096	COMPLAINT	149	10	TEACHER	GRADE	7	Khiếu nại điểm chuyên cần buổi học thứ 1 - Lớp IELTS-50-K15	Kính chào thầy/cô phụ trách lớp IELTS-50-K15, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 1, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
140	YC-202611-0023	REQUEST	54	2	ACADEMIC_STAFF	GRADE_UNLOCK	31	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp COMM-B1-K10	Kính gửi Phòng Học vụ, lớp COMM-B1-K10 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
155	YC-202611-0051	REQUEST	54	2	ACADEMIC_STAFF	GRADE_UNLOCK	31	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp COMM-B1-K10	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp COMM-B1-K10, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
176	YC-202611-0043	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp TOEIC-750-K12	Kính gửi Phòng Học vụ, lớp TOEIC-750-K12 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
210	YC-202611-0066	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	11	Đề nghị mở lại sổ điểm để giải quyết khiếu nại học viên - Lớp IELTS-65-PAST	Kính gửi Ban Học vụ, sau khi rà soát đơn khiếu nại của học viên lớp IELTS-65-PAST, giảng viên nhận thấy có sự nhầm lẫn trong quá trình nhập điểm thành phần. Kính đề nghị Quản trị viên/Học vụ mở lại sổ điểm lớp trong thời hạn 48 giờ để điều chỉnh chính xác.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
182	YC-202611-0062	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp TOEIC-550-K30	Kính gửi Ban Học vụ, giảng viên phụ trách lớp TOEIC-550-K30 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
203	YC-202611-0089	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	7	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp IELTS-50-K15	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp IELTS-50-K15, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
151	YC-202611-0050	REQUEST	74	2	ACADEMIC_STAFF	GRADE_UNLOCK	30	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp BUS-ENG-K01	Kính gửi Phòng Đào tạo & Học vụ, lớp BUS-ENG-K01 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
183	YC-202611-0067	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	33	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp TOEIC-550-PAST	Kính gửi Ban Học vụ, giảng viên phụ trách lớp TOEIC-550-PAST phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
211	KN-202611-0211	COMPLAINT	5	3	TEACHER	GRADE	1	Khiếu nại điểm chuyên cần học kỳ 1	Em có mặt đầy đủ các buổi học nhưng điểm chuyên cần chỉ có 7.0, xin thầy kiểm tra lại.	RESOLVED	2026-12-06 23:59:59.999999	2026-11-19 15:49:45.529095	2026-11-19 15:49:45.622122	f
212	YC-202611-0212	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lớp IELTS-65-K26A	Cần mở sổ điểm để cập nhật điểm chuyên cần đã giải quyết khiếu nại cho học viên.	APPROVED	\N	2026-11-19 15:49:45.645862	2026-11-19 15:49:45.675426	f
213	YC-202611-0213	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lần 2 lớp IELTS-65-K26A	Yêu cầu mở bổ sung.	REJECTED	\N	2026-11-19 15:49:45.697771	2026-11-19 15:49:45.715447	f
214	KN-202611-0214	COMPLAINT	5	3	TEACHER	GRADE	1	Khiếu nại điểm chuyên cần học kỳ 1	Em có mặt đầy đủ các buổi học nhưng điểm chuyên cần chỉ có 7.0, xin thầy kiểm tra lại.	RESOLVED	2026-12-06 23:59:59.999999	2026-11-19 15:52:10.391145	2026-11-19 15:52:10.493203	f
215	YC-202611-0215	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lớp IELTS-65-K26A	Cần mở sổ điểm để cập nhật điểm chuyên cần đã giải quyết khiếu nại cho học viên.	APPROVED	\N	2026-11-19 15:52:10.511044	2026-11-19 15:52:10.541456	f
216	YC-202611-0216	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lần 2 lớp IELTS-65-K26A	Yêu cầu mở bổ sung.	REJECTED	\N	2026-11-19 15:52:10.565605	2026-11-19 15:52:10.583571	f
217	KN-202611-0217	COMPLAINT	5	3	TEACHER	GRADE	1	Khiếu nại điểm chuyên cần học kỳ 1	Em có mặt đầy đủ các buổi học nhưng điểm chuyên cần chỉ có 7.0, xin thầy kiểm tra lại.	RESOLVED	2026-12-07 23:59:59.999999	2026-11-20 03:16:13.473767	2026-11-20 03:16:13.58231	f
218	YC-202611-0218	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lớp IELTS-65-K26A	Cần mở sổ điểm để cập nhật điểm chuyên cần đã giải quyết khiếu nại cho học viên.	APPROVED	\N	2026-11-20 03:16:13.60391	2026-11-20 03:16:13.640006	f
219	YC-202611-0219	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điểm lần 2 lớp IELTS-65-K26A	Yêu cầu mở bổ sung.	REJECTED	\N	2026-11-20 03:16:13.667795	2026-11-20 03:16:13.688125	f
220	YC-202611-0220	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Regression unlock request	Regression test content	APPROVED	\N	2026-11-20 04:32:10.209407	2026-11-20 04:32:10.240503	f
221	KN-202611-0221	COMPLAINT	5	3	TEACHER	GRADE	1	Regression grade complaint	Regression complaint content	PENDING	2026-12-07 23:59:59.999999	2026-11-20 04:32:10.282544	2026-11-20 04:32:10.283421	f
222	YC-202611-0222	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Regression unlock request	Regression test content	APPROVED	\N	2026-11-20 04:33:28.895255	2026-11-20 04:33:28.925513	f
223	KN-202611-0223	COMPLAINT	5	3	TEACHER	GRADE	1	Regression grade complaint	Regression complaint content	PENDING	2026-12-07 23:59:59.999999	2026-11-20 04:33:28.965553	2026-11-20 04:33:28.966367	f
224	YC-202611-0224	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 3	Burst content 3 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:35:39.348854	2026-11-20 04:35:39.352255	f
225	YC-202611-0225	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 4	Burst content 4 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:35:39.381995	2026-11-20 04:35:39.382887	f
226	YC-202611-0226	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 5	Burst content 5 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:35:39.395027	2026-11-20 04:35:39.39591	f
227	YC-202611-0227	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 1	Burst content 1 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:35:39.354356	2026-11-20 04:35:39.402573	f
228	YC-202611-0228	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 0	Burst content 0 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:35:39.353507	2026-11-20 04:35:39.436179	f
229	YC-202611-0229	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 2	Burst content 2 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:35:39.403978	2026-11-20 04:35:39.452092	f
230	YC-202611-0230	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 1	Burst content 1 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:36:43.04892	2026-11-20 04:36:43.052637	f
231	YC-202611-0231	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 0	Burst content 0 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:36:43.052951	2026-11-20 04:36:43.062471	f
232	YC-202611-0232	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 4	Burst content 4 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:36:43.071168	2026-11-20 04:36:43.072306	f
233	YC-202611-0233	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 3	Burst content 3 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:36:43.053289	2026-11-20 04:36:43.081372	f
234	YC-202611-0234	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 2	Burst content 2 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:36:43.051511	2026-11-20 04:36:43.096484	f
202	YC-202611-0088	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp COMM-B1-K09	Kính gửi Phòng Học vụ, lớp COMM-B1-K09 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
72	KN-202611-0070	COMPLAINT	132	8	TEACHER	GRADE	5	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp COMM-A2-K08	Trong buổi sửa bài cuối khóa trên lớp COMM-A2-K08, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-12 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
119	KN-202611-0107	COMPLAINT	173	9	TEACHER	GRADE	8	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp TOEIC-550-K30	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
110	KN-202611-0101	COMPLAINT	167	10	TEACHER	GRADE	7	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-50-K15	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
146	YC-202611-0012	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	34	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp COMM-A2-PAST	Kính gửi Ban Học vụ, giảng viên phụ trách lớp COMM-A2-PAST phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PENDING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
128	YC-202611-0027	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	35	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp IELTS-50-PAST	Kính gửi Ban Học vụ, giảng viên phụ trách lớp IELTS-50-PAST phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
169	YC-202611-0048	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	8	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp TOEIC-550-K30	Kính gửi Phòng Học vụ, lớp TOEIC-550-K30 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
192	YC-202611-0082	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	34	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp COMM-A2-PAST	Kính gửi Ban Học vụ, giảng viên phụ trách lớp COMM-A2-PAST phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
12	KN-202611-0008	COMPLAINT	18	3	TEACHER	GRADE	1	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-65-K26A	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-65-K26A. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
235	YC-202611-0235	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 5	Burst content 5 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:36:43.080652	2026-11-20 04:36:43.115165	f
236	YC-202611-0236	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 0	Burst content 0 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:38:10.585812	2026-11-20 04:38:10.588221	f
237	YC-202611-0237	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 2	Burst content 2 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:38:10.586642	2026-11-20 04:38:10.597959	f
238	YC-202611-0238	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 4	Burst content 4 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:38:10.621591	2026-11-20 04:38:10.622515	f
239	YC-202611-0239	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 5	Burst content 5 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:38:10.636574	2026-11-20 04:38:10.637507	f
240	YC-202611-0240	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 3	Burst content 3 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:38:10.5986	2026-11-20 04:38:10.644573	f
241	YC-202611-0241	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 1	Burst content 1 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:38:10.643848	2026-11-20 04:38:10.676548	f
242	YC-202611-0242	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Regression unlock request	Regression test content	APPROVED	\N	2026-11-20 04:53:45.488354	2026-11-20 04:53:45.519148	f
243	KN-202611-0243	COMPLAINT	5	3	TEACHER	GRADE	1	Regression grade complaint	Regression complaint content	PENDING	2026-12-07 23:59:59.999999	2026-11-20 04:53:45.566586	2026-11-20 04:53:45.567582	f
244	YC-202611-0244	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 0	Burst content 0 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:53:54.154395	2026-11-20 04:53:54.157537	f
245	YC-202611-0245	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 4	Burst content 4 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:53:54.178337	2026-11-20 04:53:54.179094	f
246	YC-202611-0246	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 5	Burst content 5 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:53:54.191671	2026-11-20 04:53:54.192628	f
247	YC-202611-0247	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 2	Burst content 2 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:53:54.155394	2026-11-20 04:53:54.214823	f
248	YC-202611-0248	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 3	Burst content 3 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:53:54.158188	2026-11-20 04:53:54.232578	f
249	YC-202611-0249	REQUEST	5	\N	ACADEMIC_STAFF	ENROLLMENT	\N	Burst uniqueness probe 1	Burst content 1 for ticket-code uniqueness	PENDING	\N	2026-11-20 04:53:54.158581	2026-11-20 04:53:54.248215	f
250	KN-202611-0250	COMPLAINT	5	3	TEACHER	GRADE	1	Test	Test content	PENDING	2027-01-31 23:59:59.999999	2026-11-20 16:04:46.217924	2026-11-20 16:04:46.221569	f
251	YC-202611-0251	REQUEST	3	\N	ACADEMIC_STAFF	GRADE_UNLOCK	1	Test unlock	Test reason	PENDING	\N	2026-11-20 16:05:50.363548	2026-11-20 16:05:50.373917	f
252	YC-202611-0252	REQUEST	5	6	PARENT	OTHER	\N	BẢO MẬT: Báo cáo học tập riêng cho Phụ huynh A [1795194073]	Kính gửi Phụ huynh A, đây là thông tin điểm thi và học phí riêng tư của con em quý vị [1795194073].	PENDING	\N	2026-11-20 17:01:13.210479	2026-11-20 17:01:13.221217	f
253	YC-202611-4073	REQUEST	1	\N	PARENT	OTHER	\N	THÔNG BÁO CHUNG NGHỈ LỄ CHO TOÀN THỂ PHỤ HUYNH [1795194073]	Kính gửi Quý phụ huynh, trung tâm thông báo lịch nghỉ lễ chính thức.	PENDING	\N	2026-11-20 17:01:13.268416	2026-11-20 17:01:13.26842	f
5	KN-202611-0006	COMPLAINT	16	3	TEACHER	GRADE	1	Khiếu nại điểm chuyên cần buổi học thứ 7 - Lớp IELTS-65-K26A	Kính chào thầy/cô phụ trách lớp IELTS-65-K26A, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 7, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
177	YC-202611-0059	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	5	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp COMM-A2-K08	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp COMM-A2-K08, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
184	YC-202611-0063	REQUEST	10	2	ACADEMIC_STAFF	GRADE_UNLOCK	9	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp TEENS-B2-K04	Kính gửi Phòng Học vụ, lớp TEENS-B2-K04 có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
21	KN-202611-0023	COMPLAINT	85	4	TEACHER	GRADE	3	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp TOEIC-750-K12	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
44	KN-202611-0035	COMPLAINT	91	4	TEACHER	GRADE	3	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp TOEIC-750-K12	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PROCESSING	2027-01-22 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
175	YC-202611-0060	REQUEST	11	2	ACADEMIC_STAFF	GRADE_UNLOCK	6	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp COMM-B1-K09	Kính gửi Phòng Đào tạo & Học vụ, lớp COMM-B1-K09 đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
197	YC-202611-0064	REQUEST	74	2	ACADEMIC_STAFF	GRADE_UNLOCK	30	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp BUS-ENG-K01	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp BUS-ENG-K01, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
28	KN-202611-0021	COMPLAINT	78	4	TEACHER	GRADE	3	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp TOEIC-750-K12	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
29	KN-202611-0026	COMPLAINT	94	4	TEACHER	GRADE	3	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp TOEIC-750-K12	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp TOEIC-750-K12. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
43	KN-202611-0037	COMPLAINT	92	7	TEACHER	GRADE	4	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-65-K26B	Kính gửi thầy/cô lớp IELTS-65-K26B, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
36	KN-202611-0041	COMPLAINT	104	7	TEACHER	GRADE	4	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-65-K26B	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
53	KN-202611-0045	COMPLAINT	98	7	TEACHER	GRADE	4	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-65-K26B	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
51	KN-202611-0046	COMPLAINT	109	7	TEACHER	GRADE	4	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-65-K26B	Trong buổi sửa bài cuối khóa trên lớp IELTS-65-K26B, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
50	KN-202611-0040	COMPLAINT	111	7	TEACHER	GRADE	4	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-65-K26B	Trong buổi sửa bài cuối khóa trên lớp IELTS-65-K26B, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
23	KN-202611-0007	COMPLAINT	17	3	TEACHER	GRADE	1	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-65-K26A	Kính gửi thầy/cô lớp IELTS-65-K26A, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
30	KN-202611-0011	COMPLAINT	88	3	TEACHER	GRADE	1	Cột điểm bài kiểm tra bổ sung chưa được cập nhật - Lớp IELTS-65-K26A	Em đã hoàn thành bài thi bổ sung đợt 2 vào ngày 12 vừa qua dưới sự giám sát của thầy/cô, nhưng đến nay cột điểm cuối kỳ của em trên hệ thống vẫn đang để trống. Em làm đơn này kính mong thầy/cô vào điểm giúp em để kịp xét tiến trình khóa học.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
180	YC-202611-0058	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Đề nghị mở sổ điểm bổ sung kết quả thi bù đợt 2 - Lớp IELTS-65-K26B	Kính gửi Phòng Học vụ, lớp IELTS-65-K26B có 2 học viên vắng thi có phép đã hoàn thành bài thi bù đợt 2 vào tuần qua. Nay giảng viên đã chấm xong bài thi, kính đề nghị mở sổ điểm để hoàn thiện kết quả học tập cho các em.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
205	YC-202611-0079	REQUEST	54	2	ACADEMIC_STAFF	GRADE_UNLOCK	31	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp COMM-B1-K10	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp COMM-B1-K10, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	REJECTED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
79	KN-202611-0080	COMPLAINT	172	11	TEACHER	GRADE	6	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp COMM-B1-K09	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp COMM-B1-K09. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
75	KN-202611-0072	COMPLAINT	127	11	TEACHER	GRADE	6	Khiếu nại điểm chuyên cần buổi học thứ 1 - Lớp COMM-B1-K09	Kính chào thầy/cô phụ trách lớp COMM-B1-K09, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 1, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
120	KN-202611-0103	COMPLAINT	160	10	TEACHER	GRADE	7	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-50-K15	Kính gửi thầy/cô lớp IELTS-50-K15, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
150	YC-202611-0030	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp IELTS-65-K26B	Kính gửi Phòng Đào tạo & Học vụ, lớp IELTS-65-K26B đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
171	YC-202611-0054	REQUEST	8	2	ACADEMIC_STAFF	GRADE_UNLOCK	34	Báo cáo sai sót và xin mở sổ điều chỉnh sau khóa sổ - Lớp COMM-A2-PAST	Kính gửi Phòng Học vụ, do sơ suất trong lúc nhập liệu hàng loạt tại lớp COMM-A2-PAST, giảng viên đã hoán đổi điểm giữa kỳ và điểm chuyên cần của học viên. Giảng viên kính đề nghị mở lại sổ điểm để khắc phục sai sót, cam kết kiểm tra kỹ lưỡng trước khi khóa sổ lại.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
41	KN-202611-0036	COMPLAINT	97	4	TEACHER	GRADE	3	Khiếu nại điểm chuyên cần buổi học thứ 5 - Lớp TOEIC-750-K12	Kính chào thầy/cô phụ trách lớp TOEIC-750-K12, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 5, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	PROCESSING	2027-01-22 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
80	KN-202611-0074	COMPLAINT	169	11	TEACHER	GRADE	6	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp COMM-B1-K09	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp COMM-B1-K09. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
174	YC-202611-0057	REQUEST	4	2	ACADEMIC_STAFF	GRADE_UNLOCK	3	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp TOEIC-750-K12	Kính gửi Ban Học vụ, giảng viên phụ trách lớp TOEIC-750-K12 phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
26	KN-202611-0014	COMPLAINT	84	3	TEACHER	GRADE	1	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-65-K26A	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-65-K26A. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
15	KN-202611-0013	COMPLAINT	82	3	TEACHER	GRADE	1	Đề nghị kiểm tra lại điểm bài thi giữa kỳ môn Writing - Lớp IELTS-65-K26A	Kính gửi thầy/cô lớp IELTS-65-K26A, em xin phép hỏi về bài kiểm tra giữa kỳ Task 1 vừa qua. Em đối chiếu với barem mẫu của trung tâm thấy bài làm đạt tiêu chí tương đương band 7.0, nhưng điểm nhập lên hệ thống là 6.0. Kính mong thầy/cô rà soát lại bài thi giúp em.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
58	KN-202611-0039	COMPLAINT	102	7	TEACHER	GRADE	4	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-65-K26B	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
78	KN-202611-0078	COMPLAINT	142	11	TEACHER	GRADE	6	Khiếu nại điểm chuyên cần buổi học thứ 7 - Lớp COMM-B1-K09	Kính chào thầy/cô phụ trách lớp COMM-B1-K09, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 7, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
88	KN-202611-0087	COMPLAINT	170	10	TEACHER	GRADE	7	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-50-K15	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
93	KN-202611-0112	COMPLAINT	183	9	TEACHER	GRADE	8	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp TOEIC-550-K30	Trong buổi sửa bài cuối khóa trên lớp TOEIC-550-K30, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
189	YC-202611-0072	REQUEST	7	2	ACADEMIC_STAFF	GRADE_UNLOCK	4	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp IELTS-65-K26B	Kính gửi Ban Học vụ, giảng viên phụ trách lớp IELTS-65-K26B phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.976	2026-11-21 07:32:59.994	f
46	KN-202611-0050	COMPLAINT	108	7	TEACHER	GRADE	4	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp IELTS-65-K26B	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp IELTS-65-K26B. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
76	KN-202611-0081	COMPLAINT	171	11	TEACHER	GRADE	6	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp COMM-B1-K09	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
168	YC-202611-0042	REQUEST	3	2	ACADEMIC_STAFF	GRADE_UNLOCK	1	Yêu cầu mở sổ điều chỉnh điểm kiểm tra định kỳ - Lớp IELTS-65-K26A	Kính gửi Ban Học vụ, giảng viên phụ trách lớp IELTS-65-K26A phát hiện chấm sót phần câu hỏi tự luận mở rộng bài kiểm tra số 2 của 3 học viên. Giảng viên đề nghị mở sổ điểm để cập nhật điểm chính xác theo barem chấm thi đã được phê duyệt.	APPROVED	\N	2026-11-21 07:06:55.938	2026-11-21 07:32:59.968	f
4	KN-202611-0015	COMPLAINT	90	3	TEACHER	GRADE	1	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-65-K26A	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PENDING	2027-01-31 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
14	KN-202611-0020	COMPLAINT	123	4	TEACHER	GRADE	3	Phúc khảo điểm thi cuối khóa kỹ năng Speaking - Lớp TOEIC-750-K12	Em làm đơn này xin phúc khảo phần thi Speaking kết thúc học phần lớp TOEIC-750-K12. Hôm thi em đã hoàn thành cả 3 phần thi với sự phản xạ lưu loát, nhưng điểm thi cuối kỳ ghi nhận chỉ đạt 5.5. Em xin phép được đề nghị chấm lại bản thu âm ạ.	PENDING	2027-01-22 00:00:00	2026-11-21 07:06:55.769	2026-11-21 07:32:59.884	f
45	KN-202611-0051	COMPLAINT	110	7	TEACHER	GRADE	4	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp IELTS-65-K26B	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PROCESSING	2027-02-17 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
54	KN-202611-0057	COMPLAINT	118	8	TEACHER	GRADE	5	Kiểm tra lại công thức tính điểm tổng kết học phần - Lớp COMM-A2-K08	Dạ thưa thầy/cô, điểm chuyên cần của em là 9.5, giữa kỳ 8.0, cuối kỳ 8.5 nhưng điểm tổng kết trên bảng điểm lại hiển thị là 7.4. Hình như hệ thống đang tính sai trọng số điểm giữa kỳ và cuối kỳ, mong thầy/cô kiểm tra lại giúp em.	PROCESSING	2027-01-12 00:00:00	2026-11-21 07:06:55.787	2026-11-21 07:32:59.903	f
116	KN-202611-0100	COMPLAINT	155	10	TEACHER	GRADE	7	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp IELTS-50-K15	Trong buổi sửa bài cuối khóa trên lớp IELTS-50-K15, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	RESOLVED	2027-01-25 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
117	KN-202611-0118	COMPLAINT	177	9	TEACHER	GRADE	8	Điểm hiển thị trên hệ thống không đúng với kết quả đã công bố - Lớp TOEIC-550-K30	Trong buổi sửa bài cuối khóa trên lớp TOEIC-550-K30, thầy/cô công bố điểm tổng kết của em là 8.0 (Đạt), nhưng khi em đăng nhập vào hệ thống thì bảng điểm lại hiển thị điểm 6.5 và trạng thái FAILED. Em kính mong thầy/cô cập nhật lại đúng kết quả.	CLOSED	2027-01-22 00:00:00	2026-11-21 07:06:55.887	2026-11-21 07:32:59.938	f
86	KN-202611-0084	COMPLAINT	136	11	TEACHER	GRADE	6	Khiếu nại điểm chuyên cần buổi học thứ 5 - Lớp COMM-B1-K09	Kính chào thầy/cô phụ trách lớp COMM-B1-K09, em là học viên của lớp. Em có đi học và điểm danh đầy đủ buổi học số 5, nhưng trên bảng điểm của em bị ghi nhận vắng và trừ điểm chuyên cần. Kính mong thầy/cô kiểm tra lại sổ điểm danh lớp giúp em ạ.	RESOLVED	2027-01-29 00:00:00	2026-11-21 07:06:55.853	2026-11-21 07:32:59.922	f
142	YC-202611-0025	REQUEST	9	2	ACADEMIC_STAFF	GRADE_UNLOCK	33	Yêu cầu mở sổ điểm lần đầu học kỳ - Lớp TOEIC-550-PAST	Kính gửi Phòng Đào tạo & Học vụ, lớp TOEIC-550-PAST đã kết thúc chương trình giảng dạy. Giảng viên kính đề nghị Phòng Học vụ phê duyệt mở sổ điểm đợt 1 để giảng viên tiến hành nhập điểm đánh giá quá trình và điểm thi cuối khóa cho học viên.	PROCESSING	\N	2026-11-21 07:06:55.919	2026-11-21 07:32:59.954	f
\.


--
-- Data for Name: DON_THU_PHAN_HOI; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DON_THU_PHAN_HOI" ("MaPhanHoi", "MaDon", "MaNguoiGui", "NoiDung", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
3	35	4	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.809	2026-11-21 07:06:55.809	f
21	40	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.822	2026-11-21 07:06:55.822	f
32	53	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.835	2026-11-21 07:06:55.835	f
49	41	97	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.843	2026-11-21 07:06:55.843	f
70	71	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.872	2026-11-21 07:06:55.872	f
91	62	8	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
112	78	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
138	111	9	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
158	118	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
167	112	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.908	2026-11-21 07:06:55.908	f
186	142	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.93	2026-11-21 07:06:55.93	f
203	157	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Ngô Thanh Nghĩa theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
234	185	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Dương Mai Nhi theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
244	208	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.99	2026-11-21 07:06:55.99	f
1	42	4	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.809	2026-11-21 07:06:55.809	f
11	51	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.817	2026-11-21 07:06:55.817	f
26	38	112	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.832	2026-11-21 07:06:55.832	f
37	56	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.837	2026-11-21 07:06:55.837	f
46	47	100	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.841	2026-11-21 07:06:55.841	f
67	68	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.871	2026-11-21 07:06:55.871	f
84	88	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
106	81	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
130	107	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
150	91	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.904	2026-11-21 07:06:55.904	f
197	162	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Trần Diễm My, CELTA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.95	2026-11-21 07:06:55.95	f
239	184	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.988	2026-11-21 07:06:55.988	f
2	32	4	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.808	2026-11-21 07:06:55.808	f
20	37	4	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.822	2026-11-21 07:06:55.822	f
29	39	116	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.834	2026-11-21 07:06:55.834	f
43	51	109	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.84	2026-11-21 07:06:55.84	f
77	81	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
99	73	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
116	83	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
146	109	222	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.903	2026-11-21 07:06:55.903	f
193	171	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Trần Diễm My, CELTA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.949	2026-11-21 07:06:55.949	f
217	176	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Nguyễn Thị Mai theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.96	2026-11-21 07:06:55.96	f
238	197	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Ngô Thanh Nghĩa theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.988	2026-11-21 07:06:55.988	f
8	34	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.812	2026-11-21 07:06:55.812	f
15	50	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.816	2026-11-21 07:06:55.816	f
16	46	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.819	2026-11-21 07:06:55.819	f
33	55	8	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.836	2026-11-21 07:06:55.836	f
39	54	8	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.838	2026-11-21 07:06:55.838	f
53	58	102	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.845	2026-11-21 07:06:55.845	f
56	57	134	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.845	2026-11-21 07:06:55.845	f
59	56	121	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.846	2026-11-21 07:06:55.846	f
62	73	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.87	2026-11-21 07:06:55.87	f
66	69	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.872	2026-11-21 07:06:55.872	f
75	70	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.873	2026-11-21 07:06:55.873	f
87	86	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
88	84	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
101	80	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.878	2026-11-21 07:06:55.878	f
107	70	8	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
111	65	8	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.88	2026-11-21 07:06:55.88	f
120	90	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
122	94	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.898	2026-11-21 07:06:55.898	f
124	110	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
139	92	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
143	95	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.901	2026-11-21 07:06:55.901	f
147	94	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.904	2026-11-21 07:06:55.904	f
153	104	168	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.905	2026-11-21 07:06:55.905	f
162	100	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
170	115	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.907	2026-11-21 07:06:55.907	f
187	144	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.932	2026-11-21 07:06:55.932	f
192	158	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.949	2026-11-21 07:06:55.949	f
194	151	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Ngô Thanh Nghĩa theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.949	2026-11-21 07:06:55.949	f
204	166	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
207	164	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.952	2026-11-21 07:06:55.952	f
208	169	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Đỗ Gia Bảo, IELTS 8.5 theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.952	2026-11-21 07:06:55.952	f
209	161	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.952	2026-11-21 07:06:55.952	f
214	175	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Vũ Quốc An, TESOL theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.955	2026-11-21 07:06:55.955	f
215	177	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Trần Diễm My, CELTA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.959	2026-11-21 07:06:55.959	f
9	49	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.812	2026-11-21 07:06:55.812	f
17	48	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.818	2026-11-21 07:06:55.818	f
25	36	104	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.832	2026-11-21 07:06:55.832	f
35	58	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.836	2026-11-21 07:06:55.836	f
45	44	91	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.841	2026-11-21 07:06:55.841	f
52	33	106	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.844	2026-11-21 07:06:55.844	f
60	54	118	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.846	2026-11-21 07:06:55.846	f
78	72	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
80	82	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
81	85	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
93	66	8	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
100	63	8	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
109	79	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
123	93	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.898	2026-11-21 07:06:55.898	f
133	108	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
137	103	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
152	98	159	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.904	2026-11-21 07:06:55.904	f
155	107	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.905	2026-11-21 07:06:55.905	f
157	99	223	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
168	116	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.908	2026-11-21 07:06:55.908	f
175	111	9	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.907	2026-11-21 07:06:55.907	f
177	118	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.911	2026-11-21 07:06:55.911	f
183	129	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.929	2026-11-21 07:06:55.929	f
188	143	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.932	2026-11-21 07:06:55.932	f
190	148	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.934	2026-11-21 07:06:55.934	f
191	154	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.949	2026-11-21 07:06:55.949	f
196	170	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Đỗ Gia Bảo, IELTS 8.5 theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.95	2026-11-21 07:06:55.95	f
198	160	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Đỗ Gia Bảo, IELTS 8.5 theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.95	2026-11-21 07:06:55.95	f
199	156	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
201	155	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Dương Mai Nhi theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
210	152	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Dương Mai Nhi theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.952	2026-11-21 07:06:55.952	f
213	174	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Nguyễn Thị Mai theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.954	2026-11-21 07:06:55.954	f
251	211	3	Thầy đã rà soát lại sổ điểm danh, đúng là buổi số 3 có ghi nhận nhầm.	2026-11-19 15:49:45.609271	2026-11-19 15:49:45.609273	f
4	38	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.81	2026-11-21 07:06:55.81	f
57	60	107	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.845	2026-11-21 07:06:55.845	f
68	63	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.872	2026-11-21 07:06:55.872	f
89	89	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
105	75	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
140	97	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.901	2026-11-21 07:06:55.901	f
160	119	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
176	119	173	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.911	2026-11-21 07:06:55.911	f
202	168	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Lê Hoàng Nam (Teacher) theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
233	194	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
242	202	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.989	2026-11-21 07:06:55.989	f
12	43	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.816	2026-11-21 07:06:55.816	f
13	44	4	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.818	2026-11-21 07:06:55.818	f
24	31	99	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.832	2026-11-21 07:06:55.832	f
34	57	8	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.836	2026-11-21 07:06:55.836	f
36	60	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.837	2026-11-21 07:06:55.837	f
48	40	122	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.842	2026-11-21 07:06:55.842	f
50	52	120	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.843	2026-11-21 07:06:55.843	f
69	77	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.872	2026-11-21 07:06:55.872	f
72	75	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.872	2026-11-21 07:06:55.872	f
74	80	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.873	2026-11-21 07:06:55.873	f
90	90	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
95	61	8	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.876	2026-11-21 07:06:55.876	f
94	77	8	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
108	72	8	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
113	87	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
115	88	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
125	109	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
128	96	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
136	106	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
142	112	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.901	2026-11-21 07:06:55.901	f
156	93	183	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
159	114	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
164	92	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
172	103	217	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.907	2026-11-21 07:06:55.907	f
178	114	176	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.911	2026-11-21 07:06:55.911	f
184	140	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.929	2026-11-21 07:06:55.929	f
185	139	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.929	2026-11-21 07:06:55.929	f
189	150	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.932	2026-11-21 07:06:55.932	f
195	163	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên David Wilson, M.Ed theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.95	2026-11-21 07:06:55.95	f
200	165	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Vũ Quốc An, TESOL theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
205	153	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.951	2026-11-21 07:06:55.951	f
206	167	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Lê Hoàng Nam (Teacher) theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.952	2026-11-21 07:06:55.952	f
211	159	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Lê Hoàng Nam (Teacher) theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.953	2026-11-21 07:06:55.953	f
212	172	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.954	2026-11-21 07:06:55.954	f
5	31	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.811	2026-11-21 07:06:55.811	f
10	47	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.815	2026-11-21 07:06:55.815	f
19	41	4	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.824	2026-11-21 07:06:55.824	f
22	33	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.819	2026-11-21 07:06:55.819	f
23	42	87	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.83	2026-11-21 07:06:55.83	f
28	32	103	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.833	2026-11-21 07:06:55.833	f
31	49	119	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.835	2026-11-21 07:06:55.835	f
38	59	8	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.837	2026-11-21 07:06:55.837	f
42	45	110	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.84	2026-11-21 07:06:55.84	f
47	43	92	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.842	2026-11-21 07:06:55.842	f
51	37	81	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.844	2026-11-21 07:06:55.844	f
71	67	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.872	2026-11-21 07:06:55.872	f
73	74	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.873	2026-11-21 07:06:55.873	f
79	79	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
82	76	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
92	69	8	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
97	68	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
96	64	8	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
103	82	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.878	2026-11-21 07:06:55.878	f
117	85	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
118	86	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.882	2026-11-21 07:06:55.882	f
119	84	11	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.882	2026-11-21 07:06:55.882	f
121	104	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.898	2026-11-21 07:06:55.898	f
126	102	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
127	91	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
131	105	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
141	117	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.902	2026-11-21 07:06:55.902	f
144	113	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.902	2026-11-21 07:06:55.902	f
149	102	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.904	2026-11-21 07:06:55.904	f
151	96	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.904	2026-11-21 07:06:55.904	f
163	106	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.907	2026-11-21 07:06:55.907	f
165	97	185	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.907	2026-11-21 07:06:55.907	f
169	113	194	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.908	2026-11-21 07:06:55.908	f
174	117	177	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.908	2026-11-21 07:06:55.908	f
180	115	191	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.914	2026-11-21 07:06:55.914	f
181	123	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.928	2026-11-21 07:06:55.928	f
6	39	8	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.811	2026-11-21 07:06:55.811	f
7	36	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.811	2026-11-21 07:06:55.811	f
14	45	7	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.819	2026-11-21 07:06:55.819	f
18	52	8	Thầy/Cô đã tiếp nhận đơn của em. Thầy/Cô đang rà soát lại sổ điểm và bài kiểm tra lưu trữ, dự kiến phản hồi trong 24-48 giờ tới.	2026-11-21 07:06:55.821	2026-11-21 07:06:55.821	f
27	35	96	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.832	2026-11-21 07:06:55.832	f
30	34	101	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.834	2026-11-21 07:06:55.834	f
40	46	108	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.838	2026-11-21 07:06:55.838	f
41	50	111	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.839	2026-11-21 07:06:55.839	f
44	48	115	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.841	2026-11-21 07:06:55.841	f
54	55	124	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.844	2026-11-21 07:06:55.844	f
55	53	98	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.845	2026-11-21 07:06:55.845	f
58	59	129	Dạ em cảm ơn thầy/cô nhiều ạ, em sẵn sàng nộp lại bài làm bản cứng nếu thầy/cô cần đối chiếu.	2026-11-21 07:06:55.845	2026-11-21 07:06:55.845	f
61	62	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.87	2026-11-21 07:06:55.87	f
63	61	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.87	2026-11-21 07:06:55.87	f
64	66	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.87	2026-11-21 07:06:55.87	f
65	64	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.87	2026-11-21 07:06:55.87	f
76	78	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.874	2026-11-21 07:06:55.874	f
83	87	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
85	83	11	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
86	65	8	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.875	2026-11-21 07:06:55.875	f
98	71	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.877	2026-11-21 07:06:55.877	f
102	67	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.878	2026-11-21 07:06:55.878	f
104	74	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.879	2026-11-21 07:06:55.879	f
110	76	11	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
114	89	10	[KẾT QUẢ XỬ LÝ] Sau khi chấm phúc khảo và đối soát sổ theo dõi, thầy/cô xác nhận có sự nhầm lẫn và đã cập nhật lại điểm chính xác cho em. Chúc em học tốt!	2026-11-21 07:06:55.881	2026-11-21 07:06:55.881	f
129	98	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.899	2026-11-21 07:06:55.899	f
132	99	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
135	100	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
134	101	9	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn khiếu nại và phản hồi chi tiết tới học viên.	2026-11-21 07:06:55.9	2026-11-21 07:06:55.9	f
145	116	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.903	2026-11-21 07:06:55.903	f
148	110	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.904	2026-11-21 07:06:55.904	f
154	105	180	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.905	2026-11-21 07:06:55.905	f
161	120	10	Thầy/Cô đã tiếp nhận khiếu nại của em và đang kiểm tra đối chiếu.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
166	101	192	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.906	2026-11-21 07:06:55.906	f
171	95	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.908	2026-11-21 07:06:55.908	f
173	108	210	Dạ em đã nắm rõ kết quả và hoàn toàn đồng ý với hướng giải quyết của thầy/cô. Em xin phép đóng đơn khiếu nại tại đây ạ.	2026-11-21 07:06:55.907	2026-11-21 07:06:55.907	f
179	120	10	[KẾT QUẢ XỬ LÝ] Thầy/cô đã chấm lại bài kiểm tra của em theo đúng đáp án và thang điểm chuẩn. Điểm số ban đầu là hoàn toàn chính xác theo barem của trung tâm.	2026-11-21 07:06:55.913	2026-11-21 07:06:55.913	f
182	128	2	Phòng Học vụ đã tiếp nhận đơn của thầy/cô. Đang kiểm tra biên bản thi và danh sách học viên trước khi trình duyệt mở sổ.	2026-11-21 07:06:55.929	2026-11-21 07:06:55.929	f
216	173	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Lê Hoàng Nam (Teacher) theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.959	2026-11-21 07:06:55.959	f
237	196	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.988	2026-11-21 07:06:55.988	f
218	180	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên David Wilson, M.Ed theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.96	2026-11-21 07:06:55.96	f
240	188	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.988	2026-11-21 07:06:55.988	f
250	210	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Lê Hoàng Nam (Teacher) theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.994	2026-11-21 07:06:55.994	f
219	178	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Trần Diễm My, CELTA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.96	2026-11-21 07:06:55.96	f
221	182	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Đỗ Gia Bảo, IELTS 8.5 theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.985	2026-11-21 07:06:55.985	f
248	205	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.992	2026-11-21 07:06:55.992	f
220	179	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.96	2026-11-21 07:06:55.96	f
241	198	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.988	2026-11-21 07:06:55.988	f
222	200	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.986	2026-11-21 07:06:55.986	f
249	207	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.993	2026-11-21 07:06:55.993	f
224	183	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Đỗ Gia Bảo, IELTS 8.5 theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.986	2026-11-21 07:06:55.986	f
223	186	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Trần Diễm My, CELTA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.986	2026-11-21 07:06:55.986	f
226	193	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.986	2026-11-21 07:06:55.986	f
225	189	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên David Wilson, M.Ed theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
229	199	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Vũ Quốc An, TESOL theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
245	203	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.989	2026-11-21 07:06:55.989	f
227	190	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
243	209	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Trần Diễm My, CELTA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.99	2026-11-21 07:06:55.99	f
232	187	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
235	192	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
246	204	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.992	2026-11-21 07:06:55.992	f
252	211	3	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn: Đã điều chỉnh điểm chuyên cần từ 7.0 lên 10.0 cho học viên.	2026-11-19 15:49:45.622982	2026-11-19 15:49:45.622985	f
253	212	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận mở sổ điểm trong vòng 48h để GV chỉnh sửa điểm.	2026-11-19 15:49:45.676112	2026-11-19 15:49:45.676114	f
254	213	1	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Đã quá thời hạn chỉnh sửa điểm cho phép của kỳ học.	2026-11-19 15:49:45.716654	2026-11-19 15:49:45.716657	f
255	214	3	Thầy đã rà soát lại sổ điểm danh, đúng là buổi số 3 có ghi nhận nhầm.	2026-11-19 15:52:10.480173	2026-11-19 15:52:10.480176	f
256	214	3	[KẾT QUẢ XỬ LÝ] Đã giải quyết đơn: Đã điều chỉnh điểm chuyên cần từ 7.0 lên 10.0 cho học viên.	2026-11-19 15:52:10.494049	2026-11-19 15:52:10.494051	f
257	215	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận mở sổ điểm trong vòng 48h để GV chỉnh sửa điểm.	2026-11-19 15:52:10.542419	2026-11-19 15:52:10.542422	f
258	216	1	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Đã quá thời hạn chỉnh sửa điểm cho phép của kỳ học.	2026-11-19 15:52:10.584467	2026-11-19 15:52:10.584469	f
259	217	3	Thầy đã rà soát lại sổ điểm danh, đúng là buổi số 3 có ghi nhận nhầm.	2026-11-20 03:16:13.565364	2026-11-20 03:16:13.565368	f
260	217	3	[HỆ THỐNG] Chuyển trạng thái từ PENDING sang PROCESSING khi ThS. Lê Hoàng Nam (Teacher) (TEACHER) gửi phản hồi.	2026-11-20 03:16:13.56537	2026-11-20 03:16:13.56537	f
261	217	3	[HỆ THỐNG] Chuyển trạng thái từ PROCESSING sang RESOLVED bởi ThS. Lê Hoàng Nam (Teacher) (TEACHER). Lý do / Ghi chú: Đã điều chỉnh điểm chuyên cần từ 7.0 lên 10.0 cho học viên.	2026-11-20 03:16:13.583498	2026-11-20 03:16:13.583501	f
262	218	2	[HỆ THỐNG] Chuyển trạng thái từ PENDING sang APPROVED bởi Trần Thị Học Vụ (Staff) (ACADEMIC_STAFF). Lý do / Ghi chú: Chấp thuận mở sổ điểm trong vòng 48h để GV chỉnh sửa điểm.	2026-11-20 03:16:13.640766	2026-11-20 03:16:13.640768	f
263	219	1	[HỆ THỐNG] Chuyển trạng thái từ PENDING sang REJECTED bởi Nguyễn Văn Quản Trị (Admin) (ADMIN). Lý do / Ghi chú: Đã quá thời hạn chỉnh sửa điểm cho phép của kỳ học.	2026-11-20 03:16:13.688949	2026-11-20 03:16:13.688951	f
264	220	2	[HỆ THỐNG] Chuyển trạng thái từ PENDING sang APPROVED bởi Trần Thị Học Vụ (Staff) (ACADEMIC_STAFF).	2026-11-20 04:32:10.241734	2026-11-20 04:32:10.241736	f
265	222	2	[HỆ THỐNG] Chuyển trạng thái từ PENDING sang APPROVED bởi Trần Thị Học Vụ (Staff) (ACADEMIC_STAFF).	2026-11-20 04:33:28.926808	2026-11-20 04:33:28.926811	f
266	242	2	[HỆ THỐNG] Chuyển trạng thái từ PENDING sang APPROVED bởi Trần Thị Học Vụ (Staff) (ACADEMIC_STAFF).	2026-11-20 04:53:45.520491	2026-11-20 04:53:45.520493	f
230	181	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên Hoàng Minh Phương, MA theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
247	206	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Nguyễn Thị Mai theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.992	2026-11-21 07:06:55.992	f
236	191	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.988	2026-11-21 07:06:55.988	f
228	201	2	[HỆ THỐNG] Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công. Ghi chú: Chấp thuận yêu cầu mở sổ điểm cho giảng viên ThS. Lê Hoàng Nam (Teacher) theo đơn đề nghị. Thời hạn mở sổ là 72 giờ kể từ thời điểm phê duyệt.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
231	195	2	[HỆ THỐNG] Yêu cầu đã bị từ chối. Lý do từ chối: Lớp học đã hoàn thành quá thời hạn cho phép điều chỉnh (quá 30 ngày kể từ ngày bế giảng). Đề nghị giảng viên liên hệ trực tiếp Ban Giám đốc để có quyết định phê duyệt ngoại lệ.	2026-11-21 07:06:55.987	2026-11-21 07:06:55.987	f
\.


--
-- Data for Name: GIANG_VIEN; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GIANG_VIEN" ("MaGiangVien", "MaNguoiDung", "MaSoGiangVien", "ChuyenMon", "HocVi", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
1	3	GV2026-001	IELTS 8.0 & Academic Writing	Master of Applied Linguistics	ACTIVE	2026-11-20 14:39:01.430042	2026-11-20 14:39:01.430046	f
26	71	GV2026-017	Academic English & Research Skills	PhD in Education	ACTIVE	\N	\N	f
8	67	GV2026-018	Grammar in Use & Pronunciation	BA in Linguistics	ACTIVE	\N	\N	f
10	45	GV2026-021	TOEIC & Business English	BA English Language Teaching	ACTIVE	\N	\N	f
21	36	GV2026-025	Junior English & SAT Foundation	MA in Linguistics	ACTIVE	\N	\N	f
17	37	GV2026-026	Debate & Advanced Communication	TESOL Certificate	ACTIVE	\N	\N	f
18	72	GV2026-024	TOEIC Listening & Test Strategies	IELTS 8.5, TOEIC 990	ACTIVE	\N	\N	f
2	4	GV2026-002	TOEIC & Business English	BA English Language Teaching	ACTIVE	2026-11-20 14:39:01.430047	2026-11-20 14:39:01.430047	f
12	74	GV2026-013	Phonics & Basic Communication	Cambridge CELTA	ACTIVE	\N	\N	f
35	51	GV2026-027	Academic English & Research Skills	PhD in Education	ACTIVE	\N	\N	f
29	40	GV2026-030	IELTS 8.0 & Academic Writing	Master of Applied Linguistics	ACTIVE	\N	\N	f
34	39	GV2026-012	IELTS Speaking & Native Intonation	M.Ed TESOL (Australia)	ACTIVE	\N	\N	f
33	75	GV2026-020	IELTS 8.0 & Academic Writing	Master of Applied Linguistics	ACTIVE	\N	\N	f
23	32	GV2026-023	Phonics & Basic Communication	Cambridge CELTA	ACTIVE	\N	\N	f
30	54	GV2026-014	TOEIC Listening & Test Strategies	IELTS 8.5, TOEIC 990	ACTIVE	\N	\N	f
22	43	GV2026-029	Corporate Communication & Negotiations	MBA & TESOL	ACTIVE	\N	\N	f
32	73	GV2026-016	Debate & Advanced Communication	TESOL Certificate	ACTIVE	\N	\N	f
7	11	GV2026-007	Debate & Advanced Communication	TESOL Certificate	ACTIVE	2026-11-20 14:39:02.545476	2026-11-20 14:39:02.545476	f
16	42	GV2026-008	Grammar in Use & Pronunciation	BA in Linguistics	ACTIVE	\N	\N	f
5	9	GV2026-005	TOEIC Listening & Test Strategies	IELTS 8.5, TOEIC 990	ACTIVE	2026-11-20 14:39:02.545474	2026-11-20 14:39:02.545474	f
31	29	GV2026-009	Corporate Communication & Negotiations	MBA & TESOL	ACTIVE	\N	\N	f
24	46	GV2026-010	IELTS 8.0 & Academic Writing	Master of Applied Linguistics	ACTIVE	\N	\N	f
27	27	GV2026-015	Junior English & SAT Foundation	MA in Linguistics	ACTIVE	\N	\N	f
14	70	GV2026-022	IELTS Speaking & Native Intonation	M.Ed TESOL (Australia)	ACTIVE	\N	\N	f
4	8	GV2026-004	Phonics & Basic Communication	Cambridge CELTA	ACTIVE	2026-11-20 14:39:02.545473	2026-11-20 14:39:02.545473	f
19	53	GV2026-019	Corporate Communication & Negotiations	MBA & TESOL	ACTIVE	\N	\N	f
6	10	GV2026-006	Junior English & SAT Foundation	MA in Linguistics	ACTIVE	2026-11-20 14:39:02.545475	2026-11-20 14:39:02.545475	f
41	47	GV2026-033	Phonics & Basic Communication	Cambridge CELTA	ACTIVE	\N	\N	f
45	57	GV2026-035	Junior English & SAT Foundation	MA in Linguistics	ACTIVE	\N	\N	f
47	48	GV2026-038	Grammar in Use & Pronunciation	BA in Linguistics	ACTIVE	\N	\N	f
40	58	GV2026-031	TOEIC & Business English	BA English Language Teaching	ACTIVE	\N	\N	f
13	34	GV2026-011	TOEIC & Business English	BA English Language Teaching	ACTIVE	\N	\N	f
44	49	GV2026-036	Debate & Advanced Communication	TESOL Certificate	ACTIVE	\N	\N	f
42	50	GV2026-037	Academic English & Research Skills	PhD in Education	ACTIVE	\N	\N	f
25	30	GV2026-028	Grammar in Use & Pronunciation	BA in Linguistics	ACTIVE	\N	\N	f
46	56	GV2026-032	IELTS Speaking & Native Intonation	M.Ed TESOL (Australia)	ACTIVE	\N	\N	f
43	55	GV2026-039	Corporate Communication & Negotiations	MBA & TESOL	ACTIVE	\N	\N	f
38	59	GV2026-040	IELTS 8.0 & Academic Writing	Master of Applied Linguistics	ACTIVE	\N	\N	f
3	7	GV2026-003	IELTS Speaking & Native Intonation	M.Ed TESOL (Australia)	ACTIVE	2026-11-20 14:39:02.545469	2026-11-20 14:39:02.545472	f
39	44	GV2026-034	TOEIC Listening & Test Strategies	IELTS 8.5, TOEIC 990	ACTIVE	\N	\N	f
\.


--
-- Data for Name: HOC_VIEN; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."HOC_VIEN" ("MaHocVien", "MaNguoiDung", "MaSoHocVien", "NgaySinh", "DiaChi", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
8	18	26-04008	2004-04-18	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646799	2026-11-20 14:39:04.646799	f
28	79	26-4016	2006-05-17	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
14	117	26-4019	2009-08-20	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
19	88	26-4011	2001-12-12	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
2	12	26-04002	2002-09-05	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646789	2026-11-20 14:39:04.646793	f
53	85	26-4023	2003-12-24	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
1	5	26-04001	2004-05-15	Quận 1, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:01.426615	2026-11-20 14:39:01.426618	f
57	94	26-4026	2006-03-27	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
17	80	26-4025	2005-02-26	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
13	89	26-4027	2007-04-28	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
26	114	26-4028	2008-05-01	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
55	103	26-4032	2002-09-05	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
50	86	26-4029	2009-06-02	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
29	93	26-4030	2000-07-03	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
21	122	26-4038	2008-03-11	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
25	102	26-4039	2009-04-12	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
48	104	26-4041	2001-06-14	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
27	81	26-4033	2003-10-06	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
32	96	26-4034	2004-11-07	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
16	97	26-4036	2006-01-09	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
23	91	26-4035	2005-12-08	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
44	108	26-4050	2000-03-23	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
63	120	26-4056	2006-09-01	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
69	110	26-4051	2001-04-24	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
61	119	26-4053	2003-06-26	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
66	165	26-4069	2009-10-14	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
65	124	26-4058	2008-11-03	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
71	152	26-4061	2001-02-06	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
64	127	26-4072	2002-01-17	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
68	143	26-4079	2009-08-24	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
62	142	26-4078	2008-07-23	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
70	145	26-4082	2002-11-27	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
72	137	26-4085	2005-02-02	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
67	150	26-4068	2008-09-13	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
108	129	26-4060	2000-01-05	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
73	170	26-4087	2007-04-04	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
96	155	26-4100	2000-05-17	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
131	158	26-4104	2004-09-21	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
141	185	26-4115	2005-08-04	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
160	193	26-4136	2006-05-25	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
161	213	26-4151	2001-08-12	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
201	228	26-4160	2000-05-21	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
182	230	26-4171	2001-04-04	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
221	287	26-4221	2001-06-26	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
247	296	26-4248	2008-09-25	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
262	374	26-4265	2005-02-14	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
288	368	26-4282	2002-07-03	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
359	385	26-4316	2006-05-09	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
322	379	26-4325	2005-02-18	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
351	405	26-4344	2004-09-09	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
94	169	26-4074	2004-03-19	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
104	140	26-4066	2006-07-11	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
82	147	26-4088	2008-05-05	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
83	132	26-4070	2000-11-15	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
116	192	26-4110	2000-03-27	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
128	219	26-4133	2003-02-22	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
136	211	26-4140	2000-09-01	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
138	184	26-4124	2004-05-13	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
204	240	26-4180	2000-01-13	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
170	244	26-4182	2002-03-15	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
203	266	26-4184	2004-05-17	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
191	216	26-4157	2007-02-18	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
178	246	26-4179	2009-12-12	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
252	321	26-4224	2004-09-01	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
211	277	26-4210	2000-07-15	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
232	271	26-4208	2008-05-13	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
227	278	26-4228	2008-01-05	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
259	319	26-4237	2007-10-14	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
238	309	26-4239	2009-12-16	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
260	290	26-4249	2009-10-26	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
263	311	26-4251	2001-12-28	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
282	331	26-4260	2000-09-09	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
292	375	26-4272	2002-09-21	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
277	303	26-4252	2002-01-01	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
303	345	26-4277	2007-02-26	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
358	423	26-4314	2004-03-07	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
352	380	26-4317	2007-06-10	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
323	415	26-4330	2000-07-23	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
328	391	26-4336	2006-01-01	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
339	398	26-4346	2006-11-11	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
84	172	26-4080	2000-09-25	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
126	196	26-4134	2004-03-23	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
152	202	26-4142	2002-11-03	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
181	235	26-4163	2003-08-24	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
202	264	26-4168	2008-01-01	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
225	251	26-4204	2004-01-09	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
257	317	26-4222	2002-07-27	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
249	320	26-4236	2006-09-13	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
268	298	26-4255	2005-04-04	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
294	342	26-4294	2004-07-15	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
324	406	26-4318	2008-07-11	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
354	363	26-4306	2006-07-27	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
333	413	26-4326	2006-03-19	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
105	116	26-4055	2005-08-28	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
85	157	26-4089	2009-06-06	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
119	156	26-4102	2002-07-19	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
134	181	26-4121	2001-02-10	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
177	234	26-4173	2003-06-06	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
189	265	26-4198	2008-07-03	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
231	312	26-4233	2003-06-10	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
239	291	26-4242	2002-03-19	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
258	289	26-4247	2007-08-24	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
261	301	26-4253	2003-02-02	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
300	372	26-4300	2000-01-21	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
310	359	26-4299	2009-12-20	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
319	354	26-4302	2002-03-23	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
345	408	26-4350	2000-03-15	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
86	141	26-4071	2001-12-16	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
117	180	26-4111	2001-04-28	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
149	210	26-4113	2003-06-02	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
198	262	26-4183	2003-04-16	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
173	274	26-4186	2006-07-19	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
220	324	26-4214	2004-11-19	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
242	284	26-4240	2000-01-17	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
280	343	26-4270	2000-07-19	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
284	327	26-4281	2001-06-02	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
304	336	26-4263	2003-12-12	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
316	410	26-4311	2001-12-04	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
347	382	26-4324	2004-01-17	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
87	154	26-4090	2000-07-07	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
158	217	26-4116	2006-09-05	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
129	197	26-4139	2009-08-28	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
135	198	26-4146	2006-03-07	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
165	214	26-4158	2008-03-19	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
199	256	26-4200	2000-09-05	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
236	263	26-4205	2005-02-10	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
226	279	26-4225	2005-10-02	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
265	355	26-4262	2002-11-11	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
302	346	26-4273	2003-10-22	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
344	383	26-4309	2009-10-02	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
355	420	26-4334	2004-11-27	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
329	396	26-4337	2007-02-02	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
88	164	26-4092	2002-09-09	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
121	187	26-4123	2003-04-12	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
147	206	26-4144	2004-01-05	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
174	245	26-4169	2009-02-02	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
190	239	26-4172	2002-05-05	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
224	295	26-4232	2002-05-09	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
243	300	26-4241	2001-02-18	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
281	328	26-4266	2006-03-15	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
287	338	26-4288	2008-01-09	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
314	422	26-4315	2005-04-08	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
356	377	26-4329	2009-06-22	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
337	389	26-4341	2001-06-06	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
90	138	26-4091	2001-08-08	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
115	222	26-4114	2004-07-03	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
145	200	26-4150	2000-07-11	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
176	272	26-4189	2009-10-22	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
185	257	26-4193	2003-02-26	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
207	258	26-4196	2006-05-01	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
240	322	26-4220	2000-05-25	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
217	318	26-4215	2005-12-20	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
278	373	26-4279	2009-04-28	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
293	347	26-4297	2007-10-18	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
309	352	26-4298	2008-11-19	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
312	350	26-4304	2004-05-25	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
338	421	26-4342	2002-07-07	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
89	144	26-4094	2004-11-11	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
159	163	26-4105	2005-10-22	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
150	176	26-4109	2009-02-26	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
122	207	26-4130	2000-11-19	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
163	203	26-4152	2002-09-13	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
205	232	26-4164	2004-09-25	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
186	248	26-4192	2002-01-25	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
213	270	26-4203	2003-12-08	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
246	282	26-4235	2005-08-12	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
276	365	26-4271	2001-08-20	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
296	334	26-4286	2006-11-07	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
335	392	26-4335	2005-12-28	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
327	407	26-4333	2003-10-26	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
79	130	26-4076	2006-05-21	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
95	161	26-4064	2004-05-09	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
140	182	26-4128	2008-09-17	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
127	188	26-4131	2001-12-20	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
169	227	26-4161	2001-06-22	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
194	252	26-4197	2007-06-02	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
253	306	26-4211	2001-08-16	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
230	307	26-4227	2007-12-04	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
307	361	26-4276	2006-01-25	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
269	351	26-4261	2001-10-10	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
298	333	26-4289	2009-02-10	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
313	349	26-4301	2001-02-22	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
346	384	26-4310	2000-11-03	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
91	149	26-4096	2006-01-13	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
109	131	26-4067	2007-08-12	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
111	160	26-4103	2003-08-20	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
132	173	26-4107	2007-12-24	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
153	183	26-4112	2002-05-01	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
193	237	26-4177	2007-10-10	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
175	226	26-4166	2006-11-27	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
222	281	26-4217	2007-02-22	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
251	276	26-4209	2009-06-14	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
266	344	26-4269	2009-06-18	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
291	329	26-4287	2007-12-08	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
326	393	26-4339	2009-04-04	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
343	395	26-4343	2003-08-08	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
92	153	26-4095	2005-12-12	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
130	190	26-4137	2007-06-26	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
142	221	26-4145	2005-02-06	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
166	236	26-4170	2000-03-03	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
208	250	26-4167	2007-12-28	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
188	238	26-4159	2009-04-20	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
214	273	26-4207	2007-04-12	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
250	288	26-4244	2004-05-21	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
305	326	26-4259	2009-08-08	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
275	366	26-4275	2005-12-24	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
283	332	26-4280	2000-05-01	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
318	386	26-4312	2002-01-05	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
342	402	26-4349	2009-02-14	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
110	121	26-4052	2002-05-25	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
93	146	26-4093	2003-10-10	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
123	167	26-4101	2001-06-18	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
143	225	26-4147	2007-04-08	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
184	212	26-4156	2006-01-17	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
172	243	26-4187	2007-08-20	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
223	286	26-4212	2002-09-17	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
244	285	26-4238	2008-11-15	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
271	315	26-4256	2006-05-05	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
290	341	26-4292	2002-05-13	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
331	356	26-4307	2007-08-28	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
350	390	26-4313	2003-02-06	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
45	78	26-4021	2001-10-22	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
31	87	26-4031	2001-08-04	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
4	14	26-04004	2005-01-12	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646795	2026-11-20 14:39:04.646796	f
40	123	26-4020	2000-09-21	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
54	105	26-4017	2007-06-18	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
30	95	26-4022	2002-11-23	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
3	13	26-04003	2005-08-20	Quận 3, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646794	2026-11-20 14:39:04.646795	f
7	17	26-04007	2003-11-10	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646798	2026-11-20 14:39:04.646798	f
10	20	26-04010	2003-03-25	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.6468	2026-11-20 14:39:04.6468	f
18	92	26-4037	2007-02-10	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
76	115	26-4054	2004-07-27	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
98	166	26-4099	2009-04-16	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
114	220	26-4122	2002-03-11	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
133	189	26-4138	2008-07-27	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
183	224	26-4153	2003-10-14	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
179	231	26-4176	2006-09-09	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
206	255	26-4175	2005-08-08	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
212	267	26-4201	2001-10-06	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
234	304	26-4231	2001-04-08	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
254	283	26-4229	2009-02-06	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
267	310	26-4257	2007-06-06	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
299	335	26-4293	2003-06-14	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
325	388	26-4332	2002-09-25	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
349	399	26-4348	2008-01-13	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
60	84	26-4014	2004-03-15	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
47	98	26-4045	2005-10-18	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
42	82	26-4013	2003-02-14	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
20	90	26-4015	2005-04-16	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
5	15	26-04005	2004-02-28	Quận 7, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646796	2026-11-20 14:39:04.646796	f
34	106	26-4042	2002-07-15	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
35	111	26-4040	2000-05-13	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
36	100	26-4043	2003-08-16	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
39	99	26-4044	2004-09-17	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
22	113	26-4012	2002-01-13	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
75	133	26-4073	2003-02-18	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
107	135	26-4077	2007-06-22	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
99	148	26-4097	2007-02-14	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
118	159	26-4108	2008-01-25	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
144	205	26-4149	2009-06-10	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
180	268	26-4185	2005-06-18	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
200	247	26-4188	2008-09-21	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
229	299	26-4230	2000-03-07	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
248	293	26-4246	2006-07-23	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
272	364	26-4278	2008-03-27	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
295	339	26-4296	2006-09-17	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
360	416	26-4319	2009-08-12	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
330	376	26-4328	2008-05-21	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
341	397	26-4347	2007-12-12	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
56	77	26-4018	2008-07-19	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
6	16	26-04006	2003-07-22	Quận 10, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646797	2026-11-20 14:39:04.646797	f
51	109	26-4046	2006-11-19	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
41	107	26-4049	2009-02-22	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
43	112	26-4047	2007-12-20	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
58	125	26-4024	2004-01-25	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
9	19	26-04009	2005-12-03	Quận 5, TP. Hồ Chí Minh	ACTIVE	2026-11-20 14:39:04.646799	2026-11-20 14:39:04.6468	f
59	101	26-4048	2008-01-21	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
74	128	26-4065	2005-06-10	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
106	118	26-4057	2007-10-02	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
97	136	26-4084	2004-01-01	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
112	168	26-4106	2006-11-23	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
148	204	26-4125	2005-06-14	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
157	186	26-4135	2005-04-24	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
196	229	26-4174	2004-07-07	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
162	208	26-4155	2005-12-16	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
218	325	26-4223	2003-08-28	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
241	292	26-4250	2000-11-27	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
270	362	26-4264	2004-01-13	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
297	337	26-4291	2001-04-12	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
348	371	26-4305	2005-06-26	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
321	425	26-4331	2001-08-24	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
77	134	26-4059	2009-12-04	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
101	162	26-4098	2008-03-15	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
120	194	26-4120	2000-01-09	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
146	199	26-4141	2001-10-02	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
155	215	26-4132	2002-01-21	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
187	269	26-4194	2004-03-27	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
209	254	26-4199	2009-08-04	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
164	249	26-4162	2002-07-23	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
235	323	26-4216	2006-01-21	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
256	316	26-4218	2008-03-23	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
216	259	26-4206	2006-03-11	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
264	314	26-4254	2004-03-03	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
286	369	26-4290	2000-03-11	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
308	360	26-4295	2005-08-16	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
311	358	26-4303	2003-04-24	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
353	409	26-4322	2002-11-15	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
332	394	26-4340	2000-05-05	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
103	151	26-4086	2006-03-03	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
78	171	26-4081	2001-10-26	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
154	191	26-4119	2009-12-08	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
125	195	26-4127	2007-08-16	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
137	201	26-4143	2003-12-04	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
168	241	26-4178	2008-11-11	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
210	233	26-4165	2005-10-26	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
192	275	26-4191	2001-12-24	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
215	253	26-4202	2002-11-07	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
237	294	26-4243	2003-04-20	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
274	353	26-4268	2008-05-17	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
289	340	26-4284	2004-09-05	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
357	381	26-4320	2000-09-13	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
317	378	26-4321	2001-10-14	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
334	387	26-4345	2005-10-10	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
100	174	26-4075	2005-04-20	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
80	175	26-4083	2003-12-28	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
156	178	26-4129	2009-10-18	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
124	179	26-4126	2006-07-15	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
151	218	26-4148	2008-05-09	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
167	209	26-4154	2004-11-15	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
195	260	26-4190	2000-11-23	Quận 1, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
219	308	26-4219	2009-04-24	TP. Thủ Đức, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
255	280	26-4213	2003-10-18	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
233	313	26-4234	2004-07-11	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
306	348	26-4267	2007-04-16	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
273	302	26-4258	2008-07-07	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
285	370	26-4283	2003-08-04	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
315	367	26-4308	2008-09-01	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
336	417	26-4327	2007-04-20	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
81	126	26-4062	2002-03-07	Quận 5, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
102	139	26-4063	2003-04-08	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
113	223	26-4117	2007-10-06	Quận Tân Bình, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
139	177	26-4118	2008-11-07	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
171	242	26-4181	2001-02-14	Quận 3, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
197	261	26-4195	2005-04-28	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
228	305	26-4226	2006-11-03	Quận Phú Nhuận, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
245	297	26-4245	2005-06-22	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
279	330	26-4274	2004-11-23	Quận 10, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
301	357	26-4285	2005-10-06	Quận Bình Thạnh, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
320	418	26-4323	2003-12-16	Quận 7, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
340	424	26-4338	2008-03-03	Quận Gò Vấp, TP. Hồ Chí Minh	ACTIVE	\N	\N	f
\.


--
-- Data for Name: HOC_VIEN_LOP_HOC; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."HOC_VIEN_LOP_HOC" ("MaHV_LH", "MaLopHoc", "MaHocVien", "NgayVaoLop", "TrangThaiHoc", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
116	6	72	\N	ENROLLED	\N	\N	f
117	5	109	\N	ENROLLED	\N	\N	f
118	8	153	\N	ENROLLED	\N	\N	f
119	8	134	\N	ENROLLED	\N	\N	f
120	8	158	\N	ENROLLED	\N	\N	f
121	7	123	\N	ENROLLED	\N	\N	f
122	7	111	\N	ENROLLED	\N	\N	f
123	9	148	\N	ENROLLED	\N	\N	f
124	9	127	\N	ENROLLED	\N	\N	f
125	8	154	\N	ENROLLED	\N	\N	f
126	8	116	\N	ENROLLED	\N	\N	f
127	9	121	\N	ENROLLED	\N	\N	f
128	7	96	\N	ENROLLED	\N	\N	f
129	8	150	\N	ENROLLED	\N	\N	f
130	8	141	\N	ENROLLED	\N	\N	f
131	9	155	\N	ENROLLED	\N	\N	f
132	8	132	\N	ENROLLED	\N	\N	f
133	8	112	\N	ENROLLED	\N	\N	f
134	7	131	\N	ENROLLED	\N	\N	f
135	8	113	\N	ENROLLED	\N	\N	f
136	9	156	\N	ENROLLED	\N	\N	f
137	9	122	\N	ENROLLED	\N	\N	f
138	9	125	\N	ENROLLED	\N	\N	f
139	9	133	\N	ENROLLED	\N	\N	f
140	9	124	\N	ENROLLED	\N	\N	f
142	9	126	\N	ENROLLED	\N	\N	f
143	8	115	\N	ENROLLED	\N	\N	f
141	8	149	\N	ENROLLED	\N	\N	f
166	30	144	\N	ENROLLED	\N	\N	f
182	31	191	\N	ENROLLED	\N	\N	f
207	33	176	\N	COMPLETED	\N	\N	f
236	34	256	\N	COMPLETED	\N	\N	f
253	35	244	\N	COMPLETED	\N	\N	f
152	30	146	\N	ENROLLED	\N	\N	f
162	9	140	\N	ENROLLED	\N	\N	f
167	30	135	\N	ENROLLED	\N	\N	f
169	31	208	\N	ENROLLED	\N	\N	f
188	30	161	\N	ENROLLED	\N	\N	f
195	33	200	\N	COMPLETED	\N	\N	f
208	33	189	\N	COMPLETED	\N	\N	f
215	33	209	\N	COMPLETED	\N	\N	f
221	34	255	\N	COMPLETED	\N	\N	f
238	34	253	\N	COMPLETED	\N	\N	f
240	35	231	\N	COMPLETED	\N	\N	f
255	35	226	\N	COMPLETED	\N	\N	f
153	9	157	\N	ENROLLED	\N	\N	f
163	30	143	\N	ENROLLED	\N	\N	f
164	30	151	\N	ENROLLED	\N	\N	f
178	31	169	\N	ENROLLED	\N	\N	f
186	31	184	\N	ENROLLED	\N	\N	f
194	33	172	\N	COMPLETED	\N	\N	f
209	33	192	\N	COMPLETED	\N	\N	f
213	33	186	\N	COMPLETED	\N	\N	f
218	35	254	\N	COMPLETED	\N	\N	f
228	34	214	\N	COMPLETED	\N	\N	f
239	35	259	\N	COMPLETED	\N	\N	f
241	34	232	\N	COMPLETED	\N	\N	f
154	30	136	\N	ENROLLED	\N	\N	f
161	30	152	\N	ENROLLED	\N	\N	f
184	30	145	\N	ENROLLED	\N	\N	f
185	31	164	\N	ENROLLED	\N	\N	f
200	11	179	\N	COMPLETED	\N	\N	f
210	11	203	\N	COMPLETED	\N	\N	f
220	34	251	\N	COMPLETED	\N	\N	f
226	33	225	\N	COMPLETED	\N	\N	f
245	35	246	\N	COMPLETED	\N	\N	f
248	34	240	\N	COMPLETED	\N	\N	f
156	7	119	\N	ENROLLED	\N	\N	f
177	30	183	\N	ENROLLED	\N	\N	f
196	11	180	\N	COMPLETED	\N	\N	f
229	35	257	\N	COMPLETED	\N	\N	f
246	35	228	\N	COMPLETED	\N	\N	f
257	2	6	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
258	2	7	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
259	2	8	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
260	2	9	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
261	10	56	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
262	10	57	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
263	10	58	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
264	10	59	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
265	13	66	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
266	13	67	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
267	13	68	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
268	13	69	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
269	14	71	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
270	14	72	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
271	14	73	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
272	14	74	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
273	15	76	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
274	15	77	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
275	15	78	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
276	15	79	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
277	17	81	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
278	17	82	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
279	17	83	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
280	17	84	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
281	18	86	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
282	18	87	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
283	18	88	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
284	18	89	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
285	19	91	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
286	19	92	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
287	19	93	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
288	19	94	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
289	20	96	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
290	20	97	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
291	20	98	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
292	20	99	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
293	21	101	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
294	21	102	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
295	21	103	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
296	21	104	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
297	36	131	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
298	36	132	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
299	36	133	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
300	36	134	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
301	37	136	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
302	37	137	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
303	37	138	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
304	37	139	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
305	38	141	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
306	38	142	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
307	38	143	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
308	38	144	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
309	39	146	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
310	39	147	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
311	39	148	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
312	39	149	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
313	40	151	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
314	40	152	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
315	40	153	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
316	40	154	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
317	41	156	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
318	41	157	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
319	41	158	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
320	41	159	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
321	42	161	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
322	42	162	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
323	42	163	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
324	42	164	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
325	43	166	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
326	43	167	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
327	43	168	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
328	43	169	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
329	44	171	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
330	44	172	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
331	44	173	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
332	44	174	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
333	45	176	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
334	45	177	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
335	45	178	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
336	45	179	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
337	46	181	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
338	46	182	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
339	46	183	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
340	46	184	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
341	47	186	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
157	8	159	\N	ENROLLED	\N	\N	f
176	31	205	\N	ENROLLED	\N	\N	f
199	11	204	\N	COMPLETED	\N	\N	f
211	33	207	\N	COMPLETED	\N	\N	f
230	34	235	\N	COMPLETED	\N	\N	f
249	35	234	\N	COMPLETED	\N	\N	f
342	47	187	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
343	47	188	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
344	47	189	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
345	48	191	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
346	48	192	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
347	48	193	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
348	48	194	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
349	49	196	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
350	49	197	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
351	49	198	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
352	49	199	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
353	50	201	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
354	50	202	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
355	50	203	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
356	50	204	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
357	51	206	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
358	51	207	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
359	51	208	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
360	51	209	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
361	52	211	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
362	52	212	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
363	52	213	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
364	52	214	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
365	53	216	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
366	53	217	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
367	53	218	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
368	53	219	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
369	54	221	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
370	54	222	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
371	54	223	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
372	54	224	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
373	55	226	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
374	55	227	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
375	55	228	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
376	55	229	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
377	56	231	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
378	56	232	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
379	56	233	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
380	56	234	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
381	57	236	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
382	57	237	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
383	57	238	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
384	57	239	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
385	58	241	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
386	58	242	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
387	58	243	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
388	58	244	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
389	59	246	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
390	59	247	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
391	59	248	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
392	59	249	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
393	60	251	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
394	60	252	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
395	60	253	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
396	60	254	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
397	61	256	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
398	61	257	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
399	61	258	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
400	61	259	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
401	62	261	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
402	62	262	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
403	62	263	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
404	62	264	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
405	63	266	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
406	63	267	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
407	63	268	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
408	63	269	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
409	64	271	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
410	64	272	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
411	64	273	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
412	64	274	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
413	65	276	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
414	65	277	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
415	65	278	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
416	65	279	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
417	66	281	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
418	66	282	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
419	66	283	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
420	66	284	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
421	67	286	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
422	67	287	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
423	67	288	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
424	67	289	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
425	68	291	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
426	68	292	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
155	8	118	\N	ENROLLED	\N	\N	f
171	31	162	\N	ENROLLED	\N	\N	f
192	31	210	\N	ENROLLED	\N	\N	f
214	33	185	\N	COMPLETED	\N	\N	f
224	34	219	\N	COMPLETED	\N	\N	f
250	34	236	\N	COMPLETED	\N	\N	f
427	68	293	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
428	68	294	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
429	69	296	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
430	69	297	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
431	69	298	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
432	69	299	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
433	70	301	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
434	70	302	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
435	70	303	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
436	70	304	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
437	71	306	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
438	71	307	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
439	71	308	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
440	71	309	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
441	72	311	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
442	72	312	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
443	72	313	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
444	72	314	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
445	73	316	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
446	73	317	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
447	73	318	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
448	73	319	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
449	74	321	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
450	74	322	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
451	74	323	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
452	74	324	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
453	75	326	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
454	75	327	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
455	75	328	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
456	75	329	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
457	76	331	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
458	76	332	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
459	76	333	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
460	76	334	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
461	77	336	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
462	77	337	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
463	77	338	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
464	77	339	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
465	78	341	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
466	78	342	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
467	78	343	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
468	78	344	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
469	79	346	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
470	79	347	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
471	79	348	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
472	79	349	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
473	80	351	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
474	80	352	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
475	80	353	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
476	80	354	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
477	81	356	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
478	81	357	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
479	81	358	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
480	81	359	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
481	82	1	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
482	82	2	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
483	82	3	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
484	82	4	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
485	83	6	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
486	83	7	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
487	83	8	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
488	83	9	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
489	84	13	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
490	84	14	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
491	84	16	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
492	84	17	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
493	85	19	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
494	85	20	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
495	85	21	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
496	85	22	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
497	86	25	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
498	86	26	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
499	86	27	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
500	86	28	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
501	87	30	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
502	87	31	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
503	87	32	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
504	87	34	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
505	88	36	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
506	88	39	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
507	88	40	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
508	88	41	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
509	89	43	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
510	89	44	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
511	89	45	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
145	30	129	\N	ENROLLED	\N	\N	f
165	8	117	\N	ENROLLED	\N	\N	f
168	11	182	\N	COMPLETED	\N	\N	f
189	11	198	\N	COMPLETED	\N	\N	f
205	11	206	\N	COMPLETED	\N	\N	f
237	35	229	\N	COMPLETED	\N	\N	f
158	30	142	\N	ENROLLED	\N	\N	f
181	31	165	\N	ENROLLED	\N	\N	f
202	33	195	\N	COMPLETED	\N	\N	f
227	35	252	\N	COMPLETED	\N	\N	f
251	35	224	\N	COMPLETED	\N	\N	f
512	89	47	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
513	90	50	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
514	90	51	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
515	90	53	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
516	90	54	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
517	91	56	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
518	91	57	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
519	91	58	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
520	91	59	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
521	92	61	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
522	92	62	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
523	92	63	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
524	92	64	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
525	93	66	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
526	93	67	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
527	93	68	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
528	93	69	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
529	94	71	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
530	94	72	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
531	94	73	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
532	94	74	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
533	95	76	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
534	95	77	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
535	95	78	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
536	95	79	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
537	96	81	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
538	96	82	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
539	96	83	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
540	96	84	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
541	97	86	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
542	97	87	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
543	97	88	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
544	97	89	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
545	98	91	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
546	98	92	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
547	98	93	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
548	98	94	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
549	99	96	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
550	99	97	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
551	99	98	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
552	99	99	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
553	100	101	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
554	100	102	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
555	100	103	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
556	100	104	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
557	101	106	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
558	101	107	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
559	101	108	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
560	101	109	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
561	102	111	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
562	102	112	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
563	102	113	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
564	102	114	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
565	103	116	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
566	103	117	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
567	103	118	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
568	103	119	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
569	104	121	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
570	104	122	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
571	104	123	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
572	104	124	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
573	105	126	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
574	105	127	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
575	105	128	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
576	105	129	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
577	106	131	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
578	106	132	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
579	106	133	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
580	106	134	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
581	107	136	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
582	107	137	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
583	107	138	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
584	107	139	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
585	108	141	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
586	108	142	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
587	108	143	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
588	108	144	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
589	109	146	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
590	109	147	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
591	109	148	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
592	109	149	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
593	110	151	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
594	110	152	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
595	110	153	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
596	110	154	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
159	30	147	\N	ENROLLED	\N	\N	f
183	31	188	\N	ENROLLED	\N	\N	f
204	11	190	\N	COMPLETED	\N	\N	f
225	33	212	\N	COMPLETED	\N	\N	f
243	35	233	\N	COMPLETED	\N	\N	f
597	111	156	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
598	111	157	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
599	111	158	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
600	111	159	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
601	112	161	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
602	112	162	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
603	112	163	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
604	112	164	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
605	113	166	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
606	113	167	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
607	113	168	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
608	113	169	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
609	114	171	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
610	114	172	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
611	114	173	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
612	114	174	2026-11-21 14:24:01.911663	COMPLETED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
613	115	176	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
614	115	177	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
615	115	178	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
616	115	179	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
617	116	181	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
618	116	182	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
619	116	183	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
620	116	184	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
621	117	186	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
622	117	187	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
623	117	188	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
624	117	189	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
625	118	191	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
626	118	192	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
627	118	193	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
628	118	194	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
629	119	196	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
630	119	197	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
631	119	198	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
632	119	199	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
633	120	201	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
634	120	202	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
635	120	203	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
636	120	204	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
637	121	206	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
638	121	207	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
639	121	208	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
640	121	209	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
641	122	211	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
642	122	212	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
643	122	213	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
644	122	214	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1	1	1	2026-11-20 14:39:05.888725	TRANSFERRED	2026-11-20 14:39:05.88873	2026-11-20 14:39:05.88873	f
645	4	1	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
2	11	2	2026-11-20 14:39:05.888732	TRANSFERRED	2026-11-20 14:39:05.888732	2026-11-20 14:39:05.888732	f
3	3	2	2026-11-20 14:39:05.888733	TRANSFERRED	2026-11-20 14:39:05.888733	2026-11-20 14:39:05.888734	f
646	13	2	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
4	3	4	2026-11-20 14:39:05.888734	TRANSFERRED	2026-11-20 14:39:05.888735	2026-11-20 14:39:05.888735	f
647	13	4	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
5	3	6	2026-11-20 14:39:05.888735	TRANSFERRED	2026-11-20 14:39:05.888736	2026-11-20 14:39:05.888736	f
648	13	6	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
6	4	3	2026-11-20 14:39:05.888737	TRANSFERRED	2026-11-20 14:39:05.888737	2026-11-20 14:39:05.888737	f
7	4	7	2026-11-20 14:39:05.888738	TRANSFERRED	2026-11-20 14:39:05.888738	2026-11-20 14:39:05.888739	f
8	4	9	2026-11-20 14:39:05.888739	TRANSFERRED	2026-11-20 14:39:05.888739	2026-11-20 14:39:05.88874	f
9	5	5	2026-11-20 14:39:05.88874	TRANSFERRED	2026-11-20 14:39:05.888741	2026-11-20 14:39:05.888741	f
649	19	5	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
10	5	8	2026-11-20 14:39:05.888741	TRANSFERRED	2026-11-20 14:39:05.888742	2026-11-20 14:39:05.888742	f
650	19	8	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
11	5	10	2026-11-20 14:39:05.888743	TRANSFERRED	2026-11-20 14:39:05.888743	2026-11-20 14:39:05.888743	f
651	19	10	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
12	6	3	2026-11-20 14:39:05.888744	TRANSFERRED	2026-11-20 14:39:05.888744	2026-11-20 14:39:05.888744	f
652	15	3	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
13	6	6	2026-11-20 14:39:05.888745	TRANSFERRED	2026-11-20 14:39:05.888745	2026-11-20 14:39:05.888746	f
653	15	6	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
14	7	5	2026-11-20 14:39:05.888746	TRANSFERRED	2026-11-20 14:39:05.888746	2026-11-20 14:39:05.888747	f
654	17	5	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
15	7	10	2026-11-20 14:39:05.888747	TRANSFERRED	2026-11-20 14:39:05.888748	2026-11-20 14:39:05.888748	f
655	17	10	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
16	8	2	2026-11-20 14:39:05.888748	TRANSFERRED	2026-11-20 14:39:05.888749	2026-11-20 14:39:05.888749	f
656	18	2	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
17	8	8	2026-11-20 14:39:05.888749	TRANSFERRED	2026-11-20 14:39:05.88875	2026-11-20 14:39:05.88875	f
657	18	8	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
18	9	5	2026-11-20 14:39:05.888751	TRANSFERRED	2026-11-20 14:39:05.888751	2026-11-20 14:39:05.888751	f
658	21	5	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
19	9	7	2026-11-20 14:39:05.888752	TRANSFERRED	2026-11-20 14:39:05.888752	2026-11-20 14:39:05.888752	f
659	21	7	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
20	1	60	\N	TRANSFERRED	\N	\N	f
660	4	60	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
21	1	2	\N	TRANSFERRED	\N	\N	f
661	4	2	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
22	1	6	\N	TRANSFERRED	\N	\N	f
160	8	120	\N	ENROLLED	\N	\N	f
187	11	166	\N	COMPLETED	\N	\N	f
206	11	171	\N	COMPLETED	\N	\N	f
232	34	211	\N	COMPLETED	\N	\N	f
252	33	199	\N	COMPLETED	\N	\N	f
662	4	6	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
23	1	20	\N	TRANSFERRED	\N	\N	f
663	4	20	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
25	3	27	\N	TRANSFERRED	\N	\N	f
664	13	27	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
24	4	21	\N	TRANSFERRED	\N	\N	f
665	1	21	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
27	3	26	\N	TRANSFERRED	\N	\N	f
666	13	26	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
26	1	5	\N	TRANSFERRED	\N	\N	f
667	4	5	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
28	4	48	\N	TRANSFERRED	\N	\N	f
668	1	48	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
29	1	10	\N	TRANSFERRED	\N	\N	f
669	4	10	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
30	1	56	\N	TRANSFERRED	\N	\N	f
670	4	56	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
31	3	13	\N	TRANSFERRED	\N	\N	f
671	13	13	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
32	1	19	\N	TRANSFERRED	\N	\N	f
672	4	19	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
33	3	14	\N	TRANSFERRED	\N	\N	f
673	13	14	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
34	3	31	\N	TRANSFERRED	\N	\N	f
674	13	31	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
35	3	55	\N	TRANSFERRED	\N	\N	f
675	13	55	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
36	4	36	\N	TRANSFERRED	\N	\N	f
676	1	36	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
37	1	28	\N	TRANSFERRED	\N	\N	f
677	4	28	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
38	3	32	\N	TRANSFERRED	\N	\N	f
678	13	32	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
39	4	18	\N	TRANSFERRED	\N	\N	f
679	1	18	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
40	3	29	\N	TRANSFERRED	\N	\N	f
680	13	29	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
41	4	25	\N	TRANSFERRED	\N	\N	f
681	1	25	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
43	4	41	\N	TRANSFERRED	\N	\N	f
682	1	41	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
42	4	43	\N	TRANSFERRED	\N	\N	f
683	1	43	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
44	1	7	\N	TRANSFERRED	\N	\N	f
45	4	39	\N	TRANSFERRED	\N	\N	f
684	1	39	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
47	4	47	\N	TRANSFERRED	\N	\N	f
685	1	47	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
53	3	45	\N	TRANSFERRED	\N	\N	f
686	13	45	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
46	3	50	\N	TRANSFERRED	\N	\N	f
687	13	50	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
54	1	22	\N	TRANSFERRED	\N	\N	f
688	4	22	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
51	4	59	\N	TRANSFERRED	\N	\N	f
689	1	59	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
50	3	30	\N	TRANSFERRED	\N	\N	f
690	13	30	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
55	3	57	\N	TRANSFERRED	\N	\N	f
691	13	57	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
48	1	8	\N	TRANSFERRED	\N	\N	f
692	4	8	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
49	3	53	\N	TRANSFERRED	\N	\N	f
693	13	53	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
52	1	54	\N	TRANSFERRED	\N	\N	f
694	4	54	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
56	3	17	\N	TRANSFERRED	\N	\N	f
695	13	17	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
57	4	51	\N	TRANSFERRED	\N	\N	f
696	1	51	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
58	4	34	\N	TRANSFERRED	\N	\N	f
697	1	34	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
59	3	58	\N	TRANSFERRED	\N	\N	f
698	13	58	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
60	1	4	\N	TRANSFERRED	\N	\N	f
699	4	4	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
61	4	35	\N	TRANSFERRED	\N	\N	f
700	1	35	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
62	3	40	\N	TRANSFERRED	\N	\N	f
701	13	40	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
64	3	23	\N	TRANSFERRED	\N	\N	f
702	13	23	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
65	3	16	\N	TRANSFERRED	\N	\N	f
703	13	16	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
66	1	42	\N	TRANSFERRED	\N	\N	f
704	4	42	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
63	1	9	\N	TRANSFERRED	\N	\N	f
67	1	3	\N	TRANSFERRED	\N	\N	f
68	4	76	\N	TRANSFERRED	\N	\N	f
705	1	76	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
69	5	74	\N	TRANSFERRED	\N	\N	f
706	19	74	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
70	5	67	\N	TRANSFERRED	\N	\N	f
707	19	67	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
71	5	106	\N	TRANSFERRED	\N	\N	f
708	19	106	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
73	5	66	\N	TRANSFERRED	\N	\N	f
709	19	66	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
72	4	44	\N	TRANSFERRED	\N	\N	f
710	1	44	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
74	4	61	\N	TRANSFERRED	\N	\N	f
711	1	61	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
75	6	78	\N	TRANSFERRED	\N	\N	f
76	5	108	\N	TRANSFERRED	\N	\N	f
712	19	108	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
77	6	107	\N	TRANSFERRED	\N	\N	f
713	15	107	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
78	5	71	\N	TRANSFERRED	\N	\N	f
714	19	71	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
79	7	73	\N	TRANSFERRED	\N	\N	f
715	17	73	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
80	6	64	\N	TRANSFERRED	\N	\N	f
716	15	64	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
81	6	75	\N	TRANSFERRED	\N	\N	f
717	15	75	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
82	6	103	\N	TRANSFERRED	\N	\N	f
718	15	103	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
83	6	70	\N	TRANSFERRED	\N	\N	f
719	15	70	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
84	4	69	\N	TRANSFERRED	\N	\N	f
720	1	69	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
85	6	97	\N	TRANSFERRED	\N	\N	f
721	15	97	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
86	5	105	\N	TRANSFERRED	\N	\N	f
722	19	105	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
87	6	100	\N	TRANSFERRED	\N	\N	f
723	15	100	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
88	4	110	\N	TRANSFERRED	\N	\N	f
724	1	110	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
89	7	85	\N	TRANSFERRED	\N	\N	f
725	17	85	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
90	7	92	\N	TRANSFERRED	\N	\N	f
726	17	92	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
92	7	98	\N	TRANSFERRED	\N	\N	f
727	17	98	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
95	7	99	\N	TRANSFERRED	\N	\N	f
728	17	99	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
96	6	68	\N	TRANSFERRED	\N	\N	f
729	15	68	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
97	7	91	\N	TRANSFERRED	\N	\N	f
730	17	91	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
91	6	94	\N	TRANSFERRED	\N	\N	f
731	15	94	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
100	7	101	\N	TRANSFERRED	\N	\N	f
732	17	101	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
93	7	89	\N	TRANSFERRED	\N	\N	f
733	17	89	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
101	6	62	\N	TRANSFERRED	\N	\N	f
734	15	62	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
102	7	82	\N	TRANSFERRED	\N	\N	f
94	7	93	\N	TRANSFERRED	\N	\N	f
735	17	93	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
98	6	79	\N	TRANSFERRED	\N	\N	f
99	7	87	\N	TRANSFERRED	\N	\N	f
736	17	87	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
104	5	63	\N	TRANSFERRED	\N	\N	f
737	19	63	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
108	6	80	\N	TRANSFERRED	\N	\N	f
738	15	80	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
109	5	65	\N	TRANSFERRED	\N	\N	f
739	19	65	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
105	5	102	\N	TRANSFERRED	\N	\N	f
740	19	102	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
103	5	83	\N	TRANSFERRED	\N	\N	f
741	19	83	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
110	6	86	\N	TRANSFERRED	\N	\N	f
742	15	86	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
106	5	104	\N	TRANSFERRED	\N	\N	f
743	19	104	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
107	7	88	\N	TRANSFERRED	\N	\N	f
744	17	88	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
111	5	81	\N	TRANSFERRED	\N	\N	f
745	19	81	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
112	5	95	\N	TRANSFERRED	\N	\N	f
746	19	95	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
113	7	90	\N	TRANSFERRED	\N	\N	f
747	17	90	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
114	6	84	\N	TRANSFERRED	\N	\N	f
748	15	84	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
115	5	77	\N	TRANSFERRED	\N	\N	f
749	19	77	2026-11-21 14:24:01.911663	ENROLLED	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
144	9	128	\N	ENROLLED	\N	\N	f
174	31	202	\N	ENROLLED	\N	\N	f
197	11	173	\N	COMPLETED	\N	\N	f
219	35	227	\N	COMPLETED	\N	\N	f
247	34	222	\N	COMPLETED	\N	\N	f
146	9	130	\N	ENROLLED	\N	\N	f
172	31	201	\N	ENROLLED	\N	\N	f
191	11	170	\N	COMPLETED	\N	\N	f
212	33	187	\N	COMPLETED	\N	\N	f
231	33	213	\N	COMPLETED	\N	\N	f
148	9	138	\N	ENROLLED	\N	\N	f
173	31	167	\N	ENROLLED	\N	\N	f
190	11	178	\N	COMPLETED	\N	\N	f
217	33	197	\N	COMPLETED	\N	\N	f
222	35	230	\N	COMPLETED	\N	\N	f
242	35	249	\N	COMPLETED	\N	\N	f
150	8	114	\N	ENROLLED	\N	\N	f
175	31	181	\N	ENROLLED	\N	\N	f
198	31	175	\N	ENROLLED	\N	\N	f
223	35	221	\N	COMPLETED	\N	\N	f
244	33	215	\N	COMPLETED	\N	\N	f
151	8	139	\N	ENROLLED	\N	\N	f
180	11	177	\N	COMPLETED	\N	\N	f
203	11	196	\N	COMPLETED	\N	\N	f
235	34	216	\N	COMPLETED	\N	\N	f
147	30	137	\N	ENROLLED	\N	\N	f
170	11	174	\N	COMPLETED	\N	\N	f
193	11	193	\N	COMPLETED	\N	\N	f
216	33	194	\N	COMPLETED	\N	\N	f
234	34	217	\N	COMPLETED	\N	\N	f
256	35	218	\N	COMPLETED	\N	\N	f
149	9	160	\N	ENROLLED	\N	\N	f
179	30	163	\N	ENROLLED	\N	\N	f
201	11	168	\N	COMPLETED	\N	\N	f
233	34	223	\N	COMPLETED	\N	\N	f
254	34	220	\N	COMPLETED	\N	\N	f
\.


--
-- Data for Name: KHOA_HOC; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."KHOA_HOC" ("MaKhoaHoc", "MaSoKhoaHoc", "TenKhoaHoc", "MoTa", "TrinhDoMucTieu", "ThoiLuongTuan", "HocPhi", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
1	IELTS-PREP-65	Luyện thi IELTS Chuyên Sâu 6.5+	Khóa học tập trung rèn luyện 4 kỹ năng chuẩn học thuật với mục tiêu đầu ra IELTS 6.5.	IELTS 6.5	12	8500000	t	2026-11-20 14:39:05.804003	2026-11-20 14:39:05.804006	f
2	IELTS-MASTER-75	Luyện thi IELTS Master 7.5+	Khóa học nâng cao dành cho học viên đã đạt IELTS 6.5 muốn bứt phá lên 7.5+.	IELTS 7.5	12	10500000	t	2026-11-20 14:39:05.804007	2026-11-20 14:39:05.804007	f
3	TOEIC-INTENSIVE-750	TOEIC Cấp Tốc 750+	Chinh phục kỳ thi TOEIC 2 kỹ năng Nghe - Đọc đạt chuẩn đầu ra đại học và đi làm.	TOEIC 750	8	5200000	t	2026-11-20 14:39:05.804008	2026-11-20 14:39:05.804008	f
4	COMM-A2-BASIC	Tiếng Anh Giao Tiếp Nền Tảng A2	Xây dựng nền tảng phát âm chuẩn IPA, bổ sung 1000 từ vựng đời sống và luyện phản xạ giao tiếp tự nhiên.	A2 Elementary	8	3800000	t	2026-11-20 14:39:05.804009	2026-11-20 14:39:05.804009	f
5	COMM-B1-FLUENT	Tiếng Anh Giao Tiếp Tự Tin B1+	Nâng cao khả năng diễn đạt lưu loát, thuyết trình, đàm phán công việc và tự tin giao tiếp với người bản xứ.	B1 Intermediate	10	4800000	t	2026-11-20 14:39:05.80401	2026-11-20 14:39:05.80401	f
6	IELTS-FOUNDATION-50	Luyện thi IELTS Nền Tảng 5.0+	Khóa học xây dựng nền móng ngữ pháp, từ vựng học thuật và phương pháp làm quen cấu trúc đề thi 4 kỹ năng.	IELTS 5.0	10	6800000	t	2026-11-20 14:39:05.804011	2026-11-20 14:39:05.804011	f
7	TOEIC-STARTER-550	TOEIC Mục Tiêu 550+	Trang bị các bẫy đề thi phổ biến, chiến lược phân bổ thời gian và mẹo xử lý đề thi TOEIC Nghe - Đọc chuẩn xác.	TOEIC 550	8	4200000	t	2026-11-20 14:39:05.804012	2026-11-20 14:39:05.804012	f
8	TEENS-ACADEMIC-B2	Tiếng Anh Học Thuật Thiếu Niên B2	Phát triển tư duy phản biện, kỹ năng viết luận học thuật và thuyết trình tiếng Anh tự tin cho học sinh THCS/THPT.	B2 Upper-Intermediate	12	7500000	t	2026-11-20 14:39:05.804013	2026-11-20 14:39:05.804013	f
19	COMM-A1	Tiếng Anh Giao Tiếp Sơ Cấp A1	Khóa học nền tảng giao tiếp căn bản cho người mới bắt đầu	A1	10	3200000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
20	COMM-B2	Tiếng Anh Giao Tiếp Chuyên Nghiệp B2	Giao tiếp công sở, thuyết trình và đàm phán thương mại	B2	12	4500000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
21	IELTS-80	Luyện thi IELTS Chinh Phục 8.0+	Chiến thuật chuyên sâu 4 kỹ năng band điểm xuất sắc 8.0+	C1	14	8500000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
22	TOEIC-850	TOEIC Xuất Sắc 850+	Luyện đề nâng cao và làm chủ bẫy đề thi TOEIC 2 kỹ năng	B2	10	4200000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
23	TOEFL-IBT	Luyện thi TOEFL iBT Quốc Tế	Chương trình chuẩn khảo thí ETS du học Mỹ và Canada	B2	12	6800000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
24	SAT-DIGITAL	Luyện thi Digital SAT Chiến Thuật	Toán học & Đọc hiểu thích ứng cho học sinh săn học bổng	B2	14	9200000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
25	PTE-ACAD	Tiếng Anh PTE Academic Cấp Tốc	Luyện thi chứng chỉ PTE du học và định cư Úc/New Zealand	B1	8	5500000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
26	KIDS-MOVERS	Tiếng Anh Trẻ Em Movers	Chương trình Cambridge YLE cấp độ Movers cho học sinh tiểu học	A1	12	3600000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
27	KIDS-FLYERS	Tiếng Anh Trẻ Em Flyers	Chương trình Cambridge YLE cấp độ Flyers chuẩn bị lên cấp 2	A2	12	3800000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
28	TEENS-B1	Tiếng Anh Thiếu Niên Khởi Động B1	Rèn luyện tư duy phản biện và ngữ pháp học thuật cho THCS	B1	12	4200000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
29	BUS-WRITING	Viết Email & Soạn Thảo Hợp Đồng Thương Mại	Kỹ năng thư tín thương mại quốc tế cho người đi làm	B1	8	3500000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
30	PRONUNCIATION	Luyện Phát Âm Chuẩn Quốc Tế & Ngữ Điệu	Phát âm chuẩn IPA, ngữ điệu bản xứ và nối âm tự nhiên	A1	6	2500000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
31	VSTEP-B1B2	Luyện thi Chứng chỉ VSTEP B1-B2 Quốc Gia	Ôn thi chuẩn đầu ra Đại học & Cao học theo Bộ GD&ĐT	B1	10	3900000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
32	GRAMMAR-PRO	Ngữ Pháp Tiếng Anh Ứng Dụng Chuyên Sâu	Hệ thống hóa toàn bộ cấu trúc câu và từ loại học thuật	A2	8	2800000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
33	PUBLIC-SPEAKING	Kỹ Năng Thuyết Trình & Hùng Biện Tiếng Anh	Tự tin nói trước đám đông và tranh biện tiếng Anh	B2	8	3900000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
34	ACAD-WRITING	Kỹ Năng Viết Học Thuật & Luận Văn Đại Học	Phương pháp trích dẫn APA, viết luận văn và báo cáo khoa học	B2	10	5200000	t	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
11	IELTS-75	IELTS Master 7.5+	Chinh phục band điểm cao phục vụ du học và định cư	IELTS 7.5	12	10500000	t	\N	\N	f
12	TOEIC-550	TOEIC Căn Bản 550+	Khóa học củng cố ngữ pháp và chiến lược giải đề	TOEIC 550	8	4200000	t	\N	\N	f
13	TOEIC-750	TOEIC Đột Phá 750+	Bứt phá kỹ năng Nghe & Đọc chuẩn quốc tế	TOEIC 750	8	5200000	t	\N	\N	f
14	COMM-A2	Tiếng Anh Giao Tiếp Cơ Bản A2	Xây dựng phản xạ đàm thoại hàng ngày và chuẩn ngữ âm	CEFR A2	8	4500000	t	\N	\N	f
15	COMM-B1	Tiếng Anh Giao Tiếp Phản Xạ B1	Thuyết trình, phỏng vấn và thảo luận công việc	CEFR B1	10	5800000	t	\N	\N	f
16	TEENS-B2	Tiếng Anh Thiếu Niên Học Thuật B2	Phát triển tư duy phản biện cho học sinh THCS/THPT	CEFR B2	12	7200000	t	\N	\N	f
17	BUS-ENG	Tiếng Anh Thương Mại & Đàm Phán	Giao tiếp chuyên nghiệp trong môi trường doanh nghiệp quốc tế	Business Pro	8	6000000	t	\N	\N	f
18	KIDS-STARTERS	Tiếng Anh Trẻ Em Starters	Khơi dậy niềm vui học tiếng Anh qua bài hát và trò chơi	Cambridge Starters	10	4800000	t	\N	\N	f
9	IELTS-50	IELTS Foundation 5.0+	Xây dựng nền tảng từ vựng và ngữ pháp học thuật	IELTS 5.0	10	6800000	t	\N	\N	f
10	IELTS-65	IELTS Intensive 6.5+	Luyện thi cấp tốc 4 kỹ năng chuẩn đầu ra 6.5+	IELTS 6.5	12	8500000	t	\N	\N	f
\.


--
-- Data for Name: LICHSU_KHOA_DIEM; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LICHSU_KHOA_DIEM" ("MaLichSu", "MaLopHoc", "HanhDong", "MaNguoiThucHien", "ThoiGian", "LyDo", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
1	34	UNLOCK	2	2026-11-21 07:06:55.961	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0054	2026-11-21 07:06:55.961	2026-11-21 07:06:55.961	f
40	35	UNLOCK	2	2026-11-21 07:06:55.999	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0069	2026-11-21 07:06:55.999	2026-11-21 07:06:55.999	f
2	30	UNLOCK	2	2026-11-21 07:06:55.962	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0050	2026-11-21 07:06:55.962	2026-11-21 07:06:55.962	f
3	4	UNLOCK	2	2026-11-21 07:06:55.962	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0044	2026-11-21 07:06:55.962	2026-11-21 07:06:55.962	f
4	1	UNLOCK	2	2026-11-21 07:06:55.963	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0042	2026-11-21 07:06:55.963	2026-11-21 07:06:55.963	f
5	33	UNLOCK	2	2026-11-21 07:06:55.963	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0039	2026-11-21 07:06:55.963	2026-11-21 07:06:55.963	f
6	30	UNLOCK	2	2026-11-21 07:06:55.964	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0036	2026-11-21 07:06:55.964	2026-11-21 07:06:55.964	f
7	31	UNLOCK	2	2026-11-21 07:06:55.963	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0051	2026-11-21 07:06:55.963	2026-11-21 07:06:55.963	f
8	33	UNLOCK	2	2026-11-21 07:06:55.964	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0053	2026-11-21 07:06:55.964	2026-11-21 07:06:55.964	f
9	35	UNLOCK	2	2026-11-21 07:06:55.963	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0041	2026-11-21 07:06:55.963	2026-11-21 07:06:55.963	f
10	5	UNLOCK	2	2026-11-21 07:06:55.963	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0045	2026-11-21 07:06:55.963	2026-11-21 07:06:55.963	f
12	6	UNLOCK	2	2026-11-21 07:06:55.964	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0046	2026-11-21 07:06:55.964	2026-11-21 07:06:55.964	f
11	9	UNLOCK	2	2026-11-21 07:06:55.964	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0049	2026-11-21 07:06:55.964	2026-11-21 07:06:55.964	f
13	11	UNLOCK	2	2026-11-21 07:06:55.965	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0052	2026-11-21 07:06:55.965	2026-11-21 07:06:55.965	f
14	11	UNLOCK	2	2026-11-21 07:06:55.965	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0038	2026-11-21 07:06:55.965	2026-11-21 07:06:55.965	f
15	8	UNLOCK	2	2026-11-21 07:06:55.965	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0048	2026-11-21 07:06:55.965	2026-11-21 07:06:55.965	f
17	35	UNLOCK	2	2026-11-21 07:06:55.966	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0055	2026-11-21 07:06:55.966	2026-11-21 07:06:55.966	f
16	3	UNLOCK	2	2026-11-21 07:06:55.966	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0057	2026-11-21 07:06:55.966	2026-11-21 07:06:55.966	f
18	6	UNLOCK	2	2026-11-21 07:06:55.966	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0060	2026-11-21 07:06:55.966	2026-11-21 07:06:55.966	f
19	31	UNLOCK	2	2026-11-21 07:06:55.967	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0037	2026-11-21 07:06:55.967	2026-11-21 07:06:55.967	f
20	5	UNLOCK	2	2026-11-21 07:06:55.969	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0059	2026-11-21 07:06:55.969	2026-11-21 07:06:55.969	f
21	4	UNLOCK	2	2026-11-21 07:06:55.969	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0058	2026-11-21 07:06:55.969	2026-11-21 07:06:55.969	f
22	1	UNLOCK	2	2026-11-21 07:06:55.97	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0056	2026-11-21 07:06:55.97	2026-11-21 07:06:55.97	f
23	3	UNLOCK	2	2026-11-21 07:06:55.97	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0043	2026-11-21 07:06:55.97	2026-11-21 07:06:55.97	f
24	7	UNLOCK	2	2026-11-21 07:06:55.97	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0047	2026-11-21 07:06:55.97	2026-11-21 07:06:55.97	f
25	34	UNLOCK	2	2026-11-21 07:06:55.97	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0040	2026-11-21 07:06:55.97	2026-11-21 07:06:55.97	f
26	8	UNLOCK	2	2026-11-21 07:06:55.993	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0062	2026-11-21 07:06:55.993	2026-11-21 07:06:55.993	f
27	5	UNLOCK	2	2026-11-21 07:06:55.994	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0073	2026-11-21 07:06:55.994	2026-11-21 07:06:55.994	f
28	33	UNLOCK	2	2026-11-21 07:06:55.994	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0067	2026-11-21 07:06:55.994	2026-11-21 07:06:55.994	f
29	4	UNLOCK	2	2026-11-21 07:06:55.994	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0072	2026-11-21 07:06:55.994	2026-11-21 07:06:55.994	f
30	31	UNLOCK	2	2026-11-21 07:06:55.994	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0065	2026-11-21 07:06:55.994	2026-11-21 07:06:55.994	f
31	6	UNLOCK	2	2026-11-21 07:06:55.995	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0074	2026-11-21 07:06:55.995	2026-11-21 07:06:55.995	f
32	7	UNLOCK	2	2026-11-21 07:06:55.995	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0061	2026-11-21 07:06:55.995	2026-11-21 07:06:55.995	f
33	9	UNLOCK	2	2026-11-21 07:06:55.995	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0063	2026-11-21 07:06:55.995	2026-11-21 07:06:55.995	f
34	30	UNLOCK	2	2026-11-21 07:06:55.996	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0064	2026-11-21 07:06:55.996	2026-11-21 07:06:55.996	f
35	7	UNLOCK	2	2026-11-21 07:06:55.996	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0075	2026-11-21 07:06:55.996	2026-11-21 07:06:55.996	f
36	34	UNLOCK	2	2026-11-21 07:06:55.997	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0068	2026-11-21 07:06:55.997	2026-11-21 07:06:55.997	f
37	1	UNLOCK	2	2026-11-21 07:06:55.997	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0070	2026-11-21 07:06:55.997	2026-11-21 07:06:55.997	f
38	11	UNLOCK	2	2026-11-21 07:06:55.999	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0066	2026-11-21 07:06:55.999	2026-11-21 07:06:55.999	f
39	3	UNLOCK	2	2026-11-21 07:06:55.999	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0071	2026-11-21 07:06:55.999	2026-11-21 07:06:55.999	f
41	1	UNLOCK	2	2026-11-19 15:49:45.675426	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0212	2026-11-21 07:33:00.016567	2026-11-21 07:33:00.016567	f
42	1	UNLOCK	2	2026-11-19 15:52:10.541456	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0215	2026-11-21 07:33:00.016567	2026-11-21 07:33:00.016567	f
43	1	UNLOCK	2	2026-11-20 03:16:13.640006	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0218	2026-11-21 07:33:00.016567	2026-11-21 07:33:00.016567	f
44	1	UNLOCK	2	2026-11-20 04:32:10.240503	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0220	2026-11-21 07:33:00.016567	2026-11-21 07:33:00.016567	f
45	1	UNLOCK	2	2026-11-20 04:33:28.925513	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0222	2026-11-21 07:33:00.016567	2026-11-21 07:33:00.016567	f
46	1	UNLOCK	2	2026-11-20 04:53:45.519148	Phê duyệt yêu cầu mở sổ điểm #YC-202611-0242	2026-11-21 07:33:00.016567	2026-11-21 07:33:00.016567	f
\.


--
-- Data for Name: LOP_HOC; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LOP_HOC" ("MaLopHoc", "MaSoLop", "MaKhoaHoc", "MaGiangVien", "SiSoToiDa", "SiSoHienTai", "NgayMoLop", "NgayBatDau", "NgayKetThuc", "TrangThai", "MoKhoaDiemThuCong", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
17	IELTS-50-K16	9	6	25	0	\N	2026-11-28	2027-02-10	OPEN_FOR_ENROLLMENT	f	\N	\N	f
18	TOEIC-550-K31	12	5	25	0	\N	2026-12-01	2027-02-01	OPEN_FOR_ENROLLMENT	f	\N	\N	f
19	COMM-A2-K09	14	4	20	0	\N	2026-12-05	2027-02-05	OPEN_FOR_ENROLLMENT	f	\N	\N	f
20	KIDS-ST-K01	18	13	15	0	\N	2026-12-01	2027-02-15	OPEN_FOR_ENROLLMENT	f	\N	\N	f
21	TEENS-B2-K05	16	34	20	0	\N	2026-12-10	2027-03-10	OPEN_FOR_ENROLLMENT	f	\N	\N	f
1	IELTS-65-K26A	10	1	25	18	\N	2026-11-01	2027-01-24	IN_PROGRESS	f	2026-11-20 14:39:05.848035	2026-11-20 14:39:05.848039	f
10	IELTS-75-K26B	11	3	20	0	\N	2026-12-15	2027-03-15	PLANNING	f	2026-11-20 14:39:05.848051	2026-11-20 14:39:05.848052	f
13	TOEIC-750-K14	13	16	25	0	\N	2026-12-20	2027-02-20	PLANNING	f	\N	\N	f
14	BUS-ENG-K02	17	31	20	0	\N	2027-01-05	2027-03-05	PLANNING	f	\N	\N	f
15	COMM-B1-K11	15	24	20	0	\N	2027-01-10	2027-03-20	PLANNING	f	\N	\N	f
2	IELTS-75-K26A	11	1	20	0	2026-11-01	2026-11-25	2027-02-20	OPEN_FOR_ENROLLMENT	f	2026-11-20 14:39:05.84804	2026-11-20 14:39:05.848041	f
3	TOEIC-750-K12	13	2	25	18	\N	2026-11-05	2027-01-15	IN_PROGRESS	f	2026-11-20 14:39:05.848042	2026-11-20 14:39:05.848043	f
4	IELTS-65-K26B	10	3	25	18	\N	2026-11-10	2027-02-10	IN_PROGRESS	f	2026-11-20 14:39:05.848044	2026-11-20 14:39:05.848044	f
5	COMM-A2-K08	14	4	20	16	\N	2026-11-05	2027-01-05	IN_PROGRESS	f	2026-11-20 14:39:05.848045	2026-11-20 14:39:05.848045	f
6	COMM-B1-K09	15	7	20	16	\N	2026-11-12	2027-01-22	IN_PROGRESS	f	2026-11-20 14:39:05.848046	2026-11-20 14:39:05.848047	f
7	IELTS-50-K15	9	6	25	18	\N	2026-11-08	2027-01-18	IN_PROGRESS	f	2026-11-20 14:39:05.848047	2026-11-20 14:39:05.848048	f
120	TEST-CAN-1795186657	1	1	20	4	\N	\N	\N	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
121	T-DEBUG-1	1	1	20	4	\N	\N	\N	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
122	TEST-CAN-TEMP	1	1	20	4	\N	\N	\N	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
8	TOEIC-550-K30	12	5	25	18	\N	2026-11-15	2027-01-15	IN_PROGRESS	f	2026-11-20 14:39:05.848049	2026-11-20 14:39:05.848049	f
9	TEENS-B2-K04	16	6	20	16	\N	2026-11-18	2027-02-18	IN_PROGRESS	f	2026-11-20 14:39:05.84805	2026-11-20 14:39:05.84805	f
11	IELTS-65-PAST	10	1	25	18	2026-08-01	2026-08-15	2026-10-15	COMPLETED	f	2026-11-20 14:39:05.848052	2026-11-20 14:39:05.848053	f
30	BUS-ENG-K01	17	12	20	15	\N	2026-11-02	2027-01-02	IN_PROGRESS	f	\N	\N	f
31	COMM-B1-K10	15	30	20	15	\N	2026-11-08	2027-01-18	IN_PROGRESS	f	\N	\N	f
33	TOEIC-550-PAST	12	5	25	18	\N	2026-08-01	2026-10-01	COMPLETED	f	\N	\N	f
34	COMM-A2-PAST	14	4	20	16	\N	2026-08-10	2026-10-10	COMPLETED	f	\N	\N	f
35	IELTS-50-PAST	9	6	25	18	\N	2026-07-20	2026-09-30	COMPLETED	f	\N	\N	f
36	DQ-CAP-C010E6	1	8	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
37	DQ-ENDDATE-01BE03	1	10	20	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
38	DQ-CAP-C91A7C	1	12	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
39	DQ-SEAL-A8C515	1	13	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
40	DQ-ORPHAN-529AB9	1	14	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
41	DQ-FULL-7A071A	1	16	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
42	DQ-RACE-5D1D66	1	17	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
43	DQ-RACE2-60C5D0	1	18	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
44	DQ-ENDDATE-BD2A05	1	19	20	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
45	DQ-CAP-5F7B32	1	21	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
46	DQ-SEAL-F13F16	1	22	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
47	DQ-ORPHAN-88B128	1	23	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
48	DQ-FULL-836F17	1	24	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
49	DQ-RACE-C00043	1	25	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
50	DQ-RACE2-2C7588	1	26	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
51	DQ-ENDDATE-8F5B71	1	27	20	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
52	DQ-CAP-62C292	1	29	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
53	DQ-SEAL-400E07	1	30	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
54	DQ-ORPHAN-CC7158	1	31	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
55	DQ-FULL-9D0087	1	32	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
56	DQ-RACE-FA83E2	1	33	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
57	DQ-RACE2-566E87	1	34	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
58	DQ-ENDDATE-0ED1A9	1	35	20	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
59	DQ-CAP-472237	1	38	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
60	DQ-SEAL-FC5D42	1	18	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
61	DQ-ORPHAN-FBD1EC	1	19	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
62	DQ-FULL-A0CB76	1	21	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
63	DQ-RACE-819763	1	22	1	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
64	DQ-RACE2-B39476	1	23	5	4	2026-11-20	2026-11-30	2027-02-13	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
65	IELTS-75-MORN	2	24	20	4	2026-06-01	2026-06-01	2026-08-24	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
66	IELTS-75-EVE	2	25	20	4	2026-10-15	2026-10-15	2027-01-08	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
67	IELTS-75-WKD	2	26	25	4	2026-12-05	2026-12-05	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
68	TOEIC-750-MORN	3	27	25	4	2026-05-12	2026-05-12	2026-07-28	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
69	TOEIC-750-EVE	3	29	25	4	2026-10-05	2026-10-05	2026-12-21	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
70	TOEIC-750-WKD	3	30	25	4	2026-12-06	2026-12-06	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
71	COMM-A2B-MORN	4	31	25	4	2026-06-15	2026-06-15	2026-08-31	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
72	COMM-A2B-EVE	4	32	25	4	2026-10-20	2026-10-20	2027-01-12	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
73	COMM-A2B-WKD	4	33	25	4	2026-12-12	2026-12-12	2027-02-27	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
74	COMM-B1F-MORN	5	34	20	4	2026-06-02	2026-06-02	2026-08-25	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
75	COMM-B1F-EVE	5	35	20	4	2026-10-16	2026-10-16	2027-01-09	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
76	COMM-B1F-WKD	5	38	25	4	2026-12-05	2026-12-05	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
77	IELTS-50F-MORN	6	39	20	4	2026-05-18	2026-05-18	2026-08-10	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
78	IELTS-50F-EVE	6	40	20	4	2026-10-13	2026-10-13	2027-01-13	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
79	IELTS-50F-WKD	6	41	25	4	2026-12-06	2026-12-06	2027-03-07	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
80	TOEIC-550S-MORN	7	42	25	4	2026-06-01	2026-06-01	2026-08-17	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
81	TOEIC-550S-EVE	7	43	25	4	2026-10-06	2026-10-06	2026-12-22	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
82	TOEIC-550S-WKD	7	44	25	4	2026-12-12	2026-12-12	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
83	TEENS-B2A-EVE	8	45	20	4	2026-10-14	2026-10-14	2027-01-15	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
84	TEENS-B2A-WKD	8	26	25	4	2026-12-06	2026-12-06	2027-03-07	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
85	KIDS-ST-K02	18	27	20	4	2026-12-12	2026-12-12	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
86	COMM-A1-MORN	19	29	25	4	2026-06-01	2026-06-01	2026-08-17	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
87	COMM-A1-EVE	19	30	25	4	2026-10-01	2026-10-01	2026-12-17	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
88	COMM-A1-WKD	19	31	25	4	2026-12-05	2026-12-05	2027-02-27	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
89	COMM-B2-EVE	20	32	25	4	2026-10-15	2026-10-15	2027-01-08	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
90	COMM-B2-WKD	20	33	25	4	2026-12-12	2026-12-12	2027-03-06	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
91	IELTS-80-EVE	21	34	18	4	2026-10-20	2026-10-20	2027-01-26	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
92	IELTS-80-WKD	21	35	18	4	2026-12-05	2026-12-05	2027-03-14	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
93	TOEIC-850-EVE	22	38	25	4	2026-10-05	2026-10-05	2026-12-21	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
94	TOEIC-850-WKD	22	39	25	4	2026-12-06	2026-12-06	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
95	TOEFL-IBT-EVE	23	40	20	4	2026-10-13	2026-10-13	2027-01-05	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
96	TOEFL-IBT-WKD	23	41	20	4	2027-01-09	2027-01-09	2027-04-03	PLANNING	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
97	SAT-DIG-EVE	24	42	20	4	2026-10-16	2026-10-16	2027-01-22	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
98	SAT-DIG-WKD	24	43	20	4	2026-12-12	2026-12-12	2027-03-20	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
99	PTE-ACAD-MORN	25	44	20	4	2026-10-05	2026-10-05	2026-12-21	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
100	PTE-ACAD-EVE	25	45	20	4	2026-12-01	2026-12-01	2027-02-16	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
101	KIDS-MOV-K01	26	46	20	4	2026-06-06	2026-06-06	2026-08-29	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
102	KIDS-MOV-K02	26	47	20	4	2026-10-10	2026-10-10	2027-01-02	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
103	KIDS-FLY-K01	27	1	20	4	2026-10-10	2026-10-10	2027-01-02	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
104	KIDS-FLY-K02	27	2	20	4	2026-12-12	2026-12-12	2027-03-06	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
105	TEENS-B1-K01	28	3	25	4	2026-06-01	2026-06-01	2026-08-24	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
106	TEENS-B1-K02	28	4	25	4	2026-10-15	2026-10-15	2027-01-08	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
107	BUS-WRT-EVE	29	5	25	4	2026-10-14	2026-10-14	2026-12-23	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
108	BUS-WRT-WKD	29	34	25	4	2026-12-05	2026-12-05	2027-02-20	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
109	PRONUN-MORN	30	35	20	4	2026-06-02	2026-06-02	2026-08-18	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
110	PRONUN-EVE	30	38	20	4	2026-10-05	2026-10-05	2026-12-21	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
111	PRONUN-WKD	30	39	20	4	2026-12-12	2026-12-12	2027-02-27	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
112	VSTEP-EVE	31	40	30	4	2026-10-05	2026-10-05	2026-12-21	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
113	VSTEP-WKD	31	41	30	4	2026-12-06	2026-12-06	2027-02-28	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
114	GRAMMAR-MORN	32	42	25	4	2026-06-02	2026-06-02	2026-08-18	COMPLETED	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
115	GRAMMAR-EVE	32	43	25	4	2026-10-16	2026-10-16	2027-01-08	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
116	SPEAK-EVE	33	44	25	4	2026-10-16	2026-10-16	2027-01-08	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
117	SPEAK-WKD	33	45	25	4	2026-12-05	2026-12-05	2027-02-27	OPEN_FOR_ENROLLMENT	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
118	ACAD-WRT-EVE	34	46	20	4	2026-10-13	2026-10-13	2027-01-05	IN_PROGRESS	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
119	ACAD-WRT-WKD	34	47	20	4	2027-01-09	2027-01-09	2027-03-27	PLANNING	f	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
\.


--
-- Data for Name: NGUOI_DUNG; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."NGUOI_DUNG" ("MaNguoiDung", "TenDangNhap", "Email", "HoTen", "MatKhau", "VaiTro", "SoDienThoai", "AnhDaiDien", "TrangThai", "SoLanDangNhapSai", "ThoiGianKhoa", "MaXacThucOTP", "HanXacThucOTP", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
37	teacher_26	teacher_26@center.edu.vn	ThS. Bùi Thị Hà	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000026	\N	t	0	\N	\N	\N	\N	\N	f
14	student_phuc	student_phuc@center.edu.vn	Võ Minh Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567893	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614787	2026-11-20 14:39:04.614787	f
12	student_tuan	student_tuan@center.edu.vn	Hoàng Anh Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567891	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.61478	2026-11-20 14:39:04.614784	f
7	teacher_david	david.wilson@center.edu.vn	David Wilson, M.Ed	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456791	\N	t	0	\N	\N	\N	2026-11-20 14:39:02.524323	2026-11-20 14:39:02.524327	f
222	student_0114	student_0114@center.edu.vn	Hoàng Bảo Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000114	\N	t	0	\N	\N	\N	\N	\N	f
1	admin	admin@center.edu.vn	Nguyễn Văn Quản Trị (Admin)	$2b$12$WXb5/UGH3527bTTvE.WHAesGpiqYw4kvtHgtquFm041YVMPUHxo.K	ADMIN	0901234567	\N	t	0	\N	\N	\N	2026-11-20 14:39:01.403837	2026-11-20 14:39:01.40384	f
211	student_0140	student_0140@center.edu.vn	Dương Tiến Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000140	\N	t	0	\N	\N	\N	\N	\N	f
18	student_huy	student_huy@center.edu.vn	Nguyễn Đức Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567897	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614791	2026-11-20 14:39:04.614792	f
5	student	student@center.edu.vn	Phạm Minh Khang (Student)	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567890	\N	t	0	\N	\N	\N	2026-11-20 14:39:01.403846	2026-11-20 14:39:01.403847	f
32	teacher_23	teacher_23@center.edu.vn	ThS. Vũ Tiến Bình	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000023	\N	t	0	\N	\N	\N	\N	\N	f
13	student_chau	student_chau@center.edu.vn	Nguyễn Bảo Châu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567892	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614785	2026-11-20 14:39:04.614786	f
182	student_0128	student_0128@center.edu.vn	Lê Quốc Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000128	\N	t	0	\N	\N	\N	\N	\N	f
186	student_0135	student_0135@center.edu.vn	Đặng Ngọc Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000135	\N	t	0	\N	\N	\N	\N	\N	f
260	student_0190	student_0190@center.edu.vn	Nguyễn Xuân Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000190	\N	t	0	\N	\N	\N	\N	\N	f
233	student_0165	student_0165@center.edu.vn	Vũ Phương Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000165	\N	t	0	\N	\N	\N	\N	\N	f
6	parent	parent@center.edu.vn	Phạm Quốc Hùng (Parent)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945678901	\N	t	0	\N	\N	\N	2026-11-20 14:39:01.403848	2026-11-20 14:39:01.403848	f
23	parent_nam	parent_nam@center.edu.vn	Võ Văn Nam	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945678904	\N	t	0	\N	\N	\N	2026-11-20 14:39:05.776962	2026-11-20 14:39:05.776962	f
20	student_nam	student_nam@center.edu.vn	Lê Hoàng Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567899	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614794	2026-11-20 14:39:04.614794	f
30	teacher_28	teacher_28@center.edu.vn	ThS. Hồ Ngọc Hằng	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000028	\N	t	0	\N	\N	\N	\N	\N	f
29	teacher_09	teacher_09@center.edu.vn	ThS. Đặng Hoàng Khoa	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000009	\N	t	0	\N	\N	\N	\N	\N	f
19	student_ngoc	student_ngoc@center.edu.vn	Trần Bích Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567898	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614792	2026-11-20 14:39:04.614793	f
91	student_0035	student_0035@center.edu.vn	Huỳnh Phương Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000035	\N	t	0	\N	\N	\N	\N	\N	f
109	student_0046	student_0046@center.edu.vn	Nguyễn Thanh Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000046	\N	t	0	\N	\N	\N	\N	\N	f
152	student_0061	student_0061@center.edu.vn	Lý Phương Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000061	\N	t	0	\N	\N	\N	\N	\N	f
3	teacher	teacher@center.edu.vn	ThS. Lê Hoàng Nam (Teacher)	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456789	\N	t	0	\N	\N	\N	2026-11-20 14:39:01.403844	2026-11-20 15:06:28.218483	f
9	teacher_bao	hoang.quocbao@center.edu.vn	Đỗ Gia Bảo, IELTS 8.5	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456795	\N	t	0	\N	\N	\N	2026-11-20 14:39:02.524329	2026-11-20 14:39:02.52433	f
4	teacher2	teacher2@center.edu.vn	ThS. Nguyễn Thị Mai	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456790	\N	t	0	\N	\N	\N	2026-11-20 14:39:01.403845	2026-11-20 14:39:01.403846	f
8	teacher_my	nguyen.thaomy@center.edu.vn	Trần Diễm My, CELTA	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456792	\N	t	0	\N	\N	\N	2026-11-20 14:39:02.524328	2026-11-20 14:39:02.524328	f
34	teacher_11	teacher_11@center.edu.vn	ThS. Đỗ Quốc Minh	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000011	\N	t	0	\N	\N	\N	\N	\N	f
27	teacher_15	teacher_15@center.edu.vn	ThS. Lý Đình Quân	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000015	\N	t	0	\N	\N	\N	\N	\N	f
141	student_0071	student_0071@center.edu.vn	Đặng Khánh Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000071	\N	t	0	\N	\N	\N	\N	\N	f
73	teacher_16	teacher_16@center.edu.vn	ThS. Nguyễn Khánh Quyên	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000016	\N	t	0	\N	\N	\N	\N	\N	f
88	student_0011	student_0011@center.edu.vn	Ngô Thanh Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000011	\N	t	0	\N	\N	\N	\N	\N	f
114	student_0028	student_0028@center.edu.vn	Dương Tiến Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000028	\N	t	0	\N	\N	\N	\N	\N	f
39	teacher_12	teacher_12@center.edu.vn	ThS. Hồ Hải Ngân	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000012	\N	t	0	\N	\N	\N	\N	\N	f
125	student_0024	student_0024@center.edu.vn	Bùi Hải Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000024	\N	t	0	\N	\N	\N	\N	\N	f
90	student_0015	student_0015@center.edu.vn	Trần Hải Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000015	\N	t	0	\N	\N	\N	\N	\N	f
42	teacher_08	teacher_08@center.edu.vn	ThS. Võ Thanh Lan	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000008	\N	t	0	\N	\N	\N	\N	\N	f
36	teacher_25	teacher_25@center.edu.vn	ThS. Đặng Bảo Dũng	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000025	\N	t	0	\N	\N	\N	\N	\N	f
113	student_0012	student_0012@center.edu.vn	Dương Minh Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000012	\N	t	0	\N	\N	\N	\N	\N	f
55	teacher_39	teacher_39@center.edu.vn	ThS. Vũ Quốc Thắng	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000039	\N	t	0	\N	\N	\N	\N	\N	f
110	student_0051	student_0051@center.edu.vn	Huỳnh Mỹ Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000051	\N	t	0	\N	\N	\N	\N	\N	f
108	student_0050	student_0050@center.edu.vn	Hoàng Xuân Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000050	\N	t	0	\N	\N	\N	\N	\N	f
165	student_0069	student_0069@center.edu.vn	Vũ Mai Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000069	\N	t	0	\N	\N	\N	\N	\N	f
93	student_0030	student_0030@center.edu.vn	Nguyễn Bảo Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000030	\N	t	0	\N	\N	\N	\N	\N	f
101	student_0048	student_0048@center.edu.vn	Lê Đình Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000048	\N	t	0	\N	\N	\N	\N	\N	f
135	student_0077	student_0077@center.edu.vn	Lý Mỹ Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000077	\N	t	0	\N	\N	\N	\N	\N	f
134	student_0059	student_0059@center.edu.vn	Ngô Thu Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000059	\N	t	0	\N	\N	\N	\N	\N	f
136	student_0084	student_0084@center.edu.vn	Phan Tiến Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000084	\N	t	0	\N	\N	\N	\N	\N	f
140	student_0066	student_0066@center.edu.vn	Hoàng Đức Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000066	\N	t	0	\N	\N	\N	\N	\N	f
153	student_0095	student_0095@center.edu.vn	Trần Mai Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000095	\N	t	0	\N	\N	\N	\N	\N	f
154	student_0090	student_0090@center.edu.vn	Hồ Văn Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000090	\N	t	0	\N	\N	\N	\N	\N	f
148	student_0097	student_0097@center.edu.vn	Phạm Khánh Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000097	\N	t	0	\N	\N	\N	\N	\N	f
146	student_0093	student_0093@center.edu.vn	Lý Hải Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000093	\N	t	0	\N	\N	\N	\N	\N	f
156	student_0102	student_0102@center.edu.vn	Võ Thanh Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000102	\N	t	0	\N	\N	\N	\N	\N	f
151	student_0086	student_0086@center.edu.vn	Võ Bảo Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000086	\N	t	0	\N	\N	\N	\N	\N	f
155	student_0100	student_0100@center.edu.vn	Phan Quốc Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000100	\N	t	0	\N	\N	\N	\N	\N	f
130	student_0076	student_0076@center.edu.vn	Dương Đình Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000076	\N	t	0	\N	\N	\N	\N	\N	f
145	student_0082	student_0082@center.edu.vn	Hoàng Tuấn An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000082	\N	t	0	\N	\N	\N	\N	\N	f
58	teacher_31	teacher_31@center.edu.vn	ThS. Lý Hữu Khoa	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000031	\N	t	0	\N	\N	\N	\N	\N	f
50	teacher_37	teacher_37@center.edu.vn	ThS. Huỳnh Hoàng Quân	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000037	\N	t	0	\N	\N	\N	\N	\N	f
16	student_dung	student_dung@center.edu.vn	Đặng Tiến Dũng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567895	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614789	2026-11-20 14:39:04.61479	f
77	student_0018	student_0018@center.edu.vn	Hoàng Thanh Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000018	\N	t	0	\N	\N	\N	\N	\N	f
87	student_0031	student_0031@center.edu.vn	Trần Ngọc Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000031	\N	t	0	\N	\N	\N	\N	\N	f
105	student_0017	student_0017@center.edu.vn	Phạm Mai Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000017	\N	t	0	\N	\N	\N	\N	\N	f
48	teacher_38	teacher_38@center.edu.vn	ThS. Phan Hải Phương	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000038	\N	t	0	\N	\N	\N	\N	\N	f
78	student_0021	student_0021@center.edu.vn	Vũ Diễm Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000021	\N	t	0	\N	\N	\N	\N	\N	f
53	teacher_19	teacher_19@center.edu.vn	ThS. Phạm Hải Trung	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000019	\N	t	0	\N	\N	\N	\N	\N	f
51	teacher_27	teacher_27@center.edu.vn	ThS. Đỗ Gia Hải	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000027	\N	t	0	\N	\N	\N	\N	\N	f
102	student_0039	student_0039@center.edu.vn	Đặng Bích Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000039	\N	t	0	\N	\N	\N	\N	\N	f
121	student_0052	student_0052@center.edu.vn	Phan Hải Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000052	\N	t	0	\N	\N	\N	\N	\N	f
107	student_0049	student_0049@center.edu.vn	Phạm Quỳnh Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000049	\N	t	0	\N	\N	\N	\N	\N	f
116	student_0055	student_0055@center.edu.vn	Đặng Thị Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000055	\N	t	0	\N	\N	\N	\N	\N	f
126	student_0062	student_0062@center.edu.vn	Nguyễn Văn Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000062	\N	t	0	\N	\N	\N	\N	\N	f
129	student_0060	student_0060@center.edu.vn	Dương Gia An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000060	\N	t	0	\N	\N	\N	\N	\N	f
137	student_0085	student_0085@center.edu.vn	Vũ Thu Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000085	\N	t	0	\N	\N	\N	\N	\N	f
166	student_0099	student_0099@center.edu.vn	Huỳnh Diễm My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000099	\N	t	0	\N	\N	\N	\N	\N	f
160	student_0103	student_0103@center.edu.vn	Đặng Mỹ Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000103	\N	t	0	\N	\N	\N	\N	\N	f
192	student_0110	student_0110@center.edu.vn	Nguyễn Tuấn Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000110	\N	t	0	\N	\N	\N	\N	\N	f
139	student_0063	student_0063@center.edu.vn	Trần Thanh Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000063	\N	t	0	\N	\N	\N	\N	\N	f
159	student_0108	student_0108@center.edu.vn	Dương Hải Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000108	\N	t	0	\N	\N	\N	\N	\N	f
179	student_0126	student_0126@center.edu.vn	Nguyễn Hoàng An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000126	\N	t	0	\N	\N	\N	\N	\N	f
158	student_0104	student_0104@center.edu.vn	Bùi Đình An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000104	\N	t	0	\N	\N	\N	\N	\N	f
207	student_0130	student_0130@center.edu.vn	Hoàng Thanh Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000130	\N	t	0	\N	\N	\N	\N	\N	f
204	student_0125	student_0125@center.edu.vn	Lý Diễm Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000125	\N	t	0	\N	\N	\N	\N	\N	f
163	student_0105	student_0105@center.edu.vn	Đỗ Thùy Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000105	\N	t	0	\N	\N	\N	\N	\N	f
221	student_0145	student_0145@center.edu.vn	Phạm Hải My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000145	\N	t	0	\N	\N	\N	\N	\N	f
236	student_0170	student_0170@center.edu.vn	Hồ Bảo An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000170	\N	t	0	\N	\N	\N	\N	\N	f
240	student_0180	student_0180@center.edu.vn	Phan Minh Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000180	\N	t	0	\N	\N	\N	\N	\N	f
196	student_0134	student_0134@center.edu.vn	Võ Xuân Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000134	\N	t	0	\N	\N	\N	\N	\N	f
195	student_0127	student_0127@center.edu.vn	Trần Quỳnh Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000127	\N	t	0	\N	\N	\N	\N	\N	f
206	student_0144	student_0144@center.edu.vn	Lê Gia Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000144	\N	t	0	\N	\N	\N	\N	\N	f
237	student_0177	student_0177@center.edu.vn	Phạm Diễm Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000177	\N	t	0	\N	\N	\N	\N	\N	f
212	student_0156	student_0156@center.edu.vn	Dương Quốc Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000156	\N	t	0	\N	\N	\N	\N	\N	f
49	teacher_36	teacher_36@center.edu.vn	ThS. Hoàng Bích Ngọc	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000036	\N	t	0	\N	\N	\N	\N	\N	f
56	teacher_32	teacher_32@center.edu.vn	ThS. Nguyễn Phương Linh	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000032	\N	t	0	\N	\N	\N	\N	\N	f
86	student_0029	student_0029@center.edu.vn	Lý Thị Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000029	\N	t	0	\N	\N	\N	\N	\N	f
124	student_0058	student_0058@center.edu.vn	Hồ Bảo Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000058	\N	t	0	\N	\N	\N	\N	\N	f
133	student_0073	student_0073@center.edu.vn	Đỗ Diễm Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000073	\N	t	0	\N	\N	\N	\N	\N	f
214	student_0158	student_0158@center.edu.vn	Nguyễn Thanh Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000158	\N	t	0	\N	\N	\N	\N	\N	f
123	student_0020	student_0020@center.edu.vn	Phan Đình Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000020	\N	t	0	\N	\N	\N	\N	\N	f
84	student_0014	student_0014@center.edu.vn	Nguyễn Hoàng Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000014	\N	t	0	\N	\N	\N	\N	\N	f
82	student_0013	student_0013@center.edu.vn	Lý Bích Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000013	\N	t	0	\N	\N	\N	\N	\N	f
80	student_0025	student_0025@center.edu.vn	Đỗ Mỹ Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000025	\N	t	0	\N	\N	\N	\N	\N	f
100	student_0043	student_0043@center.edu.vn	Ngô Mai Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000043	\N	t	0	\N	\N	\N	\N	\N	f
118	student_0057	student_0057@center.edu.vn	Đỗ Ngọc Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000057	\N	t	0	\N	\N	\N	\N	\N	f
127	student_0072	student_0072@center.edu.vn	Bùi Quốc Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000072	\N	t	0	\N	\N	\N	\N	\N	f
131	student_0067	student_0067@center.edu.vn	Huỳnh Hải Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000067	\N	t	0	\N	\N	\N	\N	\N	f
128	student_0065	student_0065@center.edu.vn	Phạm Bích Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000065	\N	t	0	\N	\N	\N	\N	\N	f
142	student_0078	student_0078@center.edu.vn	Nguyễn Xuân Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000078	\N	t	0	\N	\N	\N	\N	\N	f
157	student_0089	student_0089@center.edu.vn	Đỗ Thanh Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000089	\N	t	0	\N	\N	\N	\N	\N	f
143	student_0079	student_0079@center.edu.vn	Trần Thùy Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000079	\N	t	0	\N	\N	\N	\N	\N	f
99	student_0044	student_0044@center.edu.vn	Dương Quốc Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000044	\N	t	0	\N	\N	\N	\N	\N	f
98	student_0045	student_0045@center.edu.vn	Lý Khánh Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000045	\N	t	0	\N	\N	\N	\N	\N	f
115	student_0054	student_0054@center.edu.vn	Võ Tuấn Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000054	\N	t	0	\N	\N	\N	\N	\N	f
150	student_0068	student_0068@center.edu.vn	Phan Minh Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000068	\N	t	0	\N	\N	\N	\N	\N	f
161	student_0064	student_0064@center.edu.vn	Lê Hữu Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000064	\N	t	0	\N	\N	\N	\N	\N	f
138	student_0091	student_0091@center.edu.vn	Ngô Bích Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000091	\N	t	0	\N	\N	\N	\N	\N	f
164	student_0092	student_0092@center.edu.vn	Dương Hữu Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000092	\N	t	0	\N	\N	\N	\N	\N	f
167	student_0101	student_0101@center.edu.vn	Vũ Quỳnh Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000101	\N	t	0	\N	\N	\N	\N	\N	f
132	student_0070	student_0070@center.edu.vn	Võ Hoàng Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000070	\N	t	0	\N	\N	\N	\N	\N	f
147	student_0088	student_0088@center.edu.vn	Bùi Gia Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000088	\N	t	0	\N	\N	\N	\N	\N	f
144	student_0094	student_0094@center.edu.vn	Nguyễn Đức Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000094	\N	t	0	\N	\N	\N	\N	\N	f
162	student_0098	student_0098@center.edu.vn	Hoàng Hoàng Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000098	\N	t	0	\N	\N	\N	\N	\N	f
2	staff	staff@center.edu.vn	Trần Thị Học Vụ (Staff)	$2b$12$dw.gsAIPkKJVkXp2jbA/OOpLV9O2yB7EVtRaQWKJ4IcRVi6N3pS3q	ACADEMIC_STAFF	0912345678	\N	t	0	\N	\N	\N	2026-11-20 14:39:01.403842	2026-11-20 14:39:01.403843	f
46	teacher_10	teacher_10@center.edu.vn	ThS. Bùi Bích Mai	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000010	\N	t	0	\N	\N	\N	\N	\N	f
74	teacher_13	teacher_13@center.edu.vn	ThS. Ngô Thanh Nghĩa	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000013	\N	t	0	\N	\N	\N	\N	\N	f
59	teacher_40	teacher_40@center.edu.vn	ThS. Võ Mai Quỳnh	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000040	\N	t	0	\N	\N	\N	\N	\N	f
70	teacher_22	teacher_22@center.edu.vn	ThS. Phan Mỹ Yến	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000022	\N	t	0	\N	\N	\N	\N	\N	f
79	student_0016	student_0016@center.edu.vn	Lê Quốc An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000016	\N	t	0	\N	\N	\N	\N	\N	f
106	student_0042	student_0042@center.edu.vn	Hồ Hoàng Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000042	\N	t	0	\N	\N	\N	\N	\N	f
112	student_0047	student_0047@center.edu.vn	Trần Diễm Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000047	\N	t	0	\N	\N	\N	\N	\N	f
149	student_0096	student_0096@center.edu.vn	Lê Minh Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000096	\N	t	0	\N	\N	\N	\N	\N	f
11	teacher_an	dang.hoaian@center.edu.vn	Vũ Quốc An, TESOL	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456793	\N	t	0	\N	\N	\N	2026-11-20 14:39:02.524332	2026-11-20 14:39:02.524332	f
94	student_0026	student_0026@center.edu.vn	Hồ Tuấn Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000026	\N	t	0	\N	\N	\N	\N	\N	f
168	student_0106	student_0106@center.edu.vn	Hồ Xuân Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000106	\N	t	0	\N	\N	\N	\N	\N	f
194	student_0120	student_0120@center.edu.vn	Bùi Hữu Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000120	\N	t	0	\N	\N	\N	\N	\N	f
210	student_0113	student_0113@center.edu.vn	Phạm Phương Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000113	\N	t	0	\N	\N	\N	\N	\N	f
246	student_0179	student_0179@center.edu.vn	Huỳnh Quỳnh Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000179	\N	t	0	\N	\N	\N	\N	\N	f
262	student_0183	student_0183@center.edu.vn	Đặng Thùy Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000183	\N	t	0	\N	\N	\N	\N	\N	f
298	student_0255	student_0255@center.edu.vn	Trần Diễm Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000255	\N	t	0	\N	\N	\N	\N	\N	f
320	student_0236	student_0236@center.edu.vn	Dương Minh An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000236	\N	t	0	\N	\N	\N	\N	\N	f
278	student_0228	student_0228@center.edu.vn	Phan Gia Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000228	\N	t	0	\N	\N	\N	\N	\N	f
352	student_0298	student_0298@center.edu.vn	Hồ Thanh Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000298	\N	t	0	\N	\N	\N	\N	\N	f
330	student_0274	student_0274@center.edu.vn	Hoàng Xuân Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000274	\N	t	0	\N	\N	\N	\N	\N	f
422	student_0315	student_0315@center.edu.vn	Ngô Thị Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000315	\N	t	0	\N	\N	\N	\N	\N	f
389	student_0341	student_0341@center.edu.vn	Vũ Thị Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000341	\N	t	0	\N	\N	\N	\N	\N	f
428	parent_013	parent_013@center.edu.vn	Trần Hoàng Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000013	\N	t	0	\N	\N	\N	\N	\N	f
468	parent_030	parent_030@center.edu.vn	Lê Bích Chi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000030	\N	t	0	\N	\N	\N	\N	\N	f
475	parent_036	parent_036@center.edu.vn	Võ Khánh Hương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000036	\N	t	0	\N	\N	\N	\N	\N	f
447	parent_050	parent_050@center.edu.vn	Phan Thu Vy (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000050	\N	t	0	\N	\N	\N	\N	\N	f
476	parent_059	parent_059@center.edu.vn	Lý Gia Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000059	\N	t	0	\N	\N	\N	\N	\N	f
514	parent_094	parent_094@center.edu.vn	Lê Mỹ Trang (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000094	\N	t	0	\N	\N	\N	\N	\N	f
497	parent_098	parent_098@center.edu.vn	Phan Thị Anh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000098	\N	t	0	\N	\N	\N	\N	\N	f
561	parent_152	parent_152@center.edu.vn	Hồ Ngọc Lan (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000152	\N	t	0	\N	\N	\N	\N	\N	f
542	parent_137	parent_137@center.edu.vn	Ngô Tuấn Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000137	\N	t	0	\N	\N	\N	\N	\N	f
587	parent_178	parent_178@center.edu.vn	Phan Ngọc My (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000178	\N	t	0	\N	\N	\N	\N	\N	f
45	teacher_21	teacher_21@center.edu.vn	ThS. Huỳnh Tuấn Việt	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000021	\N	t	0	\N	\N	\N	\N	\N	f
169	student_0074	student_0074@center.edu.vn	Hồ Thanh Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000074	\N	t	0	\N	\N	\N	\N	\N	f
205	student_0149	student_0149@center.edu.vn	Vũ Khánh Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000149	\N	t	0	\N	\N	\N	\N	\N	f
184	student_0124	student_0124@center.edu.vn	Dương Minh Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000124	\N	t	0	\N	\N	\N	\N	\N	f
253	student_0202	student_0202@center.edu.vn	Hồ Văn Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000202	\N	t	0	\N	\N	\N	\N	\N	f
242	student_0181	student_0181@center.edu.vn	Vũ Mỹ Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000181	\N	t	0	\N	\N	\N	\N	\N	f
307	student_0227	student_0227@center.edu.vn	Huỳnh Khánh Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000227	\N	t	0	\N	\N	\N	\N	\N	f
284	student_0240	student_0240@center.edu.vn	Lê Quốc Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000240	\N	t	0	\N	\N	\N	\N	\N	f
346	student_0273	student_0273@center.edu.vn	Phạm Bích Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000273	\N	t	0	\N	\N	\N	\N	\N	f
359	student_0299	student_0299@center.edu.vn	Ngô Bích Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000299	\N	t	0	\N	\N	\N	\N	\N	f
417	student_0327	student_0327@center.edu.vn	Đặng Hải Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000327	\N	t	0	\N	\N	\N	\N	\N	f
396	student_0337	student_0337@center.edu.vn	Phạm Mỹ Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000337	\N	t	0	\N	\N	\N	\N	\N	f
464	parent_033	parent_033@center.edu.vn	Huỳnh Văn Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000033	\N	t	0	\N	\N	\N	\N	\N	f
440	parent_041	parent_041@center.edu.vn	Ngô Hoàng Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000041	\N	t	0	\N	\N	\N	\N	\N	f
491	parent_069	parent_069@center.edu.vn	Đặng Hoàng Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000069	\N	t	0	\N	\N	\N	\N	\N	f
501	parent_103	parent_103@center.edu.vn	Đỗ Đình Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000103	\N	t	0	\N	\N	\N	\N	\N	f
563	parent_134	parent_134@center.edu.vn	Bùi Bích Ngọc (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000134	\N	t	0	\N	\N	\N	\N	\N	f
573	parent_151	parent_151@center.edu.vn	Đỗ Minh Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000151	\N	t	0	\N	\N	\N	\N	\N	f
540	parent_129	parent_129@center.edu.vn	Huỳnh Thanh Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000129	\N	t	0	\N	\N	\N	\N	\N	f
577	parent_159	parent_159@center.edu.vn	Phạm Đình Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000159	\N	t	0	\N	\N	\N	\N	\N	f
17	student_anh	student_anh@center.edu.vn	Trần Tuấn Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567896	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.61479	2026-11-20 14:39:04.614791	f
170	student_0087	student_0087@center.edu.vn	Đặng Phương Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000087	\N	t	0	\N	\N	\N	\N	\N	f
208	student_0155	student_0155@center.edu.vn	Ngô Mỹ Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000155	\N	t	0	\N	\N	\N	\N	\N	f
187	student_0123	student_0123@center.edu.vn	Ngô Khánh Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000123	\N	t	0	\N	\N	\N	\N	\N	f
239	student_0172	student_0172@center.edu.vn	Dương Gia Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000172	\N	t	0	\N	\N	\N	\N	\N	f
267	student_0201	student_0201@center.edu.vn	Đỗ Khánh Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000201	\N	t	0	\N	\N	\N	\N	\N	f
322	student_0220	student_0220@center.edu.vn	Dương Hải Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000220	\N	t	0	\N	\N	\N	\N	\N	f
312	student_0233	student_0233@center.edu.vn	Đỗ Mỹ Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000233	\N	t	0	\N	\N	\N	\N	\N	f
283	student_0229	student_0229@center.edu.vn	Vũ Diễm Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000229	\N	t	0	\N	\N	\N	\N	\N	f
326	student_0259	student_0259@center.edu.vn	Huỳnh Mỹ Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000259	\N	t	0	\N	\N	\N	\N	\N	f
364	student_0278	student_0278@center.edu.vn	Võ Tuấn Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000278	\N	t	0	\N	\N	\N	\N	\N	f
347	student_0297	student_0297@center.edu.vn	Đỗ Thanh Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000297	\N	t	0	\N	\N	\N	\N	\N	f
391	student_0336	student_0336@center.edu.vn	Lê Tiến Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000336	\N	t	0	\N	\N	\N	\N	\N	f
402	student_0349	student_0349@center.edu.vn	Lý Thanh Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000349	\N	t	0	\N	\N	\N	\N	\N	f
457	parent_022	parent_022@center.edu.vn	Bùi Ngọc Quyên (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000022	\N	t	0	\N	\N	\N	\N	\N	f
443	parent_024	parent_024@center.edu.vn	Hồ Thu Thảo (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000024	\N	t	0	\N	\N	\N	\N	\N	f
483	parent_080	parent_080@center.edu.vn	Hoàng Thanh Hằng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000080	\N	t	0	\N	\N	\N	\N	\N	f
503	parent_092	parent_092@center.edu.vn	Nguyễn Quỳnh Quỳnh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000092	\N	t	0	\N	\N	\N	\N	\N	f
558	parent_143	parent_143@center.edu.vn	Phạm Gia Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000143	\N	t	0	\N	\N	\N	\N	\N	f
537	parent_126	parent_126@center.edu.vn	Lê Ngọc Hằng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000126	\N	t	0	\N	\N	\N	\N	\N	f
585	parent_176	parent_176@center.edu.vn	Hoàng Thị Linh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000176	\N	t	0	\N	\N	\N	\N	\N	f
15	student_linh	student_linh@center.edu.vn	Lê Thùy Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934567894	\N	t	0	\N	\N	\N	2026-11-20 14:39:04.614788	2026-11-20 14:39:04.614788	f
171	student_0081	student_0081@center.edu.vn	Phạm Thị Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000081	\N	t	0	\N	\N	\N	\N	\N	f
176	student_0109	student_0109@center.edu.vn	Lý Ngọc Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000109	\N	t	0	\N	\N	\N	\N	\N	f
197	student_0139	student_0139@center.edu.vn	Ngô Phương Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000139	\N	t	0	\N	\N	\N	\N	\N	f
215	student_0132	student_0132@center.edu.vn	Phan Đình Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000132	\N	t	0	\N	\N	\N	\N	\N	f
241	student_0178	student_0178@center.edu.vn	Hoàng Đức Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000178	\N	t	0	\N	\N	\N	\N	\N	f
259	student_0206	student_0206@center.edu.vn	Nguyễn Đức Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000206	\N	t	0	\N	\N	\N	\N	\N	f
316	student_0218	student_0218@center.edu.vn	Hồ Xuân Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000218	\N	t	0	\N	\N	\N	\N	\N	f
296	student_0248	student_0248@center.edu.vn	Bùi Hải Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000248	\N	t	0	\N	\N	\N	\N	\N	f
349	student_0301	student_0301@center.edu.vn	Lý Hải Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000301	\N	t	0	\N	\N	\N	\N	\N	f
334	student_0286	student_0286@center.edu.vn	Nguyễn Văn Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000286	\N	t	0	\N	\N	\N	\N	\N	f
416	student_0319	student_0319@center.edu.vn	Trần Thu Chi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000319	\N	t	0	\N	\N	\N	\N	\N	f
395	student_0343	student_0343@center.edu.vn	Đặng Ngọc Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000343	\N	t	0	\N	\N	\N	\N	\N	f
436	parent_014	parent_014@center.edu.vn	Lê Quỳnh Lan (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000014	\N	t	0	\N	\N	\N	\N	\N	f
463	parent_047	parent_047@center.edu.vn	Phạm Đình Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000047	\N	t	0	\N	\N	\N	\N	\N	f
482	parent_090	parent_090@center.edu.vn	Dương Diễm Phương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000090	\N	t	0	\N	\N	\N	\N	\N	f
510	parent_107	parent_107@center.edu.vn	Lý Hải Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000107	\N	t	0	\N	\N	\N	\N	\N	f
536	parent_138	parent_138@center.edu.vn	Dương Mai Quỳnh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000138	\N	t	0	\N	\N	\N	\N	\N	f
564	parent_156	parent_156@center.edu.vn	Nguyễn Phương Ngân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000156	\N	t	0	\N	\N	\N	\N	\N	f
583	parent_169	parent_169@center.edu.vn	Ngô Bảo Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000169	\N	t	0	\N	\N	\N	\N	\N	f
117	student_0019	student_0019@center.edu.vn	Huỳnh Khánh Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000019	\N	t	0	\N	\N	\N	\N	\N	f
172	student_0080	student_0080@center.edu.vn	Lê Hải Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000080	\N	t	0	\N	\N	\N	\N	\N	f
185	student_0115	student_0115@center.edu.vn	Huỳnh Thanh Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000115	\N	t	0	\N	\N	\N	\N	\N	f
203	student_0152	student_0152@center.edu.vn	Bùi Minh Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000152	\N	t	0	\N	\N	\N	\N	\N	f
231	student_0176	student_0176@center.edu.vn	Lê Hữu Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000176	\N	t	0	\N	\N	\N	\N	\N	f
248	student_0192	student_0192@center.edu.vn	Lê Hải An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000192	\N	t	0	\N	\N	\N	\N	\N	f
271	student_0208	student_0208@center.edu.vn	Lê Minh Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000208	\N	t	0	\N	\N	\N	\N	\N	f
281	student_0217	student_0217@center.edu.vn	Đỗ Phương Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000217	\N	t	0	\N	\N	\N	\N	\N	f
303	student_0252	student_0252@center.edu.vn	Dương Tiến Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000252	\N	t	0	\N	\N	\N	\N	\N	f
355	student_0262	student_0262@center.edu.vn	Võ Đức Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000262	\N	t	0	\N	\N	\N	\N	\N	f
332	student_0280	student_0280@center.edu.vn	Bùi Tiến An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000280	\N	t	0	\N	\N	\N	\N	\N	f
371	student_0305	student_0305@center.edu.vn	Phạm Khánh Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000305	\N	t	0	\N	\N	\N	\N	\N	f
390	student_0313	student_0313@center.edu.vn	Đỗ Thùy Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000313	\N	t	0	\N	\N	\N	\N	\N	f
385	student_0316	student_0316@center.edu.vn	Dương Hữu Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000316	\N	t	0	\N	\N	\N	\N	\N	f
425	student_0331	student_0331@center.edu.vn	Ngô Khánh Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000331	\N	t	0	\N	\N	\N	\N	\N	f
405	student_0344	student_0344@center.edu.vn	Bùi Hữu Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000344	\N	t	0	\N	\N	\N	\N	\N	f
426	parent_009	parent_009@center.edu.vn	Ngô Đức Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000009	\N	t	0	\N	\N	\N	\N	\N	f
459	parent_011	parent_011@center.edu.vn	Lý Minh Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000011	\N	t	0	\N	\N	\N	\N	\N	f
470	parent_026	parent_026@center.edu.vn	Dương Phương Trâm (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000026	\N	t	0	\N	\N	\N	\N	\N	f
479	parent_076	parent_076@center.edu.vn	Nguyễn Thu Chi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000076	\N	t	0	\N	\N	\N	\N	\N	f
515	parent_087	parent_087@center.edu.vn	Đỗ Gia Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000087	\N	t	0	\N	\N	\N	\N	\N	f
570	parent_125	parent_125@center.edu.vn	Trần Hoàng Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000125	\N	t	0	\N	\N	\N	\N	\N	f
553	parent_136	parent_136@center.edu.vn	Hồ Hải Phương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000136	\N	t	0	\N	\N	\N	\N	\N	f
543	parent_132	parent_132@center.edu.vn	Võ Thanh My (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000132	\N	t	0	\N	\N	\N	\N	\N	f
591	parent_168	parent_168@center.edu.vn	Hồ Diễm Chi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000168	\N	t	0	\N	\N	\N	\N	\N	f
96	student_0034	student_0034@center.edu.vn	Hoàng Văn Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000034	\N	t	0	\N	\N	\N	\N	\N	f
173	student_0107	student_0107@center.edu.vn	Ngô Thị Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000107	\N	t	0	\N	\N	\N	\N	\N	f
183	student_0112	student_0112@center.edu.vn	Lê Tiến Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000112	\N	t	0	\N	\N	\N	\N	\N	f
220	student_0122	student_0122@center.edu.vn	Hồ Đức Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000122	\N	t	0	\N	\N	\N	\N	\N	f
216	student_0157	student_0157@center.edu.vn	Lý Thùy Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000157	\N	t	0	\N	\N	\N	\N	\N	f
235	student_0163	student_0163@center.edu.vn	Huỳnh Thu Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000163	\N	t	0	\N	\N	\N	\N	\N	f
254	student_0199	student_0199@center.edu.vn	Đặng Mai Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000199	\N	t	0	\N	\N	\N	\N	\N	f
275	student_0191	student_0191@center.edu.vn	Trần Phương My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000191	\N	t	0	\N	\N	\N	\N	\N	f
306	student_0211	student_0211@center.edu.vn	Huỳnh Thị Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000211	\N	t	0	\N	\N	\N	\N	\N	f
277	student_0210	student_0210@center.edu.vn	Hoàng Hoàng Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000210	\N	t	0	\N	\N	\N	\N	\N	f
340	student_0284	student_0284@center.edu.vn	Dương Gia Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000284	\N	t	0	\N	\N	\N	\N	\N	f
362	student_0264	student_0264@center.edu.vn	Bùi Minh Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000264	\N	t	0	\N	\N	\N	\N	\N	f
388	student_0332	student_0332@center.edu.vn	Dương Hải Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000332	\N	t	0	\N	\N	\N	\N	\N	f
24	parent_ha	parent_ha@center.edu.vn	Lê Thanh Hà	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945678905	\N	t	0	\N	\N	\N	2026-11-20 14:39:05.776963	2026-11-20 14:39:05.776963	f
458	parent_012	parent_012@center.edu.vn	Nguyễn Diễm Hoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000012	\N	t	0	\N	\N	\N	\N	\N	f
430	parent_031	parent_031@center.edu.vn	Phạm Gia Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000031	\N	t	0	\N	\N	\N	\N	\N	f
473	parent_039	parent_039@center.edu.vn	Đỗ Minh Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000039	\N	t	0	\N	\N	\N	\N	\N	f
484	parent_064	parent_064@center.edu.vn	Hoàng Diễm Ngân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000064	\N	t	0	\N	\N	\N	\N	\N	f
512	parent_061	parent_061@center.edu.vn	Trần Văn Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000061	\N	t	0	\N	\N	\N	\N	\N	f
546	parent_116	parent_116@center.edu.vn	Võ Diễm Thảo (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000116	\N	t	0	\N	\N	\N	\N	\N	f
569	parent_118	parent_118@center.edu.vn	Bùi Quỳnh Trâm (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000118	\N	t	0	\N	\N	\N	\N	\N	f
548	parent_145	parent_145@center.edu.vn	Huỳnh Văn Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000145	\N	t	0	\N	\N	\N	\N	\N	f
578	parent_173	parent_173@center.edu.vn	Trần Văn Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000173	\N	t	0	\N	\N	\N	\N	\N	f
95	student_0022	student_0022@center.edu.vn	Võ Xuân Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000022	\N	t	0	\N	\N	\N	\N	\N	f
174	student_0075	student_0075@center.edu.vn	Ngô Quỳnh Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000075	\N	t	0	\N	\N	\N	\N	\N	f
180	student_0111	student_0111@center.edu.vn	Trần Thu Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000111	\N	t	0	\N	\N	\N	\N	\N	f
217	student_0116	student_0116@center.edu.vn	Phan Gia Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000116	\N	t	0	\N	\N	\N	\N	\N	f
232	student_0164	student_0164@center.edu.vn	Phan Hải Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000164	\N	t	0	\N	\N	\N	\N	\N	f
263	student_0205	student_0205@center.edu.vn	Lý Quỳnh Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000205	\N	t	0	\N	\N	\N	\N	\N	f
285	student_0238	student_0238@center.edu.vn	Nguyễn Hoàng Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000238	\N	t	0	\N	\N	\N	\N	\N	f
315	student_0256	student_0256@center.edu.vn	Lê Gia Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000256	\N	t	0	\N	\N	\N	\N	\N	f
375	student_0272	student_0272@center.edu.vn	Lê Đình Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000272	\N	t	0	\N	\N	\N	\N	\N	f
338	student_0288	student_0288@center.edu.vn	Lê Hữu Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000288	\N	t	0	\N	\N	\N	\N	\N	f
350	student_0304	student_0304@center.edu.vn	Lê Hải Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000304	\N	t	0	\N	\N	\N	\N	\N	f
409	student_0322	student_0322@center.edu.vn	Hoàng Hoàng Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000322	\N	t	0	\N	\N	\N	\N	\N	f
386	student_0312	student_0312@center.edu.vn	Bùi Gia Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000312	\N	t	0	\N	\N	\N	\N	\N	f
442	parent_021	parent_021@center.edu.vn	Đặng Xuân Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000021	\N	t	0	\N	\N	\N	\N	\N	f
449	parent_052	parent_052@center.edu.vn	Võ Phương Anh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000052	\N	t	0	\N	\N	\N	\N	\N	f
509	parent_067	parent_067@center.edu.vn	Vũ Minh Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000067	\N	t	0	\N	\N	\N	\N	\N	f
493	parent_085	parent_085@center.edu.vn	Đặng Bảo Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000085	\N	t	0	\N	\N	\N	\N	\N	f
575	parent_120	parent_120@center.edu.vn	Hồ Mỹ Yến (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000120	\N	t	0	\N	\N	\N	\N	\N	f
566	parent_155	parent_155@center.edu.vn	Lý Quốc Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000155	\N	t	0	\N	\N	\N	\N	\N	f
534	parent_124	parent_124@center.edu.vn	Nguyễn Thị Hà (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000124	\N	t	0	\N	\N	\N	\N	\N	f
588	parent_161	parent_161@center.edu.vn	Huỳnh Xuân Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000161	\N	t	0	\N	\N	\N	\N	\N	f
175	student_0083	student_0083@center.edu.vn	Huỳnh Ngọc Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000083	\N	t	0	\N	\N	\N	\N	\N	f
177	student_0118	student_0118@center.edu.vn	Võ Văn Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000118	\N	t	0	\N	\N	\N	\N	\N	f
199	student_0141	student_0141@center.edu.vn	Lý Thanh Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000141	\N	t	0	\N	\N	\N	\N	\N	f
224	student_0153	student_0153@center.edu.vn	Đỗ Quỳnh Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000153	\N	t	0	\N	\N	\N	\N	\N	f
247	student_0188	student_0188@center.edu.vn	Dương Đình Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000188	\N	t	0	\N	\N	\N	\N	\N	f
228	student_0160	student_0160@center.edu.vn	Lê Đình Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000160	\N	t	0	\N	\N	\N	\N	\N	f
268	student_0185	student_0185@center.edu.vn	Đỗ Thị Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000185	\N	t	0	\N	\N	\N	\N	\N	f
309	student_0239	student_0239@center.edu.vn	Trần Ngọc Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000239	\N	t	0	\N	\N	\N	\N	\N	f
289	student_0247	student_0247@center.edu.vn	Đặng Bích Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000247	\N	t	0	\N	\N	\N	\N	\N	f
345	student_0277	student_0277@center.edu.vn	Vũ Mai Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000277	\N	t	0	\N	\N	\N	\N	\N	f
353	student_0268	student_0268@center.edu.vn	Dương Quốc Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000268	\N	t	0	\N	\N	\N	\N	\N	f
379	student_0325	student_0325@center.edu.vn	Vũ Bích Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000325	\N	t	0	\N	\N	\N	\N	\N	f
407	student_0333	student_0333@center.edu.vn	Lý Diễm Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000333	\N	t	0	\N	\N	\N	\N	\N	f
465	parent_016	parent_016@center.edu.vn	Hoàng Mỹ Mai (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000016	\N	t	0	\N	\N	\N	\N	\N	f
445	parent_048	parent_048@center.edu.vn	Hoàng Ngọc Trang (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000048	\N	t	0	\N	\N	\N	\N	\N	f
496	parent_073	parent_073@center.edu.vn	Ngô Thanh Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000073	\N	t	0	\N	\N	\N	\N	\N	f
502	parent_101	parent_101@center.edu.vn	Đặng Thanh Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000101	\N	t	0	\N	\N	\N	\N	\N	f
571	parent_113	parent_113@center.edu.vn	Huỳnh Bảo Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000113	\N	t	0	\N	\N	\N	\N	\N	f
560	parent_135	parent_135@center.edu.vn	Đỗ Hải Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000135	\N	t	0	\N	\N	\N	\N	\N	f
545	parent_141	parent_141@center.edu.vn	Trần Bảo Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000141	\N	t	0	\N	\N	\N	\N	\N	f
581	parent_165	parent_165@center.edu.vn	Đặng Tuấn Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000165	\N	t	0	\N	\N	\N	\N	\N	f
178	student_0129	student_0129@center.edu.vn	Phạm Mỹ Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000129	\N	t	0	\N	\N	\N	\N	\N	f
213	student_0151	student_0151@center.edu.vn	Đặng Diễm Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000151	\N	t	0	\N	\N	\N	\N	\N	f
255	student_0175	student_0175@center.edu.vn	Trần Khánh Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000175	\N	t	0	\N	\N	\N	\N	\N	f
229	student_0174	student_0174@center.edu.vn	Nguyễn Văn Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000174	\N	t	0	\N	\N	\N	\N	\N	f
311	student_0251	student_0251@center.edu.vn	Ngô Mai Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000251	\N	t	0	\N	\N	\N	\N	\N	f
292	student_0250	student_0250@center.edu.vn	Hồ Tuấn Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000250	\N	t	0	\N	\N	\N	\N	\N	f
335	student_0293	student_0293@center.edu.vn	Vũ Thu Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000293	\N	t	0	\N	\N	\N	\N	\N	f
360	student_0295	student_0295@center.edu.vn	Đặng Phương Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000295	\N	t	0	\N	\N	\N	\N	\N	f
373	student_0279	student_0279@center.edu.vn	Đặng Khánh Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000279	\N	t	0	\N	\N	\N	\N	\N	f
383	student_0309	student_0309@center.edu.vn	Vũ Quỳnh Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000309	\N	t	0	\N	\N	\N	\N	\N	f
22	parent_trong	parent_trong@center.edu.vn	Trần Đức Trọng	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945678903	\N	t	0	\N	\N	\N	2026-11-20 14:39:05.77696	2026-11-20 14:39:05.776961	f
461	parent_029	parent_029@center.edu.vn	Trần Bảo Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000029	\N	t	0	\N	\N	\N	\N	\N	f
471	parent_037	parent_037@center.edu.vn	Đặng Đức Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000037	\N	t	0	\N	\N	\N	\N	\N	f
431	parent_034	parent_034@center.edu.vn	Phan Mai Hằng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000034	\N	t	0	\N	\N	\N	\N	\N	f
519	parent_062	parent_062@center.edu.vn	Lê Khánh Mai (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000062	\N	t	0	\N	\N	\N	\N	\N	f
477	parent_068	parent_068@center.edu.vn	Võ Mỹ Quyên (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000068	\N	t	0	\N	\N	\N	\N	\N	f
499	parent_100	parent_100@center.edu.vn	Võ Ngọc Dung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000100	\N	t	0	\N	\N	\N	\N	\N	f
539	parent_121	parent_121@center.edu.vn	Ngô Đức Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000121	\N	t	0	\N	\N	\N	\N	\N	f
555	parent_130	parent_130@center.edu.vn	Phan Phương Linh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000130	\N	t	0	\N	\N	\N	\N	\N	f
595	parent_164	parent_164@center.edu.vn	Võ Mai Trâm (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000164	\N	t	0	\N	\N	\N	\N	\N	f
223	student_0117	student_0117@center.edu.vn	Vũ Bích Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000117	\N	t	0	\N	\N	\N	\N	\N	f
181	student_0121	student_0121@center.edu.vn	Đỗ Mai Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000121	\N	t	0	\N	\N	\N	\N	\N	f
209	student_0154	student_0154@center.edu.vn	Hồ Hoàng Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000154	\N	t	0	\N	\N	\N	\N	\N	f
274	student_0186	student_0186@center.edu.vn	Hồ Thanh Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000186	\N	t	0	\N	\N	\N	\N	\N	f
226	student_0166	student_0166@center.edu.vn	Võ Tuấn Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000166	\N	t	0	\N	\N	\N	\N	\N	f
257	student_0193	student_0193@center.edu.vn	Phạm Thanh Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000193	\N	t	0	\N	\N	\N	\N	\N	f
286	student_0212	student_0212@center.edu.vn	Phan Quốc Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000212	\N	t	0	\N	\N	\N	\N	\N	f
313	student_0234	student_0234@center.edu.vn	Hồ Đức Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000234	\N	t	0	\N	\N	\N	\N	\N	f
351	student_0261	student_0261@center.edu.vn	Vũ Thùy Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000261	\N	t	0	\N	\N	\N	\N	\N	f
329	student_0287	student_0287@center.edu.vn	Trần Thùy Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000287	\N	t	0	\N	\N	\N	\N	\N	f
397	student_0347	student_0347@center.edu.vn	Ngô Phương Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000347	\N	t	0	\N	\N	\N	\N	\N	f
419	parent_008	parent_008@center.edu.vn	Hồ Mai Dung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000008	\N	t	0	\N	\N	\N	\N	\N	f
376	student_0328	student_0328@center.edu.vn	Bùi Đình Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000328	\N	t	0	\N	\N	\N	\N	\N	f
435	parent_038	parent_038@center.edu.vn	Bùi Diễm Linh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000038	\N	t	0	\N	\N	\N	\N	\N	f
460	parent_044	parent_044@center.edu.vn	Nguyễn Thùy Phương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000044	\N	t	0	\N	\N	\N	\N	\N	f
522	parent_079	parent_079@center.edu.vn	Phạm Hải Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000079	\N	t	0	\N	\N	\N	\N	\N	f
513	parent_078	parent_078@center.edu.vn	Lê Phương Hà (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000078	\N	t	0	\N	\N	\N	\N	\N	f
487	parent_088	parent_088@center.edu.vn	Hồ Khánh Ngọc (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000088	\N	t	0	\N	\N	\N	\N	\N	f
528	parent_111	parent_111@center.edu.vn	Phạm Tiến Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000111	\N	t	0	\N	\N	\N	\N	\N	f
556	parent_123	parent_123@center.edu.vn	Lý Minh Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000123	\N	t	0	\N	\N	\N	\N	\N	f
596	parent_170	parent_170@center.edu.vn	Dương Quỳnh Hà (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000170	\N	t	0	\N	\N	\N	\N	\N	f
202	student_0142	student_0142@center.edu.vn	Nguyễn Bảo Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000142	\N	t	0	\N	\N	\N	\N	\N	f
225	student_0147	student_0147@center.edu.vn	Huỳnh Mai Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000147	\N	t	0	\N	\N	\N	\N	\N	f
188	student_0131	student_0131@center.edu.vn	Huỳnh Thùy Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000131	\N	t	0	\N	\N	\N	\N	\N	f
250	student_0167	student_0167@center.edu.vn	Đặng Thanh Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000167	\N	t	0	\N	\N	\N	\N	\N	f
227	student_0161	student_0161@center.edu.vn	Phạm Ngọc Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000161	\N	t	0	\N	\N	\N	\N	\N	f
270	student_0203	student_0203@center.edu.vn	Ngô Diễm Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000203	\N	t	0	\N	\N	\N	\N	\N	f
301	student_0253	student_0253@center.edu.vn	Lý Khánh Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000253	\N	t	0	\N	\N	\N	\N	\N	f
279	student_0225	student_0225@center.edu.vn	Phạm Mai Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000225	\N	t	0	\N	\N	\N	\N	\N	f
361	student_0276	student_0276@center.edu.vn	Phan Hải Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000276	\N	t	0	\N	\N	\N	\N	\N	f
333	student_0289	student_0289@center.edu.vn	Phạm Thị Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000289	\N	t	0	\N	\N	\N	\N	\N	f
372	student_0300	student_0300@center.edu.vn	Dương Đình Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000300	\N	t	0	\N	\N	\N	\N	\N	f
410	student_0311	student_0311@center.edu.vn	Đặng Mỹ Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000311	\N	t	0	\N	\N	\N	\N	\N	f
381	student_0320	student_0320@center.edu.vn	Lê Minh Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000320	\N	t	0	\N	\N	\N	\N	\N	f
437	parent_035	parent_035@center.edu.vn	Vũ Hữu Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000035	\N	t	0	\N	\N	\N	\N	\N	f
467	parent_054	parent_054@center.edu.vn	Bùi Thanh Dung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000054	\N	t	0	\N	\N	\N	\N	\N	f
517	parent_071	parent_071@center.edu.vn	Đỗ Quốc Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000071	\N	t	0	\N	\N	\N	\N	\N	f
523	parent_075	parent_075@center.edu.vn	Lý Đình Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000075	\N	t	0	\N	\N	\N	\N	\N	f
485	parent_091	parent_091@center.edu.vn	Lý Hữu Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000091	\N	t	0	\N	\N	\N	\N	\N	f
526	parent_109	parent_109@center.edu.vn	Trần Tuấn Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000109	\N	t	0	\N	\N	\N	\N	\N	f
567	parent_144	parent_144@center.edu.vn	Hoàng Quỳnh Anh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000144	\N	t	0	\N	\N	\N	\N	\N	f
547	parent_139	parent_139@center.edu.vn	Lý Tiến Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000139	\N	t	0	\N	\N	\N	\N	\N	f
582	parent_171	parent_171@center.edu.vn	Lý Gia Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000171	\N	t	0	\N	\N	\N	\N	\N	f
219	student_0133	student_0133@center.edu.vn	Vũ Thị Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000133	\N	t	0	\N	\N	\N	\N	\N	f
198	student_0146	student_0146@center.edu.vn	Hoàng Văn Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000146	\N	t	0	\N	\N	\N	\N	\N	f
189	student_0138	student_0138@center.edu.vn	Hồ Tuấn Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000138	\N	t	0	\N	\N	\N	\N	\N	f
245	student_0169	student_0169@center.edu.vn	Đỗ Bích Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000169	\N	t	0	\N	\N	\N	\N	\N	f
258	student_0196	student_0196@center.edu.vn	Phan Tiến Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000196	\N	t	0	\N	\N	\N	\N	\N	f
305	student_0226	student_0226@center.edu.vn	Hoàng Bảo Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000226	\N	t	0	\N	\N	\N	\N	\N	f
295	student_0232	student_0232@center.edu.vn	Bùi Hữu Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000232	\N	t	0	\N	\N	\N	\N	\N	f
368	student_0282	student_0282@center.edu.vn	Hồ Bảo Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000282	\N	t	0	\N	\N	\N	\N	\N	f
341	student_0292	student_0292@center.edu.vn	Phan Minh Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000292	\N	t	0	\N	\N	\N	\N	\N	f
413	student_0326	student_0326@center.edu.vn	Võ Thanh Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000326	\N	t	0	\N	\N	\N	\N	\N	f
387	student_0345	student_0345@center.edu.vn	Đỗ Thu Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000345	\N	t	0	\N	\N	\N	\N	\N	f
441	parent_045	parent_045@center.edu.vn	Trần Thanh Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000045	\N	t	0	\N	\N	\N	\N	\N	f
456	parent_058	parent_058@center.edu.vn	Dương Hải Hoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000058	\N	t	0	\N	\N	\N	\N	\N	f
521	parent_070	parent_070@center.edu.vn	Bùi Thùy Thảo (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000070	\N	t	0	\N	\N	\N	\N	\N	f
511	parent_066	parent_066@center.edu.vn	Phan Quỳnh Nhi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000066	\N	t	0	\N	\N	\N	\N	\N	f
488	parent_096	parent_096@center.edu.vn	Hoàng Thùy Vy (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000096	\N	t	0	\N	\N	\N	\N	\N	f
531	parent_114	parent_114@center.edu.vn	Phan Khánh Quyên (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000114	\N	t	0	\N	\N	\N	\N	\N	f
550	parent_146	parent_146@center.edu.vn	Phan Mỹ Dung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000146	\N	t	0	\N	\N	\N	\N	\N	f
590	parent_174	parent_174@center.edu.vn	Lê Thùy Hương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000174	\N	t	0	\N	\N	\N	\N	\N	f
190	student_0137	student_0137@center.edu.vn	Đỗ Thu Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000137	\N	t	0	\N	\N	\N	\N	\N	f
200	student_0150	student_0150@center.edu.vn	Võ Đức Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000150	\N	t	0	\N	\N	\N	\N	\N	f
249	student_0162	student_0162@center.edu.vn	Hoàng Xuân Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000162	\N	t	0	\N	\N	\N	\N	\N	f
234	student_0173	student_0173@center.edu.vn	Lý Mai Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000173	\N	t	0	\N	\N	\N	\N	\N	f
269	student_0194	student_0194@center.edu.vn	Hoàng Tuấn Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000194	\N	t	0	\N	\N	\N	\N	\N	f
287	student_0221	student_0221@center.edu.vn	Lý Bích Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000221	\N	t	0	\N	\N	\N	\N	\N	f
304	student_0231	student_0231@center.edu.vn	Đặng Quỳnh Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000231	\N	t	0	\N	\N	\N	\N	\N	f
342	student_0294	student_0294@center.edu.vn	Võ Hoàng Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000294	\N	t	0	\N	\N	\N	\N	\N	f
358	student_0303	student_0303@center.edu.vn	Trần Mai Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000303	\N	t	0	\N	\N	\N	\N	\N	f
399	student_0348	student_0348@center.edu.vn	Dương Minh Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000348	\N	t	0	\N	\N	\N	\N	\N	f
421	student_0342	student_0342@center.edu.vn	Võ Văn Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000342	\N	t	0	\N	\N	\N	\N	\N	f
393	student_0339	student_0339@center.edu.vn	Huỳnh Thùy Vy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000339	\N	t	0	\N	\N	\N	\N	\N	f
432	parent_028	parent_028@center.edu.vn	Nguyễn Thanh Yến (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000028	\N	t	0	\N	\N	\N	\N	\N	f
455	parent_046	parent_046@center.edu.vn	Lê Thị Quỳnh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000046	\N	t	0	\N	\N	\N	\N	\N	f
490	parent_060	parent_060@center.edu.vn	Nguyễn Mai Lan (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000060	\N	t	0	\N	\N	\N	\N	\N	f
520	parent_074	parent_074@center.edu.vn	Dương Ngọc Yến (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000074	\N	t	0	\N	\N	\N	\N	\N	f
516	parent_108	parent_108@center.edu.vn	Nguyễn Bích Mai (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000108	\N	t	0	\N	\N	\N	\N	\N	f
533	parent_117	parent_117@center.edu.vn	Đặng Văn Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000117	\N	t	0	\N	\N	\N	\N	\N	f
557	parent_150	parent_150@center.edu.vn	Bùi Thị Hoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000150	\N	t	0	\N	\N	\N	\N	\N	f
572	parent_147	parent_147@center.edu.vn	Vũ Hữu Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000147	\N	t	0	\N	\N	\N	\N	\N	f
579	parent_163	parent_163@center.edu.vn	Vũ Hải Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000163	\N	t	0	\N	\N	\N	\N	\N	f
191	student_0119	student_0119@center.edu.vn	Đặng Hải Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000119	\N	t	0	\N	\N	\N	\N	\N	f
201	student_0143	student_0143@center.edu.vn	Trần Bích Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000143	\N	t	0	\N	\N	\N	\N	\N	f
244	student_0182	student_0182@center.edu.vn	Võ Hoàng Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000182	\N	t	0	\N	\N	\N	\N	\N	f
251	student_0204	student_0204@center.edu.vn	Dương Hữu Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000204	\N	t	0	\N	\N	\N	\N	\N	f
272	student_0189	student_0189@center.edu.vn	Lý Thu Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000189	\N	t	0	\N	\N	\N	\N	\N	f
280	student_0213	student_0213@center.edu.vn	Vũ Ngọc Mai	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000213	\N	t	0	\N	\N	\N	\N	\N	f
299	student_0230	student_0230@center.edu.vn	Võ Văn Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000230	\N	t	0	\N	\N	\N	\N	\N	f
319	student_0237	student_0237@center.edu.vn	Lý Thị My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000237	\N	t	0	\N	\N	\N	\N	\N	f
343	student_0270	student_0270@center.edu.vn	Nguyễn Thanh Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000270	\N	t	0	\N	\N	\N	\N	\N	f
367	student_0308	student_0308@center.edu.vn	Phan Tiến Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000308	\N	t	0	\N	\N	\N	\N	\N	f
380	student_0317	student_0317@center.edu.vn	Lý Ngọc Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000317	\N	t	0	\N	\N	\N	\N	\N	f
404	parent_007	parent_007@center.edu.vn	Đỗ Hữu Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000007	\N	t	0	\N	\N	\N	\N	\N	f
444	parent_049	parent_049@center.edu.vn	Huỳnh Xuân Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000049	\N	t	0	\N	\N	\N	\N	\N	f
450	parent_053	parent_053@center.edu.vn	Đặng Tuấn Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000053	\N	t	0	\N	\N	\N	\N	\N	f
489	parent_097	parent_097@center.edu.vn	Huỳnh Hoàng Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000097	\N	t	0	\N	\N	\N	\N	\N	f
498	parent_106	parent_106@center.edu.vn	Dương Thanh Lan (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000106	\N	t	0	\N	\N	\N	\N	\N	f
568	parent_157	parent_157@center.edu.vn	Trần Thanh Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000157	\N	t	0	\N	\N	\N	\N	\N	f
529	parent_127	parent_127@center.edu.vn	Phạm Quốc Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000127	\N	t	0	\N	\N	\N	\N	\N	f
580	parent_175	parent_175@center.edu.vn	Phạm Hữu Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000175	\N	t	0	\N	\N	\N	\N	\N	f
193	student_0136	student_0136@center.edu.vn	Bùi Hải Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000136	\N	t	0	\N	\N	\N	\N	\N	f
218	student_0148	student_0148@center.edu.vn	Phan Hữu An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000148	\N	t	0	\N	\N	\N	\N	\N	f
230	student_0171	student_0171@center.edu.vn	Ngô Hải Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000171	\N	t	0	\N	\N	\N	\N	\N	f
264	student_0168	student_0168@center.edu.vn	Bùi Tiến Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000168	\N	t	0	\N	\N	\N	\N	\N	f
308	student_0219	student_0219@center.edu.vn	Ngô Thanh Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000219	\N	t	0	\N	\N	\N	\N	\N	f
282	student_0235	student_0235@center.edu.vn	Ngô Thùy Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000235	\N	t	0	\N	\N	\N	\N	\N	f
325	student_0223	student_0223@center.edu.vn	Trần Hải Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000223	\N	t	0	\N	\N	\N	\N	\N	f
344	student_0269	student_0269@center.edu.vn	Lý Phương Trâm	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000269	\N	t	0	\N	\N	\N	\N	\N	f
366	student_0275	student_0275@center.edu.vn	Huỳnh Hải Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000275	\N	t	0	\N	\N	\N	\N	\N	f
418	student_0323	student_0323@center.edu.vn	Huỳnh Thanh Hằng	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000323	\N	t	0	\N	\N	\N	\N	\N	f
394	student_0340	student_0340@center.edu.vn	Phan Gia Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000340	\N	t	0	\N	\N	\N	\N	\N	f
438	parent_032	parent_032@center.edu.vn	Hoàng Hải Hà (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000032	\N	t	0	\N	\N	\N	\N	\N	f
453	parent_055	parent_055@center.edu.vn	Đỗ Tiến Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000055	\N	t	0	\N	\N	\N	\N	\N	f
518	parent_065	parent_065@center.edu.vn	Huỳnh Đức Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000065	\N	t	0	\N	\N	\N	\N	\N	f
525	parent_083	parent_083@center.edu.vn	Vũ Tiến Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000083	\N	t	0	\N	\N	\N	\N	\N	f
494	parent_093	parent_093@center.edu.vn	Trần Đức Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000093	\N	t	0	\N	\N	\N	\N	\N	f
535	parent_112	parent_112@center.edu.vn	Hoàng Mai Nhi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000112	\N	t	0	\N	\N	\N	\N	\N	f
554	parent_148	parent_148@center.edu.vn	Võ Thùy Hân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000148	\N	t	0	\N	\N	\N	\N	\N	f
584	parent_177	parent_177@center.edu.vn	Huỳnh Đức Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000177	\N	t	0	\N	\N	\N	\N	\N	f
238	student_0159	student_0159@center.edu.vn	Trần Thị Dung	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000159	\N	t	0	\N	\N	\N	\N	\N	f
266	student_0184	student_0184@center.edu.vn	Bùi Quốc Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000184	\N	t	0	\N	\N	\N	\N	\N	f
323	student_0216	student_0216@center.edu.vn	Bùi Đình Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000216	\N	t	0	\N	\N	\N	\N	\N	f
293	student_0246	student_0246@center.edu.vn	Võ Xuân Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000246	\N	t	0	\N	\N	\N	\N	\N	f
302	student_0258	student_0258@center.edu.vn	Hoàng Văn An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000258	\N	t	0	\N	\N	\N	\N	\N	f
336	student_0263	student_0263@center.edu.vn	Đặng Thị Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000263	\N	t	0	\N	\N	\N	\N	\N	f
354	student_0302	student_0302@center.edu.vn	Nguyễn Xuân An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000302	\N	t	0	\N	\N	\N	\N	\N	f
382	student_0324	student_0324@center.edu.vn	Phan Quốc An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000324	\N	t	0	\N	\N	\N	\N	\N	f
406	student_0318	student_0318@center.edu.vn	Nguyễn Đức Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000318	\N	t	0	\N	\N	\N	\N	\N	f
469	parent_020	parent_020@center.edu.vn	Võ Thị Nhi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000020	\N	t	0	\N	\N	\N	\N	\N	f
448	parent_015	parent_015@center.edu.vn	Phạm Quốc Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000015	\N	t	0	\N	\N	\N	\N	\N	f
434	parent_027	parent_027@center.edu.vn	Lý Tiến Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000027	\N	t	0	\N	\N	\N	\N	\N	f
480	parent_077	parent_077@center.edu.vn	Trần Xuân Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000077	\N	t	0	\N	\N	\N	\N	\N	f
506	parent_105	parent_105@center.edu.vn	Ngô Xuân Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000105	\N	t	0	\N	\N	\N	\N	\N	f
532	parent_119	parent_119@center.edu.vn	Đỗ Hữu Dũng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000119	\N	t	0	\N	\N	\N	\N	\N	f
574	parent_128	parent_128@center.edu.vn	Hoàng Thu Hương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000128	\N	t	0	\N	\N	\N	\N	\N	f
549	parent_142	parent_142@center.edu.vn	Lê Diễm Vy (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000142	\N	t	0	\N	\N	\N	\N	\N	f
576	parent_160	parent_160@center.edu.vn	Hoàng Bích Quyên (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000160	\N	t	0	\N	\N	\N	\N	\N	f
597	parent_167	parent_167@center.edu.vn	Đỗ Tiến Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000167	\N	t	0	\N	\N	\N	\N	\N	f
243	student_0187	student_0187@center.edu.vn	Ngô Ngọc Hương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000187	\N	t	0	\N	\N	\N	\N	\N	f
261	student_0195	student_0195@center.edu.vn	Huỳnh Bích Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000195	\N	t	0	\N	\N	\N	\N	\N	f
324	student_0214	student_0214@center.edu.vn	Võ Thanh An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000214	\N	t	0	\N	\N	\N	\N	\N	f
288	student_0244	student_0244@center.edu.vn	Phan Đình Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000244	\N	t	0	\N	\N	\N	\N	\N	f
317	student_0222	student_0222@center.edu.vn	Nguyễn Tuấn Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000222	\N	t	0	\N	\N	\N	\N	\N	f
331	student_0260	student_0260@center.edu.vn	Phan Hữu Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000260	\N	t	0	\N	\N	\N	\N	\N	f
357	student_0285	student_0285@center.edu.vn	Lý Mỹ Ngọc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000285	\N	t	0	\N	\N	\N	\N	\N	f
392	student_0335	student_0335@center.edu.vn	Trần Quỳnh Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000335	\N	t	0	\N	\N	\N	\N	\N	f
21	parent_huong	parent_huong@center.edu.vn	Nguyễn Thu Hương	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945678902	\N	t	0	\N	\N	\N	2026-11-20 14:39:05.776957	2026-11-20 14:39:05.776959	f
472	parent_023	parent_023@center.edu.vn	Đỗ Hải Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000023	\N	t	0	\N	\N	\N	\N	\N	f
439	parent_040	parent_040@center.edu.vn	Hồ Quỳnh My (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000040	\N	t	0	\N	\N	\N	\N	\N	f
466	parent_057	parent_057@center.edu.vn	Ngô Bảo Hùng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000057	\N	t	0	\N	\N	\N	\N	\N	f
481	parent_072	parent_072@center.edu.vn	Hồ Thị Trâm (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000072	\N	t	0	\N	\N	\N	\N	\N	f
504	parent_104	parent_104@center.edu.vn	Hồ Phương Hoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000104	\N	t	0	\N	\N	\N	\N	\N	f
544	parent_140	parent_140@center.edu.vn	Nguyễn Khánh Trang (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000140	\N	t	0	\N	\N	\N	\N	\N	f
551	parent_131	parent_131@center.edu.vn	Vũ Đình Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000131	\N	t	0	\N	\N	\N	\N	\N	f
594	parent_179	parent_179@center.edu.vn	Vũ Minh Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000179	\N	t	0	\N	\N	\N	\N	\N	f
294	student_0243	student_0243@center.edu.vn	Huỳnh Phương Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000243	\N	t	0	\N	\N	\N	\N	\N	f
310	student_0257	student_0257@center.edu.vn	Phạm Quỳnh Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000257	\N	t	0	\N	\N	\N	\N	\N	f
314	student_0254	student_0254@center.edu.vn	Nguyễn Bảo Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000254	\N	t	0	\N	\N	\N	\N	\N	f
365	student_0271	student_0271@center.edu.vn	Trần Thanh Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000271	\N	t	0	\N	\N	\N	\N	\N	f
369	student_0290	student_0290@center.edu.vn	Hoàng Đức Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000290	\N	t	0	\N	\N	\N	\N	\N	f
374	student_0265	student_0265@center.edu.vn	Đỗ Ngọc Quyên	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000265	\N	t	0	\N	\N	\N	\N	\N	f
327	student_0281	student_0281@center.edu.vn	Đỗ Diễm Linh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000281	\N	t	0	\N	\N	\N	\N	\N	f
276	student_0209	student_0209@center.edu.vn	Phạm Thùy Hoa	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000209	\N	t	0	\N	\N	\N	\N	\N	f
339	student_0296	student_0296@center.edu.vn	Bùi Quốc Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000296	\N	t	0	\N	\N	\N	\N	\N	f
356	student_0307	student_0307@center.edu.vn	Huỳnh Diễm Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000307	\N	t	0	\N	\N	\N	\N	\N	f
377	student_0329	student_0329@center.edu.vn	Đỗ Mai My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000329	\N	t	0	\N	\N	\N	\N	\N	f
415	student_0330	student_0330@center.edu.vn	Hồ Xuân Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000330	\N	t	0	\N	\N	\N	\N	\N	f
328	student_0266	student_0266@center.edu.vn	Hồ Hoàng Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000266	\N	t	0	\N	\N	\N	\N	\N	f
337	student_0291	student_0291@center.edu.vn	Huỳnh Ngọc Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000291	\N	t	0	\N	\N	\N	\N	\N	f
363	student_0306	student_0306@center.edu.vn	Hoàng Tuấn Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000306	\N	t	0	\N	\N	\N	\N	\N	f
420	student_0334	student_0334@center.edu.vn	Nguyễn Tuấn Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000334	\N	t	0	\N	\N	\N	\N	\N	f
384	student_0310	student_0310@center.edu.vn	Võ Bảo Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000310	\N	t	0	\N	\N	\N	\N	\N	f
378	student_0321	student_0321@center.edu.vn	Phạm Phương Hà	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000321	\N	t	0	\N	\N	\N	\N	\N	f
398	student_0346	student_0346@center.edu.vn	Hồ Đức An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000346	\N	t	0	\N	\N	\N	\N	\N	f
424	student_0338	student_0338@center.edu.vn	Hoàng Bảo Phúc	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000338	\N	t	0	\N	\N	\N	\N	\N	f
433	parent_018	parent_018@center.edu.vn	Phan Thùy Ngân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000018	\N	t	0	\N	\N	\N	\N	\N	f
423	student_0314	student_0314@center.edu.vn	Hồ Văn Nam	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000314	\N	t	0	\N	\N	\N	\N	\N	f
429	parent_010	parent_010@center.edu.vn	Dương Khánh Hân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000010	\N	t	0	\N	\N	\N	\N	\N	f
427	parent_017	parent_017@center.edu.vn	Huỳnh Thanh Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000017	\N	t	0	\N	\N	\N	\N	\N	f
408	student_0350	student_0350@center.edu.vn	Nguyễn Hoàng Đạt	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000350	\N	t	0	\N	\N	\N	\N	\N	f
446	parent_043	parent_043@center.edu.vn	Lý Quốc Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000043	\N	t	0	\N	\N	\N	\N	\N	f
25	parent_lien	parent_lien@center.edu.vn	Trần Thị Kim Liên	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945678906	\N	t	0	\N	\N	\N	2026-11-20 14:39:05.776964	2026-11-20 14:39:05.776964	f
454	parent_042	parent_042@center.edu.vn	Dương Mỹ Ngọc (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000042	\N	t	0	\N	\N	\N	\N	\N	f
451	parent_051	parent_051@center.edu.vn	Vũ Hải Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000051	\N	t	0	\N	\N	\N	\N	\N	f
452	parent_056	parent_056@center.edu.vn	Hồ Bích Hân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000056	\N	t	0	\N	\N	\N	\N	\N	f
318	student_0215	student_0215@center.edu.vn	Đặng Thu Ngân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000215	\N	t	0	\N	\N	\N	\N	\N	f
291	student_0242	student_0242@center.edu.vn	Hoàng Thanh Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000242	\N	t	0	\N	\N	\N	\N	\N	f
300	student_0241	student_0241@center.edu.vn	Phạm Thu Phương	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000241	\N	t	0	\N	\N	\N	\N	\N	f
321	student_0224	student_0224@center.edu.vn	Lê Tiến Long	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000224	\N	t	0	\N	\N	\N	\N	\N	f
290	student_0249	student_0249@center.edu.vn	Đỗ Hải Anh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000249	\N	t	0	\N	\N	\N	\N	\N	f
462	parent_025	parent_025@center.edu.vn	Ngô Tuấn Trung (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000025	\N	t	0	\N	\N	\N	\N	\N	f
505	parent_081	parent_081@center.edu.vn	Huỳnh Tuấn Khoa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000081	\N	t	0	\N	\N	\N	\N	\N	f
495	parent_099	parent_099@center.edu.vn	Vũ Quốc Hải (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000099	\N	t	0	\N	\N	\N	\N	\N	f
541	parent_110	parent_110@center.edu.vn	Lê Hải Ngân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000110	\N	t	0	\N	\N	\N	\N	\N	f
559	parent_153	parent_153@center.edu.vn	Ngô Hoàng Quân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000153	\N	t	0	\N	\N	\N	\N	\N	f
589	parent_166	parent_166@center.edu.vn	Bùi Khánh Yến (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000166	\N	t	0	\N	\N	\N	\N	\N	f
474	parent_019	parent_019@center.edu.vn	Vũ Đình Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000019	\N	t	0	\N	\N	\N	\N	\N	f
478	parent_063	parent_063@center.edu.vn	Phạm Hữu Nghĩa (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000063	\N	t	0	\N	\N	\N	\N	\N	f
500	parent_102	parent_102@center.edu.vn	Bùi Thu Hân (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000102	\N	t	0	\N	\N	\N	\N	\N	f
565	parent_158	parent_158@center.edu.vn	Lê Thanh Nhi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000158	\N	t	0	\N	\N	\N	\N	\N	f
530	parent_122	parent_122@center.edu.vn	Dương Thùy Chi (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000122	\N	t	0	\N	\N	\N	\N	\N	f
586	parent_172	parent_172@center.edu.vn	Nguyễn Mỹ Hằng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000172	\N	t	0	\N	\N	\N	\N	\N	f
486	parent_086	parent_086@center.edu.vn	Bùi Mai My (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000086	\N	t	0	\N	\N	\N	\N	\N	f
508	parent_082	parent_082@center.edu.vn	Phan Bích Hương (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000082	\N	t	0	\N	\N	\N	\N	\N	f
562	parent_154	parent_154@center.edu.vn	Dương Thu Mai (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000154	\N	t	0	\N	\N	\N	\N	\N	f
538	parent_133	parent_133@center.edu.vn	Đặng Xuân Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000133	\N	t	0	\N	\N	\N	\N	\N	f
593	parent_162	parent_162@center.edu.vn	Phan Hải Thảo (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000162	\N	t	0	\N	\N	\N	\N	\N	f
54	teacher_14	teacher_14@center.edu.vn	ThS. Dương Mai Nhi	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000014	\N	t	0	\N	\N	\N	\N	\N	f
72	teacher_24	teacher_24@center.edu.vn	ThS. Võ Thùy Chi	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000024	\N	t	0	\N	\N	\N	\N	\N	f
40	teacher_30	teacher_30@center.edu.vn	ThS. Dương Thu Hương	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000030	\N	t	0	\N	\N	\N	\N	\N	f
43	teacher_29	teacher_29@center.edu.vn	ThS. Ngô Văn Hùng	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000029	\N	t	0	\N	\N	\N	\N	\N	f
47	teacher_33	teacher_33@center.edu.vn	ThS. Trần Đức Minh	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000033	\N	t	0	\N	\N	\N	\N	\N	f
57	teacher_35	teacher_35@center.edu.vn	ThS. Phạm Minh Nghĩa	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000035	\N	t	0	\N	\N	\N	\N	\N	f
552	parent_149	parent_149@center.edu.vn	Đặng Đức Minh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000149	\N	t	0	\N	\N	\N	\N	\N	f
10	teacher_phuong	vu.bichphuong@center.edu.vn	Hoàng Minh Phương, MA	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923456794	\N	t	0	\N	\N	\N	2026-11-20 14:39:02.524331	2026-11-20 14:39:02.524331	f
75	teacher_20	teacher_20@center.edu.vn	ThS. Hoàng Quỳnh Trâm	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000020	\N	t	0	\N	\N	\N	\N	\N	f
67	teacher_18	teacher_18@center.edu.vn	ThS. Lê Diễm Thảo	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000018	\N	t	0	\N	\N	\N	\N	\N	f
44	teacher_34	teacher_34@center.edu.vn	ThS. Lê Thanh My	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000034	\N	t	0	\N	\N	\N	\N	\N	f
71	teacher_17	teacher_17@center.edu.vn	ThS. Trần Xuân Thắng	$2b$12$CI.OW030PBWdJqXKcXLaL.sLDmrfisv2B3RA/hfmBFxU7yko5sqvK	TEACHER	0923000017	\N	t	0	\N	\N	\N	\N	\N	f
85	student_0023	student_0023@center.edu.vn	Đặng Quỳnh Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000023	\N	t	0	\N	\N	\N	\N	\N	f
92	student_0037	student_0037@center.edu.vn	Vũ Thanh Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000037	\N	t	0	\N	\N	\N	\N	\N	f
111	student_0040	student_0040@center.edu.vn	Bùi Minh Cường	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000040	\N	t	0	\N	\N	\N	\N	\N	f
104	student_0041	student_0041@center.edu.vn	Đỗ Hải Yến	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000041	\N	t	0	\N	\N	\N	\N	\N	f
97	student_0036	student_0036@center.edu.vn	Phan Hữu Tuấn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000036	\N	t	0	\N	\N	\N	\N	\N	f
122	student_0038	student_0038@center.edu.vn	Võ Đức An	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000038	\N	t	0	\N	\N	\N	\N	\N	f
120	student_0056	student_0056@center.edu.vn	Bùi Tiến Thịnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000056	\N	t	0	\N	\N	\N	\N	\N	f
119	student_0053	student_0053@center.edu.vn	Vũ Thùy My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000053	\N	t	0	\N	\N	\N	\N	\N	f
89	student_0027	student_0027@center.edu.vn	Ngô Thùy Lan	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000027	\N	t	0	\N	\N	\N	\N	\N	f
81	student_0033	student_0033@center.edu.vn	Phạm Thu Nhi	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000033	\N	t	0	\N	\N	\N	\N	\N	f
103	student_0032	student_0032@center.edu.vn	Lê Gia Sơn	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000032	\N	t	0	\N	\N	\N	\N	\N	f
265	student_0198	student_0198@center.edu.vn	Võ Bảo Hiếu	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000198	\N	t	0	\N	\N	\N	\N	\N	f
273	student_0207	student_0207@center.edu.vn	Trần Mỹ Hân	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000207	\N	t	0	\N	\N	\N	\N	\N	f
256	student_0200	student_0200@center.edu.vn	Bùi Gia Huy	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000200	\N	t	0	\N	\N	\N	\N	\N	f
252	student_0197	student_0197@center.edu.vn	Vũ Hải Quỳnh	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000197	\N	t	0	\N	\N	\N	\N	\N	f
297	student_0245	student_0245@center.edu.vn	Vũ Thanh Trang	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000245	\N	t	0	\N	\N	\N	\N	\N	f
348	student_0267	student_0267@center.edu.vn	Ngô Thu Thảo	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000267	\N	t	0	\N	\N	\N	\N	\N	f
370	student_0283	student_0283@center.edu.vn	Ngô Quỳnh My	$2b$12$UGJKzKqzGB89SzfhLPM0quN2yDHgdSCb6QdFCIJw5tpdyZs..qxK6	STUDENT	0934000283	\N	t	0	\N	\N	\N	\N	\N	f
524	parent_084	parent_084@center.edu.vn	Võ Hải Linh (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000084	\N	t	0	\N	\N	\N	\N	\N	f
507	parent_089	parent_089@center.edu.vn	Ngô Văn Thắng (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000089	\N	t	0	\N	\N	\N	\N	\N	f
492	parent_095	parent_095@center.edu.vn	Phạm Minh Bình (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000095	\N	t	0	\N	\N	\N	\N	\N	f
527	parent_115	parent_115@center.edu.vn	Vũ Gia Việt (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000115	\N	t	0	\N	\N	\N	\N	\N	f
592	parent_180	parent_180@center.edu.vn	Võ Thu Ngọc (PH)	$2b$12$O6jlUJzM4ATzpCzkXQCbGe5u.UMRjADGcMGSeqRR1MJTyA2YhAsy6	PARENT	0945000180	\N	t	0	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: PHONG_HOC; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PHONG_HOC" ("MaPhongHoc", "MaSoPhong", "ToaNha", "SucChua", "TrangThai", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
3	LAB.201	Tòa nhà B (Phòng máy)	35	AVAILABLE	2026-11-20 14:39:05.813756	2026-11-20 14:39:05.813756	f
7	LAB.202	Tòa nhà B (Phòng máy)	30	AVAILABLE	2026-11-20 14:39:05.813759	2026-11-20 14:39:05.813759	f
8	HALL.101	Tòa nhà C	80	AVAILABLE	2026-11-20 14:39:05.81376	2026-11-20 14:39:05.81376	f
21	P.104	Tòa nhà A	30	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
22	P.204	Tòa nhà B	30	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
23	P.304	Tòa nhà C	25	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
24	P.401	Tòa nhà B	35	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
25	P.402	Tòa nhà B	35	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
26	LAB.301	Tòa nhà A (Phòng máy)	30	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
27	LAB.302	Tòa nhà B (Phòng máy)	30	AVAILABLE	2026-11-21 14:24:01.911663	2026-11-21 14:24:01.911663	f
1	P.101	Tòa nhà A	30	AVAILABLE	2026-11-20 14:39:05.813749	2026-11-20 14:39:05.813753	f
2	P.102	Tòa nhà A	25	AVAILABLE	2026-11-20 14:39:05.813755	2026-11-20 14:39:05.813755	f
5	P.103	Tòa nhà A	25	AVAILABLE	2026-11-20 14:39:05.813757	2026-11-20 14:39:05.813758	f
6	P.201	Tòa nhà B	35	AVAILABLE	2026-11-20 14:39:05.813758	2026-11-20 14:39:05.813758	f
15	P.202	Tòa nhà B	30	AVAILABLE	\N	\N	f
16	P.203	Tòa nhà B	20	AVAILABLE	\N	\N	f
4	P.301	Tòa nhà C	40	AVAILABLE	2026-11-20 14:39:05.813756	2026-11-20 14:39:05.813757	f
9	P.302	Tòa nhà C	25	AVAILABLE	2026-11-20 14:39:05.813761	2026-11-20 14:39:05.813761	f
10	P.303	Tòa nhà C	20	AVAILABLE	2026-11-20 14:39:05.813762	2026-11-20 14:39:05.813762	f
20	LAB-01	Tòa nhà D	30	AVAILABLE	\N	\N	f
\.


--
-- Data for Name: PHU_HUYNH_HOC_VIEN; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PHU_HUYNH_HOC_VIEN" ("MaPH_HV", "MaNguoiDung_PH", "MaHocVien", "QuanHe", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
1	6	1	Bố ruột	2026-11-20 14:39:01.439413	2026-11-20 14:39:01.439416	f
2	21	2	Mẹ ruột	2026-11-20 14:39:05.796988	2026-11-20 14:39:05.796992	f
3	22	3	Bố ruột	2026-11-20 14:39:05.796993	2026-11-20 14:39:05.796993	f
4	23	4	Bố ruột	2026-11-20 14:39:05.796994	2026-11-20 14:39:05.796994	f
5	24	5	Mẹ ruột	2026-11-20 14:39:05.796994	2026-11-20 14:39:05.796995	f
6	25	7	Mẹ ruột	2026-11-20 14:39:05.796995	2026-11-20 14:39:05.796996	f
7	433	14	Mẹ	\N	\N	f
8	448	28	Bố	\N	\N	f
9	459	22	Bố	\N	\N	f
10	427	56	Bố	\N	\N	f
11	404	8	Bố	\N	\N	f
12	462	57	Bố	\N	\N	f
13	457	53	Mẹ	\N	\N	f
14	458	42	Mẹ	\N	\N	f
15	469	45	Mẹ	\N	\N	f
17	426	10	Bố	\N	\N	f
16	472	58	Bố	\N	\N	f
18	434	26	Bố	\N	\N	f
19	461	29	Bố	\N	\N	f
20	432	50	Mẹ	\N	\N	f
21	470	13	Mẹ	\N	\N	f
22	429	19	Mẹ	\N	\N	f
24	428	60	Bố	\N	\N	f
23	474	40	Bố	\N	\N	f
25	438	27	Mẹ	\N	\N	f
26	468	31	Mẹ	\N	\N	f
27	430	55	Bố	\N	\N	f
28	475	18	Mẹ	\N	\N	f
29	419	9	Mẹ	\N	\N	f
31	471	21	Bố	\N	\N	f
32	473	35	Bố	\N	\N	f
35	443	17	Mẹ	\N	\N	f
36	464	32	Bố	\N	\N	f
38	439	48	Mẹ	\N	\N	f
30	431	23	Mẹ	\N	\N	f
39	442	30	Bố	\N	\N	f
40	437	16	Bố	\N	\N	f
37	436	20	Mẹ	\N	\N	f
33	435	25	Mẹ	\N	\N	f
34	465	54	Mẹ	\N	\N	f
41	441	51	Bố	\N	\N	f
42	496	94	Bố	\N	\N	f
43	476	108	Bố	\N	\N	f
44	509	67	Bố	\N	\N	f
45	444	44	Bố	\N	\N	f
46	484	74	Mẹ	\N	\N	f
47	491	83	Bố	\N	\N	f
49	455	43	Mẹ	\N	\N	f
48	454	36	Mẹ	\N	\N	f
50	440	34	Bố	\N	\N	f
51	450	76	Bố	\N	\N	f
54	521	86	Mẹ	\N	\N	f
52	519	102	Mẹ	\N	\N	f
55	452	106	Mẹ	\N	\N	f
53	481	75	Mẹ	\N	\N	f
57	512	81	Bố	\N	\N	f
56	517	64	Bố	\N	\N	f
58	449	61	Mẹ	\N	\N	f
59	511	109	Mẹ	\N	\N	f
60	447	69	Mẹ	\N	\N	f
61	520	100	Mẹ	\N	\N	f
62	480	62	Bố	\N	\N	f
63	451	110	Bố	\N	\N	f
64	490	71	Mẹ	\N	\N	f
66	478	95	Bố	\N	\N	f
65	477	66	Mẹ	\N	\N	f
69	479	107	Mẹ	\N	\N	f
70	513	68	Mẹ	\N	\N	f
71	518	104	Bố	\N	\N	f
72	460	47	Mẹ	\N	\N	f
73	463	59	Bố	\N	\N	f
75	483	78	Mẹ	\N	\N	f
76	467	105	Mẹ	\N	\N	f
67	446	39	Bố	\N	\N	f
68	523	79	Bố	\N	\N	f
74	456	77	Mẹ	\N	\N	f
77	466	65	Bố	\N	\N	f
78	445	41	Mẹ	\N	\N	f
79	453	63	Bố	\N	\N	f
80	522	84	Bố	\N	\N	f
81	507	87	Bố	\N	\N	f
82	494	89	Bố	\N	\N	f
83	486	73	Mẹ	\N	\N	f
84	527	158	Bố	\N	\N	f
85	546	113	Mẹ	\N	\N	f
86	499	123	Mẹ	\N	\N	f
88	505	70	Bố	\N	\N	f
87	493	103	Bố	\N	\N	f
89	514	92	Mẹ	\N	\N	f
90	526	116	Bố	\N	\N	f
91	482	90	Mẹ	\N	\N	f
92	571	115	Bố	\N	\N	f
93	508	80	Mẹ	\N	\N	f
94	495	96	Bố	\N	\N	f
95	528	153	Bố	\N	\N	f
97	531	141	Mẹ	\N	\N	f
96	535	149	Mẹ	\N	\N	f
98	532	120	Bố	\N	\N	f
99	504	159	Mẹ	\N	\N	f
100	510	118	Bố	\N	\N	f
101	541	117	Mẹ	\N	\N	f
102	569	154	Mẹ	\N	\N	f
103	501	131	Bố	\N	\N	f
104	516	150	Mẹ	\N	\N	f
106	487	85	Mẹ	\N	\N	f
107	515	82	Bố	\N	\N	f
110	500	111	Mẹ	\N	\N	f
111	525	97	Bố	\N	\N	f
113	533	139	Bố	\N	\N	f
109	492	91	Bố	\N	\N	f
108	498	132	Mẹ	\N	\N	f
112	506	112	Bố	\N	\N	f
105	575	134	Mẹ	\N	\N	f
114	524	72	Mẹ	\N	\N	f
117	485	88	Bố	\N	\N	f
118	489	101	Bố	\N	\N	f
115	502	119	Bố	\N	\N	f
116	503	93	Mẹ	\N	\N	f
119	488	99	Mẹ	\N	\N	f
120	497	98	Mẹ	\N	\N	f
121	544	146	Mẹ	\N	\N	f
122	539	114	Bố	\N	\N	f
123	558	147	Bố	\N	\N	f
124	530	121	Mẹ	\N	\N	f
125	554	144	Mẹ	\N	\N	f
126	561	183	Mẹ	\N	\N	f
127	551	155	Bố	\N	\N	f
128	547	136	Bố	\N	\N	f
129	549	137	Mẹ	\N	\N	f
130	563	157	Mẹ	\N	\N	f
131	552	145	Bố	\N	\N	f
132	574	156	Mẹ	\N	\N	f
133	557	161	Mẹ	\N	\N	f
134	562	162	Mẹ	\N	\N	f
135	542	133	Bố	\N	\N	f
136	559	167	Bố	\N	\N	f
137	548	135	Bố	\N	\N	f
138	545	152	Bố	\N	\N	f
139	572	151	Bố	\N	\N	f
140	550	143	Mẹ	\N	\N	f
141	560	160	Bố	\N	\N	f
142	566	184	Bố	\N	\N	f
143	537	125	Mẹ	\N	\N	f
144	577	201	Bố	\N	\N	f
145	529	140	Bố	\N	\N	f
146	567	142	Mẹ	\N	\N	f
147	576	169	Mẹ	\N	\N	f
148	565	188	Mẹ	\N	\N	f
149	570	124	Bố	\N	\N	f
150	556	138	Bố	\N	\N	f
151	568	165	Bố	\N	\N	f
153	564	191	Mẹ	\N	\N	f
154	536	129	Mẹ	\N	\N	f
155	534	148	Mẹ	\N	\N	f
158	543	128	Mẹ	\N	\N	f
163	595	210	Mẹ	\N	\N	f
159	538	126	Bố	\N	\N	f
161	589	208	Mẹ	\N	\N	f
172	590	206	Mẹ	\N	\N	f
160	573	163	Bố	\N	\N	f
173	584	168	Bố	\N	\N	f
180	591	174	Mẹ	\N	\N	f
162	593	181	Mẹ	\N	\N	f
174	579	205	Bố	\N	\N	f
152	540	122	Bố	\N	\N	f
171	581	175	Bố	\N	\N	f
164	588	164	Bố	\N	\N	f
175	592	171	Mẹ	\N	\N	f
165	583	166	Bố	\N	\N	f
177	582	190	Bố	\N	\N	f
157	555	127	Mẹ	\N	\N	f
178	596	182	Mẹ	\N	\N	f
166	585	193	Mẹ	\N	\N	f
179	594	204	Bố	\N	\N	f
167	578	196	Bố	\N	\N	f
156	553	130	Mẹ	\N	\N	f
176	597	202	Bố	\N	\N	f
168	580	179	Bố	\N	\N	f
169	587	178	Mẹ	\N	\N	f
170	586	177	Mẹ	\N	\N	f
\.


--
-- Data for Name: TIEN_TRINH_KHOA_HOC; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TIEN_TRINH_KHOA_HOC" ("MaTienTrinh", "MaHocVien", "MaKhoaHocHienTai", "MaKhoaHocTiepTheo", "DuDieuKien", "DaXacNhan", "MaNguoiXacNhan", "NgayXacNhan", "GhiChu", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
1	1	1	2	t	t	2	2026-11-20 14:39:06.035349	Học viên đã đạt 8.1 ở khóa IELTS 6.5, đủ điều kiện học lên lớp IELTS Master 7.5+.	2026-11-20 14:39:06.046827	2026-11-20 14:39:06.046831	f
2	2	7	3	t	t	2	2026-11-20 14:39:06.038695	Học viên hoàn thành TOEIC 550 với điểm tổng kết 8.4, đủ điều kiện học TOEIC Cấp Tốc 750+.	2026-11-20 14:39:06.046833	2026-11-20 14:39:06.046834	f
3	3	6	1	t	t	2	2026-11-20 14:39:06.04048	Hoàn thành xuất sắc khóa IELTS Foundation 5.0, chuyển tiếp lên lớp IELTS 6.5+.	2026-11-20 14:39:06.046834	2026-11-20 14:39:06.046835	f
4	5	4	5	t	f	\N	\N	Học viên đạt kết quả xuất sắc ở lớp Giao tiếp A2, chờ xác nhận chuyển tiếp lớp B1+.	2026-11-20 14:39:06.046836	2026-11-20 14:39:06.046836	f
5	1	10	11	t	t	2	2026-11-21 07:06:55.763	Đủ điều kiện chuyển tiếp từ IELTS 6.5 lên 7.5	\N	\N	f
\.


--
-- Data for Name: YEU_CAU_DANG_KY; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."YEU_CAU_DANG_KY" ("MaYeuCau", "MaHocVien", "MaLopHoc", "NgayYeuCau", "TrangThai", "GhiChu", "LyDoTuChoi", "MaNguoiDuyet", "NgayDuyet", "NgayTao", "NgayCapNhat", "DaXoa") FROM stdin;
1	1	1	2026-11-20 14:39:05.902935	APPROVED	Học viên đã nộp học phí qua chuyển khoản	\N	2	2026-11-20 14:39:05.90208	2026-11-20 14:39:05.902939	2026-11-20 14:39:05.90294	f
2	2	3	2026-11-20 14:39:05.928379	APPROVED	Đăng ký thành công khóa TOEIC 750+, thanh toán tiền mặt tại quầy	\N	2	2026-11-20 14:39:05.913277	2026-11-20 14:39:05.928384	2026-11-20 14:39:05.928385	f
3	3	4	2026-11-20 14:39:05.928385	APPROVED	Học viên đạt bài thi test đầu vào 6.0, được chấp nhận vào lớp 6.5+	\N	2	2026-11-20 14:39:05.916836	2026-11-20 14:39:05.928386	2026-11-20 14:39:05.928386	f
4	5	5	2026-11-20 14:39:05.928387	APPROVED	Học viên đăng ký học giao tiếp nền tảng, hoàn tất học phí	\N	2	2026-11-20 14:39:05.919944	2026-11-20 14:39:05.928387	2026-11-20 14:39:05.928388	f
5	4	2	2026-11-20 14:39:05.928388	PENDING	Học viên đang kiểm tra lại lịch học trước khi chuyển khoản học phí	\N	\N	\N	2026-11-20 14:39:05.928389	2026-11-20 14:39:05.928389	f
6	9	7	2026-11-20 14:39:05.92839	PENDING	Học viên chuyển khoản qua ngân hàng, đang chờ kế toán đối soát mã giao dịch	\N	\N	\N	2026-11-20 14:39:05.92839	2026-11-20 14:39:05.92839	f
7	6	1	2026-11-20 14:39:05.928391	REJECTED	Đăng ký không thành công do chưa đạt bài kiểm tra đầu vào	Điểm thi đầu vào 4.5 chưa đủ điều kiện theo học lớp IELTS 6.5+. Đã tư vấn chuyển sang lớp IELTS 5.0+.	2	2026-11-20 14:39:05.927121	2026-11-20 14:39:05.928391	2026-11-20 14:39:05.928392	f
8	2	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.404	\N	\N	f
9	55	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.428	\N	\N	f
10	56	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.428	\N	\N	f
11	26	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.428	\N	\N	f
12	27	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.429	\N	\N	f
13	5	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.43	\N	\N	f
15	31	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.43	\N	\N	f
14	20	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.429	\N	\N	f
16	60	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.432	\N	\N	f
17	19	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.431	\N	\N	f
18	10	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.431	\N	\N	f
19	2	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.432	\N	\N	f
20	36	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.432	\N	\N	f
21	29	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.433	\N	\N	f
22	28	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.433	\N	\N	f
23	32	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.433	\N	\N	f
24	14	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.434	\N	\N	f
25	13	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.434	\N	\N	f
26	39	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.434	\N	\N	f
28	43	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.436	\N	\N	f
27	48	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.435	\N	\N	f
29	18	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.435	\N	\N	f
30	47	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.436	\N	\N	f
31	57	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.436	\N	\N	f
32	8	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.437	\N	\N	f
33	21	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.435	\N	\N	f
34	53	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.437	\N	\N	f
35	45	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.438	\N	\N	f
36	34	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.439	\N	\N	f
37	7	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.437	\N	\N	f
38	30	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.439	\N	\N	f
39	25	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.439	\N	\N	f
40	17	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.44	\N	\N	f
41	22	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.439	\N	\N	f
42	50	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.44	\N	\N	f
43	41	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.44	\N	\N	f
44	59	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
45	51	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
46	54	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
47	4	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
50	58	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
52	42	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
54	23	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
51	16	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
55	35	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
48	3	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
49	9	1	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
53	40	3	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.441	\N	\N	f
56	67	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.475	\N	\N	f
57	74	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.475	\N	\N	f
58	107	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.475	\N	\N	f
59	73	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.475	\N	\N	f
60	66	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.475	\N	\N	f
61	75	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.475	\N	\N	f
62	106	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.476	\N	\N	f
63	76	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.476	\N	\N	f
64	103	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.478	\N	\N	f
65	44	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.478	\N	\N	f
66	64	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.478	\N	\N	f
67	71	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.479	\N	\N	f
68	85	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.478	\N	\N	f
69	61	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.479	\N	\N	f
71	108	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.479	\N	\N	f
93	88	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
111	134	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.522	\N	\N	f
132	122	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
151	117	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.531	\N	\N	f
177	175	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
198	189	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.569	\N	\N	f
227	249	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
73	70	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.479	\N	\N	f
74	101	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.48	\N	\N	f
79	99	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
84	65	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
89	80	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.483	\N	\N	f
92	63	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
91	79	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
100	95	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.485	\N	\N	f
108	158	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.521	\N	\N	f
112	123	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.522	\N	\N	f
113	96	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.523	\N	\N	f
119	132	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.524	\N	\N	f
127	155	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
130	129	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.526	\N	\N	f
129	157	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.526	\N	\N	f
131	156	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.526	\N	\N	f
142	118	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.529	\N	\N	f
148	143	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.53	\N	\N	f
150	137	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.53	\N	\N	f
155	140	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.531	\N	\N	f
154	151	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.531	\N	\N	f
159	169	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.561	\N	\N	f
161	201	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.561	\N	\N	f
164	205	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.562	\N	\N	f
168	145	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.564	\N	\N	f
170	198	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
173	172	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
182	165	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.566	\N	\N	f
183	173	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.566	\N	\N	f
188	171	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
193	168	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
190	206	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.568	\N	\N	f
199	207	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.569	\N	\N	f
203	187	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.569	\N	\N	f
207	254	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.596	\N	\N	f
213	221	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
218	212	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
222	217	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.602	\N	\N	f
225	216	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
232	246	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
240	218	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
241	226	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
243	244	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
70	78	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.479	\N	\N	f
96	94	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
116	113	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.523	\N	\N	f
143	159	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
158	208	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.556	\N	\N	f
172	204	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
196	196	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.568	\N	\N	f
212	214	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
229	222	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
75	100	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.48	\N	\N	f
80	92	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.481	\N	\N	f
85	89	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.483	\N	\N	f
90	98	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
94	86	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
104	109	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.486	\N	\N	f
110	121	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.522	\N	\N	f
115	116	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.523	\N	\N	f
117	141	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.524	\N	\N	f
125	126	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
134	120	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.527	\N	\N	f
135	147	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
141	136	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.529	\N	\N	f
147	119	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.53	\N	\N	f
153	144	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.531	\N	\N	f
157	174	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.556	\N	\N	f
163	183	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.562	\N	\N	f
166	167	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.563	\N	\N	f
171	191	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
174	164	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
185	184	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
187	170	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
189	190	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
195	179	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.568	\N	\N	f
209	230	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.598	\N	\N	f
214	225	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
215	219	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
226	213	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
228	215	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
231	240	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
234	233	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.605	\N	\N	f
77	110	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.481	\N	\N	f
81	93	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
86	62	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
102	104	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.486	\N	\N	f
106	153	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.52	\N	\N	f
109	154	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.521	\N	\N	f
114	111	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.523	\N	\N	f
126	124	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
133	130	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
136	142	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
146	160	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.53	\N	\N	f
152	135	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.531	\N	\N	f
176	161	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
179	166	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.566	\N	\N	f
180	163	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.566	\N	\N	f
197	195	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.568	\N	\N	f
202	185	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.57	\N	\N	f
204	209	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.569	\N	\N	f
208	227	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.596	\N	\N	f
217	252	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
221	229	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.602	\N	\N	f
230	259	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
238	199	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
242	220	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.607	\N	\N	f
72	97	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.479	\N	\N	f
95	81	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.484	\N	\N	f
123	115	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
140	139	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
169	177	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.564	\N	\N	f
192	192	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
219	253	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.6	\N	\N	f
235	231	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.605	\N	\N	f
76	69	4	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.48	\N	\N	f
82	91	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
87	87	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.483	\N	\N	f
98	83	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.485	\N	\N	f
103	102	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.485	\N	\N	f
105	84	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.485	\N	\N	f
120	148	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.524	\N	\N	f
121	133	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.524	\N	\N	f
122	127	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
137	112	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
139	138	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
144	128	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.529	\N	\N	f
156	182	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.557	\N	\N	f
165	202	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.562	\N	\N	f
175	193	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.565	\N	\N	f
178	200	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.566	\N	\N	f
181	180	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
194	203	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.568	\N	\N	f
200	194	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.57	\N	\N	f
201	197	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.569	\N	\N	f
206	251	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.596	\N	\N	f
220	223	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.6	\N	\N	f
223	256	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.602	\N	\N	f
224	211	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.602	\N	\N	f
237	232	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
244	228	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
78	68	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
83	105	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.483	\N	\N	f
88	82	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.482	\N	\N	f
97	90	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.485	\N	\N	f
99	72	6	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.486	\N	\N	f
101	77	5	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.485	\N	\N	f
107	150	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.52	\N	\N	f
118	125	9	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.524	\N	\N	f
124	131	7	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.525	\N	\N	f
128	149	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.526	\N	\N	f
138	146	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.528	\N	\N	f
145	152	30	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.53	\N	\N	f
149	114	8	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.53	\N	\N	f
160	162	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.561	\N	\N	f
162	181	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.561	\N	\N	f
167	188	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.563	\N	\N	f
184	178	11	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.566	\N	\N	f
186	210	31	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.567	\N	\N	f
191	176	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.569	\N	\N	f
205	186	33	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.57	\N	\N	f
210	255	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.598	\N	\N	f
211	257	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.599	\N	\N	f
216	235	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.6	\N	\N	f
233	224	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.604	\N	\N	f
236	236	34	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
239	234	35	\N	APPROVED	Ghi danh theo học phần	\N	2	2026-11-21 07:06:55.606	\N	\N	f
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
0e23e790063c
\.


--
-- Name: BANG_DIEM_MaBangDiem_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."BANG_DIEM_MaBangDiem_seq"', 381, true);


--
-- Name: BUOI_HOC_MaBuoiHoc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."BUOI_HOC_MaBuoiHoc_seq"', 2438, true);


--
-- Name: DON_THU_MaDon_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DON_THU_MaDon_seq"', 883, true);


--
-- Name: DON_THU_PHAN_HOI_MaPhanHoi_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DON_THU_PHAN_HOI_MaPhanHoi_seq"', 266, true);


--
-- Name: GIANG_VIEN_MaGiangVien_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."GIANG_VIEN_MaGiangVien_seq"', 167, true);


--
-- Name: HOC_VIEN_LOP_HOC_MaHV_LH_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."HOC_VIEN_LOP_HOC_MaHV_LH_seq"', 749, true);


--
-- Name: HOC_VIEN_MaHocVien_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."HOC_VIEN_MaHocVien_seq"', 1410, true);


--
-- Name: KHOA_HOC_MaKhoaHoc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."KHOA_HOC_MaKhoaHoc_seq"', 64, true);


--
-- Name: LICHSU_KHOA_DIEM_MaLichSu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."LICHSU_KHOA_DIEM_MaLichSu_seq"', 46, true);


--
-- Name: LOP_HOC_MaLopHoc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."LOP_HOC_MaLopHoc_seq"', 194, true);


--
-- Name: NGUOI_DUNG_MaNguoiDung_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."NGUOI_DUNG_MaNguoiDung_seq"', 2313, true);


--
-- Name: PHONG_HOC_MaPhongHoc_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."PHONG_HOC_MaPhongHoc_seq"', 57, true);


--
-- Name: PHU_HUYNH_HOC_VIEN_MaPH_HV_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."PHU_HUYNH_HOC_VIEN_MaPH_HV_seq"', 180, true);


--
-- Name: TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."TIEN_TRINH_KHOA_HOC_MaTienTrinh_seq"', 5, true);


--
-- Name: YEU_CAU_DANG_KY_MaYeuCau_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."YEU_CAU_DANG_KY_MaYeuCau_seq"', 244, true);


--
-- Name: BANG_DIEM BANG_DIEM_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BANG_DIEM"
    ADD CONSTRAINT "BANG_DIEM_pkey" PRIMARY KEY ("MaBangDiem");


--
-- Name: BUOI_HOC BUOI_HOC_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BUOI_HOC"
    ADD CONSTRAINT "BUOI_HOC_pkey" PRIMARY KEY ("MaBuoiHoc");


--
-- Name: DON_THU_PHAN_HOI DON_THU_PHAN_HOI_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU_PHAN_HOI"
    ADD CONSTRAINT "DON_THU_PHAN_HOI_pkey" PRIMARY KEY ("MaPhanHoi");


--
-- Name: DON_THU DON_THU_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU"
    ADD CONSTRAINT "DON_THU_pkey" PRIMARY KEY ("MaDon");


--
-- Name: GIANG_VIEN GIANG_VIEN_MaNguoiDung_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GIANG_VIEN"
    ADD CONSTRAINT "GIANG_VIEN_MaNguoiDung_key" UNIQUE ("MaNguoiDung");


--
-- Name: GIANG_VIEN GIANG_VIEN_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GIANG_VIEN"
    ADD CONSTRAINT "GIANG_VIEN_pkey" PRIMARY KEY ("MaGiangVien");


--
-- Name: HOC_VIEN_LOP_HOC HOC_VIEN_LOP_HOC_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN_LOP_HOC"
    ADD CONSTRAINT "HOC_VIEN_LOP_HOC_pkey" PRIMARY KEY ("MaHV_LH");


--
-- Name: HOC_VIEN HOC_VIEN_MaNguoiDung_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN"
    ADD CONSTRAINT "HOC_VIEN_MaNguoiDung_key" UNIQUE ("MaNguoiDung");


--
-- Name: HOC_VIEN HOC_VIEN_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN"
    ADD CONSTRAINT "HOC_VIEN_pkey" PRIMARY KEY ("MaHocVien");


--
-- Name: KHOA_HOC KHOA_HOC_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."KHOA_HOC"
    ADD CONSTRAINT "KHOA_HOC_pkey" PRIMARY KEY ("MaKhoaHoc");


--
-- Name: LICHSU_KHOA_DIEM LICHSU_KHOA_DIEM_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LICHSU_KHOA_DIEM"
    ADD CONSTRAINT "LICHSU_KHOA_DIEM_pkey" PRIMARY KEY ("MaLichSu");


--
-- Name: LOP_HOC LOP_HOC_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LOP_HOC"
    ADD CONSTRAINT "LOP_HOC_pkey" PRIMARY KEY ("MaLopHoc");


--
-- Name: NGUOI_DUNG NGUOI_DUNG_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NGUOI_DUNG"
    ADD CONSTRAINT "NGUOI_DUNG_pkey" PRIMARY KEY ("MaNguoiDung");


--
-- Name: PHONG_HOC PHONG_HOC_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PHONG_HOC"
    ADD CONSTRAINT "PHONG_HOC_pkey" PRIMARY KEY ("MaPhongHoc");


--
-- Name: PHU_HUYNH_HOC_VIEN PHU_HUYNH_HOC_VIEN_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PHU_HUYNH_HOC_VIEN"
    ADD CONSTRAINT "PHU_HUYNH_HOC_VIEN_pkey" PRIMARY KEY ("MaPH_HV");


--
-- Name: TIEN_TRINH_KHOA_HOC TIEN_TRINH_KHOA_HOC_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIEN_TRINH_KHOA_HOC"
    ADD CONSTRAINT "TIEN_TRINH_KHOA_HOC_pkey" PRIMARY KEY ("MaTienTrinh");


--
-- Name: YEU_CAU_DANG_KY YEU_CAU_DANG_KY_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YEU_CAU_DANG_KY"
    ADD CONSTRAINT "YEU_CAU_DANG_KY_pkey" PRIMARY KEY ("MaYeuCau");


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: NGUOI_DUNG uq_nguoidung_email_vaitro; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."NGUOI_DUNG"
    ADD CONSTRAINT uq_nguoidung_email_vaitro UNIQUE ("Email", "VaiTro");


--
-- Name: ix_BANG_DIEM_MaBangDiem; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BANG_DIEM_MaBangDiem" ON public."BANG_DIEM" USING btree ("MaBangDiem");


--
-- Name: ix_BANG_DIEM_MaHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BANG_DIEM_MaHocVien" ON public."BANG_DIEM" USING btree ("MaHocVien");


--
-- Name: ix_BANG_DIEM_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BANG_DIEM_MaLopHoc" ON public."BANG_DIEM" USING btree ("MaLopHoc");


--
-- Name: ix_BUOI_HOC_MaBuoiHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BUOI_HOC_MaBuoiHoc" ON public."BUOI_HOC" USING btree ("MaBuoiHoc");


--
-- Name: ix_BUOI_HOC_MaGiangVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BUOI_HOC_MaGiangVien" ON public."BUOI_HOC" USING btree ("MaGiangVien");


--
-- Name: ix_BUOI_HOC_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BUOI_HOC_MaLopHoc" ON public."BUOI_HOC" USING btree ("MaLopHoc");


--
-- Name: ix_BUOI_HOC_MaPhongHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_BUOI_HOC_MaPhongHoc" ON public."BUOI_HOC" USING btree ("MaPhongHoc");


--
-- Name: ix_DON_THU_MaDon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_DON_THU_MaDon" ON public."DON_THU" USING btree ("MaDon");


--
-- Name: ix_DON_THU_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_DON_THU_MaLopHoc" ON public."DON_THU" USING btree ("MaLopHoc");


--
-- Name: ix_DON_THU_MaNguoiGui; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_DON_THU_MaNguoiGui" ON public."DON_THU" USING btree ("MaNguoiGui");


--
-- Name: ix_DON_THU_MaNguoiNhan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_DON_THU_MaNguoiNhan" ON public."DON_THU" USING btree ("MaNguoiNhan");


--
-- Name: ix_DON_THU_MaSoDon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_DON_THU_MaSoDon" ON public."DON_THU" USING btree ("MaSoDon");


--
-- Name: ix_DON_THU_PHAN_HOI_MaDon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_DON_THU_PHAN_HOI_MaDon" ON public."DON_THU_PHAN_HOI" USING btree ("MaDon");


--
-- Name: ix_DON_THU_PHAN_HOI_MaPhanHoi; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_DON_THU_PHAN_HOI_MaPhanHoi" ON public."DON_THU_PHAN_HOI" USING btree ("MaPhanHoi");


--
-- Name: ix_GIANG_VIEN_MaGiangVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_GIANG_VIEN_MaGiangVien" ON public."GIANG_VIEN" USING btree ("MaGiangVien");


--
-- Name: ix_GIANG_VIEN_MaSoGiangVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_GIANG_VIEN_MaSoGiangVien" ON public."GIANG_VIEN" USING btree ("MaSoGiangVien");


--
-- Name: ix_HOC_VIEN_LOP_HOC_MaHV_LH; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_HOC_VIEN_LOP_HOC_MaHV_LH" ON public."HOC_VIEN_LOP_HOC" USING btree ("MaHV_LH");


--
-- Name: ix_HOC_VIEN_LOP_HOC_MaHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_HOC_VIEN_LOP_HOC_MaHocVien" ON public."HOC_VIEN_LOP_HOC" USING btree ("MaHocVien");


--
-- Name: ix_HOC_VIEN_LOP_HOC_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_HOC_VIEN_LOP_HOC_MaLopHoc" ON public."HOC_VIEN_LOP_HOC" USING btree ("MaLopHoc");


--
-- Name: ix_HOC_VIEN_MaHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_HOC_VIEN_MaHocVien" ON public."HOC_VIEN" USING btree ("MaHocVien");


--
-- Name: ix_HOC_VIEN_MaSoHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_HOC_VIEN_MaSoHocVien" ON public."HOC_VIEN" USING btree ("MaSoHocVien");


--
-- Name: ix_KHOA_HOC_MaKhoaHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_KHOA_HOC_MaKhoaHoc" ON public."KHOA_HOC" USING btree ("MaKhoaHoc");


--
-- Name: ix_KHOA_HOC_MaSoKhoaHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_KHOA_HOC_MaSoKhoaHoc" ON public."KHOA_HOC" USING btree ("MaSoKhoaHoc");


--
-- Name: ix_LICHSU_KHOA_DIEM_MaLichSu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_LICHSU_KHOA_DIEM_MaLichSu" ON public."LICHSU_KHOA_DIEM" USING btree ("MaLichSu");


--
-- Name: ix_LICHSU_KHOA_DIEM_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_LICHSU_KHOA_DIEM_MaLopHoc" ON public."LICHSU_KHOA_DIEM" USING btree ("MaLopHoc");


--
-- Name: ix_LICHSU_KHOA_DIEM_MaNguoiThucHien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_LICHSU_KHOA_DIEM_MaNguoiThucHien" ON public."LICHSU_KHOA_DIEM" USING btree ("MaNguoiThucHien");


--
-- Name: ix_LOP_HOC_MaGiangVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_LOP_HOC_MaGiangVien" ON public."LOP_HOC" USING btree ("MaGiangVien");


--
-- Name: ix_LOP_HOC_MaKhoaHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_LOP_HOC_MaKhoaHoc" ON public."LOP_HOC" USING btree ("MaKhoaHoc");


--
-- Name: ix_LOP_HOC_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_LOP_HOC_MaLopHoc" ON public."LOP_HOC" USING btree ("MaLopHoc");


--
-- Name: ix_LOP_HOC_MaSoLop; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_LOP_HOC_MaSoLop" ON public."LOP_HOC" USING btree ("MaSoLop");


--
-- Name: ix_NGUOI_DUNG_Email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_NGUOI_DUNG_Email" ON public."NGUOI_DUNG" USING btree ("Email");


--
-- Name: ix_NGUOI_DUNG_MaNguoiDung; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_NGUOI_DUNG_MaNguoiDung" ON public."NGUOI_DUNG" USING btree ("MaNguoiDung");


--
-- Name: ix_NGUOI_DUNG_TenDangNhap; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_NGUOI_DUNG_TenDangNhap" ON public."NGUOI_DUNG" USING btree ("TenDangNhap");


--
-- Name: ix_PHONG_HOC_MaPhongHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_PHONG_HOC_MaPhongHoc" ON public."PHONG_HOC" USING btree ("MaPhongHoc");


--
-- Name: ix_PHONG_HOC_MaSoPhong; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ix_PHONG_HOC_MaSoPhong" ON public."PHONG_HOC" USING btree ("MaSoPhong");


--
-- Name: ix_PHU_HUYNH_HOC_VIEN_MaHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_PHU_HUYNH_HOC_VIEN_MaHocVien" ON public."PHU_HUYNH_HOC_VIEN" USING btree ("MaHocVien");


--
-- Name: ix_PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH" ON public."PHU_HUYNH_HOC_VIEN" USING btree ("MaNguoiDung_PH");


--
-- Name: ix_PHU_HUYNH_HOC_VIEN_MaPH_HV; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_PHU_HUYNH_HOC_VIEN_MaPH_HV" ON public."PHU_HUYNH_HOC_VIEN" USING btree ("MaPH_HV");


--
-- Name: ix_TIEN_TRINH_KHOA_HOC_MaHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_TIEN_TRINH_KHOA_HOC_MaHocVien" ON public."TIEN_TRINH_KHOA_HOC" USING btree ("MaHocVien");


--
-- Name: ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai" ON public."TIEN_TRINH_KHOA_HOC" USING btree ("MaKhoaHocHienTai");


--
-- Name: ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo" ON public."TIEN_TRINH_KHOA_HOC" USING btree ("MaKhoaHocTiepTheo");


--
-- Name: ix_TIEN_TRINH_KHOA_HOC_MaTienTrinh; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_TIEN_TRINH_KHOA_HOC_MaTienTrinh" ON public."TIEN_TRINH_KHOA_HOC" USING btree ("MaTienTrinh");


--
-- Name: ix_YEU_CAU_DANG_KY_MaHocVien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_YEU_CAU_DANG_KY_MaHocVien" ON public."YEU_CAU_DANG_KY" USING btree ("MaHocVien");


--
-- Name: ix_YEU_CAU_DANG_KY_MaLopHoc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_YEU_CAU_DANG_KY_MaLopHoc" ON public."YEU_CAU_DANG_KY" USING btree ("MaLopHoc");


--
-- Name: ix_YEU_CAU_DANG_KY_MaYeuCau; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_YEU_CAU_DANG_KY_MaYeuCau" ON public."YEU_CAU_DANG_KY" USING btree ("MaYeuCau");


--
-- Name: BANG_DIEM BANG_DIEM_MaHocVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BANG_DIEM"
    ADD CONSTRAINT "BANG_DIEM_MaHocVien_fkey" FOREIGN KEY ("MaHocVien") REFERENCES public."HOC_VIEN"("MaHocVien");


--
-- Name: BANG_DIEM BANG_DIEM_MaLopHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BANG_DIEM"
    ADD CONSTRAINT "BANG_DIEM_MaLopHoc_fkey" FOREIGN KEY ("MaLopHoc") REFERENCES public."LOP_HOC"("MaLopHoc");


--
-- Name: BUOI_HOC BUOI_HOC_MaGiangVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BUOI_HOC"
    ADD CONSTRAINT "BUOI_HOC_MaGiangVien_fkey" FOREIGN KEY ("MaGiangVien") REFERENCES public."GIANG_VIEN"("MaGiangVien");


--
-- Name: BUOI_HOC BUOI_HOC_MaLopHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BUOI_HOC"
    ADD CONSTRAINT "BUOI_HOC_MaLopHoc_fkey" FOREIGN KEY ("MaLopHoc") REFERENCES public."LOP_HOC"("MaLopHoc");


--
-- Name: BUOI_HOC BUOI_HOC_MaPhongHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BUOI_HOC"
    ADD CONSTRAINT "BUOI_HOC_MaPhongHoc_fkey" FOREIGN KEY ("MaPhongHoc") REFERENCES public."PHONG_HOC"("MaPhongHoc");


--
-- Name: DON_THU DON_THU_MaLopHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU"
    ADD CONSTRAINT "DON_THU_MaLopHoc_fkey" FOREIGN KEY ("MaLopHoc") REFERENCES public."LOP_HOC"("MaLopHoc");


--
-- Name: DON_THU DON_THU_MaNguoiGui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU"
    ADD CONSTRAINT "DON_THU_MaNguoiGui_fkey" FOREIGN KEY ("MaNguoiGui") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: DON_THU DON_THU_MaNguoiNhan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU"
    ADD CONSTRAINT "DON_THU_MaNguoiNhan_fkey" FOREIGN KEY ("MaNguoiNhan") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: DON_THU_PHAN_HOI DON_THU_PHAN_HOI_MaDon_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU_PHAN_HOI"
    ADD CONSTRAINT "DON_THU_PHAN_HOI_MaDon_fkey" FOREIGN KEY ("MaDon") REFERENCES public."DON_THU"("MaDon");


--
-- Name: DON_THU_PHAN_HOI DON_THU_PHAN_HOI_MaNguoiGui_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DON_THU_PHAN_HOI"
    ADD CONSTRAINT "DON_THU_PHAN_HOI_MaNguoiGui_fkey" FOREIGN KEY ("MaNguoiGui") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: GIANG_VIEN GIANG_VIEN_MaNguoiDung_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GIANG_VIEN"
    ADD CONSTRAINT "GIANG_VIEN_MaNguoiDung_fkey" FOREIGN KEY ("MaNguoiDung") REFERENCES public."NGUOI_DUNG"("MaNguoiDung") ON DELETE CASCADE;


--
-- Name: HOC_VIEN_LOP_HOC HOC_VIEN_LOP_HOC_MaHocVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN_LOP_HOC"
    ADD CONSTRAINT "HOC_VIEN_LOP_HOC_MaHocVien_fkey" FOREIGN KEY ("MaHocVien") REFERENCES public."HOC_VIEN"("MaHocVien");


--
-- Name: HOC_VIEN_LOP_HOC HOC_VIEN_LOP_HOC_MaLopHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN_LOP_HOC"
    ADD CONSTRAINT "HOC_VIEN_LOP_HOC_MaLopHoc_fkey" FOREIGN KEY ("MaLopHoc") REFERENCES public."LOP_HOC"("MaLopHoc");


--
-- Name: HOC_VIEN HOC_VIEN_MaNguoiDung_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HOC_VIEN"
    ADD CONSTRAINT "HOC_VIEN_MaNguoiDung_fkey" FOREIGN KEY ("MaNguoiDung") REFERENCES public."NGUOI_DUNG"("MaNguoiDung") ON DELETE CASCADE;


--
-- Name: LICHSU_KHOA_DIEM LICHSU_KHOA_DIEM_MaLopHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LICHSU_KHOA_DIEM"
    ADD CONSTRAINT "LICHSU_KHOA_DIEM_MaLopHoc_fkey" FOREIGN KEY ("MaLopHoc") REFERENCES public."LOP_HOC"("MaLopHoc");


--
-- Name: LICHSU_KHOA_DIEM LICHSU_KHOA_DIEM_MaNguoiThucHien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LICHSU_KHOA_DIEM"
    ADD CONSTRAINT "LICHSU_KHOA_DIEM_MaNguoiThucHien_fkey" FOREIGN KEY ("MaNguoiThucHien") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: LOP_HOC LOP_HOC_MaGiangVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LOP_HOC"
    ADD CONSTRAINT "LOP_HOC_MaGiangVien_fkey" FOREIGN KEY ("MaGiangVien") REFERENCES public."GIANG_VIEN"("MaGiangVien");


--
-- Name: LOP_HOC LOP_HOC_MaKhoaHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LOP_HOC"
    ADD CONSTRAINT "LOP_HOC_MaKhoaHoc_fkey" FOREIGN KEY ("MaKhoaHoc") REFERENCES public."KHOA_HOC"("MaKhoaHoc");


--
-- Name: PHU_HUYNH_HOC_VIEN PHU_HUYNH_HOC_VIEN_MaHocVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PHU_HUYNH_HOC_VIEN"
    ADD CONSTRAINT "PHU_HUYNH_HOC_VIEN_MaHocVien_fkey" FOREIGN KEY ("MaHocVien") REFERENCES public."HOC_VIEN"("MaHocVien");


--
-- Name: PHU_HUYNH_HOC_VIEN PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PHU_HUYNH_HOC_VIEN"
    ADD CONSTRAINT "PHU_HUYNH_HOC_VIEN_MaNguoiDung_PH_fkey" FOREIGN KEY ("MaNguoiDung_PH") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: TIEN_TRINH_KHOA_HOC TIEN_TRINH_KHOA_HOC_MaHocVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIEN_TRINH_KHOA_HOC"
    ADD CONSTRAINT "TIEN_TRINH_KHOA_HOC_MaHocVien_fkey" FOREIGN KEY ("MaHocVien") REFERENCES public."HOC_VIEN"("MaHocVien");


--
-- Name: TIEN_TRINH_KHOA_HOC TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIEN_TRINH_KHOA_HOC"
    ADD CONSTRAINT "TIEN_TRINH_KHOA_HOC_MaKhoaHocHienTai_fkey" FOREIGN KEY ("MaKhoaHocHienTai") REFERENCES public."KHOA_HOC"("MaKhoaHoc");


--
-- Name: TIEN_TRINH_KHOA_HOC TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIEN_TRINH_KHOA_HOC"
    ADD CONSTRAINT "TIEN_TRINH_KHOA_HOC_MaKhoaHocTiepTheo_fkey" FOREIGN KEY ("MaKhoaHocTiepTheo") REFERENCES public."KHOA_HOC"("MaKhoaHoc");


--
-- Name: TIEN_TRINH_KHOA_HOC TIEN_TRINH_KHOA_HOC_MaNguoiXacNhan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TIEN_TRINH_KHOA_HOC"
    ADD CONSTRAINT "TIEN_TRINH_KHOA_HOC_MaNguoiXacNhan_fkey" FOREIGN KEY ("MaNguoiXacNhan") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: YEU_CAU_DANG_KY YEU_CAU_DANG_KY_MaHocVien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YEU_CAU_DANG_KY"
    ADD CONSTRAINT "YEU_CAU_DANG_KY_MaHocVien_fkey" FOREIGN KEY ("MaHocVien") REFERENCES public."HOC_VIEN"("MaHocVien");


--
-- Name: YEU_CAU_DANG_KY YEU_CAU_DANG_KY_MaLopHoc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YEU_CAU_DANG_KY"
    ADD CONSTRAINT "YEU_CAU_DANG_KY_MaLopHoc_fkey" FOREIGN KEY ("MaLopHoc") REFERENCES public."LOP_HOC"("MaLopHoc");


--
-- Name: YEU_CAU_DANG_KY YEU_CAU_DANG_KY_MaNguoiDuyet_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."YEU_CAU_DANG_KY"
    ADD CONSTRAINT "YEU_CAU_DANG_KY_MaNguoiDuyet_fkey" FOREIGN KEY ("MaNguoiDuyet") REFERENCES public."NGUOI_DUNG"("MaNguoiDung");


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict 6JoyCw8Bp52fPaJRZDch5oAjxe4lhnMeVao9UOzOl9qoMQfZjpTKzwMD06kmY46

