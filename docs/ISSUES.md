# 📋 BỘ 11 ISSUES NGHIỆP VỤ CỐT LÕI (CORE BUSINESS ISSUES)
## Dự án: Hệ thống Web Quản lý Trung tâm Ngoại ngữ (SMART-EDU LMS)
### Phân loại theo 11 Bounded Contexts & 82 Chức năng nghiệp vụ (FR-01 -> FR-82)

Tài liệu này định nghĩa chi tiết **11 Issues nghiệp vụ cốt lõi** phục vụ đồ án môn học Phân tích Thiết kế Hướng đối tượng (OOAD) và quản lý tiến độ dự án trên GitHub / Jira.

---

## 📌 BẢNG TỔNG HỢP 11 ISSUES NGHIỆP VỤ

| Issue # | Tên phân hệ nghiệp vụ | Phạm vi FRs | Vai trò chính tác động | Tệp Frontend & Backend tương ứng |
| :---: | :--- | :---: | :--- | :--- |
| **#1** | **Xác thực, Cấp quyền JWT & Phân quyền 5 Roles** | FR-01 $\rightarrow$ FR-06 | Tất cả 5 vai trò | `LoginView.jsx`, `app/modules/auth/` |
| **#2** | **Quản trị Tài khoản, Nâng quyền & Khóa bảo vệ** | FR-07 $\rightarrow$ FR-10 | Admin, Academic Staff | `AccountsView.jsx`, `app/modules/accounts/` |
| **#3** | **Quản lý Chương trình đào tạo & Khóa học** | FR-11 $\rightarrow$ FR-17 | Admin, Staff, Student | `CoursesView.jsx`, `app/modules/courses/` |
| **#4** | **Quản lý Hồ sơ Học viên & Lịch sử học tập** | FR-18 $\rightarrow$ FR-24 | Admin, Staff, Student | `StudentsView.jsx`, `app/modules/students/` |
| **#5** | **Quản lý Hồ sơ Giảng viên & Chuyên môn giảng dạy** | FR-25 $\rightarrow$ FR-31 | Admin, Academic Staff | `TeachersView.jsx`, `app/modules/teachers/` |
| **#6** | **Quản lý Mở lớp học, Sĩ số & Trạng thái tuyển sinh** | FR-32 $\rightarrow$ FR-41 | Admin, Staff, Student | `ClassesView.jsx`, `app/modules/classes/` |
| **#7** | **Quản lý Phòng học, Sức chứa & Tình trạng thiết bị** | FR-42 $\rightarrow$ FR-49 | Admin, Academic Staff | `ClassroomsView.jsx`, `app/modules/classrooms/` |
| **#8** | **Quy trình Đăng ký lớp học & Xét duyệt ghi danh** | FR-50 $\rightarrow$ FR-60 | Student, Staff, Admin | `EnrollmentsView.jsx`, `app/modules/enrollments/` |
| **#9** | **Thời khóa biểu ma trận tuần & Phát hiện xung đột lịch** | FR-61 $\rightarrow$ FR-68 | Staff, Teacher, Student | `SchedulesView.jsx`, `app/modules/schedules/` |
| **#10** | **Quản lý Điểm số trọng số & Khóa bảng điểm chính thức** | FR-69 $\rightarrow$ FR-77 | Teacher, Staff, Student | `GradesView.jsx`, `app/modules/grades/` |
| **#11** | **Chuyển khóa học, Lộ trình đào tạo & Giám hộ Phụ huynh** | FR-78 $\rightarrow$ FR-82 | Parent, Student, Staff | `ProgressionParentView.jsx`, `app/modules/progression_parent/` |

---

## 🔍 CHI TIẾT 11 ISSUES NGHIỆP VỤ

