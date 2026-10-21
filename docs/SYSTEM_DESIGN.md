# TÀI LIỆU THIẾT KẾ HỆ THỐNG TOÀN DIỆN (SYSTEM ARCHITECTURE & DESIGN SPECIFICATION)
## Hệ thống Web Quản lý Trung tâm Ngoại ngữ (SMART-EDU LMS)
### Áp dụng: Fullstack LMS Workflow &bull; Impeccable UI/UX (Operate Mode) &bull; Ponytail Pragmatism

Tài liệu này đóng vai trò là **Bản thiết kế kỹ thuật chuẩn (Blueprint)** của hệ thống, định hình toàn bộ cấu trúc kiến trúc, mô hình dữ liệu, tiêu chuẩn giao diện và quy trình tích hợp giữa **Frontend React (JavaScript JSX + Vite)** và **Backend Python (FastAPI + SQLAlchemy)**, hiện thực hóa đầy đủ 82 chức năng nghiệp vụ (FR-01 đến FR-82).

---

## 1. TRIẾT LÝ THIẾT KẾ & ÁP DỤNG CÁC KỸ NĂNG (SKILLS)

Hệ thống được thiết kế dựa trên sự giao thoa của 3 kỹ năng chuyên sâu:

```
+-----------------------------------------------------------------------------------+
|                           SMART-EDU LMS ARCHITECTURE                              |
+-----------------------------------------+-----------------------------------------+
|      BACKEND: Python (FastAPI)          |         FRONTEND: React (Vite)          |
|  [Skill: fullstack-lms-workflow]        |      [Skill: impeccable (Operate)]      |
|  - Modular Monolith (DDD-Lite)          |  - Design System & Design Tokens        |
|  - 11 Bounded Contexts độc lập          |  - Quét thông tin nhanh (Scanability)   |
|  - Single Source of Truth: Pydantic v2  |  - Non-blocking Toast Feedback          |
|  - RBAC 5 Roles Dependency Injection    |  - Tabular Numbers & Semantic Badges    |
+-----------------------------------------+-----------------------------------------+
|                               [Skill: ponytail]                                   |
|  - Kiến trúc tinh gọn (Zero Bloat), không cài cắm thư viện dư thừa                 |
|  - Tối ưu hiệu năng, phản hồi nhanh, dễ mở rộng, bảo trì dài hạn                  |
+-----------------------------------------------------------------------------------+
```

1. **Skill `fullstack-lms-workflow` (Kiến trúc & Nghiệp vụ đào tạo):**
   - Phân rã 82 yêu cầu chức năng thành 11 Bounded Contexts rõ ràng.
   - Thiết lập cấu trúc phân tầng 4 lớp trong từng module: `Router -> Schema -> Service -> Model`.
   - Chuẩn hóa 3 thuật toán nghiệp vụ cốt lõi: Phát hiện xung đột lịch thời gian thực, Tính điểm theo trọng số & Khóa điểm, Ràng buộc điều kiện tiên quyết chuyển khóa.
2. **Skill `impeccable` (Giao diện người dùng chuẩn Operate Mode):**
   - Hướng đến năng suất làm việc của người dùng (nhân viên học vụ, giảng viên, học viên, quản trị viên): Ưu tiên tính rõ ràng, độ tương phản chuẩn, khả năng đọc lướt (scanability) và cảm giác an tâm khi thao tác dữ liệu.
   - Chuẩn typography: `Plus Jakarta Sans` cho nội dung văn bản, `JetBrains Mono` cho mã định danh và số liệu.
   - Thẻ trạng thái thông minh (Semantic Status Badges) với chỉ báo chấm tròn (dot indicator).
3. **Skill `ponytail` (Tinh gọn & Thực tế):**
   - Không lạm dụng các state management cồng kềnh (Redux, MobX); sử dụng React Context thuần túy cho Auth và Toast.
   - Tận dụng SQLite Zero-config để hệ thống có thể chạy ngay sau khi clone mà không cần thiết lập database phức tạp, sẵn sàng chuyển đổi PostgreSQL qua 1 dòng config `.env`.

