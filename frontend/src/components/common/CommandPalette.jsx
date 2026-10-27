import React, { useState, useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../../context/AuthContext';
import {
  Search,
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
  ArrowRight,
  Sparkles,
  X,
  User,
  LogOut
} from 'lucide-react';

export const CommandPalette = ({
  isOpen,
  onClose,
  onSelectTab,
  onOpenProfile,
}) => {
  const { user, logout } = useAuth();
  const role = user?.role || 'STUDENT';
  const [query, setQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef(null);

  const allNavigationItems = [
    {
      id: 'dashboard',
      label: 'Bảng điều khiển',
      description: 'Tổng quan chỉ số hoạt động, thống kê điều hành & phím tắt nhanh',
      icon: LayoutDashboard,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'],
      category: 'Tổng quan',
    },
    {
      id: 'courses',
      label: 'Khóa học & Cấp độ',
      description: 'Quản lý danh mục chương trình đào tạo, mục tiêu IELTS & TOEIC, học phí',
      icon: BookOpen,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT'],
      category: 'Chương trình',
    },
    {
      id: 'classes',
      label: 'Lớp học & Sĩ số',
      description: 'Danh sách lớp đang mở, phân công giảng viên và theo dõi sĩ số thực tế',
      icon: School,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT'],
      category: 'Chương trình',
    },
    {
      id: 'classrooms',
      label: 'Phòng học & Cơ sở',
      description: 'Quản lý sức chứa, phòng học lý thuyết & chuyển bảo trì phòng máy',
      icon: DoorOpen,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'],
      category: 'Cơ sở vật chất',
    },
    {
      id: 'schedules',
      label: 'Thời khóa biểu ma trận',
      description: 'Lịch học 7 ngày, phát hiện xung đột phòng/giáo viên thời gian thực',
      icon: CalendarDays,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'],
      category: 'Lịch học',
    },
    {
      id: 'enrollments',
      label: 'Đăng ký & Xét duyệt',
      description: 'Ghi danh lớp học, xét duyệt học viên hoặc hủy đơn đăng ký',
      icon: UserCheck,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT'],
      category: 'Tuyển sinh',
    },
    {
      id: 'grades',
      label: 'Sổ điểm & Kết quả',
      description: 'Nhập điểm chuyên cần, giữa kỳ, cuối kỳ và xác nhận bảng điểm',
      icon: FileSpreadsheet,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'],
      category: 'Đánh giá',
    },
    {
      id: 'progression',
      label: 'Lộ trình & Phụ huynh',
      description: 'Kiểm tra điều kiện tiên quyết nâng khóa & cổng phụ huynh theo dõi con',
      icon: Award,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT', 'PARENT'],
      category: 'Đánh giá',
    },
    {
      id: 'students',
      label: 'Hồ sơ Học viên',
      description: 'Danh sách học viên, lịch sử đăng ký và bảng điểm học tập chi tiết',
      icon: Users,
      roles: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'],
      category: 'Nhân sự',
    },
    {
      id: 'teachers',
      label: 'Hồ sơ Giáo viên',
      description: 'Đội ngũ giảng viên, bằng cấp, chuyên môn và lịch giảng dạy',
      icon: GraduationCap,
      roles: ['ADMIN', 'ACADEMIC_STAFF'],
      category: 'Nhân sự',
    },
    {
      id: 'accounts',
      label: 'Quản lý Tài khoản',
      description: 'Phân quyền 5 vai trò, nâng quyền vai trò, khóa/mở khóa & reset mật khẩu',
      icon: ShieldAlert,
      roles: ['ADMIN'],
      category: 'Quản trị',
    },
  ];

  const allowedItems = allNavigationItems.filter((item) =>
    item.roles.includes(role)
  );

  const filteredItems = allowedItems.filter((item) => {
    if (!query.trim()) return true;
    const q = query.toLowerCase().trim();
    return (
      item.label.toLowerCase().includes(q) ||
      item.description.toLowerCase().includes(q) ||
      item.category.toLowerCase().includes(q)
    );
  });

  useEffect(() => {
    if (isOpen) {
      setQuery('');
      setSelectedIndex(0);
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [isOpen]);

  useEffect(() => {
    setSelectedIndex(0);
  }, [query]);

  // Keyboard navigation
  const handleKeyDown = (e) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setSelectedIndex((prev) =>
        prev < filteredItems.length - 1 ? prev + 1 : 0
      );
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setSelectedIndex((prev) =>
        prev > 0 ? prev - 1 : filteredItems.length - 1
      );
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (filteredItems[selectedIndex]) {
        handleSelect(filteredItems[selectedIndex].id);
      }
    } else if (e.key === 'Escape') {
      e.preventDefault();
      onClose();
    }
  };

  const handleSelect = (tabId) => {
    onSelectTab(tabId);
    onClose();
  };

  if (!isOpen) return null;

  return createPortal(
    <div
      className="fixed inset-0 z-50 flex items-start justify-center pt-16 sm:pt-24 p-4 bg-slate-950/70 backdrop-blur-xs animate-in fade-in duration-150 select-none"
      onClick={onClose}
    >
      <div
        className="w-full max-w-xl bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden transform transition-all animate-in zoom-in-95 duration-150 flex flex-col max-h-[80vh]"
        onClick={(e) => e.stopPropagation()}
        onKeyDown={handleKeyDown}
      >
        {/* Search Input Bar */}
        <div className="flex items-center gap-3 px-5 py-4 border-b border-slate-100 bg-slate-50/60">
          <Search className="w-5 h-5 text-indigo-500 shrink-0" />
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Tìm kiếm phân hệ, tác vụ hoặc tính năng... (Ctrl + K)"
            className="flex-1 bg-transparent text-sm font-semibold text-slate-800 placeholder:text-slate-400 placeholder:font-normal focus:outline-none"
          />
          {query ? (
            <button
              type="button"
              onClick={() => setQuery('')}
              className="text-slate-400 hover:text-slate-600 p-1 rounded-md"
            >
              <X className="w-4 h-4" />
            </button>
          ) : (
            <kbd className="hidden sm:inline-flex items-center gap-1 text-[10px] font-mono font-bold text-slate-400 bg-slate-200/60 px-2 py-0.5 rounded-md border border-slate-300/50">
              ESC
            </kbd>
          )}
        </div>

        {/* Results List */}
        <div className="flex-1 overflow-y-auto p-2.5 space-y-1">
          {filteredItems.length === 0 ? (
            <div className="py-12 text-center text-slate-400">
              <Search className="w-8 h-8 mx-auto mb-2 text-slate-300" />
              <p className="text-xs font-semibold text-slate-600">
                Không tìm thấy phân hệ phù hợp với "{query}"
              </p>
              <p className="text-[11px] text-slate-400 mt-1">
                Vui lòng thử tìm với từ khóa khác như "khóa học", "sổ điểm", "lịch"...
              </p>
            </div>
          ) : (
            filteredItems.map((item, index) => {
              const Icon = item.icon;
              const isSelected = index === selectedIndex;
              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => handleSelect(item.id)}
                  onMouseEnter={() => setSelectedIndex(index)}
                  className={`w-full flex items-center justify-between p-3 rounded-2xl text-left transition-all cursor-pointer ${
                    isSelected
                      ? 'bg-indigo-50/90 text-indigo-950 border border-indigo-100 shadow-2xs'
                      : 'hover:bg-slate-50 text-slate-700 border border-transparent'
                  }`}
                >
                  <div className="flex items-center gap-3.5 min-w-0">
                    <div
                      className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 transition-colors ${
                        isSelected
                          ? 'bg-indigo-600 text-white shadow-sm shadow-indigo-300'
                          : 'bg-slate-100 text-slate-500'
                      }`}
                    >
                      <Icon className="w-5 h-5" />
                    </div>
                    <div className="min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-bold truncate">
                          {item.label}
                        </span>
                        <span className="text-[10px] font-semibold text-slate-400 bg-slate-100 px-2 py-0.5 rounded-full">
                          {item.category}
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-500 font-medium truncate mt-0.5">
                        {item.description}
                      </p>
                    </div>
                  </div>
                  <ArrowRight
                    className={`w-4 h-4 shrink-0 transition-transform ${
                      isSelected
                        ? 'text-indigo-600 translate-x-1'
                        : 'text-slate-300 opacity-0 group-hover:opacity-100'
                    }`}
                  />
                </button>
              );
            })
          )}
        </div>

        {/* Footer Quick Actions */}
        <div className="px-4 py-3 bg-slate-50 border-t border-slate-100 flex items-center justify-between text-[11px] font-medium text-slate-500">
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => {
                onClose();
                if (onOpenProfile) onOpenProfile();
              }}
              className="flex items-center gap-1.5 hover:text-indigo-600 transition cursor-pointer font-bold"
            >
              <User className="w-3.5 h-3.5 text-indigo-500" />
              <span>Hồ sơ & Đổi Avatar</span>
            </button>
            <span>&bull;</span>
            <button
              type="button"
              onClick={() => {
                onClose();
                logout();
              }}
              className="flex items-center gap-1.5 hover:text-rose-600 transition cursor-pointer font-bold"
            >
              <LogOut className="w-3.5 h-3.5 text-rose-500" />
              <span>Đăng xuất</span>
            </button>
          </div>

          <div className="hidden sm:flex items-center gap-2 text-slate-400 text-[10px]">
            <span>Dùng phím</span>
            <kbd className="bg-white border border-slate-200 px-1.5 py-0.5 rounded shadow-2xs">↑</kbd>
            <kbd className="bg-white border border-slate-200 px-1.5 py-0.5 rounded shadow-2xs">↓</kbd>
            <span>để chọn</span>
            <kbd className="bg-white border border-slate-200 px-1.5 py-0.5 rounded shadow-2xs">Enter</kbd>
          </div>
        </div>
      </div>
    </div>,
    document.body
  );
};

