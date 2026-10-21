import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { progressionParentApi, studentsApi, coursesApi } from '../services/api';
import { Award, ShieldCheck, CheckCircle2, User } from 'lucide-react';
export const ProgressionParentView = () => {
    const { user } = useAuth();
    const toast = useToast();
    const isParent = user?.role === 'PARENT';
    const canManageProgression = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');
    // Parent State
    const [wards, setWards] = useState([]);
    const [selectedWard, setSelectedWard] = useState(null);
    const [wardEnrollments, setWardEnrollments] = useState([]);
    // Staff Progression Checker State
    const [students, setStudents] = useState([]);
    const [courses, setCourses] = useState([]);
    const [checkForm, setCheckForm] = useState({
        student_id: 1,
        current_course_id: 1,
        next_course_id: 2,
        note: '',
    });
    const [eligibilityResult, setEligibilityResult] = useState(null);
    const loadData = async () => {
        try {
            if (isParent) {
                const res = await progressionParentApi.getParentWards();
                setWards(res.data || []);
                if (res.data && res.data.length > 0) {
                    setSelectedWard(res.data[0]);
                }
            }
            else {
                const [resSt, resCo] = await Promise.all([
                    studentsApi.list(),
                    coursesApi.list(),
                ]);
                setStudents(resSt.data || []);
                setCourses(resCo.data || []);
            }
        }
        catch (e) {
            console.error(e);
        }
    };
    useEffect(() => {
        loadData();
    }, [user?.role]);
    useEffect(() => {
        if (selectedWard && isParent) {
            progressionParentApi
                .getWardEnrollmentStatus(selectedWard.student_id)
                .then((res) => setWardEnrollments(res.data || []))
                .catch(console.error);
        }
    }, [selectedWard]);
    const handleCheckEligibility = async (e) => {
        e.preventDefault();
        try {
            const res = await progressionParentApi.checkEligibility(checkForm.student_id, checkForm.current_course_id, checkForm.next_course_id);
            setEligibilityResult(res.data);
            if (res.data?.is_eligible) {
                toast.success('Học viên đủ điều kiện nâng khóa!');
            }
            else {
                toast.warning('Học viên chưa đủ điều kiện tiên quyết.');
            }
        }
        catch (e) {
            toast.error(e.message);
        }
    };
    const handleConfirmEligibility = async (progressionId) => {
        try {
            const res = await progressionParentApi.confirmProgression(progressionId);
            setEligibilityResult(res.data);
            toast.success('Đã xác nhận đủ điều kiện nâng khóa thành công (FR-79)!');
        }
        catch (e) {
            toast.error(e.message);
        }
    };
    return (<div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-slate-800">
          11. Chuyển khóa học tiếp theo & Cổng Phụ huynh (FR-78 đến FR-82)
        </h2>
        <p className="text-xs text-slate-500 mt-0.5">
          Kiểm tra điều kiện chuyển cấp độ, xét duyệt lộ trình học nâng cao và theo dõi tiến độ học viên được giám hộ.
        </p>
      </div>

      {isParent ? (
        /* Parent Portal (FR-81, FR-82) */
        <div className="space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {wards.map((w) => (<div key={w.student_id} onClick={() => setSelectedWard(w)} className={`bg-white p-5 rounded-2xl border transition cursor-pointer shadow-xs ${selectedWard?.student_id === w.student_id
                    ? 'border-indigo-600 ring-2 ring-indigo-50'
                    : 'border-slate-200 hover:border-slate-300'}`}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
                      <User className="w-5 h-5"/>
                    </div>
                    <div>
                      <h4 className="font-bold text-slate-900 text-sm">{w.full_name}</h4>
                      <p className="text-xs text-slate-500 font-mono">{w.student_code} • {w.relationship_type}</p>
                    </div>
                  </div>
                  <span className="text-[10px] font-bold bg-emerald-100 text-emerald-800 px-2 py-0.5 rounded-full">
                    {w.latest_status}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-3 mt-4 pt-3 border-t border-slate-100 text-xs">
                  <div>
                    <span className="text-slate-500">Khóa học tham gia:</span>
                    <p className="font-bold text-slate-800 mt-0.5">{w.enrolled_courses_count} lớp</p>
                  </div>
                  <div>
                    <span className="text-slate-500">Điểm trung bình tích lũy:</span>
                    <p className="font-bold text-indigo-600 text-sm mt-0.5">{w.average_score || 'Chưa có'}</p>
                  </div>
                </div>
              </div>))}
          </div>

          {/* Ward Enrollment Status (FR-82) */}
          {selectedWard && (<div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
              <div className="p-4 border-b border-slate-100">
                <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
                  <Award className="w-4 h-4 text-indigo-600"/> Trạng thái đăng ký & Lịch sử học của con: {selectedWard.full_name} (FR-82)
                </h3>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 font-semibold text-slate-600 border-b border-slate-200 uppercase">
                    <tr>
                      <th className="p-4">Mã đơn</th>
                      <th className="p-4">Lớp đăng ký</th>
                      <th className="p-4">Khóa học / Cấp độ</th>
                      <th className="p-4">Ngày gửi đơn</th>
                      <th className="p-4">Trạng thái phê duyệt</th>
                      <th className="p-4">Ghi chú</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {wardEnrollments.length === 0 ? (<tr>
                        <td colSpan={6} className="p-6 text-center text-slate-400">
                          Học viên chưa có yêu cầu đăng ký nào gần đây.
                        </td>
                      </tr>) : (wardEnrollments.map((en) => (<tr key={en.id} className="hover:bg-slate-50">
                          <td className="p-4 font-mono font-bold text-slate-700">#{en.id}</td>
                          <td className="p-4 font-mono font-bold text-indigo-700">{en.class_code}</td>
                          <td className="p-4">
                            <div className="font-semibold text-slate-800">{en.course_title}</div>
                            <span className="text-[10px] text-slate-500">{en.target_level}</span>
                          </td>
                          <td className="p-4 text-slate-500">{new Date(en.request_date).toLocaleDateString('vi-VN')}</td>
                          <td className="p-4">
                            <span className={`px-2 py-0.5 rounded-full font-bold text-[10px] ${en.status === 'APPROVED'
                        ? 'bg-emerald-100 text-emerald-800'
                        : en.status === 'REJECTED'
                            ? 'bg-red-100 text-red-800'
                            : 'bg-amber-100 text-amber-800'}`}>
                              {en.status}
                            </span>
                          </td>
                          <td className="p-4 text-slate-600">{en.note || '--'}</td>
                        </tr>)))}
                  </tbody>
                </table>
              </div>
            </div>)}
        </div>) : (
        /* Staff / Admin Prerequisite Checker (FR-78, FR-79) */
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs space-y-5">
          <div>
            <h3 className="font-bold text-slate-800 text-sm flex items-center gap-2">
              <ShieldCheck className="w-4 h-4 text-indigo-600"/>
              Kiểm tra điều kiện đăng ký khóa học cao hơn (FR-78 & FR-79)
            </h3>
            <p className="text-xs text-slate-500 mt-1">
              Hệ thống tự động kiểm tra điểm số khóa học tiên quyết (bắt buộc phải đạt chuẩn đầu ra 'PASSED') trước khi cho phép học viên nâng cấp độ.
            </p>
          </div>

          <form onSubmit={handleCheckEligibility} className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
            <div>
              <label className="font-semibold text-slate-700 block mb-1">Chọn học viên:</label>
              <select value={checkForm.student_id} onChange={(e) => setCheckForm({ ...checkForm, student_id: Number(e.target.value) })} className="w-full border border-slate-300 p-2.5 rounded-xl bg-white outline-hidden focus:border-indigo-600">
                {students.map((st) => (<option key={st.id} value={st.id}>
                    {st.student_code} - {st.full_name}
                  </option>))}
              </select>
            </div>
            <div>
              <label className="font-semibold text-slate-700 block mb-1">Khóa học hiện tại:</label>
              <select value={checkForm.current_course_id} onChange={(e) => setCheckForm({ ...checkForm, current_course_id: Number(e.target.value) })} className="w-full border border-slate-300 p-2.5 rounded-xl bg-white outline-hidden focus:border-indigo-600">
                {courses.map((c) => (<option key={c.id} value={c.id}>
                    {c.code} ({c.target_level})
                  </option>))}
              </select>
            </div>
            <div>
              <label className="font-semibold text-slate-700 block mb-1">Khóa học mục tiêu tiếp theo:</label>
              <select value={checkForm.next_course_id} onChange={(e) => setCheckForm({ ...checkForm, next_course_id: Number(e.target.value) })} className="w-full border border-slate-300 p-2.5 rounded-xl bg-white outline-hidden focus:border-indigo-600">
                {courses.map((c) => (<option key={c.id} value={c.id}>
                    {c.code} ({c.target_level})
                  </option>))}
              </select>
            </div>
            <div className="sm:col-span-3 flex justify-end">
              <button type="submit" className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-xl text-xs shadow-xs transition cursor-pointer">
                Kiểm tra điều kiện (FR-78)
              </button>
            </div>
          </form>

          {/* Eligibility Result Banner */}
          {eligibilityResult && (<div className={`p-4 rounded-xl border text-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3 ${eligibilityResult.is_eligible
                    ? 'bg-emerald-50 border-emerald-200 text-emerald-900'
                    : 'bg-red-50 border-red-200 text-red-900'}`}>
              <div>
                <span className="font-bold text-sm block">
                  {eligibilityResult.is_eligible
                    ? '✓ Học viên ĐỦ ĐIỀU KIỆN học khóa tiếp theo!'
                    : '✕ Học viên CHƯA ĐỦ ĐIỀU KIỆN!'}
                </span>
                <p className="mt-1">{eligibilityResult.note}</p>
                <div className="mt-2 text-slate-600 font-medium">
                  Lộ trình: {eligibilityResult.current_course_title} &rarr; {eligibilityResult.next_course_title}
                </div>
              </div>

              {canManageProgression && eligibilityResult.is_eligible && (<div>
                  {eligibilityResult.is_confirmed ? (<span className="inline-flex items-center gap-1.5 bg-emerald-600 text-white font-bold px-3 py-1.5 rounded-xl text-xs">
                      <CheckCircle2 className="w-4 h-4"/> Đã xác nhận cho phép đăng ký (FR-79)
                    </span>) : (<button onClick={() => handleConfirmEligibility(eligibilityResult.id)} className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold px-4 py-2 rounded-xl text-xs shadow-xs cursor-pointer">
                      Xác nhận phê duyệt lên khóa (FR-79)
                    </button>)}
                </div>)}
            </div>)}
        </div>)}
    </div>);
};
