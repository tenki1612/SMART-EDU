import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ToastProvider } from './context/ToastContext';
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
const MainApp = () => {
    const { user, token, isLoading } = useAuth();
    const [currentTab, setCurrentTab] = useState('dashboard');
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    if (isLoading) {
        return (<div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center text-white text-xs gap-3 font-semibold">
        <div className="w-8 h-8 border-3 border-indigo-500 border-t-transparent rounded-full animate-spin"/>
        Đang khởi tạo phiên làm việc...
      </div>);
    }
    if (!token || !user) {
        return <LoginView />;
    }
    const renderContent = () => {
        switch (currentTab) {
            case 'dashboard':
                return <DashboardView />;
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
            case 'grades':
                return <GradesView />;
            case 'progression':
                return <ProgressionParentView />;
            case 'students':
                return <StudentsView />;
            case 'teachers':
                return <TeachersView />;
            case 'accounts':
                return <AccountsView />;
            default:
                return <DashboardView />;
        }
    };
    return (<div className="min-h-screen flex flex-col bg-slate-50 text-slate-800">
      <Navbar onToggleMobileMenu={() => setMobileMenuOpen(!mobileMenuOpen)}/>
      <div className="flex flex-1">
        <Sidebar currentTab={currentTab} onTabChange={setCurrentTab} mobileOpen={mobileMenuOpen} onCloseMobile={() => setMobileMenuOpen(false)}/>
        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl mx-auto w-full">
          {renderContent()}
        </main>
      </div>
    </div>);
};
export function App() {
    return (<AuthProvider>
      <ToastProvider>
        <MainApp />
      </ToastProvider>
    </AuthProvider>);
}
export default App;
