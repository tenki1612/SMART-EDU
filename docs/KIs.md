# KNOWLEDGE ITEMS (KIs) - BẢN ĐỒ TRI THỨC VÀ BÀI HỌC KỸ THUẬT
## Dự án: Hệ thống Web Quản lý Trung tâm Ngoại ngữ (SMART-EDU LMS)

Tài liệu này lưu trữ các **Knowledge Items (KIs)** — các bài học kiến trúc, giải pháp kỹ thuật, công thức nghiệp vụ cốt lõi và các "bẫy" kỹ thuật (gotchas/edge cases) được giải quyết và đúc kết trong quá trình triển khai hệ thống 82 chức năng (FR-01 đến FR-82).

---

## 📌 MỤC LỤC KNOWLEDGE ITEMS

- **KI-01:** Thuật toán phát hiện xung đột thời khóa biểu thời gian thực (Interval Collision Detection)
- **KI-02:** Công thức tính điểm theo trọng số, Validation thang điểm 0-10 và khóa điểm chính thức
- **KI-03:** Ràng buộc điều kiện tiên quyết trong chuyển khóa học (Prerequisite Progression Check)
- **KI-04:** Mô hình Modular Monolith (DDD-Lite) kiểm soát quy mô 80+ endpoints trên FastAPI
- **KI-05:** Cấu hình biến môi trường Zero-Config với Pydantic-Settings & SQLite Fallback
- **KI-06:** Xử lý Type-Only Imports và ký tự escape trong TypeScript 5 / Vite JSX
- **KI-07:** Thiết kế Lightweight Toast Notification không phụ thuộc bên ngoài (Ponytail UX Pattern)
- **KI-08:** Phân quyền theo vai trò (RBAC) 5 Roles bằng FastAPI Dependency Injection
- **KI-09:** Thiết kế Cơ sở Dữ liệu Quan hệ chuẩn 3NF và Ràng buộc Khóa Ngoại cho 82 chức năng
- **KI-10:** Cơ chế Đăng nhập Nghiêm ngặt (Strict Authentication) & Bảo mật Mật khẩu Bcrypt
- **KI-11:** Chuyển đổi Toàn diện sang React JavaScript (JSX) Chuẩn Tinh Gọn (Ponytail Mode)
- **KI-12:** Hoàn thiện Nghiệp vụ Quản lý Điểm số cho Giáo viên (Nhập, Thêm, Xóa & Mở khóa bảng điểm)
- **KI-13:** Thiết kế Bảng Thời Khóa Biểu Ma Trận Tuần & Lọc Lịch Sử Đã Học (Weekly Matrix Timetable)
- **KI-14:** Vòng Đời Đăng Ký Lớp Học & Ràng Buộc Hủy Đơn Theo Trạng Thái (State-Gated Cancellation)
- **KI-15:** Chuẩn Hóa Phân Quyền Kép (Dual Administrative RBAC) và Hoàn Thiện Thao Tác CRUD
- **KI-16:** Phân Quyền Sổ Điểm Nghiêm Ngặt (Strict Grade Mutation RBAC & Separation of Concerns)
- **KI-17:** Cô Lập Dữ Liệu Điểm Số Cá Nhân & Giám Hộ (Data Privacy Isolation for Student & Parent)
- **KI-18:** Thiết Kế Bảng Điều Khiển Chuyên Biệt Theo Vai Trò (Role-Tailored Dashboards Architecture)
- **KI-19:** Phòng Vệ Chống Tấn Công Dò Mật Khẩu (Brute-force Lockout) & Khôi Phục Mật Khẩu Bằng Mã OTP
- **KI-20:** Quản Trị Phân Quyền An Toàn: Nâng Quyền Vai Trò, Khóa/Mở Khóa Tức Thì và Đồng Bộ Hồ Sơ Liên Kết
- **KI-21:** Phân Loại Phản Hồi Lỗi Xác Thực Đa Tầng & Cơ Chế Tự Đăng Ký Tài Khoản (Self-Registration)
- **KI-22:** Kiến Trúc Quản Lý Ảnh Đại Diện & Đồng Bộ Hồ Sơ Người Dùng Đa Phân Hệ (Avatar & Profile Management)

---

### [KI-01] Thuật toán Phát hiện Xung đột Thời khóa biểu Thời gian thực
- **Bối cảnh nghiệp vụ:** (FR-61, FR-62, FR-65) Khi xếp lịch hoặc điều chỉnh thời khóa biểu cho một lớp, hệ thống bắt buộc phải kiểm tra xem **phòng học** hoặc **giáo viên** có bị trùng giờ với bất kỳ buổi học nào khác trong cùng ngày hay không.
- **Nguyên lý toán học:** Hai khoảng thời gian $[A_{\text{start}}, A_{\text{end}}]$ và $[B_{\text{start}}, B_{\text{end}}]$ giao nhau khi và chỉ khi:
  $$\text{Overlap} \iff (A_{\text{start}} < B_{\text{end}}) \land (A_{\text{end}} > B_{\text{start}})$$
- **Triển khai chuẩn:**
  ```python
  # backend/app/modules/schedules/conflict_checker.py
  def _is_time_overlap(start1: str, end1: str, start2: str, end2: str) -> bool:
      return (start1 < end2) and (end1 > start2)
  ```
- **Lưu ý thực tế (Edge cases):**
  1. *Buổi học liền kề không xung đột:* Nếu ca 1 kết thúc lúc `18:00` và ca 2 bắt đầu lúc `18:00`, điều kiện trên trả về `False` $\rightarrow$ Hợp lệ (không va chạm).
  2. *Bỏ qua các buổi đã hủy:* Bắt buộc phải thêm điều kiện lọc `status != 'CANCELLED'` và `is_deleted == False`.
  3. *Loại trừ chính buổi học đang sửa:* Khi cập nhật lịch (`PUT /schedules/{session_id}`), phải truyền `exclude_session_id` để tránh tự xung đột với chính mình.

---

