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
  // Student: 'requests' | 'classes'
  // Parent: 'wards' | 'ward_requests'
  const defaultSubTab = isParent ? 'wards' : isStudent ? 'requests' : 'requests';
  const [activeSubTab, setActiveSubTab] = useState(defaultSubTab);

  // ---------------------------------------------------------------------------
  // 1. DATA STATES
  // ---------------------------------------------------------------------------
  // Requests list (shared / role-aware)
  const [requests, setRequests] = useState([]);
  const [filterStatus, setFilterStatus] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  // Student Open Classes for Registration
  const [openClasses, setOpenClasses] = useState([]);
  const [selectedClassToRegister, setSelectedClassToRegister] = useState(null);
  const [registerNote, setRegisterNote] = useState('');

  // Admin/Staff Rejection Modal
  const [rejectingRequestId, setRejectingRequestId] = useState(null);
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
        const [resCls, resReq] = await Promise.all([
          classesApi.list(undefined, 'OPEN_FOR_ENROLLMENT'),
          enrollmentsApi.getMyRequests(),
        ]);
        setOpenClasses(resCls.data || []);
        setRequests(resReq.data || []);
      } else if (isStaffOrAdmin) {
        const [resReq, resSt, resCo] = await Promise.all([
          enrollmentsApi.listAll(filterStatus === 'ALL' ? undefined : filterStatus),
          studentsApi.list().catch(() => ({ data: [] })),
          coursesApi.list().catch(() => ({ data: [] })),
        ]);
        setRequests(resReq.data || []);
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
  const handleRegister = async (e) => {
    e.preventDefault();
    if (!selectedClassToRegister) return;
    try {
      await enrollmentsApi.createRequest(selectedClassToRegister.id, registerNote);
      toast.success('Đã gửi yêu cầu chuyển khóa học thành công! Vui lòng chờ Học vụ phê duyệt.');
      setSelectedClassToRegister(null);
      setRegisterNote('');
      setActiveSubTab('requests');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleApprove = async (id) => {
    const isConfirmed = await confirm({
      title: 'Phê duyệt chuyển khóa học',
      message: 'Xác nhận duyệt yêu cầu chuyển khóa này và ghi danh học viên vào lớp học mới?',
      confirmText: 'Phê duyệt',
      cancelText: 'Xem lại',
      type: 'info',
    });
    if (!isConfirmed) return;
    try {
      await enrollmentsApi.approve(id);
      toast.success('Đã duyệt chuyển khóa thành công và ghi danh học viên vào lớp mới!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleCancelRequest = async (id) => {
    const isConfirmed = await confirm({
      title: 'Hủy yêu cầu chuyển khóa',
      message: 'Bạn có chắc chắn muốn hủy yêu cầu chuyển khóa này không? Trạng thái sẽ được chuyển sang ĐÃ HỦY.',
      confirmText: 'Xác nhận hủy',
      cancelText: 'Giữ lại đơn',
      type: 'warning',
    });
    if (!isConfirmed) return;
    try {
      await enrollmentsApi.cancelRequest(id);
      toast.success('Đã hủy yêu cầu chuyển khóa học thành công!');
      loadData();
    } catch (e) {
      toast.error(e.message || 'Không thể hủy yêu cầu');
    }
  };

  const handleReject = async (e) => {
    e.preventDefault();
    if (!rejectingRequestId) return;
    try {
      await enrollmentsApi.reject(rejectingRequestId, rejectionReason);
      toast.info('Đã từ chối đơn chuyển khóa và lưu lý do phản hồi.');
      setRejectingRequestId(null);
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
    } catch (e) {
      toast.error(e.message);
    }
  };

  // ---------------------------------------------------------------------------
  // 4. METRICS & FILTERING
  // ---------------------------------------------------------------------------
  const stats = useMemo(() => {
    const total = requests.length;
    const pending = requests.filter((r) => r.status === 'PENDING').length;
    const approved = requests.filter((r) => r.status === 'APPROVED').length;
    const rejectedOrCancelled = requests.filter((r) => ['REJECTED', 'CANCELLED'].includes(r.status)).length;
    return { total, pending, approved, rejectedOrCancelled };
  }, [requests]);

  const filteredRequests = useMemo(() => {
    return requests.filter((r) => {
      const q = searchTerm.toLowerCase();
      return (
        r.student_name?.toLowerCase().includes(q) ||
        r.student_code?.toLowerCase().includes(q) ||
        r.class_code?.toLowerCase().includes(q) ||
        r.course_title?.toLowerCase().includes(q)
      );
    });
  }, [requests, searchTerm]);

  // ---------------------------------------------------------------------------
  // 5. RENDER
  // ---------------------------------------------------------------------------
  return (
    <div className="space-y-6">

      {/* Sub-tab Navigation Switcher Portaled to Top HeaderSlot */}
      {headerSlot && createPortal(
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
                onClick={() => setActiveSubTab('requests')}
                className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                  activeSubTab === 'requests'
                    ? 'bg-white text-indigo-600 shadow-2xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <FileCheck2 className="w-3.5 h-3.5" />
                <span>Lịch sử chuyển khóa ({requests.length})</span>
              </button>
              <button
                type="button"
                onClick={() => setActiveSubTab('classes')}
                className={`px-3 py-1 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                  activeSubTab === 'classes'
                    ? 'bg-white text-indigo-600 shadow-2xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <School className="w-3.5 h-3.5" />
                <span>Lớp mở chuyển khóa ({openClasses.length})</span>
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

          {/* Action button for Student (moved up to top header) */}
          {isStudent && (
            <button
              type="button"
              onClick={() => setActiveSubTab('classes')}
              className="px-3.5 py-1.5 bg-indigo-600 hover:bg-indigo-700 active:scale-95 text-white font-bold rounded-xl text-xs shadow-xs hover:shadow-md transition cursor-pointer flex items-center gap-1.5 shrink-0"
            >
              <Send className="w-3.5 h-3.5" />
              <span>+ Đăng ký chuyển khóa</span>
            </button>
          )}
        </div>,
        headerSlot
      )}

      {/* KPI Metric Overview for Admin/Staff (Hidden for Students) */}
      {isStaffOrAdmin && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng số đơn</span>
              <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
                <Send className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
            <div className="text-[11px] text-slate-500 mt-1 font-medium">Yêu cầu chuyển khóa</div>
          </div>

          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-amber-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Chờ xét duyệt</span>
              <div className="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                <Clock className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-amber-600 tabular-nums">{stats.pending}</div>
            <div className="text-[11px] text-amber-700/80 mt-1 font-medium">Cần học vụ xử lý</div>
          </div>

          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-emerald-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đã phê duyệt</span>
              <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <CheckCircle2 className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-emerald-600 tabular-nums">{stats.approved}</div>
            <div className="text-[11px] text-emerald-700/80 mt-1 font-medium">Đã vào lớp mới</div>
          </div>

          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-rose-200 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Từ chối / Hủy</span>
              <div className="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center">
                <XCircle className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-rose-600 tabular-nums">{stats.rejectedOrCancelled}</div>
            <div className="text-[11px] text-rose-700/80 mt-1 font-medium">Đã khép hồ sơ</div>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* SECTION A: STUDENT OPEN CLASSES                                           */}
      {/* ========================================================================= */}
      {isStudent && activeSubTab === 'classes' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-black uppercase tracking-wider text-slate-700 flex items-center gap-2">
              <School className="w-4 h-4 text-indigo-600" />
              <span>Các khóa học & lớp đang mở chuyển khóa ({openClasses.length})</span>
            </h3>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {openClasses.map((cls) => (
              <div
                key={cls.id}
                className="bg-white p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:shadow-md hover:border-indigo-200 transition-all duration-200 flex flex-col justify-between"
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
                  <p className="text-xs text-indigo-600 font-bold mt-1">
                    Chuẩn đầu ra: {cls.target_level}
                  </p>
                </div>

                <div className="mt-4 pt-3.5 border-t border-slate-100 flex items-center justify-between text-xs">
                  <span className="text-slate-500 font-medium">
                    GV: <strong className="text-slate-700">{cls.teacher_name || 'Đang phân công'}</strong>
                  </span>

                  <button
                    type="button"
                    disabled={cls.is_full}
                    onClick={() => setSelectedClassToRegister(cls)}
                    className={`px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs transition-all cursor-pointer active:scale-95 ${
                      cls.is_full
                        ? 'bg-slate-100 text-slate-400 cursor-not-allowed border border-slate-200'
                        : 'bg-indigo-600 hover:bg-indigo-700 text-white'
                    }`}
                  >
                    {cls.is_full ? 'Hết chỗ' : 'Đăng ký chuyển khóa'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* SECTION B: REQUESTS TABLE (FOR ADMIN, STAFF, AND STUDENT)                 */}
      {/* ========================================================================= */}
      {((!isParent && activeSubTab === 'requests') || (isStudent && activeSubTab === 'requests')) && (
        <div className="space-y-4">
          {/* Filter and Search Bar (Only for Admin / Staff) */}
          {isStaffOrAdmin && (
            <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
              <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
                <Search className="w-4 h-4 text-slate-400 shrink-0" />
                <input
                  type="text"
                  placeholder="Tìm theo tên học viên, mã HV, mã lớp hoặc khóa học..."
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

              {/* Status Filter Chips (for Admin / Staff) */}
              <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 shrink-0">
                {[
                  { id: 'ALL', label: 'Tất cả' },
                  { id: 'PENDING', label: 'Chờ duyệt' },
                  { id: 'APPROVED', label: 'Đã duyệt' },
                  { id: 'REJECTED', label: 'Từ chối' },
                  { id: 'CANCELLED', label: 'Đã hủy' },
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

                <span className="text-[11px] font-bold text-slate-500 bg-slate-100 border border-slate-200/60 px-3 py-1.5 rounded-xl ml-1">
                  {filteredRequests.length} đơn
                </span>
              </div>
            </div>
          )}

          {/* Table */}
          <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
                  <tr>
                    <th className="p-4 pl-5">Mã đơn</th>
                    <th className="p-4">Học viên</th>
                    <th className="p-4">Lớp chuyển tới</th>
                    <th className="p-4">Ngày gửi đơn</th>
                    <th className="p-4 text-center">Trạng thái</th>
                    <th className="p-4">Ghi chú & Lý do</th>
                    <th className="p-4 pr-5 text-right">Thao tác</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {filteredRequests.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="p-12 text-center text-slate-400 font-medium">
                        <FileCheck2 className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                        Không tìm thấy yêu cầu chuyển khóa học nào.
                      </td>
                    </tr>
                  ) : (
                    filteredRequests.map((r) => (
                      <tr key={r.id} className="hover:bg-slate-50/70 transition-colors">
                        <td className="p-4 pl-5 font-mono font-bold text-slate-500">
                          #{r.id}
                        </td>

                        <td className="p-4">
                          <div className="flex items-center gap-2.5">
                            <UserAvatar name={r.student_name} role="STUDENT" size="xs" shape="rounded-lg" />
                            <div>
                              <div className="font-bold text-slate-900">{r.student_name}</div>
                              <div className="font-mono text-[10px] text-indigo-600 font-bold">{r.student_code}</div>
                            </div>
                          </div>
                        </td>

                        <td className="p-4">
                          <div className="font-mono font-bold text-indigo-700 bg-indigo-50 border border-indigo-200/60 px-2 py-0.5 rounded-lg inline-block text-[11px]">
                            {r.class_code}
                          </div>
                          <div className="text-[11px] text-slate-500 font-medium mt-0.5">{r.course_title}</div>
                        </td>

                        <td className="p-4 text-slate-500 tabular-nums font-medium">
                          {new Date(r.request_date).toLocaleDateString('vi-VN')}
                        </td>

                        <td className="p-4 text-center">
                          <span
                            className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full font-bold text-[10px] border ${
                              r.status === 'APPROVED'
                                ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                                : r.status === 'REJECTED'
                                ? 'bg-rose-50 text-rose-700 border-rose-200/80'
                                : r.status === 'CANCELLED'
                                ? 'bg-slate-100 text-slate-600 border-slate-200'
                                : 'bg-amber-50 text-amber-800 border-amber-200/80'
                            }`}
                          >
                            {r.status === 'APPROVED' ? (
                              <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                            ) : r.status === 'REJECTED' ? (
                              <XCircle className="w-3 h-3 text-rose-600" />
                            ) : r.status === 'CANCELLED' ? (
                              <Ban className="w-3 h-3 text-slate-400" />
                            ) : (
                              <Clock className="w-3 h-3 text-amber-600" />
                            )}
                            <span>
                              {r.status === 'APPROVED'
                                ? 'Đã duyệt'
                                : r.status === 'REJECTED'
                                ? 'Bị từ chối'
                                : r.status === 'CANCELLED'
                                ? 'Đã hủy'
                                : 'Chờ duyệt'}
                            </span>
                          </span>
                        </td>

                        <td className="p-4 text-slate-600 max-w-[200px]">
                          {r.rejection_reason ? (
                            <div className="text-rose-600 text-[11px] font-semibold bg-rose-50 border border-rose-100 p-2 rounded-xl">
                              Lý do: {r.rejection_reason}
                            </div>
                          ) : (
                            <span className="text-slate-500 text-[11px] font-medium">{r.note || '--'}</span>
                          )}
                        </td>

                        <td className="p-4 pr-5 text-right">
                          {isStaffOrAdmin && (
                            <div className="space-x-1.5 inline-flex items-center justify-end">
                              {r.status === 'PENDING' ? (
                                <>
                                  <button
                                    type="button"
                                    onClick={() => handleApprove(r.id)}
                                    className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl shadow-xs cursor-pointer active:scale-95 text-xs"
                                  >
                                    Duyệt chuyển khóa
                                  </button>
                                  <button
                                    type="button"
                                    onClick={() => setRejectingRequestId(r.id)}
                                    className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-bold rounded-xl cursor-pointer active:scale-95 text-xs"
                                  >
                                    Từ chối
                                  </button>
                                </>
                              ) : (
                                <span className="text-slate-400 font-medium text-xs">Đã xử lý</span>
                              )}
                            </div>
                          )}

                          {isStudent && (
                            <div className="flex justify-end">
                              {r.status === 'PENDING' ? (
                                <button
                                  type="button"
                                  onClick={() => handleCancelRequest(r.id)}
                                  className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 font-bold border border-rose-200 rounded-xl cursor-pointer transition text-xs shadow-2xs active:scale-95"
                                  title="Hủy đơn chuyển khóa này"
                                >
                                  <Trash2 className="w-3.5 h-3.5" />
                                  <span>Hủy yêu cầu</span>
                                </button>
                              ) : r.status === 'APPROVED' ? (
                                <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-1 rounded-xl">
                                  Đã vào lớp mới
                                </span>
                              ) : (
                                <span className="text-[11px] text-slate-400 font-medium">--</span>
                              )}
                            </div>
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
      {/* SECTION C: STAFF MANUAL ELIGIBILITY CHECKER                               */}
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
      {/* SECTION D: PARENT PORTAL                                                  */}
      {/* ========================================================================= */}
      {isParent && (
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
                      Lịch sử chuyển khóa & Ghi danh của con: {selectedWard.full_name}
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
                          Học viên chưa có yêu cầu chuyển khóa nào gần đây.
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
      )}

      {/* ========================================================================= */}
      {/* MODAL 1: XÁC NHẬN ĐĂNG KÝ CHUYỂN KHÓA HỌC VIÊN                           */}
      {/* ========================================================================= */}
      {selectedClassToRegister &&
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
                      Chuyển Khóa Học: {selectedClassToRegister.class_code}
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
                    <span className="text-slate-500">Chuẩn đầu ra:</span>
                    <span className="font-bold text-indigo-600">{selectedClassToRegister.target_level}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Giáo viên phụ trách:</span>
                    <span className="font-semibold text-slate-800">{selectedClassToRegister.teacher_name || 'Đang xếp'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-500">Sĩ số hiện tại:</span>
                    <span className="font-bold text-slate-800">
                      {selectedClassToRegister.current_enrolled}/{selectedClassToRegister.max_capacity}
                    </span>
                  </div>
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1.5">
                    Ghi chú / Nguyện vọng học viên:
                  </label>
                  <textarea
                    rows={3}
                    value={registerNote}
                    onChange={(e) => setRegisterNote(e.target.value)}
                    placeholder="Ví dụ: Em đã hoàn thành khóa tiên quyết và mong muốn chuyển sang lớp này vào ca tối..."
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
                    <span>Gửi yêu cầu chuyển</span>
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ========================================================================= */}
      {/* MODAL 2: TỪ CHỐI ĐƠN CHUYỂN KHÓA (ADMIN/HỌC VỤ)                           */}
      {/* ========================================================================= */}
      {rejectingRequestId &&
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
                      Từ Chối Đơn Chuyển Khóa #{rejectingRequestId}
                    </h3>
                    <span className="text-xs text-slate-400">Gửi thông báo lý do đến học viên</span>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => setRejectingRequestId(null)}
                  className="text-slate-400 hover:text-slate-600 p-1.5 rounded-xl hover:bg-slate-100 cursor-pointer transition"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <form onSubmit={handleReject} className="space-y-4 text-xs">
                <div>
                  <label className="font-bold text-slate-700 block mb-1.5">
                    Lý do từ chối: <span className="text-rose-500">*</span>
                  </label>
                  <textarea
                    rows={3}
                    required
                    value={rejectionReason}
                    onChange={(e) => setRejectionReason(e.target.value)}
                    placeholder="Ví dụ: Học viên chưa đạt chuẩn đầu ra khóa tiên quyết, hoặc lớp đã đủ sĩ số..."
                    className="w-full border border-slate-200 p-3 rounded-2xl bg-slate-50 focus:bg-white outline-hidden focus:border-rose-600 focus:ring-2 focus:ring-rose-100 transition resize-none font-medium text-xs"
                  />
                </div>

                <div className="flex items-center gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setRejectingRequestId(null)}
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
