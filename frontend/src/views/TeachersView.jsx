import React, { useEffect, useState } from 'react';
import { teachersApi } from '../services/api';
import { useToast } from '../context/ToastContext';
import { 
  GraduationCap, Search, Calendar, Award, BookOpen, 
  Mail, Phone, CheckCircle2, Clock, MapPin, X, ArrowUpRight
} from 'lucide-react';

export const TeachersView = () => {
  const toast = useToast();
  const [teachers, setTeachers] = useState([]);
  const [search, setSearch] = useState('');
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [isLoadingSchedule, setIsLoadingSchedule] = useState(false);

  const loadTeachers = async () => {
    try {
      const res = await teachersApi.list(search);
      setTeachers(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách giáo viên: ' + e.message);
    }
  };

  useEffect(() => {
    loadTeachers();
  }, [search]);

  const handleViewSchedule = async (t) => {
    setIsLoadingSchedule(true);
    try {
      const res = await teachersApi.getSchedule(t.id);
      setSelectedSchedule({ teacher: t, schedule: res.data || [] });
    } catch (e) {
      toast.error('Không thể tải lịch giảng dạy: ' + e.message);
    } finally {
      setIsLoadingSchedule(false);
    }
  };

  const totalTeachers = teachers.length;
  const activeTeachers = teachers.filter(t => t.status === 'ACTIVE' || !t.status).length;

  return (
    <div className="space-y-6">
      
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600">
              <GraduationCap className="w-4 h-4" />
            </div>
            Đội ngũ & Lịch giảng dạy Giảng viên
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Quản trị hồ sơ chuyên môn giảng viên, chứng chỉ quốc tế và điều phối thời khóa biểu giảng dạy.
          </p>
        </div>
      </div>

      {/* Overview Stat Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider block">Tổng số giảng viên</span>
            <span className="text-2xl font-black text-slate-900 mt-0.5 block tabular-nums">{totalTeachers}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600">
            <GraduationCap className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-emerald-600 uppercase tracking-wider block">Đang công tác</span>
            <span className="text-2xl font-black text-emerald-700 mt-0.5 block tabular-nums">{activeTeachers}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-200/60 flex items-center justify-center text-emerald-600">
            <CheckCircle2 className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-indigo-600 uppercase tracking-wider block">Chuyên môn IELTS</span>
            <span className="text-2xl font-black text-indigo-700 mt-0.5 block tabular-nums">
              {teachers.filter(t => (t.specialty || '').toUpperCase().includes('IELTS')).length}
            </span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-200/60 flex items-center justify-center text-indigo-600">
            <Award className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-purple-600 uppercase tracking-wider block">TOEIC / Giao tiếp</span>
            <span className="text-2xl font-black text-purple-700 mt-0.5 block tabular-nums">
              {teachers.filter(t => !(t.specialty || '').toUpperCase().includes('IELTS')).length}
            </span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-purple-50 border border-purple-200/60 flex items-center justify-center text-purple-600">
            <BookOpen className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Search Input Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200/80 shadow-xs flex items-center gap-3">
        <Search className="w-4 h-4 text-slate-400 shrink-0 ml-1" />
        <input
          type="text"
          placeholder="Tìm kiếm giảng viên theo mã (GV-...), họ tên, chuyên môn, bằng cấp..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full text-xs font-medium outline-hidden text-slate-800 placeholder:text-slate-400"
        />
      </div>

      {/* Teacher Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {teachers.length === 0 ? (
          <div className="col-span-full py-12 text-center text-slate-400 bg-white rounded-3xl border border-slate-200/80">
            <GraduationCap className="w-8 h-8 mx-auto mb-2 opacity-40 text-slate-400" />
            Không tìm thấy giảng viên nào phù hợp.
          </div>
        ) : (
          teachers.map((t) => (
            <div
              key={t.id}
              className="bg-white rounded-3xl border border-slate-200/80 p-5 shadow-xs hover:shadow-md hover:border-indigo-200 transition-all duration-200 flex flex-col justify-between group"
            >
              <div>
                {/* Card Top: Code & Status */}
                <div className="flex items-center justify-between mb-3.5">
                  <span className="font-mono text-xs font-black bg-indigo-50 text-indigo-700 border border-indigo-200/60 px-2.5 py-1 rounded-xl shadow-2xs">
                    {t.teacher_code}
                  </span>
                  <span className="inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200/80">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                    {t.status || 'ACTIVE'}
                  </span>
                </div>

                {/* Profile Info */}
                <div className="flex items-start gap-3">
                  <div className="w-11 h-11 rounded-2xl bg-gradient-to-tr from-indigo-600 to-violet-500 text-white flex items-center justify-center font-black text-sm shadow-md shadow-indigo-500/20 shrink-0">
                    {t.full_name?.charAt(0) || 'G'}
                  </div>
                  <div className="min-w-0">
                    <h3 className="font-black text-base text-slate-900 group-hover:text-indigo-600 transition-colors truncate">
                      {t.full_name}
                    </h3>
                    <div className="flex items-center gap-1 text-[11px] text-slate-500 mt-0.5 truncate">
                      <Mail className="w-3 h-3 text-slate-400 shrink-0" />
                      <span className="truncate">{t.email}</span>
                    </div>
                  </div>
                </div>

                {/* Professional Qualifications */}
                <div className="mt-4 pt-3.5 border-t border-slate-100 space-y-2.5 text-xs">
                  <div className="flex items-start gap-2">
                    <Award className="w-3.5 h-3.5 text-indigo-600 mt-0.5 shrink-0" />
                    <div>
                      <span className="text-[10px] uppercase font-bold text-slate-400 block tracking-wider">Chuyên môn</span>
                      <span className="font-bold text-indigo-700">{t.specialty || 'Chưa cập nhật'}</span>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <BookOpen className="w-3.5 h-3.5 text-slate-500 mt-0.5 shrink-0" />
                    <div>
                      <span className="text-[10px] uppercase font-bold text-slate-400 block tracking-wider">Học vị / Bằng cấp</span>
                      <span className="font-semibold text-slate-700">{t.degree || 'Chưa cập nhật'}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Button */}
              <div className="mt-5 pt-3.5 border-t border-slate-100 flex items-center justify-between">
                <div className="flex items-center gap-1 text-[11px] text-slate-400 font-mono">
                  <Phone className="w-3 h-3 text-slate-400" />
                  <span>{t.phone || '--'}</span>
                </div>
                <button
                  onClick={() => handleViewSchedule(t)}
                  className="inline-flex items-center gap-1.5 bg-slate-50 hover:bg-indigo-50 hover:text-indigo-700 hover:border-indigo-200 text-slate-700 font-bold px-3 py-1.5 rounded-xl text-xs transition-all border border-slate-200/80 cursor-pointer shadow-2xs active:scale-95"
                >
                  <Calendar className="w-3.5 h-3.5 text-indigo-600" />
                  <span>Lịch dạy</span>
                  <ArrowUpRight className="w-3 h-3 opacity-60" />
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Teacher Schedule Modal */}
      {selectedSchedule && (
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200/80">
            
            {/* Modal Header */}
            <div className="flex items-start justify-between pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600">
                  <Calendar className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900 tracking-tight">
                    Lịch giảng dạy chi tiết
                  </h3>
                  <p className="text-xs text-slate-500 font-medium">
                    Giảng viên: <strong className="text-slate-800">{selectedSchedule.teacher.full_name}</strong> &bull; Mã: <span className="font-mono text-indigo-600 font-bold">{selectedSchedule.teacher.teacher_code}</span>
                  </p>
                </div>
              </div>
              <button
                onClick={() => setSelectedSchedule(null)}
                className="w-8 h-8 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-500 flex items-center justify-center transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="mt-5 max-h-80 overflow-y-auto space-y-2.5">
              {selectedSchedule.schedule.length === 0 ? (
                <div className="text-center py-10">
                  <Calendar className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-xs text-slate-400 font-medium">
                    Giảng viên hiện không có lịch dạy nào trong thời gian tới.
                  </p>
                </div>
              ) : (
                selectedSchedule.schedule.map((s, idx) => (
                  <div
                    key={idx}
                    className="p-3.5 bg-slate-50/80 hover:bg-slate-100/80 transition-colors border border-slate-200/70 rounded-2xl text-xs flex items-center justify-between"
                  >
                    <div>
                      <div className="font-black text-slate-900 text-xs">
                        <span className="text-indigo-600 font-mono mr-1.5">{s.class_code}</span>
                        {s.course_title}
                      </div>
                      <div className="text-slate-500 text-[11px] mt-1 flex items-center gap-2">
                        <span className="font-medium">📅 {s.session_date}</span>
                        <span>•</span>
                        <span className="font-mono font-bold text-slate-700">{s.start_time} - {s.end_time}</span>
                        <span>({s.slot_name})</span>
                      </div>
                    </div>
                    <span className="font-bold bg-amber-50 text-amber-800 border border-amber-200/80 px-2.5 py-1 rounded-xl text-[11px] shadow-2xs">
                      Phòng {s.room_code}
                    </span>
                  </div>
                ))
              )}
            </div>

            {/* Modal Footer */}
            <div className="mt-6 pt-4 border-t border-slate-100 flex justify-end">
              <button
                onClick={() => setSelectedSchedule(null)}
                className="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-bold text-xs transition cursor-pointer"
              >
                Đóng
              </button>
            </div>

          </div>
        </div>
      )}

    </div>
  );
};