---

## 2. THIẾT KẾ KIẾN TRÚC BACKEND (PYTHON / FASTAPI)

### 2.1. Cấu trúc Thư mục Backend (Modular Monolith DDD-Lite)

```
d:\OOAD\backend\
├── app/
│   ├── api/
│   │   └── v1/
│   │       └── api.py                   # Điểm tập trung Router của cả 11 Bounded Contexts
│   ├── common/                          # Các lớp dùng chung toàn hệ thống
│   │   ├── base_model.py                # TimestampMixin (id, created_at, updated_at, is_deleted)
│   │   └── response.py                  # ApiResponse[T] (success, code, message, data)
│   ├── core/                            # Cấu hình hạt nhân & bảo mật
│   │   ├── config.py                    # Settings (Pydantic-Settings với fallback an toàn)
│   │   ├── database.py                  # SQLAlchemy engine & get_db dependency
│   │   ├── security.py                  # Bcrypt hashing & PyJWT token generator
│   │   └── permissions.py               # RBAC 5 roles dependency (require_roles)
│   ├── modules/                         # 11 Bounded Contexts (Độc lập & Tự bao hàm)
│   │   ├── auth/                        # FR-01 -> FR-04: Đăng nhập JWT, Profile
│   │   ├── accounts/                    # FR-05 -> FR-10: Quản lý Users, Đổi mật khẩu
│   │   ├── courses/                     # FR-11 -> FR-17: Khóa học & Chuẩn đầu ra
│   │   ├── students/                    # FR-18 -> FR-24: Hồ sơ & Lịch sử học viên
│   │   ├── teachers/                    # FR-25 -> FR-31: Hồ sơ & Lịch dạy giáo viên
│   │   ├── classes/                     # FR-32 -> FR-41: Lớp học & Quản lý sĩ số
│   │   ├── classrooms/                  # FR-42 -> FR-49: Phòng học & Tình trạng thiết bị
│   │   ├── enrollments/                 # FR-50 -> FR-60: Đăng ký & Xét duyệt nhập học
│   │   ├── schedules/                   # FR-61 -> FR-68: Lịch học & Thuật toán xung đột
│   │   ├── grades/                      # FR-69 -> FR-77: Điểm số, Trọng số & Khóa sổ
│   │   └── progression_parent/          # FR-78 -> FR-82: Lên khóa & Cổng phụ huynh
│   └── main.py                          # Khởi tạo FastAPI App, CORS, Lifespan
├── language_center.db                   # Database SQLite cục bộ (Zero config)
├── seed.py                              # Dữ liệu mẫu khởi tạo cho 5 vai trò
├── requirements.txt                     # Danh mục thư viện Python
└── test_api.py                          # Kịch bản kiểm thử API tự động
```

### 2.2. Luồng Xử lý 4 Tầng Phân lập trong Mỗi Module

Mỗi module trong `app/modules/<module_name>/` tuân thủ nghiêm ngặt 4 tầng:

```
[HTTP Request] 
      │
      ▼
┌──────────────┐
│  router.py   │  ── Tiếp nhận HTTP request, xác thực Bearer JWT & Phân quyền RBAC
└──────┬───────┘
      │ Validate DTO
      ▼
┌──────────────┐
│  schemas.py  │  ── Pydantic v2 Models: Base, Create, Update, Response (Nguồn chân lý)
└──────┬───────┘
      │ Gọi nghiệp vụ
      ▼
┌──────────────┐
│  service.py  │  ── Xử lý Business Logic, tính toán, kiểm tra ràng buộc & transaction
└──────┬───────┘
      │ Đọc / Ghi ORM
      ▼
┌──────────────┐
│  models.py   │  ── SQLAlchemy Table Model (kế thừa TimestampMixin & Soft Delete)
└──────────────┘
```

### 2.3. Ba Thuật toán Nghiệp vụ Cốt lõi

1. **Thuật toán Phát hiện Xung đột Lịch học (`schedules/conflict_checker.py`):**
   - Hai ca học chồng lấn khi và chỉ khi: `(start_A < end_B) AND (end_A > start_B)`.
   - Quét đồng thời trên cả 2 tài nguyên: `classroom_id` và `teacher_id` trong cùng `session_date`.