### [KI-02] Công thức Tính điểm Trọng số và Xếp loại Học viên
- **Bối cảnh nghiệp vụ:** (FR-69 $\rightarrow$ FR-77) Nhập điểm, kiểm tra điểm hợp lệ và tổng kết kết quả khóa học.
- **Quy tắc tính toán:**
  - Điểm chuyên cần (Attendance): $20\%$
  - Điểm giữa kỳ (Midterm): $30\%$
  - Điểm cuối kỳ (Final): $50\%$
  - $\text{Total Score} = \text{round}(0.2 \times \text{Attendance} + 0.3 \times \text{Midterm} + 0.5 \times \text{Final}, 2)$
- **Điều kiện Đạt (PASSED):**
  $$\text{PASSED} \iff (\text{Total Score} \ge 5.0) \land (\text{Final Score} \ge 4.0)$$
- **Quy trình khóa điểm (Locking):**
  - Giáo viên chỉ có quyền nhập điểm nháp (`result_status = PENDING`).
  - Điểm chỉ có hiệu lực chính thức khi Nhân viên học vụ hoặc Admin thực hiện thao tác **"Xác nhận chính thức (FR-76)"** (`is_confirmed = True`). Khi đã xác nhận, hệ thống từ chối mọi thao tác chỉnh sửa bảng điểm để bảo vệ tính toàn vẹn dữ liệu.

---

### [KI-03] Ràng buộc Điều kiện Tiên quyết Chuyển Khóa (Progression)
- **Bối cảnh nghiệp vụ:** (FR-78 $\rightarrow$ FR-80) Tránh việc học viên chưa đủ trình độ (ví dụ: chưa đạt IELTS 6.5) đăng ký vượt cấp lên các lớp IELTS Master 7.5+.
- **Luồng kiểm tra 3 bước:**
  1. **Bước 1 (Hệ thống):** Quét toàn bộ lịch sử điểm của học viên ở khóa học hiện tại (`current_course_id`). Kiểm tra có ít nhất một bản ghi điểm chính thức đạt trạng thái `result_status == 'PASSED'` và `is_confirmed == True`.
  2. **Bước 2 (Học vụ):** Nhân viên học vụ kiểm tra bảng tổng kết và bấm nút **"Xác nhận đủ điều kiện nâng khóa (FR-79)"**.
  3. **Bước 3 (Học viên/Phụ huynh):** Khi gửi yêu cầu đăng ký lớp khóa kế tiếp (`FR-80`), hệ thống kiểm tra bản ghi xác nhận ở Bước 2. Nếu chưa được duyệt, từ chối đăng ký với thông báo rõ ràng.

---

### [KI-04] Kiến trúc Modular Monolith (DDD-Lite) trên FastAPI
- **Vấn đề thường gặp:** Trong các dự án có 70-80+ endpoints, cấu trúc Flat Layer (`routers/`, `services/`, `models/` ở root) làm cho các file phình to hàng nghìn dòng, rất khó bảo trì và dễ xung đột git merge.
- **Giải pháp áp dụng:**
  - Chia theo **11 Bounded Contexts** (auth, accounts, courses, students, teachers, classes, classrooms, enrollments, schedules, grades, progression_parent).
  - Mỗi module sở hữu đầy đủ 4 tầng riêng: `models.py`, `schemas.py`, `service.py`, `router.py`.
  - Một file tổng hợp `app/api/v1/api.py` include toàn bộ routers với `tags` tương ứng, giúp Swagger UI tự động nhóm thành 11 phân hệ sạch sẽ, trực quan.

---

### [KI-05] Cấu hình Biến Môi trường Zero-Config với Pydantic-Settings
- **Vấn đề:** Người dùng chạy thử dự án thường gặp lỗi `KeyError: DATABASE_URL` hoặc quên tạo file `.env`, dẫn tới crash ứng dụng khi khởi động.
- **Giải pháp:**
  - Định nghĩa class `Settings(BaseSettings)` với giá trị mặc định cho toàn bộ các biến quan trọng:
    - `DATABASE_URL = "sqlite:///./language_center.db"` (mặc định SQLite chạy ngay).
    - `SECRET_KEY = "..."`, `API_V1_STR = "/api/v1"`.
  - Cấu hình `env_file = ".env"`. Pydantic sẽ nạp file `.env` nếu có; nếu không có, tự động dùng giá trị mặc định mà không throw exception.

---

### [KI-06] Xử lý Type-Only Imports và Ký tự Escape trong TypeScript / JSX
- **Gotchas:**
  1. *TypeScript `verbatimModuleSyntax`:* Trong TypeScript 5+, khi import type interface thông thường (`import { User } from './types'`), trình biên dịch có thể báo lỗi `TS1484: 'User' is a type and must be imported using a type-only import`.
     $\rightarrow$ Giải pháp: Cấu hình `"verbatimModuleSyntax": false` trong `tsconfig.app.json` hoặc sử dụng `import type { User }`.
  2. *Unescaped JSX character `>`:* Trong React JSX, viết văn bản thô như `(FR-11 -> FR-17)` sẽ bị trình phân tích JSX coi ký tự `>` là thẻ đóng HTML và báo lỗi `TS1382: Unexpected token. Did you mean {'>'} or &gt;?`.
     $\rightarrow$ Giải pháp: Sử dụng từ ngữ tự nhiên `(FR-11 đến FR-17)` hoặc thực thể HTML `&rarr;`.

---

### [KI-07] Lightweight Toast Notification Context (Ponytail UX Pattern)
- **Vấn đề:** Dùng popup trình duyệt `alert()` làm đơ UI thread và giao diện nhìn kém chuyên nghiệp. Nhưng cài đặt thư viện ngoài (`react-toastify`, `sweetalert2`) làm tăng kích thước bundle thêm hàng trăm kB.
- **Giải pháp:**
  - Viết một `ToastContext` gói gọn trong 60 dòng code React thuần:
    - Quản lý mảng state `toasts: ToastItem[]`.
    - Auto-dismiss bằng `setTimeout` sau 4000ms.
    - Container cố định góc phải màn hình (`fixed bottom-5 right-5 z-50 pointer-events-none`).
    - Nút bấm và toast con có `pointer-events-auto`.
  - Cho phép gọi `toast.success()`, `toast.error()`, `toast.warning()`, `toast.info()` ở bất kỳ view nào.

---

