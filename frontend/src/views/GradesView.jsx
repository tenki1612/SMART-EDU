import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { gradesApi, classesApi, studentsApi, progressionParentApi } from '../services/api';
import {
  CheckCircle2,
  Save,
  Lock,
  Unlock,
  AlertCircle,
  Award,
  FileSpreadsheet,
  Plus,
  Trash2,
  X,
  UserPlus,
  ShieldAlert,
  UserCheck,
  GraduationCap,
  Sparkles,
  BookOpen,
  Calendar,
  AlertTriangle
} from 'lucide-react';

export const GradesView = () => {
  const { user } = useAuth();
  const toast = useToast();

  const isTeacher = user?.role === 'TEACHER';
  const isAdminOrStaff = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');
  const isStudent = user?.role === 'STUDENT';
  const isParent = user?.role === 'PARENT';

  // Classes & Grading Sheet (for Teacher, Admin, Staff)
  const [classes, setClasses] = useState([]);
  const [selectedClassId, setSelectedClassId] = useState(0);
  const [gradingSheet, setGradingSheet] = useState([]);
  const [allStudents, setAllStudents] = useState([]);

  // Student specific state
  const [myGrades, setMyGrades] = useState([]);

  // Parent specific state
  const [wards, setWards] = useState([]);
  const [selectedWardId, setSelectedWardId] = useState(null);
  const [wardGrades, setWardGrades] = useState([]);

  // Modal: Thêm học viên vào bảng điểm
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [addForm, setAddForm] = useState({
    student_id: '',
    attendance_score: 0,
    midterm_score: 0,
    final_score: 0,
    note: ''
  });

  const loadClasses = async () => {
    try {
      const res = await classesApi.list();
      const clsList = res.data || [];
      setClasses(clsList);
      if (clsList.length > 0 && !selectedClassId) {
        setSelectedClassId(clsList[0].id);
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách lớp: ' + e.message);
    }
  };

  const loadAllStudents = async () => {
    try {
      const res = await studentsApi.list();
      setAllStudents(res.data || []);
    } catch (e) {
      console.error(e);
    }
  };

  const loadStudentGrades = async () => {
    try {
      const res = await gradesApi.getMyGrades();
      setMyGrades(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải bảng điểm cá nhân: ' + e.message);
    }
  };

  const loadParentWards = async () => {
    try {
      const res = await progressionParentApi.getParentWards();
      const list = res.data || [];
      setWards(list);
      if (list.length > 0) {
        setSelectedWardId(list[0].student_id);
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải thông tin con được giám hộ: ' + e.message);
    }
  };

  const loadWardGrades = async (studentId) => {
    if (!studentId) return;
    try {
      const res = await progressionParentApi.getWardGrades(studentId);
      setWardGrades(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải bảng điểm của con: ' + e.message);
    }
  };

  const loadGradingSheet = async (classId) => {
    if (!classId) return;
    try {
      const res = await gradesApi.getGradingSheet(classId);
      setGradingSheet(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải bảng điểm lớp: ' + e.message);
    }
  };

  // Initial Load based on Role
  useEffect(() => {
    if (isStudent) {
      loadStudentGrades();
    } else if (isParent) {
      loadParentWards();
    } else {
      loadClasses();
      loadAllStudents();
    }
  }, [user?.role]);

  // Load Ward Grades when selected Ward changes (Parent)
  useEffect(() => {
    if (isParent && selectedWardId) {
      loadWardGrades(selectedWardId);
    }
  }, [selectedWardId]);

  // Load Grading Sheet when selected Class changes (Teacher/Admin/Staff)
  useEffect(() => {
    if (selectedClassId && (isTeacher || isAdminOrStaff)) {
      loadGradingSheet(selectedClassId);
    }
  }, [selectedClassId]);

  const isSheetLocked = gradingSheet.length > 0 && gradingSheet.every((s) => s.is_confirmed);

  // Score change handler for Teachers
  const handleScoreChange = (studentId, field, val) => {
    if (!isTeacher) return; // Only teacher can edit
    const clamped = isNaN(val) ? 0 : Math.max(0, Math.min(10, val));
    setGradingSheet((prev) =>
      prev.map((item) => {
        if (item.student_id === studentId) {
          const updated = { ...item, [field]: clamped };
          const total = Number(
            (
              (Number(updated.attendance_score) || 0) * 0.2 +
              (Number(updated.midterm_score) || 0) * 0.3 +
              (Number(updated.final_score) || 0) * 0.5
            ).toFixed(2)
          );
          const finalScore = Number(updated.final_score) || 0;
          const status = total >= 5.0 && finalScore >= 4.0 ? 'PASSED' : 'FAILED';
          return { ...updated, total_score: total, result_status: status };
        }
        return item;
      })
    );
  };

  // Teacher saves grades
  const handleSaveGrades = async () => {
    if (!isTeacher) {
      toast.warning('Chỉ giảng viên phụ trách mới có quyền thay đổi điểm học viên.');
      return;
    }
    try {
      await gradesApi.saveGrades(
        selectedClassId,
        gradingSheet.map((s) => ({
          student_id: s.student_id,
          attendance_score: Number(s.attendance_score) || 0,
          midterm_score: Number(s.midterm_score) || 0,
          final_score: Number(s.final_score) || 0,
          note: s.note,
        }))
      );
      toast.success('Giảng viên đã lưu bảng điểm thành công!');
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Admin & Staff officially confirm/lock grades
  const handleConfirmGrades = async () => {
    if (!window.confirm('Bạn có chắc chắn muốn xác nhận kết quả học tập chính thức? Bảng điểm sẽ được khóa an toàn.')) return;
    try {
      await gradesApi.confirmGrades(selectedClassId);
      toast.success('Đã lưu & xác nhận bảng điểm chính thức thành công!');
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Unlock grades
  const handleUnlockGrades = async () => {
    if (!window.confirm('Mở khóa bảng điểm để giảng viên có thể cập nhật điểm số?')) return;
    try {
      await gradesApi.unlockGrades(selectedClassId);
      toast.success('Đã mở khóa bảng điểm thành công!');
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Delete student from grade sheet
  const handleDeleteStudent = async (studentId, studentName) => {
    if (!window.confirm(`Bạn có chắc chắn muốn XÓA điểm và gỡ học viên "${studentName}" khỏi lớp?`)) return;
    try {
      await gradesApi.deleteStudentFromGradeSheet(selectedClassId, studentId);
      toast.success(`Đã xóa học viên ${studentName} khỏi bảng điểm thành công!`);
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Add student to grade sheet
  const handleAddStudentSubmit = async (e) => {
    e.preventDefault();
    if (!addForm.student_id) {
      toast.warning('Vui lòng chọn học viên từ danh sách.');
      return;
    }
    try {
      await gradesApi.addStudentToGradeSheet(selectedClassId, {
        student_id: Number(addForm.student_id),
        attendance_score: Number(addForm.attendance_score) || 0,
        midterm_score: Number(addForm.midterm_score) || 0,
        final_score: Number(addForm.final_score) || 0,
        note: addForm.note
      });
      toast.success('Thêm học viên vào bảng điểm lớp thành công!');
      setIsAddModalOpen(false);
      setAddForm({
        student_id: '',
        attendance_score: 0,
        midterm_score: 0,
        final_score: 0,
        note: ''
      });
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // -------------------------------------------------------------
  // RENDER 1: HỌC VIÊN (STUDENT) - CHỈ XEM ĐIỂM CỦA CHÍNH MÌNH
  // -------------------------------------------------------------
  if (isStudent) {
    const passedCount = myGrades.filter((g) => g.result_status === 'PASSED').length;
    const avgScore = myGrades.length > 0
      ? (myGrades.reduce((acc, curr) => acc + (curr.total_score || 0), 0) / myGrades.length).toFixed(2)
      : '--';

    return (
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
              <Award className="w-5 h-5 text-indigo-600" />
              Bảng điểm & Kết quả Học tập Cá nhân
            </h2>
            <p className="text-xs text-slate-500 mt-1">
              Hệ thống điểm học tập cá nhân bảo mật của học viên <strong className="text-slate-800">{user?.full_name}</strong>.
            </p>
          </div>
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-indigo-50 text-indigo-700 border border-indigo-200">
            <UserCheck className="w-3.5 h-3.5" /> Học viên: {user?.full_name}
          </span>
        </div>

        {/* Quick KPI summary */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">Khóa học đã đăng ký</span>
            <div className="text-2xl font-black text-slate-900 mt-2 tabular-nums">{myGrades.length}</div>
          </div>
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">Số môn Đạt chuẩn đầu ra</span>
            <div className="text-2xl font-black text-emerald-600 mt-2 tabular-nums">{passedCount} môn</div>
          </div>
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">Điểm trung bình tích lũy</span>
            <div className="text-2xl font-black text-indigo-600 mt-2 tabular-nums">{avgScore}</div>
          </div>
        </div>

        {/* Personal Transcript Table */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
          <div className="p-4 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between">
            <div className="font-extrabold text-xs text-slate-800 uppercase tracking-wider">
              Bảng điểm chi tiết từng môn
            </div>
            <span className="text-[11px] text-slate-400">Trọng số: CC 20% &bull; GK 30% &bull; CK 50%</span>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 text-slate-600 font-bold border-b border-slate-200 text-[11px] uppercase">
                <tr>
                  <th className="p-4">Lớp học / Khóa học</th>
                  <th className="p-4 text-center">Chuyên cần (20%)</th>
                  <th className="p-4 text-center">Giữa kỳ (30%)</th>
                  <th className="p-4 text-center">Cuối kỳ (50%)</th>
                  <th className="p-4 text-center">Điểm tổng kết</th>
                  <th className="p-4 text-center">Xếp loại kết quả</th>
                  <th className="p-4">Trạng thái phê duyệt</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {myGrades.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="p-8 text-center text-slate-400 font-medium">
                      Bạn chưa có điểm số nào được công bố hoặc đang trong quá trình học.
                    </td>
                  </tr>
                ) : (
                  myGrades.map((g) => (
                    <tr key={g.id} className="hover:bg-slate-50/80 transition-colors">
                      <td className="p-4">
                        <div className="font-mono font-bold text-indigo-700">{g.class_code}</div>
                        <div className="text-xs text-slate-700 font-semibold">{g.course_title}</div>
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.attendance_score}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.midterm_score}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.final_score}
                      </td>
                      <td className="p-4 text-center font-mono font-black text-indigo-600 text-sm tabular-nums">
                        {g.total_score}
                      </td>
                      <td className="p-4 text-center">
                        <span
                          className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold border ${
                            g.result_status === 'PASSED'
                              ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                              : g.result_status === 'FAILED'
                              ? 'bg-rose-50 text-rose-700 border-rose-200'
                              : 'bg-slate-100 text-slate-600 border-slate-200'
                          }`}
                        >
                          {g.result_status === 'PASSED'
                            ? 'ĐẠT (PASSED)'
                            : g.result_status === 'FAILED'
                            ? 'CHƯA ĐẠT (FAILED)'
                            : 'ĐANG XỬ LÝ'}
                        </span>
                      </td>
                      <td className="p-4">
                        {g.is_confirmed ? (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Điểm chính thức
                          </span>
                        ) : (
                          <span className="text-[11px] font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200">
                            Điểm tạm tính
                          </span>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------
  // RENDER 2: PHỤ HUYNH (PARENT) - CHỈ XEM ĐIỂM CỦA CON MÌNH
  // -------------------------------------------------------------
  if (isParent) {
    const currentWard = wards.find((w) => w.student_id === selectedWardId) || wards[0];

    return (
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
              <Award className="w-5 h-5 text-indigo-600" />
              Bảng điểm & Đánh giá Kết quả Học tập của Con
            </h2>
            <p className="text-xs text-slate-500 mt-1">
              Phụ huynh chỉ theo dõi điểm số và tiến độ của học viên được giám hộ hợp pháp.
            </p>
          </div>
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-800 border border-amber-200">
            <UserCheck className="w-3.5 h-3.5" /> Phụ huynh: {user?.full_name}
          </span>
        </div>

        {/* Ward Selector if multiple children */}
        {wards.length > 1 && (
          <div className="flex items-center gap-2 bg-white p-2 rounded-2xl border border-slate-200 shadow-2xs">
            <span className="text-xs font-bold text-slate-600 px-2">Chọn con em theo dõi:</span>
            {wards.map((w) => (
              <button
                key={w.student_id}
                onClick={() => setSelectedWardId(w.student_id)}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition cursor-pointer ${
                  selectedWardId === w.student_id
                    ? 'bg-indigo-600 text-white shadow-xs'
                    : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
                }`}
              >
                {w.full_name} ({w.student_code})
              </button>
            ))}
          </div>
        )}

        {/* Current Ward Profile Summary Card */}
        {currentWard && (
          <div className="bg-gradient-to-r from-indigo-900 to-slate-900 text-white rounded-3xl p-6 shadow-xl border border-indigo-800">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="space-y-1">
                <span className="text-[11px] font-bold text-indigo-300 uppercase tracking-wider">
                  Hồ sơ học viên được giám hộ
                </span>
                <h3 className="text-2xl font-black text-white">{currentWard.full_name}</h3>
                <div className="flex items-center gap-3 text-xs text-indigo-200 font-mono">
                  <span>Mã HV: {currentWard.student_code}</span>
                  <span>&bull;</span>
                  <span>Quan hệ: {currentWard.relationship_type}</span>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="bg-white/10 backdrop-blur-md px-4 py-3 rounded-2xl text-center border border-white/10">
                  <span className="block text-xs font-semibold text-indigo-200">Điểm TB tích lũy</span>
                  <span className="text-2xl font-black text-white tabular-nums">
                    {currentWard.average_score ?? '--'}
                  </span>
                </div>
                <div className="bg-white/10 backdrop-blur-md px-4 py-3 rounded-2xl text-center border border-white/10">
                  <span className="block text-xs font-semibold text-indigo-200">Khóa đã tham gia</span>
                  <span className="text-2xl font-black text-amber-300 tabular-nums">
                    {currentWard.enrolled_courses_count}
                  </span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Ward Grades Table */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
          <div className="p-4 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between">
            <div className="font-extrabold text-xs text-slate-800 uppercase tracking-wider">
              Chi tiết bảng điểm môn học của con
            </div>
            <span className="text-[11px] text-slate-400">Trọng số: CC 20% &bull; GK 30% &bull; CK 50%</span>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 text-slate-600 font-bold border-b border-slate-200 text-[11px] uppercase">
                <tr>
                  <th className="p-4">Khóa học / Lớp</th>
                  <th className="p-4 text-center">Chuyên cần (20%)</th>
                  <th className="p-4 text-center">Giữa kỳ (30%)</th>
                  <th className="p-4 text-center">Cuối kỳ (50%)</th>
                  <th className="p-4 text-center">Điểm tổng kết</th>
                  <th className="p-4 text-center">Xếp loại</th>
                  <th className="p-4">Trạng thái</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {wardGrades.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="p-8 text-center text-slate-400 font-medium">
                      Chưa có bảng điểm chính thức nào được công bố cho học viên này.
                    </td>
                  </tr>
                ) : (
                  wardGrades.map((g) => (
                    <tr key={g.id} className="hover:bg-slate-50/80 transition-colors">
                      <td className="p-4">
                        <div className="font-mono font-bold text-indigo-700">{g.class_code}</div>
                        <div className="text-xs text-slate-700 font-semibold">{g.course_title}</div>
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.attendance_score}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.midterm_score}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.final_score}
                      </td>
                      <td className="p-4 text-center font-mono font-black text-indigo-600 text-sm tabular-nums">
                        {g.total_score}
                      </td>
                      <td className="p-4 text-center">
                        <span
                          className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold border ${
                            g.result_status === 'PASSED'
                              ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                              : g.result_status === 'FAILED'
                              ? 'bg-rose-50 text-rose-700 border-rose-200'
                              : 'bg-slate-100 text-slate-600 border-slate-200'
                          }`}
                        >
                          {g.result_status === 'PASSED'
                            ? 'ĐẠT (PASSED)'
                            : g.result_status === 'FAILED'
                            ? 'CHƯA ĐẠT (FAILED)'
                            : 'ĐANG XỬ LÝ'}
                        </span>
                      </td>
                      <td className="p-4">
                        {g.is_confirmed ? (
                          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                            <CheckCircle2 className="w-3.5 h-3.5" /> Điểm chính thức
                          </span>
                        ) : (
                          <span className="text-[11px] font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200">
                            Điểm tạm tính
                          </span>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------
  // RENDER 3 & 4: GIẢNG VIÊN (TEACHER) & QUẢN TRỊ VIÊN / HỌC VỤ
  // -------------------------------------------------------------
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
            <FileSpreadsheet className="w-5 h-5 text-indigo-600" />
            {isTeacher
              ? 'Sổ Nhập Điểm & Đánh Giá Học Viên (Giảng Viên)'
              : 'Quản Lý & Phê Duyệt Bảng Điểm Lớp Học (Admin / Học Vụ)'}
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            {isTeacher
              ? 'Giảng viên chấm điểm chuyên cần, giữa kỳ, cuối kỳ. Điểm được lưu nháp và tự động tổng hợp kết quả.'
              : 'Quản trị viên và Học vụ có thẩm quyền lưu xác nhận điểm chính thức và xóa điểm học viên khỏi lớp.'}
          </p>
        </div>

        {/* Role action buttons */}
        <div className="flex items-center gap-2">
          {/* Teacher Action: Lưu bảng điểm */}
          {isTeacher && !isSheetLocked && (
            <button
              onClick={handleSaveGrades}
              className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer"
            >
              <Save className="w-4 h-4" /> Lưu bảng điểm
            </button>
          )}

          {/* Admin / Staff Action: Lưu & Xác nhận điểm chính thức */}
          {isAdminOrStaff && !isSheetLocked && gradingSheet.length > 0 && (
            <button
              onClick={handleConfirmGrades}
              className="flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-sm shadow-emerald-200 transition cursor-pointer"
            >
              <CheckCircle2 className="w-4 h-4" /> Lưu & Khóa điểm chính thức
            </button>
          )}

          {/* Unlock action if sheet is locked */}
          {isSheetLocked && (
            <button
              onClick={handleUnlockGrades}
              className="flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-sm shadow-amber-200 transition cursor-pointer"
            >
              <Unlock className="w-4 h-4" /> Mở khóa bảng điểm
            </button>
          )}

          {/* Thêm học viên vào bảng điểm */}
          <button
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 px-3.5 py-2 rounded-xl text-xs font-bold shadow-2xs transition cursor-pointer"
          >
            <UserPlus className="w-4 h-4 text-indigo-600" /> Thêm học viên
          </button>
        </div>
      </div>

      {/* Special Notice Banner for Admin / Staff according to Requirement 1 */}
      {isAdminOrStaff && (
        <div className="p-4 bg-amber-50/80 border border-amber-200/90 rounded-2xl flex items-start gap-3 text-xs text-amber-900 shadow-2xs">
          <ShieldAlert className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
          <div className="space-y-0.5">
            <span className="font-extrabold text-sm block">Quy tắc Phân quyền Nhập Điểm:</span>
            <p className="leading-relaxed">
              Điểm số chỉ có <strong>Giảng viên phụ trách</strong> mới có quyền thay đổi và cập nhật số điểm. 
              Nhân viên học vụ và Quản trị viên chỉ có quyền <strong>Lưu/Xác nhận kết quả chính thức (Khóa điểm)</strong> và <strong>Xóa điểm</strong> của học viên khỏi lớp.
            </p>
          </div>
        </div>
      )}

      {/* Class Selector Bar */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-200 shadow-2xs flex flex-col sm:flex-row items-center justify-between gap-3">
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <span className="text-xs font-bold text-slate-700 whitespace-nowrap">Chọn lớp chấm điểm:</span>
          <select
            value={selectedClassId}
            onChange={(e) => setSelectedClassId(Number(e.target.value))}
            className="border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-800 bg-white font-bold outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
          >
            {classes.map((c) => (
              <option key={c.id} value={c.id}>
                {c.class_code} - {c.course_title} ({c.current_enrolled}/{c.max_capacity} HV)
              </option>
            ))}
          </select>
        </div>

        <div className="flex items-center gap-2">
          {isSheetLocked ? (
            <span className="inline-flex items-center gap-1.5 text-xs font-bold text-amber-800 bg-amber-50 border border-amber-200 px-3 py-1 rounded-full">
              <Lock className="w-3.5 h-3.5 text-amber-600" /> Bảng điểm đã khóa chính thức
            </span>
          ) : (
            <span className="inline-flex items-center gap-1.5 text-xs font-bold text-emerald-800 bg-emerald-50 border border-emerald-200 px-3 py-1 rounded-full">
              <Unlock className="w-3.5 h-3.5 text-emerald-600" /> 
              {isTeacher ? 'Đang mở nhập điểm (Giảng viên)' : 'Đang mở (Chờ học vụ lưu/khóa điểm)'}
            </span>
          )}
          <span className="text-xs font-bold text-slate-500 bg-slate-100 px-2.5 py-1 rounded-lg">
            {gradingSheet.length} học viên
          </span>
        </div>
      </div>

      {/* Grading Sheet Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 border-b border-slate-200 font-bold text-slate-600 uppercase text-[11px]">
              <tr>
                <th className="p-4 w-16">STT</th>
                <th className="p-4">Học viên</th>
                <th className="p-4 text-center w-36">Chuyên cần (20%)</th>
                <th className="p-4 text-center w-36">Giữa kỳ (30%)</th>
                <th className="p-4 text-center w-36">Cuối kỳ (50%)</th>
                <th className="p-4 text-center w-32">Tổng kết</th>
                <th className="p-4 text-center w-36">Xếp loại</th>
                <th className="p-4 text-right w-24">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {gradingSheet.length === 0 ? (
                <tr>
                  <td colSpan={8} className="p-8 text-center text-slate-400 font-medium">
                    Lớp học này chưa có học viên nào trong danh sách chấm điểm.
                  </td>
                </tr>
              ) : (
                gradingSheet.map((st, idx) => (
                  <tr key={st.student_id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="p-4 font-mono font-semibold text-slate-400">{idx + 1}</td>
                    <td className="p-4">
                      <div className="font-bold text-slate-900">{st.full_name}</div>
                      <div className="font-mono text-[11px] text-indigo-700">{st.student_code}</div>
                    </td>

                    {/* Điểm chuyên cần */}
                    <td className="p-4 text-center">
                      {isTeacher && !isSheetLocked ? (
                        <input
                          type="number"
                          step="0.5"
                          min="0"
                          max="10"
                          value={st.attendance_score}
                          onChange={(e) => handleScoreChange(st.student_id, 'attendance_score', parseFloat(e.target.value))}
                          className="w-20 text-center font-mono font-bold border border-slate-300 p-1.5 rounded-lg outline-hidden focus:border-indigo-600 bg-white"
                        />
                      ) : (
                        <span className="font-mono font-bold text-slate-800 text-sm tabular-nums">
                          {st.attendance_score}
                        </span>
                      )}
                    </td>

                    {/* Điểm giữa kỳ */}
                    <td className="p-4 text-center">
                      {isTeacher && !isSheetLocked ? (
                        <input
                          type="number"
                          step="0.5"
                          min="0"
                          max="10"
                          value={st.midterm_score}
                          onChange={(e) => handleScoreChange(st.student_id, 'midterm_score', parseFloat(e.target.value))}
                          className="w-20 text-center font-mono font-bold border border-slate-300 p-1.5 rounded-lg outline-hidden focus:border-indigo-600 bg-white"
                        />
                      ) : (
                        <span className="font-mono font-bold text-slate-800 text-sm tabular-nums">
                          {st.midterm_score}
                        </span>
                      )}
                    </td>

                    {/* Điểm cuối kỳ */}
                    <td className="p-4 text-center">
                      {isTeacher && !isSheetLocked ? (
                        <input
                          type="number"
                          step="0.5"
                          min="0"
                          max="10"
                          value={st.final_score}
                          onChange={(e) => handleScoreChange(st.student_id, 'final_score', parseFloat(e.target.value))}
                          className="w-20 text-center font-mono font-bold border border-slate-300 p-1.5 rounded-lg outline-hidden focus:border-indigo-600 bg-white"
                        />
                      ) : (
                        <span className="font-mono font-bold text-slate-800 text-sm tabular-nums">
                          {st.final_score}
                        </span>
                      )}
                    </td>

                    {/* Tổng kết */}
                    <td className="p-4 text-center font-mono font-black text-indigo-700 text-base tabular-nums">
                      {st.total_score}
                    </td>

                    {/* Xếp loại */}
                    <td className="p-4 text-center">
                      <span
                        className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold border ${
                          st.result_status === 'PASSED'
                            ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                            : st.result_status === 'FAILED'
                            ? 'bg-rose-50 text-rose-700 border-rose-200'
                            : 'bg-slate-100 text-slate-600 border-slate-200'
                        }`}
                      >
                        {st.result_status === 'PASSED'
                          ? 'ĐẠT (PASSED)'
                          : st.result_status === 'FAILED'
                          ? 'CHƯA ĐẠT (FAILED)'
                          : 'CHỜ ĐIỂM'}
                      </span>
                    </td>

                    {/* Xóa điểm / học viên (Admin, Staff, Teacher) */}
                    <td className="p-4 text-right">
                      {!st.is_confirmed && (
                        <button
                          onClick={() => handleDeleteStudent(st.student_id, st.full_name)}
                          className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition cursor-pointer"
                          title="Xóa học viên khỏi bảng điểm"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: Thêm học viên vào bảng điểm */}
      {isAddModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-lg font-black text-slate-900">
                Thêm Học viên vào Bảng điểm
              </h3>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleAddStudentSubmit} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Chọn học viên:</label>
                <select
                  required
                  value={addForm.student_id}
                  onChange={(e) => setAddForm({ ...addForm, student_id: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                >
                  <option value="">-- Chọn học viên từ danh sách --</option>
                  {allStudents.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.full_name} ({s.student_code})
                    </option>
                  ))}
                </select>
              </div>

              {/* Nếu là giáo viên, cho nhập điểm khởi tạo */}
              {isTeacher && (
                <div className="grid grid-cols-3 gap-2">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Chuyên cần:</label>
                    <input
                      type="number"
                      step="0.5"
                      min="0"
                      max="10"
                      value={addForm.attendance_score}
                      onChange={(e) => setAddForm({ ...addForm, attendance_score: parseFloat(e.target.value) || 0 })}
                      className="w-full border border-slate-300 p-2 rounded-xl text-center font-mono font-bold"
                    />
                  </div>
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Giữa kỳ:</label>
                    <input
                      type="number"
                      step="0.5"
                      min="0"
                      max="10"
                      value={addForm.midterm_score}
                      onChange={(e) => setAddForm({ ...addForm, midterm_score: parseFloat(e.target.value) || 0 })}
                      className="w-full border border-slate-300 p-2 rounded-xl text-center font-mono font-bold"
                    />
                  </div>
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Cuối kỳ:</label>
                    <input
                      type="number"
                      step="0.5"
                      min="0"
                      max="10"
                      value={addForm.final_score}
                      onChange={(e) => setAddForm({ ...addForm, final_score: parseFloat(e.target.value) || 0 })}
                      className="w-full border border-slate-300 p-2 rounded-xl text-center font-mono font-bold"
                    />
                  </div>
                </div>
              )}

              <div>
                <label className="font-bold text-slate-700 block mb-1">Ghi chú (Note):</label>
                <textarea
                  rows={2}
                  value={addForm.note}
                  onChange={(e) => setAddForm({ ...addForm, note: e.target.value })}
                  placeholder="Ghi chú thêm về học viên..."
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600"
                />
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Thêm vào lớp
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
