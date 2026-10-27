---
name: fullstack-lms-workflow
description: Quy trình chuẩn xây dựng hệ thống quản lý đào tạo / trung tâm ngoại ngữ (LMS/CRM) full-stack với FastAPI, SQLAlchemy, Pydantic v2, React 19, JavaScript (JSX), Vite và Tailwind CSS theo mô hình Modular Monolith DDD-Lite.
---

# Fullstack Educational LMS Development Workflow

Quy trình chuẩn hóa để thiết kế, triển khai, kiểm thử và tối ưu hóa các hệ thống Quản lý Đào tạo / Trung tâm Giáo dục (LMS/CRM) quy mô lớn (từ 50 đến 100+ chức năng nghiệp vụ) với kiến trúc bền vững, dễ mở rộng, bảo mật cao và giao diện người dùng đạt chuẩn Operate Mode & SaaS Craft cao cấp.

---

## 1. NGUYÊN TẮC THIẾT KẾ CỐT LÕI (ARCHITECTURE PRINCIPLES)

1. **Modular Monolith (DDD-Lite):**
   - Đóng gói theo nghiệp vụ (Feature-first / Bounded Context), không chia phẳng (Flat Layered).
   - Mỗi module nghiệp vụ sở hữu đầy đủ 4 tầng riêng biệt:
     $$\text{Router (HTTP)} \longrightarrow \text{Schema (DTO)} \longrightarrow \text{Service (Logic)} \longrightarrow \text{Repository/Model (DB)}$$
2. **Zero-Config Database Defaults:**
   - Cấu hình mặc định sử dụng SQLite cục bộ (`sqlite:///./language_center.db`) để nhà phát triển có thể clone về và chạy ngay mà không cần cài đặt database server.
   - Hỗ trợ chuyển đổi sang PostgreSQL thông qua biến môi trường `DATABASE_URL` trong file `.env`.
3. **Ponytail JavaScript JSX & Clean Architecture:**
   - Sử dụng React 19 với JavaScript (JSX) thuần túy tinh gọn (Ponytail Mode), loại bỏ rào cản phức tạp về compiler TypeScript, tối ưu tốc độ build Vite (< 1.5s).
   - Tổ chức mã nguồn sáng sủa, tường minh, có fallback an toàn cho runtime.
4. **Phân Quyền Vai Trò (RBAC) 5 Cấp & Phân Quyền Kép:**
   - 5 vai trò phân lập: `ADMIN`, `ACADEMIC_STAFF`, `TEACHER`, `STUDENT`, `PARENT`.
   - Bảo vệ an toàn từng endpoint bằng FastAPI Dependency Injection (`require_roles([...])`).
   - Chuẩn hóa phân quyền kép (Dual RBAC) cho `ADMIN` và `ACADEMIC_STAFF` trong các tác vụ điều phối học vụ (Khóa học, Lớp học, Phòng học, Lịch học, Tài khoản).
   - Phân quyền sổ điểm nghiêm ngặt: Chỉ Giảng viên phụ trách mới có quyền sửa điểm; Quản trị viên và Học vụ chỉ có quyền xác nhận khóa điểm chính thức hoặc gỡ học viên.
5. **Bảo Mật Nghiêm Ngặt & Phòng Vệ Đa Tầng:**
   - Tuyệt đối không để lại cơ chế bypass xác thực hay nút đăng nhập nhanh trên môi trường Production.
   - Mã hóa mật khẩu 1 chiều bằng thuật toán `bcrypt`.
   - Phòng chống brute-force: Cảnh báo số lần thử còn lại; tự động khóa tài khoản tạm thời 15 phút sau 5 lần nhập sai liên tiếp.
   - Khôi phục mật khẩu an toàn 2 bước bằng mã OTP 6 chữ số ngẫu nhiên thời hạn 15 phút.
   - Phân loại 5 tầng phản hồi lỗi xác thực (Tài khoản không tồn tại, Đã bị xóa, Bị khóa bởi Admin, Bị tạm khóa 15p, Sai mật khẩu).
