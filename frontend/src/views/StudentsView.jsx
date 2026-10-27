import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { UserAvatar } from '../components/common/UserAvatar';
import { studentsApi } from '../services/api';
import { useToast } from '../context/ToastContext';
import { useAuth } from '../context/AuthContext';
import { 
  Search, History, Users, GraduationCap, CheckCircle2, 
  Clock, MapPin, Phone, Mail, X, BookOpen, Award, ArrowUpRight,
  ShieldAlert, School
} from 'lucide-react';

const statusMeta = {
  STUDYING: { label: 'Đang theo học', bg: 'bg-emerald-50 text-emerald-700 border-emerald-200/80', dot: 'bg-emerald-500' },
  GRADUATED: { label: 'Đã tốt nghiệp', bg: 'bg-indigo-50 text-indigo-700 border-indigo-200/80', dot: 'bg-indigo-500' },
  RESERVED: { label: 'Bảo lưu kết quả', bg: 'bg-amber-50 text-amber-800 border-amber-200/80', dot: 'bg-amber-500' },
  DROPPED: { label: 'Đã thôi học', bg: 'bg-rose-50 text-rose-700 border-rose-200/80', dot: 'bg-rose-500' },
};

export const StudentsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const isTeacher = user?.role === 'TEACHER';

  const [students, setStudents] = useState([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [selectedHistory, setSelectedHistory] = useState(null);
  const [isLoadingHistory, setIsLoadingHistory] = useState(false);

  const loadStudents = async () => {
    if (isTeacher) return;
    try {
      const res = await studentsApi.list(search);
      setStudents(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi khi tải danh sách học viên: ' + e.message);
    }
  };

  useEffect(() => {
    if (!isTeacher) {
      loadStudents();
    }
  }, [search, isTeacher]);

  const handleViewHistory = async (st) => {
    setIsLoadingHistory(true);
    try {
      const res = await studentsApi.getHistory(st.id);
      setSelectedHistory({ student: st, history: res.data || [] });
    } catch (e) {
      toast.error('Không thể lấy lịch sử học tập: ' + e.message);
    } finally {
      setIsLoadingHistory(false);
    }
  };

  // Yêu cầu 8: Giảng viên không thể xem toàn bộ database của học sinh
  if (isTeacher) {
    return (
      <div className="bg-white rounded-3xl border border-slate-200/80 p-8 sm:p-12 text-center max-w-2xl mx-auto shadow-sm my-8">
        <div className="w-16 h-16 rounded-3xl bg-amber-50 border border-amber-200 text-amber-600 flex items-center justify-center mx-auto mb-4">
          <ShieldAlert className="w-8 h-8" />
        </div>
        <h3 className="text-lg font-black text-slate-900 tracking-tight">
          Quyền truy cập bị giới hạn đối với Giảng viên
        </h3>
        <p className="text-xs text-slate-500 mt-2 leading-relaxed">
          Theo chính sách bảo mật dữ liệu học tập, Giảng viên không thể xem toàn bộ cơ sở dữ liệu học sinh của toàn trung tâm.
        </p>
        <div className="mt-6 p-4 rounded-2xl bg-indigo-50/70 border border-indigo-100 text-xs text-indigo-900 text-left flex items-start gap-3">
          <School className="w-5 h-5 text-indigo-600 shrink-0 mt-0.5" />
          <div>
            <span className="font-bold block">Hướng dẫn dành cho Giảng viên:</span>
            <span>
              Để xem danh sách học sinh và điểm số của các lớp do mình trực tiếp phụ trách, vui lòng chuyển sang phân hệ <strong>Lớp học</strong> hoặc <strong>Sổ điểm & Kết quả</strong>.
            </span>
          </div>
        </div>
      </div>
    );
  }

  const filteredStudents = students.filter((s) => {
    if (statusFilter === 'ALL') return true;
    return s.status === statusFilter;
  });

  const totalCount = students.length;
  const studyingCount = students.filter(s => s.status === 'STUDYING').length;
  const graduatedCount = students.filter(s => s.status === 'GRADUATED').length;
  const reservedCount = students.filter(s => s.status === 'RESERVED').length;

  return (
    <div className="space-y-6">
      
      {/* KPI Metric Overview Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider block">Tổng học viên</span>
            <span className="text-2xl font-black text-slate-900 mt-0.5 block tabular-nums">{totalCount}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600">
            <Users className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-emerald-600 uppercase tracking-wider block">Đang theo học</span>
            <span className="text-2xl font-black text-emerald-700 mt-0.5 block tabular-nums">{studyingCount}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-200/60 flex items-center justify-center text-emerald-600">
            <CheckCircle2 className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-indigo-600 uppercase tracking-wider block">Đã tốt nghiệp</span>
            <span className="text-2xl font-black text-indigo-700 mt-0.5 block tabular-nums">{graduatedCount}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-200/60 flex items-center justify-center text-indigo-600">
            <GraduationCap className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-amber-600 uppercase tracking-wider block">Bảo lưu</span>
            <span className="text-2xl font-black text-amber-700 mt-0.5 block tabular-nums">{reservedCount}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-amber-50 border border-amber-200/60 flex items-center justify-center text-amber-600">
            <Clock className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex flex-col sm:flex-row items-center justify-between gap-3">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Tìm theo tên hoặc mã học viên..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:bg-white focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-hidden transition"
          />
        </div>

        <div className="flex items-center gap-1.5 overflow-x-auto w-full sm:w-auto pb-1 sm:pb-0">
          {[
            { id: 'ALL', label: 'Tất cả' },
            { id: 'STUDYING', label: 'Đang học' },
            { id: 'GRADUATED', label: 'Tốt nghiệp' },
            { id: 'RESERVED', label: 'Bảo lưu' },
            { id: 'DROPPED', label: 'Thôi học' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setStatusFilter(tab.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition whitespace-nowrap cursor-pointer ${
                statusFilter === tab.id
                  ? 'bg-indigo-600 text-white shadow-2xs'
                  : 'bg-slate-50 text-slate-600 hover:bg-slate-100'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Students Data Table */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200/80 text-[11px] font-black uppercase tracking-wider text-slate-500">
              <tr>
                <th className="p-3.5">Học viên</th>
                <th className="p-3.5">Mã học viên</th>
                <th className="p-3.5">Liên hệ</th>
                <th className="p-3.5">Trạng thái đào tạo</th>
                <th className="p-3.5 text-right">Lịch sử đào tạo</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredStudents.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-12 text-center text-slate-400">
                    <Users className="w-8 h-8 mx-auto mb-2 opacity-30" />
                    Không tìm thấy hồ sơ học viên phù hợp.
                  </td>
                </tr>
              ) : (
                filteredStudents.map((st) => {
                  const meta = statusMeta[st.status] || statusMeta.STUDYING;
                  return (
                    <tr key={st.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="p-3.5">
                        <div className="flex items-center gap-3">
                          <UserAvatar
                            name={st.full_name}
                            role="STUDENT"
                            size="md"
                            shape="rounded-xl"
                          />
                          <div>
                            <span className="font-bold text-slate-900 block leading-tight">{st.full_name}</span>
                            <span className="text-[11px] text-slate-400 font-mono mt-0.5 block">
                              Sinh ngày: {st.date_of_birth ? new Date(st.date_of_birth).toLocaleDateString('vi-VN') : '---'}
                            </span>
                          </div>
                        </div>
                      </td>
                      <td className="p-3.5">
                        <span className="font-mono font-bold text-indigo-600 bg-indigo-50 border border-indigo-200/60 px-2 py-0.5 rounded-md">
                          {st.student_code}
                        </span>
                      </td>
                      <td className="p-3.5 space-y-1">
                        <div className="flex items-center gap-1.5 text-slate-600">
                          <Mail className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                          <span className="truncate max-w-[150px]">{st.email}</span>
                        </div>
                        {st.phone && (
                          <div className="flex items-center gap-1.5 text-slate-500 font-mono">
                            <Phone className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                            <span>{st.phone}</span>
                          </div>
                        )}
                      </td>
                      <td className="p-3.5">
                        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wide border ${meta.bg}`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${meta.dot}`} />
                          {meta.label}
                        </span>
                      </td>
                      <td className="p-3.5 text-right">
                        <button
                          onClick={() => handleViewHistory(st)}
                          className="inline-flex items-center gap-1.5 bg-slate-50 hover:bg-indigo-50 text-slate-700 hover:text-indigo-700 border border-slate-200 hover:border-indigo-200 px-3 py-1.5 rounded-xl font-bold transition shadow-2xs cursor-pointer active:scale-95"
                          title="Xem lịch sử học tập & điểm số"
                        >
                          <History className="w-3.5 h-3.5 text-indigo-500" />
                          <span>Hồ sơ & Lịch sử</span>
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: Student History (Portal to body) */}
      {selectedHistory && createPortal(
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-xs">
          <div className="bg-white rounded-3xl border border-slate-200 shadow-2xl max-w-2xl w-full max-h-[85vh] flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            
            {/* Modal Header */}
            <div className="p-4 sm:p-5 border-b border-slate-100 flex items-center justify-between shrink-0 bg-slate-50/50">
              <div className="flex items-center gap-3">
                <UserAvatar
                  name={selectedHistory.student.full_name}
                  role="STUDENT"
                  size="md"
                  shape="rounded-xl"
                />
                <div>
                  <h3 className="font-extrabold text-sm text-slate-900 leading-tight">
                    {selectedHistory.student.full_name}
                  </h3>
                  <div className="flex items-center gap-2 mt-0.5 text-xs text-slate-500">
                    <span className="font-mono text-indigo-600 font-bold">
                      {selectedHistory.student.student_code}
                    </span>
                    <span>&bull;</span>
                    <span>{selectedHistory.student.email}</span>
                  </div>
                </div>
              </div>
              <button
                onClick={() => setSelectedHistory(null)}
                className="p-1.5 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-xl transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-4 sm:p-6 overflow-y-auto space-y-4 flex-1">
              <div className="flex items-center justify-between">
                <h4 className="text-xs font-black uppercase tracking-wider text-slate-600 flex items-center gap-1.5">
                  <BookOpen className="w-4 h-4 text-indigo-600" />
                  Tiến trình các lớp học & Kết quả đào tạo
                </h4>
                <span className="text-xs text-slate-400 font-mono">
                  {selectedHistory.history.length} lớp đã đăng ký
                </span>
              </div>

              {selectedHistory.history.length === 0 ? (
                <div className="py-12 text-center text-slate-400 bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                  <BookOpen className="w-8 h-8 mx-auto mb-2 opacity-30 text-slate-400" />
                  <p className="text-xs font-medium">Chưa có lịch sử học tập nào được ghi nhận cho học viên này.</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {selectedHistory.history.map((h, i) => (
                    <div
                      key={i}
                      className="p-3.5 rounded-2xl border border-slate-200/80 bg-slate-50/50 hover:bg-white transition flex flex-col sm:flex-row sm:items-center justify-between gap-3 shadow-2xs"
                    >
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-xs text-slate-900">{h.class_name}</span>
                          <span className="font-mono text-[10px] bg-slate-200/70 text-slate-700 px-1.5 py-0.5 rounded font-bold">
                            {h.class_code}
                          </span>
                        </div>
                        <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-3">
                          <span>Khóa học: <strong className="text-slate-700">{h.course_title}</strong></span>
                          <span>&bull;</span>
                          <span>Giảng viên: <strong className="text-slate-700">{h.teacher_name || 'Chưa phân công'}</strong></span>
                        </div>
                      </div>

                      <div className="flex items-center gap-3 shrink-0 self-end sm:self-center">
                        <div className="text-right">
                          <span className="text-[10px] uppercase font-bold text-slate-400 block">Tổng kết</span>
                          <span className={`text-sm font-black font-mono ${
                            h.total_score >= 5 ? 'text-emerald-600' : 'text-rose-600'
                          }`}>
                            {h.total_score !== null ? Number(h.total_score).toFixed(1) : '---'}
                          </span>
                        </div>
                        <div className="text-right">
                          <span className="text-[10px] uppercase font-bold text-slate-400 block">Trạng thái</span>
                          <span className={`inline-block px-2 py-0.5 rounded-full text-[10px] font-extrabold ${
                            h.status === 'PASSED'
                              ? 'bg-emerald-100 text-emerald-800'
                              : h.status === 'FAILED'
                              ? 'bg-rose-100 text-rose-800'
                              : 'bg-amber-100 text-amber-800'
                          }`}>
                            {h.status === 'PASSED' ? 'ĐẠT' : h.status === 'FAILED' ? 'CHƯA ĐẠT' : 'ĐANG HỌC'}
                          </span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Modal Footer */}
            <div className="p-3.5 sm:p-4 border-t border-slate-100 bg-slate-50 flex items-center justify-end shrink-0">
              <button
                type="button"
                onClick={() => setSelectedHistory(null)}
                className="px-4 py-2 rounded-xl bg-white border border-slate-200 text-slate-700 hover:bg-slate-100 text-xs font-bold transition cursor-pointer"
              >
                Đóng hồ sơ
              </button>
            </div>

          </div>
        </div>,
        document.body
      )}

    </div>
  );
};
