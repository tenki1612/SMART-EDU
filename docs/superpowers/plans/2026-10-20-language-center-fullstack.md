ok bây # Language Center Management Web System (Hệ thống Quản lý Trung tâm Ngoại ngữ) Implementation Plan

> **Trạng thái thực thi:** ✅ ĐÃ HOÀN THÀNH TOÀN DIỆN (100% IMPLEMENTED & VERIFIED)

## Overview
Xây dựng toàn diện mã nguồn Backend (FastAPI, SQLAlchemy, Pydantic v2, SQLite, JWT RBAC) và Frontend (React, TypeScript, Vite, Tailwind CSS, Lucide icons) phục vụ 82 chức năng nghiệp vụ thuộc 11 nhóm cho 5 nhóm đối tượng (Admin, Academic Staff, Teacher, Student, Parent).

## Tasks Decomposition & Completion Status

### Phase 1: Backend Foundation & Core Architecture
- [x] Task 1.1: Khởi tạo cấu trúc Backend, `core/` (config, database, security, permissions, exceptions), `common/` (base models, response wrappers, pagination).
  - *Files:* `backend/app/core/{config,database,security,permissions,exceptions}.py`, `backend/app/common/{base_model,response}.py`.
- [x] Task 1.2: Xây dựng ORM Database Models cho toàn bộ 11 thực thể nghiệp vụ: Users, Courses, Students, Teachers, Classes, Classrooms, Enrollments, Schedules/Sessions, Grades, CourseProgression, ParentStudentLink.
  - *Files:* `backend/app/models.py` và models trong từng module.
- [x] Task 1.3: Khởi tạo SQLite database & Seed Data Generator (`seed.py`) với đầy đủ 5 tài khoản mẫu và dữ liệu ban đầu cho các khóa học, lớp, phòng, điểm.
  - *Result:* Nạp thành công database `language_center.db` với 5 roles (Admin, Staff, Teacher, Student, Parent).

### Phase 2: Backend Modules Implementation (11 Bounded Contexts - 82 FRs)
- [x] Task 2.1: Module 1 (`auth`) & Module 2 (`accounts`) - Đăng nhập, phân quyền RBAC, token JWT, quản lý tài khoản, đổi mật khẩu. (FR-01 -> FR-10)
- [x] Task 2.2: Module 3 (`courses`), Module 4 (`students`), Module 5 (`teachers`) - Quản lý khóa học (target level: IELTS/TOEIC), hồ sơ học viên, hồ sơ giáo viên. (FR-11 -> FR-31)
- [x] Task 2.3: Module 6 (`classes`) & Module 7 (`classrooms`) - Quản lý lớp học, sức chứa phòng, gán giáo viên, cập nhật trạng thái lớp. (FR-32 -> FR-49)
- [x] Task 2.4: Module 8 (`enrollments`) - Đăng ký lớp học, duyệt/từ chối đăng ký có lý do, tự động cập nhật danh sách học viên trong lớp khi duyệt. (FR-50 -> FR-60)
- [x] Task 2.5: Module 9 (`schedules`) - Thời khóa biểu, logic phát hiện xung đột phòng học & giáo viên (`conflict_checker`), xác nhận lịch, lịch cá nhân. (FR-61 -> FR-68)
- [x] Task 2.6: Module 10 (`grades`) - Bảng nhập điểm, kiểm tra điểm (0-10), tính tổng kết Đạt/Chưa đạt, xác nhận điểm chính thức. (FR-69 -> FR-77)
- [x] Task 2.7: Module 11 (`progression_parent`) - Kiểm tra điều kiện học tiếp lên khóa cao hơn, đăng ký khóa kế tiếp, portal phụ huynh xem tiến độ con. (FR-78 -> FR-82)
- [x] Task 2.8: Tổng hợp API router v1 trong `app/main.py`, kiểm thử khởi động và verify toàn bộ 82 endpoints trong Swagger UI `/docs`.
  - *Result:* 49 endpoints RESTful tích hợp, `test_api.py` passed 100%.

### Phase 3: Frontend Foundation & Design System (Vite + React + TypeScript + Tailwind)
- [x] Task 3.1: Khởi tạo dự án Frontend với Vite, React 19, TypeScript, Tailwind CSS v4, Lucide React, Axios.
- [x] Task 3.2: Thiết lập cấu trúc thư mục Feature-driven: `src/types`, `src/services/api.ts`, `src/context/AuthContext.tsx`, `src/components/layout/{Navbar,Sidebar}.tsx`.
- [x] Task 3.3: Tạo các Types TypeScript ánh xạ 1-1 với Pydantic Schemas Backend trong `src/types/index.ts`.

### Phase 4: Frontend Features & Role-tailored Views
- [x] Task 4.1: Xây dựng trang Authentication & Quick Role Switcher (`src/views/LoginView.tsx` - Đăng nhập nhanh 1-click cho cả 5 vai trò).
- [x] Task 4.2: Xây dựng Dashboard & Thống kê tổng quan phù hợp với từng Role (`src/views/DashboardView.tsx`).
- [x] Task 4.3: Xây dựng Module UI Khóa học (`CoursesView.tsx`), Lớp học (`ClassesView.tsx`), Phòng học (`ClassroomsView.tsx`).
- [x] Task 4.4: Xây dựng Module UI Đăng ký & Xét duyệt lớp học (`EnrollmentsView.tsx`) với modal từ chối/phê duyệt và bộ lọc trạng thái.
- [x] Task 4.5: Xây dựng Module UI Thời khóa biểu (`SchedulesView.tsx`) với lịch trực quan, công cụ kiểm tra xung đột thời gian thực (Conflict Warning).
- [x] Task 4.6: Xây dựng Module UI Bảng điểm & Kết quả (`GradesView.tsx`) với validation điểm số 0-10 và xác nhận kết quả.
- [x] Task 4.7: Xây dựng Module UI Chuyển khóa học & Portal Phụ huynh (`ProgressionParentView.tsx` - theo dõi con và kiểm tra điều kiện nâng khóa).
- [x] Task 4.8: Xây dựng Module UI Quản lý tài khoản & Đổi mật khẩu (`AccountsView.tsx`).

### Phase 5: Verification & Integration Testing
- [x] Task 5.1: Chạy Backend server, kiểm thử các API chính thông qua `backend/test_api.py` -> 100% Passed.
- [x] Task 5.2: Build Frontend (`npm run build`) -> TypeScript compiled sạch 0 lỗi, bundle thành công trong 2.25s.
- [x] Task 5.3: Hướng dẫn chạy và tài liệu vận hành chi tiết (`README.md`, `start_backend.bat`, `start_frontend.bat`).