6. **Kiến Trúc Cuộn Độc Lập (Dual-Scroll Shell) & React Portal:**
   - Khóa chiều cao viewport ứng dụng `h-screen w-screen overflow-hidden flex flex-col`.
   - Navbar cố định trên cùng (`shrink-0 z-30`); Sidebar cuộn riêng biệt; Vùng nội dung chính cuộn độc lập (`overflow-y-auto min-h-0`).
   - Sử dụng React Portal (`createPortal(modalJSX, document.body)`) cho tất cả các Modal để thoát khỏi bẫy CSS `backdrop-filter` Containing Block, đảm bảo modal luôn hiển thị toàn màn hình và căn giữa chuẩn xác.
7. **SaaS-Grade 4-Pillar Ledger UI Pattern:**
   - Hàng 4 thẻ KPI Metrics đỉnh trang với con số `tabular-nums`.
   - Dãy chip lọc nhanh (Quick Filter Chips) kèm badge đếm số lượng thời gian thực.
   - Trừu tượng hóa hoàn toàn các mã kỹ thuật nội bộ (`FR-xx`) thành ngôn ngữ nghiệp vụ trực quan.
   - Đồng bộ component `UserAvatar` với fallback chữ cái đầu tiên và gradient đặc trưng theo vai trò.
8. **Trải Nghiệm Phi Chặn (Zero Native Alerts/Confirms):**
   - Tuyệt đối không sử dụng `alert()`, `confirm()`, `prompt()` của trình duyệt.
   - Thay thế 100% bằng hệ thống thông báo Toast nổi nhẹ nhàng (`useToast()`) và Modal xác nhận hành động chuyên dụng (`useConfirm()`).

---

## 2. QUY TRÌNH TRIỂN KHAI 8 BƯỚC CHUẨN HÓA

### Bước 1: Phân rã Nghiệp vụ thành 11 Bounded Contexts
Nhóm toàn bộ các yêu cầu chức năng (FRs) vào các phân hệ nghiệp vụ độc lập:
1. `auth`: Xác thực JWT, đăng nhập nghiêm ngặt, tự đăng ký (Học viên/Phụ huynh), quên mật khẩu OTP, kiểm tra phiên.
2. `accounts`: Quản lý tài khoản, nâng quyền vai trò (Role Elevation), khóa/mở khóa tức thì, cấp lại mật khẩu Admin, cập nhật hồ sơ & ảnh đại diện (`avatar_url`).
3. `courses`: Quản lý chương trình đào tạo, chuẩn đầu ra mục tiêu (IELTS, TOEIC), thời lượng, học phí, trạng thái mở/ngừng.
4. `students`: Hồ sơ học viên, mã định danh (`HV...`), lịch sử học tập và kết quả các lớp đã/đang học.
5. `teachers`: Hồ sơ giảng viên, mã định danh (`GV...`), bằng cấp, chuyên môn, lịch giảng dạy.
6. `classes`: Lớp học, sức chứa tối đa (`max_capacity`), theo dõi sĩ số thực tế (`current_enrolled`), gán giáo viên, cập nhật trạng thái lớp (`COMPLETED`).
7. `classrooms`: Phòng học, sức chứa, chuyển đổi trạng thái bảo trì (`AVAILABLE`, `MAINTENANCE`).
8. `enrollments`: Luồng nộp đơn đăng ký lớp mở, học sinh chủ động hủy đơn khi `PENDING` (cấm hủy khi `APPROVED`), học vụ xét duyệt hoặc từ chối (bắt buộc nhập lý do), tự động cập nhật sĩ số lớp.
9. `schedules`: Lập lịch học từng buổi, thuật toán kiểm tra xung đột phòng/giáo viên thời gian thực, ma trận thời khóa biểu tuần 7 ngày $\times$ 4 ca học, lọc lịch sắp tới vs lịch sử đã qua.
10. `grades`: Sổ điểm lớp học, kiểm tra thang điểm hợp lệ 0-10, công thức tính tổng kết theo trọng số (20% CC + 30% GK + 50% CK), tự động xếp loại Đạt/Chưa đạt, khóa điểm chính thức (Admin/Staff), thêm/xóa học viên khỏi sổ điểm.
11. `progression_parent`: Ràng buộc điều kiện tiên quyết nâng khóa (Prerequisite), xét duyệt lên cấp độ, cổng phụ huynh theo dõi tiến độ và điểm số cô lập của con em được giám hộ.

