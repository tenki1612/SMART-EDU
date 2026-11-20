import React, { useState, useMemo } from 'react';
import {
  ArrowLeft,
  Lock,
  Unlock,
  Save,
  Plus,
  Trash2,
  FileSpreadsheet,
  CheckCircle2,
  Award,
  Users,
  Search,
  X,
  Filter,
  RotateCcw,
  BookOpen,
  GraduationCap,
  Calendar,
  AlertTriangle,
  ChevronDown,
  ArrowUpDown,
  Clock,
  Sparkles,
  HelpCircle
} from 'lucide-react';
import { UserAvatar } from '../common/UserAvatar';
import { GradeSheetStatusBadge, ClassStatusBadge } from './GradeStatusBadge';

export const GradeDetailLevel = ({
  classItem,
  allClasses = [],
  gradingSheet = [],
  lockInfo = { is_locked: false, is_manually_unlocked: false, lock_reason: '' },
  isTeacher = false,
  isAdminOrStaff = false,
  loading = false,
  onBackToOverview,
  onSelectAnotherClass,
  onScoreChange,
  onSaveGrades,
  onOpenLockModal,
  onOpenUnlockModal,
  onViewLockHistory,
  onOpenAddModal,
  onDeleteStudent,
}) => {
  // Search, filter, and sort state for student table
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL'); // 'ALL' | 'PASSED' | 'FAILED' | 'PENDING' | 'GRADED' | 'UNGRADED'
  const [sortOption, setSortOption] = useState('name_asc'); // 'name_asc' | 'name_desc' | 'code_asc' | 'score_desc' | 'score_asc'

  // Pagination for large student list
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 15;

  const isSheetLocked = Boolean(lockInfo?.is_locked) || (gradingSheet.length > 0 && gradingSheet.every((s) => s.is_confirmed));

  // -------------------------------------------------------------
  // THỐNG KÊ ĐIỂM CỦA LỚP (SECTION 4.B)
  // Không tính học viên chưa có kết quả tổng kết thành PASS/FAIL
  // -------------------------------------------------------------
  const gradeStats = useMemo(() => {
    const totalStudents = gradingSheet.length;

    // Evaluated students: those with an actual final result
    const evaluatedList = gradingSheet.filter(
      (s) => s.result_status === 'PASSED' || s.result_status === 'FAILED'
    );
    const evaluatedCount = evaluatedList.length;

    const passedCount = gradingSheet.filter((s) => s.result_status === 'PASSED').length;
    const failedCount = gradingSheet.filter((s) => s.result_status === 'FAILED').length;
    const pendingCount = totalStudents - evaluatedCount;

    // Class average score (calculated only over students who have total_score)
    const studentsWithScore = gradingSheet.filter(
      (s) => s.total_score !== null && s.total_score !== undefined
    );
    const avgScore =
      studentsWithScore.length > 0
        ? (
            studentsWithScore.reduce((acc, curr) => acc + Number(curr.total_score || 0), 0) /
            studentsWithScore.length
          ).toFixed(2)
        : '--';

    const passRate = evaluatedCount > 0 ? Math.round((passedCount / evaluatedCount) * 100) : 0;
    const failRate = evaluatedCount > 0 ? Math.round((failedCount / evaluatedCount) * 100) : 0;

    return {
      totalStudents,
      evaluatedCount,
      passedCount,
      failedCount,
      pendingCount,
      avgScore,
      passRate,
      failRate,
    };
  }, [gradingSheet]);

  // Filtered and sorted student grading list
  const processedStudents = useMemo(() => {
    return gradingSheet
      .filter((st) => {
        // 1. Text search (Name or Code)
        if (searchTerm.trim()) {
          const term = searchTerm.toLowerCase().trim();
          const matchName = st.full_name?.toLowerCase().includes(term);
          const matchCode = st.student_code?.toLowerCase().includes(term);
          if (!matchName && !matchCode) return false;
        }

        // 2. Status filter
        if (statusFilter === 'PASSED') {
          return st.result_status === 'PASSED';
        }
        if (statusFilter === 'FAILED') {
          return st.result_status === 'FAILED';
        }
        if (statusFilter === 'PENDING') {
          return st.result_status !== 'PASSED' && st.result_status !== 'FAILED';
        }
        if (statusFilter === 'GRADED') {
          return st.total_score !== null && st.total_score !== undefined;
        }
        if (statusFilter === 'UNGRADED') {
          return st.total_score === null || st.total_score === undefined;
        }

        return true;
      })
      .sort((a, b) => {
        switch (sortOption) {
          case 'name_desc':
            return (b.full_name || '').localeCompare(a.full_name || '', 'vi');
          case 'code_asc':
            return (a.student_code || '').localeCompare(b.student_code || '', 'en');
          case 'score_desc':
            return (Number(b.total_score) || -1) - (Number(a.total_score) || -1);
          case 'score_asc':
            return (Number(a.total_score) || 999) - (Number(b.total_score) || 999);
          case 'name_asc':
          default:
            return (a.full_name || '').localeCompare(b.full_name || '', 'vi');
        }
      });
  }, [gradingSheet, searchTerm, statusFilter, sortOption]);

  const totalPages = Math.ceil(processedStudents.length / pageSize) || 1;
  const paginatedStudents = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return processedStudents.slice(start, start + pageSize);
  }, [processedStudents, currentPage, pageSize]);

  return (
    <div className="space-y-6">
      {/* ------------------------------------------------------------- */}
      {/* NAVIGATION BAR & ACTION BUTTONS */}
      {/* ------------------------------------------------------------- */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs">
        <div className="flex items-center gap-3">
          {onBackToOverview && (
            <button
              type="button"
              onClick={onBackToOverview}
              className="inline-flex items-center gap-2 px-3.5 py-2 rounded-2xl text-xs font-bold bg-slate-100 hover:bg-indigo-50 text-slate-700 hover:text-indigo-700 transition cursor-pointer shadow-2xs group"
              title="Quay lại danh sách tổng quan các lớp"
            >
              <ArrowLeft className="w-4 h-4 text-slate-500 group-hover:text-indigo-600 transition-transform group-hover:-translate-x-0.5" />
              <span>Quay lại danh sách lớp</span>
            </button>
          )}

          {/* Quick class switcher */}
          {allClasses.length > 1 && onSelectAnotherClass && (
            <div className="relative">
              <select
                value={classItem?.id || ''}
                onChange={(e) => {
                  const target = allClasses.find((c) => String(c.id) === String(e.target.value));
                  if (target) onSelectAnotherClass(target);
                }}
                className="text-xs font-bold bg-slate-50 border border-slate-200 rounded-2xl px-3 py-2 text-slate-800 outline-none hover:bg-slate-100 cursor-pointer shadow-2xs max-w-[200px] sm:max-w-[260px] truncate"
              >
                {allClasses.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.class_code} - {c.course_title}
                  </option>
                ))}
              </select>
            </div>
          )}
        </div>

        {/* Action Buttons for Class Sheet */}
        <div className="flex items-center gap-2 flex-wrap shrink-0">
          {/* Lịch sử khóa điểm */}
          {isAdminOrStaff && (
            <button
              type="button"
              onClick={onViewLockHistory}
              className="flex items-center gap-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 px-3.5 py-2 rounded-2xl text-xs font-bold shadow-2xs transition cursor-pointer"
            >
              <FileSpreadsheet className="w-3.5 h-3.5 text-indigo-600" />
              <span>Lịch sử khóa</span>
            </button>
          )}

          {/* Thêm điểm học viên */}
          {(!isSheetLocked || isAdminOrStaff) && onOpenAddModal && (
            <button
              type="button"
              onClick={onOpenAddModal}
              className="flex items-center gap-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 px-3.5 py-2 rounded-2xl text-xs font-bold shadow-2xs transition cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5 text-indigo-600" />
              <span>Thêm học viên</span>
            </button>
          )}

          {/* Lưu điểm (Dành cho Giảng viên khi bảng điểm chưa bị khóa) */}
          {isTeacher && !isSheetLocked && (
            <button
              type="button"
              onClick={onSaveGrades}
              className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-2xl text-xs font-bold shadow-xs shadow-indigo-200 transition cursor-pointer active:scale-95"
            >
              <Save className="w-3.5 h-3.5" />
              <span>Lưu điểm</span>
            </button>
          )}

          {/* Khóa điểm (Admin & Staff) */}
          {isAdminOrStaff && !isSheetLocked && gradingSheet.length > 0 && (
            <button
              type="button"
              onClick={onOpenLockModal}
              className="flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-2xl text-xs font-bold shadow-xs shadow-emerald-200 transition cursor-pointer active:scale-95"
            >
              <Lock className="w-3.5 h-3.5" />
              <span>Khóa sổ điểm</span>
            </button>
          )}

          {/* Mở khóa điểm (Admin & Staff) */}
          {isAdminOrStaff && isSheetLocked && (
            <button
              type="button"
              onClick={onOpenUnlockModal}
              className="flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white px-4 py-2 rounded-2xl text-xs font-bold shadow-xs shadow-amber-200 transition cursor-pointer active:scale-95"
            >
              <Unlock className="w-3.5 h-3.5" />
              <span>Mở khóa điểm (72h)</span>
            </button>
          )}
        </div>
      </div>

      {/* ------------------------------------------------------------- */}
      {/* THÔNG TIN LỚP HỌC (CARD CHI TIẾT - SECTION 4.A) */}
      {/* ------------------------------------------------------------- */}
      <div className="bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 text-white rounded-3xl p-6 sm:p-7 shadow-xl border border-indigo-900/60 relative overflow-hidden">
        {/* Subtle decorative background circles */}
        <div className="absolute -right-12 -top-12 w-48 h-48 bg-indigo-500/10 rounded-full blur-2xl pointer-events-none" />
        <div className="absolute right-1/3 -bottom-12 w-56 h-56 bg-blue-500/10 rounded-full blur-3xl pointer-events-none" />

        <div className="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
          {/* Main class info */}
          <div className="space-y-2">
            <div className="flex items-center gap-2.5 flex-wrap">
              <span className="font-mono text-sm font-black px-3 py-1 rounded-xl bg-white/10 text-white border border-white/10 backdrop-blur-md">
                {classItem?.class_code}
              </span>
              <ClassStatusBadge status={classItem?.status} className="bg-white/10 text-indigo-200 border-white/15" />
              <GradeSheetStatusBadge
                status={
                  isSheetLocked
                    ? 'LOCKED'
                    : gradeStats.totalStudents === 0
                    ? 'NO_STUDENTS'
                    : gradeStats.evaluatedCount === gradeStats.totalStudents && gradeStats.totalStudents > 0
                    ? 'COMPLETED_GRADING'
                    : 'GRADING_IN_PROGRESS'
                }
                isManuallyUnlocked={lockInfo?.is_manually_unlocked}
                className="bg-white/15 text-white border-white/20 backdrop-blur-md"
              />
            </div>

            <h2 className="text-xl sm:text-2xl font-black text-white tracking-tight">
              {classItem?.course_title || `Khóa học #${classItem?.course_id}`}
            </h2>

            <div className="flex flex-wrap items-center gap-y-1.5 gap-x-4 text-xs text-indigo-200/90 pt-1 font-medium">
              <div className="flex items-center gap-1.5">
                <GraduationCap className="w-4 h-4 text-indigo-400 shrink-0" />
                <span>GV: <strong className="text-white">{classItem?.teacher_name || 'Chưa phân công'}</strong></span>
              </div>
              <span>&bull;</span>
              <div className="flex items-center gap-1.5">
                <Calendar className="w-4 h-4 text-indigo-400 shrink-0" />
                <span>
                  {classItem?.start_date ? `Từ ${classItem.start_date}` : 'Chưa có lịch'}
                  {classItem?.end_date ? ` đến ${classItem.end_date}` : ''}
                </span>
              </div>
              <span>&bull;</span>
              <div className="flex items-center gap-1.5">
                <Users className="w-4 h-4 text-indigo-400 shrink-0" />
                <span>
                  Sĩ số: <strong className="text-white">{classItem?.current_enrolled || 0} / {classItem?.max_capacity || 25} HV</strong>
                </span>
              </div>
            </div>
          </div>

          {/* Quick grade summary cards inside banner */}
          <div className="flex items-center gap-3 shrink-0">
            <div className="bg-white/10 backdrop-blur-md px-5 py-3.5 rounded-2xl text-center border border-white/10">
              <span className="block text-[11px] font-bold uppercase tracking-wider text-indigo-200">
                Điểm TB lớp
              </span>
              <span className="text-2xl sm:text-3xl font-black text-white tabular-nums tracking-tight mt-0.5 block">
                {gradeStats.avgScore}
              </span>
            </div>

            <div className="bg-white/10 backdrop-blur-md px-5 py-3.5 rounded-2xl text-center border border-white/10">
              <span className="block text-[11px] font-bold uppercase tracking-wider text-emerald-300">
                Tỷ lệ Đạt (Pass)
              </span>
              <span className="text-2xl sm:text-3xl font-black text-emerald-400 tabular-nums tracking-tight mt-0.5 block">
                {gradeStats.evaluatedCount > 0 ? `${gradeStats.passRate}%` : '--'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* ------------------------------------------------------------- */}
      {/* THÔNG BÁO TRẠNG THÁI KHÓA ĐIỂM HOẶC MỞ KHÓA THỦ CÔNG */}
      {/* ------------------------------------------------------------- */}
      {isSheetLocked && (
        <div className="bg-amber-50 border border-amber-200/90 text-amber-900 px-4 sm:p-4.5 rounded-2xl text-xs font-semibold flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 shadow-2xs">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-amber-100 flex items-center justify-center shrink-0">
              <Lock className="w-4 h-4 text-amber-700" />
            </div>
            <div>
              <span className="font-bold text-amber-950 block">Sổ điểm đã bị khóa chính thức</span>
              <span className="text-amber-800 text-[11px]">
                {lockInfo?.lock_reason || 'Lớp học đã kết thúc hoặc được khóa sổ chính thức. Giảng viên chỉ có quyền xem, không được chỉnh sửa điểm.'}
              </span>
            </div>
          </div>
          {isAdminOrStaff && (
            <button
              type="button"
              onClick={onOpenUnlockModal}
              className="px-3.5 py-1.5 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-xs font-bold shrink-0 cursor-pointer transition shadow-2xs"
            >
              Mở khóa điểm
            </button>
          )}
        </div>
      )}

      {!isSheetLocked && lockInfo?.is_manually_unlocked && (
        <div className="bg-emerald-50 border border-emerald-200/90 text-emerald-900 px-4 sm:p-4.5 rounded-2xl text-xs font-semibold flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 shadow-2xs">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-emerald-100 flex items-center justify-center shrink-0">
              <Unlock className="w-4 h-4 text-emerald-700" />
            </div>
            <div>
              <span className="font-bold text-emerald-950 block">Bảng điểm đang mở khóa thủ công</span>
              <span className="text-emerald-800 text-[11px]">
                {lockInfo?.lock_reason || 'Bảng điểm được mở khóa tạm thời trong 72 giờ cho giảng viên sửa điểm nhầm lẫn.'}
              </span>
            </div>
          </div>
          {isAdminOrStaff && (
            <button
              type="button"
              onClick={onOpenLockModal}
              className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shrink-0 cursor-pointer transition shadow-2xs"
            >
              Khóa lại sổ điểm
            </button>
          )}
        </div>
      )}

      {/* ------------------------------------------------------------- */}
      {/* 4 THẺ THỐNG KÊ ĐIỂM (SECTION 4.B) */}
      {/* ------------------------------------------------------------- */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Card 1: Tổng số học viên */}
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-black uppercase tracking-wider text-slate-500 block">
              Sĩ số bảng điểm
            </span>
            <span className="text-2xl sm:text-3xl font-black text-slate-900 mt-1 block tabular-nums">
              {gradeStats.totalStudents}
            </span>
            <span className="text-[11px] text-slate-400 mt-0.5 block">
              {gradeStats.evaluatedCount} đã tổng kết &bull; {gradeStats.pendingCount} đang học
            </span>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-slate-100 flex items-center justify-center text-slate-600 shrink-0">
            <Users className="w-5 h-5" />
          </div>
        </div>

        {/* Card 2: Đạt chuẩn (PASSED) */}
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-black uppercase tracking-wider text-emerald-600 block">
              Đạt chuẩn (PASSED)
            </span>
            <span className="text-2xl sm:text-3xl font-black text-emerald-700 mt-1 block tabular-nums">
              {gradeStats.passedCount}
            </span>
            <span className="text-[11px] text-emerald-600 font-semibold mt-0.5 block">
              {gradeStats.evaluatedCount > 0 ? `${gradeStats.passRate}% trên diện đánh giá` : 'Chưa có kết quả'}
            </span>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-emerald-50 border border-emerald-200/60 flex items-center justify-center text-emerald-600 shrink-0">
            <CheckCircle2 className="w-5 h-5" />
          </div>
        </div>

        {/* Card 3: Không đạt (FAILED) */}
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-black uppercase tracking-wider text-rose-600 block">
              Chưa đạt (FAILED)
            </span>
            <span className="text-2xl sm:text-3xl font-black text-rose-700 mt-1 block tabular-nums">
              {gradeStats.failedCount}
            </span>
            <span className="text-[11px] text-rose-600 font-semibold mt-0.5 block">
              {gradeStats.evaluatedCount > 0 ? `${gradeStats.failRate}% trên diện đánh giá` : 'Chưa có kết quả'}
            </span>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-rose-50 border border-rose-200/60 flex items-center justify-center text-rose-600 shrink-0">
            <AlertTriangle className="w-5 h-5" />
          </div>
        </div>

        {/* Card 4: Điểm trung bình lớp */}
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-black uppercase tracking-wider text-indigo-600 block">
              Điểm TB lớp
            </span>
            <span className="text-2xl sm:text-3xl font-black text-indigo-700 mt-1 block tabular-nums">
              {gradeStats.avgScore}
            </span>
            <span className="text-[11px] text-slate-400 mt-0.5 block">
              Thang điểm 10 (CC 20%, GK 30%, CK 50%)
            </span>
          </div>
          <div className="w-10 h-10 rounded-2xl bg-indigo-50 border border-indigo-200/60 flex items-center justify-center text-indigo-600 shrink-0">
            <Award className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* ------------------------------------------------------------- */}
      {/* BẢNG ĐIỂM HỌC VIÊN (SECTION 4.C) */}
      {/* ------------------------------------------------------------- */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden space-y-0">
        {/* Toolbar trong bảng điểm */}
        <div className="p-4 sm:p-5 bg-slate-50/70 border-b border-slate-200/80 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
          {/* Ô tìm kiếm học viên */}
          <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-2xl px-3.5 py-2 w-full sm:w-72 focus-within:border-indigo-400 focus-within:ring-2 focus-within:ring-indigo-100 transition shadow-2xs">
            <Search className="w-3.5 h-3.5 text-slate-400 shrink-0" />
            <input
              type="text"
              placeholder="Tìm theo tên hoặc mã học viên..."
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
                className="text-slate-400 hover:text-slate-600 p-0.5 rounded-full"
                title="Xóa"
              >
                <X className="w-3 h-3" />
              </button>
            )}
          </div>

          {/* Lọc & Sắp xếp học viên */}
          <div className="flex items-center gap-2 flex-wrap">
            {/* Lọc theo kết quả */}
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setCurrentPage(1);
              }}
              className="text-xs font-semibold bg-white border border-slate-200 rounded-2xl px-3 py-2 text-slate-700 outline-none hover:border-slate-300 cursor-pointer shadow-2xs"
            >
              <option value="ALL">-- Tất cả trạng thái --</option>
              <option value="PASSED">Đạt chuẩn (PASSED)</option>
              <option value="FAILED">Chưa đạt (FAILED)</option>
              <option value="PENDING">Chờ điểm / Đang học</option>
              <option value="GRADED">Đã có điểm tổng kết</option>
              <option value="UNGRADED">Chưa có điểm tổng kết</option>
            </select>

            {/* Sắp xếp */}
            <select
              value={sortOption}
              onChange={(e) => setSortOption(e.target.value)}
              className="text-xs font-semibold bg-white border border-slate-200 rounded-2xl px-3 py-2 text-slate-700 outline-none hover:border-slate-300 cursor-pointer shadow-2xs"
            >
              <option value="name_asc">Tên học viên (A - Z)</option>
              <option value="name_desc">Tên học viên (Z - A)</option>
              <option value="code_asc">Mã học viên</option>
              <option value="score_desc">Điểm tổng kết (Cao nhất)</option>
              <option value="score_asc">Điểm tổng kết (Thấp nhất)</option>
            </select>

            {(searchTerm || statusFilter !== 'ALL') && (
              <button
                type="button"
                onClick={() => {
                  setSearchTerm('');
                  setStatusFilter('ALL');
                  setCurrentPage(1);
                }}
                className="px-2.5 py-2 text-xs font-bold text-rose-600 hover:bg-rose-50 rounded-2xl border border-rose-200 transition cursor-pointer"
                title="Đặt lại bộ lọc học viên"
              >
                <RotateCcw className="w-3.5 h-3.5" />
              </button>
            )}
          </div>
        </div>

        {/* Bảng chi tiết điểm */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/90 border-b border-slate-200/90 font-bold text-slate-600 uppercase text-[11px] tracking-wider">
              <tr>
                <th className="p-4 w-12 text-center">STT</th>
                <th className="p-4 min-w-[200px]">Học viên</th>
                <th className="p-4 text-center w-36">Chuyên cần (20%)</th>
                <th className="p-4 text-center w-36">Giữa kỳ (30%)</th>
                <th className="p-4 text-center w-36">Cuối kỳ (50%)</th>
                <th className="p-4 text-center w-32">Tổng kết</th>
                <th className="p-4 text-center w-36">Xếp loại</th>
                <th className="p-4 text-center w-36">Trạng thái</th>
                {(!isSheetLocked || isAdminOrStaff) && <th className="p-4 text-right w-20">Thao tác</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {gradingSheet.length === 0 ? (
                // Lớp chưa có học viên
                <tr>
                  <td colSpan={10} className="p-12 text-center text-slate-400">
                    <div className="max-w-xs mx-auto space-y-3">
                      <div className="w-12 h-12 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
                        <Users className="w-6 h-6" />
                      </div>
                      <div className="font-bold text-slate-800 text-sm">
                        Lớp học chưa có học viên nào
                      </div>
                      <p className="text-xs text-slate-500">
                        Chưa có học viên nào được ghi danh vào lớp học này để chấm điểm.
                      </p>
                      {onOpenAddModal && (
                        <button
                          type="button"
                          onClick={onOpenAddModal}
                          className="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold rounded-xl text-xs transition cursor-pointer"
                        >
                          + Thêm học viên vào lớp
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : paginatedStudents.length === 0 ? (
                // Tìm kiếm không ra học viên
                <tr>
                  <td colSpan={10} className="p-8 text-center text-slate-400 font-medium">
                    Không tìm thấy học viên nào phù hợp với điều kiện tìm kiếm/lọc hiện tại.
                  </td>
                </tr>
              ) : (
                paginatedStudents.map((st, idx) => {
                  const isConfirmed = Boolean(st.is_confirmed);
                  const isGraded = st.total_score !== null && st.total_score !== undefined;

                  return (
                    <tr key={st.student_id} className="hover:bg-slate-50/80 transition-colors">
                      {/* STT */}
                      <td className="p-4 text-center font-mono font-semibold text-slate-400">
                        {(currentPage - 1) * pageSize + idx + 1}
                      </td>

                      {/* Thông tin học viên */}
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <UserAvatar
                            name={st.full_name}
                            avatarUrl={st.avatar_url}
                            size="sm"
                            className="rounded-xl shrink-0"
                          />
                          <div>
                            <div className="font-bold text-slate-900 leading-tight">{st.full_name}</div>
                            <div className="font-mono text-[11px] text-indigo-700 font-semibold">{st.student_code}</div>
                            {st.note && (
                              <div className="text-[10px] text-slate-400 italic line-clamp-1 mt-0.5">
                                {st.note}
                              </div>
                            )}
                          </div>
                        </div>
                      </td>

                      {/* Điểm chuyên cần (20%) */}
                      <td className="p-4 text-center">
                        {isTeacher && !isSheetLocked ? (
                          <input
                            type="number"
                            step="0.5"
                            min="0"
                            max="10"
                            value={st.attendance_score ?? ''}
                            onChange={(e) =>
                              onScoreChange &&
                              onScoreChange(
                                st.student_id,
                                'attendance_score',
                                e.target.value === '' ? 0 : parseFloat(e.target.value)
                              )
                            }
                            placeholder="0"
                            className="w-20 text-center font-mono font-bold border border-slate-300 p-1.5 rounded-xl outline-hidden focus:border-indigo-600 bg-white"
                          />
                        ) : (
                          <span
                            className={`font-mono font-bold text-sm tabular-nums ${
                              st.attendance_score !== null && st.attendance_score !== undefined
                                ? 'text-slate-800'
                                : 'text-slate-300'
                            }`}
                          >
                            {st.attendance_score !== null && st.attendance_score !== undefined
                              ? st.attendance_score
                              : '--'}
                          </span>
                        )}
                      </td>

                      {/* Điểm giữa kỳ (30%) */}
                      <td className="p-4 text-center">
                        {isTeacher && !isSheetLocked ? (
                          <input
                            type="number"
                            step="0.5"
                            min="0"
                            max="10"
                            value={st.midterm_score ?? ''}
                            onChange={(e) =>
                              onScoreChange &&
                              onScoreChange(
                                st.student_id,
                                'midterm_score',
                                e.target.value === '' ? 0 : parseFloat(e.target.value)
                              )
                            }
                            placeholder="0"
                            className="w-20 text-center font-mono font-bold border border-slate-300 p-1.5 rounded-xl outline-hidden focus:border-indigo-600 bg-white"
                          />
                        ) : (
                          <span
                            className={`font-mono font-bold text-sm tabular-nums ${
                              st.midterm_score !== null && st.midterm_score !== undefined
                                ? 'text-slate-800'
                                : 'text-slate-300'
                            }`}
                          >
                            {st.midterm_score !== null && st.midterm_score !== undefined
                              ? st.midterm_score
                              : '--'}
                          </span>
                        )}
                      </td>

                      {/* Điểm cuối kỳ (50%) */}
                      <td className="p-4 text-center">
                        {isTeacher && !isSheetLocked ? (
                          <input
                            type="number"
                            step="0.5"
                            min="0"
                            max="10"
                            value={st.final_score ?? ''}
                            onChange={(e) =>
                              onScoreChange &&
                              onScoreChange(
                                st.student_id,
                                'final_score',
                                e.target.value === '' ? 0 : parseFloat(e.target.value)
                              )
                            }
                            placeholder="0"
                            className="w-20 text-center font-mono font-bold border border-slate-300 p-1.5 rounded-xl outline-hidden focus:border-indigo-600 bg-white"
                          />
                        ) : (
                          <span
                            className={`font-mono font-bold text-sm tabular-nums ${
                              st.final_score !== null && st.final_score !== undefined
                                ? 'text-slate-800'
                                : 'text-slate-300'
                            }`}
                          >
                            {st.final_score !== null && st.final_score !== undefined
                              ? st.final_score
                              : '--'}
                          </span>
                        )}
                      </td>

                      {/* Điểm tổng kết */}
                      <td className="p-4 text-center">
                        <span
                          className={`font-mono font-black text-base tabular-nums ${
                            isGraded ? 'text-indigo-700' : 'text-slate-300 font-normal'
                          }`}
                        >
                          {isGraded ? st.total_score : '--'}
                        </span>
                      </td>

                      {/* Xếp loại kết quả */}
                      <td className="p-4 text-center">
                        <span
                          className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold border ${
                            st.result_status === 'PASSED'
                              ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                              : st.result_status === 'FAILED'
                              ? 'bg-rose-50 text-rose-700 border-rose-200'
                              : 'bg-slate-100 text-slate-500 border-slate-200'
                          }`}
                        >
                          {st.result_status === 'PASSED'
                            ? 'ĐẠT (PASSED)'
                            : st.result_status === 'FAILED'
                            ? 'CHƯA ĐẠT (FAILED)'
                            : 'CHỜ ĐIỂM'}
                        </span>
                      </td>

                      {/* Trạng thái xác nhận */}
                      <td className="p-4 text-center">
                        {isConfirmed ? (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Điểm chính thức
                          </span>
                        ) : (
                          <span className="text-[11px] font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200">
                            Điểm tạm tính
                          </span>
                        )}
                      </td>

                      {/* Thao tác xóa học viên */}
                      {(!isSheetLocked || isAdminOrStaff) && (
                        <td className="p-4 text-right">
                          {!isConfirmed && onDeleteStudent && (
                            <button
                              type="button"
                              onClick={() => onDeleteStudent(st.student_id, st.full_name)}
                              className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition cursor-pointer"
                              title="Xóa học viên khỏi bảng điểm"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          )}
                        </td>
                      )}
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Phân trang danh sách học viên */}
        {processedStudents.length > pageSize && (
          <div className="p-4 bg-slate-50/80 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
            <div>
              Hiển thị {(currentPage - 1) * pageSize + 1} -{' '}
              {Math.min(currentPage * pageSize, processedStudents.length)} / {processedStudents.length} học viên
            </div>
            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                disabled={currentPage === 1}
                className="px-3 py-1 rounded-xl border border-slate-200 hover:bg-white disabled:opacity-40 cursor-pointer"
              >
                Trước
              </button>
              <span className="font-bold text-slate-700 px-2">
                Trang {currentPage} / {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages}
                className="px-3 py-1 rounded-xl border border-slate-200 hover:bg-white disabled:opacity-40 cursor-pointer"
              >
                Sau
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
