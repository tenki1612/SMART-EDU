# TÀI LIỆU HỆ THỐNG THIẾT KẾ GIAO DIỆN (UI/UX DESIGN SYSTEM)
## SMART-EDU LMS &bull; Chuẩn Thiết kế Operate Mode (Theo Kỹ năng Impeccable)

Tài liệu này quy chuẩn hóa toàn bộ ngôn ngữ thiết kế giao diện (Design System), bảng mã token màu sắc, typography, component primitives và các nguyên tắc tương tác người dùng của Frontend React.

---

## 1. TRIẾT LÝ GIAO DIỆN: CHUẨN OPERATE MODE

Hệ thống Quản lý Đào tạo (LMS) là phần mềm dạng **Operate Mode** (Công cụ điều hành tác nghiệp):
- **Đối tượng sử dụng:** Nhân viên học vụ, Giáo viên, Ban quản trị làm việc hàng ngày trong thời gian dài (6 - 8 tiếng).
- **Mục tiêu tối thượng:** Khả năng quét thông tin nhanh (High Scanability), giảm thiểu tối đa mỏi mắt, thao tác dữ liệu chính xác, và phản hồi tức thời không làm gián đoạn luồng làm việc.

---

## 2. HỆ THỐNG DESIGN TOKENS (BẢNG MÃ QUY CHUẨN)

### 2.1. Bảng màu (Color Palette)

| Vai trò màu | Hex Code / Tailwind Class | Mục đích sử dụng |
|---|---|---|
| **Primary (Chủ đạo)** | `#4f46e5` (`indigo-600`) | Nhận diện thương hiệu, nút hành động chính (Primary Button), active tab, focus ring |
| **Primary Hover** | `#4338ca` (`indigo-700`) | Trạng thái hover của nút bấm chính |
| **Neutral Canvas** | `#f8fafc` (`slate-50`) | Nền tổng thể của toàn bộ ứng dụng |
| **Surface Card** | `#ffffff` (`white`) | Nền của các thẻ nội dung, modal, bảng dữ liệu |
| **Surface Sub-panel** | `#f1f5f9` (`slate-100`) | Nền bảng header, ô phụ trợ, vùng thông tin thứ cấp |
| **Text Primary** | `#0f172a` (`slate-900`) | Tiêu đề lớn, tên học viên, con số quan trọng |
| **Text Secondary** | `#475569` (`slate-600`) | Nội dung chi tiết, nhãn form, văn bản phụ trợ |
| **Text Muted** | `#94a3b8` (`slate-400`) | Ghi chú ngày giờ, placeholder, chú thích nhỏ |
| **Border Neutral** | `#e2e8f0` (`slate-200`) | Viền bảng, đường phân cách card, viền input |
| **Success / Passed** | `#16a34a` (`emerald-600`) | Trạng thái Đạt, Đã duyệt, Sẵn sàng sử dụng |
| **Warning / Pending** | `#d97706` (`amber-600`) | Trạng thái Chờ duyệt, Bảo trì, Cảnh báo sĩ số |
| **Danger / Failed** | `#e11d48` (`rose-600`) | Chưa đạt, Bị từ chối, Nút Xóa, Lỗi xác thực |

### 2.2. Hệ thống Typography

- **Font chữ văn bản (Body & Headings):** `Plus Jakarta Sans`, sans-serif (nét chữ hiện đại, hình học nhẹ nhàng, độ cao x-height lớn giúp đọc văn bản tiếng Việt rõ ràng ở kích thước nhỏ).
- **Font chữ kỹ thuật (Numbers & Codes):** `JetBrains Mono`, monospace kết hợp thuộc tính CSS `font-variant-numeric: tabular-nums` (đảm bảo các con số ở cột điểm, sĩ số, ngày tháng, mã học viên luôn thẳng hàng theo chiều dọc).

---

## 3. CÁC THÀNH PHẦN NỀN TẢNG (COMPONENT PRIMITIVES)

### 3.1. Thẻ Trạng thái (Semantic Status Badges)
Mọi trạng thái đều sử dụng công thức: **Nền nhạt + Viền mỏng + Chữ đậm vừa + Chấm tròn tín hiệu (Dot indicator)**.

- **Đã duyệt / Sẵn sàng (Success):**
  `bg-emerald-50 text-emerald-700 border border-emerald-200` + Chấm tròn `bg-emerald-500`
- **Chờ duyệt / Bảo trì (Pending):**
  `bg-amber-50 text-amber-700 border border-amber-200` + Chấm tròn `bg-amber-500`
- **Từ chối / Chưa đạt (Danger):**
  `bg-rose-50 text-rose-700 border border-rose-200` + Chấm tròn `bg-rose-500`

### 3.2. Bảng Dữ liệu (Operate Data Tables)
- **Header:** Chiều cao compact (`py-2.5 px-4`), nền `bg-slate-50/80`, chữ `text-[11px] font-bold uppercase tracking-wider text-slate-500`.
- **Row:** Hiệu ứng hover mềm mại `hover:bg-indigo-50/30 transition`, chiều cao hàng vừa phải (`py-3 px-4`).
- **Căn lề chuẩn:**
  - Cột văn bản (Tên, Mã, Email): **Căn trái** (`text-left`).
  - Cột trạng thái / Cờ: **Căn giữa** (`text-center`).
  - Cột số liệu (Điểm số, Sĩ số, Học phí, Thao tác): **Căn phải** (`text-right tabular-nums`).

### 3.3. Thông báo Phản hồi Phi chặn (Toast System)
- Đặt tại góc dưới bên phải màn hình (`fixed bottom-5 right-5 z-50`).
- Tự động đóng sau 4000ms có thanh tiến trình hoặc nút đóng nhanh.
- Tuyệt đối không dùng popup `alert()` làm đóng băng giao diện người dùng.

---

## 4. BẢO MẬT GIAO DIỆN & QUY TẮC ĐĂNG NHẬP

1. Form đăng nhập bắt buộc yêu cầu cả 2 trường: `username` và `password`.
2. Không cho phép bypass hoặc sinh token trực tiếp phía client mà không gửi request xác thực qua API Backend.
3. Khi đổi vai trò, người dùng phải thực hiện thao tác **Đăng xuất** để xóa sạch session, sau đó đăng nhập bằng tài khoản khác.