---

### Bước 2: Thiết lập Tầng Core & Common Backend
Tạo bộ khung bất biến:
- `app/core/config.py`: `pydantic-settings` với `DATABASE_URL = "sqlite:///./language_center.db"`.
- `app/core/security.py`: `bcrypt` băm mật khẩu một chiều, `PyJWT` mã hóa token truy cập.
- `app/core/permissions.py`: Khởi tạo `RoleEnum` và dependency `require_roles(allowed_roles: List[RoleEnum])`.
- `app/common/base_model.py`: `TimestampMixin` (`id`, `created_at`, `updated_at`, `is_deleted`).
- `app/common/response.py`: `ApiResponse[T]` (success, code, message, data).
- Mount thư mục tĩnh `uploads/` để phục vụ ảnh đại diện với giới hạn kích thước $\le 5\text{MB}$ và kiểm duyệt định dạng.

---

### Bước 3: Thiết kế Database Models & Quan hệ Thực thể Chuẩn 3NF
- Mọi quan hệ giữa bảng lớp học (`Class`) và học viên (`Student`) phải thông qua bảng liên kết (`ClassStudent`) để lưu trữ lịch sử tham gia và trạng thái (`ENROLLED`, `DROPPED`, `COMPLETED`).
- Bảng lịch học (`ScheduleSession`) liên kết với `Class`, `Classroom`, `Teacher` theo từng buổi riêng lẻ (không gán phòng cố định cứng cho cả khóa).
- Bảng quan hệ giám hộ `parent_students` phân quyền độc quyền cho phụ huynh theo dõi con em của mình.
- Tự động đồng bộ hồ sơ chuyên môn (tạo record trong `teachers` hoặc `students`) khi tài khoản được nâng quyền vai trò tương ứng.

---

### Bước 4: Triển khai Thuật toán Nghiệp vụ Cốt lõi

