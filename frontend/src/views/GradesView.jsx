import React, { useEffect, useState, useMemo } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { useConfirm } from '../context/ConfirmDialogContext';
import { useHeaderSlot } from '../context/HeaderSlotContext';
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
  Users,
  Calendar,
  AlertTriangle,
  RefreshCw,
} from 'lucide-react';
import { GradeOverviewLevel } from '../components/grades/GradeOverviewLevel';
import { GradeDetailLevel } from '../components/grades/GradeDetailLevel';

export const GradesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const confirm = useConfirm();
  const headerSlot = useHeaderSlot();

  const isTeacher = user?.role === 'TEACHER';
  const isAdminOrStaff = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');
  const isStudent = user?.role === 'STUDENT';
  const isParent = user?.role === 'PARENT';

  // Level navigation: 'overview' (Cấp độ 1) | 'detail' (Cấp độ 2)
  // ADMIN and ACADEMIC_STAFF default to 'overview'
  // TEACHER defaults to 'detail' for direct grading
  const [activeLevel, setActiveLevel] = useState(isAdminOrStaff ? 'overview' : 'detail');

  // Classes & Grading Sheet data
  const [classes, setClasses] = useState([]);
  const [selectedClassId, setSelectedClassId] = useState(0);
  const [gradingSheet, setGradingSheet] = useState([]);
  const [allStudents, setAllStudents] = useState([]);
  const [sheetStats, setSheetStats] = useState({});
  const [loading, setLoading] = useState(false);
  const [loadingStats, setLoadingStats] = useState(false);

  // Student specific state
  const [myGrades, setMyGrades] = useState([]);

  // Parent specific state
  const [wards, setWards] = useState([]);
  const [selectedWardId, setSelectedWardId] = useState(null);
  const [wardGrades, setWardGrades] = useState([]);

  // Lock and audit states
  const [lockInfo, setLockInfo] = useState({
    is_locked: false,
    is_manually_unlocked: false,
    lock_reason: '',
    can_edit: true,
  });
  const [showLockModal, setShowLockModal] = useState(false);
  const [showUnlockModal, setShowUnlockModal] = useState(false);
  const [showHistoryModal, setShowHistoryModal] = useState(false);
  const [historyTargetClassId, setHistoryTargetClassId] = useState(0);
  const [lockReason, setLockReason] = useState('');
  const [lockHistory, setLockHistory] = useState([]);

  // Modal: Thêm học viên vào bảng điểm
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [addForm, setAddForm] = useState({
    student_id: '',
    attendance_score: 0,
    midterm_score: 0,
    final_score: 0,
    note: '',
  });

  // Selected Class object derived from selectedClassId
  const selectedClass = useMemo(() => {
    return classes.find((c) => c.id === selectedClassId) || classes[0] || null;
  }, [classes, selectedClassId]);

  // Load all classes
  const loadClasses = async () => {
    try {
      setLoading(true);
      const res = await classesApi.list(isTeacher ? { my_classes: true } : {});
      const clsList = res.data || [];
      setClasses(clsList);

      const validClasses = clsList.filter((c) => c.status !== 'PLANNING');
      if (validClasses.length > 0) {
        if (!selectedClassId || !clsList.some((c) => c.id === selectedClassId)) {
          setSelectedClassId(validClasses[0].id);
        }
      } else {
        setSelectedClassId(0);
        setGradingSheet([]);
      }

      // Background load stats for Level 1 overview
      if (isAdminOrStaff || isTeacher) {
        loadStatsForAllClasses(clsList);
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách lớp: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  // Asynchronous batch loading of grade sheets and lock statuses
  const loadStatsForAllClasses = async (classList) => {
    setLoadingStats(true);
    try {
      const activeClasses = (classList || []).filter((c) => c.status !== 'PLANNING');
      const statsMap = {};

      // Pre-set PLANNING classes as NOT_OPEN
      (classList || []).forEach((c) => {
        if (c.status === 'PLANNING') {
          statsMap[c.id] = {
            classId: c.id,
            totalStudents: 0,
            fullyGraded: 0,
            partiallyGraded: 0,
            passedCount: 0,
            failedCount: 0,
            isLocked: false,
            isManuallyUnlocked: false,
            sheetStatus: 'NOT_OPEN',
          };
        }
      });

      const results = await Promise.allSettled(
        activeClasses.map(async (cls) => {
          try {
            const [sheetRes, lockRes] = await Promise.all([
              gradesApi.getGradingSheet(cls.id).catch(() => ({ data: [] })),
              gradesApi.getLockStatus(cls.id).catch(() => ({ data: { is_locked: false } })),
            ]);

            const sheet = sheetRes?.data || [];
            const lockData = lockRes?.data || {};
            const isLocked = Boolean(lockData.is_locked) || cls.status === 'COMPLETED';
            const isManuallyUnlocked = Boolean(lockData.is_manually_unlocked);

            const fullyGraded = sheet.filter(
              (s) =>
                s.total_score !== null &&
                s.total_score !== undefined &&
                s.final_score !== null &&
                s.final_score !== undefined
            ).length;

            const partiallyGraded = sheet.filter(
              (s) =>
                (s.attendance_score !== null && s.attendance_score !== undefined) ||
                (s.midterm_score !== null && s.midterm_score !== undefined) ||
                (s.final_score !== null && s.final_score !== undefined)
            ).length;

            const passedCount = sheet.filter((s) => s.result_status === 'PASSED').length;
            const failedCount = sheet.filter((s) => s.result_status === 'FAILED').length;

            let sheetStatus = 'GRADING_IN_PROGRESS';
            if (sheet.length === 0) {
              sheetStatus = 'NO_STUDENTS';
            } else if (isLocked) {
              sheetStatus = 'LOCKED';
            } else if (fullyGraded === sheet.length && sheet.length > 0) {
              sheetStatus = 'COMPLETED_GRADING';
            } else {
              sheetStatus = 'GRADING_IN_PROGRESS';
            }

            return {
              classId: cls.id,
              totalStudents: sheet.length,
              fullyGraded,
              partiallyGraded,
              passedCount,
              failedCount,
              isLocked,
              isManuallyUnlocked,
              sheetStatus,
            };
          } catch (e) {
            return {
              classId: cls.id,
              totalStudents: cls.current_enrolled || 0,
              fullyGraded: cls.status === 'COMPLETED' ? cls.current_enrolled || 0 : 0,
              partiallyGraded: 0,
              passedCount: 0,
              failedCount: 0,
              isLocked: cls.status === 'COMPLETED',
              isManuallyUnlocked: false,
              sheetStatus:
                cls.status === 'COMPLETED'
                  ? 'LOCKED'
                  : cls.current_enrolled === 0
                  ? 'NO_STUDENTS'
                  : 'GRADING_IN_PROGRESS',
            };
          }
        })
      );

      results.forEach((r) => {
        if (r.status === 'fulfilled' && r.value) {
          statsMap[r.value.classId] = r.value;
        }
      });

      setSheetStats(statsMap);
    } catch (err) {
      console.error('Error loading sheet stats:', err);
    } finally {
      setLoadingStats(false);
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
      setLoading(true);
      const res = await gradesApi.getMyGrades();
      setMyGrades(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải bảng điểm cá nhân: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  const loadParentWards = async () => {
    try {
      setLoading(true);
      const res = await progressionParentApi.getParentWards();
      const list = res.data || [];
      setWards(list);
      if (list.length > 0) {
        setSelectedWardId(list[0].student_id);
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải thông tin con được giám hộ: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  const loadWardGrades = async (studentId) => {
    if (!studentId) return;
    try {
      setLoading(true);
      const res = await progressionParentApi.getWardGrades(studentId);
      setWardGrades(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải bảng điểm của con: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  const loadGradingSheet = async (classId) => {
    if (!classId) return;
    try {
      setLoading(true);
      const [sheetRes, statusRes] = await Promise.all([
        gradesApi.getGradingSheet(classId),
        gradesApi.getLockStatus(classId).catch(() => ({ data: { is_locked: false } })),
      ]);
      const sheet = sheetRes.data || [];
      const status = statusRes.data || { is_locked: false };
      setGradingSheet(sheet);
      setLockInfo(status);

      // Also update sheetStats entry for this class
      const isLocked = Boolean(status.is_locked) || (selectedClass?.status === 'COMPLETED');
      const isManuallyUnlocked = Boolean(status.is_manually_unlocked);
      const fullyGraded = sheet.filter(
        (s) =>
          s.total_score !== null &&
          s.total_score !== undefined &&
          s.final_score !== null &&
          s.final_score !== undefined
      ).length;
      const partiallyGraded = sheet.filter(
        (s) =>
          (s.attendance_score !== null && s.attendance_score !== undefined) ||
          (s.midterm_score !== null && s.midterm_score !== undefined) ||
          (s.final_score !== null && s.final_score !== undefined)
      ).length;
      const passedCount = sheet.filter((s) => s.result_status === 'PASSED').length;
      const failedCount = sheet.filter((s) => s.result_status === 'FAILED').length;

      let sheetStatus = 'GRADING_IN_PROGRESS';
      if (sheet.length === 0) {
        sheetStatus = 'NO_STUDENTS';
      } else if (isLocked) {
        sheetStatus = 'LOCKED';
      } else if (fullyGraded === sheet.length && sheet.length > 0) {
        sheetStatus = 'COMPLETED_GRADING';
      } else {
        sheetStatus = 'GRADING_IN_PROGRESS';
      }

      setSheetStats((prev) => ({
        ...prev,
        [classId]: {
          classId,
          totalStudents: sheet.length,
          fullyGraded,
          partiallyGraded,
          passedCount,
          failedCount,
          isLocked,
          isManuallyUnlocked,
          sheetStatus,
        },
      }));
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải bảng điểm lớp: ' + e.message);
    } finally {
      setLoading(false);
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

  // Load Grading Sheet when selected Class changes in detail level
  useEffect(() => {
    if (selectedClassId && (isTeacher || isAdminOrStaff) && activeLevel === 'detail') {
      loadGradingSheet(selectedClassId);
    }
  }, [selectedClassId, activeLevel]);

  // Score change handler for Teachers
  const handleScoreChange = (studentId, field, val) => {
    if (!isTeacher) return;
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
  const handleOpenLockModal = () => {
    setLockReason('');
    setShowLockModal(true);
  };

  const handleConfirmGradesSubmit = async (e) => {
    e.preventDefault();
    try {
      await gradesApi.confirmGrades(selectedClassId, lockReason);
      toast.success('Đã khóa sổ bảng điểm chính thức thành công!');
      setShowLockModal(false);
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Unlock grades
  const handleOpenUnlockModal = () => {
    setLockReason('');
    setShowUnlockModal(true);
  };

  const handleUnlockGradesSubmit = async (e) => {
    e.preventDefault();
    try {
      await gradesApi.unlockGrades(selectedClassId, lockReason);
      toast.success('Đã mở khóa bảng điểm thành công (hiệu lực 72 giờ)!');
      setShowUnlockModal(false);
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // View lock history for specific class or global
  const handleViewLockHistory = async (targetClassId) => {
    const cid = targetClassId || selectedClassId || (classes[0]?.id || 0);
    if (!cid) {
      toast.info('Vui lòng chọn một lớp học để xem lịch sử khóa điểm.');
      return;
    }
    setHistoryTargetClassId(cid);
    try {
      const res = await gradesApi.getLockHistory(cid);
      setLockHistory(res.data || []);
      setShowHistoryModal(true);
    } catch (e) {
      toast.error('Lỗi tải lịch sử khóa điểm: ' + e.message);
    }
  };

  // Switch class history inside history modal
  const handleHistoryClassChange = async (cid) => {
    setHistoryTargetClassId(Number(cid));
    try {
      const res = await gradesApi.getLockHistory(Number(cid));
      setLockHistory(res.data || []);
    } catch (e) {
      toast.error('Lỗi tải lịch sử khóa điểm: ' + e.message);
    }
  };

  // Delete student from grade sheet
  const handleDeleteStudent = async (studentId, studentName) => {
    const isConfirmed = await confirm({
      title: 'Xóa học viên khỏi bảng điểm',
      message: `Bạn có chắc chắn muốn XÓA điểm và gỡ học viên "${studentName}" khỏi lớp học này?`,
      confirmText: 'Xác nhận xóa',
      cancelText: 'Hủy bỏ',
      type: 'danger',
    });
    if (!isConfirmed) return;
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
        note: addForm.note,
      });
      toast.success('Thêm học viên vào bảng điểm lớp thành công!');
      setIsAddModalOpen(false);
      setAddForm({
        student_id: '',
        attendance_score: 0,
        midterm_score: 0,
        final_score: 0,
        note: '',
      });
      loadGradingSheet(selectedClassId);
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Navigation handlers between Level 1 and Level 2
  const handleSelectClassFromOverview = (cls) => {
    setSelectedClassId(cls.id);
    setActiveLevel('detail');
  };

  const handleBackToOverview = () => {
    setActiveLevel('overview');
  };

  const handleSelectAnotherClassInDetail = (cls) => {
    setSelectedClassId(cls.id);
  };

  // -------------------------------------------------------------
  // RENDER 1: HỌC VIÊN (STUDENT) - CHỈ XEM ĐIỂM CỦA CHÍNH MÌNH
  // -------------------------------------------------------------
  if (isStudent) {
    const passedCount = myGrades.filter((g) => g.result_status === 'PASSED').length;
    const avgScore =
      myGrades.length > 0
        ? (
            myGrades.reduce((acc, curr) => acc + (curr.total_score || 0), 0) / myGrades.length
          ).toFixed(2)
        : '--';

    return (
      <div className="space-y-6">
        {/* Quick KPI summary */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="bg-white p-5 rounded-3xl border border-slate-200/90 shadow-2xs">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              Khóa học đã đăng ký
            </span>
            <div className="text-2xl font-black text-slate-900 mt-2 tabular-nums">{myGrades.length}</div>
          </div>
          <div className="bg-white p-5 rounded-3xl border border-slate-200/90 shadow-2xs">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              Số môn Đạt chuẩn đầu ra
            </span>
            <div className="text-2xl font-black text-emerald-600 mt-2 tabular-nums">
              {passedCount} môn
            </div>
          </div>
          <div className="bg-white p-5 rounded-3xl border border-slate-200/90 shadow-2xs">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider">
              Điểm trung bình tích lũy
            </span>
            <div className="text-2xl font-black text-indigo-600 mt-2 tabular-nums">{avgScore}</div>
          </div>
        </div>

        {/* Personal Transcript Table */}
        <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
          <div className="p-4 sm:p-5 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between">
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
                        {g.attendance_score ?? '--'}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.midterm_score ?? '--'}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.final_score ?? '--'}
                      </td>
                      <td className="p-4 text-center font-mono font-black text-indigo-600 text-sm tabular-nums">
                        {g.total_score ?? '--'}
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
        {/* Ward Selector if multiple children */}
        {wards.length > 1 && (
          <div className="flex items-center gap-2 bg-white p-2.5 rounded-3xl border border-slate-200 shadow-2xs">
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
        <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
          <div className="p-4 sm:p-5 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between">
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
                        {g.attendance_score ?? '--'}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.midterm_score ?? '--'}
                      </td>
                      <td className="p-4 text-center font-mono font-bold text-slate-800 tabular-nums">
                        {g.final_score ?? '--'}
                      </td>
                      <td className="p-4 text-center font-mono font-black text-indigo-600 text-sm tabular-nums">
                        {g.total_score ?? '--'}
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
  // RENDER 3: ADMIN & ACADEMIC_STAFF & TEACHER (2-LEVEL VIEW)
  // -------------------------------------------------------------
  return (
    <div className="space-y-6">
      {/* CẤP ĐỘ 1: TỔNG QUAN QUẢN LÝ SỔ ĐIỂM */}
      {activeLevel === 'overview' && (
        <GradeOverviewLevel
          classes={classes}
          sheetStats={sheetStats}
          loading={loading}
          loadingStats={loadingStats}
          onRefresh={loadClasses}
          onSelectClass={handleSelectClassFromOverview}
          onOpenHistoryModal={() => handleViewLockHistory(selectedClassId)}
        />
      )}

      {/* CẤP ĐỘ 2: CHI TIẾT SỔ ĐIỂM CỦA LỚP */}
      {activeLevel === 'detail' && (
        <GradeDetailLevel
          classItem={selectedClass}
          allClasses={classes}
          gradingSheet={gradingSheet}
          lockInfo={lockInfo}
          isTeacher={isTeacher}
          isAdminOrStaff={isAdminOrStaff}
          loading={loading}
          onBackToOverview={isAdminOrStaff ? handleBackToOverview : undefined}
          onSelectAnotherClass={handleSelectAnotherClassInDetail}
          onScoreChange={handleScoreChange}
          onSaveGrades={handleSaveGrades}
          onOpenLockModal={handleOpenLockModal}
          onOpenUnlockModal={handleOpenUnlockModal}
          onViewLockHistory={() => handleViewLockHistory(selectedClassId)}
          onOpenAddModal={() => setIsAddModalOpen(true)}
          onDeleteStudent={handleDeleteStudent}
        />
      )}

      {/* ================= MODAL: THÊM HỌC VIÊN VÀO BẢNG ĐIỂM ================= */}
      {isAddModalOpen &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                <h3 className="text-base font-black text-slate-900">
                  Thêm Học viên vào Bảng điểm
                </h3>
                <button
                  type="button"
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
                        onChange={(e) =>
                          setAddForm({ ...addForm, attendance_score: parseFloat(e.target.value) || 0 })
                        }
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
                        onChange={(e) =>
                          setAddForm({ ...addForm, midterm_score: parseFloat(e.target.value) || 0 })
                        }
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
                        onChange={(e) =>
                          setAddForm({ ...addForm, final_score: parseFloat(e.target.value) || 0 })
                        }
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
                    className="px-4 py-2 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                  >
                    Hủy
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                  >
                    Thêm vào lớp
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ================= MODAL: KHÓA BẢNG ĐIỂM ================= */}
      {showLockModal &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                <div className="flex items-center gap-2">
                  <Lock className="w-5 h-5 text-emerald-600" />
                  <h3 className="text-base font-black text-slate-900">Khóa Bảng Điểm Lớp Học</h3>
                </div>
                <button
                  type="button"
                  onClick={() => setShowLockModal(false)}
                  className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
                >
                  ✕
                </button>
              </div>
              <form onSubmit={handleConfirmGradesSubmit} className="space-y-4 text-xs">
                <p className="text-slate-600">
                  Sau khi khóa, giảng viên sẽ không thể thêm, sửa hoặc xóa điểm số của lớp này nữa.
                </p>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Lý do khóa sổ điểm:</label>
                  <textarea
                    rows={3}
                    value={lockReason}
                    onChange={(e) => setLockReason(e.target.value)}
                    placeholder="Ví dụ: Đã hoàn tất nhập điểm và duyệt điểm cuối kỳ..."
                    className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-emerald-600 text-xs"
                  />
                </div>
                <div className="flex justify-end gap-2.5 pt-2 border-t border-slate-100">
                  <button
                    type="button"
                    onClick={() => setShowLockModal(false)}
                    className="px-4 py-2 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                  >
                    Hủy
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 bg-emerald-600 text-white rounded-xl font-bold hover:bg-emerald-700 shadow-sm shadow-emerald-200 cursor-pointer"
                  >
                    Xác nhận khóa điểm
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ================= MODAL: MỞ KHÓA BẢNG ĐIỂM ================= */}
      {showUnlockModal &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                <div className="flex items-center gap-2">
                  <Unlock className="w-5 h-5 text-amber-600" />
                  <h3 className="text-base font-black text-slate-900">Mở Khóa Bảng Điểm</h3>
                </div>
                <button
                  type="button"
                  onClick={() => setShowUnlockModal(false)}
                  className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
                >
                  ✕
                </button>
              </div>
              <form onSubmit={handleUnlockGradesSubmit} className="space-y-4 text-xs">
                <p className="text-slate-600">
                  Mở khóa bảng điểm để giảng viên phụ trách có thể sửa đổi điểm trong trường hợp nhập
                  nhầm. Thời hạn mở khóa là <strong>72 giờ</strong>. Toàn bộ thao tác sẽ được lưu vào lịch
                  sử kiểm toán.
                </p>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">
                    Lý do mở khóa điểm (bắt buộc):
                  </label>
                  <textarea
                    required
                    rows={3}
                    value={lockReason}
                    onChange={(e) => setLockReason(e.target.value)}
                    placeholder="Ví dụ: Giảng viên báo nhập nhầm điểm cuối kỳ của học viên..."
                    className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-amber-600 text-xs"
                  />
                </div>
                <div className="flex justify-end gap-2.5 pt-2 border-t border-slate-100">
                  <button
                    type="button"
                    onClick={() => setShowUnlockModal(false)}
                    className="px-4 py-2 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                  >
                    Hủy
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 bg-amber-600 text-white rounded-xl font-bold hover:bg-amber-700 shadow-sm shadow-amber-200 cursor-pointer"
                  >
                    Xác nhận mở khóa
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ================= MODAL: LỊCH SỬ KHÓA / MỞ KHÓA ================= */}
      {showHistoryModal &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200 max-h-[85vh] flex flex-col">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4 shrink-0">
                <div className="flex items-center gap-2">
                  <FileSpreadsheet className="w-5 h-5 text-indigo-600" />
                  <h3 className="text-base font-black text-slate-900">
                    Lịch Sử Khóa / Mở Khóa Bảng Điểm
                  </h3>
                </div>
                <button
                  type="button"
                  onClick={() => setShowHistoryModal(false)}
                  className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
                >
                  ✕
                </button>
              </div>

              {/* Class switcher in history modal */}
              {classes.length > 0 && (
                <div className="mb-4 flex items-center gap-2 shrink-0">
                  <span className="text-xs font-bold text-slate-600 whitespace-nowrap">Xem lịch sử của lớp:</span>
                  <select
                    value={historyTargetClassId}
                    onChange={(e) => handleHistoryClassChange(e.target.value)}
                    className="text-xs font-bold bg-slate-50 border border-slate-200 rounded-xl px-3 py-1.5 text-slate-800 outline-none hover:bg-slate-100 cursor-pointer w-full"
                  >
                    {classes.map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.class_code} - {c.course_title}
                      </option>
                    ))}
                  </select>
                </div>
              )}

              <div className="overflow-y-auto flex-1 text-xs pr-1">
                {lockHistory.length === 0 ? (
                  <div className="p-10 text-center text-slate-400 font-medium">
                    Chưa có lịch sử khóa hoặc mở khóa điểm cho lớp học này.
                  </div>
                ) : (
                  <div className="space-y-3">
                    {lockHistory.map((h) => (
                      <div
                        key={h.id}
                        className="p-3.5 rounded-2xl border border-slate-100 bg-slate-50/60 flex items-start justify-between gap-3"
                      >
                        <div>
                          <div className="flex items-center gap-2">
                            <span
                              className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                                h.action === 'LOCK'
                                  ? 'bg-emerald-100 text-emerald-800'
                                  : h.action === 'UNLOCK'
                                  ? 'bg-amber-100 text-amber-800'
                                  : 'bg-indigo-100 text-indigo-800'
                              }`}
                            >
                              {h.action === 'LOCK'
                                ? 'KHÓA ĐIỂM'
                                : h.action === 'UNLOCK'
                                ? 'MỞ KHÓA'
                                : 'TỰ ĐỘNG KHÓA'}
                            </span>
                            <span className="font-bold text-slate-800">
                              {h.performer_name || 'Hệ thống'}
                            </span>
                          </div>
                          <p className="text-slate-600 mt-1 font-medium">
                            {h.reason || 'Không có ghi chú'}
                          </p>
                        </div>
                        <span className="text-[11px] text-slate-400 shrink-0 font-mono">
                          {new Date(h.performed_at).toLocaleString('vi-VN')}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="pt-3 border-t border-slate-100 mt-4 flex justify-end shrink-0">
                <button
                  type="button"
                  onClick={() => setShowHistoryModal(false)}
                  className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl cursor-pointer"
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