### [Issue #1] Hệ thống Xác thực, Quản lý Phiên Đăng nhập & Phân quyền RBAC 5 Vai trò
- **Labels:** `epic`, `security`, `authentication`, `backend`, `frontend`
- **Mã chức năng:** `FR-01` đến `FR-06`
- **Mô tả nghiệp vụ:**
  - Cung cấp cơ chế đăng nhập an toàn bằng Username/Email và Password băm `bcrypt`.
  - Phân quyền chặt chẽ 5 vai trò (`ADMIN`, `ACADEMIC_STAFF`, `TEACHER`, `STUDENT`, `PARENT`) thông qua JWT Bearer Token.
  - Tự động khóa tài khoản tạm thời 15 phút nếu nhập sai mật khẩu quá 5 lần liên tiếp.
  - Cung cấp tính năng Quên mật khẩu & Đặt lại mật khẩu an toàn bằng mã OTP xác thực 6 số.
  - Hỗ trợ học viên mới tự đăng ký tài khoản (Self-Registration) với phân quyền mặc định là `STUDENT`.
- **Tiêu chí nghiệm thu (Acceptance Criteria):**
  - [x] Đăng nhập đúng cấp Access Token JWT (thời hạn 24h), tự động điều hướng về đúng Dashboard của vai trò.
  - [x] Đăng nhập sai 1-4 lần: hiển thị cảnh báo số lần thử còn lại.
  - [x] Đăng nhập sai lần thứ 5: tài khoản bị khóa 15 phút, từ chối mọi yêu cầu đăng nhập tiếp theo.
  - [x] Yêu cầu OTP gửi mã ngẫu nhiên 6 số, mã chỉ dùng được 1 lần và hết hạn sau 15 phút.
  - [x] Đăng xuất tài khoản xóa bỏ toàn bộ Token lưu trữ tại trình duyệt và chuyển về màn hình đăng nhập.
- **API Endpoints chính:**
  - `POST /api/v1/auth/login` (OAuth2 Password Request Form)
  - `POST /api/v1/auth/register` (Đăng ký tài khoản học viên)
  - `POST /api/v1/auth/forgot-password` (Yêu cầu mã OTP khôi phục)
  - `POST /api/v1/auth/reset-password-otp` (Xác thực OTP & Đặt lại mật khẩu)
  - `GET /api/v1/auth/me` (Lấy thông tin phiên làm việc hiện tại)

---

### [Issue #2] Quản trị Tài khoản Người dùng, Nâng quyền Vai trò & Quản lý Khóa tài khoản
- **Labels:** `epic`, `user-management`, `admin`, `backend`, `frontend`
- **Mã chức năng:** `FR-07` đến `FR-10`
- **Mô tả nghiệp vụ:**
  - Dành riêng cho Quản trị viên (`ADMIN`) và Nhân viên học vụ (`ACADEMIC_STAFF`).
  - Quản lý danh sách toàn bộ tài khoản trong hệ thống với bộ lọc theo vai trò và trạng thái.
  - Cho phép Admin nâng quyền vai trò cho người dùng (ví dụ: `STUDENT` lên `TEACHER` hoặc `ACADEMIC_STAFF`), tự động khởi tạo hồ sơ nghiệp vụ tương ứng.
  - Cho phép Admin thực hiện Khóa / Mở khóa tài khoản thủ công tức thì.
  - Hỗ trợ đổi mật khẩu khẩn cấp cho bất kỳ người dùng nào khi có yêu cầu hỗ trợ kỹ thuật.
- **Tiêu chí nghiệm thu:**
  - [x] Chỉ tài khoản có vai trò `ADMIN` mới có quyền thực hiện nâng quyền và khóa tài khoản người dùng khác.
  - [x] Nhân viên học vụ (`ACADEMIC_STAFF`) bị từ chối với mã lỗi `403 Forbidden` nếu cố ý nâng quyền vai trò.
  - [x] Tài khoản khi bị khóa: nếu đang đăng nhập sẽ bị từ chối gọi API, nếu đăng nhập mới sẽ nhận thông báo lỗi rõ ràng.
  - [x] Khi nâng quyền từ `STUDENT` lên `TEACHER`, hệ thống tự động sinh mã giáo viên (`GVxxxx`) và hồ sơ giảng dạy.