2. **Thuật toán Tính điểm & Xếp loại Tự động (`grades/calculator.py`):**
   - $\text{Total} = \text{round}(0.2 \times \text{Attendance} + 0.3 \times \text{Midterm} + 0.5 \times \text{Final}, 2)$
   - $\text{Status} = \text{PASSED} \iff (\text{Total} \ge 5.0) \land (\text{Final} \ge 4.0)$
   - Khóa điểm chính thức (`is_confirmed = True`) ngăn chặn sửa đổi điểm sau khi học vụ đã phê duyệt.
3. **Ràng buộc Chuyển tiếp Khóa học (`progression_parent/service.py`):**
   - Yêu cầu học viên phải có kết quả `PASSED` và `is_confirmed = True` ở khóa tiên quyết trước khi học vụ bấm nút xác nhận đủ điều kiện nâng khóa.

---

## 3. THIẾT KẾ KIẾN TRÚC FRONTEND (REACT / JAVASCRIPT JSX / VITE)

### 3.1. Cấu trúc Thư mục Frontend (Feature-Driven Architecture)

```
d:\OOAD\frontend\
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Navbar.jsx               # Header định danh, thông tin User, Nút Đăng xuất
│   │   │   └── Sidebar.jsx              # Menu điều hướng phân nhóm theo 5 chuyên mục
│   ├── context/
│   │   ├── AuthContext.jsx              # Quản lý phiên đăng nhập, JWT Token & User State
│   │   └── ToastContext.jsx             # Thông báo Toast nổi nhẹ nhàng (Non-blocking)
│   ├── services/
│   │   └── api.js                       # Axios instance + API client cho 82 endpoints
│   ├── types/
│   │   └── index.js                     # Constants & Enum references (ROLES, CLASS_STATUS)
│   ├── views/                           # 11 Views nghiệp vụ tương ứng 11 Bounded Contexts
│   │   ├── LoginView.jsx                # Đăng nhập chuẩn mật khẩu Bcrypt + Bảng tra cứu User
│   │   ├── AccountsView.jsx             # Quản lý tài khoản & Phân quyền 5 vai trò
│   │   ├── CoursesView.jsx              # Quản lý khóa học, học phí, chỉ tiêu đầu ra
│   │   ├── StudentsView.jsx             # Hồ sơ học viên, xem tiến trình học tập
│   │   ├── TeachersView.jsx             # Quản lý giáo viên & lịch giảng dạy
│   │   ├── ClassesView.jsx              # Quản lý lớp học & cảnh báo sĩ số
│   │   ├── ClassroomsView.jsx           # Quản lý phòng học & bảo trì
│   │   ├── EnrollmentsView.jsx          # Xét duyệt đăng ký lớp & nhập lý do từ chối
│   │   ├── SchedulesView.jsx            # Xếp lịch học & phát hiện xung đột phòng/giáo viên
│   │   ├── GradesView.jsx               # Bảng nhập điểm, tính điểm tổng kết & khóa sổ
│   │   ├── ProgressionParentView.jsx    # Cổng phụ huynh & xét chuyển khóa học
│   │   └── DashboardView.jsx            # Tổng quan trung tâm & thống kê nhanh
│   ├── App.jsx                          # Router điều hướng View theo State & Phân quyền
│   ├── main.jsx                         # Khởi tạo React 19 Root
│   └── index.css                        # Tailwind CSS v4 & Custom Utility classes
├── index.html                           # Điểm nạp module /src/main.jsx
├── package.json                         # Dependencies & Scripts ("build": "vite build")
└── vite.config.js                       # Cấu hình Vite bundler & Dev server
```

### 3.2. Tiêu chuẩn Thiết kế UI/UX theo Kỹ năng `impeccable` (Operate Mode)