### [KI-08] Phân Quyền Vai Trò (RBAC) bằng FastAPI Dependency Injection
- **Triển khai:**
  ```python
  def require_roles(allowed_roles: List[RoleEnum]):
      def role_checker(payload: dict = Depends(get_current_user_payload)):
          user_role = payload.get("role")
          if user_role not in [r.value for r in allowed_roles]:
              raise HTTPException(
                  status_code=403,
                  detail=f"Quyền truy cập bị từ chối. Vai trò ({user_role}) không được phép."
              )
          return payload
      return role_checker
  ```
- **Sử dụng:** Gắn trực tiếp vào router decorator:
  ```python
  @router.post("/", dependencies=[Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))])
  ```
  Giúp kiểm soát quyền ngay tại cửa ngõ HTTP trước khi request chạm vào Service logic.

---

### [KI-09] Thiết kế Cơ sở Dữ liệu Quan hệ chuẩn 3NF và Ràng buộc Khóa Ngoại
- **Bối cảnh:** Toàn bộ 82 chức năng nghiệp vụ được phân rã thành 12 thực thể bảng quan hệ: `users`, `courses`, `students`, `teachers`, `classrooms`, `classes`, `class_students`, `enrollment_requests`, `schedule_sessions`, `grade_records`, `course_progressions`, `parent_students`.
- **Nguyên tắc thiết kế:**
  1. *Phân tách thông tin tài khoản và hồ sơ chuyên môn (1-1):* Bảng `users` quản lý thông tin xác thực (`username`, `hashed_password`, `role`). Bảng `students` và `teachers` liên kết 1-1 qua `user_id` để chứa các thuộc tính chuyên ngành (`student_code`, `date_of_birth`, `teacher_code`, `specialty`, `degree`).
  2. *Ràng buộc toàn vẹn dữ liệu:* Khóa ngoại `FOREIGN KEY` với cơ chế `ON DELETE CASCADE` hoặc `RESTRICT` phù hợp.
  3. *Tối ưu truy vấn (Indexing):* Đánh Index các trường thường xuyên tìm kiếm và join: `username`, `email`, `code`, `student_code`, `teacher_code`, `room_code`, `class_code`, `session_date`.
  4. *Chi tiết hoàn chỉnh:* Xem tại [DATABASE_DESIGN.md](file:///d:/OOAD/docs/DATABASE_DESIGN.md).

---

### [KI-10] Cơ chế Đăng nhập Nghiêm ngặt (Strict Authentication) & Bảo mật Mật khẩu Bcrypt
- **Vấn đề:** Trong giai đoạn phát triển ban đầu, các nút chuyển đổi vai trò nhanh (Quick Login / Role Switcher) thường được dùng để test nhanh. Tuy nhiên, nếu để lại trong hệ thống sẽ tạo lỗ hổng bảo mật nghiêm trọng (bất kỳ ai cũng có thể giả mạo Admin mà không có mật khẩu).
- **Giải pháp xử lý:**
  1. *Loại bỏ hoàn toàn tính năng bypass xác thực:* Gỡ bỏ `quickLogin()` khỏi `AuthContext`, xóa các nút đổi vai trò tự động trên Navbar và Login View.
  2. *Bắt buộc xác thực 2 yếu tố đầu vào:* Người dùng (kể cả Admin, Giáo viên, Học vụ, Học viên, Phụ huynh) đều phải nhập đúng `username` và `password`.
  3. *Mã hóa một chiều an toàn:* Mật khẩu được băm bằng thuật toán `bcrypt` (`passlib.context.CryptContext(schemes=["bcrypt"], deprecated="auto")`), không lưu plaintext trong database.
  4. *Chuẩn hóa màn hình đăng nhập Production:* Form đăng nhập khởi tạo ở trạng thái trống (`username = ''`, `password = ''`), loại bỏ các nút phím tắt đăng nhập mẫu để đảm bảo người dùng nhập đúng thông tin tài khoản thật, bảo đảm an ninh và phản ánh trung thực quy trình xác thực.

---

### [KI-11] Chuyển đổi Toàn diện sang React JavaScript (JSX) Chuẩn Tinh Gọn (Ponytail Mode)
- **Bối cảnh:** Đáp ứng yêu cầu chuyển đổi từ TypeScript sang JavaScript thuần túy nhằm giảm sự phức tạp về cấu hình compiler, tăng tốc độ phát triển và giúp mã nguồn dễ tiếp cận, dễ tùy biến.
- **Quy trình chuyển đổi:**
  1. *Lược bỏ toàn bộ Type Annotations & Interfaces:* Chuyển đổi 20 file từ `.tsx` sang `.jsx` và `.ts` sang `.js` (`views`, `components`, `context`, `services`).
  2. *Cập nhật cấu hình Bundler:* `vite.config.ts` $\rightarrow$ `vite.config.js`, `index.html` trỏ sang `/src/main.jsx`.
  3. *Tối giản Dependencies:* Gỡ bỏ các file `tsconfig*.json` và các package `@types/*`, `typescript` trong `package.json`. Lệnh build chuyển thành `vite build`.
  4. *Kết quả:* 2001 modules được build chỉ trong 500ms, không phát sinh bất kỳ lỗi cú pháp nào.

---

### [KI-12] Hoàn thiện Nghiệp vụ Quản lý Điểm số cho Giáo viên (Nhập, Thêm, Xóa & Mở khóa)
- **Vấn đề phát hiện:**
  1. Dữ liệu mẫu (Seed Data) bị khóa cứng trạng thái `is_confirmed = True`, khiến giáo viên khi bấm "Lưu bảng điểm" bị Backend từ chối với lỗi `HTTP 400`.
  2. Giao diện trước đây chỉ hiển thị học viên đã có sẵn trong lớp, thiếu hoàn toàn nút chức năng **Thêm học viên vào bảng điểm** và **Xóa học viên khỏi bảng điểm**.
- **Giải pháp triển khai:**
  1. *Backend Endpoints:*
     - `POST /api/v1/grades/classes/{class_id}/students`: Thêm học viên vào lớp và khởi tạo bản ghi điểm.
     - `DELETE /api/v1/grades/classes/{class_id}/students/{student_id}`: Xóa bản ghi điểm và gỡ học viên khỏi lớp.
     - `PATCH /api/v1/grades/classes/{class_id}/unlock`: Mở khóa bảng điểm để giáo viên điều chỉnh khi cần.
  2. *Frontend View (`GradesView.jsx`):*
     - Bổ sung Modal chọn học viên trong trung tâm để thêm vào bảng điểm với điểm khởi tạo.
     - Thêm nút Xóa (icon `Trash2`) cho từng dòng học viên trong bảng điểm.
     - Thêm nút Mở khóa bảng điểm (`Unlock`) và hiển thị trạng thái rõ ràng (Đang mở / Đã khóa).
     - Cho phép giáo viên nhập điểm (Chuyên cần, Giữa kỳ, Cuối kỳ), tự động tính tổng kết theo thời gian thực và lưu bảng điểm thành công 100%.

---

### [KI-13] Thiết kế Bảng Thời Khóa Biểu Ma Trận Tuần & Lọc Lịch Sử Đã Học (Weekly Timetable)
- **Bối cảnh nghiệp vụ:** (FR-63, FR-64, FR-68) Học viên, giáo viên và nhân viên học vụ gặp khó khăn khi theo dõi thời khóa biểu nếu chỉ có chế độ xem danh sách (List View). Cần có bảng tuần (Timetable Matrix) trực quan theo phong cách Google Calendar / Outlook và bộ lọc phân tách buổi học sắp tới vs lịch sử đã học.
- **Thuật toán xác định Thứ Hai đầu tuần:**
  ```javascript
  const now = new Date();
  const day = now.getDay();
  const diff = (day === 0 ? -6 : 1) - day; // Chủ nhật getDay()=0 -> lùi 6 ngày; Thứ 2 -> giữ nguyên
  const monday = new Date(now);
  monday.setDate(now.getDate() + diff);
  monday.setHours(0, 0, 0, 0);
  ```
- **Xây dựng Ma trận 2 Chiều (7 Ngày $\times$ $N$ Ca học):**
  - **7 Cột Ngày:** Thứ 2 $\rightarrow$ Chủ Nhật, tự động highlight cột "Hôm nay" (`isToday`).
  - **Hàng Ca học chuẩn:** Ca sáng (08:00 - 10:00), Ca chiều (14:00 - 16:00), Ca tối (18:00 - 20:00), Ca tối 2 (20:00 - 22:00).
  - **Khớp buổi học vào ô:** Lọc các session thỏa mãn `s.session_date === dateStr` và `s.start_time >= slot.start && s.start_time < slot.end`.
- **Cơ chế Quick-Scheduling từ Ô trống:**
  - Khi ô lưới không có buổi học và người dùng là Admin/Staff: Hiển thị placeholder nét đứt; bấm vào sẽ mở ngay Modal thêm buổi học với `session_date`, `start_time`, `end_time` được điền tự động.
- **Phân loại Lịch sử (History Partitioning):**
  - `upcoming`: `session_date >= todayStr`
  - `past`: `session_date < todayStr`
  - Giúp học viên và phụ huynh dễ dàng rà soát lại các buổi đã hoàn thành trong quá khứ.

---

### [KI-14] Vòng Đời Đăng Ký Lớp Học & Ràng Buộc Hủy Đơn Theo Trạng Thái (State-Gated Cancellation)
- **Bối cảnh nghiệp vụ:** (FR-50 $\rightarrow$ FR-60) Học viên gửi yêu cầu đăng ký lớp (`EnrollmentRequest`). Cần cho phép học viên chủ động hủy đơn khi đổi ý, nhưng phải ngăn chặn triệt để việc tự ý hủy khi đơn đã được duyệt chính thức.
- **Máy Trạng Thái Nghiệp Vụ (Finite State Machine):**
  $$\text{PENDING} \xrightarrow{\text{Student Cancel}} \text{CANCELLED}$$
  $$\text{PENDING} \xrightarrow{\text{Staff Approve}} \text{APPROVED}$$
  $$\text{PENDING} \xrightarrow{\text{Staff Reject}} \text{REJECTED}$$
- **Ràng buộc Bất Biến (Invariant):**
  - *Chỉ được hủy khi `status == PENDING`*: Học viên có thể hủy đăng ký nếu hồ sơ chưa được nhân viên học vụ xem xét.
  - *Cấm hủy khi `status == APPROVED`*: Khi đã duyệt, hệ thống đã ghi nhận học viên vào bảng `ClassStudent`, tăng `current_enrolled`, và cấp chỗ ngồi trong lớp. Việc tự ý hủy lúc này sẽ làm sai lệch sĩ số và kế hoạch lớp học. Phải thông qua quy trình rút lớp do Học vụ xử lý.
- **Mô hình Phòng vệ 2 Lớp (Defense-in-depth):**
  1. *Tầng Frontend UI (`EnrollmentsView.jsx`):*
     - Nếu `status === 'PENDING'`: Hiển thị nút "Hủy đăng ký" (icon `Trash2`).
     - Nếu `status === 'APPROVED'`: Khóa nút hủy, thay bằng badge `Đã duyệt • Không thể hủy`.
  2. *Tầng Backend Service (`service.py`):*
     ```python
     if req.status != "PENDING":
         raise BusinessException("Chỉ có thể hủy yêu cầu khi đang ở trạng thái 'Chờ duyệt' (PENDING).")
     ```

---

### [KI-15] Chuẩn Hóa Phân Quyền Kép (Dual Administrative RBAC) và Hoàn Thiện Thao Tác CRUD
- **Vấn đề phát hiện:**
  - Nhân viên học vụ (`ACADEMIC_STAFF`) là người trực tiếp điều phối lớp học, phòng học, khóa học và lịch học hàng ngày, nhưng một số API và View trước đây chỉ cấp quyền cho `ADMIN`, hoặc thiếu các modal chỉnh sửa/xóa hoàn chỉnh.
- **Giải pháp Kiến trúc:**
  1. *Đồng bộ RBAC Decorators Backend:* Cấp quyền đồng thời cho cả `ADMIN` và `ACADEMIC_STAFF`:
     ```python
     _ = Depends(require_roles([RoleEnum.ADMIN, RoleEnum.ACADEMIC_STAFF]))
     ```
     Áp dụng nhất quán tại:
     - `courses/router.py`: Tạo, cập nhật, xóa, bật/tắt khóa học.
     - `classes/router.py`: Tạo, cập nhật thông tin, xóa lớp học.
     - `classrooms/router.py`: Tạo, cập nhật sức chứa, chuyển bảo trì, xóa phòng học.
     - `accounts/router.py`: Tạo, cập nhật thông tin, kích hoạt/vô hiệu hóa, xóa tài khoản.
     - `schedules/router.py`: Tạo, cập nhật buổi học, hủy buổi, xóa buổi học khỏi thời khóa biểu.
  2. *Frontend View Integration:*
     - Cờ kiểm tra quyền hạn nhất quán: `const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');`.
     - Bổ sung đầy đủ Modal: Thêm mới, Sửa chi tiết, Nút Xóa có hộp thoại xác nhận.
     - Loại bỏ triệt để các hàm `alert()` và `window.prompt()` cũ, thay thế bằng `ToastContext` và Modal chuẩn Tailwind CSS hiện đại.


---

### [KI-16] Phân Quyền Sổ Điểm Nghiêm Ngặt (Strict Grade Mutation RBAC & Separation of Concerns)
- **Bối cảnh nghiệp vụ:**
  - Quy định học viện: Chỉ có Giảng viên trực tiếp phụ trách lớp học mới có quyền nhập và chỉnh sửa điểm số học viên.
  - Quản trị viên (ADMIN) và Nhân viên học vụ (ACADEMIC_STAFF) chỉ đóng vai trò phê duyệt, lưu trữ/khóa điểm chính thức và xóa điểm học viên khỏi danh sách lớp khi cần xử lý học vụ. Họ tuyệt đối không được tự ý sửa điểm thành phần hay điểm thi của học viên.
- **Giải pháp Kiến trúc Phòng vệ 2 Tầng (Defense-in-depth):**
  1. *Backend RBAC (`backend/app/modules/grades/router.py`):*
     - `POST /api/v1/grades/batch`: Chặn cứng bằng `require_roles([RoleEnum.TEACHER])`. Bất kỳ yêu cầu sửa điểm hàng loạt nào gửi từ Admin hoặc Academic Staff đều bị phản hồi lỗi `403 Forbidden` kèm thông báo: *"Chỉ có Giảng viên phụ trách mới có quyền thay đổi điểm!"*.
     - `PATCH /api/v1/grades/classes/{class_id}/confirm`: Cấp riêng cho `RoleEnum.ADMIN` và `RoleEnum.ACADEMIC_STAFF` để đóng sổ điểm chính thức.
     - `DELETE /api/v1/grades/classes/{class_id}/students/{student_id}`: Cho phép `ADMIN`, `ACADEMIC_STAFF` và `TEACHER` rút học viên/xóa điểm khỏi sổ điểm lớp.
  2. *Frontend View (`frontend/src/views/GradesView.jsx`):*
     - Với `ADMIN` và `ACADEMIC_STAFF`: Các ô input nhập điểm (`attendance_score`, `midterm_score`, `final_score`) đều bị khóa cứng `disabled`, giao diện hiển thị banner thông báo màu lam nêu rõ quy định quyền hạn.
     - Ẩn hoàn toàn nút *"Lưu bảng điểm"* đối với nhân viên và quản trị viên, thay vào đó là nút *"Lưu & Khóa điểm chính thức (Chỉ Staff/Admin)"*, *"Mở khóa"*, *"Thêm học viên"* và nút *"Xóa khỏi bảng điểm"*.

---

### [KI-17] Cô Lập Dữ Liệu Điểm Số Cá Nhân & Giám Hộ (Data Privacy Isolation for Student & Parent)
- **Bối cảnh nghiệp vụ:**
  - Để tuân thủ quyền riêng tư dữ liệu học tập, học sinh chỉ được phép xem điểm của chính mình; tuyệt đối không thể xem điểm của học sinh khác trong cùng lớp hoặc các lớp khác.
  - Phụ huynh chỉ được phép theo dõi bảng điểm của những người con (wards) mà mình được phân quyền giám hộ hợp pháp trong bảng `parent_students`.
- **Kiến trúc Bảo mật:**
  1. *Học sinh (`STUDENT`):*
     - Endpoint chuyên biệt: `GET /api/v1/grades/my-grades` sử dụng `current_user.id` để truy vấn `Student` tương ứng, chỉ trả về các bản ghi điểm của chính học viên.
     - Giao diện `GradesView.jsx`: Tự động nhận diện vai trò học sinh, ẩn bỏ hoàn toàn thanh chọn lớp học (tránh việc tò mò xem điểm lớp khác), hiển thị trực tiếp danh sách kết quả học tập cá nhân kèm KPI môn đạt/chưa đạt và GPA.
  2. *Phụ huynh (`PARENT`):*
     - Endpoint mới: `GET /api/v1/progression/parent/wards/{student_id}/grades` bảo vệ bằng `require_roles([RoleEnum.PARENT])`.
     - Tầng Service kiểm tra nghiêm ngặt quan hệ giám hộ trong bảng `parent_students`:
       ```python
       link = db.query(ParentStudent).filter(
           ParentStudent.parent_user_id == parent_user_id,
           ParentStudent.student_id == student_id
       ).first()
       if not link:
           raise ForbiddenException("Bạn chỉ có quyền xem bảng điểm của con mình được giám hộ.")
       ```
     - Giao diện `GradesView.jsx`: Hiển thị thanh tab lựa chọn từng người con được giám hộ, thẻ tóm tắt học sinh và bảng điểm môn học chi tiết của người con đó.

---

### [KI-18] Thiết Kế Bảng Điều Khiển Chuyên Biệt Theo Vai Trò (Role-Tailored Dashboards Architecture)
- **Bối cảnh nghiệp vụ:**
  - Bảng điều khiển (Dashboard) là nơi người dùng tiếp cận đầu tiên sau khi đăng nhập. Một bảng điều khiển chung chung sẽ khiến phụ huynh, học sinh bối rối bởi các thuật ngữ quản trị, trong khi giáo viên và nhân viên học vụ lại thiếu các công cụ điều hành nhanh.
- **Giải pháp Thiết kế Giao diện (Frontend Architecture):**
  - Tách `DashboardView.jsx` thành 4 giao diện nghiệp vụ độc lập dựa trên `user?.role`:
  1. **Quản trị viên & Nhân viên học vụ (`ADMIN` / `ACADEMIC_STAFF`):**
     - 4 Thẻ KPI vĩ mô: Tổng số học viên, Khóa học đang mở, Số lớp hoạt động, Yêu cầu đăng ký chờ duyệt.
     - Widget Điều hành: Danh sách đơn đăng ký chờ duyệt nhanh, Tỷ lệ lấp đầy phòng học (Room Capacity Utilization).
     - Phím tắt tác vụ nhanh: Mở khóa học mới, Tạo lớp học, Xếp thời khóa biểu, Quản lý phòng học.
  2. **Giảng viên (`TEACHER`):**
     - Thống kê giảng dạy: Số lớp phụ trách, Tổng học viên đang dạy, Lịch dạy trong tuần, Sổ điểm đang chờ hoàn tất.
     - Bảng lớp học phụ trách kèm trạng thái sổ điểm (Đã khóa / Cần nhập điểm) và nút chuyển nhanh đến Sổ điểm.
  3. **Học sinh (`STUDENT`):**
     - Thông tin cá nhân: Lớp học đang tham gia, Điểm trung bình GPA, Tỷ lệ môn đã hoàn thành.
     - Lịch học sắp tới trong tuần (kèm phòng học, giảng viên và giờ học).
     - Bảng điểm tóm tắt các môn gần nhất và nút điều hướng đến Lịch học, Sổ điểm cá nhân, Đăng ký lớp.
  4. **Phụ huynh (`PARENT`):**
     - Thẻ hồ sơ con em được giám hộ: Mã học viên, Tên, Ngày sinh, Khóa học đang học, Trạng thái.
     - Danh sách các môn con đang học kèm điểm số và kết quả (Đạt/Chưa đạt).
     - Nút xem chi tiết bảng điểm và đăng ký khóa học tiếp theo cho con.


---

### [KI-19] Phòng Vệ Chống Tấn Công Dò Mật Khẩu (Brute-force Lockout) & Khôi Phục Mật Khẩu Bằng Mã OTP
- **Bối cảnh nghiệp vụ:**
  - Hệ thống đào tạo lưu trữ dữ liệu nhạy cảm của học viên, điểm số và thông tin cá nhân của phụ huynh, giáo viên.
  - Nguy cơ: Kẻ tấn công hoặc người dùng thử dò mật khẩu tài khoản liên tục (Brute-force attack).
  - Yêu cầu: Hiển thị cảnh báo số lần thử còn lại khi nhập sai mật khẩu; nếu nhập sai quá 5 lần thì tài khoản phải bị khóa tạm thời trong 15 phút. Người dùng có thể sử dụng chức năng Quên mật khẩu để khôi phục quyền truy cập ngay lập tức.
- **Giải pháp Kiến trúc Bảo mật (Backend Architecture):**
  1. *Schema mở rộng trên bảng `users`:*
     - `failed_login_attempts`: Lưu số lần đăng nhập thất bại liên tiếp (mặc định 0).
     - `locked_until`: Thời điểm kết thúc khóa tài khoản (DateTime, mặc định `None`).
     - `reset_token`: Mã OTP khôi phục mật khẩu (6 chữ số).
     - `reset_token_expires_at`: Thời hạn hiệu lực của mã OTP (15 phút).
  2. *Quy trình Xác thực & Khóa đăng nhập (`AuthService.authenticate_user`):*
     - Bước 1: Kiểm tra `user.locked_until`. Nếu thời điểm hiện tại `< user.locked_until`: Từ chối đăng nhập với thông báo: *"Tài khoản của bạn đã bị khóa tạm thời do nhập sai mật khẩu quá 5 lần. Vui lòng thử lại sau X phút hoặc sử dụng chức năng 'Quên mật khẩu' để khôi phục."*
     - Bước 2: Nếu thời gian khóa đã trôi qua, tự động reset `failed_login_attempts = 0` và `locked_until = None`.
     - Bước 3: So khớp mật khẩu qua Bcrypt. Nếu sai:
       - Tăng `failed_login_attempts += 1`.
       - Nếu `failed_login_attempts < 5`: Trả về `400 Bad Request` kèm thông báo: *"Mật khẩu không chính xác. Bạn còn {5 - attempts} lần thử trước khi tài khoản bị khóa tạm thời."*
       - Nếu `failed_login_attempts >= 5`: Thiết lập `locked_until = now + 15 phút`, phản hồi cảnh báo khóa tài khoản.
     - Bước 4: Khi đăng nhập thành công với mật khẩu đúng, reset ngay `failed_login_attempts = 0` và xóa `locked_until`.
  3. *Quy trình Khôi phục Mật khẩu Hai Bước (2-Step OTP Password Reset):*
     - **Bước 1 (`POST /auth/forgot-password`):** Người dùng nhập username hoặc email. Hệ thống sinh mã OTP 6 chữ số ngẫu nhiên an toàn qua `secrets.randbelow()`, lưu vào `reset_token` kèm thời hạn 15 phút.
     - **Bước 2 (`POST /auth/reset-password`):** Người dùng nhập `identifier`, `reset_code` và `new_password` (tối thiểu 6 ký tự). Hệ thống kiểm tra tính hợp lệ và thời hạn của OTP, cập nhật hash mật khẩu mới, đồng thời tự động xóa trạng thái khóa tài khoản (`failed_login_attempts = 0`, `locked_until = None`), cho phép đăng nhập ngay.
- **Trải nghiệm Người dùng (Frontend UI/UX):**
  - Giao diện `LoginView.jsx` phân định rõ các trạng thái: Thẻ cảnh báo màu vàng khi còn lượt thử, Thẻ cảnh báo đỏ đậm khi bị khóa tạm thời kèm liên kết tắt *"Mở khóa tài khoản ngay qua chức năng Quên mật khẩu"*.
  - Chuyển đổi mượt mà giữa chế độ Đăng nhập $\leftrightarrow$ Nhận mã OTP $\leftrightarrow$ Đặt lại mật khẩu. Tự động điền mã OTP mẫu giúp thao tác kiểm thử trực quan và thuận tiện.


---

### [KI-20] Quản Trị Phân Quyền An Toàn: Nâng Quyền Vai Trò, Khóa/Mở Khóa Tức Thì và Đồng Bộ Hồ Sơ Liên Kết
- **Bối cảnh nghiệp vụ:**
  - Quản trị viên (Admin) cần giám sát và điều hành toàn bộ người dùng trong trung tâm: khóa tài khoản khi có nghi vấn bảo mật hoặc nghỉ việc/học, mở khóa ngay lập tức khi tài khoản bị khóa tạm thời do nhập sai quá 5 lần, nâng/hạ quyền vai trò (Role Elevation), và cấp lại mật khẩu an toàn.
  - Vấn đề an toàn thông tin (Security & Privacy): Tuyệt đối không cho phép xem mật khẩu thô của người dùng (tuân thủ nguyên tắc Zero-Knowledge, tiêu chuẩn NIST SP 800-63B và OWASP). Mật khẩu chỉ được phép băm một chiều an toàn bằng Bcrypt; việc hỗ trợ người dùng quên mật khẩu được giải quyết qua tính năng **Admin Reset Password**.
- **Giải pháp Kiến trúc Backend (RBAC & Profile Synchronization):**
  1. *Phân quyền Nghiêm ngặt (Strict Admin-Only RBAC):*
     - Endpoint `PATCH /api/v1/accounts/{user_id}/role`: Chỉ có `RoleEnum.ADMIN` mới có quyền thực thi. Nhân viên học vụ hay bất kỳ ai khác cố tình gọi API sẽ bị từ chối với lỗi `HTTP 403 Forbidden`.
     - Endpoint `PATCH /api/v1/accounts/{user_id}/toggle-lock`: Admin có quyền đảo trạng thái tài khoản. Nếu đang bị khóa (bởi Admin hoặc do nhập sai 5 lần), hệ thống tự động reset `is_active = True`, `locked_until = None`, `failed_login_attempts = 0`. Nếu đang hoạt động, hệ thống khóa lại `is_active = False`.
     - Ngăn ngừa lỗi vận hành nghiêm trọng: Admin không thể tự khóa tài khoản của chính mình và không thể tự hạ quyền nếu mình là Quản trị viên duy nhất trong hệ thống.
  2. *Đồng bộ Hồ sơ Liên kết Tự động (Automatic Profile Synchronization):*
     - Trong mô hình dữ liệu quan hệ, bảng `teachers` và `students` có khóa ngoại trỏ tới `users.id`.
     - Khi nâng quyền hoặc chuyển đổi vai trò sang `TEACHER` hoặc `STUDENT`, hệ thống tự động kiểm tra và khởi tạo bản ghi `Teacher` profile (mã `GV...`) hoặc `Student` profile (mã `HV...`) nếu chưa có, ngăn chặn triệt để lỗi ngoại lệ khóa ngoại (`ForeignKeyViolation`) khi lớp học hoặc sổ điểm tham chiếu tới người dùng này.
  3. *Admin Cấp lại Mật khẩu (Admin Reset Password):*
     - Endpoint `POST /api/v1/accounts/{user_id}/reset-password`: Cho phép Admin đặt mật khẩu mới (tối thiểu 6 ký tự) cho người dùng gặp sự cố. Hệ thống băm Bcrypt mật khẩu mới và tự động mở khóa tài khoản.
- **Trải nghiệm Giao diện Quản trị (`AccountsView.jsx`):**
  - Bổ sung 4 thẻ KPI thống kê tức thì: Tổng tài khoản, Đang hoạt động, Đang bị khóa/tạm dừng, Số lượng Quản trị & Học vụ.
  - Bộ lọc kép đa chiều: Lọc tìm kiếm theo từ khóa + Lọc theo Vai trò + Lọc theo Trạng thái (Hoạt động / Bị khóa).
  - Modal Nâng quyền vai trò trực quan với mô tả trách nhiệm rõ ràng cho từng vai trò (`ADMIN`, `ACADEMIC_STAFF`, `TEACHER`, `STUDENT`, `PARENT`).
  - Modal Cấp lại mật khẩu tích hợp bộ sinh mật khẩu ngẫu nhiên an toàn một chạm và nút sao chép Clipboard.


---

### [KI-21] Phân Loại Phản Hồi Lỗi Xác Thực Đa Tầng & Cơ Chế Tự Đăng Ký Tài Khoản (Self-Registration)
- **Bối cảnh nghiệp vụ:**
  - Trải nghiệm đăng nhập truyền thống thường chỉ trả về thông báo chung chung *"Tên đăng nhập hoặc mật khẩu không chính xác"*. Điều này gây khó khăn lớn cho người dùng khi không biết nguyên nhân thật sự (chưa có tài khoản, gõ nhầm mật khẩu, tài khoản bị Admin khóa hay tài khoản đã bị xóa).
  - Người dùng mới (Học viên, Phụ huynh) cần có khả năng tự đăng ký tài khoản tham gia học tập mà không cần chờ Admin tạo thủ công.
- **Giải pháp Kiến trúc Backend (Detailed Authentication Error Differentiation):**
  1. *Quy trình Kiểm tra 5 Tầng Phân Biệt (`AuthService.authenticate_user`):*
     - **Tầng 1 (Tồn tại):** Tìm tài khoản theo username hoặc email trong toàn bộ cơ sở dữ liệu (kể cả bản ghi `is_deleted`). Nếu không tìm thấy $
ightarrow$ Báo lỗi *"Tài khoản không tồn tại trong hệ thống. Vui lòng kiểm tra lại thông tin hoặc đăng ký tài khoản mới."*
     - **Tầng 2 (Đã xóa):** Nếu `user.is_deleted == True` $
ightarrow$ Báo lỗi *"Tài khoản này đã bị xóa khỏi hệ thống. Vui lòng liên hệ ban quản trị để được hỗ trợ."*
     - **Tầng 3 (Khóa bởi Admin):** Nếu `user.is_active == False` $
ightarrow$ Báo lỗi *"Tài khoản của bạn đã bị Quản trị viên khóa hoặc vô hiệu hóa. Vui lòng liên hệ ban quản trị để được hỗ trợ."*
     - **Tầng 4 (Khóa tạm thời 15p):** Nếu `user.locked_until > now` $
ightarrow$ Báo lỗi *"Tài khoản của bạn đã bị khóa tạm thời do nhập sai mật khẩu quá 5 lần. Vui lòng thử lại sau X phút..."*
     - **Tầng 5 (Sai mật khẩu):** So khớp Bcrypt. Nếu sai $
ightarrow$ Tăng số lần sai và báo lỗi *"Mật khẩu không chính xác. Bạn còn {5 - attempts} lần thử trước khi tài khoản bị khóa tạm thời."*
  2. *Quy trình Tự Đăng Ký Tài Khoản (`POST /api/v1/auth/register`):*
     - Cho phép tự đăng ký với vai trò `STUDENT` hoặc `PARENT`.
     - Tự động chuẩn hóa `username` và `email` (lowercase, trim).
     - Ràng buộc độ dài mật khẩu $\ge 6$ ký tự, băm Bcrypt an toàn.
     - Tự động khởi tạo `Student` profile (mã `HV...`) nếu đăng ký học viên.
     - Trả về ngay lập tức JWT `TokenResponse` để người dùng được đăng nhập thẳng vào hệ thống mà không cần thêm thao tác.
- **Trải nghiệm Giao diện Frontend (`LoginView.jsx`):**
  - Khối hiển thị lỗi có icon chuyên biệt theo từng loại: `UserX` (Không tồn tại), `Trash2` (Đã bị xóa), `Lock` (Khóa bởi Admin), `ShieldAlert` (Khóa tạm thời), `AlertTriangle` (Sai mật khẩu).
  - Tích hợp nút hành động ngữ cảnh (Contextual Actions): Nút *"Đăng ký tài khoản mới ngay"* xuất hiện ngay trong thẻ lỗi nếu tài khoản chưa có trong hệ thống.


---

### [KI-22] Kiến Trúc Quản Lý Ảnh Đại Diện & Đồng Bộ Hồ Sơ Người Dùng Đa Phân Hệ (Avatar & Profile Management)
- **Bối cảnh nghiệp vụ:**
  - Người dùng thuộc 5 phân quyền (`ADMIN`, `ACADEMIC_STAFF`, `TEACHER`, `STUDENT`, `PARENT`) có nhu cầu định danh trực quan qua ảnh đại diện cá nhân trên toàn bộ giao diện (Thanh điều hướng Navbar, Danh sách tài khoản, Bảng điểm, Lớp học).
  - Yêu cầu cung cấp trải nghiệm linh hoạt: cho phép tải ảnh từ máy tính (PNG/JPG/WEBP), chọn từ bộ sưu tập avatar mẫu (DiceBear presets), nhập URL trực tiếp, hoặc gỡ bỏ ảnh về chữ cái viết tắt mặc định.
- **Giải pháp Kiến trúc Backend (FastAPI Static Serving & File Upload Security):**
  1. *Lưu trữ Tệp Tĩnh (Static Files Directory):*
     - Tạo thư mục `backend/uploads/avatars` và mount tĩnh qua `app.mount("/uploads", StaticFiles(directory="backend/uploads"), name="uploads")`.
     - URL sinh ra có dạng `/uploads/avatars/{filename}` được phục vụ trực tiếp với độ trễ thấp và hỗ trợ cache trình duyệt.
  2. *Kiểm soát An toàn Tệp Tải Lên (File Upload Validation):*
     - Giới hạn kích thước tệp <= 5MB để tránh tấn công cạn kiệt tài nguyên đĩa (Disk Flooding).
     - Kiểm duyệt định dạng đuôi file (`.jpg`, `.jpeg`, `.png`, `.webp`) và kiểm tra content type ảnh hợp lệ.
     - Sử dụng `uuid.uuid4().hex` để đặt tên file, ngăn chặn triệt để tấn công Path Traversal hoặc ghi đè file có sẵn.
  3. *Thứ tự Định tuyến FastAPI (Routing Precedence Gotcha):*
     - **Vấn đề gặp phải:** Trong `accounts/router.py`, nếu khai báo `/{user_id}` trước `/me`, khi người dùng gửi request `GET /api/v1/accounts/me`, FastAPI sẽ cố ép chuỗi `"me"` thành kiểu số `int` của `user_id` và trả về lỗi `422 Unprocessable Entity`.
     - **Giải pháp:** Đặt toàn bộ các route đặc tả cá nhân (`/me`, `/me/avatar`, `/me/avatar/upload`) lên trước các route tham số hóa `/{user_id}`.
- **Giải pháp Kiến trúc Frontend (React 19 Context Synchronization & Modal UI):**
  1. *Đồng bộ Toàn cục qua AuthContext (`AuthContext.jsx`):*
     - Bổ sung `avatar_url` vào state `user` và lưu trữ trong `localStorage`.
     - Cung cấp hàm `updateUserProfile` và `refreshUser` để khi người dùng đổi avatar hoặc thông tin cá nhân trong modal, thanh `Navbar` và các view phụ thuộc lập tức cập nhật lại mà không cần tải lại trang.
  2. *Modal Quản lý Hồ sơ 3 Tab (`ProfileModal.jsx`):*
     - **Tab 1 - Đổi ảnh đại diện:** Hỗ trợ 4 chế độ: Tải tệp lên kèm vùng kéo thả trực quan, Chọn nhanh 8 mẫu Preset đồ họa ngộ nghĩnh, Nhập liên kết ảnh trực tiếp, và Nút Xóa ảnh. Có khung xem trước (Live Preview) tức thì.
     - **Tab 2 - Thông tin cá nhân:** Cập nhật họ tên, email, số điện thoại và xem vai trò được gắn màu badge chuyên biệt.
     - **Tab 3 - Đổi mật khẩu:** Xác thực mật khẩu cũ và đặt mật khẩu mới ngay trong phiên làm việc.
  3. *Tự Động Fallback Chữ Cái Viết Tắt (Initial Fallback UX):*
     - Khi `avatar_url` bị rỗng hoặc tải lỗi (`onError`), component tự động chuyển đổi sang vòng tròn màu gradient hiển thị chữ cái đầu tiên viết hoa của `full_name` hoặc `username`, đảm bảo giao diện luôn mượt mà và không bao giờ bị vỡ layout ảnh.