- **API Endpoints chính:**
  - `GET /api/v1/accounts/` (Danh sách tài khoản có tìm kiếm & lọc)
  - `POST /api/v1/accounts/` (Tạo tài khoản mới thủ công)
  - `PUT /api/v1/accounts/{id}/role` (Nâng cấp vai trò người dùng)
  - `POST /api/v1/accounts/{id}/toggle-lock` (Khóa / Mở khóa tài khoản)
  - `POST /api/v1/accounts/{id}/reset-password` (Admin đổi mật khẩu cho người dùng)

---

### [Issue #3] Quản lý Danh mục Chương trình Đào tạo & Khóa học Ngoại ngữ
- **Labels:** `epic`, `courses`, `academic`, `backend`, `frontend`
- **Mã chức năng:** `FR-11` đến `FR-17`
- **Mô tả nghiệp vụ:**
  - Quản lý toàn bộ danh mục khóa học (IELTS, TOEIC, Giao tiếp, Tiếng Anh trẻ em...).
  - Lưu trữ chi tiết: Mã khóa học, Tên khóa học, Mô tả, Chuẩn đầu ra (`target_level`), Thời lượng học (`duration_weeks`), Mức học phí chuẩn (`fee`) và Trạng thái kích hoạt.
  - Học viên xem danh sách các khóa học công khai, tìm kiếm theo tên hoặc lọc theo chuẩn đầu ra.
  - Admin & Nhân viên học vụ có toàn quyền thêm, cập nhật thông tin và điều chỉnh mức học phí.
- **Tiêu chí nghiệm thu:**
  - [x] Mã khóa học là duy nhất trong toàn hệ thống (Unique Constraint).
  - [x] Học viên đăng nhập chỉ thấy các khóa học đang hoạt động (`is_active = True`).
  - [x] Nhân viên học vụ và Admin có thể kích hoạt hoặc tạm ẩn khóa học mà không làm mất lịch sử các lớp đã học.
- **API Endpoints chính:**
  - `GET /api/v1/courses/` (Danh sách khóa học có tìm kiếm & lọc trạng thái)
  - `POST /api/v1/courses/` (Thêm khóa học mới)
  - `PUT /api/v1/courses/{id}` (Cập nhật thông tin khóa học)
  - `DELETE /api/v1/courses/{id}` (Xóa mềm khóa học)

---

### [Issue #4] Quản lý Hồ sơ Học viên & Tra cứu Lịch sử Đào tạo
- **Labels:** `epic`, `students`, `profiles`, `backend`, `frontend`
- **Mã chức năng:** `FR-18` đến `FR-24`
- **Mô tả nghiệp vụ:**
  - Quản lý hồ sơ định danh học viên: Mã số học viên (`student_code` theo chuẩn format `YY-XXXXX`), ngày sinh, địa chỉ, số điện thoại, tình trạng học phí.
  - Lưu trữ và tra cứu lịch sử đào tạo toàn diện: Các lớp đã từng đăng ký, kết quả hoàn thành và điểm số tích lũy.
  - Học viên có quyền tra cứu hồ sơ và lịch sử học tập của chính mình.
  - Học vụ và Admin quản lý, cập nhật thông tin và theo dõi tình trạng học viên (Đang học, Bảo lưu, Đã tốt nghiệp).
- **Tiêu chí nghiệm thu:**
  - [x] Mỗi học viên liên kết 1-1 với một tài khoản người dùng (`User`).
  - [x] Mã số học viên tự động chuẩn hóa và không trùng lặp.
  - [x] API tra cứu lịch sử `/students/{id}/learning-history` trả về đầy đủ các lớp, giảng viên phụ trách và kết quả đạt chuẩn.
- **API Endpoints chính:**
  - `GET /api/v1/students/` (Danh sách hồ sơ học viên)
  - `GET /api/v1/students/{id}` (Chi tiết hồ sơ học viên)
  - `GET /api/v1/students/{id}/learning-history` (Lịch sử học tập chi tiết)
  - `PUT /api/v1/students/{id}` (Cập nhật thông tin học viên)

---

