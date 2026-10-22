import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { UserAvatar } from '../components/common/UserAvatar';
import { studentsApi } from '../services/api';
import { useToast } from '../context/ToastContext';
import { 
  Search, History, Users, GraduationCap, CheckCircle2, 
  Clock, MapPin, Phone, Mail, X, BookOpen, Award, ArrowUpRight
} from 'lucide-react';

const statusMeta = {
  STUDYING: { label: 'Đang theo học', bg: 'bg-emerald-50 text-emerald-700 border-emerald-200/80', dot: 'bg-emerald-500' },
  GRADUATED: { label: 'Đã tốt nghiệp', bg: 'bg-indigo-50 text-indigo-700 border-indigo-200/80', dot: 'bg-indigo-500' },
  RESERVED: { label: 'Bảo lưu kết quả', bg: 'bg-amber-50 text-amber-800 border-amber-200/80', dot: 'bg-amber-500' },
  DROPPED: { label: 'Đã thôi học', bg: 'bg-rose-50 text-rose-700 border-rose-200/80', dot: 'bg-rose-500' },
};

export const StudentsView = () => {
  const toast = useToast();
  const [students, setStudents] = useState([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [selectedHistory, setSelectedHistory] = useState(null);
  const [isLoadingHistory, setIsLoadingHistory] = useState(false);

  const loadStudents = async () => {
    try {
      const res = await studentsApi.list(search);
      setStudents(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi khi tải danh sách học viên: ' + e.message);
    }
  };

  useEffect(() => {
    loadStudents();
  }, [search]);

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
      
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600">
              <Users className="w-4 h-4" />
            </div>
            Hồ sơ & Lịch sử Học viên
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Tra cứu thông tin cá nhân, tình trạng đào tạo và hồ sơ tiến trình học tập của học viên.
          </p>
        </div>
      </div>

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
      <div className="bg-white p-3.5 rounded-2xl border border-slate-200/80 shadow-xs flex flex-col md:flex-row md:items-center justify-between gap-3">
        {/* Status Filter Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0">
          {[
            { key: 'ALL', label: 'Tất cả', count: totalCount },
            { key: 'STUDYING', label: 'Đang học', count: studyingCount },
            { key: 'GRADUATED', label: 'Tốt nghiệp', count: graduatedCount },
            { key: 'RESERVED', label: 'Bảo lưu', count: reservedCount },
          ].map(f => (
            <button
              key={f.key}
              onClick={() => setStatusFilter(f.key)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap flex items-center gap-1.5 ${
                statusFilter === f.key
                  ? 'bg-indigo-600 text-white shadow-xs'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200/70'
              }`}
            >
              <span>{f.label}</span>
              <span className={`text-[10px] px-1.5 py-0.2 rounded-full font-mono ${
                statusFilter === f.key ? 'bg-indigo-700 text-white' : 'bg-slate-200 text-slate-700'
              }`}>
                {f.count}
              </span>
            </button>
          ))}
        </div>

        {/* Search input */}
        <div className="relative md:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Tìm mã HV, họ tên, email, sđt..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden text-xs font-medium transition"
          />
        </div>
      </div>

      {/* Main Student Data Table */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/90 border-b border-slate-200 text-[11px] font-black uppercase tracking-wider text-slate-500">
              <tr>
                <th className="py-3 px-4">Mã học viên</th>
                <th className="py-3 px-4">Họ và tên</th>
                <th className="py-3 px-4">Thông tin liên hệ</th>
                <th className="py-3 px-4">Địa chỉ cư trú</th>
                <th className="py-3 px-4 text-center">Trạng thái</th>
                <th className="py-3 px-4 text-right">Lịch sử học tập</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredStudents.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-slate-400">
                    <Users className="w-8 h-8 mx-auto mb-2 opacity-40 text-slate-400" />
                    Không tìm thấy học viên nào phù hợp với bộ lọc hiện tại.
                  </td>
                </tr>
              ) : (
                filteredStudents.map((st) => {
                  const sMeta = statusMeta[st.status] || {
                    label: st.status,
                    bg: 'bg-slate-100 text-slate-700 border-slate-200',
                    dot: 'bg-slate-400'
                  };

                  return (
                    <tr key={st.id} className="hover:bg-slate-50/80 transition-colors">
                      <td className="py-3.5 px-4 font-mono font-black text-indigo-600">
                        {st.student_code}
                      </td>
                      <td className="py-3.5 px-4">
                        <div className="flex items-center gap-3">
                          <UserAvatar
                            name={st.full_name}
                            avatarUrl={st.avatar_url}
                            size="sm"
                            className="rounded-xl shrink-0"
                          />
                          <div>
                            <span className="font-bold text-slate-900 block leading-tight">{st.full_name}</span>
                            <span className="text-[10px] text-slate-400 font-medium">
                              Sinh ngày: {st.date_of_birth || '--'}
                            </span>
                          </div>
                        </div>
                      </td>
                      <td className="py-3.5 px-4 text-slate-600">
                        <div className="space-y-0.5">
                          <div className="flex items-center gap-1.5 text-[11px]">
                            <Mail className="w-3 h-3 text-slate-400 shrink-0" />
                            <span className="truncate max-w-[180px]">{st.email}</span>
                          </div>
                          {st.phone && (
                            <div className="flex items-center gap-1.5 text-[11px] text-slate-500 font-mono">
                              <Phone className="w-3 h-3 text-slate-400 shrink-0" />
                              <span>{st.phone}</span>
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3.5 px-4 text-slate-500 max-w-[200px] truncate">
                        <div className="flex items-center gap-1 text-[11px]">
                          <MapPin className="w-3 h-3 text-slate-400 shrink-0" />
                          <span className="truncate">{st.address || 'Chưa cập nhật'}</span>
                        </div>
                      </td>
                      <td className="py-3.5 px-4 text-center">
                        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold border shadow-2xs ${sMeta.bg}`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${sMeta.dot}`} />
                          {sMeta.label}
                        </span>
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        <button
                          onClick={() => handleViewHistory(st)}
                          className="inline-flex items-center gap-1.5 bg-indigo-50 hover:bg-indigo-100 active:scale-95 text-indigo-700 font-bold px-3 py-1.5 rounded-xl text-xs transition cursor-pointer border border-indigo-200/60 shadow-2xs"
                        >
                          <History className="w-3.5 h-3.5 text-indigo-600" />
                          <span>Xem lịch sử</span>
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

      {/* Learning History Modal */}
      {selectedHistory && createPortal(
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200/80">
            
            {/* Modal Header */}
            <div className="flex items-start justify-between pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <UserAvatar
                  name={selectedHistory.student.full_name}
                  avatarUrl={selectedHistory.student.avatar_url}
                  size="md"
                  className="rounded-2xl shrink-0 shadow-xs"
                />
                <div>
                  <h3 className="text-base font-black text-slate-900 tracking-tight">
                    Lịch sử quá trình học tập
                  </h3>
                  <p className="text-xs text-slate-500 font-medium">
                    Học viên: <strong className="text-slate-800">{selectedHistory.student.full_name}</strong> &bull; Mã: <span className="font-mono text-indigo-600 font-bold">{selectedHistory.student.student_code}</span>
                  </p>
                </div>
              </div>
              <button
                onClick={() => setSelectedHistory(null)}
                className="w-8 h-8 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-500 flex items-center justify-center transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="mt-5 max-h-80 overflow-y-auto">
              {selectedHistory.history.length === 0 ? (
                <div className="text-center py-10">
                  <BookOpen className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-xs text-slate-400 font-medium">
                    Học viên chưa có lịch sử lớp học nào trong hệ thống.
                  </p>
                </div>
              ) : (
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 text-slate-500 font-bold uppercase text-[10px] tracking-wider border-b border-slate-100">
                    <tr>
                      <th className="py-2.5 px-3">Mã lớp</th>
                      <th className="py-2.5 px-3">Khóa học / Cấp độ</th>
                      <th className="py-2.5 px-3">Ngày ghi danh</th>
                      <th className="py-2.5 px-3 text-center">Tổng điểm</th>
                      <th className="py-2.5 px-3 text-center">Kết quả</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {selectedHistory.history.map((h, i) => (
                      <tr key={i} className="hover:bg-slate-50 transition-colors">
                        <td className="py-3 px-3 font-mono font-bold text-indigo-700">
                          {h.class_code}
                        </td>
                        <td className="py-3 px-3">
                          <div className="font-bold text-slate-800">{h.course_title}</div>
                          <span className="text-[10px] font-semibold text-indigo-600 bg-indigo-50 px-1.5 py-0.2 rounded border border-indigo-100">
                            {h.target_level}
                          </span>
                        </td>
                        <td className="py-3 px-3 text-slate-500 font-medium">
                          {new Date(h.enrolled_at).toLocaleDateString('vi-VN')}
                        </td>
                        <td className="py-3 px-3 text-center font-mono font-bold text-slate-900">
                          {h.total_score != null ? h.total_score : '--'}
                        </td>
                        <td className="py-3 px-3 text-center">
                          <span
                            className={`px-2.5 py-0.5 rounded-full font-bold text-[10px] border ${
                              h.result_status === 'PASSED'
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                                : h.result_status === 'FAILED'
                                ? 'bg-rose-50 text-rose-700 border-rose-200'
                                : 'bg-amber-50 text-amber-700 border-amber-200'
                            }`}
                          >
                            {h.result_status === 'PASSED' ? 'ĐẠT (PASSED)' : h.result_status === 'FAILED' ? 'CHƯA ĐẠT (FAILED)' : 'ĐANG HỌC'}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>

            {/* Modal Footer */}
            <div className="mt-6 pt-4 border-t border-slate-100 flex justify-end">
              <button
                onClick={() => setSelectedHistory(null)}
                className="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-bold text-xs transition cursor-pointer"
              >
                Đóng
              </button>
            </div>

          </div>
        </div>,
        document.body
      )}

    </div>
  );
};
