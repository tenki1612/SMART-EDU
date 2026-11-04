import React, { useState, useEffect, useCallback } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ToastProvider } from './context/ToastContext';
import { ConfirmDialogProvider } from './context/ConfirmDialogContext';
import { HeaderSlotProvider, useSetHeaderSlot } from './context/HeaderSlotContext';
import { Navbar } from './components/layout/Navbar';
import { Sidebar } from './components/layout/Sidebar';
import { LoginView } from './views/LoginView';
import { DashboardView } from './views/DashboardView';
import { CoursesView } from './views/CoursesView';
import { ClassesView } from './views/ClassesView';
import { ClassroomsView } from './views/ClassroomsView';
import { SchedulesView } from './views/SchedulesView';
import { EnrollmentsView } from './views/EnrollmentsView';
import { GradesView } from './views/GradesView';
import { ProgressionParentView } from './views/ProgressionParentView';
import { StudentsView } from './views/StudentsView';
import { TeachersView } from './views/TeachersView';
import { AccountsView } from './views/AccountsView';
import {
  LayoutDashboard,
  BookOpen,
  School,
  DoorOpen,
  CalendarDays,
  ArrowUpRight,
  FileSpreadsheet,
  Award,
  UserCheck,
  Users,
  GraduationCap,
  ShieldAlert,
  ChevronRight,
  Home,
  PanelLeftClose,
  PanelLeftOpen
} from 'lucide-react';

const tabMetadata = {
  dashboard: { group: 'Tổng quan', label: 'Bảng điều khiển', icon: LayoutDashboard },
  courses: { group: 'Chương trình & Đào tạo', label: 'Khóa học', icon: BookOpen },
  classes: { group: 'Chương trình & Đào tạo', label: 'Lớp học', icon: School },
  classrooms: { group: 'Chương trình & Đào tạo', label: 'Phòng học & Cơ sở', icon: DoorOpen },
  schedules: { group: 'Lịch học & Đào tạo', label: 'Thời khóa biểu', icon: CalendarDays },
  enrollments: { group: 'Lịch học & Tuyển sinh', label: 'Đăng ký lớp học', icon: UserCheck },
  grades: { group: 'Đánh giá & Tiến độ', label: 'Sổ điểm & Kết quả', icon: FileSpreadsheet },
  progression: { group: 'Đánh giá & Tiến độ', label: 'Chuyển khóa học', icon: ArrowUpRight },
  students: { group: 'Quản trị & Nhân sự', label: 'Hồ sơ Học viên', icon: Users },
  teachers: { group: 'Quản trị & Nhân sự', label: 'Hồ sơ Giáo viên', icon: GraduationCap },
  accounts: { group: 'Quản trị & Nhân sự', label: 'Quản lý Tài khoản', icon: ShieldAlert },
};

const tabRolePermissions = {
  dashboard: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'],
  courses: ['ADMIN', 'ACADEMIC_STAFF'],
  classes: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT'],
  classrooms: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'],
  schedules: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'],
  enrollments: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT'],
  grades: ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER', 'STUDENT', 'PARENT'],
  progression: ['ADMIN', 'ACADEMIC_STAFF', 'STUDENT', 'PARENT'],
  students: ['ADMIN', 'ACADEMIC_STAFF'],
  teachers: ['ADMIN', 'ACADEMIC_STAFF'],
  accounts: ['ADMIN'],
};

const isTabAllowedForRole = (tab, role) => {
  if (!tab || !tabRolePermissions[tab]) return false;
  if (!role) return false;
  return tabRolePermissions[tab].includes(role);
};

