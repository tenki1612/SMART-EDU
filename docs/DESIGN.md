# TÀI LIỆU HỆ THỐNG THIẾT KẾ GIAO DIỆN (UI/UX DESIGN SYSTEM)
## SMART-EDU LMS &bull; Chuẩn Thiết kế Operate Mode (Theo Kỹ năng Impeccable & UI-UX Pro Max)

Tài liệu này quy chuẩn hóa toàn bộ ngôn ngữ thiết kế giao diện (Design System), bảng mã token màu sắc, typography, component primitives và các nguyên tắc tương tác người dùng của Frontend React 19.

---

## 1. TRIẾT LÝ GIAO DIỆN: CHUẨN OPERATE MODE & SAAS CRAFT

Hệ thống Quản lý Đào tạo (LMS) là phần mềm dạng **Operate Mode** (Công cụ điều hành tác nghiệp):
- **Đối tượng sử dụng:** Nhân viên học vụ, Giáo viên, Ban quản trị làm việc hàng ngày trong thời gian dài (6 - 8 tiếng).
- **Mục tiêu tối thượng:** Khả năng quét thông tin nhanh (High Scanability), giảm thiểu tối đa mỏi mắt, thao tác dữ liệu chính xác, và phản hồi tức thời không làm gián đoạn luồng làm việc.
- **Tiêu chuẩn Craft:** Tinh gọn, không lạm dụng hiệu ứng rườm rà, loại bỏ các mã ký hiệu kỹ thuật thô (`FR-xx`) trên tiêu đề người dùng, mang lại cảm giác phần mềm doanh nghiệp cao cấp (chuẩn mực tương đương Stripe, Linear, TailwindUI).

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
| **Sidebar Dark** | `#020617` (`slate-950`) | Nền thanh điều hướng bên trái, tạo độ sâu và phân tầng thị giác |
| **Text Primary** | `#0f172a` (`slate-900`) | Tiêu đề lớn, tên học viên, con số quan trọng |
| **Text Secondary** | `#475569` (`slate-600`) | Nội dung chi tiết, nhãn form, văn bản phụ trợ |
| **Text Muted** | `#94a3b8` (`slate-400`) | Ghi chú ngày giờ, placeholder, chú thích nhỏ |
| **Border Neutral** | `#e2e8f0` (`slate-200`) | Viền bảng, đường phân cách card, viền input |
| **Success / Passed** | `#16a34a` (`emerald-600`) | Trạng thái Đạt, Đã duyệt, Sẵn sàng sử dụng, Trực tuyến |
| **Warning / Pending** | `#d97706` (`amber-600`) | Trạng thái Chờ duyệt, Bảo trì, Cảnh báo số lần thử |
| **Danger / Failed** | `#e11d48` (`rose-600`) | Chưa đạt, Bị từ chối, Nút Xóa, Khóa tài khoản tạm thời |

### 2.2. Hệ thống Typography

- **Font chữ văn bản (Body & Headings):** `Plus Jakarta Sans`, sans-serif (nét chữ hiện đại, hình học nhẹ nhàng, độ cao x-height lớn giúp đọc văn bản tiếng Việt rõ ràng ở kích thước nhỏ).
- **Font chữ kỹ thuật (Numbers & Codes):** `JetBrains Mono`, monospace kết hợp thuộc tính CSS `font-variant-numeric: tabular-nums` (đảm bảo các con số ở cột điểm, sĩ số, ngày tháng, mã học viên luôn thẳng hàng theo chiều dọc).

---

## 3. CÁC THÀNH PHẦN NỀN TẢNG (COMPONENT PRIMITIVES)

### 3.1. Thẻ Trạng thái (Semantic Status Badges)
Mọi trạng thái đều sử dụng công thức: **Nền nhạt + Viền mỏng + Chữ đậm vừa + Chấm tròn tín hiệu (Dot indicator)**.

- **Đã duyệt / Sẵn sàng / Hoạt động (Success):**
  `bg-emerald-50 text-emerald-700 border border-emerald-200` + Chấm tròn `bg-emerald-500`
- **Chờ duyệt / Bảo trì (Pending):**
  `bg-amber-50 text-amber-700 border border-amber-200` + Chấm tròn `bg-amber-500`
- **Từ chối / Chưa đạt / Khóa (Danger):**
  `bg-rose-50 text-rose-700 border border-rose-200` + Chấm tròn `bg-rose-500`
- **Học viên tốt nghiệp / Lộ trình (Accent):**
  `bg-indigo-50 text-indigo-700 border border-indigo-200` + Chấm tròn `bg-indigo-500`

### 3.2. Bảng Dữ liệu (Operate Data Tables)
- **Header:** Chiều cao compact (`py-3 px-4`), nền `bg-slate-50/90`, chữ `text-[11px] font-black uppercase tracking-wider text-slate-500`.
- **Row:** Hiệu ứng hover mềm mại `hover:bg-slate-50/80 transition-colors`, chiều cao hàng vừa phải (`py-3.5 px-4`).
- **Avatar Initial:** Hiển thị chữ cái đầu tên người dùng trong ô vuông bo tròn `rounded-xl` với nền màu vai trò tương ứng.
- **Căn lề chuẩn:**
  - Cột văn bản (Tên, Mã, Email, Liên hệ): **Căn trái** (`text-left`).
  - Cột trạng thái / Cờ: **Căn giữa** (`text-center`).
  - Cột số liệu & Thao tác hành động: **Căn phải** (`text-right tabular-nums`).

### 3.3. Thông báo Phản hồi Phi chặn (Toast System)
- Đặt tại góc dưới bên phải màn hình (`fixed bottom-5 right-5 z-50`).
- Tự động đóng sau 4000ms có thanh tiến trình hoặc nút đóng nhanh.
- Tuyệt đối không dùng popup `alert()` làm đóng băng giao diện người dùng.

---

## 4. QUY CHUẨN NÂNG CẤP GIAO DIỆN ĐẲNG CẤP SAAS

1. **Bộ thẻ KPI Metric Overview:** Mỗi phân hệ quản trị đều có 4 thẻ thống kê đầu trang với con số lớn (`text-2xl font-black tabular-nums`), nhãn danh mục màu xám nhạt và icon đại diện bo tròn trong khối màu riêng biệt.
2. **Bộ lọc trạng thái (Filter Chips) động:** Cho phép lọc nhanh dữ liệu với các chip bo góc, hiển thị số lượng bản ghi tương ứng ngay bên trong badge (`font-mono text-[10px]`).
3. **Thanh điều hướng Sidebar Đẳng cấp:**
   - Nền màu đen đá phiến `slate-950` tách biệt với canvas chính.
   - Nút tab đang chọn được phủ dải màu chuyển tiếp `bg-gradient-to-r from-indigo-600 to-indigo-500` kèm bóng đổ neon và mũi tên chỉ báo `ChevronRight`.
4. **Thanh Navbar Trực quan:**
   - Đèn tín hiệu nhấp nháy (Live Ping Indicator) báo hiệu trạng thái máy chủ `ONLINE`.
   - Hiển thị ngày tháng theo định dạng Tiếng Việt chuẩn.
   - Thẻ hồ sơ cá nhân hiển thị vai trò với gradient màu sắc nhận diện.
5. **Modal Hiện đại:**
   - Nền mờ kính tối `bg-slate-950/60 backdrop-blur-xs`.
   - Thân modal bo góc mềm mại `rounded-3xl` với nút đóng nhanh `X` và phân tách header/footer rõ ràng.