### [Issue #5] Quản lý Hồ sơ Giảng viên, Học vị & Phân công Chuyên môn
- **Labels:** `epic`, `teachers`, `academic`, `backend`, `frontend`
- **Mã chức năng:** `FR-25` đến `FR-31`
- **Mô tả nghiệp vụ:**
  - Quản lý thông tin giảng viên cơ hữu và thỉnh giảng của trung tâm.
  - Lưu trữ: Mã giáo viên (`GVxxxx`), Học vị (Cử nhân, Thạc sĩ, Tiến sĩ), Chuyên môn chính (IELTS 8.0, TOEIC 900, Ngữ pháp học thuật...) và Trạng thái giảng dạy (`ACTIVE`, `ON_LEAVE`).
  - Giúp nhân viên học vụ dễ dàng tra cứu, lựa chọn giảng viên phù hợp khi phân công mở lớp hoặc xếp lịch thời khóa biểu.
- **Tiêu chí nghiệm thu:**
  - [x] Giảng viên liên kết 1-1 với tài khoản người dùng có quyền `TEACHER`.
  - [x] Tích hợp bộ lọc giảng viên theo chuyên môn (IELTS / TOEIC) phục vụ điều phối giảng dạy.
  - [x] Thông tin giảng viên hiển thị rõ ràng trên thời khóa biểu và giao diện danh sách lớp học.
- **API Endpoints chính:**
  - `GET /api/v1/teachers/` (Danh sách giảng viên)
  - `GET /api/v1/teachers/{id}` (Chi tiết hồ sơ giảng viên)
  - `POST /api/v1/teachers/` (Thêm mới giảng viên)
  - `PUT /api/v1/teachers/{id}` (Cập nhật thông tin chuyên môn)

---

### [Issue #6] Quản lý Mở Lớp học, Phân bổ Sĩ số & Giám sát Tuyển sinh
- **Labels:** `epic`, `classes`, `academic`, `backend`, `frontend`
- **Mã chức năng:** `FR-32` đến `FR-41`
- **Mô tả nghiệp vụ:**
  - Quản lý các lớp học mở theo từng khóa đào tạo (ví dụ: `IELTS-65-K26A`).
  - Thiết lập: Khóa học liên kết, Giảng viên chủ nhiệm, Sức chứa tối đa (`max_capacity`), Sĩ số hiện tại (`current_enrolled`), Ngày khai giảng và Ngày bế giảng.
  - Quản lý vòng đời trạng thái lớp: `OPEN_FOR_ENROLLMENT` (Đang tuyển sinh), `IN_PROGRESS` (Đang học), `COMPLETED` (Đã kết thúc), `CANCELLED` (Đã hủy).
  - Tự động khóa đăng ký khi lớp học đã đạt đủ sĩ số tối đa.
- **Tiêu chí nghiệm thu:**
  - [x] Sĩ số hiện tại tự động cập nhật khi học vụ duyệt đơn đăng ký hoặc xóa học viên khỏi lớp.
  - [x] Không cho phép ghi danh vượt quá `max_capacity`.
  - [x] Học viên chỉ xem được danh sách lớp đang mở đăng ký hoặc lớp mình đang học (bảo mật danh sách lớp đối với học viên khác).
- **API Endpoints chính:**
  - `GET /api/v1/classes/` (Danh sách lớp học kèm bộ lọc trạng thái và khóa học)
  - `POST /api/v1/classes/` (Khởi tạo lớp học mới)
  - `PUT /api/v1/classes/{id}` (Cập nhật lớp học / giảng viên phụ trách)
  - `GET /api/v1/classes/{id}/students` (Danh sách học viên trong lớp - Chỉ dành cho Giáo viên của lớp, Staff và Admin)

---

### [Issue #7] Quản lý Danh mục Phòng học, Cơ sở vật chất & Sức chứa
- **Labels:** `epic`, `classrooms`, `facilities`, `backend`, `frontend`
- **Mã chức năng:** `FR-42` đến `FR-49`
- **Mô tả nghiệp vụ:**
  - Quản lý hệ thống cơ sở hạ tầng phòng học: Phòng lý thuyết, phòng máy (Lab), hội trường...
  - Lưu trữ: Mã phòng (`P.101`, `LAB.201`), Tòa nhà cơ sở (`Tòa A`, `Tòa B`), Sức chứa ghế ngồi (`capacity`), Trạng thái khả dụng (`AVAILABLE`, `MAINTENANCE`).
  - Hỗ trợ học vụ chọn phòng học phù hợp với quy mô sĩ số lớp và tránh xếp trùng phòng học.
