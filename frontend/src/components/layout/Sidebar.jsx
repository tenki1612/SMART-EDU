import React from 'react';
import { useAuth } from '../../context/AuthContext';
import {
  LayoutDashboard,
  BookOpen,
  School,
  DoorOpen,
  CalendarDays,
  FileSpreadsheet,
  Users,
  GraduationCap,
  ShieldAlert,
  X,
  ChevronRight,
  Layers,
  ArrowUpRight,
  UserCheck,
  PanelLeftClose,
  PanelLeftOpen
} from 'lucide-react';

export const Sidebar = ({
  currentTab,
  onTabChange,
  mobileOpen = false,
  onCloseMobile,
  collapsed = false,
  onToggleCollapse,
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
        { id: 'courses', label: 'Khóa học', icon: BookOpen, roles: ['ADMIN', 'ACADEMIC_STAFF'] },
        { id: 'classes', label: 'Lớp học', icon: School, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT'] },
        { id: 'classrooms', label: 'Phòng học & Cơ sở', icon: DoorOpen, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'] },
      ],
    },
    {
      groupName: 'LỊCH HỌC & TUYỂN SINH',
      items: [
        { id: 'schedules', label: 'Thời khóa biểu', icon: CalendarDays, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
        { id: 'enrollments', label: 'Đăng ký lớp học', icon: UserCheck, roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT'] },
      ],
    },
    {
      groupName: 'ĐÁNH GIÁ & TIẾN ĐỘ',
      items: [
        { id: 'grades', label: 'Sổ điểm & Kết quả', icon: FileSpreadsheet, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
        { id: 'progression', label: 'Chuyển khóa học', icon: ArrowUpRight, roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT', 'PARENT'] },
      ],
    },
    {
      groupName: 'QUẢN TRỊ & NHÂN SỰ',
      items: [
        { id: 'students', label: 'Hồ sơ Học viên', icon: Users, roles: ['ADMIN', 'ACADEMIC_STAFF'] },
        { id: 'teachers', label: 'Hồ sơ Giáo viên', icon: GraduationCap, roles: ['ADMIN', 'ACADEMIC_STAFF'] },
        { id: 'accounts', label: 'Quản lý Tài khoản', icon: ShieldAlert, roles: ['ADMIN'] },
      ],
    },
  ];

  const sidebarContent = (
    /* ── SIDEBAR: Pure White with Top-Right Collapse Button (No text) ─────── */
    <div
      className={`flex flex-col h-full select-none overflow-hidden bg-white border-r-2 border-slate-300 shadow-sm transition-all duration-300 ease-in-out ${
        collapsed ? 'w-[72px]' : 'w-64'
      }`}
    >
      {/* Header — Nút thu gọn sát lề trái */}
      <div className="shrink-0 bg-white border-b border-slate-100 px-2.5 py-2 flex items-center justify-between min-h-[50px]">
        {collapsed ? (
          <div className="w-full flex items-center justify-center">
            <button
              type="button"
              onClick={onToggleCollapse}
              className="w-10 h-10 rounded-xl hover:bg-indigo-50 hover:text-indigo-600 text-slate-500 flex items-center justify-center transition cursor-pointer active:scale-95 border border-slate-200/80 shadow-2xs group"
              title="Mở rộng menu"
              aria-label="Mở rộng menu"
            >
              <PanelLeftOpen className="w-5 h-5 text-indigo-600 group-hover:scale-110 transition-transform" />
            </button>
          </div>
        ) : (
          <div className="flex items-center justify-between w-full">
            <button
              type="button"
              onClick={onToggleCollapse}
              className="p-1.5 rounded-xl text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 border border-slate-200/80 transition cursor-pointer active:scale-95 shadow-2xs flex items-center justify-center"
              title="Thu gọn menu"
              aria-label="Thu gọn menu"
            >
              <PanelLeftClose className="w-4 h-4" />
            </button>

            {onCloseMobile && (
              <button
                type="button"
                onClick={onCloseMobile}
                className="md:hidden text-slate-400 hover:text-slate-700 p-1.5 rounded-lg cursor-pointer transition ml-0.5"
                aria-label="Đóng menu"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>
        )}
      </div>

      {/* Nav Menu Items */}
      <nav
        className="p-2 space-y-2.5 flex-1 overflow-y-auto min-h-0"
        style={{ scrollbarWidth: 'thin', scrollbarColor: '#e2e8f0 transparent' }}
      >
        {menuGroups.map((group, gIdx) => {
          const visibleItems = group.items.filter((item) => item.roles.includes(role));
          if (visibleItems.length === 0) return null;

          return (
            <div key={gIdx} className="space-y-0.5">
              {!collapsed ? (
                <div className="px-2.5 text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1 pt-1">
                  {group.groupName}
                </div>
              ) : (
                <div className="border-t border-slate-100 my-1.5" />
              )}

              {visibleItems.map((item) => {
                const Icon = item.icon;
                const isActive = currentTab === item.id;

                if (collapsed) {
                  return (
                    <button
                      key={item.id}
                      type="button"
                      title={item.label}
                      onClick={() => {
                        onTabChange(item.id);
                        if (onCloseMobile) onCloseMobile();
                      }}
                      className={`group relative w-full flex items-center justify-center py-2.5 rounded-xl transition-all cursor-pointer focus-visible:outline-hidden ${
                        isActive
                          ? 'bg-indigo-600 text-white shadow-sm'
                          : 'text-slate-500 hover:bg-slate-100 hover:text-indigo-600'
                      }`}
                    >
                      <Icon className="w-5 h-5 shrink-0" />
                      {isActive && (
                        <span className="absolute left-1 w-1 h-3 rounded-full bg-white" />
                      )}
                    </button>
                  );
                }

                return (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => {
                      onTabChange(item.id);
                      if (onCloseMobile) onCloseMobile();
                    }}
                    className={`group w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-semibold transition-all duration-150 text-left cursor-pointer focus-visible:outline-hidden ${
                      isActive
                        ? 'bg-indigo-600 text-white shadow-sm font-bold'
                        : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                    }`}
                  >
                    <div className="flex items-center gap-2.5 truncate">
                      <div
                        className={`w-7 h-7 rounded-lg flex items-center justify-center shrink-0 transition-all ${
                          isActive
                            ? 'bg-white/20 text-white'
                            : 'bg-slate-100 text-slate-500 group-hover:bg-indigo-50 group-hover:text-indigo-600'
                        }`}
                      >
                        <Icon className="w-3.5 h-3.5" />
                      </div>
                      <span className="truncate">{item.label}</span>
                    </div>

                    {isActive && (
                      <ChevronRight className="w-3.5 h-3.5 text-white/90 shrink-0" />
                    )}
                  </button>
                );
              })}
            </div>
          );
        })}
      </nav>

      {/* Bottom Footer */}
      <div className="px-3 py-2.5 border-t border-slate-100 bg-slate-50/70 text-[11px] shrink-0 min-h-[46px] flex items-center justify-between">
        {!collapsed ? (
          <>
            <div className="flex items-center gap-1.5 text-slate-400">
              <Layers className="w-3.5 h-3.5 text-indigo-500" />
              <span className="font-bold text-slate-600">FastAPI &bull; React 19</span>
            </div>
            <span className="text-[10px] font-mono font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              V1.0
            </span>
          </>
        ) : (
          <div className="w-full flex items-center justify-center" title="LMS V1.0">
            <span className="w-2 h-2 rounded-full bg-emerald-500" />
          </div>
        )}
      </div>
    </div>
  );

  return (
    <>
      {/* Desktop Sidebar (Permanent) */}
      <aside className="hidden md:block h-full shrink-0">
        {sidebarContent}
      </aside>

      {/* Mobile Drawer */}
      {mobileOpen && (
        <div className="fixed inset-0 z-50 md:hidden flex">
          <div
            className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs transition-opacity"
            onClick={onCloseMobile}
            aria-hidden="true"
          />
          <div className="relative z-10 h-full">
            {sidebarContent}
          </div>
        </div>
      )}
    </>
  );
};
