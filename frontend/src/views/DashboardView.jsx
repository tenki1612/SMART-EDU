import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import {
  coursesApi,
  classesApi,
  classroomsApi,
  enrollmentsApi,
  schedulesApi,
  gradesApi,
  studentsApi,
  progressionParentApi
} from '../services/api';
import {
  BookOpen,
  School,
  DoorOpen,
  UserCheck,
  Calendar,
  Clock,
  Sparkles,
  CheckCircle2,
  AlertCircle,
  FileSpreadsheet,
  Award,
  Users,
  GraduationCap,
  ArrowRight,
  TrendingUp,
  MapPin,
  CalendarDays,
  ShieldCheck,
  Plus
} from 'lucide-react';

export const DashboardView = ({ onTabChange = () => {} }) => {
  const { user } = useAuth();
  const role = user?.role || 'STUDENT';

  const isAdminOrStaff = ['ADMIN', 'ACADEMIC_STAFF'].includes(role);
  const isTeacher = role === 'TEACHER';
  const isStudent = role === 'STUDENT';
  const isParent = role === 'PARENT';

  // Common date string
  const todayStr = new Date().toLocaleDateString('vi-VN', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  // -------------------------------------------------------------------------
  // 1. ADMIN & ACADEMIC STAFF DATA
  // -------------------------------------------------------------------------
  const [adminStats, setAdminStats] = useState({
    courses: 0,
    classes: 0,
    classrooms: 0,
    pendingRequests: 0,
  });
  const [pendingEnrollments, setPendingEnrollments] = useState([]);
  const [adminClasses, setAdminClasses] = useState([]);
  const [todaySchedules, setTodaySchedules] = useState([]);

  // -------------------------------------------------------------------------
  // 2. TEACHER DATA
  // -------------------------------------------------------------------------
  const [teacherClasses, setTeacherClasses] = useState([]);
  const [teacherSchedules, setTeacherSchedules] = useState([]);
  const [totalStudentsTeaching, setTotalStudentsTeaching] = useState(0);

  // -------------------------------------------------------------------------
  // 3. STUDENT DATA
  // -------------------------------------------------------------------------
  const [studentGrades, setStudentGrades] = useState([]);
  const [studentSchedules, setStudentSchedules] = useState([]);
  const [myEnrollmentRequests, setMyEnrollmentRequests] = useState([]);

  // -------------------------------------------------------------------------
  // 4. PARENT DATA
  // -------------------------------------------------------------------------
  const [parentWards, setParentWards] = useState([]);
  const [selectedWardForDash, setSelectedWardForDash] = useState(null);
  const [selectedWardGrades, setSelectedWardGrades] = useState([]);
  const [selectedWardRequests, setSelectedWardRequests] = useState([]);

  useEffect(() => {
    const loadRoleData = async () => {
      try {
        if (isAdminOrStaff) {
          const [c, cl, cr, en, sc] = await Promise.all([
            coursesApi.list().catch(() => ({ data: [] })),
            classesApi.list().catch(() => ({ data: [] })),
            classroomsApi.list().catch(() => ({ data: [] })),
            enrollmentsApi.listAll('PENDING').catch(() => ({ data: [] })),
            schedulesApi.list().catch(() => ({ data: [] })),
          ]);
          setAdminStats({
            courses: c.data?.length || 0,
            classes: cl.data?.length || 0,
            classrooms: cr.data?.length || 0,
            pendingRequests: en.data?.length || 0,
          });
          setPendingEnrollments((en.data || []).slice(0, 4));
          setAdminClasses((cl.data || []).slice(0, 5));
          setTodaySchedules((sc.data || []).slice(0, 4));
        } else if (isTeacher) {
          const [cl, sc] = await Promise.all([
            classesApi.list().catch(() => ({ data: [] })),
            schedulesApi.getPersonal().catch(() => ({ data: [] })),
          ]);
          const allClasses = cl.data || [];
          // Filter classes where teacher name matches or all
          setTeacherClasses(allClasses.slice(0, 6));
          setTeacherSchedules((sc.data || []).slice(0, 4));
          const totalHV = allClasses.reduce((acc, curr) => acc + (curr.current_enrolled || 0), 0);
          setTotalStudentsTeaching(totalHV);
        } else if (isStudent) {
          const [gr, sc, en] = await Promise.all([
            gradesApi.getMyGrades().catch(() => ({ data: [] })),
            schedulesApi.getPersonal().catch(() => ({ data: [] })),
            enrollmentsApi.getMyRequests().catch(() => ({ data: [] })),
          ]);
          setStudentGrades(gr.data || []);
          setStudentSchedules((sc.data || []).slice(0, 4));
          setMyEnrollmentRequests(en.data || []);
        } else if (isParent) {
          const wardsRes = await progressionParentApi.getParentWards().catch(() => ({ data: [] }));
          const listWards = wardsRes.data || [];
          setParentWards(listWards);
          if (listWards.length > 0) {
            const firstWard = listWards[0];
            setSelectedWardForDash(firstWard);
            const [wGr, wReq] = await Promise.all([
              progressionParentApi.getWardGrades(firstWard.student_id).catch(() => ({ data: [] })),
              progressionParentApi.getWardEnrollmentStatus(firstWard.student_id).catch(() => ({ data: [] })),
            ]);
            setSelectedWardGrades(wGr.data || []);
            setSelectedWardRequests(wReq.data || []);
          }
        }
      } catch (err) {
        console.error('Error loading dashboard data:', err);
      }
    };

    loadRoleData();
  }, [role]);

  // -------------------------------------------------------------------------
  // RENDER: 1. ADMIN & ACADEMIC STAFF DASHBOARD
  // -------------------------------------------------------------------------
  if (isAdminOrStaff) {
    return (
      <div className="space-y-6">
        {/* Operations Hero Banner */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-slate-900 via-indigo-950 to-slate-900 p-7 sm:p-8 text-white shadow-xl border border-slate-800">
          <div className="absolute top-0 right-0 -mr-16 -mt-16 w-80 h-80 rounded-full bg-indigo-500/10 blur-3xl pointer-events-none" />
          <div className="absolute bottom-0 left-1/3 -mb-20 w-64 h-64 rounded-full bg-purple-500/10 blur-2xl pointer-events-none" />

          <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="max-w-xl space-y-2">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-500/20 border border-indigo-400/30 text-indigo-200 text-xs font-semibold backdrop-blur-md">
                <Sparkles className="w-3.5 h-3.5 text-indigo-300" />
                <span>{todayStr}</span>
              </div>
              <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white leading-tight">
                Trung tâm Điều hành & Quản trị
              </h2>
              <p className="text-sm text-slate-300 leading-relaxed">
                Xin chào <strong className="text-white font-extrabold">{user?.full_name}</strong> ({role === 'ADMIN' ? 'Quản trị viên' : 'Nhân viên học vụ'}). Toàn bộ 11 phân hệ và hệ thống cơ sở vật chất, lịch học đang vận hành thông suốt.
              </p>
            </div>

            <div className="flex flex-wrap sm:flex-nowrap gap-3 shrink-0">
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-white tabular-nums">{adminStats.courses}</span>
                <span className="text-[11px] font-medium text-indigo-200 uppercase tracking-wider">Khóa học</span>
              </div>
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-white tabular-nums">{adminStats.classes}</span>
                <span className="text-[11px] font-medium text-indigo-200 uppercase tracking-wider">Lớp học</span>
              </div>
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-amber-300 tabular-nums">{adminStats.pendingRequests}</span>
                <span className="text-[11px] font-medium text-amber-200 uppercase tracking-wider">Chờ duyệt</span>
              </div>
            </div>
          </div>
        </div>

        {/* Admin KPI Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs flex flex-col justify-between">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Khóa học đào tạo</span>
              <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center font-bold">
                <BookOpen className="w-5 h-5" />
              </div>
            </div>
            <div className="mt-4">
              <div className="text-3xl font-black text-slate-900 tabular-nums">{adminStats.courses}</div>
              <div className="flex items-center gap-1.5 mt-1.5">
                <span className="w-2 h-2 rounded-full bg-blue-500" />
                <span className="text-xs font-semibold text-slate-600">IELTS 6.5+, TOEIC 750+</span>
              </div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs flex flex-col justify-between">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Lớp đang mở & học</span>
              <div className="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
                <School className="w-5 h-5" />
              </div>
            </div>
            <div className="mt-4">
              <div className="text-3xl font-black text-slate-900 tabular-nums">{adminStats.classes}</div>
              <div className="flex items-center gap-1.5 mt-1.5">
                <span className="w-2 h-2 rounded-full bg-indigo-500" />
                <span className="text-xs font-semibold text-slate-600">Kiểm soát sĩ số tối đa</span>
              </div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs flex flex-col justify-between">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Phòng học khả dụng</span>
              <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold">
                <DoorOpen className="w-5 h-5" />
              </div>
            </div>
            <div className="mt-4">
              <div className="text-3xl font-black text-slate-900 tabular-nums">{adminStats.classrooms}</div>
              <div className="flex items-center gap-1.5 mt-1.5">
                <span className="w-2 h-2 rounded-full bg-emerald-500" />
                <span className="text-xs font-semibold text-slate-600">Trang thiết bị sẵn sàng</span>
              </div>
            </div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs flex flex-col justify-between">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Đơn đăng ký chờ duyệt</span>
              <div className="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold">
                <UserCheck className="w-5 h-5" />
              </div>
            </div>
            <div className="mt-4">
              <div className="text-3xl font-black text-slate-900 tabular-nums">{adminStats.pendingRequests}</div>
              <div className="flex items-center gap-1.5 mt-1.5">
                <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse" />
                <span className="text-xs font-semibold text-amber-700">Yêu cầu từ học viên</span>
              </div>
            </div>
          </div>
        </div>

        {/* Two Column Layout: Pending Approvals + Classes Capacity Overview */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Left: Pending Enrollments */}
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-100">
                <h3 className="font-extrabold text-sm text-slate-900 flex items-center gap-2">
                  <UserCheck className="w-4 h-4 text-amber-600" /> Yêu cầu đăng ký lớp mới nhất
                </h3>
                <button
                  onClick={() => onTabChange('enrollments')}
                  className="text-xs font-bold text-indigo-600 hover:text-indigo-700 flex items-center gap-1 cursor-pointer transition"
                >
                  Xét duyệt ngay <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>

              <div className="space-y-3">
                {pendingEnrollments.length === 0 ? (
                  <div className="py-8 text-center text-slate-400 text-xs">
                    Hiện không có đơn đăng ký nào chờ xét duyệt.
                  </div>
                ) : (
                  pendingEnrollments.map((req) => (
                    <div
                      key={req.id}
                      className="p-3 bg-amber-50/40 rounded-xl border border-amber-200/60 flex items-center justify-between gap-3"
                    >
                      <div>
                        <div className="font-bold text-slate-900 text-xs">{req.student_name}</div>
                        <div className="text-[11px] text-slate-500 font-mono mt-0.5">
                          Mã HV: {req.student_code} &bull; Lớp: <span className="font-bold text-indigo-700">{req.class_code}</span>
                        </div>
                        <div className="text-[11px] text-slate-600 truncate mt-0.5">{req.course_title}</div>
                      </div>
                      <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 shrink-0">
                        Chờ duyệt
                      </span>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>

          {/* Right: Classes & Capacity Overview */}
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-100">
              <h3 className="font-extrabold text-sm text-slate-900 flex items-center gap-2">
                <School className="w-4 h-4 text-indigo-600" /> Sĩ số & Tỷ lệ lấp đầy lớp học
              </h3>
              <button
                onClick={() => onTabChange('classes')}
                className="text-xs font-bold text-indigo-600 hover:text-indigo-700 flex items-center gap-1 cursor-pointer transition"
              >
                Xem tất cả <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="space-y-3">
              {adminClasses.map((cl) => {
                const percentage = Math.min(100, Math.round((cl.current_enrolled / cl.max_capacity) * 100));
                return (
                  <div key={cl.id} className="p-3 bg-slate-50 rounded-xl border border-slate-100 space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="font-mono font-bold text-xs text-indigo-700">{cl.class_code}</span>
                      <span className="text-xs font-bold text-slate-700 tabular-nums">
                        {cl.current_enrolled} / {cl.max_capacity} HV ({percentage}%)
                      </span>
                    </div>
                    <div className="w-full bg-slate-200 rounded-full h-1.5 overflow-hidden">
                      <div
                        className={`h-full rounded-full transition-all duration-300 ${
                          percentage >= 100 ? 'bg-rose-500' : percentage >= 80 ? 'bg-amber-500' : 'bg-indigo-600'
                        }`}
                        style={{ width: `${percentage}%` }}
                      />
                    </div>
                    <div className="flex items-center justify-between text-[11px] text-slate-500">
                      <span className="truncate">{cl.course_title}</span>
                      <span className="font-medium">GV: {cl.teacher_name || 'Chưa phân công'}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Quick Operational Actions Bar */}
        <div className="bg-gradient-to-r from-indigo-50 to-purple-50 p-5 rounded-2xl border border-indigo-100 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-indigo-600 text-white flex items-center justify-center font-bold shrink-0">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-extrabold text-slate-900">Phím tắt Tác vụ Quản trị</h4>
              <p className="text-[11px] text-slate-500">Truy cập tức thì các công cụ vận hành trọng yếu của trung tâm</p>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <button
              onClick={() => onTabChange('classes')}
              className="px-3 py-1.5 rounded-xl bg-white hover:bg-slate-50 text-slate-800 border border-slate-200 text-xs font-bold shadow-2xs cursor-pointer transition flex items-center gap-1.5"
            >
              <Plus className="w-3.5 h-3.5 text-indigo-600" /> Tạo lớp học mới
            </button>
            <button
              onClick={() => onTabChange('schedules')}
              className="px-3 py-1.5 rounded-xl bg-white hover:bg-slate-50 text-slate-800 border border-slate-200 text-xs font-bold shadow-2xs cursor-pointer transition flex items-center gap-1.5"
            >
              <CalendarDays className="w-3.5 h-3.5 text-indigo-600" /> Xếp thời khóa biểu
            </button>
            <button
              onClick={() => onTabChange('courses')}
              className="px-3 py-1.5 rounded-xl bg-white hover:bg-slate-50 text-slate-800 border border-slate-200 text-xs font-bold shadow-2xs cursor-pointer transition flex items-center gap-1.5"
            >
              <BookOpen className="w-3.5 h-3.5 text-indigo-600" /> Quản lý khóa học
            </button>
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------------------
  // RENDER: 2. TEACHER DASHBOARD
  // -------------------------------------------------------------------------
  if (isTeacher) {
    return (
      <div className="space-y-6">
        {/* Teacher Hero Banner */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-emerald-950 via-slate-900 to-indigo-950 p-7 sm:p-8 text-white shadow-xl border border-slate-800">
          <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="max-w-xl space-y-2">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/20 border border-emerald-400/30 text-emerald-200 text-xs font-semibold backdrop-blur-md">
                <GraduationCap className="w-3.5 h-3.5 text-emerald-300" />
                <span>Không gian Giảng viên</span>
              </div>
              <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white leading-tight">
                Thầy/Cô {user?.full_name}
              </h2>
              <p className="text-sm text-slate-300 leading-relaxed">
                Chào mừng bạn đến với hệ thống quản lý giảng dạy. Hãy theo dõi lịch dạy, quản lý sĩ số và nhập bảng điểm các lớp phụ trách.
              </p>
            </div>

            <div className="flex gap-3 shrink-0">
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-emerald-300 tabular-nums">{teacherClasses.length}</span>
                <span className="text-[11px] font-medium text-emerald-200 uppercase tracking-wider">Lớp dạy</span>
              </div>
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-white tabular-nums">{totalStudentsTeaching}</span>
                <span className="text-[11px] font-medium text-emerald-200 uppercase tracking-wider">Học viên</span>
              </div>
            </div>
          </div>
        </div>

        {/* Two Column Layout: Teacher Schedule + Assigned Classes */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Left: Teaching Schedule */}
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-100">
              <h3 className="font-extrabold text-sm text-slate-900 flex items-center gap-2">
                <Calendar className="w-4 h-4 text-emerald-600" /> Lịch giảng dạy cá nhân
              </h3>
              <button
                onClick={() => onTabChange('schedules')}
                className="text-xs font-bold text-emerald-700 hover:text-emerald-800 flex items-center gap-1 cursor-pointer transition"
              >
                Xem chi tiết lịch <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="space-y-3">
              {teacherSchedules.length === 0 ? (
                <p className="text-xs text-slate-400 py-8 text-center">Bạn chưa có ca dạy nào được xếp trong tuần.</p>
              ) : (
                teacherSchedules.map((s) => (
                  <div key={s.id} className="p-3 bg-emerald-50/40 rounded-xl border border-emerald-100 flex items-center justify-between gap-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono font-bold text-xs text-indigo-700">{s.class_code}</span>
                        <span className="text-[10px] font-bold bg-amber-100 text-amber-800 px-2 py-0.5 rounded">
                          Phòng {s.room_code}
                        </span>
                      </div>
                      <div className="text-xs font-semibold text-slate-800 mt-1">{s.course_title}</div>
                      <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-1">
                        <Clock className="w-3 h-3 text-slate-400" />
                        <span className="font-mono">{s.session_date} &bull; {s.start_time} - {s.end_time}</span>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Right: Classes & Grading Shortcuts */}
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-100">
              <h3 className="font-extrabold text-sm text-slate-900 flex items-center gap-2">
                <FileSpreadsheet className="w-4 h-4 text-indigo-600" /> Sổ điểm các lớp phụ trách
              </h3>
              <button
                onClick={() => onTabChange('grades')}
                className="text-xs font-bold text-indigo-600 hover:text-indigo-700 flex items-center gap-1 cursor-pointer transition"
              >
                Vào trang nhập điểm <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="space-y-3">
              {teacherClasses.map((cl) => (
                <div key={cl.id} className="p-3 bg-slate-50 rounded-xl border border-slate-100 flex items-center justify-between gap-3">
                  <div>
                    <div className="font-mono font-bold text-xs text-indigo-700">{cl.class_code}</div>
                    <div className="text-xs font-semibold text-slate-800 mt-0.5">{cl.course_title}</div>
                    <div className="text-[11px] text-slate-500 mt-0.5">
                      Sĩ số: <strong className="text-slate-800">{cl.current_enrolled}/{cl.max_capacity}</strong> học viên
                    </div>
                  </div>
                  <button
                    onClick={() => onTabChange('grades')}
                    className="px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold rounded-lg text-xs cursor-pointer transition border border-indigo-200"
                  >
                    Chấm điểm
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------------------
  // RENDER: 3. STUDENT DASHBOARD
  // -------------------------------------------------------------------------
  if (isStudent) {
    const passedMôn = studentGrades.filter((g) => g.result_status === 'PASSED').length;

    return (
      <div className="space-y-6">
        {/* Student Hero Banner */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-blue-950 via-indigo-950 to-slate-900 p-7 sm:p-8 text-white shadow-xl border border-slate-800">
          <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="max-w-xl space-y-2">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 border border-blue-400/30 text-blue-200 text-xs font-semibold backdrop-blur-md">
                <Award className="w-3.5 h-3.5 text-blue-300" />
                <span>Góc Học tập Cá nhân</span>
              </div>
              <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white leading-tight">
                Xin chào, {user?.full_name}!
              </h2>
              <p className="text-sm text-slate-300 leading-relaxed">
                Chào mừng bạn quay trở lại. Hãy rà soát lịch học hôm nay, tra cứu điểm số môn học và cập nhật tiến độ nâng cấp độ tiếng Anh.
              </p>
            </div>

            <div className="flex gap-3 shrink-0">
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-blue-300 tabular-nums">{studentGrades.length}</span>
                <span className="text-[11px] font-medium text-blue-200 uppercase tracking-wider">Môn đã học</span>
              </div>
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-emerald-300 tabular-nums">{passedMôn}</span>
                <span className="text-[11px] font-medium text-emerald-200 uppercase tracking-wider">Môn đạt</span>
              </div>
            </div>
          </div>
        </div>

        {/* Student Two Columns: Schedules + Grades */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Left: Upcoming Schedule */}
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-100">
              <h3 className="font-extrabold text-sm text-slate-900 flex items-center gap-2">
                <CalendarDays className="w-4 h-4 text-indigo-600" /> Lịch học sắp tới của bạn
              </h3>
              <button
                onClick={() => onTabChange('schedules')}
                className="text-xs font-bold text-indigo-600 hover:text-indigo-700 flex items-center gap-1 cursor-pointer transition"
              >
                Xem toàn bộ lịch <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="space-y-3">
              {studentSchedules.length === 0 ? (
                <p className="text-xs text-slate-400 py-8 text-center">Bạn không có lịch học nào trong thời gian tới.</p>
              ) : (
                studentSchedules.map((s) => (
                  <div key={s.id} className="p-3 bg-indigo-50/40 rounded-xl border border-indigo-100 flex items-center justify-between gap-3">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-mono font-bold text-xs text-indigo-700">{s.class_code}</span>
                        <span className="text-[10px] font-bold bg-amber-100 text-amber-800 px-2 py-0.5 rounded">
                          Phòng {s.room_code}
                        </span>
                      </div>
                      <div className="text-xs font-semibold text-slate-800 mt-1">{s.course_title}</div>
                      <div className="flex items-center gap-2 text-[11px] text-slate-500 mt-1 font-mono">
                        <Clock className="w-3 h-3 text-slate-400" />
                        <span>{s.session_date} &bull; {s.start_time} - {s.end_time}</span>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Right: Personal Grades Summary */}
          <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-slate-100">
              <h3 className="font-extrabold text-sm text-slate-900 flex items-center gap-2">
                <Award className="w-4 h-4 text-indigo-600" /> Kết quả điểm gần đây
              </h3>
              <button
                onClick={() => onTabChange('grades')}
                className="text-xs font-bold text-indigo-600 hover:text-indigo-700 flex items-center gap-1 cursor-pointer transition"
              >
                Xem bảng điểm <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="space-y-3">
              {studentGrades.length === 0 ? (
                <p className="text-xs text-slate-400 py-8 text-center">Bạn chưa có bảng điểm nào được cập nhật.</p>
              ) : (
                studentGrades.map((g) => (
                  <div key={g.id} className="p-3 bg-slate-50 rounded-xl border border-slate-100 flex items-center justify-between gap-3">
                    <div>
                      <span className="font-mono font-bold text-xs text-indigo-700">{g.class_code}</span>
                      <div className="text-xs font-semibold text-slate-800 mt-0.5">{g.course_title}</div>
                      <div className="text-[11px] text-slate-500 mt-0.5 font-mono">
                        CC: {g.attendance_score} &bull; GK: {g.midterm_score} &bull; CK: {g.final_score}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-black text-indigo-700 tabular-nums">{g.total_score}</div>
                      <span
                        className={`text-[9px] font-bold px-2 py-0.5 rounded-full border ${
                          g.result_status === 'PASSED'
                            ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                            : 'bg-rose-50 text-rose-700 border-rose-200'
                        }`}
                      >
                        {g.result_status === 'PASSED' ? 'ĐẠT' : 'CHƯA ĐẠT'}
                      </span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------------------
  // RENDER: 4. PARENT DASHBOARD
  // -------------------------------------------------------------------------
  if (isParent) {
    return (
      <div className="space-y-6">
        {/* Parent Hero Banner */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-amber-950 via-slate-900 to-indigo-950 p-7 sm:p-8 text-white shadow-xl border border-slate-800">
          <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="max-w-xl space-y-2">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-amber-500/20 border border-amber-400/30 text-amber-200 text-xs font-semibold backdrop-blur-md">
                <Users className="w-3.5 h-3.5 text-amber-300" />
                <span>Cổng Thông tin Phụ huynh</span>
              </div>
              <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white leading-tight">
                Kính chào Phụ huynh {user?.full_name}
              </h2>
              <p className="text-sm text-slate-300 leading-relaxed">
                Đồng hành cùng sự tiến bộ và lộ trình đào tạo của con em tại trung tâm ngoại ngữ.
              </p>
            </div>

            <div className="flex gap-3 shrink-0">
              <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
                <span className="block text-2xl font-black text-amber-300 tabular-nums">{parentWards.length}</span>
                <span className="text-[11px] font-medium text-amber-200 uppercase tracking-wider">Con theo học</span>
              </div>
            </div>
          </div>
        </div>

        {/* Ward Info Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {parentWards.map((w) => (
            <div key={w.student_id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-2xs space-y-4">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100">
                <div>
                  <h3 className="font-extrabold text-base text-slate-900">{w.full_name}</h3>
                  <span className="text-xs text-slate-500 font-mono">Mã HV: {w.student_code} &bull; {w.relationship_type}</span>
                </div>
                <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                  {w.latest_status || 'Đang theo học'}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-3 text-xs">
                <div className="p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <span className="text-slate-400 font-semibold block text-[11px]">Khóa đã tham gia</span>
                  <span className="text-xl font-black text-slate-900 mt-1 block tabular-nums">{w.enrolled_courses_count} khóa</span>
                </div>
                <div className="p-3 bg-indigo-50/40 rounded-xl border border-indigo-100">
                  <span className="text-indigo-600 font-semibold block text-[11px]">Điểm TB tích lũy</span>
                  <span className="text-xl font-black text-indigo-700 mt-1 block tabular-nums">{w.average_score ?? '--'}</span>
                </div>
              </div>

              <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                <button
                  onClick={() => onTabChange('grades')}
                  className="px-3.5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-bold transition cursor-pointer shadow-xs"
                >
                  Xem bảng điểm của con
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return null;
};
