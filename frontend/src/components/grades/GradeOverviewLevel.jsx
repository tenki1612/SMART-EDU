import React, { useState, useMemo } from 'react';
import {
  FileSpreadsheet,
  Search,
  RefreshCw,
  Filter,
  RotateCcw,
  BookOpen,
  GraduationCap,
  Users,
  CheckCircle2,
  Lock,
  ArrowRight,
  ChevronLeft,
  ChevronRight,
  Calendar,
  Layers,
  Sparkles,
  X,
  AlertCircle,
  Eye,
  SlidersHorizontal,
  Clock
} from 'lucide-react';
import { UserAvatar } from '../common/UserAvatar';
import { GradeSheetStatusBadge, ClassStatusBadge } from './GradeStatusBadge';

export const GradeOverviewLevel = ({
  classes = [],
  sheetStats = {},
  loading = false,
  loadingStats = false,
  onRefresh,
  onSelectClass,
  onOpenHistoryModal,
}) => {
  // Filters state
  const [searchTerm, setSearchTerm] = useState('');
  const [teacherFilter, setTeacherFilter] = useState('');
  const [classStatusFilter, setClassStatusFilter] = useState('');
  const [sheetStatusFilter, setSheetStatusFilter] = useState('');
  const [timeFilter, setTimeFilter] = useState(''); // 'all' | 'upcoming' | 'ongoing' | 'ended'
  const [activeKpiCard, setActiveKpiCard] = useState(null); // 'all' | 'in_progress' | 'completed' | 'locked'

  // Pagination state
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

  const todayStr = useMemo(() => {
    const d = new Date();
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }, []);

  // Distinct list of teachers for dropdown
  const availableTeachers = useMemo(() => {
    const map = new Map();
    classes.forEach((c) => {
      if (c.teacher_id && c.teacher_name) {
        if (!map.has(c.teacher_id)) {
          map.set(c.teacher_id, {
            id: c.teacher_id,
            name: c.teacher_name,
            classCount: 1,
          });
        } else {
          map.get(c.teacher_id).classCount += 1;
        }
      }
    });
    return Array.from(map.values()).sort((a, b) => a.name.localeCompare(b.name, 'vi'));
  }, [classes]);

  // Aggregate stats across all classes
  const kpiData = useMemo(() => {
    // 1. Tổng số lớp có sổ điểm (loại trừ PLANNING)
    const gradeClasses = classes.filter((c) => c.status !== 'PLANNING');
    const totalGradeClasses = gradeClasses.length;

    let inProgressCount = 0;
    let completedGradingCount = 0;
    let lockedCount = 0;

    gradeClasses.forEach((c) => {
      const stat = sheetStats[c.id];
      const status = stat?.sheetStatus || (c.status === 'COMPLETED' ? 'LOCKED' : (c.current_enrolled === 0 ? 'NO_STUDENTS' : 'GRADING_IN_PROGRESS'));

      if (status === 'LOCKED') {
        lockedCount++;
      }
      if (status === 'COMPLETED_GRADING' || (status === 'LOCKED' && stat?.fullyGraded === stat?.totalStudents && stat?.totalStudents > 0)) {
        completedGradingCount++;
      }
      if (status === 'GRADING_IN_PROGRESS') {
        inProgressCount++;
      }
    });

    return {
      totalGradeClasses,
      inProgressCount,
      completedGradingCount,
      lockedCount,
    };
  }, [classes, sheetStats]);

  // Handle clicking on a KPI card to filter
  const handleKpiCardClick = (cardType) => {
    if (activeKpiCard === cardType) {
      // Toggle off
      setActiveKpiCard(null);
      setSheetStatusFilter('');
      setClassStatusFilter('');
    } else {
      setActiveKpiCard(cardType);
      switch (cardType) {
        case 'all':
          setSheetStatusFilter('');
          setClassStatusFilter('');
          break;
        case 'in_progress':
          setSheetStatusFilter('GRADING_IN_PROGRESS');
          break;
        case 'completed':
          setSheetStatusFilter('COMPLETED_GRADING');
          break;
        case 'locked':
          setSheetStatusFilter('LOCKED');
          break;
        default:
          break;
      }
    }
    setCurrentPage(1);
  };

  // Reset all filters
  const handleResetFilters = () => {
    setSearchTerm('');
    setTeacherFilter('');
    setClassStatusFilter('');
    setSheetStatusFilter('');
    setTimeFilter('');
    setActiveKpiCard(null);
    setCurrentPage(1);
  };

  const isFiltered = Boolean(searchTerm || teacherFilter || classStatusFilter || sheetStatusFilter || timeFilter || activeKpiCard);

  // Filtered classes list
  const filteredClasses = useMemo(() => {
    return classes.filter((c) => {
      const stat = sheetStats[c.id];
      const resolvedSheetStatus = stat?.sheetStatus || (
        c.status === 'PLANNING'
          ? 'NOT_OPEN'
          : c.status === 'COMPLETED'
          ? 'LOCKED'
          : c.current_enrolled === 0
          ? 'NO_STUDENTS'
          : 'GRADING_IN_PROGRESS'
      );

      // Search keyword (class_code, course_title, teacher_name)
      if (searchTerm.trim()) {
        const term = searchTerm.toLowerCase().trim();
        const matchCode = c.class_code?.toLowerCase().includes(term);
        const matchCourse = c.course_title?.toLowerCase().includes(term);
        const matchTeacher = c.teacher_name?.toLowerCase().includes(term);
        if (!matchCode && !matchCourse && !matchTeacher) {
          return false;
        }
      }

      // Teacher filter
      if (teacherFilter && String(c.teacher_id) !== String(teacherFilter)) {
        return false;
      }

      // Class status filter
      if (classStatusFilter && c.status !== classStatusFilter) {
        return false;
      }

      // Sheet status filter
      if (sheetStatusFilter) {
        if (sheetStatusFilter === 'COMPLETED_GRADING') {
          // Bao gồm cả lớp đã hoàn tất 100% hoặc lớp đã khóa mà 100% điểm
          const isFull = stat?.fullyGraded === stat?.totalStudents && (stat?.totalStudents || 0) > 0;
          if (resolvedSheetStatus !== 'COMPLETED_GRADING' && !isFull) {
            return false;
          }
        } else if (resolvedSheetStatus !== sheetStatusFilter) {
          return false;
        }
      }

      // Time filter
      if (timeFilter) {
        const start = c.start_date || c.opening_date;
        const end = c.end_date;
        if (timeFilter === 'upcoming') {
          if (!start || start <= todayStr) return false;
        } else if (timeFilter === 'ongoing') {
          if (!start || start > todayStr || (end && end < todayStr)) return false;
        } else if (timeFilter === 'ended') {
          if (!end || end >= todayStr) return false;
        }
      }

      return true;
    });
  }, [classes, sheetStats, searchTerm, teacherFilter, classStatusFilter, sheetStatusFilter, timeFilter, todayStr]);

  // Paginated items
  const paginatedClasses = useMemo(() => {
    const startIdx = (currentPage - 1) * pageSize;
    return filteredClasses.slice(startIdx, startIdx + pageSize);
  }, [filteredClasses, currentPage, pageSize]);

  const totalPages = Math.ceil(filteredClasses.length / pageSize) || 1;

  return (
    <div className="space-y-6">
      {/* ------------------------------------------------------------- */}
      {/* HEADER TỔNG QUAN (CẤP ĐỘ 1) */}
      {/* ------------------------------------------------------------- */}
      <div className="bg-white p-5 sm:p-6 rounded-3xl border border-slate-200/90 shadow-2xs">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-2.5">
              <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-indigo-600 to-indigo-500 text-white flex items-center justify-center shadow-xs shadow-indigo-200">
                <FileSpreadsheet className="w-5 h-5" />
              </div>
              <div>
                <h1 className="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">
                  Sổ điểm & Kết quả
                </h1>
                <p className="text-xs text-slate-500 font-medium">
                  Quản lý bảng điểm, tiến độ đánh giá và kết quả học tập của học viên.
                </p>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2.5 flex-wrap shrink-0">
            {onOpenHistoryModal && (
              <button
                type="button"
                onClick={onOpenHistoryModal}
                className="flex items-center gap-2 bg-slate-100 hover:bg-slate-200 text-slate-700 px-3.5 py-2 rounded-2xl text-xs font-bold transition cursor-pointer shadow-2xs"
                title="Xem lịch sử khóa và mở khóa bảng điểm các lớp"
              >
                <Lock className="w-3.5 h-3.5 text-indigo-600" />
                <span>Lịch sử khóa sổ</span>
              </button>
            )}

            <button
              type="button"
              onClick={onRefresh}
              disabled={loading}
              className="flex items-center gap-2 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 px-3.5 py-2 rounded-2xl text-xs font-bold transition cursor-pointer shadow-2xs disabled:opacity-50"
              title="Làm mới dữ liệu toàn hệ thống"
            >
              <RefreshCw className={`w-3.5 h-3.5 text-indigo-600 ${loading || loadingStats ? 'animate-spin' : ''}`} />
              <span>Làm mới</span>
            </button>
          </div>
        </div>
      </div>

      {/* ------------------------------------------------------------- */}
      {/* 4 THẺ THỐNG KÊ (KPI CARDS) - CÓ THỂ CLICK ĐỂ LỌC NHANH */}
      {/* ------------------------------------------------------------- */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Card 1: Tổng số lớp có sổ điểm */}
        <button
          type="button"
          onClick={() => handleKpiCardClick('all')}
          className={`text-left p-4 sm:p-5 rounded-3xl border transition-all cursor-pointer shadow-2xs relative overflow-hidden group ${
            activeKpiCard === 'all'
              ? 'bg-indigo-50/70 border-indigo-400 ring-2 ring-indigo-500/20 shadow-indigo-100'
              : 'bg-white hover:bg-slate-50 border-slate-200/90'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black uppercase tracking-wider text-slate-500">
              Tổng số lớp có sổ điểm
            </span>
            <div className="w-9 h-9 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center shrink-0">
              <Layers className="w-4 h-4 text-indigo-600" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline justify-between">
            <span className="text-3xl font-black text-slate-900 tracking-tight tabular-nums">
              {kpiData.totalGradeClasses}
            </span>
            <span className="text-[11px] font-bold text-slate-400">
              lớp học
            </span>
          </div>
          <div className="mt-1 text-[11px] text-slate-500 font-medium">
            (Đã trừ các lớp đang lập kế hoạch)
          </div>
        </button>

        {/* Card 2: Lớp đang nhập điểm */}
        <button
          type="button"
          onClick={() => handleKpiCardClick('in_progress')}
          className={`text-left p-4 sm:p-5 rounded-3xl border transition-all cursor-pointer shadow-2xs relative overflow-hidden group ${
            activeKpiCard === 'in_progress'
              ? 'bg-blue-50/70 border-blue-400 ring-2 ring-blue-500/20 shadow-blue-100'
              : 'bg-white hover:bg-slate-50 border-slate-200/90'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black uppercase tracking-wider text-blue-700">
              Lớp đang nhập điểm
            </span>
            <div className="w-9 h-9 rounded-xl bg-blue-100 text-blue-700 flex items-center justify-center shrink-0">
              <Users className="w-4 h-4 text-blue-600" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline justify-between">
            <span className="text-3xl font-black text-blue-800 tracking-tight tabular-nums">
              {kpiData.inProgressCount}
            </span>
            <span className="text-[11px] font-bold text-blue-600">
              đang mở
            </span>
          </div>
          <div className="mt-1 text-[11px] text-blue-600 font-medium">
            Giảng viên đang chấm điểm
          </div>
        </button>

        {/* Card 3: Lớp đã hoàn thành nhập điểm */}
        <button
          type="button"
          onClick={() => handleKpiCardClick('completed')}
          className={`text-left p-4 sm:p-5 rounded-3xl border transition-all cursor-pointer shadow-2xs relative overflow-hidden group ${
            activeKpiCard === 'completed'
              ? 'bg-emerald-50/70 border-emerald-400 ring-2 ring-emerald-500/20 shadow-emerald-100'
              : 'bg-white hover:bg-slate-50 border-slate-200/90'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black uppercase tracking-wider text-emerald-700">
              Đã hoàn thành nhập
            </span>
            <div className="w-9 h-9 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline justify-between">
            <span className="text-3xl font-black text-emerald-800 tracking-tight tabular-nums">
              {kpiData.completedGradingCount}
            </span>
            <span className="text-[11px] font-bold text-emerald-600">
              100% học viên
            </span>
          </div>
          <div className="mt-1 text-[11px] text-emerald-600 font-medium">
            Đủ điều kiện khóa sổ chính thức
          </div>
        </button>

        {/* Card 4: Lớp đã khóa sổ điểm */}
        <button
          type="button"
          onClick={() => handleKpiCardClick('locked')}
          className={`text-left p-4 sm:p-5 rounded-3xl border transition-all cursor-pointer shadow-2xs relative overflow-hidden group ${
            activeKpiCard === 'locked'
              ? 'bg-amber-50/70 border-amber-400 ring-2 ring-amber-500/20 shadow-amber-100'
              : 'bg-white hover:bg-slate-50 border-slate-200/90'
          }`}
        >
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-black uppercase tracking-wider text-amber-700">
              Lớp đã khóa sổ điểm
            </span>
            <div className="w-9 h-9 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center shrink-0">
              <Lock className="w-4 h-4 text-amber-600" />
            </div>
          </div>
          <div className="mt-3 flex items-baseline justify-between">
            <span className="text-3xl font-black text-amber-800 tracking-tight tabular-nums">
              {kpiData.lockedCount}
            </span>
            <span className="text-[11px] font-bold text-amber-600">
              đã khóa
            </span>
          </div>
          <div className="mt-1 text-[11px] text-amber-600 font-medium">
            Bảo toàn kết quả học tập
          </div>
        </button>
      </div>

      {/* ------------------------------------------------------------- */}
      {/* BỘ LỌC VÀ TÌM KIẾM (CẤP ĐỘ 1) */}
      {/* ------------------------------------------------------------- */}
      <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs space-y-3.5">
        <div className="flex flex-col lg:flex-row items-stretch lg:items-center justify-between gap-3">
          {/* Ô tìm kiếm thông minh */}
          <div className="flex items-center gap-2.5 flex-1 bg-slate-50/90 border border-slate-200/90 rounded-2xl px-3.5 py-2.5 focus-within:bg-white focus-within:border-indigo-400 focus-within:ring-2 focus-within:ring-indigo-100 transition">
            <Search className="w-4 h-4 text-slate-400 shrink-0" />
            <input
              type="text"
              placeholder="Tìm theo mã lớp, tên khóa học, giáo viên phụ trách..."
              value={searchTerm}
              onChange={(e) => {
                setSearchTerm(e.target.value);
                setCurrentPage(1);
              }}
              className="w-full text-xs outline-hidden text-slate-800 placeholder:text-slate-400 bg-transparent font-medium"
            />
            {searchTerm && (
              <button
                type="button"
                onClick={() => setSearchTerm('')}
                className="text-slate-400 hover:text-slate-600 cursor-pointer p-0.5 rounded-full hover:bg-slate-200/50"
                title="Xóa tìm kiếm"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>

          {/* Các bộ lọc theo trường nghiệp vụ */}
          <div className="flex items-center gap-2 flex-wrap shrink-0">
            {/* Lọc theo Giáo viên */}
            <div className="relative">
              <select
                value={teacherFilter}
                onChange={(e) => {
                  setTeacherFilter(e.target.value);
                  setCurrentPage(1);
                }}
                className="text-xs font-semibold bg-white border border-slate-200/90 rounded-2xl px-3 py-2 text-slate-700 outline-none hover:border-slate-300 cursor-pointer shadow-2xs"
              >
                <option value="">-- Tất cả giáo viên ({availableTeachers.length}) --</option>
                {availableTeachers.map((t) => (
                  <option key={t.id} value={t.id}>
                    GV: {t.name} ({t.classCount} lớp)
                  </option>
                ))}
              </select>
            </div>

            {/* Lọc theo Trạng thái lớp */}
            <div className="relative">
              <select
                value={classStatusFilter}
                onChange={(e) => {
                  setClassStatusFilter(e.target.value);
                  setCurrentPage(1);
                }}
                className="text-xs font-semibold bg-white border border-slate-200/90 rounded-2xl px-3 py-2 text-slate-700 outline-none hover:border-slate-300 cursor-pointer shadow-2xs"
              >
                <option value="">-- Trạng thái lớp: Tất cả --</option>
                <option value="IN_PROGRESS">Lớp đang diễn ra</option>
                <option value="OPEN_FOR_ENROLLMENT">Lớp đang mở ghi danh</option>
                <option value="COMPLETED">Lớp đã kết thúc</option>
                <option value="PLANNING">Lớp lập kế hoạch</option>
              </select>
            </div>

            {/* Lọc theo Trạng thái sổ điểm */}
            <div className="relative">
              <select
                value={sheetStatusFilter}
                onChange={(e) => {
                  setSheetStatusFilter(e.target.value);
                  setActiveKpiCard(null);
                  setCurrentPage(1);
                }}
                className="text-xs font-semibold bg-white border border-slate-200/90 rounded-2xl px-3 py-2 text-slate-700 outline-none hover:border-slate-300 cursor-pointer shadow-2xs"
              >
                <option value="">-- Trạng thái sổ điểm: Tất cả --</option>
                <option value="GRADING_IN_PROGRESS">Đang mở nhập điểm</option>
                <option value="COMPLETED_GRADING">Đã hoàn thành nhập</option>
                <option value="LOCKED">Đã khóa sổ điểm</option>
                <option value="NO_STUDENTS">Chưa có học viên</option>
                <option value="NOT_OPEN">Chưa mở sổ (Planning)</option>
              </select>
            </div>

            {/* Lọc theo Thời gian khai giảng */}
            <div className="relative">
              <select
                value={timeFilter}
                onChange={(e) => {
                  setTimeFilter(e.target.value);
                  setCurrentPage(1);
                }}
                className="text-xs font-semibold bg-white border border-slate-200/90 rounded-2xl px-3 py-2 text-slate-700 outline-none hover:border-slate-300 cursor-pointer shadow-2xs"
              >
                <option value="">-- Thời gian: Tất cả --</option>
                <option value="upcoming">Sắp khai giảng</option>
                <option value="ongoing">Đang trong thời gian học</option>
                <option value="ended">Đã kết thúc</option>
              </select>
            </div>

            {/* Nút Xóa bộ lọc (Reset) */}
            {isFiltered && (
              <button
                type="button"
                onClick={handleResetFilters}
                className="px-3 py-2 text-xs font-bold text-rose-600 hover:bg-rose-50 rounded-2xl border border-rose-200/80 transition cursor-pointer flex items-center gap-1.5 active:scale-95 shadow-2xs"
                title="Xóa toàn bộ điều kiện lọc"
              >
                <RotateCcw className="w-3.5 h-3.5" />
                <span>Đặt lại</span>
              </button>
            )}
          </div>
        </div>

        {/* Chỉ dẫn kết quả lọc */}
        <div className="flex items-center justify-between text-xs text-slate-500 pt-1 border-t border-slate-100">
          <div>
            Hiển thị <span className="font-bold text-slate-800">{filteredClasses.length}</span> / {classes.length} lớp học
            {isFiltered && <span className="text-indigo-600 ml-1 font-semibold">(đang lọc)</span>}
          </div>
          {loadingStats && (
            <div className="flex items-center gap-1.5 text-[11px] text-indigo-600">
              <RefreshCw className="w-3 h-3 animate-spin" />
              <span>Đang đồng bộ tiến độ điểm từ hệ thống...</span>
            </div>
          )}
        </div>
      </div>

      {/* ------------------------------------------------------------- */}
      {/* BẢNG DANH SÁCH LỚP HỌC (CẤP ĐỘ 1 TABLE) */}
      {/* ------------------------------------------------------------- */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/90 border-b border-slate-200/90 font-bold text-slate-600 uppercase text-[11px] tracking-wider">
              <tr>
                <th className="p-4 w-12 text-center">STT</th>
                <th className="p-4 w-40">Mã lớp</th>
                <th className="p-4 min-w-[200px]">Khóa học</th>
                <th className="p-4 min-w-[180px]">Giáo viên phụ trách</th>
                <th className="p-4 text-center w-28">Sĩ số</th>
                <th className="p-4 min-w-[200px]">Tiến độ nhập điểm</th>
                <th className="p-4 text-center w-40">Trạng thái sổ điểm</th>
                <th className="p-4 text-right w-28">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                // Skeleton loading state
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    <td className="p-4 text-center"><div className="h-4 bg-slate-200 rounded-md w-6 mx-auto" /></td>
                    <td className="p-4"><div className="h-4 bg-slate-200 rounded-md w-24" /></td>
                    <td className="p-4"><div className="h-4 bg-slate-200 rounded-md w-40" /></td>
                    <td className="p-4"><div className="h-4 bg-slate-200 rounded-md w-32" /></td>
                    <td className="p-4"><div className="h-4 bg-slate-200 rounded-md w-16 mx-auto" /></td>
                    <td className="p-4"><div className="h-4 bg-slate-200 rounded-md w-32" /></td>
                    <td className="p-4"><div className="h-4 bg-slate-200 rounded-md w-24 mx-auto" /></td>
                    <td className="p-4"><div className="h-8 bg-slate-200 rounded-xl w-20 ml-auto" /></td>
                  </tr>
                ))
              ) : filteredClasses.length === 0 ? (
                // Empty state
                <tr>
                  <td colSpan={8} className="p-12 text-center text-slate-400">
                    <div className="max-w-sm mx-auto space-y-3">
                      <div className="w-12 h-12 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
                        <FileSpreadsheet className="w-6 h-6" />
                      </div>
                      <div className="font-bold text-slate-800 text-sm">
                        Không tìm thấy lớp học phù hợp
                      </div>
                      <p className="text-xs text-slate-500">
                        Thử điều chỉnh hoặc xóa các điều kiện lọc để xem danh sách toàn bộ lớp học.
                      </p>
                      {isFiltered && (
                        <button
                          type="button"
                          onClick={handleResetFilters}
                          className="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold rounded-xl text-xs transition cursor-pointer"
                        >
                          Xóa bộ lọc tìm kiếm
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                paginatedClasses.map((cls, idx) => {
                  const stat = sheetStats[cls.id];
                  const resolvedSheetStatus = stat?.sheetStatus || (
                    cls.status === 'PLANNING'
                      ? 'NOT_OPEN'
                      : cls.status === 'COMPLETED'
                      ? 'LOCKED'
                      : cls.current_enrolled === 0
                      ? 'NO_STUDENTS'
                      : 'GRADING_IN_PROGRESS'
                  );

                  const totalStudents = stat?.totalStudents ?? cls.current_enrolled ?? 0;
                  const fullyGraded = stat?.fullyGraded ?? (cls.status === 'COMPLETED' ? totalStudents : 0);
                  const progressPct = totalStudents > 0 ? Math.round((fullyGraded / totalStudents) * 100) : 0;

                  return (
                    <tr
                      key={cls.id}
                      onClick={() => onSelectClass(cls)}
                      className="hover:bg-slate-50/80 transition-colors cursor-pointer group"
                    >
                      {/* STT */}
                      <td className="p-4 text-center font-mono font-semibold text-slate-400">
                        {(currentPage - 1) * pageSize + idx + 1}
                      </td>

                      {/* Mã lớp */}
                      <td className="p-4">
                        <div className="font-mono font-bold text-indigo-700 text-xs flex items-center gap-1.5 group-hover:text-indigo-900 transition">
                          <span>{cls.class_code}</span>
                        </div>
                        <div className="mt-1">
                          <ClassStatusBadge status={cls.status} />
                        </div>
                      </td>

                      {/* Khóa học */}
                      <td className="p-4">
                        <div className="font-bold text-slate-900 line-clamp-1 group-hover:text-indigo-600 transition">
                          {cls.course_title || `Khóa học #${cls.course_id}`}
                        </div>
                        {cls.target_level && (
                          <span className="inline-block mt-0.5 text-[10px] font-mono font-semibold text-slate-500 bg-slate-100 px-1.5 py-0.5 rounded">
                            {cls.target_level}
                          </span>
                        )}
                      </td>

                      {/* Giáo viên */}
                      <td className="p-4">
                        <div className="flex items-center gap-2.5">
                          <UserAvatar
                            name={cls.teacher_name || 'Chưa phân công'}
                            size="sm"
                            className="rounded-xl shrink-0"
                          />
                          <div className="min-w-0">
                            <div className="font-semibold text-slate-800 truncate">
                              {cls.teacher_name || (
                                <span className="text-slate-400 italic">Chưa phân công</span>
                              )}
                            </div>
                            <div className="text-[10px] text-slate-400 font-mono">
                              {cls.start_date ? `Khai giảng: ${cls.start_date}` : 'Lịch dự kiến'}
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* Sĩ số */}
                      <td className="p-4 text-center">
                        <div className="font-mono font-bold text-slate-800 tabular-nums">
                          {cls.current_enrolled} / {cls.max_capacity}
                        </div>
                        {/* Mini capacity bar */}
                        <div className="w-16 h-1.5 bg-slate-100 rounded-full mx-auto mt-1 overflow-hidden">
                          <div
                            className={`h-full rounded-full ${
                              cls.current_enrolled >= cls.max_capacity
                                ? 'bg-amber-500'
                                : 'bg-indigo-500'
                            }`}
                            style={{
                              width: `${Math.min(100, (cls.current_enrolled / (cls.max_capacity || 1)) * 100)}%`,
                            }}
                          />
                        </div>
                      </td>

                      {/* Tiến độ nhập điểm */}
                      <td className="p-4">
                        {totalStudents === 0 ? (
                          <div className="text-slate-400 text-[11px] italic">
                            Chưa có học viên
                          </div>
                        ) : (
                          <div className="space-y-1.5">
                            <div className="flex items-center justify-between text-[11px]">
                              <span className="font-mono font-bold text-slate-700 tabular-nums">
                                {fullyGraded} / {totalStudents} HV
                              </span>
                              <span
                                className={`font-mono font-bold ${
                                  progressPct === 100
                                    ? 'text-emerald-600'
                                    : progressPct > 0
                                    ? 'text-indigo-600'
                                    : 'text-slate-400'
                                }`}
                              >
                                {progressPct}%
                              </span>
                            </div>
                            {/* Visual Progress Bar */}
                            <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                              <div
                                className={`h-full rounded-full transition-all duration-300 ${
                                  progressPct === 100
                                    ? 'bg-emerald-500'
                                    : progressPct > 0
                                    ? 'bg-indigo-600'
                                    : 'bg-slate-200'
                                }`}
                                style={{ width: `${progressPct}%` }}
                              />
                            </div>
                          </div>
                        )}
                      </td>

                      {/* Trạng thái sổ điểm */}
                      <td className="p-4 text-center">
                        <GradeSheetStatusBadge
                          status={resolvedSheetStatus}
                          isManuallyUnlocked={stat?.isManuallyUnlocked}
                        />
                      </td>

                      {/* Thao tác: Xem sổ điểm */}
                      <td className="p-4 text-right">
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            onSelectClass(cls);
                          }}
                          className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl text-xs font-bold bg-indigo-50 hover:bg-indigo-600 text-indigo-700 hover:text-white transition cursor-pointer shadow-2xs group-hover:bg-indigo-600 group-hover:text-white"
                        >
                          <span>Xem sổ</span>
                          <ArrowRight className="w-3.5 h-3.5" />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Phân trang (Pagination) */}
        {filteredClasses.length > pageSize && (
          <div className="p-4 bg-slate-50/80 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs">
            <div className="flex items-center gap-2 text-slate-500">
              <span>Hiển thị:</span>
              <select
                value={pageSize}
                onChange={(e) => {
                  setPageSize(Number(e.target.value));
                  setCurrentPage(1);
                }}
                className="bg-white border border-slate-200 rounded-xl px-2 py-1 text-slate-700 font-semibold outline-none cursor-pointer"
              >
                <option value={10}>10 lớp/trang</option>
                <option value={20}>20 lớp/trang</option>
                <option value={50}>50 lớp/trang</option>
              </select>
              <span>(Trang {currentPage} / {totalPages})</span>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                disabled={currentPage === 1}
                className="p-1.5 rounded-xl border border-slate-200 hover:bg-white text-slate-600 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer"
                title="Trang trước"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>

              {Array.from({ length: totalPages }).map((_, i) => {
                const pageNum = i + 1;
                // Only show around current page if many pages
                if (
                  pageNum === 1 ||
                  pageNum === totalPages ||
                  (pageNum >= currentPage - 1 && pageNum <= currentPage + 1)
                ) {
                  return (
                    <button
                      key={pageNum}
                      type="button"
                      onClick={() => setCurrentPage(pageNum)}
                      className={`w-7 h-7 rounded-xl font-bold transition cursor-pointer ${
                        currentPage === pageNum
                          ? 'bg-indigo-600 text-white shadow-xs shadow-indigo-200'
                          : 'hover:bg-slate-100 text-slate-700'
                      }`}
                    >
                      {pageNum}
                    </button>
                  );
                } else if (
                  pageNum === currentPage - 2 ||
                  pageNum === currentPage + 2
                ) {
                  return <span key={pageNum} className="text-slate-400 px-1">...</span>;
                }
                return null;
              })}

              <button
                type="button"
                onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages}
                className="p-1.5 rounded-xl border border-slate-200 hover:bg-white text-slate-600 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer"
                title="Trang tiếp"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
