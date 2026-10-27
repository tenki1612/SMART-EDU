import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import {
  GraduationCap,
  LogOut,
  Menu,
  Sparkles,
  Camera,
  Bell
} from 'lucide-react';
import { ProfileModal } from '../profile/ProfileModal';
import { UserAvatar } from '../common/UserAvatar';

const roleMeta = {
  ADMIN: {
    label: 'Quản trị viên',
    badgeClass: 'bg-rose-950/70 text-rose-300 border-rose-800/60',
    dotClass: 'bg-rose-400',
    avatarRing: 'ring-rose-500',
  },
  ACADEMIC_STAFF: {
    label: 'Nhân viên học vụ',
    badgeClass: 'bg-purple-950/70 text-purple-300 border-purple-800/60',
    dotClass: 'bg-purple-400',
    avatarRing: 'ring-purple-500',
  },
  TEACHER: {
    label: 'Giảng viên',
    badgeClass: 'bg-sky-950/70 text-sky-300 border-sky-800/60',
    dotClass: 'bg-sky-400',
    avatarRing: 'ring-sky-500',
  },
  STUDENT: {
    label: 'Học viên',
    badgeClass: 'bg-emerald-950/70 text-emerald-300 border-emerald-800/60',
    dotClass: 'bg-emerald-400',
    avatarRing: 'ring-emerald-500',
  },
  PARENT: {
    label: 'Phụ huynh',
    badgeClass: 'bg-amber-950/70 text-amber-300 border-amber-800/60',
    dotClass: 'bg-amber-400',
    avatarRing: 'ring-amber-500',
  },
};

export const Navbar = ({
  onToggleMobileMenu,
  onToggleSidebar,
  sidebarCollapsed = false
}) => {
  const { user, logout } = useAuth();
  const [showProfileModal, setShowProfileModal] = useState(false);
  const currentRole = user?.role || 'STUDENT';
  const roleInfo = roleMeta[currentRole] || roleMeta.STUDENT;

  return (
    <>
      {/* ── NAVBAR: Distinct dark slate top frame ──────────────────────────── */}
      <header className="relative shrink-0 z-30 px-3 sm:px-6 py-2.5 select-none bg-slate-900 border-b border-slate-800 shadow-md">
        <div className="flex items-center justify-between gap-3 max-w-7xl mx-auto">

          {/* Brand & Mobile Trigger */}
          <div className="flex items-center gap-2.5 sm:gap-3">
            {/* Mobile Menu Trigger */}
            {onToggleMobileMenu && (
              <button
                type="button"
                onClick={onToggleMobileMenu}
                className="md:hidden p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-xl transition cursor-pointer active:scale-95"
                aria-label="Mở danh mục menu"
              >
                <Menu className="w-5 h-5" />
              </button>
            )}

            <div className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-indigo-500 to-violet-600 flex items-center justify-center text-white shadow-md shadow-indigo-950/50 shrink-0">
                <GraduationCap className="w-5 h-5" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-base font-black text-white tracking-tight">
                    SMART-EDU
                  </span>
                  <span className="hidden sm:inline-flex items-center gap-1 text-[10px] font-extrabold uppercase tracking-widest text-indigo-300 bg-indigo-950/80 border border-indigo-700/60 px-2 py-0.5 rounded-full">
                    <Sparkles className="w-2.5 h-2.5 text-indigo-400" />
                    LMS 2.0
                  </span>
                </div>
                <p className="hidden md:block text-[10px] text-slate-400 font-medium">
                  Hệ thống Quản lý Đào tạo &amp; Khảo thí Ngoại ngữ
                </p>
              </div>
            </div>
          </div>

          {/* Profile, Notifications & Logout */}
          <div className="flex items-center gap-2 sm:gap-2.5">
            {/* Notification Bell */}
            <button
              type="button"
              className="relative p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-xl transition cursor-pointer border border-slate-750 shadow-xs"
              title="Thông báo hệ thống"
            >
              <Bell className="w-4 h-4" />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-indigo-500 animate-pulse" />
            </button>

            {user && (
              <button
                type="button"
                onClick={() => setShowProfileModal(true)}
                className="flex items-center gap-2.5 bg-slate-800/90 hover:bg-slate-750 border border-slate-700/90 hover:border-slate-600 py-1.5 px-2.5 sm:px-3 rounded-2xl transition cursor-pointer group text-left shadow-xs"
                title="Hồ sơ cá nhân"
              >
                <div className="relative">
                  <UserAvatar
                    avatarUrl={user.avatar_url}
                    name={user.full_name}
                    role={user.role}
                    size="sm"
                    shape="rounded-xl"
                  />
                  <div className="absolute -bottom-1 -right-1 w-3.5 h-3.5 rounded-full bg-slate-700 text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition shadow-xs">
                    <Camera className="w-2 h-2 text-white" />
                  </div>
                </div>
                <div className="text-left hidden sm:block max-w-[130px] md:max-w-[170px]">
                  <div className="text-xs font-bold text-white leading-tight truncate">
                    {user.full_name}
                  </div>
                  <div className="flex items-center gap-1.5 mt-0.5">
                    <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${roleInfo.dotClass}`} />
                    <span className="text-[10px] font-bold text-slate-400 truncate">
                      {roleInfo.label}
                    </span>
                  </div>
                </div>
              </button>
            )}

            <button
              type="button"
              onClick={logout}
              className="group flex items-center gap-1.5 px-3 py-2 text-xs font-bold text-slate-300 hover:text-white hover:bg-rose-950/40 rounded-xl transition border border-slate-700/80 hover:border-rose-800/70 cursor-pointer shrink-0 shadow-xs"
              title="Đăng xuất"
            >
              <LogOut className="w-3.5 h-3.5 text-slate-400 group-hover:text-rose-400 transition-colors" />
              <span className="hidden sm:inline">Đăng xuất</span>
            </button>
          </div>
        </div>
      </header>

      <ProfileModal isOpen={showProfileModal} onClose={() => setShowProfileModal(false)} />
    </>
  );
};
