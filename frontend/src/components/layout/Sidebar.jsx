import React from 'react';
import { useAuth } from '../../context/AuthContext';
import { LayoutDashboard, BookOpen, School, DoorOpen, CalendarDays, UserCheck, FileSpreadsheet, Award, Users, GraduationCap, ShieldAlert, X, } from 'lucide-react';
export const Sidebar = ({ currentTab, onTabChange, mobileOpen = false, onCloseMobile, }) => {
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
                { id: 'classrooms', label: 'Phòng học', icon: DoorOpen, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'] },
            ],
        },
        {
            groupName: 'LỊCH HỌC & TUYỂN SINH',
            items: [
                { id: 'schedules', label: 'Thời khóa biểu & Xung đột', icon: CalendarDays, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
                { id: 'enrollments', label: 'Đăng ký & Xét duyệt', icon: UserCheck, roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT'] },
            ],
        },
        {
            groupName: 'ĐÁNH GIÁ & TIẾN ĐỘ',
            items: [
                { id: 'grades', label: 'Bảng điểm & Kết quả', icon: FileSpreadsheet, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'] },
                { id: 'progression', label: 'Chuyển khóa & Phụ huynh', icon: Award, roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT', 'PARENT'] },
            ],
        },
        {
            groupName: 'QUẢN LÝ NHÂN SỰ & HỆ THỐNG',
            items: [
                { id: 'students', label: 'Hồ sơ Học viên', icon: Users, roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'] },
                { id: 'teachers', label: 'Hồ sơ Giáo viên', icon: GraduationCap, roles: ['ADMIN', 'ACADEMIC_STAFF'] },
                { id: 'accounts', label: 'Quản lý Tài khoản', icon: ShieldAlert, roles: ['ADMIN'] },
            ],
        },
    ];
    const sidebarContent = (<div className="flex flex-col h-full bg-slate-900 text-slate-300 w-64 select-none border-r border-slate-800">
      <div className="p-4 border-b border-slate-800/80 flex items-center justify-between">
        <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
          Chức năng nghiệp vụ
        </span>
        {onCloseMobile && (<button onClick={onCloseMobile} className="md:hidden text-slate-400 hover:text-white p-1 rounded-lg cursor-pointer">
            <X className="w-4 h-4"/>
          </button>)}
      </div>

      <nav className="p-3 space-y-4 flex-1 overflow-y-auto">
        {menuGroups.map((group, gIdx) => {
            const visibleItems = group.items.filter((item) => item.roles.includes(role));
            if (visibleItems.length === 0)
                return null;
            return (<div key={gIdx} className="space-y-1">
              <div className="px-3 text-[10px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
                {group.groupName}
              </div>
              {visibleItems.map((item) => {
                    const Icon = item.icon;
                    const isActive = currentTab === item.id;
                    return (<button key={item.id} onClick={() => {
                            onTabChange(item.id);
                            if (onCloseMobile)
                                onCloseMobile();
                        }} className={`w-full flex items-center gap-3 px-3 py-2 rounded-xl text-xs font-semibold transition-all duration-150 text-left cursor-pointer focus-visible:outline-hidden focus-visible:ring-2 focus-visible:ring-indigo-400 ${isActive
                            ? 'bg-indigo-600 text-white shadow-xs font-bold'
                            : 'text-slate-400 hover:bg-slate-800 hover:text-slate-100'}`}>
                    <Icon className={`w-4 h-4 shrink-0 transition-colors ${isActive ? 'text-white' : 'text-slate-400'}`}/>
                    <span className="truncate">{item.label}</span>
                  </button>);
                })}
            </div>);
        })}
      </nav>

      <div className="p-3.5 border-t border-slate-800 bg-slate-950/60 text-[11px] text-slate-400">
        <div className="flex items-center justify-between">
          <span className="font-semibold text-slate-300">FastAPI &bull; React 19</span>
          <span className="text-[10px] font-mono text-emerald-400 font-bold bg-emerald-950/60 border border-emerald-800/40 px-1.5 rounded">ONLINE</span>
        </div>
      </div>
    </div>);
    return (<>
      {/* Desktop Persistent Sidebar */}
      <aside className="hidden md:flex shrink-0 min-h-[calc(100vh-53px)] sticky top-[53px]">
        {sidebarContent}
      </aside>

      {/* Mobile Drawer Overlay */}
      {mobileOpen && (<div className="fixed inset-0 z-50 md:hidden flex">
          <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs transition-opacity" onClick={onCloseMobile}/>
          <div className="relative z-10 animate-in slide-in-from-left duration-200">
            {sidebarContent}
          </div>
        </div>)}
    </>);
};
