import React from 'react';
import { useAuth } from '../../context/AuthContext';
import {
  LayoutDashboard,
  BookOpen,
  School,
  DoorOpen,
  CalendarDays,
  UserCheck,
  FileSpreadsheet,
  Award,
  Users,
  GraduationCap,
  ShieldAlert,
  X,
  ChevronRight,
  Sparkles
} from 'lucide-react';

export const Sidebar = ({
  currentTab,
  onTabChange,
  mobileOpen = false,
  onCloseMobile,
}) => {
  const { user } = useAuth();
  const role = user?.role || 'STUDENT';

  const menuGroups = [
    {
      groupName: 'TỔNG QUAN',
      items: [
        { id: 'dashboard', label: 'Bảng điều khiển', icon: LayoutDashboard, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
      ],
    },
    {
      groupName: 'CHƯƠNG TRÌNH & ĐÀO TẠO',
      items: [
        { id: 'courses', label: 'Khóa học & Cấp độ', icon: BookOpen, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT'] },
        { id: 'classes', label: 'Lớp học & Sĩ số', icon: School, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT'] },
        { id: 'classrooms', label: 'Phòng học & Cơ sở', icon: DoorOpen, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'] },
      ],
    },
    {
      groupName: 'LỊCH HỌC & TUYỂN SINH',
      items: [
        { id: 'schedules', label: 'Thời khóa biểu ma trận', icon: CalendarDays, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
        { id: 'enrollments', label: 'Đăng ký & Xét duyệt', icon: UserCheck, roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT'] },
      ],
    },
    {
      groupName: 'ĐÁNH GIÁ & TIẾN ĐỘ',
      items: [
        { id: 'grades', label: 'Sổ điểm & Kết quả', icon: FileSpreadsheet, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
        { id: 'progression', label: 'Lộ trình & Phụ huynh', icon: Award, roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT', 'PARENT'] },
      ],
    },
    {
      groupName: 'QUẢN TRỊ & NHÂN SỰ',
      items: [
        { id: 'students', label: 'Hồ sơ Học viên', icon: Users, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'] },
        { id: 'teachers', label: 'Hồ sơ Giáo viên', icon: GraduationCap, roles: ['ADMIN', 'ACADEMIC_STAFF'] },
        { id: 'accounts', label: 'Quản lý Tài khoản', icon: ShieldAlert, roles: ['ADMIN'] },
      ],
    },
  ];

  const sidebarContent = (
    <div className="flex flex-col h-full bg-slate-950 text-slate-300 w-64 select-none border-r border-slate-800/80 shadow-xl">
      
      {/* Header bar */}
      <div className="p-4 border-b border-slate-800/80 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-indigo-500 animate-pulse" />
          <span className="text-[11px] font-black uppercase tracking-wider text-slate-300">
            Hệ thống Quản trị
          </span>
        </div>
        {onCloseMobile && (
          <button
            onClick={onCloseMobile}
            className="md:hidden text-slate-400 hover:text-white p-1 rounded-lg cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {/* Nav Menu Items */}
      <nav className="p-3 space-y-4 flex-1 overflow-y-auto">
        {menuGroups.map((group, gIdx) => {
          const visibleItems = group.items.filter((item) => item.roles.includes(role));
          if (visibleItems.length === 0) return null;

          return (
            <div key={gIdx} className="space-y-1">
              <div className="px-3 text-[10px] font-black text-slate-300 uppercase tracking-widest mb-1.5 flex items-center justify-between">
                <span>{group.groupName}</span>
              </div>

              {visibleItems.map((item) => {
                const Icon = item.icon;
                const isActive = currentTab === item.id;

                return (
                  <button
                    key={item.id}
                    onClick={() => {
                      onTabChange(item.id);
                      if (onCloseMobile) onCloseMobile();
                    }}
                    className={`group w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-semibold transition-all duration-200 text-left cursor-pointer focus-visible:outline-hidden ${
                      isActive
                        ? 'bg-gradient-to-r from-indigo-600 to-indigo-500 text-white shadow-md shadow-indigo-600/30 font-bold'
                        : 'text-slate-400 hover:bg-slate-900/90 hover:text-slate-100 hover:translate-x-0.5'
                    }`}
                  >
                    <div className="flex items-center gap-2.5 truncate">
                      <Icon
                        className={`w-4 h-4 shrink-0 transition-transform duration-200 ${
                          isActive
                            ? 'text-white scale-110'
                            : 'text-slate-400 group-hover:text-indigo-400 group-hover:scale-110'
                        }`}
                      />
                      <span className="truncate">{item.label}</span>
                    </div>

                    {isActive && (
                      <ChevronRight className="w-3.5 h-3.5 text-white/80 shrink-0" />
                    )}
                  </button>
                );
              })}
            </div>
          );
        })}
      </nav>

      {/* Bottom Profile Footer */}
      <div className="p-3.5 border-t border-slate-800/80 bg-slate-900/60 text-[11px] text-slate-400">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="font-bold text-slate-300">FastAPI &bull; React 19</span>
          </div>
          <span className="text-[10px] font-mono text-emerald-400 font-bold bg-emerald-950/80 border border-emerald-700/50 px-2 py-0.5 rounded-full shadow-2xs flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
            V1.0
          </span>
        </div>
      </div>
    </div>
  );

  return (
    <>
      {/* Desktop Persistent Sidebar */}
      <aside className="hidden md:flex shrink-0 min-h-[calc(100vh-53px)] sticky top-[53px]">
        {sidebarContent}
      </aside>

      {/* Mobile Drawer Overlay */}
      {mobileOpen && (
        <div className="fixed inset-0 z-50 md:hidden flex">
          <div
            className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs transition-opacity"
            onClick={onCloseMobile}
          />
          <div className="relative z-10 animate-in slide-in-from-left duration-200">
            {sidebarContent}
          </div>
        </div>
      )}
    </>
  );
};
