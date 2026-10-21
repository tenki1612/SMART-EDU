import React, { useEffect, useState } from 'react';
import { studentsApi } from '../services/api';
import { Search, History } from 'lucide-react';
export const StudentsView = () => {
    const [students, setStudents] = useState([]);
    const [search, setSearch] = useState('');
    const [selectedHistory, setSelectedHistory] = useState(null);
    const loadStudents = async () => {
        try {
            const res = await studentsApi.list(search);
            setStudents(res.data || []);
        }
        catch (e) {
            console.error(e);
        }
    };
    useEffect(() => {
        loadStudents();
    }, [search]);
    const handleViewHistory = async (st) => {
        try {
            const res = await studentsApi.getHistory(st.id);
            setSelectedHistory({ student: st, history: res.data || [] });
        }
        catch (e) {
            alert(e.message);
        }
    };
    return (<div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-slate-800">
          04. Quản lý Hồ sơ Học viên (FR-18 đến FR-24)
        </h2>
        <p className="text-xs text-slate-500 mt-0.5">
          Theo dõi thông tin cá nhân, tình trạng học tập và toàn bộ lịch sử các lớp đã/đang tham gia.
        </p>
      </div>

      <div className="bg-white p-3 rounded-xl border border-slate-200 shadow-xs flex items-center gap-3">
        <Search className="w-4 h-4 text-slate-400"/>
        <input type="text" placeholder="Tìm kiếm học viên theo mã, họ tên, email, sđt..." value={search} onChange={(e) => setSearch(e.target.value)} className="w-full text-xs outline-hidden text-slate-800"/>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 border-b border-slate-200 font-semibold text-slate-600 uppercase">
              <tr>
                <th className="p-4">Mã HV</th>
                <th className="p-4">Họ và tên</th>
                <th className="p-4">Email</th>
                <th className="p-4">Số điện thoại</th>
                <th className="p-4">Địa chỉ</th>
                <th className="p-4">Trạng thái (FR-23)</th>
                <th className="p-4 text-right">Lịch sử học</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {students.map((st) => (<tr key={st.id} className="hover:bg-slate-50/80 transition">
                  <td className="p-4 font-mono font-bold text-indigo-700">{st.student_code}</td>
                  <td className="p-4 font-bold text-slate-800">{st.full_name}</td>
                  <td className="p-4 text-slate-600">{st.email}</td>
                  <td className="p-4 text-slate-600">{st.phone || '--'}</td>
                  <td className="p-4 text-slate-500 max-w-xs truncate">{st.address || '--'}</td>
                  <td className="p-4">
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                      {st.status}
                    </span>
                  </td>
                  <td className="p-4 text-right">
                    <button onClick={() => handleViewHistory(st)} className="inline-flex items-center gap-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-semibold px-3 py-1.5 rounded-lg text-xs transition cursor-pointer">
                      <History className="w-3.5 h-3.5"/> Lịch sử học (FR-22)
                    </button>
                  </td>
                </tr>))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Learning History Modal (FR-22) */}
      {selectedHistory && (<div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="text-base font-bold text-slate-800 flex items-center gap-2">
                <History className="w-4 h-4 text-indigo-600"/>
                Lịch sử học tập: {selectedHistory.student.full_name} ({selectedHistory.student.student_code})
              </h3>
              <button onClick={() => setSelectedHistory(null)} className="text-slate-400 hover:text-slate-600 font-bold text-sm cursor-pointer">
                ✕
              </button>
            </div>

            <div className="mt-4 max-h-80 overflow-y-auto">
              {selectedHistory.history.length === 0 ? (<p className="text-xs text-slate-500 py-6 text-center">
                  Học viên chưa có lịch sử lớp học nào.
                </p>) : (<table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 text-slate-500 font-semibold border-b border-slate-100">
                    <tr>
                      <th className="p-2.5">Mã lớp</th>
                      <th className="p-2.5">Khóa học / Cấp độ</th>
                      <th className="p-2.5">Ngày tham gia</th>
                      <th className="p-2.5 text-center">Tổng điểm</th>
                      <th className="p-2.5 text-center">Kết quả</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {selectedHistory.history.map((h, i) => (<tr key={i} className="hover:bg-slate-50">
                        <td className="p-2.5 font-mono font-bold text-indigo-700">{h.class_code}</td>
                        <td className="p-2.5">
                          <div className="font-semibold text-slate-800">{h.course_title}</div>
                          <span className="text-[10px] text-slate-500">{h.target_level}</span>
                        </td>
                        <td className="p-2.5 text-slate-500">{new Date(h.enrolled_at).toLocaleDateString('vi-VN')}</td>
                        <td className="p-2.5 text-center font-bold text-indigo-700">{h.total_score || '--'}</td>
                        <td className="p-2.5 text-center">
                          <span className={`px-2 py-0.5 rounded-full font-bold text-[10px] ${h.result_status === 'PASSED'
                        ? 'bg-emerald-100 text-emerald-800'
                        : h.result_status === 'FAILED'
                            ? 'bg-red-100 text-red-800'
                            : 'bg-slate-100 text-slate-600'}`}>
                            {h.result_status || 'ĐANG HỌC'}
                          </span>
                        </td>
                      </tr>))}
                  </tbody>
                </table>)}
            </div>

            <div className="mt-5 pt-3 border-t border-slate-100 flex justify-end">
              <button onClick={() => setSelectedHistory(null)} className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-semibold text-xs cursor-pointer">
                Đóng
              </button>
            </div>
          </div>
        </div>)}
    </div>);
};
