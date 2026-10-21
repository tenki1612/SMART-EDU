---
name: fullstack-lms-workflow
description: Quy trình chuẩn xây dựng hệ thống quản lý đào tạo / trung tâm ngoại ngữ (LMS/CRM) full-stack với FastAPI, SQLAlchemy, Pydantic v2, React 19, TypeScript, Vite và Tailwind CSS theo mô hình Modular Monolith DDD-Lite.
---

# Fullstack Educational LMS Development Workflow

Quy trình chuẩn hóa để thiết kế, triển khai và kiểm thử các hệ thống Quản lý Đào tạo / Trung tâm Giáo dục (LMS/CRM) quy mô lớn (từ 50 đến 100+ chức năng nghiệp vụ) với kiến trúc bền vững, dễ mở rộng và giao diện người dùng đạt chuẩn Operate Mode cao cấp.

---

## 1. NGUYÊN TẮC THIẾT KẾ CỐT LÕI (ARCHITECTURE PRINCIPLES)

1. **Modular Monolith (DDD-Lite):**
   - Đóng gói theo nghiệp vụ (Feature-first / Bounded Context), không chia phẳng (Flat Layered).
   - Mỗi module nghiệp vụ sở hữu đầy đủ 4 tầng riêng biệt:
     $$\text{Router (HTTP)} \longrightarrow \text{Schema (DTO)} \longrightarrow \text{Service (Logic)} \longrightarrow \text{Repository/Model (DB)}$$
2. **Zero-Config Database Defaults:**
   - Cấu hình mặc định sử dụng SQLite cục bộ để nhà phát triển có thể clone về và chạy ngay mà không cần cài đặt database server.
   - Hỗ trợ chuyển đổi sang PostgreSQL thông qua biến môi trường `DATABASE_URL` trong file `.env`.
3. **End-to-End Type Safety:**
   - Định nghĩa Schema Pydantic v2 ở Backend làm nguồn chân lý duy nhất (Single Source of Truth).
   - Ánh xạ tương ứng 1-1 sang TypeScript Interfaces ở Frontend, triệt tiêu lỗi sai lệch kiểu dữ liệu hoặc đổi tên trường.
4. **Phân quyền vai trò (RBAC) chặt chẽ:**
   - 5 vai trò phân lập: `ADMIN`, `ACADEMIC_STAFF`, `TEACHER`, `STUDENT`, `PARENT`.
   - Bảo vệ an toàn từng endpoint bằng cơ chế FastAPI Dependency Injection (`require_roles([...])`).

---

## 2. QUY TRÌNH TRIỂN KHAI 8 BƯỚC CHUẨN HÓA

### Bước 1: Phân rã Nghiệp vụ thành các Bounded Contexts
Nhóm toàn bộ các yêu cầu chức năng (FRs) vào các phân hệ nghiệp vụ độc lập:
1. `auth`: Xác thực JWT, đăng nhập, đăng xuất, kiểm tra phiên.
2. `accounts`: Quản lý tài khoản người dùng, đổi mật khẩu cá nhân, tìm kiếm.
3. `courses`: Quản lý chương trình đào tạo, chuẩn đầu ra mục tiêu (IELTS, TOEIC), trạng thái mở/ngừng.
4. `students`: Hồ sơ học viên, lịch sử học tập và kết quả các lớp đã/đang học.
5. `teachers`: Hồ sơ giảng viên, bằng cấp, chuyên môn, lịch giảng dạy.
6. `classes`: Lớp học, sức chứa tối đa (`max_capacity`), theo dõi sĩ số thực tế (`current_enrolled`), gán giáo viên, cập nhật trạng thái lớp (`COMPLETED`).
7. `classrooms`: Phòng học, sức chứa, chuyển đổi trạng thái bảo trì (`AVAILABLE`, `MAINTENANCE`).
8. `enrollments`: Luồng nộp đơn đăng ký lớp mở, học vụ xét duyệt hoặc từ chối (bắt buộc nhập lý do), tự động cập nhật sĩ số lớp.
9. `schedules`: Lập lịch học từng buổi, thuật toán kiểm tra xung đột phòng/giáo viên, xác nhận lịch chính thức, xem lịch cá nhân.
10. `grades`: Bảng nhập điểm, kiểm tra thang điểm hợp lệ 0-10, công thức tính tổng kết theo trọng số, tự động xếp loại Đạt/Chưa đạt, khóa điểm chính thức.
11. `progression_parent`: Ràng buộc điều kiện tiên quyết nâng khóa, xét duyệt lên cấp độ, cổng phụ huynh theo dõi tiến độ và điểm số của con.

---