const MainApp = () => {
  const { user, token, isLoading } = useAuth();
  
  // Khởi tạo tab từ query parameter trên URL (nếu có)
  const getInitialTab = () => {
    try {
      const params = new URLSearchParams(window.location.search);
      const tabParam = params.get('tab');
      if (tabParam && tabMetadata[tabParam]) {
        return tabParam;
      }
    } catch (e) {
      // ignore
    }
    return 'dashboard';
  };

  const [currentTab, setCurrentTab] = useState(getInitialTab);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const setHeaderSlot = useSetHeaderSlot();

  const prevUserIdRef = React.useRef(user?.id);

  // Đồng bộ tab sang thanh địa chỉ (Address bar query parameter: ?tab=...)
  const handleTabChange = useCallback((newTab) => {
    let targetTab = newTab;
    if (!isTabAllowedForRole(targetTab, user?.role)) {
      targetTab = 'dashboard';
    }
    setCurrentTab(targetTab);
    try {
      const url = new URL(window.location.href);
      url.searchParams.set('tab', targetTab);
      window.history.pushState({ tab: targetTab }, '', url.toString());
    } catch (e) {
      // ignore
    }
  }, [user?.role]);

  // Lắng nghe sự kiện Back / Forward của trình duyệt
  useEffect(() => {
    const handlePopState = () => {
      try {
        const params = new URLSearchParams(window.location.search);
        const tabParam = params.get('tab');
        if (tabParam && tabMetadata[tabParam] && isTabAllowedForRole(tabParam, user?.role)) {
          setCurrentTab(tabParam);
        } else {
          setCurrentTab('dashboard');
        }
      } catch (e) {
        // ignore
      }
    };
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, [user?.role]);

  // Điều hướng và chuyển về Bảng điều khiển khi đăng nhập hoặc chuyển tài khoản khác
  useEffect(() => {
    if (!user?.id) {
      prevUserIdRef.current = null;
      setCurrentTab('dashboard');
      return;
    }

    const justLoggedIn = sessionStorage.getItem('just_logged_in') === 'true';
    const isNewUser = prevUserIdRef.current !== user.id;

    if (justLoggedIn || isNewUser) {
      sessionStorage.removeItem('just_logged_in');
      sessionStorage.removeItem('just_logged_out');
      prevUserIdRef.current = user.id;
      handleTabChange('dashboard');
      return;
    }

    const params = new URLSearchParams(window.location.search);
    const tabParam = params.get('tab');
    if (tabParam && tabMetadata[tabParam]) {
      if (!isTabAllowedForRole(tabParam, user.role)) {
        handleTabChange('dashboard');
      } else {
        setCurrentTab(tabParam);
      }
    } else {
      handleTabChange('dashboard');
    }
  }, [user?.id, user?.role, handleTabChange]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-indigo-950 via-slate-900 to-slate-950 flex flex-col items-center justify-center text-white text-xs gap-3 font-semibold">
        <div className="w-8 h-8 border-3 border-indigo-500 border-t-transparent rounded-full animate-spin" />
        Đang khởi tạo phiên làm việc...
      </div>
    );
  }

  if (!token || !user) {
    return <LoginView />;
  }

  const currentMeta = tabMetadata[currentTab] || tabMetadata.dashboard;
  const TabIcon = currentMeta.icon;

  const renderContent = () => {
    switch (currentTab) {
      case 'dashboard':
        return <DashboardView onTabChange={handleTabChange} />;
      case 'courses':
        return <CoursesView />;
      case 'classes':
        return <ClassesView />;
      case 'classrooms':
        return <ClassroomsView />;
      case 'schedules':
        return <SchedulesView />;
      case 'enrollments':
        return <EnrollmentsView />;
      case 'progression':
        return <ProgressionParentView />;
      case 'grades':
        return <GradesView />;
      case 'students':
        return <StudentsView />;
      case 'teachers':
        return <TeachersView />;
      case 'accounts':
        return <AccountsView />;
      default:
        return <DashboardView onTabChange={handleTabChange} />;
    }
  };

  return (
    <div className="h-screen w-screen overflow-hidden flex flex-col bg-slate-100/90 text-slate-900 selection:bg-indigo-600 selection:text-white">
      <Navbar
        onToggleMobileMenu={() => setMobileMenuOpen(!mobileMenuOpen)}
        onToggleSidebar={() => setSidebarCollapsed(!sidebarCollapsed)}
        sidebarCollapsed={sidebarCollapsed}
      />
      <div className="flex-1 flex overflow-hidden min-h-0 w-full">
        <Sidebar
          currentTab={currentTab}
          onTabChange={handleTabChange}
          mobileOpen={mobileMenuOpen}
          onCloseMobile={() => setMobileMenuOpen(false)}
          collapsed={sidebarCollapsed}
          onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
        />
        <main className="flex-1 h-full overflow-y-auto min-h-0 min-w-0 bg-slate-100/90">
          <div className="p-4 sm:p-6 lg:p-7 max-w-7xl mx-auto w-full">
            {/* Function Title Header */}
            <div className="flex items-center justify-between gap-3 mb-5 px-4 py-2.5 bg-white rounded-2xl border border-slate-200/90 shadow-2xs">
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600 shadow-2xs shrink-0">
                  <TabIcon className="w-4 h-4" />
                </div>
                <h1 className="text-sm sm:text-base font-black text-slate-900 tracking-tight">
                  {currentMeta.label}
                </h1>
              </div>

              <div className="flex items-center gap-2.5">
                {/* Dynamic Action Buttons pushed from views */}
                <div ref={setHeaderSlot} className="flex items-center gap-2" />
              </div>
            </div>

            {/* Main View Content */}
            {renderContent()}
          </div>
        </main>
      </div>
    </div>
  );
};

export default function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <ConfirmDialogProvider>
          <HeaderSlotProvider>
            <MainApp />
          </HeaderSlotProvider>
        </ConfirmDialogProvider>
      </ToastProvider>
    </AuthProvider>
  );
}
