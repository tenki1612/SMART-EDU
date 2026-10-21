import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { coursesApi, classesApi, classroomsApi, enrollmentsApi, schedulesApi } from '../services/api';
import {
  BookOpen,
  School,
  DoorOpen,
  UserCheck,
  Calendar,
  Clock,
  Sparkles,
  CheckCircle2,
  AlertCircle
} from 'lucide-react';

export const DashboardView = () => {
  const { user } = useAuth();
  const [stats, setStats] = useState({
    courses: 0,
    classes: 0,
    classrooms: 0,
    pendingRequests: 0,
  });
  const [upcomingSessions, setUpcomingSessions] = useState([]);
  const [recentClasses, setRecentClasses] = useState([]);

  useEffect(() => {
    const loadDashboardData = async () => {
      try {
        const [c, cl, cr, en, sc] = await Promise.all([
          coursesApi.list(),
          classesApi.list(),
          classroomsApi.list(),
          enrollmentsApi.listAll('PENDING').catch(() => ({ data: [] })),
          schedulesApi.list().catch(() => ({ data: [] })),
        ]);
        setStats({
          courses: c.data?.length || 0,
          classes: cl.data?.length || 0,
          classrooms: cr.data?.length || 0,
          pendingRequests: en.data?.length || 0,
        });
        setUpcomingSessions((sc.data || []).slice(0, 4));
        setRecentClasses((cl.data || []).slice(0, 5));
      } catch (e) {
        console.error('Error loading dashboard stats:', e);
      }
    };
    loadDashboardData();
  }, []);

  const todayStr = new Date().toLocaleDateString('vi-VN', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  return (
    <div className="space-y-6">
      {/* Premium Hero Banner */}
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
              Xin chào, {user?.full_name}!
            </h2>
            <p className="text-sm text-slate-300 leading-relaxed">
              Bạn đang đăng nhập với quyền hạn <strong className="text-indigo-300 font-bold">{user?.role}</strong>. Hệ thống quản trị trung tâm hoạt động ổn định và sẵn sàng tác nghiệp.
            </p>
          </div>

          <div className="flex flex-wrap sm:flex-nowrap gap-3 shrink-0">
            <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
              <span className="block text-2xl font-black text-white tabular-nums">{stats.courses}</span>
              <span className="text-[11px] font-medium text-indigo-200 uppercase tracking-wider">Khóa học</span>
            </div>
            <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
              <span className="block text-2xl font-black text-white tabular-nums">{stats.classes}</span>
              <span className="text-[11px] font-medium text-indigo-200 uppercase tracking-wider">Lớp học</span>
            </div>
            <div className="bg-white/10 backdrop-blur-md border border-white/10 p-4 rounded-2xl text-center min-w-[110px]">
              <span className="block text-2xl font-black text-amber-300 tabular-nums">{stats.pendingRequests}</span>
              <span className="text-[11px] font-medium text-indigo-200 uppercase tracking-wider">Chờ duyệt</span>
            </div>
          </div>
        </div>
      </div>

      {/* Modern KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Card 1 */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Chương trình học</span>
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center font-bold">
              <BookOpen className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <div className="text-3xl font-black text-slate-900 tabular-nums">{stats.courses}</div>
            <div className="flex items-center gap-1.5 mt-1.5">
              <span className="w-2 h-2 rounded-full bg-blue-500" />
              <span className="text-xs font-semibold text-slate-600">IELTS 6.5+, TOEIC 750+</span>
            </div>
          </div>
        </div>

        {/* Card 2 */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Lớp đang hoạt động</span>
            <div className="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
              <School className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <div className="text-3xl font-black text-slate-900 tabular-nums">{stats.classes}</div>
            <div className="flex items-center gap-1.5 mt-1.5">
              <span className="w-2 h-2 rounded-full bg-indigo-500" />
              <span className="text-xs font-semibold text-slate-600">Đang tuyển sinh / Giảng dạy</span>
            </div>
          </div>
        </div>

        {/* Card 3 */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Phòng học sẵn sàng</span>
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold">
              <DoorOpen className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <div className="text-3xl font-black text-slate-900 tabular-nums">{stats.classrooms}</div>
            <div className="flex items-center gap-1.5 mt-1.5">
              <span className="w-2 h-2 rounded-full bg-emerald-500" />
              <span className="text-xs font-semibold text-slate-600">Trang thiết bị đạt chuẩn</span>
            </div>
          </div>
        </div>

        {/* Card 4 */}
        <div className="bg-white p-5 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider">Đơn đăng ký chờ duyệt</span>
            <div className="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold">
              <UserCheck className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-4">
            <div className="text-3xl font-black text-slate-900 tabular-nums">{stats.pendingRequests}</div>
            <div className="flex items-center gap-1.5 mt-1.5">
              <span className="w-2 h-2 rounded-full bg-amber-500" />
              <span className="text-xs font-semibold text-slate-600">Yêu cầu từ học viên</span>
            </div>
          </div>
        </div>
      </div>

      {/* Two Column Layout: Upcoming Classes + Recent Classes Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left: Upcoming Schedule Sessions */}
        <div className="bg-white rounded-2xl border border-slate-200/90 p-5 shadow-2xs flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
                <Calendar className="w-4 h-4 text-indigo-600" /> Lịch học sắp diễn ra
              </h3>
              <span className="text-[11px] font-semibold text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded-md">
                Thời gian thực
              </span>
            </div>

            <div className="space-y-3">
              {upcomingSessions.length === 0 ? (
                <p className="text-xs text-slate-400 py-8 text-center">Chưa có buổi học nào sắp diễn ra.</p>
              ) : (
                upcomingSessions.map((s, idx) => (
                  <div
                    key={idx}
                    className="p-3 bg-slate-50/80 rounded-xl border border-slate-100 flex flex-col gap-1.5"
                  >
                    <div className="flex items-center justify-between">
                      <span className="font-mono font-bold text-xs text-indigo-700">{s.class_code}</span>
                      <span className="text-[10px] font-bold bg-amber-100 text-amber-800 px-2 py-0.5 rounded">
                        Phòng {s.room_code}
                      </span>
                    </div>
                    <div className="text-xs font-semibold text-slate-800 truncate">{s.course_title}</div>
                    <div className="flex items-center gap-2 text-[11px] text-slate-500">
                      <span className="flex items-center gap-1">
                        <Clock className="w-3 h-3 text-slate-400" /> {s.start_time} - {s.end_time}
                      </span>
                      <span>&bull;</span>
                      <span className="truncate">GV: {s.teacher_name}</span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {/* Right: Recent Classes Overview */}
        <div className="bg-white rounded-2xl border border-slate-200/90 p-5 shadow-2xs">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-sm text-slate-800 flex items-center gap-2">
              <School className="w-4 h-4 text-indigo-600" /> Tổng quan các lớp học
            </h3>
            <span className="text-[11px] font-semibold text-slate-500">
              Tổng số: {stats.classes} lớp
            </span>
          </div>

          <div className="space-y-3">
            {recentClasses.length === 0 ? (
              <p className="text-xs text-slate-400 py-8 text-center">Chưa có lớp học nào.</p>
            ) : (
              recentClasses.map((cl) => (
                <div
                  key={cl.id}
                  className="p-3 bg-slate-50/80 hover:bg-indigo-50/40 rounded-xl border border-slate-100 transition flex items-center justify-between gap-3"
                >
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-xs text-indigo-700">{cl.class_code}</span>
                      <span className="text-[10px] font-semibold bg-slate-200 text-slate-700 px-1.5 py-0.5 rounded">
                        {cl.target_level || 'IELTS/TOEIC'}
                      </span>
                    </div>
                    <div className="text-xs font-semibold text-slate-800 truncate mt-0.5">
                      {cl.course_title}
                    </div>
                    <div className="text-[11px] text-slate-500 mt-0.5">
                      GV: {cl.teacher_name || 'Chưa phân công'}
                    </div>
                  </div>

                  <div className="text-right shrink-0">
                    <div className="text-xs font-bold text-slate-900 tabular-nums">
                      {cl.current_enrolled}/{cl.max_capacity} <span className="text-[10px] text-slate-500 font-normal">HV</span>
                    </div>
                    <span
                      className={`inline-block mt-1 text-[10px] font-bold px-2 py-0.5 rounded-full border ${
                        cl.status === 'OPEN_FOR_ENROLLMENT'
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : cl.status === 'IN_PROGRESS'
                          ? 'bg-blue-50 text-blue-700 border-blue-200'
                          : 'bg-slate-100 text-slate-600 border-slate-200'
                      }`}
                    >
                      {cl.status === 'OPEN_FOR_ENROLLMENT'
                        ? 'Đang mở'
                        : cl.status === 'IN_PROGRESS'
                        ? 'Đang học'
                        : cl.status}
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
};
