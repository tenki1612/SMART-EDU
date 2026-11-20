import React from 'react';
import { Lock, Unlock, CheckCircle2, Clock, Users, Ban, Edit3 } from 'lucide-react';

/**
 * Badge hiển thị trạng thái Sổ điểm (Grade Sheet Status)
 * Phân biệt rõ ràng với trạng thái vòng đời của lớp học.
 */
export const GradeSheetStatusBadge = ({ status, isManuallyUnlocked, className = '' }) => {
  switch (status) {
    case 'LOCKED':
      return (
        <span
          className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-50 text-amber-800 border border-amber-200/80 shadow-2xs ${className}`}
          title="Bảng điểm đã được khóa chính thức hoặc lớp học đã kết thúc"
        >
          <Lock className="w-3.5 h-3.5 text-amber-600 shrink-0" />
          <span>Đã khóa sổ</span>
        </span>
      );

    case 'COMPLETED_GRADING':
      return (
        <span
          className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-800 border border-emerald-200/80 shadow-2xs ${className}`}
          title="100% học viên trong diện đánh giá đã có đủ điểm tổng kết"
        >
          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
          <span>Đã hoàn thành nhập</span>
        </span>
      );

    case 'GRADING_IN_PROGRESS':
      return (
        <span
          className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-indigo-50 text-indigo-800 border border-indigo-200/80 shadow-2xs ${className}`}
          title={isManuallyUnlocked ? 'Đang mở nhập điểm (được mở khóa thủ công 72h)' : 'Bảng điểm đang mở cho giảng viên chấm điểm'}
        >
          {isManuallyUnlocked ? (
            <Unlock className="w-3.5 h-3.5 text-indigo-600 shrink-0" />
          ) : (
            <Edit3 className="w-3.5 h-3.5 text-indigo-600 shrink-0" />
          )}
          <span>{isManuallyUnlocked ? 'Đang mở (Thủ công)' : 'Đang mở nhập'}</span>
        </span>
      );

    case 'NO_STUDENTS':
      return (
        <span
          className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-slate-100 text-slate-700 border border-slate-200/80 shadow-2xs ${className}`}
          title="Lớp học chưa có học viên nào trong danh sách chấm điểm"
        >
          <Users className="w-3.5 h-3.5 text-slate-500 shrink-0" />
          <span>Chưa có học viên</span>
        </span>
      );

    case 'NOT_OPEN':
    default:
      return (
        <span
          className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-zinc-100 text-zinc-600 border border-zinc-200 shadow-2xs ${className}`}
          title="Lớp đang lập kế hoạch, chưa mở sổ điểm"
        >
          <Clock className="w-3.5 h-3.5 text-zinc-500 shrink-0" />
          <span>Chưa mở sổ</span>
        </span>
      );
  }
};

/**
 * Badge hiển thị trạng thái Lớp học (Class Status)
 */
export const ClassStatusBadge = ({ status, className = '' }) => {
  switch (status) {
    case 'IN_PROGRESS':
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200 ${className}`}
        >
          <span className="w-1.5 h-1.5 rounded-full bg-blue-500 animate-pulse" />
          <span>Đang diễn ra</span>
        </span>
      );
    case 'OPEN_FOR_ENROLLMENT':
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-teal-50 text-teal-700 border border-teal-200 ${className}`}
        >
          <span className="w-1.5 h-1.5 rounded-full bg-teal-500" />
          <span>Đang mở ghi danh</span>
        </span>
      );
    case 'COMPLETED':
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-slate-100 text-slate-600 border border-slate-200 ${className}`}
        >
          <span>Đã hoàn thành</span>
        </span>
      );
    case 'PLANNING':
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200 ${className}`}
        >
          <span>Lập kế hoạch</span>
        </span>
      );
    case 'CANCELLED':
      return (
        <span
          className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-200 ${className}`}
        >
          <span>Đã hủy</span>
        </span>
      );
    default:
      return (
        <span
          className={`inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold bg-slate-100 text-slate-600 border border-slate-200 ${className}`}
        >
          {status}
        </span>
      );
  }
};
