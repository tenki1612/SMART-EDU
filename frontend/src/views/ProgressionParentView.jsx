import React, { useEffect, useState, useMemo } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { useConfirm } from '../context/ConfirmDialogContext';
import { useHeaderSlot } from '../context/HeaderSlotContext';
import {
  enrollmentsApi,
  classesApi,
  progressionParentApi,
  studentsApi,
  coursesApi,
} from '../services/api';
import { UserAvatar } from '../components/common/UserAvatar';
import {
  Award,
  ShieldCheck,
  CheckCircle2,
  XCircle,
  Clock,
  Send,
  Ban,
  Trash2,
  Search,
  School,
  Sparkles,
  AlertTriangle,
  X,
  FileCheck2,
  ArrowRight,
  BookOpen,
  Users,
  Layers,
  ArrowUpRight,
  HelpCircle,
  Info,
} from 'lucide-react';

export const ProgressionParentView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const confirm = useConfirm();
  const headerSlot = useHeaderSlot();

  const isStudent = user?.role === 'STUDENT';
  const isParent = user?.role === 'PARENT';
  const isStaffOrAdmin = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  // Sub-tab selection:
  // Admin/Staff: 'requests' | 'eligibility'
  // Student: 'courses' | 'my_progressions' | 'classes'
  // Parent: 'wards' | 'ward_requests'
  const defaultSubTab = isParent ? 'wards' : isStudent ? 'courses' : 'requests';
  const [activeSubTab, setActiveSubTab] = useState(defaultSubTab);

  // ---------------------------------------------------------------------------
  // 1. DATA STATES
  // ---------------------------------------------------------------------------
  // Progression requests list (for Admin/Staff)
  const [progressionRequests, setProgressionRequests] = useState([]);
  const [filterStatus, setFilterStatus] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  // Student Course Transfer States
  const [availableCourses, setAvailableCourses] = useState([]);
  const [myProgressions, setMyProgressions] = useState([]);
  const [selectedCourseToTransfer, setSelectedCourseToTransfer] = useState(null);
  const [courseTransferNote, setCourseTransferNote] = useState('');
  const [isSubmittingTransfer, setIsSubmittingTransfer] = useState(false);

  // Student Open Classes for Registration
  const [openClasses, setOpenClasses] = useState([]);
  const [myClasses, setMyClasses] = useState([]);
  const [selectedClassToRegister, setSelectedClassToRegister] = useState(null);
  const [registerNote, setRegisterNote] = useState('');

  // Admin/Staff Rejection Modal
  const [rejectingProgressionId, setRejectingProgressionId] = useState(null);
  const [rejectionReason, setRejectionReason] = useState('');

  // Parent State
  const [wards, setWards] = useState([]);
  const [selectedWard, setSelectedWard] = useState(null);
  const [wardEnrollments, setWardEnrollments] = useState([]);

  // Staff Manual Eligibility Checker State
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

  // ---------------------------------------------------------------------------
  // 2. DATA LOADING
  // ---------------------------------------------------------------------------
  const loadData = async () => {
    try {
      if (isStudent) {
        const [resCourses, resMyProg, resOpenCls, resMyCls] = await Promise.all([
          progressionParentApi.getAvailableCourses(),
          progressionParentApi.getMyProgressions(),
          classesApi.list(undefined, 'OPEN_FOR_ENROLLMENT'),
          classesApi.list(),
        ]);
        setAvailableCourses(resCourses.data || []);
        setMyProgressions(resMyProg.data || []);
        setOpenClasses(resOpenCls.data || []);
        setMyClasses(resMyCls.data || []);
      } else if (isStaffOrAdmin) {
        const [resProg, resSt, resCo] = await Promise.all([
          progressionParentApi.listAll(filterStatus === 'ALL' ? undefined : filterStatus),
          studentsApi.list().catch(() => ({ data: [] })),
          coursesApi.list().catch(() => ({ data: [] })),
        ]);
        setProgressionRequests(resProg.data || []);
        setStudents(resSt.data || []);
        setCourses(resCo.data || []);
      } else if (isParent) {
        const res = await progressionParentApi.getParentWards();
        const wardList = res.data || [];
        setWards(wardList);
        if (wardList.length > 0 && !selectedWard) {
          setSelectedWard(wardList[0]);
        }
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải dữ liệu chuyển khóa học: ' + e.message);
    }
  };

  useEffect(() => {
    loadData();
  }, [filterStatus, user?.role]);

  useEffect(() => {
    if (selectedWard && isParent) {
      progressionParentApi
        .getWardEnrollmentStatus(selectedWard.student_id)
        .then((res) => setWardEnrollments(res.data || []))
        .catch((e) => toast.error('Lỗi tải thông tin đăng ký của con: ' + e.message));
    }
  }, [selectedWard]);

  // ---------------------------------------------------------------------------
  // 3. ACTION HANDLERS
  // ---------------------------------------------------------------------------
  // Student submits course progression request
  const handleRequestCourseTransfer = async (e) => {
    e.preventDefault();
    if (!selectedCourseToTransfer) return;
    setIsSubmittingTransfer(true);
    try {
      await progressionParentApi.requestProgression({
        next_course_id: selectedCourseToTransfer.id,
        note: courseTransferNote || undefined,
      });
      toast.success(
        `Đã gửi yêu cầu đăng ký chuyển sang khóa ${selectedCourseToTransfer.title}! Vui lòng chờ Học vụ phê duyệt.`
      );
      setSelectedCourseToTransfer(null);
      setCourseTransferNote('');
      setActiveSubTab('my_progressions');
      loadData();
    } catch (e) {
      toast.error(e.message || 'Không thể gửi yêu cầu chuyển khóa');
    } finally {
      setIsSubmittingTransfer(false);
    }
  };

  // Student cancels pending course progression request
  const handleCancelProgression = async (id) => {
    const isConfirmed = await confirm({
      title: 'Hủy yêu cầu chuyển khóa',
      message: 'Bạn có chắc chắn muốn hủy yêu cầu đăng ký chuyển khóa học này không?',
      confirmText: 'Xác nhận hủy',
      cancelText: 'Giữ lại',
      type: 'warning',
    });
    if (!isConfirmed) return;
    try {
      await progressionParentApi.cancelProgression(id);
      toast.success('Đã hủy yêu cầu chuyển khóa thành công!');
      loadData();
    } catch (e) {
      toast.error(e.message || 'Không thể hủy yêu cầu');
    }
  };

  // Student registers for a class in approved course
  const handleRegister = async (e) => {
    e.preventDefault();
    if (!selectedClassToRegister) return;
    try {
      await enrollmentsApi.createRequest(selectedClassToRegister.id, registerNote);
      toast.success('Đã gửi yêu cầu đăng ký lớp học thành công! Vui lòng chờ Học vụ phê duyệt.');
      setSelectedClassToRegister(null);
      setRegisterNote('');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Admin/Staff confirms progression
  const handleApproveProgression = async (id) => {
    const isConfirmed = await confirm({
      title: 'Phê duyệt chuyển khóa học',
      message: 'Xác nhận học viên đủ điều kiện chuyển khóa và cho phép đăng ký các lớp học thuộc khóa mục tiêu?',
      confirmText: 'Phê duyệt',
      cancelText: 'Xem lại',
      type: 'info',
    });
    if (!isConfirmed) return;
    try {
      await progressionParentApi.confirmProgression(id);
      toast.success('Đã duyệt chuyển khóa thành công! Học viên có thể đăng ký lớp thuộc khóa này.');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Admin/Staff rejects progression
  const handleRejectProgression = async (e) => {
    e.preventDefault();
    if (!rejectingProgressionId) return;
    try {
      await progressionParentApi.rejectProgression(rejectingProgressionId, rejectionReason);
      toast.info('Đã từ chối đơn chuyển khóa.');
      setRejectingProgressionId(null);
      setRejectionReason('');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

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
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // ---------------------------------------------------------------------------
  // 4. METRICS & FILTERING
  // ---------------------------------------------------------------------------
  const stats = useMemo(() => {
    const total = progressionRequests.length;
    const pending = progressionRequests.filter((r) => !r.is_confirmed).length;
    const approved = progressionRequests.filter((r) => r.is_confirmed).length;
    return { total, pending, approved };
  }, [progressionRequests]);

  const filteredRequests = useMemo(() => {
    return progressionRequests.filter((r) => {
      const q = searchTerm.toLowerCase();
      return (
        r.student_name?.toLowerCase().includes(q) ||
        r.student_code?.toLowerCase().includes(q) ||
        r.current_course_title?.toLowerCase().includes(q) ||
        r.next_course_title?.toLowerCase().includes(q)
      );
    });
  }, [progressionRequests, searchTerm]);

  // Set of confirmed course IDs for current student
  const studentConfirmedCourseIds = useMemo(() => {
    const ids = new Set();
    myProgressions.forEach((p) => {
      if (p.is_confirmed) ids.add(p.next_course_id);
    });
    myClasses.forEach((mc) => {
      if (mc.course_id) ids.add(mc.course_id);
    });
    return ids;
  }, [myProgressions, myClasses]);

  // ---------------------------------------------------------------------------
  // 5. RENDER
  // ---------------------------------------------------------------------------
  return (
    <div className="space-y-6">
      {/* Sub-tab Navigation Switcher Portaled to Top HeaderSlot */}
      {headerSlot &&
        createPortal(
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1 bg-slate-100 p-1 rounded-xl border border-slate-200/80">
              {isStaffOrAdmin && (
                <>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('requests')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'requests'
                        ? 'bg-white text-indigo-600 shadow-2xs'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <FileCheck2 className="w-3.5 h-3.5" />
                    <span>Yêu cầu chuyển khóa ({stats.pending})</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('eligibility')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'eligibility'
                        ? 'bg-white text-indigo-600 shadow-2xs'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <ShieldCheck className="w-3.5 h-3.5" />
                    <span>Thẩm định điều kiện</span>
                  </button>
                </>
              )}

              {isStudent && (
                <>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('courses')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'courses'
                        ? 'bg-white text-indigo-600 shadow-2xs font-extrabold'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <BookOpen className="w-3.5 h-3.5" />
                    <span>Đăng ký chuyển khóa ({availableCourses.length})</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('my_progressions')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'my_progressions'
                        ? 'bg-white text-indigo-600 shadow-2xs font-extrabold'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <FileCheck2 className="w-3.5 h-3.5" />
                    <span>Lịch sử chuyển khóa ({myProgressions.length})</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('classes')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'classes'
                        ? 'bg-white text-indigo-600 shadow-2xs font-extrabold'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <School className="w-3.5 h-3.5" />
                    <span>Lớp mở đăng ký</span>
                  </button>
                </>
              )}

              {isParent && (
                <>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('wards')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'wards'
                        ? 'bg-white text-indigo-600 shadow-2xs'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <Users className="w-3.5 h-3.5" />
                    <span>Lộ trình của con ({wards.length})</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveSubTab('ward_requests')}
                    className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                      activeSubTab === 'ward_requests'
                        ? 'bg-white text-indigo-600 shadow-2xs'
                        : 'text-slate-600 hover:text-slate-900'
                    }`}
                  >
                    <Clock className="w-3.5 h-3.5" />
                    <span>Đơn đăng ký</span>
                  </button>
                </>
              )}
            </div>

            {/* Quick Action Button for Student */}
            {isStudent && (
              <button
                type="button"
                onClick={() => setActiveSubTab('courses')}
                className="px-3.5 py-1.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-bold rounded-xl text-xs shadow-xs hover:shadow-md transition cursor-pointer flex items-center gap-1.5 shrink-0"
              >
                <Send className="w-3.5 h-3.5" />
                <span>+ Đăng ký chuyển khóa</span>
              </button>
            )}
          </div>,
          headerSlot
        )}

      {/* KPI Metric Overview for Admin/Staff */}
      {isStaffOrAdmin && (
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-3.5 sm:gap-4">
          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                Tổng hồ sơ chuyển khóa
              </span>
              <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                <Send className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
            <div className="text-[11px] text-slate-500 mt-1 font-medium">Hồ sơ tiến trình nâng khóa</div>
          </div>

          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-amber-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                Chờ học vụ phê duyệt
              </span>
              <div className="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                <Clock className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-amber-600 tabular-nums">{stats.pending}</div>
            <div className="text-[11px] text-amber-700/80 mt-1 font-medium">Cần thẩm định & duyệt</div>
          </div>

          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-emerald-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                Đã phê duyệt
              </span>
              <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <CheckCircle2 className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-emerald-600 tabular-nums">{stats.approved}</div>
            <div className="text-[11px] text-emerald-700/80 mt-1 font-medium">Được phép đăng ký lớp mới</div>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* STUDENT SECTION 1: AVAILABLE COURSES FOR PROGRESSION                      */}
      {/* ========================================================================= */}
      {isStudent && activeSubTab === 'courses' && (
        <div className="space-y-6">
          {/* Information Banner */}
          <div className="bg-gradient-to-r from-indigo-500/10 via-sky-500/10 to-transparent p-5 rounded-3xl border border-indigo-200/80 shadow-2xs">
            <div className="flex items-start gap-3.5">
              <div className="w-10 h-10 rounded-2xl bg-indigo-600 text-white flex items-center justify-center shrink-0 shadow-xs">
                <Info className="w-5 h-5" />
              </div>
              <div className="space-y-1">
                <h3 className="text-sm font-black text-slate-900">
                  Quy trình Chuyển khóa học & Nâng cấp độ đào tạo
                </h3>
                <p className="text-xs text-slate-600 leading-relaxed font-medium">
                  Theo quy định của trung tâm, học viên <strong>bắt buộc phải gửi đơn đăng ký chuyển khóa học</strong> và
                  được Học vụ phê duyệt đủ điều kiện trước khi có thể đăng ký vào các lớp học cụ thể thuộc khóa học đó.
                </p>
              </div>
            </div>
          </div>

          {/* Current Course Card */}
          {myClasses.length > 0 && (
            <div className="bg-white p-5 rounded-3xl border border-indigo-100 shadow-2xs">
              <div className="flex flex-wrap items-center justify-between gap-3 mb-3">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-2xl bg-indigo-600 text-white flex items-center justify-center shadow-xs">
                    <BookOpen className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] font-black uppercase tracking-wider text-indigo-500 block">
                      Khóa học hiện tại của bạn
                    </span>
                    <h3 className="text-base font-black text-slate-900 leading-tight">
                      {myClasses[0].course_title}
                    </h3>
                  </div>
                </div>
                <span className="text-xs font-bold px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1.5 shadow-2xs">
                  <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                  Đang theo học lớp {myClasses[0].class_code}
                </span>
              </div>
            </div>
          )}

          {/* List of Available Courses */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-xs font-black uppercase tracking-wider text-slate-700 flex items-center gap-2">
                <BookOpen className="w-4 h-4 text-indigo-600" />
                <span>Danh sách khóa học tiếp nhận chuyển khóa ({availableCourses.length})</span>
              </h3>
              <span className="text-[11px] text-slate-400 font-medium">
                Chọn khóa học mục tiêu để gửi đơn xét duyệt
              </span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {availableCourses.map((c) => (
                <div
                  key={c.id}
                  className={`bg-white p-5 rounded-3xl border shadow-2xs hover:shadow-md transition-all duration-200 flex flex-col justify-between ${
                    c.is_current
                      ? 'border-indigo-300 ring-2 ring-indigo-50'
                      : c.is_confirmed
                      ? 'border-emerald-300 ring-2 ring-emerald-50'
                      : 'border-slate-200/90 hover:border-indigo-200'
                  }`}
                >
                  <div>
                    <div className="flex items-center justify-between mb-2.5">
                      <span className="font-mono text-xs font-black bg-indigo-50 text-indigo-700 border border-indigo-200/60 px-2.5 py-1 rounded-xl shadow-2xs">
                        {c.code}
                      </span>
                      <span className="text-xs font-bold text-slate-600 tabular-nums">
                        {c.duration_weeks} tuần
                      </span>
                    </div>

                    <h4 className="font-black text-slate-900 text-sm leading-snug">{c.title}</h4>
                    <p className="text-xs text-indigo-600 font-bold mt-1">Chuẩn đầu ra: {c.target_level}</p>
                    <p className="text-xs text-slate-500 font-medium mt-1 line-clamp-2">
                      {c.description || 'Chương trình đào tạo tiêu chuẩn quốc tế'}
                    </p>
                  </div>

                  <div className="mt-4 pt-3.5 border-t border-slate-100 flex items-center justify-between text-xs">
                    <span className="text-slate-700 font-bold tabular-nums">
                      {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(c.fee || c.tuition_fee || 0)}
                    </span>

                    {c.is_current ? (
                      <span className="px-3 py-1.5 rounded-xl text-xs font-bold bg-indigo-50 text-indigo-700 border border-indigo-200">
                        Khóa hiện tại
                      </span>
                    ) : c.is_confirmed ? (
                      <button
                        type="button"
                        onClick={() => setActiveSubTab('classes')}
                        className="px-3.5 py-1.5 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs cursor-pointer flex items-center gap-1"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        <span>Đã duyệt • Đăng ký lớp</span>
                      </button>
                    ) : c.is_pending ? (
                      <span className="px-3 py-1.5 rounded-xl text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200 flex items-center gap-1">
                        <Clock className="w-3.5 h-3.5" />
                        <span>Chờ duyệt</span>
                      </span>
                    ) : (
                      <button
                        type="button"
                        onClick={() => setSelectedCourseToTransfer(c)}
                        className="px-3.5 py-1.5 rounded-xl text-xs font-bold bg-indigo-600 hover:bg-indigo-700 text-white shadow-xs transition-all cursor-pointer active:scale-95 flex items-center gap-1"
                      >
                        <Send className="w-3.5 h-3.5" />
                        <span>Đăng ký chuyển khóa</span>
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* STUDENT SECTION 2: MY PROGRESSION REQUESTS HISTORY                        */}
      {/* ========================================================================= */}
      {isStudent && activeSubTab === 'my_progressions' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-black uppercase tracking-wider text-slate-700 flex items-center gap-2">
              <FileCheck2 className="w-4 h-4 text-indigo-600" />
              <span>Lịch sử hồ sơ chuyển khóa học ({myProgressions.length})</span>
            </h3>
            <button
              type="button"
              onClick={() => setActiveSubTab('courses')}
              className="text-xs font-bold text-indigo-600 hover:text-indigo-700 cursor-pointer flex items-center gap-1"
            >
              <span>+ Đăng ký khóa mới</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
                  <tr>
                    <th className="p-4 pl-5">Mã hồ sơ</th>
                    <th className="p-4">Khóa hiện tại</th>
                    <th className="p-4">Khóa chuyển tới</th>
                    <th className="p-4">Điều kiện tiên quyết</th>
                    <th className="p-4 text-center">Trạng thái</th>
                    <th className="p-4">Ghi chú & Thẩm định</th>
                    <th className="p-4 pr-5 text-right">Thao tác</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {myProgressions.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="p-12 text-center text-slate-400 font-medium">
                        <FileCheck2 className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                        Bạn chưa gửi yêu cầu chuyển khóa học nào.
                      </td>
                    </tr>
                  ) : (
                    myProgressions.map((p) => (
                      <tr key={p.id} className="hover:bg-slate-50/70 transition-colors">
                        <td className="p-4 pl-5 font-mono font-bold text-slate-500">#{p.id}</td>
                        <td className="p-4 font-medium text-slate-700">{p.current_course_title}</td>
                        <td className="p-4 font-bold text-indigo-700">{p.next_course_title}</td>
                        <td className="p-4">
                          <span
                            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold border ${
                              p.is_eligible
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                                : 'bg-rose-50 text-rose-700 border-rose-200'
                            }`}
                          >
                            {p.is_eligible ? (
                              <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            ) : (
                              <AlertTriangle className="w-3 h-3 text-rose-600" />
                            )}
                            <span>{p.is_eligible ? 'Đạt chuẩn đầu ra' : 'Cần học vụ thẩm định'}</span>
                          </span>
                        </td>
                        <td className="p-4 text-center">
                          <span
                            className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full font-bold text-[10px] border ${
                              p.is_confirmed
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                                : 'bg-amber-50 text-amber-800 border-amber-200/80'
                            }`}
                          >
                            {p.is_confirmed ? (
                              <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            ) : (
                              <Clock className="w-3 h-3 text-amber-600" />
                            )}
                            <span>{p.is_confirmed ? 'Đã phê duyệt' : 'Chờ học vụ duyệt'}</span>
                          </span>
                        </td>
                        <td className="p-4 text-slate-600 max-w-[220px]">
                          <span className="text-[11px] font-medium">{p.note || '--'}</span>
                          {p.confirmed_by_name && (
                            <div className="text-[10px] text-slate-400 mt-0.5">
                              Người duyệt: {p.confirmed_by_name}
                            </div>
                          )}
                        </td>
                        <td className="p-4 pr-5 text-right">
                          {!p.is_confirmed ? (
                            <button
                              type="button"
                              onClick={() => handleCancelProgression(p.id)}
                              className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 font-bold border border-rose-200 rounded-xl cursor-pointer transition text-xs shadow-2xs active:scale-95"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                              <span>Hủy yêu cầu</span>
                            </button>
                          ) : (
                            <button
                              type="button"
                              onClick={() => setActiveSubTab('classes')}
                              className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl cursor-pointer transition text-xs shadow-xs active:scale-95"
                            >
                              <School className="w-3.5 h-3.5" />
                              <span>Đăng ký lớp</span>
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
        </div>
      )}

      {/* ========================================================================= */}
      {/* STUDENT SECTION 3: OPEN CLASSES                                           */}
      {/* ========================================================================= */}
      {isStudent && activeSubTab === 'classes' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-xs font-black uppercase tracking-wider text-slate-700 flex items-center gap-2">
                <School className="w-4 h-4 text-indigo-600" />
                <span>Các lớp học đang mở đăng ký ({openClasses.length})</span>
              </h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Chỉ những lớp học thuộc khóa bạn đã học hoặc đã được phê duyệt chuyển khóa mới được phép ghi danh.
              </p>
            </div>
            <button
              type="button"
              onClick={() => setActiveSubTab('courses')}
              className="text-xs font-bold text-indigo-600 hover:text-indigo-700 cursor-pointer flex items-center gap-1"
            >
              <span>+ Chuyển khóa học</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {openClasses.map((cls) => {
              const isEligibleForClass = studentConfirmedCourseIds.has(cls.course_id);
              return (
                <div
                  key={cls.id}
                  className={`bg-white p-5 rounded-3xl border shadow-2xs hover:shadow-md transition-all duration-200 flex flex-col justify-between ${
                    isEligibleForClass
                      ? 'border-indigo-200/90'
                      : 'border-slate-200/80 bg-slate-50/50'
                  }`}
                >
                  <div>
                    <div className="flex items-center justify-between mb-2.5">
                      <span className="font-mono text-xs font-black bg-indigo-50 text-indigo-700 border border-indigo-200/60 px-2.5 py-1 rounded-xl shadow-2xs">
                        {cls.class_code}
                      </span>
                      <span className="text-xs font-bold text-slate-600 tabular-nums">
                        Sĩ số: {cls.current_enrolled}/{cls.max_capacity}
                      </span>
                    </div>

                    <h4 className="font-black text-slate-900 text-sm leading-snug">{cls.course_title}</h4>
                    <p className="text-xs text-indigo-600 font-bold mt-1">Chuẩn đầu ra: {cls.target_level}</p>

                    {!isEligibleForClass && (
                      <div className="mt-2 text-[11px] font-semibold text-amber-700 bg-amber-50 border border-amber-200/80 p-2 rounded-xl flex items-center gap-1.5">
                        <AlertTriangle className="w-3.5 h-3.5 shrink-0 text-amber-600" />
                        <span>Cần đăng ký chuyển khóa trước</span>
                      </div>
                    )}
                  </div>

                  <div className="mt-4 pt-3.5 border-t border-slate-100 flex items-center justify-between text-xs">
                    <span className="text-slate-500 font-medium">
                      GV: <strong className="text-slate-700">{cls.teacher_name || 'Đang xếp'}</strong>
                    </span>

                    {cls.is_enrolled ? (
                      <span className="px-3 py-1.5 rounded-xl text-xs font-bold bg-slate-100 text-slate-500 border border-slate-200">
                        Đang theo học
                      </span>
                    ) : isEligibleForClass ? (
                      <button
                        type="button"
                        disabled={cls.is_full}
                        onClick={() => setSelectedClassToRegister(cls)}
                        className={`px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs transition-all cursor-pointer active:scale-95 ${
                          cls.is_full
                            ? 'bg-slate-100 text-slate-400 cursor-not-allowed border border-slate-200'
                            : 'bg-indigo-600 hover:bg-indigo-700 text-white shadow-indigo-200'
                        }`}
                      >
                        {cls.is_full ? 'Hết chỗ' : 'Đăng ký lớp này'}
                      </button>
                    ) : (
                      <button
                        type="button"
                        onClick={() => setActiveSubTab('courses')}
                        className="px-3 py-1.5 rounded-xl text-xs font-bold bg-amber-100 hover:bg-amber-200 text-amber-800 cursor-pointer flex items-center gap-1"
                      >
                        <span>Chuyển khóa trước</span>
                        <ArrowRight className="w-3 h-3" />
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* ADMIN & STAFF SECTION: PROGRESSION REQUESTS TABLE                         */}
      {/* ========================================================================= */}
      {isStaffOrAdmin && activeSubTab === 'requests' && (
        <div className="space-y-4">
          {/* Search and Filters */}
          <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
            <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
              <Search className="w-4 h-4 text-slate-400 shrink-0" />
              <input
                type="text"
                placeholder="Tìm theo tên học viên, mã HV, khóa hiện tại hoặc khóa mục tiêu..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full text-xs outline-hidden text-slate-800 placeholder:text-slate-400 bg-transparent font-medium"
              />
              {searchTerm && (
                <button
                  type="button"
                  onClick={() => setSearchTerm('')}
                  className="text-slate-400 hover:text-slate-600 cursor-pointer p-0.5"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              )}
            </div>

            <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 shrink-0">
              {[
                { id: 'ALL', label: 'Tất cả' },
                { id: 'PENDING', label: 'Chờ duyệt' },
                { id: 'CONFIRMED', label: 'Đã duyệt' },
              ].map((st) => {
                const isSelected = filterStatus === st.id;
                return (
                  <button
                    key={st.id}
                    type="button"
                    onClick={() => setFilterStatus(st.id)}
                    className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
                      isSelected
                        ? 'bg-indigo-600 text-white shadow-xs'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200/70'
                    }`}
                  >
                    {st.label}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Table */}
          <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
                  <tr>
                    <th className="p-4 pl-5">Mã hồ sơ</th>
                    <th className="p-4">Học viên</th>
                    <th className="p-4">Lộ trình chuyển khóa</th>
                    <th className="p-4">Điều kiện tiên quyết</th>
                    <th className="p-4 text-center">Trạng thái</th>
                    <th className="p-4">Ghi chú</th>
                    <th className="p-4 pr-5 text-right">Thao tác</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {filteredRequests.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="p-12 text-center text-slate-400 font-medium">
                        <FileCheck2 className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                        Không tìm thấy hồ sơ chuyển khóa học nào.
                      </td>
                    </tr>
                  ) : (
                    filteredRequests.map((r) => (
                      <tr key={r.id} className="hover:bg-slate-50/70 transition-colors">
                        <td className="p-4 pl-5 font-mono font-bold text-slate-500">#{r.id}</td>

                        <td className="p-4">
                          <div className="flex items-center gap-2.5">
                            <UserAvatar name={r.student_name} role="STUDENT" size="xs" shape="rounded-lg" />
                            <div>
                              <div className="font-bold text-slate-900">{r.student_name}</div>
                              <div className="font-mono text-[10px] text-indigo-600 font-bold">
                                {r.student_code}
                              </div>
                            </div>
                          </div>
                        </td>

                        <td className="p-4">
                          <div className="flex items-center gap-1.5 font-bold text-slate-800">
                            <span>{r.current_course_title}</span>
                            <ArrowRight className="w-3.5 h-3.5 text-indigo-600" />
                            <span className="text-indigo-600">{r.next_course_title}</span>
                          </div>
                        </td>

                        <td className="p-4">
                          <span
                            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold border ${
                              r.is_eligible
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                                : 'bg-rose-50 text-rose-700 border-rose-200'
                            }`}
                          >
                            {r.is_eligible ? (
                              <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            ) : (
                              <AlertTriangle className="w-3 h-3 text-rose-600" />
                            )}
                            <span>{r.is_eligible ? 'Đã đạt chuẩn đầu ra' : 'Chưa đạt chuẩn'}</span>
                          </span>
                        </td>

                        <td className="p-4 text-center">
                          <span
                            className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full font-bold text-[10px] border ${
                              r.is_confirmed
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                                : 'bg-amber-50 text-amber-800 border-amber-200/80'
                            }`}
                          >
                            {r.is_confirmed ? (
                              <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            ) : (
                              <Clock className="w-3 h-3 text-amber-600" />
                            )}
                            <span>{r.is_confirmed ? 'Đã phê duyệt' : 'Chờ học vụ duyệt'}</span>
                          </span>
                        </td>

                        <td className="p-4 text-slate-600 max-w-[200px]">
                          <span className="text-slate-600 text-[11px] font-medium block">{r.note || '--'}</span>
                          {r.confirmed_by_name && (
                            <span className="text-[10px] text-slate-400 block mt-0.5">
                              Duyệt bởi: {r.confirmed_by_name}
                            </span>
                          )}
                        </td>

                        <td className="p-4 pr-5 text-right">
                          <div className="space-x-1.5 inline-flex items-center justify-end">
                            {!r.is_confirmed ? (
                              <>
                                <button
                                  type="button"
                                  onClick={() => handleApproveProgression(r.id)}
                                  className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl shadow-xs cursor-pointer active:scale-95 text-xs"
                                >
                                  Phê duyệt chuyển khóa
                                </button>
                                <button
                                  type="button"
                                  onClick={() => setRejectingProgressionId(r.id)}
                                  className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-bold rounded-xl cursor-pointer active:scale-95 text-xs"
                                >
                                  Từ chối
                                </button>
                              </>
                            ) : (
                              <span className="text-emerald-700 font-bold text-xs bg-emerald-50 px-2.5 py-1 rounded-xl border border-emerald-200">
                                Đã phê duyệt
                              </span>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* ADMIN & STAFF SECTION: MANUAL ELIGIBILITY CHECKER                         */}
      {/* ========================================================================= */}
      {isStaffOrAdmin && activeSubTab === 'eligibility' && (
        <div className="bg-white rounded-3xl border border-slate-200/80 p-6 sm:p-7 shadow-xs space-y-6">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-2xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600 shrink-0">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-black text-slate-900 text-base">
                Thẩm định & Kiểm tra Điều kiện Tiên quyết Chuyển khóa
              </h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Quy tắc nghiệp vụ: Hệ thống kiểm tra điểm số khóa học tiên quyết hiện tại (phải đạt chuẩn 'PASSED') trước khi phê duyệt học viên ghi danh vào khóa tiếp theo.
              </p>
            </div>
          </div>

          <form onSubmit={handleCheckEligibility} className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs pt-2">
            <div>
              <label className="font-bold text-slate-700 block mb-1.5">Học viên cần thẩm định:</label>
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
              <label className="font-bold text-slate-700 block mb-1.5">Khóa học mục tiêu chuyển lên:</label>
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
                <span>{isChecking ? 'Đang thẩm định...' : 'Kiểm tra điều kiện tiên quyết'}</span>
              </button>
            </div>
          </form>

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

              {isStaffOrAdmin && eligibilityResult.is_eligible && (
                <div className="shrink-0">
                  {eligibilityResult.is_confirmed ? (
                    <span className="inline-flex items-center gap-1.5 bg-emerald-600 text-white font-bold px-3.5 py-2 rounded-xl text-xs shadow-xs">
                      <CheckCircle2 className="w-4 h-4" /> Đã duyệt nâng khóa
                    </span>
                  ) : (
                    <button
                      type="button"
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

      {/* ========================================================================= */}
      {/* PARENT PORTAL                                                             */}
      {/* ========================================================================= */}
      {isParent && (
        <div className="space-y-6">
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
                    <div className="flex items-center gap-3.5">
                      <UserAvatar name={w.full_name} role="STUDENT" size="md" shape="rounded-2xl" />
                      <div>
                        <div className="font-black text-slate-900 text-sm">{w.full_name}</div>
                        <div className="text-xs text-indigo-600 font-mono font-bold">{w.student_code}</div>
                        <div className="text-[11px] text-slate-400 mt-0.5">{w.relationship_type}</div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {selectedWard && (
            <div className="bg-white rounded-3xl border border-slate-200/80 p-5 shadow-xs space-y-4">
              <h4 className="font-bold text-slate-800 text-xs">
                Trạng thái đăng ký khóa học của {selectedWard.full_name}
              </h4>
              <div className="overflow-x-auto">
                <table className="w-full text-xs text-left">
                  <thead className="bg-slate-50 text-slate-600 font-bold border-b border-slate-200">
                    <tr>
                      <th className="py-2.5 px-4">Lớp học</th>
                      <th className="py-2.5 px-4">Khóa học</th>
                      <th className="py-2.5 px-4">Ngày đăng ký</th>
                      <th className="py-2.5 px-4">Trạng thái</th>
                      <th className="py-2.5 px-4">Ghi chú</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {wardEnrollments.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="py-8 text-center text-slate-400">
                          Chưa có yêu cầu đăng ký nào.
                        </td>
                      </tr>
                    ) : (
                      wardEnrollments.map((en) => (
                        <tr key={en.id}>
                          <td className="py-3 px-4 font-mono font-bold text-indigo-600">{en.class_code}</td>
                          <td className="py-3 px-4 font-semibold text-slate-800">{en.course_title}</td>
                          <td className="py-3 px-4 text-slate-500">
                            {new Date(en.request_date).toLocaleDateString('vi-VN')}
                          </td>
                          <td className="py-3 px-4">
                            <span
                              className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold ${
                                en.status === 'APPROVED'
                                  ? 'bg-emerald-50 text-emerald-700'
                                  : en.status === 'REJECTED'
                                  ? 'bg-rose-50 text-rose-700'
                                  : 'bg-amber-50 text-amber-700'
                              }`}
                            >
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
      )}

      {/* ========================================================================= */}
      {/* MODAL 1: STUDENT SENDS COURSE PROGRESSION REQUEST                          */}
      {/* ========================================================================= */}
      {selectedCourseToTransfer &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                    <Send className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-black text-slate-900">
                      Đăng Ký Chuyển Khóa Học
                    </h3>
                    <span className="text-xs text-slate-400">{selectedCourseToTransfer.code}</span>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setSelectedCourseToTransfer(null)}
                  className="text-slate-400 hover:text-slate-600 p-1.5 rounded-xl hover:bg-slate-100 cursor-pointer transition"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <form onSubmit={handleRequestCourseTransfer} className="space-y-4 text-xs">
                <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-100 space-y-2">
                  {myClasses[0] && (
                    <div className="flex justify-between pb-2 border-b border-slate-200/60">
                      <span className="text-slate-500">Khóa hiện tại:</span>
                      <span className="font-bold text-slate-800">{myClasses[0].course_title}</span>
                    </div>
                  )}
                  <div className="flex justify-between">
                    <span className="text-slate-500">Khóa chuyển tới:</span>
                    <span className="font-bold text-indigo-700">{selectedCourseToTransfer.title}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Chuẩn đầu ra:</span>
                    <span className="font-bold text-indigo-600">{selectedCourseToTransfer.target_level}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Thời lượng:</span>
                    <span className="font-bold text-slate-800">{selectedCourseToTransfer.duration_weeks} tuần</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Học phí:</span>
                    <span className="font-bold text-emerald-700">
                      {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(
                        selectedCourseToTransfer.fee || selectedCourseToTransfer.tuition_fee || 0
                      )}
                    </span>
                  </div>
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1.5">
                    Ghi chú / Nguyện vọng học viên:
                  </label>
                  <textarea
                    rows={3}
                    value={courseTransferNote}
                    onChange={(e) => setCourseTransferNote(e.target.value)}
                    placeholder="Ví dụ: Em đã hoàn thành khóa IELTS 6.5 và mong muốn nâng cấp độ lên IELTS 7.5..."
                    className="w-full border border-slate-200 p-3 rounded-2xl bg-slate-50 focus:bg-white outline-hidden focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 transition resize-none font-medium text-xs"
                  />
                </div>

                <div className="flex items-center gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setSelectedCourseToTransfer(null)}
                    className="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200/80 text-slate-700 font-bold rounded-xl transition cursor-pointer text-xs"
                  >
                    Đóng
                  </button>
                  <button
                    type="submit"
                    disabled={isSubmittingTransfer}
                    className="flex-1 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-bold rounded-xl shadow-md shadow-indigo-200 transition cursor-pointer text-xs flex items-center justify-center gap-1.5"
                  >
                    <Send className="w-3.5 h-3.5" />
                    <span>{isSubmittingTransfer ? 'Đang gửi...' : 'Xác nhận gửi yêu cầu'}</span>
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ========================================================================= */}
      {/* MODAL 2: STUDENT ENROLLS IN CLASS                                         */}
      {/* ========================================================================= */}
      {selectedClassToRegister &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                    <School className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-black text-slate-900">
                      Đăng Ký Lớp: {selectedClassToRegister.class_code}
                    </h3>
                    <span className="text-xs text-slate-400">{selectedClassToRegister.course_title}</span>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setSelectedClassToRegister(null)}
                  className="text-slate-400 hover:text-slate-600 p-1.5 rounded-xl hover:bg-slate-100 cursor-pointer transition"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <form onSubmit={handleRegister} className="space-y-4 text-xs">
                <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-100 space-y-2">
                  <div className="flex justify-between">
                    <span className="text-slate-500">Khóa học:</span>
                    <span className="font-bold text-indigo-700">{selectedClassToRegister.course_title}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Chuẩn đầu ra:</span>
                    <span className="font-bold text-indigo-600">{selectedClassToRegister.target_level}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Giáo viên:</span>
                    <span className="font-semibold text-slate-800">
                      {selectedClassToRegister.teacher_name || 'Đang xếp'}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Sĩ số:</span>
                    <span className="font-bold text-slate-800">
                      {selectedClassToRegister.current_enrolled}/{selectedClassToRegister.max_capacity}
                    </span>
                  </div>
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1.5">Ghi chú đăng ký:</label>
                  <textarea
                    rows={3}
                    value={registerNote}
                    onChange={(e) => setRegisterNote(e.target.value)}
                    placeholder="Ghi chú thêm nếu có..."
                    className="w-full border border-slate-200 p-3 rounded-2xl bg-slate-50 focus:bg-white outline-hidden focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 transition resize-none font-medium text-xs"
                  />
                </div>

                <div className="flex items-center gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setSelectedClassToRegister(null)}
                    className="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200/80 text-slate-700 font-bold rounded-xl transition cursor-pointer text-xs"
                  >
                    Đóng
                  </button>
                  <button
                    type="submit"
                    className="flex-1 py-2.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-bold rounded-xl shadow-md shadow-indigo-200 transition cursor-pointer text-xs flex items-center justify-center gap-1.5"
                  >
                    <Send className="w-3.5 h-3.5" />
                    <span>Xác nhận đăng ký lớp</span>
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ========================================================================= */}
      {/* MODAL 3: STAFF REJECTS PROGRESSION REQUEST                                 */}
      {/* ========================================================================= */}
      {rejectingProgressionId &&
        createPortal(
          <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
            <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-2xl bg-rose-50 border border-rose-100 flex items-center justify-center text-rose-600">
                    <XCircle className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-black text-slate-900">
                      Từ Chối Đơn Chuyển Khóa #{rejectingProgressionId}
                    </h3>
                    <span className="text-xs text-slate-400">Gửi thông báo lý do đến học viên</span>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setRejectingProgressionId(null)}
                  className="text-slate-400 hover:text-slate-600 p-1.5 rounded-xl hover:bg-slate-100 cursor-pointer transition"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <form onSubmit={handleRejectProgression} className="space-y-4 text-xs">
                <div>
                  <label className="font-bold text-slate-700 block mb-1.5">
                    Lý do từ chối: <span className="text-rose-500">*</span>
                  </label>
                  <textarea
                    rows={3}
                    required
                    value={rejectionReason}
                    onChange={(e) => setRejectionReason(e.target.value)}
                    placeholder="Ví dụ: Học viên chưa hoàn thành đạt chuẩn đầu ra khóa tiên quyết..."
                    className="w-full border border-slate-200 p-3 rounded-2xl bg-slate-50 focus:bg-white outline-hidden focus:border-rose-600 focus:ring-2 focus:ring-rose-100 transition resize-none font-medium text-xs"
                  />
                </div>

                <div className="flex items-center gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setRejectingProgressionId(null)}
                    className="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200/80 text-slate-700 font-bold rounded-xl transition cursor-pointer text-xs"
                  >
                    Xem lại
                  </button>
                  <button
                    type="submit"
                    className="flex-1 py-2.5 bg-rose-600 hover:bg-rose-700 active:scale-95 text-white font-bold rounded-xl shadow-md shadow-rose-200 transition cursor-pointer text-xs flex items-center justify-center gap-1.5"
                  >
                    <XCircle className="w-3.5 h-3.5" />
                    <span>Xác nhận từ chối</span>
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}
    </div>
  );
};
