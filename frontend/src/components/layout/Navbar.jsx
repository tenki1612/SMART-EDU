import React from 'react';
import { useAuth } from '../../context/AuthContext';
import { GraduationCap, LogOut, Menu } from 'lucide-react';
const roleMeta = {
    ADMIN: {
        label: 'Quản trị viên',
        badgeClass: 'bg-rose-50 text-rose-700 border-rose-200/80',
        dotClass: 'bg-rose-500',
    },
    ACADEMIC_STAFF: {
        label: 'Nhân viên học vụ',
        badgeClass: 'bg-purple-50 text-purple-700 border-purple-200/80',
        dotClass: 'bg-purple-500',
    },
    TEACHER: {
        label: 'Giáo viên',
        badgeClass: 'bg-sky-50 text-sky-700 border-sky-200/80',
        dotClass: 'bg-sky-500',
    },
    STUDENT: {
        label: 'Học viên',
        badgeClass: 'bg-emerald-50 text-emerald-700 border-emerald-200/80',
        dotClass: 'bg-emerald-500',
    },
    PARENT: {
        label: 'Phụ huynh',
        badgeClass: 'bg-amber-50 text-amber-800 border-amber-200/80',
        dotClass: 'bg-amber-500',
    },
};
export const Navbar = ({ onToggleMobileMenu }) => {
    const { user, logout } = useAuth();
    const currentRole = user?.role || 'STUDENT';
    const roleInfo = roleMeta[currentRole];
    return (<header className="bg-white/90 backdrop-blur-md border-b border-slate-200/80 sticky top-0 z-40 px-4 sm:px-6 py-2.5 transition-all">
      <div className="flex items-center justify-between gap-3 max-w-7xl mx-auto">
        {/* Brand & Mobile Trigger */}
        <div className="flex items-center gap-3">
          {onToggleMobileMenu && (<button onClick={onToggleMobileMenu} className="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-xl transition cursor-pointer" aria-label="Mở danh mục menu">
              <Menu className="w-5 h-5"/>
            </button>)}

          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-indigo-700 to-indigo-500 flex items-center justify-center text-white shadow-sm shadow-indigo-200">
              <GraduationCap className="w-5 h-5"/>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-base font-extrabold text-slate-900 tracking-tight">
                  SMART-EDU
                </span>
                <span className="hidden sm:inline-flex items-center text-[10px] font-bold uppercase tracking-wider text-indigo-700 bg-indigo-50 border border-indigo-200/60 px-1.5 py-0.2 rounded-md">
                  Center LMS
                </span>
              </div>
              <p className="hidden md:block text-[11px] text-slate-400 font-medium">
                Hệ thống Quản lý Trung tâm Ngoại ngữ
              </p>
            </div>
          </div>
        </div>

        {/* User Profile & Logout Action */}
        <div className="flex items-center gap-3">
          {user && (<div className="flex items-center gap-2.5 bg-slate-50/80 border border-slate-200/80 py-1.5 px-3 rounded-xl">
              <div className="w-7 h-7 rounded-lg bg-indigo-600 text-white flex items-center justify-center font-bold text-xs shadow-2xs">
                {user.full_name.charAt(0).toUpperCase()}
              </div>
              <div className="text-left">
                <div className="text-xs font-bold text-slate-800 leading-tight">
                  {user.full_name}
                </div>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className={`w-1.5 h-1.5 rounded-full ${roleInfo.dotClass}`}/>
                  <span className="text-[10px] font-semibold text-slate-500">
                    {roleInfo.label} (@{user.username})
                  </span>
                </div>
              </div>
            </div>)}

          <button onClick={logout} className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-slate-600 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition border border-slate-200/60 hover:border-rose-200 cursor-pointer" title="Đăng xuất khỏi hệ thống">
            <LogOut className="w-3.5 h-3.5 text-slate-400 group-hover:text-rose-600"/>
            <span className="hidden sm:inline">Đăng xuất</span>
          </button>
        </div>
      </div>
    </header>);
};