| Yếu tố | Tiêu chuẩn thiết kế áp dụng | Lý do thiết kế (Rationale) |
|---|---|---|
| **Tone & Style** | Tối giản, hiện đại, màu sắc chủ đạo Indigo (`#4f46e5`) kết hợp Slate (`#0f172a`). | Tránh gây mỏi mắt cho nhân viên khi làm việc liên tục 8 tiếng với dữ liệu bảng biểu. |
| **Typography** | `Plus Jakarta Sans` cho Text; `JetBrains Mono` cho Code/Mã số; Sử dụng `tabular-nums`. | Đảm bảo các con số ở cột điểm, học phí, sĩ số luôn thẳng hàng hoàn hảo khi quét mắt qua bảng. |
| **Status Badges** | Chấm màu tín hiệu (`w-1.5 h-1.5 rounded-full`) đi kèm nền nhạt và viền mỏng (`border`). | Phân biệt tức thì: `Xanh lá` = Thành công/Đạt, `Vàng hổ phách` = Đang chờ duyệt, `Đỏ hồng` = Từ chối/Chưa đạt. |
| **Bảng dữ liệu** | Header chữ in hoa nhỏ (`text-[11px] uppercase tracking-wider`), border mỏng, zebra striping nhẹ. | Giúp mắt người vận hành quét nhanh qua hàng trăm bản ghi mà không bị nhầm dòng. |
| **Phản hồi người dùng** | Sử dụng `ToastContext` nổi ở góc phải dưới (`fixed bottom-5 right-5`), tự ẩn sau 4 giây. | Tuyệt đối **không dùng `alert()` trình duyệt** làm chặn UI thread. Thao tác mượt mà, liên tục. |
| **Bảo mật Đăng nhập** | Form nhập liệu bắt buộc `username` + `password`, băm Bcrypt, gỡ bỏ toàn bộ bypass. | Đảm bảo tiêu chuẩn an ninh thông tin của môi trường sản xuất (Production). |

---

## 4. QUY TRÌNH KẾT NỐI VÀ BẢO ĐẢM TYPE-SAFETY (END-TO-END)

```
┌─────────────────────────────────┐                    ┌─────────────────────────────────┐
│     BACKEND (FastAPI / Python)   │                    │    FRONTEND (React / TypeScript) │
├─────────────────────────────────┤                    ├─────────────────────────────────┤
│ class CourseResponse(BaseModel):│                    │ export interface Course {       │
│     id: int                     │  Sync Contract 1-1 │   id: number;                   │
│     code: str                   │ ══════════════════>│   code: string;                 │
│     title: str                  │                    │   title: string;                │
│     target_level: str           │                    │   target_level: string;         │
│     duration_weeks: int         │                    │   duration_weeks: number;       │
│     fee: float                  │                    │   fee: number;                  │
│     is_active: bool             │                    │   is_active: boolean;           │
└─────────────────────────────────┘                    └─────────────────────────────────┘
```

- **Interceptor tự động:** `client.ts` tự động đính kèm `Authorization: Bearer <token>` vào mọi HTTP request sau khi đăng nhập thành công.
- **Xử lý lỗi 401 tự động:** Khi token hết hạn hoặc không hợp lệ, interceptor tự động xóa token và chuyển hướng người dùng về màn hình Đăng nhập một cách êm ái.

---

## 5. KẾT LUẬN & HƯỚNG DẪN BẢO TRÌ

Bản thiết kế này đã được hiện thực hóa đầy đủ trong mã nguồn hiện tại của dự án:
- Backend: Khởi chạy bằng lệnh `uvicorn app.main:app --reload` tại thư mục `backend/`.
- Frontend: Khởi chạy bằng lệnh `npm run dev` tại thư mục `frontend/`.
- Tài liệu CSDL chi tiết: [docs/DATABASE_DESIGN.md](file:///d:/OOAD/docs/DATABASE_DESIGN.md).
- Bài học kỹ thuật & Gotchas: [docs/KIs.md](file:///d:/OOAD/docs/KIs.md).
- Quy trình phát triển chuẩn: [.agents/skills/fullstack-lms-workflow/SKILL.md](file:///d:/OOAD/.agents/skills/fullstack-lms-workflow/SKILL.md).