- **Tiêu chí nghiệm thu:**
  - [x] Mã phòng học là duy nhất.
  - [x] Phòng học ở trạng thái bảo trì (`MAINTENANCE`) bị từ chối khi xếp lịch thời khóa biểu.
  - [x] Giao diện trực quan dạng lưới (Grid Cards) thể hiện đầy đủ trạng thái và thông số phòng.
- **API Endpoints chính:**
  - `GET /api/v1/classrooms/` (Danh sách phòng học)
  - `POST /api/v1/classrooms/` (Thêm phòng học mới)
  - `PUT /api/v1/classrooms/{id}` (Cập nhật thông tin / bảo trì phòng)
  - `DELETE /api/v1/classrooms/{id}` (Xóa phòng học nếu chưa có lịch học liên kết)

---

### [Issue #8] Quy trình Đăng ký Nhập học, Xét duyệt Ghi danh & Quản lý Đơn
- **Labels:** `epic`, `enrollments`, `workflow`, `backend`, `frontend`
- **Mã chức năng:** `FR-50` đến `FR-60`
- **Mô tả nghiệp vụ:**
  - Cho phép học viên gửi yêu cầu đăng ký vào các lớp học đang mở tuyển sinh.
  - Học vụ / Admin xem danh sách đơn đăng ký chờ duyệt (`PENDING`), kiểm tra hồ sơ, thông tin học phí và quyết định Phê duyệt (`APPROVED`) hoặc Từ chối (`REJECTED`) kèm lý do giải thích.
  - Khi phê duyệt: Tự động ghi danh học viên vào bảng `class_students` và tăng `current_enrolled` của lớp học.
  - Học viên có quyền tự hủy đơn đăng ký khi đơn còn ở trạng thái chờ duyệt (`PENDING`). Khi đơn đã được duyệt (`APPROVED`), ngăn chặn học viên tự ý hủy đơn.
- **Tiêu chí nghiệm thu:**
  - [x] Mỗi học viên chỉ được gửi 1 đơn chờ duyệt cho một lớp học cụ thể (ngăn chặn duplicate requests).
  - [x] Khi lớp học đã đầy sĩ số (`current_enrolled >= max_capacity`), từ chối phê duyệt đơn và thông báo rõ ràng.
  - [x] Học viên hủy đơn thành công: trạng thái chuyển thành `CANCELLED`.
  - [x] Nếu học vụ từ chối đơn: bắt buộc phải nhập lý do phản hồi cho học viên.
- **API Endpoints chính:**
  - `GET /api/v1/enrollments/my-requests` (Học viên xem các đơn đăng ký của mình)
  - `GET /api/v1/enrollments/requests` (Học vụ xem toàn bộ đơn đăng ký trong hệ thống)
  - `POST /api/v1/enrollments/register` (Học viên gửi đơn đăng ký vào lớp)
  - `POST /api/v1/enrollments/requests/{id}/approve` (Học vụ phê duyệt đơn)
  - `POST /api/v1/enrollments/requests/{id}/reject` (Học vụ từ chối đơn kèm lý do)
  - `POST /api/v1/enrollments/requests/{id}/cancel` (Học viên tự hủy đơn)

---

