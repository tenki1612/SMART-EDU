import React, { useEffect, useState } from 'react';
import { teachersApi } from '../services/api';
import { Search, Calendar } from 'lucide-react';
export const TeachersView = () => {
    const [teachers, setTeachers] = useState([]);
    const [search, setSearch] = useState('');
    const [selectedSchedule, setSelectedSchedule] = useState(null);
    const loadTeachers = async () => {
        try {
            const res = await teachersApi.list(search);
            setTeachers(res.data || []);
        }
        catch (e) {
            console.error(e);
        }
    };
    useEffect(() => {
        loadTeachers();
    }, [search]);
    const handleViewSchedule = async (t) => {
        try {
            const res = await fetch(`http://localhost:8000/api/v1/teachers/${t.id}/schedule`, {
                headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
            });
            const data = await res.json();
            setSelectedSchedule({ teacher: t, schedule: data.data || [] });
        }
        catch (e) {
            alert(e.message);
        }
    };
    return (<div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-slate-800">
          05. Quản lý Hồ sơ Giáo viên (FR-25 đến FR-31)
        </h2>
        <p className="text-xs text-slate-500 mt-0.5">
          Theo dõi thông tin giảng viên, trình độ chuyên môn và lịch giảng dạy chi tiết.
        </p>
      </div>

      <div className="bg-white p-3 rounded-xl border border-slate-200 shadow-xs flex items-center gap-3">
        <Search className="w-4 h-4 text-slate-400"/>
        <input type="text" placeholder="Tìm kiếm giáo viên theo mã, họ tên, chuyên môn..." value={search} onChange={(e) => setSearch(e.target.value)} className="w-full text-xs outline-hidden text-slate-800"/>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {teachers.map((t) => (<div key={t.id} className="bg-white rounded-2xl border border-slate-200 p-5 shadow-xs flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="font-mono text-xs font-bold bg-indigo-50 text-indigo-700 px-2 py-0.5 rounded">
                  {t.teacher_code}
                </span>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                  {t.status}
                </span>
              </div>

              <h3 className="font-bold text-base text-slate-900">{t.full_name}</h3>
              <p className="text-xs text-slate-500">{t.email} • {t.phone || '--'}</p>

              <div className="mt-4 pt-3 border-t border-slate-100 space-y-2 text-xs">
                <div>
                  <span className="text-slate-500 font-medium">Chuyên môn chính:</span>
                  <p className="font-bold text-indigo-700 mt-0.5">{t.specialty}</p>
                </div>
                <div>
                  <span className="text-slate-500 font-medium">Bằng cấp:</span>
                  <p className="font-semibold text-slate-800 mt-0.5">{t.degree}</p>
                </div>
              </div>
            </div>

            <div className="mt-5 pt-3 border-t border-slate-100 flex justify-end">
              <button onClick={() => handleViewSchedule(t)} className="inline-flex items-center gap-1.5 bg-slate-100 hover:bg-indigo-50 text-slate-700 hover:text-indigo-600 font-semibold px-3 py-1.5 rounded-lg text-xs transition cursor-pointer">
                <Calendar className="w-3.5 h-3.5"/> Lịch dạy (FR-29)
              </button>
            </div>
          </div>))}
      </div>

      {/* Teacher Schedule Modal (FR-29) */}
      {selectedSchedule && (<div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-xl w-full p-6 shadow-xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="text-base font-bold text-slate-800 flex items-center gap-2">
                <Calendar className="w-4 h-4 text-indigo-600"/>
                Lịch giảng dạy: {selectedSchedule.teacher.full_name}
              </h3>
              <button onClick={() => setSelectedSchedule(null)} className="text-slate-400 hover:text-slate-600 font-bold text-sm cursor-pointer">
                ✕
              </button>
            </div>

            <div className="mt-4 max-h-80 overflow-y-auto space-y-2.5">
              {selectedSchedule.schedule.length === 0 ? (<p className="text-xs text-slate-500 py-6 text-center">
                  Giáo viên chưa có lịch dạy nào trong thời gian tới.
                </p>) : (selectedSchedule.schedule.map((s, idx) => (<div key={idx} className="p-3 bg-slate-50 border border-slate-100 rounded-xl text-xs flex items-center justify-between">
                    <div>
                      <div className="font-bold text-slate-800">{s.class_code} - {s.course_title}</div>
                      <div className="text-slate-500 mt-0.5">
                        Ngày: {s.session_date} • {s.start_time} - {s.end_time} ({s.slot_name})
                      </div>
                    </div>
                    <span className="font-bold bg-amber-100 text-amber-800 px-2 py-0.5 rounded text-[11px]">
                      Phòng {s.room_code}
                    </span>
                  </div>)))}
            </div>

            <div className="mt-5 pt-3 border-t border-slate-100 flex justify-end">
              <button onClick={() => setSelectedSchedule(null)} className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-semibold text-xs cursor-pointer">
                Đóng
              </button>
            </div>
          </div>
        </div>)}
    </div>);
};
