import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { GraduationCap, LogOut, Menu, Calendar, Sparkles, Camera } from 'lucide-react';
import { ProfileModal } from '../profile/ProfileModal';
import { UserAvatar } from '../common/UserAvatar';

const roleMeta = {
  ADMIN: {
    label: 'Quản trị viên',
    badgeClass: 'bg-rose-950/80 text-rose-300 border-rose-800/60',
    dotClass: 'bg-rose-400',
    gradient: 'from-rose-500 to-pink-600',
  },
  ACADEMIC_STAFF: {
    label: 'Nhân viên học vụ',
    badgeClass: 'bg-purple-950/80 text-purple-300 border-purple-800/60',
    dotClass: 'bg-purple-400',
    gradient: 'from-purple-500 to-indigo-600',
  },
  TEACHER: {
    label: 'Giảng viên',
    badgeClass: 'bg-sky-950/80 text-sky-300 border-sky-800/60',
    dotClass: 'bg-sky-400',
    gradient: 'from-sky-500 to-blue-600',
  },
  STUDENT: {
    label: 'Học viên',
    badgeClass: 'bg-emerald-950/80 text-emerald-300 border-emerald-800/60',
    dotClass: 'bg-emerald-400',
    gradient: 'from-emerald-500 to-teal-600',
  },
  PARENT: {
    label: 'Phụ huynh',
    badgeClass: 'bg-amber-950/80 text-amber-300 border-amber-800/60',
    dotClass: 'bg-amber-400',
    gradient: 'from-amber-500 to-orange-600',
  },
};

export const Navbar = ({ onToggleMobileMenu }) => {
  const { user, logout } = useAuth();
  const [showProfileModal, setShowProfileModal] = useState(false);
  const currentRole = user?.role || 'STUDENT';
  const roleInfo = roleMeta[currentRole] || roleMeta.STUDENT;

  const todayFormatted = new Date().toLocaleDateString('vi-VN', {
    weekday: 'short',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });

  return (
    <>
      <header className="bg-slate-900/95 backdrop-blur-md border-b border-slate-800 shrink-0 z-30 px-4 sm:px-6 py-2.5 transition-all shadow-md text-white select-none">
        <div className="flex items-center justify-between gap-4 max-w-7xl mx-auto">
          
          {/* Brand & Mobile Trigger */}
          <div className="flex items-center gap-3">
            {onToggleMobileMenu && (
              <button
                type="button"
                onClick={onToggleMobileMenu}
                className="md:hidden p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-xl transition cursor-pointer active:scale-95"
                aria-label="Mở danh mục menu"
              >
                <Menu className="w-5 h-5" />
              </button>
            )}

            <div className="flex items-center gap-2.5">
              <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-indigo-500 to-indigo-600 flex items-center justify-center text-white shadow-lg shadow-indigo-500/25 ring-2 ring-indigo-400/20 shrink-0">
                <GraduationCap className="w-5 h-5" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-base font-black text-white tracking-tight">
                    SMART-EDU
                  </span>
                  <span className="hidden sm:inline-flex items-center gap-1 text-[10px] font-extrabold uppercase tracking-widest text-indigo-300 bg-indigo-950/80 border border-indigo-700/50 px-2 py-0.5 rounded-full shadow-2xs">
                    <Sparkles className="w-2.5 h-2.5 text-indigo-400" />
                    Center LMS
                  </span>
                </div>
                <p className="hidden md:block text-[11px] text-slate-400 font-medium">
                  Hệ thống Quản lý Đào tạo & Khảo thí Ngoại ngữ Chuẩn Quốc tế
                </p>
              </div>
            </div>
          </div>

          {/* Center / Status Indicator (Desktop) */}
          <div className="hidden lg:flex items-center gap-4 text-xs font-medium bg-slate-800/80 border border-slate-700/60 px-3.5 py-1.5 rounded-full shadow-2xs">
            <div className="flex items-center gap-2">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-400"></span>
              </span>
              <span className="text-[11px] font-bold text-slate-200">Hệ thống Trực tuyến</span>
            </div>
            <span className="text-slate-600">•</span>
            <div className="flex items-center gap-1.5 text-[11px] text-slate-300">
              <Calendar className="w-3.5 h-3.5 text-slate-400" />
              <span>{todayFormatted}</span>
            </div>
          </div>

          {/* User Profile & Logout Action */}
          <div className="flex items-center gap-3">
            {user && (
              <button
                type="button"
                onClick={() => setShowProfileModal(true)}
                className="flex items-center gap-2.5 bg-slate-800/90 hover:bg-slate-800 hover:border-indigo-500/50 transition border border-slate-700/70 py-1.5 px-3 rounded-2xl shadow-xs cursor-pointer group text-left active:scale-98"
                title="Xem hồ sơ & Đổi ảnh đại diện cá nhân"
              >
                <div className="relative">
                  <UserAvatar
                    avatarUrl={user.avatar_url}
                    name={user.full_name}
                    role={user.role}
                    size="sm"
                    shape="rounded-xl"
                  />
                  <div className="absolute -bottom-1 -right-1 w-3.5 h-3.5 rounded-full bg-slate-900 border border-slate-700 flex items-center justify-center text-slate-300 opacity-0 group-hover:opacity-100 transition shadow-2xs">
                    <Camera className="w-2 h-2 text-indigo-400" />
                  </div>
                </div>

                <div className="text-left hidden sm:block max-w-[140px] md:max-w-[180px]">
                  <div className="text-xs font-bold text-white leading-tight group-hover:text-indigo-300 transition-colors truncate">
                    {user.full_name}
                  </div>
                  <div className="flex items-center gap-1.5 mt-0.5">
                    <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${roleInfo.dotClass}`} />
                    <span className="text-[10px] font-semibold text-slate-300 truncate">
                      {roleInfo.label} • @{user.username}
                    </span>
                  </div>
                </div>
              </button>
            )}

            <button
              type="button"
              onClick={logout}
              className="group flex items-center gap-1.5 px-3.5 py-2 text-xs font-bold text-slate-300 hover:text-rose-400 hover:bg-rose-950/40 rounded-2xl transition-all border border-slate-700/70 hover:border-rose-800/60 cursor-pointer shadow-xs active:scale-95 shrink-0"
              title="Đăng xuất khỏi hệ thống"
            >
              <LogOut className="w-3.5 h-3.5 text-slate-400 group-hover:text-rose-400 transition-colors" />
              <span className="hidden sm:inline">Đăng xuất</span>
            </button>
          </div>

        </div>
      </header>

      {/* Profile & Avatar Modal (Portal to body) */}
      <ProfileModal
        isOpen={showProfileModal}
        onClose={() => setShowProfileModal(false)}
      />
    </>
  );
};