### [Issue #9] Thời khóa biểu Ma trận Tuần & Thuật toán Phát hiện Xung đột Lịch Học
- **Labels:** `epic`, `schedules`, `algorithm`, `backend`, `frontend`
- **Mã chức năng:** `FR-61` đến `FR-68`
- **Mô tả nghiệp vụ:**
  - Quản lý lịch học chi tiết từng buổi: Ngày học (`session_date`), Ca học / Khung giờ (`start_time` - `end_time`), Phòng học, Giảng viên phụ trách và Lớp học.
  - **Thuật toán tự động phát hiện xung đột thời gian thực:**
    - Kiểm tra xung đột **phòng học**: Ngăn chặn 2 lớp học xếp cùng một phòng vào cùng thời điểm.
    - Kiểm tra xung đột **giảng viên**: Ngăn chặn 1 giáo viên bị xếp dạy 2 lớp khác nhau trong cùng khung giờ.
  - Cung cấp 2 chế độ hiển thị linh hoạt: **Bảng ma trận tuần (Weekly Matrix)** và **Danh sách tổng hợp (List View)**.
  - Tích hợp thanh tìm kiếm và 2 bộ lọc nhanh theo **"Giáo viên"** và **"Khóa học"** cho Admin và Staff.
  - Học viên và Giảng viên có chế độ xem lịch học cá nhân (`/schedules/personal`).
- **Tiêu chí nghiệm thu:**
  - [x] Endpoint kiểm tra xung đột `/schedules/check-conflict` trả về chi tiết lớp, phòng, giáo viên bị va chạm.
  - [x] Không cho phép lưu buổi học nếu tồn tại xung đột chưa được giải quyết.
  - [x] Cho phép chuyển đổi tuần trước / tuần sau và nhảy nhanh về tuần hiện tại ("Hôm nay").
- **API Endpoints chính:**
  - `GET /api/v1/schedules/` (Lấy toàn bộ lịch học - Admin/Staff)
  - `GET /api/v1/schedules/personal` (Lấy lịch học cá nhân của Giáo viên hoặc Học viên đang đăng nhập)
  - `POST /api/v1/schedules/` (Tạo buổi học mới có kiểm tra xung đột)
  - `POST /api/v1/schedules/check-conflict` (Kiểm tra va chạm lịch trước khi lưu)
  - `PUT /api/v1/schedules/{id}` (Điều chỉnh lịch học buổi cụ thể)
  - `DELETE /api/v1/schedules/{id}` (Xóa buổi học)

---

### [Issue #10] Quản lý Sổ điểm Trọng số, Xếp loại Học tập & Khóa Sổ điểm Chính thức
- **Labels:** `epic`, `grades`, `assessment`, `backend`, `frontend`
- **Mã chức năng:** `FR-69` đến `FR-77`
- **Mô tả nghiệp vụ:**
  - Quản lý sổ chấm điểm học tập theo công thức trọng số chuẩn:
    $$\text{Điểm tổng kết} = 0.2 \times \text{Chuyên cần} + 0.3 \times \text{Giữa kỳ} + 0.5 \times \text{Cuối kỳ}$$
  - Quy tắc xếp loại kết quả:
    - **ĐẠT (PASSED):** Điểm tổng kết $\ge 5.0$ **VÀ** Điểm cuối kỳ $\ge 4.0$.
    - **CHƯA ĐẠT (FAILED):** Điểm tổng kết $< 5.0$ hoặc Điểm cuối kỳ $< 4.0$.
  - Phân quyền nghiêm ngặt giữa Giảng viên và Quản trị:
    - **Giảng viên:** Nhập điểm, cập nhật điểm và thêm/xóa học viên trong sổ điểm lớp mình dạy.
    - **Học vụ / Admin:** Thực hiện thao tác **"Lưu & Khóa sổ điểm chính thức"** (`is_confirmed = True`) hoặc **"Mở khóa sổ điểm"** để giáo viên điều chỉnh.
  - Khi sổ điểm đã bị khóa chính thức, giáo viên không thể sửa điểm nhằm đảm bảo tính toàn vẹn kết quả đào tạo.
  - Học viên chỉ được xem bảng điểm môn học của chính mình.
- **Tiêu chí nghiệm thu:**
  - [x] Validation điểm số nghiêm ngặt trong thang điểm từ $0.0$ đến $10.0$.
  - [x] Admin và Staff bị cấm sửa điểm trực tiếp (chỉ giáo viên được nhập điểm).
  - [x] Khi `is_confirmed = True`, toàn bộ các ô nhập điểm chuyển sang chế độ chỉ đọc (Read-only).
  - [x] Học viên gọi `/grades/my-grades` chỉ trả về đúng danh sách điểm cá nhân của mình.