#### 4.1. Thuật toán Kiểm tra Xung đột Thời khóa biểu (`conflict_checker.py`):
```python
def check_conflicts(db, classroom_id, teacher_id, session_date, start_time, end_time, exclude_session_id=None):
    # Kiểm tra giao khoảng: (start1 < end2) and (end1 > start2)
    # 1. Quét theo classroom_id trong cùng session_date (status != CANCELLED, is_deleted == False)
    # 2. Quét theo teacher_id trong cùng session_date (status != CANCELLED, is_deleted == False)
    # 3. Loại trừ exclude_session_id khi cập nhật chính buổi đó
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
- Học viên phải có kết quả `PASSED` và `is_confirmed == True` ở khóa trước mới được nhân viên học vụ duyệt lên khóa tiếp theo.

#### 4.4. Cơ chế Phòng vệ Brute-force & Khóa Đăng nhập:
- Nhập sai mật khẩu: Tăng `failed_login_attempts`. Nếu $< 5$, cảnh báo số lần còn lại; nếu $\ge 5$, khóa tài khoản trong 15 phút (`locked_until = now + 15m`).
- Quên mật khẩu: Tạo mã OTP 6 chữ số an toàn qua `secrets.randbelow()`, gửi và xác thực để reset mật khẩu và tự động mở khóa tài khoản.

---

### Bước 5: Viết Kịch bản Seed Data Ban đầu (`seed.py`)
Luôn tạo sẵn dữ liệu mẫu phục vụ kiểm thử ngay sau khi khởi tạo DB:
- 5 tài khoản chuẩn cho 5 vai trò (`admin/admin123`, `staff/staff123`, `teacher/teacher123`, `student/student123`, `parent/parent123`).
- Đầy đủ Khóa học (IELTS, TOEIC), Phòng học, Lớp học, Lịch học ma trận, Sổ điểm nháp & chính thức, Quan hệ Giám hộ phụ huynh.

---

### Bước 6: Khởi tạo Frontend & Quản lý Trạng thái Phiên
- Khởi tạo React 19 + Vite + JavaScript (JSX).
- Cấu hình `apiClient` (Axios) tự động đính kèm `Authorization: Bearer <token>` và xử lý lỗi 401.
- `AuthContext`:
  - Phân tách rạch ròi giữa trạng thái nạp phiên ban đầu (`isLoading` chỉ chạy 1 lần khi load app) và trạng thái gửi form (`isLoggingIn` cục bộ tại view) để ngăn chặn hiện tượng unmount mất dữ liệu form khi nhập sai thông tin.
  - Quản lý thông tin định danh và `avatar_url` của người dùng toàn cục.
- Cung cấp `ToastContext` và `ConfirmDialogContext` phục vụ phản hồi người dùng phi chặn.

---

### Bước 7: Tiêu chuẩn Thiết kế UX/UI (Operate Mode & SaaS Craft)
- **Typography:** Google Font `Plus Jakarta Sans` kết hợp `JetBrains Mono` và class `tabular-nums` cho toàn bộ số liệu, mã định danh và thời gian.
- **Dual-Scroll Shell:** Viewport không bao giờ xuất hiện thanh cuộn ngoài cùng; Navbar và Sidebar cố định, main content cuộn độc lập.
- **React Portal Modals:** Mọi modal đều render ra `document.body` qua `createPortal`, có phím tắt ESC và click ngoài để đóng.
- **Thẻ Trạng Thái Đồng Bộ:** Chấm tròn tín hiệu (`dot indicator`) kết hợp nền nhạt và viền mỏng theo chuẩn ngữ nghĩa (Emerald, Amber, Rose, Indigo).
- **Phím tắt Thông minh (Command Palette):** Hỗ trợ `Ctrl+K` để tìm kiếm và chuyển nhanh phân hệ tác vụ.
- **Empty States & Skeletons:** Giao diện khi không có dữ liệu luôn có hình minh họa, thông điệp rõ ràng và nút hành động gợi ý.

---

### Bước 8: Kiểm thử Tự động & Verification
1. **Kiểm thử tích hợp Backend (`test_api.py`):**
   - Kiểm tra Health check, Auth & RBAC 5 vai trò, Brute-force lockout & OTP.
   - Kiểm tra CRUD Khóa học, Lớp học, Phòng học, Đơn đăng ký, Thời khóa biểu, Sổ điểm.
   - Kiểm tra Avatar upload và Static files serving.
   - Đảm bảo 100% test suites (15 suites) đạt trạng thái PASSED.
2. **Kiểm tra Frontend Build:**
   - Chạy `npm run build --prefix frontend` xác thực 0 lỗi, 0 warnings.
   - Rà soát đối chiếu toàn bộ icon imports từ `lucide-react` để loại bỏ rủi ro `ReferenceError` lúc runtime.

---

## 3. DANH MỤC BẢN ĐỒ TRI THỨC KNOWLEDGE ITEMS (KIs)

| Mã KI | Tiêu đề nghiệp vụ & Kỹ thuật cốt lõi |
|---|---|
| **KI-01** | Thuật toán phát hiện xung đột thời khóa biểu thời gian thực (Interval Collision Detection) |
| **KI-02** | Công thức tính điểm theo trọng số, Validation thang điểm 0-10 và khóa điểm chính thức |
| **KI-03** | Ràng buộc điều kiện tiên quyết trong chuyển khóa học (Prerequisite Progression Check) |
| **KI-04** | Mô hình Modular Monolith (DDD-Lite) kiểm soát quy mô 80+ endpoints trên FastAPI |
| **KI-05** | Cấu hình biến môi trường Zero-Config với Pydantic-Settings & SQLite Fallback |
| **KI-06** | Xử lý Type-Only Imports và ký tự escape trong TypeScript / Vite JSX |
| **KI-07** | Thiết kế Lightweight Toast Notification không phụ thuộc bên ngoài (Ponytail UX Pattern) |
| **KI-08** | Phân quyền theo vai trò (RBAC) 5 Roles bằng FastAPI Dependency Injection |
| **KI-09** | Thiết kế Cơ sở Dữ liệu Quan hệ chuẩn 3NF và Ràng buộc Khóa Ngoại cho 82 chức năng |
| **KI-10** | Cơ chế Đăng nhập Nghiêm ngặt (Strict Authentication) & Bảo mật Mật khẩu Bcrypt |
| **KI-11** | Chuyển đổi Toàn diện sang React JavaScript (JSX) Chuẩn Tinh Gọn (Ponytail Mode) |
| **KI-12** | Hoàn thiện Nghiệp vụ Quản lý Điểm số cho Giáo viên (Nhập, Thêm, Xóa & Mở khóa bảng điểm) |
| **KI-13** | Thiết kế Bảng Thời Khóa Biểu Ma Trận Tuần & Lọc Lịch Sử Đã Học (Weekly Matrix Timetable) |
| **KI-14** | Vòng Đời Đăng Ký Lớp Học & Ràng Buộc Hủy Đơn Theo Trạng Thái (State-Gated Cancellation) |
| **KI-15** | Chuẩn Hóa Phân Quyền Kép (Dual Administrative RBAC) và Hoàn Thiện Thao Tác CRUD |
| **KI-16** | Phân Quyền Sổ Điểm Nghiêm Ngặt (Strict Grade Mutation RBAC & Separation of Concerns) |
| **KI-17** | Cô Lập Dữ Liệu Điểm Số Cá Nhân & Giám Hộ (Data Privacy Isolation for Student & Parent) |
| **KI-18** | Thiết Kế Bảng Điều Khiển Chuyên Biệt Theo Vai Trò (Role-Tailored Dashboards Architecture) |
| **KI-19** | Phòng Vệ Chống Tấn Công Dò Mật Khẩu (Brute-force Lockout) & Khôi Phục Mật Khẩu Bằng Mã OTP |
| **KI-20** | Quản Trị Phân Quyền An Toàn: Nâng Quyền Vai Trò, Khóa/Mở Khóa Tức Thì và Đồng Bộ Hồ Sơ Liên Kết |
| **KI-21** | Phân Loại Phản Hồi Lỗi Xác Thực Đa Tầng & Cơ Chế Tự Đăng Ký Tài Khoản (Self-Registration) |
| **KI-22** | Kiến Trúc Quản Lý Ảnh Đại Diện & Đồng Bộ Hồ Sơ Người Dùng Đa Phân Hệ (Avatar & Profile Management) |
| **KI-23** | Kiến Trúc Cuộn Độc Lập (Independent Dual-Scroll Shell) & Giải Quyết Bẫy CSS backdrop-filter Với React Portal |
| **KI-24** | Ngăn Chặn Hiện Tượng Unmount Mất Dữ Liệu Form Do Trạng Thái Loading Toàn Cục (Loading vs Submitting State) |
| **KI-25** | Thiết Kế Bảng Dữ Liệu Chuẩn SaaS (SaaS-Grade Ledger UI Pattern) & Phòng Tránh Bẫy Runtime Missing Icon Imports |
