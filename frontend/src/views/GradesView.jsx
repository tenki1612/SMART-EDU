import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { gradesApi, classesApi, studentsApi } from '../services/api';
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
  UserPlus
} from 'lucide-react';

export const GradesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const isStudent = user?.role === 'STUDENT';
  const canEdit = ['ADMIN', 'TEACHER', 'ACADEMIC_STAFF'].includes(user?.role || '');
  const canConfirm = ['ADMIN', 'ACADEMIC_STAFF', 'TEACHER'].includes(user?.role || '');

  const [classes, setClasses] = useState([]);
  const [selectedClassId, setSelectedClassId] = useState(0);
  const [gradingSheet, setGradingSheet] = useState([]);
  const [myGrades, setMyGrades] = useState([]);
  const [allStudents, setAllStudents] = useState([]);

  // Modal thêm học viên vào bảng điểm
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
      setClasses(res.data || []);
      if (res.data && res.data.length > 0) {
        setSelectedClassId(res.data[0].id);
      }
    } catch (e) {
      console.error(e);
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
    }
  };

  const loadGradingSheet = async (classId) => {
    if (!classId) return;
    try {
      const res = await gradesApi.getGradingSheet(classId);
      setGradingSheet(res.data || []);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    if (isStudent) {
      loadStudentGrades();
    } else {
      loadClasses();
      loadAllStudents();
    }
  }, [user?.role]);

  useEffect(() => {
    if (selectedClassId && !isStudent) {
      loadGradingSheet(selectedClassId);
    }
  }, [selectedClassId]);

  // Kiểm tra xem toàn bộ bảng điểm của lớp này có đang bị khóa hay không
  const isSheetLocked = gradingSheet.length > 0 && gradingSheet.every((s) => s.is_confirmed);

  const handleScoreChange = (studentId, field, val) => {
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

  const handleNoteChange = (studentId, noteVal) => {
    setGradingSheet((prev) =>
      prev.map((item) => (item.student_id === studentId ? { ...item, note: noteVal } : item))
    );
  };

  const handleSaveGrades = async () => {
    try {
      const cleanGrades = gradingSheet.map((g) => ({
        student_id: g.student_id,
        attendance_score: Number(g.attendance_score) || 0,
        midterm_score: Number(g.midterm_score) || 0,
        final_score: Number(g.final_score) || 0,
        note: g.note || ''
      }));
      await gradesApi.saveGrades(selectedClassId, cleanGrades);
      toast.success('Đã lưu điểm và tự động tổng hợp kết quả thành công!');
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message || 'Lỗi khi lưu bảng điểm');
    }
  };

  const handleConfirmGrades = async () => {
    if (!window.confirm('Xác nhận kết quả học tập chính thức cho lớp học này? Điểm số sẽ được khóa lại.'))
      return;
    try {
      await gradesApi.confirmGrades(selectedClassId);
      toast.success('Đã xác nhận kết quả học tập chính thức thành công!');
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message || 'Lỗi khi xác nhận điểm');
    }
  };

  const handleUnlockGrades = async () => {
    if (!window.confirm('Mở khóa bảng điểm để tiếp tục chỉnh sửa, thêm hoặc xóa điểm?')) return;
    try {
      await gradesApi.unlockGrades(selectedClassId);
      toast.success('Đã mở khóa bảng điểm thành công! Bạn có thể chỉnh sửa ngay.');
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message || 'Lỗi khi mở khóa bảng điểm');
    }
  };

  const handleOpenAddModal = () => {
    // Tìm học viên đầu tiên chưa có trong bảng điểm
    const existingIds = new Set(gradingSheet.map((s) => s.student_id));
    const available = allStudents.filter((st) => !existingIds.has(st.id));
    setAddForm({
      student_id: available.length > 0 ? String(available[0].id) : '',
      attendance_score: 0,
      midterm_score: 0,
      final_score: 0,
      note: ''
    });
    setIsAddModalOpen(true);
  };

  const handleAddStudentSubmit = async (e) => {
    e.preventDefault();
    if (!addForm.student_id) {
      toast.warning('Vui lòng chọn học viên cần thêm vào bảng điểm.');
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
      toast.success('Đã thêm học viên vào bảng điểm lớp học thành công!');
      setIsAddModalOpen(false);
      loadGradingSheet(selectedClassId);
      loadClasses(); // cập nhật sĩ số
    } catch (err) {
      toast.error(err.message || 'Lỗi khi thêm học viên vào bảng điểm');
    }
  };

  const handleDeleteStudent = async (studentId, studentName) => {
    if (!window.confirm(`Bạn có chắc chắn muốn xóa học viên "${studentName}" khỏi bảng điểm lớp này?`)) {
      return;
    }
    try {
      await gradesApi.deleteStudentFromGradeSheet(selectedClassId, studentId);
      toast.success(`Đã xóa học viên ${studentName} khỏi bảng điểm thành công!`);
      loadGradingSheet(selectedClassId);
      loadClasses();
    } catch (err) {
      toast.error(err.message || 'Lỗi khi xóa học viên khỏi bảng điểm');
    }
  };

  // Danh sách học viên chưa có trong bảng điểm hiện tại
  const existingStudentIds = new Set(gradingSheet.map((s) => s.student_id));
  const availableStudentsToAdd = allStudents.filter((st) => !existingStudentIds.has(st.id));

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
            <FileSpreadsheet className="w-5 h-5 text-indigo-600" />
            Bảng điểm & Đánh giá kết quả học tập
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Nhập điểm chuẩn thang điểm 0 - 10, tự động tính tổng kết theo trọng số (20% CC + 30% GK + 50% CK) và xếp loại Đạt/Chưa đạt.
          </p>
        </div>
      </div>

      {isStudent ? (
        /* Student Transcript View */
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-2xs overflow-hidden">
          <div className="p-5 border-b border-slate-100 flex items-center justify-between">
            <h3 className="font-extrabold text-slate-900 text-sm flex items-center gap-2">
              <Award className="w-4 h-4 text-indigo-600" /> Bảng điểm kết quả học tập cá nhân
            </h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 font-bold text-slate-600 border-b border-slate-200/80 uppercase text-[11px]">
                <tr>
                  <th className="p-4">Mã lớp</th>
                  <th className="p-4">Khóa học đào tạo</th>
                  <th className="p-4 text-center">Chuyên cần (20%)</th>
                  <th className="p-4 text-center">Giữa kỳ (30%)</th>
                  <th className="p-4 text-center">Cuối kỳ (50%)</th>
                  <th className="p-4 text-center">Điểm tổng kết</th>
                  <th className="p-4 text-center">Xếp loại</th>
                  <th className="p-4">Nhận xét của giáo viên</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {myGrades.map((g) => (
                  <tr key={g.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="p-4 font-mono font-bold text-indigo-700">{g.class_code}</td>
                    <td className="p-4 font-bold text-slate-900">{g.course_title}</td>
                    <td className="p-4 text-center font-semibold text-slate-700 tabular-nums">
                      {g.attendance_score}
                    </td>
                    <td className="p-4 text-center font-semibold text-slate-700 tabular-nums">
                      {g.midterm_score}
                    </td>
                    <td className="p-4 text-center font-semibold text-slate-700 tabular-nums">
                      {g.final_score}
                    </td>
                    <td className="p-4 text-center font-black text-sm text-indigo-700 tabular-nums">
                      {g.total_score}
                    </td>
                    <td className="p-4 text-center">
                      <span
                        className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full font-bold text-[10px] border ${
                          g.result_status === 'PASSED'
                            ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                            : 'bg-rose-50 text-rose-700 border-rose-200'
                        }`}
                      >
                        <span
                          className={`w-1.5 h-1.5 rounded-full ${
                            g.result_status === 'PASSED' ? 'bg-emerald-500' : 'bg-rose-500'
                          }`}
                        />
                        {g.result_status === 'PASSED' ? 'ĐẠT (PASSED)' : 'CHƯA ĐẠT (FAILED)'}
                      </span>
                    </td>
                    <td className="p-4 text-slate-500 max-w-xs">{g.note || '--'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        /* Teacher / Staff / Admin Grading Sheet View */
        <div className="space-y-4">
          {/* Action Bar */}
          <div className="bg-white p-4 sm:p-5 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            <div className="flex flex-wrap items-center gap-3">
              <label className="text-xs font-bold text-slate-700 shrink-0">Chọn lớp nhập điểm:</label>
              <select
                value={selectedClassId}
                onChange={(e) => setSelectedClassId(Number(e.target.value))}
                className="border border-slate-300 rounded-xl px-3 py-2 text-xs font-bold text-slate-800 bg-white outline-hidden cursor-pointer shadow-2xs hover:border-slate-400"
              >
                {classes.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.class_code} - {c.course_title} ({c.current_enrolled} học viên)
                  </option>
                ))}
              </select>

              {isSheetLocked ? (
                <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-1 rounded-lg flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5" /> Bảng điểm đã khóa chính thức
                </span>
              ) : (
                <span className="text-[11px] font-bold text-amber-700 bg-amber-50 border border-amber-200 px-2.5 py-1 rounded-lg">
                  Đang mở - Cho phép nhập & chỉnh sửa
                </span>
              )}
            </div>

            <div className="flex flex-wrap items-center gap-2">
              {/* Nút Thêm học viên */}
              {canEdit && (
                <button
                  type="button"
                  onClick={handleOpenAddModal}
                  className="flex items-center gap-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 border border-indigo-200 px-3.5 py-2 rounded-xl text-xs font-bold transition cursor-pointer"
                >
                  <Plus className="w-3.5 h-3.5" /> Thêm học viên vào lớp
                </button>
              )}

              {/* Nút Lưu bảng điểm */}
              {canEdit && !isSheetLocked && (
                <button
                  type="button"
                  onClick={handleSaveGrades}
                  className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white px-4 py-2 rounded-xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer"
                >
                  <Save className="w-3.5 h-3.5" /> Lưu bảng điểm
                </button>
              )}

              {/* Nút Mở khóa sửa điểm */}
              {isSheetLocked && canEdit && (
                <button
                  type="button"
                  onClick={handleUnlockGrades}
                  className="flex items-center gap-1.5 bg-amber-500 hover:bg-amber-600 active:scale-[0.99] text-white px-3.5 py-2 rounded-xl text-xs font-bold shadow-sm shadow-amber-200 transition cursor-pointer"
                >
                  <Unlock className="w-3.5 h-3.5" /> Mở khóa sửa điểm
                </button>
              )}

              {/* Nút Xác nhận chính thức */}
              {canConfirm && !isSheetLocked && gradingSheet.length > 0 && (
                <button
                  type="button"
                  onClick={handleConfirmGrades}
                  className="flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 active:scale-[0.99] text-white px-4 py-2 rounded-xl text-xs font-bold shadow-sm shadow-emerald-200 transition cursor-pointer"
                >
                  <Lock className="w-3.5 h-3.5" /> Khóa sổ điểm chính thức
                </button>
              )}
            </div>
          </div>

          {/* Table Container */}
          <div className="bg-white rounded-2xl border border-slate-200/90 shadow-2xs overflow-hidden">
            <div className="p-3.5 bg-indigo-50/50 border-b border-indigo-100/70 flex items-center justify-between text-xs text-indigo-900 font-medium">
              <div className="flex items-center gap-2">
                <AlertCircle className="w-4 h-4 text-indigo-600 shrink-0" />
                <span>
                  Công thức: <strong>Tổng kết = 20% Chuyên cần + 30% Giữa kỳ + 50% Cuối kỳ</strong>. Đạt khi Tổng &ge; 5.0 và Cuối kỳ &ge; 4.0.
                </span>
              </div>
              <span className="text-[11px] text-slate-500 font-semibold">
                Sĩ số lớp: {gradingSheet.length} học viên
              </span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50/80 font-bold text-slate-600 border-b border-slate-200/80 uppercase text-[11px]">
                  <tr>
                    <th className="p-3.5">Mã HV</th>
                    <th className="p-3.5">Họ và tên học viên</th>
                    <th className="p-3.5 text-center w-28">Chuyên cần (20%)</th>
                    <th className="p-3.5 text-center w-28">Giữa kỳ (30%)</th>
                    <th className="p-3.5 text-center w-28">Cuối kỳ (50%)</th>
                    <th className="p-3.5 text-center w-24">Tổng kết</th>
                    <th className="p-3.5 text-center w-28">Xếp loại</th>
                    <th className="p-3.5">Ghi chú</th>
                    <th className="p-3.5 text-center w-20">Trạng thái</th>
                    {canEdit && <th className="p-3.5 text-center w-20">Thao tác</th>}
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {gradingSheet.length === 0 ? (
                    <tr>
                      <td colSpan={canEdit ? 10 : 9} className="p-10 text-center text-slate-400 font-medium">
                        <div className="max-w-sm mx-auto space-y-3">
                          <p>Lớp học hiện chưa có học viên nào trong bảng điểm.</p>
                          {canEdit && (
                            <button
                              type="button"
                              onClick={handleOpenAddModal}
                              className="inline-flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm cursor-pointer"
                            >
                              <Plus className="w-4 h-4" /> Thêm học viên đầu tiên
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ) : (
                    gradingSheet.map((st) => (
                      <tr key={st.student_id} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-3.5 font-mono font-bold text-slate-700">{st.student_code}</td>
                        <td className="p-3.5 font-bold text-slate-900">{st.full_name}</td>
                        <td className="p-3.5 text-center">
                          <input
                            type="number"
                            step="0.1"
                            min="0"
                            max="10"
                            disabled={st.is_confirmed || !canEdit}
                            value={st.attendance_score}
                            onChange={(e) =>
                              handleScoreChange(st.student_id, 'attendance_score', parseFloat(e.target.value))
                            }
                            className="w-16 border border-slate-300 rounded-lg p-1.5 text-center font-bold text-slate-800 disabled:bg-slate-100 outline-hidden focus:border-indigo-600 tabular-nums transition"
                          />
                        </td>
                        <td className="p-3.5 text-center">
                          <input
                            type="number"
                            step="0.1"
                            min="0"
                            max="10"
                            disabled={st.is_confirmed || !canEdit}
                            value={st.midterm_score}
                            onChange={(e) =>
                              handleScoreChange(st.student_id, 'midterm_score', parseFloat(e.target.value))
                            }
                            className="w-16 border border-slate-300 rounded-lg p-1.5 text-center font-bold text-slate-800 disabled:bg-slate-100 outline-hidden focus:border-indigo-600 tabular-nums transition"
                          />
                        </td>
                        <td className="p-3.5 text-center">
                          <input
                            type="number"
                            step="0.1"
                            min="0"
                            max="10"
                            disabled={st.is_confirmed || !canEdit}
                            value={st.final_score}
                            onChange={(e) =>
                              handleScoreChange(st.student_id, 'final_score', parseFloat(e.target.value))
                            }
                            className="w-16 border border-slate-300 rounded-lg p-1.5 text-center font-bold text-slate-800 disabled:bg-slate-100 outline-hidden focus:border-indigo-600 tabular-nums transition"
                          />
                        </td>
                        <td className="p-3.5 text-center font-black text-sm text-indigo-700 tabular-nums">
                          {st.total_score}
                        </td>
                        <td className="p-3.5 text-center">
                          <span
                            className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full font-bold text-[10px] border ${
                              st.result_status === 'PASSED'
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                                : 'bg-rose-50 text-rose-700 border-rose-200'
                            }`}
                          >
                            <span
                              className={`w-1.5 h-1.5 rounded-full ${
                                st.result_status === 'PASSED' ? 'bg-emerald-500' : 'bg-rose-500'
                              }`}
                            />
                            {st.result_status === 'PASSED' ? 'ĐẠT' : 'CHƯA ĐẠT'}
                          </span>
                        </td>
                        <td className="p-3.5">
                          <input
                            type="text"
                            disabled={st.is_confirmed || !canEdit}
                            value={st.note || ''}
                            placeholder="Nhận xét..."
                            onChange={(e) => handleNoteChange(st.student_id, e.target.value)}
                            className="w-full min-w-[120px] border border-slate-200 rounded-lg px-2 py-1 text-xs text-slate-700 disabled:bg-slate-100 outline-hidden focus:border-indigo-600"
                          />
                        </td>
                        <td className="p-3.5 text-center">
                          {st.is_confirmed ? (
                            <span className="text-[10px] font-bold text-emerald-700 flex items-center justify-center gap-1">
                              <CheckCircle2 className="w-3.5 h-3.5" /> Đã khóa
                            </span>
                          ) : (
                            <span className="text-[10px] text-amber-700 bg-amber-50 px-1.5 py-0.5 rounded font-medium">
                              Chưa khóa
                            </span>
                          )}
                        </td>
                        {canEdit && (
                          <td className="p-3.5 text-center">
                            <button
                              type="button"
                              disabled={st.is_confirmed}
                              onClick={() => handleDeleteStudent(st.student_id, st.full_name)}
                              title={st.is_confirmed ? 'Mở khóa trước khi xóa' : 'Xóa học viên khỏi bảng điểm'}
                              className="p-1.5 text-rose-600 hover:bg-rose-50 rounded-lg transition cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </td>
                        )}
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: Thêm học viên vào bảng điểm lớp */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-md w-full shadow-2xl border border-slate-200 overflow-hidden">
            <div className="p-5 border-b border-slate-100 flex items-center justify-between bg-slate-50/70">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-indigo-600 text-white flex items-center justify-center">
                  <UserPlus className="w-4 h-4" />
                </div>
                <h3 className="font-extrabold text-slate-900 text-sm">Thêm học viên vào bảng điểm</h3>
              </div>
              <button
                type="button"
                onClick={() => setIsAddModalOpen(false)}
                className="text-slate-400 hover:text-slate-700 p-1 rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddStudentSubmit} className="p-6 space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1.5">
                  Chọn học viên: <span className="text-rose-500">*</span>
                </label>
                {availableStudentsToAdd.length === 0 ? (
                  <div className="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-[11px]">
                    Tất cả học viên trong trung tâm đã có mặt trong lớp này!
                  </div>
                ) : (
                  <select
                    required
                    value={addForm.student_id}
                    onChange={(e) => setAddForm({ ...addForm, student_id: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl px-3 py-2.5 font-semibold text-slate-800 bg-white outline-hidden focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100"
                  >
                    {availableStudentsToAdd.map((st) => (
                      <option key={st.id} value={st.id}>
                        {st.student_code} - {st.full_name} ({st.email})
                      </option>
                    ))}
                  </select>
                )}
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Chuyên cần:</label>
                  <input
                    type="number"
                    step="0.1"
                    min="0"
                    max="10"
                    value={addForm.attendance_score}
                    onChange={(e) =>
                      setAddForm({ ...addForm, attendance_score: parseFloat(e.target.value) || 0 })
                    }
                    className="w-full border border-slate-300 rounded-xl p-2 text-center font-bold text-slate-800 outline-hidden focus:border-indigo-600"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giữa kỳ:</label>
                  <input
                    type="number"
                    step="0.1"
                    min="0"
                    max="10"
                    value={addForm.midterm_score}
                    onChange={(e) =>
                      setAddForm({ ...addForm, midterm_score: parseFloat(e.target.value) || 0 })
                    }
                    className="w-full border border-slate-300 rounded-xl p-2 text-center font-bold text-slate-800 outline-hidden focus:border-indigo-600"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Cuối kỳ:</label>
                  <input
                    type="number"
                    step="0.1"
                    min="0"
                    max="10"
                    value={addForm.final_score}
                    onChange={(e) =>
                      setAddForm({ ...addForm, final_score: parseFloat(e.target.value) || 0 })
                    }
                    className="w-full border border-slate-300 rounded-xl p-2 text-center font-bold text-slate-800 outline-hidden focus:border-indigo-600"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1.5">Ghi chú / Nhận xét:</label>
                <textarea
                  rows={2}
                  value={addForm.note}
                  onChange={(e) => setAddForm({ ...addForm, note: e.target.value })}
                  placeholder="Ghi chú về học lực, sự tiến bộ..."
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-xs text-slate-800 outline-hidden focus:border-indigo-600"
                />
              </div>

              <div className="pt-2 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-600 font-bold hover:bg-slate-50 transition cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={availableStudentsToAdd.length === 0}
                  className="px-5 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white font-bold transition shadow-md shadow-indigo-200 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Xác nhận thêm
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
