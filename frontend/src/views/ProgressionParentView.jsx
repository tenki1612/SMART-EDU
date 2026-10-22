import React, { useEffect, useState } from 'react';
import { UserAvatar } from '../components/common/UserAvatar';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { progressionParentApi, studentsApi, coursesApi } from '../services/api';
import { 
  Award, ShieldCheck, CheckCircle2, User, ArrowRight, 
  BookOpen, Sparkles, AlertTriangle, Calendar, Clock, ChevronRight
} from 'lucide-react';

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
  const [isChecking, setIsChecking] = useState(false);

  const loadData = async () => {
    try {
      if (isParent) {
        const res = await progressionParentApi.getParentWards();
        setWards(res.data || []);
        if (res.data && res.data.length > 0) {
          setSelectedWard(res.data[0]);
        }
      } else {
        const [resSt, resCo] = await Promise.all([
          studentsApi.list(),
          coursesApi.list(),
        ]);
        setStudents(resSt.data || []);
        setCourses(resCo.data || []);
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải dữ liệu lộ trình: ' + e.message);
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
        .catch((e) => toast.error('Lỗi tải thông tin đăng ký của con: ' + e.message));
    }
  }, [selectedWard]);

  const handleCheckEligibility = async (e) => {
    e.preventDefault();
    setIsChecking(true);
    try {
      const res = await progressionParentApi.checkEligibility(
        checkForm.student_id,
        checkForm.current_course_id,
        checkForm.next_course_id
      );
      setEligibilityResult(res.data);
      if (res.data?.is_eligible) {
        toast.success('Học viên đủ điều kiện nâng khóa tiếp theo!');
      } else {
        toast.warning('Học viên chưa đạt chuẩn đầu ra khóa tiên quyết.');
      }
    } catch (e) {
      toast.error(e.message);
    } finally {
      setIsChecking(false);
    }
  };

  const handleConfirmEligibility = async (progressionId) => {
    try {
      const res = await progressionParentApi.confirmProgression(progressionId);
      setEligibilityResult(res.data);
      toast.success('Đã xác nhận đủ điều kiện nâng khóa thành công!');
    } catch (e) {
      toast.error(e.message);
    }
  };

  return (
    <div className="space-y-6">
      
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600">
              <Award className="w-4 h-4" />
            </div>
            {isParent ? 'Cổng Theo Dõi Học Tập Của Con' : 'Lộ Trình & Điều Kiện Chuyển Khóa Học'}
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            {isParent
              ? 'Theo dõi sát sao tiến độ học tập, lịch đăng ký và kết quả các khóa học của con em.'
              : 'Kiểm tra chuẩn đầu ra điều kiện tiên quyết và phê duyệt nâng cấp độ học tiếp cho học viên.'}
          </p>
        </div>
      </div>

      {isParent ? (
        /* PARENT PORTAL */
        <div className="space-y-6">
          
          {/* Ward Selection Cards */}
          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">
              Danh sách con được giám hộ ({wards.length})
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {wards.map((w) => {
                const isSelected = selectedWard?.student_id === w.student_id;
                return (
                  <div
                    key={w.student_id}
                    onClick={() => setSelectedWard(w)}
                    className={`bg-white p-5 rounded-3xl border transition-all duration-200 cursor-pointer shadow-xs ${
                      isSelected
                        ? 'border-indigo-600 ring-4 ring-indigo-50 shadow-md'
                        : 'border-slate-200/80 hover:border-slate-300 hover:shadow-sm'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <UserAvatar
                          name={w.full_name}
                          avatarUrl={w.avatar_url}
                          size="md"
                          className="rounded-2xl shrink-0 shadow-sm"
                        />
                        <div>
                          <h4 className="font-black text-slate-900 text-sm">{w.full_name}</h4>
                          <p className="text-xs text-slate-500">
                            Mã: <span className="font-mono text-indigo-600 font-bold">{w.student_code}</span> &bull; {w.relationship_type || 'Con'}
                          </p>
                        </div>
                      </div>
                      <span className="text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200/80 px-2.5 py-0.5 rounded-full shadow-2xs">
                        {w.latest_status || 'Đang theo học'}
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-3 mt-4 pt-3.5 border-t border-slate-100 text-xs">
                      <div className="bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                        <span className="text-[11px] text-slate-500 font-medium block">Số lớp tham gia</span>
                        <span className="font-black text-slate-800 text-sm mt-0.5 block">{w.enrolled_courses_count} khóa học</span>
                      </div>
                      <div className="bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                        <span className="text-[11px] text-slate-500 font-medium block">Điểm trung bình (GPA)</span>
                        <span className="font-black text-indigo-600 text-sm mt-0.5 block tabular-nums">
                          {w.average_score != null ? `${w.average_score} / 10` : 'Đang cập nhật'}
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Ward Enrollment Status Table */}
          {selectedWard && (
            <div className="bg-white rounded-3xl border border-slate-200/80 shadow-xs overflow-hidden">
              <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-xl bg-indigo-50 border border-indigo-200/60 flex items-center justify-center text-indigo-600">
                    <BookOpen className="w-4 h-4" />
                  </div>
                  <div>
                    <h3 className="font-black text-slate-900 text-sm">
                      Hồ sơ đăng ký & Trạng thái xét duyệt: {selectedWard.full_name}
                    </h3>
                    <p className="text-[11px] text-slate-500">
                      Theo dõi quá trình ghi danh vào các lớp của trung tâm
                    </p>
                  </div>
                </div>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50/90 font-black text-slate-500 text-[10px] tracking-wider border-b border-slate-200 uppercase">
                    <tr>
                      <th className="py-3 px-4">Mã đơn</th>
                      <th className="py-3 px-4">Lớp đăng ký</th>
                      <th className="py-3 px-4">Khóa học / Cấp độ</th>
                      <th className="py-3 px-4">Ngày gửi yêu cầu</th>
                      <th className="py-3 px-4 text-center">Trạng thái phê duyệt</th>
                      <th className="py-3 px-4">Ghi chú</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {wardEnrollments.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="py-10 text-center text-slate-400">
                          Học viên chưa có yêu cầu ghi danh nào gần đây.
                        </td>
                      </tr>
                    ) : (
                      wardEnrollments.map((en) => (
                        <tr key={en.id} className="hover:bg-slate-50/80 transition-colors">
                          <td className="py-3 px-4 font-mono font-bold text-slate-500">#{en.id}</td>
                          <td className="py-3 px-4 font-mono font-black text-indigo-600">{en.class_code}</td>
                          <td className="py-3 px-4">
                            <span className="font-bold text-slate-900 block">{en.course_title}</span>
                            <span className="text-[10px] font-semibold text-indigo-600 bg-indigo-50 px-1.5 py-0.2 rounded border border-indigo-100">
                              {en.target_level}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-slate-500 font-medium">
                            {new Date(en.request_date).toLocaleDateString('vi-VN')}
                          </td>
                          <td className="py-3 px-4 text-center">
                            <span
                              className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full font-bold text-[10px] border shadow-2xs ${
                                en.status === 'APPROVED'
                                  ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                                  : en.status === 'REJECTED'
                                  ? 'bg-rose-50 text-rose-700 border-rose-200'
                                  : 'bg-amber-50 text-amber-800 border-amber-200'
                              }`}
                            >
                              <span
                                className={`w-1.5 h-1.5 rounded-full ${
                                  en.status === 'APPROVED' ? 'bg-emerald-500' : en.status === 'REJECTED' ? 'bg-rose-500' : 'bg-amber-500'
                                }`}
                              />
                              {en.status === 'APPROVED' ? 'Đã duyệt' : en.status === 'REJECTED' ? 'Từ chối' : 'Chờ duyệt'}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-slate-600 italic">{en.note || '--'}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

        </div>
      ) : (
        /* STAFF PREREQUISITE CHECKER */
        <div className="bg-white rounded-3xl border border-slate-200/80 p-6 sm:p-7 shadow-xs space-y-6">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-2xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600 shrink-0">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-black text-slate-900 text-base">
                Xét duyệt & Kiểm tra Điều kiện Tiên quyết Nâng khóa
              </h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Quy tắc nghiệp vụ: Hệ thống tự động kiểm tra điểm số của khóa học hiện tại (bắt buộc phải đạt chuẩn đầu ra 'PASSED') trước khi cho phép ghi danh vào khóa cấp độ cao hơn.
              </p>
            </div>
          </div>

          <form onSubmit={handleCheckEligibility} className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs pt-2">
            <div>
              <label className="font-bold text-slate-700 block mb-1.5">Học viên cần xét duyệt:</label>
              <select
                value={checkForm.student_id}
                onChange={(e) => setCheckForm({ ...checkForm, student_id: Number(e.target.value) })}
                className="w-full border border-slate-200 p-2.5 rounded-xl bg-slate-50 focus:bg-white outline-hidden focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 font-medium transition"
              >
                {students.map((st) => (
                  <option key={st.id} value={st.id}>
                    {st.student_code} - {st.full_name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="font-bold text-slate-700 block mb-1.5">Khóa học tiên quyết hiện tại:</label>
              <select
                value={checkForm.current_course_id}
                onChange={(e) => setCheckForm({ ...checkForm, current_course_id: Number(e.target.value) })}
                className="w-full border border-slate-200 p-2.5 rounded-xl bg-slate-50 focus:bg-white outline-hidden focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 font-medium transition"
              >
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.code} - {c.title} ({c.target_level})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="font-bold text-slate-700 block mb-1.5">Khóa học mục tiêu tiếp theo:</label>
              <select
                value={checkForm.next_course_id}
                onChange={(e) => setCheckForm({ ...checkForm, next_course_id: Number(e.target.value) })}
                className="w-full border border-slate-200 p-2.5 rounded-xl bg-slate-50 focus:bg-white outline-hidden focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 font-medium transition"
              >
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.code} - {c.title} ({c.target_level})
                  </option>
                ))}
              </select>
            </div>

            <div className="sm:col-span-3 flex justify-end pt-2">
              <button
                type="submit"
                disabled={isChecking}
                className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-bold rounded-xl text-xs shadow-md shadow-indigo-200 transition cursor-pointer flex items-center gap-2"
              >
                <ShieldCheck className="w-4 h-4" />
                <span>{isChecking ? 'Đang kiểm tra...' : 'Kiểm tra điều kiện tiên quyết'}</span>
              </button>
            </div>
          </form>

          {/* Eligibility Result Banner */}
          {eligibilityResult && (
            <div
              className={`p-5 rounded-2xl border text-xs flex flex-col sm:flex-row sm:items-center justify-between gap-4 transition-all ${
                eligibilityResult.is_eligible
                  ? 'bg-emerald-50 border-emerald-200 text-emerald-950 shadow-xs'
                  : 'bg-rose-50 border-rose-200 text-rose-950 shadow-xs'
              }`}
            >
              <div>
                <span className="font-black text-sm flex items-center gap-2">
                  {eligibilityResult.is_eligible ? (
                    <>
                      <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                      Học viên ĐỦ ĐIỀU KIỆN TIÊN QUYẾT để nâng khóa tiếp theo!
                    </>
                  ) : (
                    <>
                      <AlertTriangle className="w-5 h-5 text-rose-600" />
                      Học viên CHƯA ĐỦ ĐIỀU KIỆN tiên quyết!
                    </>
                  )}
                </span>
                <p className="mt-1.5 text-slate-700 leading-relaxed font-medium">{eligibilityResult.note}</p>
                <div className="mt-2.5 inline-flex items-center gap-2 bg-white/80 px-3 py-1.5 rounded-xl border border-slate-200/60 font-semibold text-slate-800 text-[11px]">
                  <span>{eligibilityResult.current_course_title}</span>
                  <ArrowRight className="w-3.5 h-3.5 text-indigo-600" />
                  <span className="text-indigo-600 font-bold">{eligibilityResult.next_course_title}</span>
                </div>
              </div>

              {canManageProgression && eligibilityResult.is_eligible && (
                <div className="shrink-0">
                  {eligibilityResult.is_confirmed ? (
                    <span className="inline-flex items-center gap-1.5 bg-emerald-600 text-white font-bold px-3.5 py-2 rounded-xl text-xs shadow-xs">
                      <CheckCircle2 className="w-4 h-4" /> Đã duyệt nâng khóa
                    </span>
                  ) : (
                    <button
                      onClick={() => handleConfirmEligibility(eligibilityResult.id)}
                      className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold px-4 py-2.5 rounded-xl text-xs shadow-md shadow-indigo-200 cursor-pointer transition active:scale-95 flex items-center gap-2"
                    >
                      <Sparkles className="w-4 h-4" />
                      <span>Xác nhận phê duyệt lên khóa</span>
                    </button>
                  )}
                </div>
              )}
            </div>
          )}
        </div>
      )}

    </div>
  );
};