### Bước 2: Thiết lập Tầng Core & Common Backend
Tạo bộ khung bất biến:
- `app/core/config.py`: `pydantic-settings` với `DATABASE_URL = "sqlite:///./language_center.db"`.
- `app/core/security.py`: `bcrypt` băm mật khẩu, `PyJWT` mã hóa token.
- `app/core/permissions.py`: Khởi tạo `RoleEnum` và dependency `require_roles(allowed_roles: List[RoleEnum])`.
- `app/common/base_model.py`: `TimestampMixin` (`id`, `created_at`, `updated_at`, `is_deleted`).
- `app/common/response.py`: `ApiResponse[T]` (success, code, message, data).

---

### Bước 3: Thiết kế Database Models & Quan hệ Thực thể
- Mọi quan hệ giữa bảng lớp học (`Class`) và học viên (`Student`) phải thông qua bảng liên kết (`ClassStudent`) để lưu trữ lịch sử tham gia và trạng thái (`ENROLLED`, `DROPPED`, `COMPLETED`).
- Bảng lịch học (`ScheduleSession`) phải liên kết với `Class`, `Classroom`, `Teacher` theo từng buổi riêng lẻ (không gán phòng cố định cứng cho cả khóa).

---

### Bước 4: Triển khai Thuật toán Nghiệp vụ Cốt lõi

#### 4.1. Thuật toán Kiểm tra Xung đột Thời khóa biểu (`conflict_checker.py`):
```python
def check_conflicts(db, classroom_id, teacher_id, session_date, start_time, end_time, exclude_session_id=None):
    # Kiểm tra giao khoảng: start1 < end2 AND end1 > start2
    # 1. Quét theo classroom_id trong cùng session_date
    # 2. Quét theo teacher_id trong cùng session_date
    # Trả về (has_conflict, conflict_type, message)
```

#### 4.2. Công thức Điểm số & Xếp loại (`calculator.py`):
```python
def calculate_total_and_status(attendance, midterm, final):
    total = round(attendance * 0.2 + midterm * 0.3 + final * 0.5, 2)
    status = "PASSED" if (total >= 5.0 and final >= 4.0) else "FAILED"
    return total, status
```

#### 4.3. Ràng buộc Chuyển khóa học (Prerequisite):
- Kiểm tra học viên có bản ghi điểm `PASSED` và `is_confirmed == True` ở khóa trước mới cho phép học vụ xác nhận đủ điều kiện nâng khóa.

---

### Bước 5: Viết Kịch bản Seed Data Ban đầu (`seed.py`)
Luôn tạo sẵn dữ liệu mẫu phục vụ kiểm thử ngay sau khi khởi tạo DB:
- 5 tài khoản mẫu cho 5 vai trò (`admin/admin123`, `staff/staff123`, `teacher/teacher123`, `student/student123`, `parent/parent123`).
- Dữ liệu mẫu cho Khóa học, Phòng học, Lớp học, Lịch học, Điểm số và Quan hệ Phụ huynh - Học viên.

---

### Bước 6: Khởi tạo Frontend & Quản lý Type
- Khởi tạo React + Vite + TypeScript.
- Cấu hình file `src/types/index.ts` chứa đầy đủ interface của các đối tượng trong hệ thống.
- Cấu hình `apiClient` (Axios) tự động đính kèm `Authorization: Bearer <token>` và bắt lỗi 401.
- Xây dựng `AuthContext` tích hợp tính năng **"Đăng nhập nhanh 1-Click"** cho cả 5 vai trò, giúp việc kiểm thử đa vai trò diễn ra ngay lập tức mà không cần gõ mật khẩu.

---

### Bước 7: Tiêu chuẩn Thiết kế UX/UI (Operate Mode)
- **Typography:** Sử dụng Google Font `Plus Jakarta Sans` kết hợp `JetBrains Mono` và class `tabular-nums` cho toàn bộ số liệu và mã định danh.
- **Phản hồi không chặn (Non-blocking Feedback):** Tuyệt đối không dùng `alert()` trình duyệt. Sử dụng `ToastContext` nổi nhẹ nhàng ở góc màn hình.
- **Thẻ trạng thái (Status Badges):** Sử dụng chấm màu (`dot indicator`) kết hợp nền nhạt và viền mỏng (`bg-emerald-50 text-emerald-700 border-emerald-200`).
- **Responsive Drawer:** Tích hợp menu trượt mượt mà trên Mobile/Tablet.
- **Phân nhóm Sidebar:** Nhóm theo 5 danh mục nghiệp vụ tự nhiên, bỏ tiền tố số vụng về (`01.`, `03.`).

---

### Bước 8: Kiểm thử Tự động & Verification
1. **Viết test suite kiểm thử tích hợp Backend (`test_api.py`):**
   - Kiểm tra Endpoint Health check.
   - Kiểm tra Đăng nhập JWT & cấp quyền.
   - Kiểm tra Thuật toán phát hiện xung đột lịch.
   - Kiểm tra Lịch sử học viên & Cổng phụ huynh.
2. **Kiểm tra Frontend Build:**
   - Chạy `npm run build` để xác thực trình biên dịch TypeScript không phát sinh bất kỳ lỗi cú pháp hoặc unescaped JSX nào.