- **API Endpoints chính:**
  - `GET /api/v1/grades/class/{class_id}` (Xem sổ điểm lớp học)
  - `POST /api/v1/grades/class/{class_id}` (Giáo viên lưu điểm cả lớp theo lô)
  - `POST /api/v1/grades/class/{class_id}/confirm` (Học vụ khóa điểm chính thức)
  - `POST /api/v1/grades/class/{class_id}/unlock` (Học vụ mở khóa sổ điểm)
  - `GET /api/v1/grades/my-grades` (Học viên xem điểm cá nhân)
  - `POST /api/v1/grades/class/{class_id}/students` (Thêm học viên vào bảng điểm)
  - `DELETE /api/v1/grades/class/{class_id}/students/{student_id}` (Xóa học viên khỏi bảng điểm)

---

### [Issue #11] Quản lý Lộ trình Đào tạo, Điều kiện Tiên quyết Chuyển Khóa & Portal Phụ huynh
- **Labels:** `epic`, `progression`, `parents`, `backend`, `frontend`
- **Mã chức năng:** `FR-78` đến `FR-82`
- **Mô tả nghiệp vụ:**
  - **Kiểm soát điều kiện tiên quyết (Prerequisite Check):**
    - Học viên muốn đăng ký chuyển lên khóa học cao hơn (ví dụ: từ IELTS 6.5 lên IELTS 7.5+) bắt buộc phải có kết quả **ĐẠT (PASSED)** ở khóa học hiện tại và đã được khóa điểm chính thức.
  - **Quy trình chuyển khóa học (Course Transfer):**
    - Học viên / Phụ huynh nộp đơn đăng ký chuyển khóa học.
    - Học vụ kiểm tra điều kiện điểm và phê duyệt chuyển lớp mới.
  - **Cổng theo dõi dành cho Phụ huynh (Parent Portal):**
    - Thiết lập quan hệ liên kết giám hộ giữa tài khoản Phụ huynh và Con em (học viên).
    - Phụ huynh đăng nhập xem tổng quan: Lớp con đang học, Thời khóa biểu buổi học của con, Sổ điểm chi tiết từng môn và Lộ trình nâng khóa.
- **Tiêu chí nghiệm thu:**
  - [x] Hệ thống tự động từ chối đơn chuyển khóa nếu học viên chưa đạt chuẩn đầu ra khóa tiên quyết.
  - [x] Phụ huynh chỉ xem được dữ liệu của con em mà mình được gán giám hộ hợp lệ.
  - [x] Hỗ trợ phụ huynh có nhiều con em: chuyển đổi mượt mà giữa các hồ sơ con để theo dõi.
- **API Endpoints chính:**
  - `GET /api/v1/progression/wards` (Phụ huynh xem danh sách con em được giám hộ)
  - `GET /api/v1/progression/wards/{student_id}/grades` (Xem bảng điểm con em)
  - `GET /api/v1/progression/requests` (Danh sách yêu cầu chuyển khóa)
  - `POST /api/v1/progression/transfer` (Gửi yêu cầu đăng ký chuyển khóa)
  - `POST /api/v1/progression/requests/{id}/approve` (Học vụ phê duyệt đơn chuyển khóa)
  - `POST /api/v1/progression/requests/{id}/reject` (Học vụ từ chối đơn kèm lý do)

---

### 🚀 HƯỚNG DẪN SỬ DỤNG
Bạn có thể:
1. Sử dụng tài liệu này để đưa vào Báo cáo Đồ án môn học Phân tích Thiết kế Hướng đối tượng (**OOAD Document / SRS**).
2. Tạo trực tiếp các Issues trên GitHub theo danh sách tiêu đề và mô tả ở trên.
3. Liên kết các Pull Request hoặc Commit với từng mã Issue (ví dụ: `git commit -m "fix: #9 fix weekly timetable matrix and search filters"`).
