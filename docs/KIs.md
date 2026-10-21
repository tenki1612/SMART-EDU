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
  4. *Hỗ trợ trải nghiệm người dùng (UX):* Trên màn hình đăng nhập cung cấp danh sách tài khoản mẫu để người dùng bấm vào thì hệ thống **tự động điền (pre-fill)** `username` và `password` vào form, sau đó người dùng vẫn phải bấm **"Đăng nhập vào hệ thống"** để gửi request xác thực qua Backend API.

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
