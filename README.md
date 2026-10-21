# HỆ THỐNG QUẢN LÝ TRUNG TÂM NGOẠI NGỮ (SMART-EDU LMS)

Hệ thống Web Quản lý Trung tâm Ngoại ngữ được thiết kế và xây dựng theo chuẩn công nghiệp **Modular Monolith & DDD-Lite** (FastAPI) kết hợp kiến trúc **Feature-Driven Frontend** (React 19 + JavaScript JSX + Vite + Tailwind CSS), hiện thực hóa đầy đủ **82 chức năng nghiệp vụ (FR-01 đến FR-82)** thuộc 11 phân hệ và hỗ trợ 5 nhóm đối tượng (Admin, Nhân viên học vụ, Giáo viên, Học viên, Phụ huynh).

---

## 1. THÔNG TIN TECH STACK
- **Backend:** Python 3.14+, FastAPI 0.143+, SQLAlchemy 2.0+, Pydantic v2, PyJWT, Passlib/Bcrypt, SQLite (zero-config, sẵn sàng chạy ngay).
- **Frontend:** React 19, JavaScript (JSX), Vite 8, Tailwind CSS v4, Lucide React, Axios.
- **Tài liệu API Swagger tự động:** `http://localhost:8000/docs`

---

## 2. TÀI KHOẢN MẪU KHỞI TẠO (5 ROLES SẴN CÓ)

Hệ thống đã được nạp dữ liệu mẫu ban đầu qua script `backend/seed.py`:

| Vai trò (Role) | Username | Password | Quyền hạn chính |
|---|---|---|---|
| **Quản trị viên (Admin)** | `admin` | `admin123` | Toàn quyền cấu hình khóa học, phòng học, lớp học, tài khoản (FR-01 -> FR-17, FR-42 -> FR-49). |
| **Nhân viên học vụ (Staff)** | `staff` | `staff123` | Duyệt đăng ký, xếp lịch học & phòng, giải quyết xung đột, xác nhận điểm, xét chuyển khóa (FR-55 -> FR-60, FR-61 -> FR-67, FR-76, FR-78, FR-79). |
| **Giáo viên (Teacher)** | `teacher` | `teacher123` | Xem lịch giảng dạy cá nhân, danh sách lớp, nhập & cập nhật bảng điểm học viên (FR-27 -> FR-29, FR-68 -> FR-71). |
| **Học viên (Student)** | `student` | `student123` | Xem khóa học mở, nộp đơn đăng ký lớp, xem lịch học cá nhân, tra cứu điểm & kết quả, đăng ký lên khóa (FR-50 -> FR-54, FR-68, FR-72, FR-80). |
| **Phụ huynh (Parent)** | `parent` | `parent123` | Xem thông tin học viên được giám hộ, theo dõi tiến độ & điểm số, tra cứu tình trạng đăng ký của con (FR-81, FR-82). |

*(Lưu ý: Mọi tài khoản kể cả Admin đều bắt buộc phải nhập đúng Tên đăng nhập và Mật khẩu. Màn hình đăng nhập có cung cấp danh sách thông tin tài khoản mẫu để bạn bấm vào là tự động điền thông tin vào form, sau đó bấm "Đăng nhập vào hệ thống" để xác thực).*

---

## 3. HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### Bước 1: Khởi động Backend (FastAPI)
Mở cửa sổ Terminal (PowerShell hoặc CMD):
```bash
cd d:\OOAD\backend

# Khởi tạo database & nạp dữ liệu mẫu (đã được chạy sẵn, có thể chạy lại bất kỳ lúc nào nếu muốn reset)
python seed.py

# Chạy backend server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- Server API Backend chạy tại: `http://localhost:8000`
- Swagger UI / OpenAPI Specs: `http://localhost:8000/docs`

### Bước 2: Khởi động Frontend (React Vite)
Mở một cửa sổ Terminal khác:
```bash
cd d:\OOAD\frontend

# Chạy máy chủ phát triển
npm run dev
```
- Giao diện Web chạy tại: `http://localhost:5173`

---

## 4. MA TRẬN 11 PHÂN HỆ NGHIỆP VỤ (82 CHỨC NĂNG)

| Phân hệ | Mã FR | Mô tả & Chức năng nổi bật |
|:---|:---:|:---|
| **01. Đăng nhập & Phân quyền** | FR-01 $\rightarrow$ FR-04 | Đăng nhập JWT, đăng xuất, phân quyền theo 5 vai trò RBAC, bảo vệ endpoint bằng Dependency Injection. |
| **02. Quản lý Tài khoản** | FR-05 $\rightarrow$ FR-10 | Thêm tài khoản người dùng, đổi mật khẩu cá nhân, tìm kiếm, cập nhật và xóa an toàn (Soft delete). |
| **03. Quản lý Khóa học** | FR-11 $\rightarrow$ FR-17 | CRUD khóa học, gán cấp độ mục tiêu đầu ra (IELTS 6.5, TOEIC 750), kích hoạt / ngừng sử dụng khóa học. |
| **04. Quản lý Học viên** | FR-18 $\rightarrow$ FR-24 | Hồ sơ học viên, xem toàn bộ lịch sử học tập & các lớp đã/đang tham gia, liên kết điểm số chi tiết. |
| **05. Quản lý Giáo viên** | FR-25 $\rightarrow$ FR-31 | Quản lý giảng viên, trình độ, bằng cấp, chuyên môn và tra cứu lịch giảng dạy. |
| **06. Quản lý Lớp học & Sĩ số** | FR-32 $\rightarrow$ FR-41 | Tạo lớp, quản lý sức chứa tối đa & sĩ số hiện tại (cảnh báo đủ chỗ), phân công giáo viên, danh sách học viên trong lớp, kết thúc lớp chuyển sang `COMPLETED`. |
| **07. Quản lý Phòng học** | FR-42 $\rightarrow$ FR-49 | Quản lý phòng học, sức chứa từng phòng, chuyển đổi trạng thái đang sử dụng hoặc bảo trì. |
| **08. Đăng ký & Xét duyệt lớp** | FR-50 $\rightarrow$ FR-60 | Học viên xem các lớp đang mở & đăng ký; Học vụ xét duyệt hoặc từ chối (bắt buộc nhập lý do); Tự động thêm học viên vào lớp sau khi duyệt. |
| **09. Thời khóa biểu & Xung đột** | FR-61 $\rightarrow$ FR-68 | Lập lịch theo từng buổi (chọn phòng và giảng viên riêng); **Thuật toán tự động phát hiện xung đột phòng học hoặc giảng viên trùng giờ**; Xác nhận lịch áp dụng chính thức; Xem lịch cá nhân theo vai trò. |
| **10. Điểm số & Kết quả** | FR-69 $\rightarrow$ FR-77 | Bảng nhập điểm lớp học; kiểm tra thang điểm hợp lệ 0-10; tự động tính tổng kết theo trọng số (20% CC, 30% GK, 50% CK) & xếp loại Đạt/Chưa đạt; Học vụ xác nhận khóa điểm chính thức. |
| **11. Chuyển khóa & Phụ huynh** | FR-78 $\rightarrow$ FR-82 | Kiểm tra điều kiện tiên quyết (bắt buộc hoàn thành và Đạt khóa trước mới được học khóa cao hơn); Học vụ xác nhận đủ điều kiện; Học viên đăng ký khóa tiếp theo; Cổng phụ huynh theo dõi tiến độ, điểm số và trạng thái đăng ký của con. |

