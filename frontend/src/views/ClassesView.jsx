import React, { useEffect, useState, useMemo } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { useConfirm } from '../context/ConfirmDialogContext';
import { useHeaderSlot } from '../context/HeaderSlotContext';
import { classesApi, teachersApi, coursesApi } from '../services/api';
import { UserAvatar } from '../components/common/UserAvatar';
import {
  Users,
  Search,
  School,
  UserCheck,
  Plus,
  Edit2,
  Trash2,
  BookOpen,
  Calendar,
  Clock,
  Sparkles,
  CheckCircle2,
  X,
  Layers,
  ArrowRight,
  ArrowRightLeft,
  AlertCircle,
  CheckCircle,
  XCircle,
  FileText,
  Filter,
  Eye,
  Check
} from 'lucide-react';

export const ClassesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const confirm = useConfirm();
  const headerSlot = useHeaderSlot();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');
  const isTeacher = user?.role === 'TEACHER';

  const [classes, setClasses] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [courses, setCourses] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('');

  // Roster modal
  const [selectedClassRoster, setSelectedClassRoster] = useState(null);
  const [rosterStudents, setRosterStudents] = useState([]);

  // Add Class Modal
  const [showAddModal, setShowAddModal] = useState(false);
  const [newClass, setNewClass] = useState({
    class_code: '',
    course_id: '',
    teacher_id: '',
    max_capacity: 25,
    opening_date: new Date().toISOString().split('T')[0],
    start_date: new Date().toISOString().split('T')[0],
    end_date: '',
  });

  // Edit Class Modal
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingClass, setEditingClass] = useState(null);
  const [editForm, setEditForm] = useState({
    teacher_id: '',
    max_capacity: 25,
    opening_date: '',
    start_date: '',
    end_date: '',
    status: 'OPEN_FOR_ENROLLMENT',
  });

  // Transfer Class Modal (Requirement 3)
  const [showTransferModal, setShowTransferModal] = useState(false);
  const [transferSourceClass, setTransferSourceClass] = useState(null);
  const [transferTargets, setTransferTargets] = useState([]);
  const [loadingTransferTargets, setLoadingTransferTargets] = useState(false);
  const [selectedTargetId, setSelectedTargetId] = useState('');
  const [transferReason, setTransferReason] = useState('');
  const [transferSubmitting, setTransferSubmitting] = useState(false);

  // Transfer Management Workflow (Admin / Academic Staff / Student)
  const [activeTab, setActiveTab] = useState('CLASSES'); // 'CLASSES' | 'TRANSFERS'
  const [transferRequests, setTransferRequests] = useState([]);
  const [loadingTransfers, setLoadingTransfers] = useState(false);
  const [transferStatusFilter, setTransferStatusFilter] = useState('');
  const [transferSearchTerm, setTransferSearchTerm] = useState('');
  const [selectedTransferDetail, setSelectedTransferDetail] = useState(null);
  const [showTransferDetailModal, setShowTransferDetailModal] = useState(false);
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);
  const [myTransferRequests, setMyTransferRequests] = useState([]);

  const loadTransferRequests = async () => {
    if (!canManage) return;
    setLoadingTransfers(true);
    try {
      const res = await classesApi.listTransferRequests({
        status: transferStatusFilter || undefined,
        q: transferSearchTerm || undefined,
      });
      setTransferRequests(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách yêu cầu chuyển lớp: ' + e.message);
    } finally {
      setLoadingTransfers(false);
    }
  };

  const loadMyTransferRequests = async () => {
    if (user?.role !== 'STUDENT') return;
    try {
      const res = await classesApi.listTransferRequests({});
      setMyTransferRequests(res.data || []);
    } catch (e) {
      console.error(e);
    }
  };

  const pendingTransfersCount = useMemo(() => {
    return transferRequests.filter((r) => r.status === 'PENDING').length;
  }, [transferRequests]);

  const loadData = async () => {
    try {
      const [resCls, resTea, resCou] = await Promise.all([
        classesApi.list(isTeacher ? { my_classes: true, q: searchTerm, status: statusFilter || undefined } : searchTerm, statusFilter || undefined),
        teachersApi.list().catch(() => ({ data: [] })),
        coursesApi.list('', true).catch(() => ({ data: [] })),
      ]);
      setClasses(resCls.data || []);
      setTeachers(resTea.data || []);
      setCourses(resCou.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải dữ liệu lớp học: ' + e.message);
    }
  };

  useEffect(() => {
    loadData();
  }, [searchTerm, statusFilter]);

  useEffect(() => {
    if (canManage) {
      loadTransferRequests();
    }
  }, [canManage, activeTab, transferStatusFilter, transferSearchTerm]);

  useEffect(() => {
    if (user?.role === 'STUDENT') {
      loadMyTransferRequests();
    }
  }, [user]);

  // Helper: Tự động tính ngày kết thúc từ ngày bắt đầu và thời lượng khóa học (tuần)
  const calculateEndDate = (startDateStr, courseId) => {
    if (!startDateStr || !courseId) return '';
    const selectedCourse = courses.find((c) => String(c.id) === String(courseId));
    const weeks = selectedCourse?.duration_weeks || 12;
    const date = new Date(startDateStr);
    if (isNaN(date.getTime())) return '';
    date.setDate(date.getDate() + weeks * 7);
    return date.toISOString().split('T')[0];
  };

  const getCourseDurationWeeks = (courseId) => {
    if (!courseId) return null;
    const selectedCourse = courses.find((c) => String(c.id) === String(courseId));
    return selectedCourse?.duration_weeks || null;
  };

  const handleNewClassCourseChange = (courseId) => {
    const computedEnd = calculateEndDate(newClass.start_date, courseId);
    setNewClass((prev) => ({
      ...prev,
      course_id: courseId,
      end_date: computedEnd || prev.end_date,
    }));
  };

  const handleNewClassStartDateChange = (startDate) => {
    const computedEnd = calculateEndDate(startDate, newClass.course_id);
    setNewClass((prev) => ({
      ...prev,
      start_date: startDate,
      end_date: computedEnd,
    }));
  };

  const handleEditStartDateChange = (startDate) => {
    const courseId = editingClass?.course_id;
    const computedEnd = calculateEndDate(startDate, courseId);
    setEditForm((prev) => ({
      ...prev,
      start_date: startDate,
      end_date: computedEnd || prev.end_date,
    }));
  };

  const handleCreateClass = async (e) => {
    e.preventDefault();
    if (!newClass.class_code || !newClass.course_id) {
      toast.warning('Vui lòng nhập đầy đủ mã lớp và chọn khóa học.');
      return;
    }
    const today = new Date().toISOString().split('T')[0];
    const opening = newClass.opening_date || newClass.start_date;
    if (opening && opening < today) {
      toast.error('Thời gian mở lớp không hợp lệ. Thời gian mở lớp không được nằm trong quá khứ.');
      return;
    }
    if (newClass.start_date && opening && newClass.start_date < opening) {
      toast.error('Thời gian bắt đầu học thực tế không được trước thời gian mở lớp.');
      return;
    }
    try {
      await classesApi.create({
        class_code: newClass.class_code.trim().toUpperCase(),
        course_id: Number(newClass.course_id),
        teacher_id: newClass.teacher_id ? Number(newClass.teacher_id) : null,
        max_capacity: Number(newClass.max_capacity) || 25,
        opening_date: opening || null,
        start_date: newClass.start_date || null,
        end_date: newClass.end_date || null,
      });
      toast.success('Đã tạo lớp học mới thành công!');
      setShowAddModal(false);
      setNewClass({
        class_code: '',
        course_id: courses[0]?.id || '',
        teacher_id: '',
        max_capacity: 25,
        opening_date: new Date().toISOString().split('T')[0],
        start_date: new Date().toISOString().split('T')[0],
        end_date: '',
      });
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleOpenEdit = (cls) => {
    setEditingClass(cls);
    setEditForm({
      teacher_id: cls.teacher_id || '',
      max_capacity: cls.max_capacity,
      opening_date: cls.opening_date || cls.start_date || '',
      start_date: cls.start_date || '',
      end_date: cls.end_date || '',
      status: cls.status,
    });
    setShowEditModal(true);
  };

  const handleUpdateClass = async (e) => {
    e.preventDefault();
    const today = new Date().toISOString().split('T')[0];
    if (editForm.opening_date && editForm.opening_date < today) {
      toast.error('Thời gian mở lớp không hợp lệ. Thời gian mở lớp không được nằm trong quá khứ.');
      return;
    }
    if (editForm.start_date && editForm.opening_date && editForm.start_date < editForm.opening_date) {
      toast.error('Thời gian bắt đầu học thực tế không được trước thời gian mở lớp.');
      return;
    }
    try {
      await classesApi.update(editingClass.id, {
        teacher_id: editForm.teacher_id ? Number(editForm.teacher_id) : null,
        max_capacity: Number(editForm.max_capacity) || 25,
        opening_date: editForm.opening_date || null,
        start_date: editForm.start_date || null,
        end_date: editForm.end_date || null,
        status: editForm.status,
      });
      toast.success('Cập nhật lớp học thành công!');
      setShowEditModal(false);
      setEditingClass(null);
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleDeleteClass = async (id, code) => {
    const isConfirmed = await confirm({
      title: 'Xóa lớp học vĩnh viễn',
      message: `Bạn có chắc chắn muốn XÓA vĩnh viễn lớp học ${code}? Toàn bộ dữ liệu điểm và phân công liên quan sẽ bị ảnh hưởng.`,
      confirmText: 'Xác nhận xóa',
      cancelText: 'Hủy bỏ',
      type: 'danger',
    });
    if (!isConfirmed) return;
    try {
      await classesApi.delete(id);
      toast.success('Đã xóa lớp học thành công!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleAssignTeacher = async (classId, teacherId) => {
    try {
      await classesApi.assignTeacher(classId, teacherId === 0 ? null : teacherId);
      toast.success('Đã cập nhật phân công giáo viên thành công!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleUpdateStatus = async (classId, status) => {
    try {
      await classesApi.updateStatus(classId, status);
      toast.success('Đã cập nhật trạng thái lớp học!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleOpenRoster = async (cls) => {
    if (user?.role === 'STUDENT') {
      toast.warning('Học viên không có quyền xem danh sách học viên trong lớp học!');
      return;
    }
    try {
      const res = await classesApi.getRoster(cls.id);
      const studentList = res.data || [];

      // Giáo viên chỉ được xem danh sách học viên lớp học của mình
      if (user?.role === 'TEACHER') {
        const currentTeacher = teachers.find(t => t.user_id === user.id || t.email === user.email);
        const isMyClass = (currentTeacher && cls.teacher_id === currentTeacher.id) ||
                          cls.teacher_id === user.id ||
                          cls.teacher_name?.toLowerCase() === user.full_name?.toLowerCase();
        if (!isMyClass) {
          toast.warning(
            `Bạn không phải là giảng viên phụ trách lớp ${cls.class_code}. Giảng viên chỉ được xem danh sách học viên lớp học của mình!`
          );
          return;
        }
      }

      // Học viên không có quyền xem danh sách lớp học
      if (user?.role === 'STUDENT') {
        toast.warning('Học viên không có quyền xem danh sách học viên trong lớp học!');
        return;
      }

      setRosterStudents(studentList);
      setSelectedClassRoster({ id: cls.id, code: cls.class_code });
    } catch (e) {
      toast.error('Lỗi khi tải danh sách học viên: ' + e.message);
    }
  };

  const handleOpenTransfer = async (cls) => {
    setTransferSourceClass(cls);
    setSelectedTargetId('');
    setTransferReason('');
    setShowTransferModal(true);
    setLoadingTransferTargets(true);
    try {
      const res = await classesApi.getTransferTargets(cls.id);
      const targets = res.data || [];
      setTransferTargets(targets);
      const available = targets.filter((t) => !t.is_full && (t.max_capacity - (t.current_enrolled || 0)) > 0);
      if (available.length > 0) {
        setSelectedTargetId(String(available[0].id));
      } else {
        setSelectedTargetId('');
      }
    } catch (e) {
      toast.error('Không thể tải danh sách lớp học đích: ' + e.message);
      setTransferTargets([]);
    } finally {
      setLoadingTransferTargets(false);
    }
  };

  const handleExecuteTransfer = async (e) => {
    e.preventDefault();
    if (!transferSourceClass || !selectedTargetId) {
      toast.warning('Vui lòng chọn lớp học đích để chuyển.');
      return;
    }
    setTransferSubmitting(true);
    try {
      await classesApi.createTransferRequest({
        current_class_id: transferSourceClass.id,
        target_class_id: Number(selectedTargetId),
        reason: transferReason.trim() || undefined,
      });
      toast.success('Gửi yêu cầu chuyển lớp thành công! Yêu cầu đang ở trạng thái chờ Phòng Học vụ/Admin phê duyệt.');
      setShowTransferModal(false);
      setTransferSourceClass(null);
      loadData();
      if (user?.role === 'STUDENT') {
        loadMyTransferRequests();
      }
    } catch (e) {
      toast.error(e.message || 'Lỗi khi gửi yêu cầu chuyển lớp');
    } finally {
      setTransferSubmitting(false);
    }
  };

  const handleViewTransferDetail = async (reqId) => {
    try {
      const res = await classesApi.getTransferRequest(reqId);
      setSelectedTransferDetail(res.data);
      setShowTransferDetailModal(true);
    } catch (e) {
      toast.error('Không thể tải chi tiết yêu cầu chuyển lớp: ' + e.message);
    }
  };

  const handleApproveTransfer = async (reqId) => {
    const ok = await confirm({
      title: 'Xác nhận phê duyệt chuyển lớp',
      message: 'Học viên sẽ được chuyển chính thức sang lớp học mới và bảng điểm được đồng bộ bảo toàn. Bạn có chắc chắn muốn phê duyệt?',
      confirmText: 'Phê duyệt',
      cancelText: 'Hủy'
    });
    if (!ok) return;

    setActionLoading(true);
    try {
      await classesApi.approveTransferRequest(reqId);
      toast.success('Phê duyệt chuyển lớp thành công! Học viên đã được chuyển lớp.');
      setShowTransferDetailModal(false);
      loadTransferRequests();
      loadData();
    } catch (e) {
      toast.error(e.message || 'Lỗi khi phê duyệt chuyển lớp');
    } finally {
      setActionLoading(false);
    }
  };

  const handleOpenRejectModal = (detail) => {
    setSelectedTransferDetail(detail);
    setRejectReason('');
    setShowRejectModal(true);
  };

  const handleConfirmReject = async (e) => {
    e.preventDefault();
    if (!rejectReason.trim()) {
      toast.warning('Vui lòng nhập lý do từ chối.');
      return;
    }
    setActionLoading(true);
    try {
      await classesApi.rejectTransferRequest(selectedTransferDetail.id, {
        reason: rejectReason.trim(),
      });
      toast.success('Đã từ chối yêu cầu chuyển lớp.');
      setShowRejectModal(false);
      setShowTransferDetailModal(false);
      loadTransferRequests();
    } catch (e) {
      toast.error(e.message || 'Lỗi khi từ chối yêu cầu chuyển lớp');
    } finally {
      setActionLoading(false);
    }
  };

  // KPI Calculations
  const stats = useMemo(() => {
    const total = classes.length;
    const openEnroll = classes.filter((c) => c.status === 'OPEN_FOR_ENROLLMENT').length;
    const inProgress = classes.filter((c) => c.status === 'IN_PROGRESS').length;
    const totalStudents = classes.reduce((acc, c) => acc + (c.current_enrolled || 0), 0);
    return { total, openEnroll, inProgress, totalStudents };
  }, [classes]);

  const getStatusBadge = (status) => {
    switch (status) {
      case 'PLANNING':
        return { label: 'Lập kế hoạch', bg: 'bg-amber-50 text-amber-700 border-amber-200/80', dot: 'bg-amber-500' };
      case 'OPEN_FOR_ENROLLMENT':
        return { label: 'Đang mở đăng ký', bg: 'bg-emerald-50 text-emerald-700 border-emerald-200/80', dot: 'bg-emerald-500' };
      case 'IN_PROGRESS':
        return { label: 'Đang diễn ra', bg: 'bg-sky-50 text-sky-700 border-sky-200/80', dot: 'bg-sky-500' };
      case 'COMPLETED':
        return { label: 'Đã hoàn thành', bg: 'bg-purple-50 text-purple-700 border-purple-200/80', dot: 'bg-purple-500' };
      case 'CANCELLED':
        return { label: 'Đã hủy', bg: 'bg-rose-50 text-rose-700 border-rose-200/80', dot: 'bg-rose-500' };
      default:
        return { label: status, bg: 'bg-slate-100 text-slate-700 border-slate-200', dot: 'bg-slate-400' };
    }
  };

  return (
    <div className="space-y-6">
      
      {/* Top Header Action Button */}
      {headerSlot && canManage && createPortal(
        <button
          type="button"
          onClick={() => {
            if (courses.length > 0) {
              setNewClass((prev) => ({ ...prev, course_id: courses[0].id }));
            }
            setShowAddModal(true);
          }}
          className="flex items-center gap-1.5 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 active:scale-95 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-indigo-200 transition cursor-pointer shrink-0"
        >
          <Plus className="w-4 h-4" />
          <span>Thêm lớp học mới</span>
        </button>,
        headerSlot
      )}

      {/* Top Header Action Button for Student: Đăng ký lớp học */}
      {headerSlot && user?.role === 'STUDENT' && createPortal(
        <button
          type="button"
          onClick={() => {
            const url = new URL(window.location.href);
            url.searchParams.set('tab', 'enrollments');
            window.history.pushState({ tab: 'enrollments' }, '', url.toString());
            window.dispatchEvent(new PopStateEvent('popstate'));
          }}
          className="flex items-center gap-1.5 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 active:scale-95 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-indigo-200 transition cursor-pointer shrink-0"
        >
          <UserCheck className="w-4 h-4" />
          <span>Đăng ký lớp học</span>
        </button>,
        headerSlot
      )}

      {/* Management View Switcher Tabs (Admin & Academic Staff) */}
      {canManage && (
        <div className="flex items-center gap-2 border-b border-slate-200/90 pb-3">
          <button
            type="button"
            onClick={() => setActiveTab('CLASSES')}
            className={`flex items-center gap-2 px-4 py-2 rounded-2xl text-xs font-bold transition-all cursor-pointer ${
              activeTab === 'CLASSES'
                ? 'bg-indigo-600 text-white shadow-xs shadow-indigo-200'
                : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200/80'
            }`}
          >
            <School className="w-4 h-4" />
            <span>Quản lý danh sách lớp học</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('TRANSFERS')}
            className={`flex items-center gap-2 px-4 py-2 rounded-2xl text-xs font-bold transition-all cursor-pointer ${
              activeTab === 'TRANSFERS'
                ? 'bg-indigo-600 text-white shadow-xs shadow-indigo-200'
                : 'bg-white text-slate-600 hover:bg-slate-100 border border-slate-200/80'
            }`}
          >
            <ArrowRightLeft className="w-4 h-4" />
            <span>Yêu cầu chuyển lớp</span>
            {pendingTransfersCount > 0 && (
              <span className="px-2 py-0.5 rounded-full text-[10px] font-black bg-rose-500 text-white animate-pulse">
                {pendingTransfersCount}
              </span>
            )}
          </button>
        </div>
      )}

      {/* Student: My Transfer Requests Section */}
      {user?.role === 'STUDENT' && myTransferRequests.length > 0 && (
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <ArrowRightLeft className="w-4 h-4 text-indigo-600" />
              <h3 className="font-bold text-sm text-slate-800">Yêu cầu chuyển lớp của bạn</h3>
            </div>
            <span className="text-[11px] font-semibold text-slate-400">
              {myTransferRequests.length} yêu cầu
            </span>
          </div>

          <div className="grid gap-2.5">
            {myTransferRequests.map((req) => (
              <div
                key={req.id}
                className="p-3.5 rounded-2xl bg-slate-50/80 border border-slate-200/80 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-slate-900 font-mono bg-white px-2 py-0.5 rounded border border-slate-200">
                      {req.source_class_code}
                    </span>
                    <ArrowRight className="w-3.5 h-3.5 text-slate-400" />
                    <span className="font-bold text-indigo-700 font-mono bg-indigo-50 px-2 py-0.5 rounded border border-indigo-100">
                      {req.target_class_code}
                    </span>
                    <span className="text-[11px] text-slate-500">
                      ({req.target_course_title})
                    </span>
                  </div>
                  {req.reason && (
                    <div className="text-slate-600 text-[11px]">
                      Lý do: <span className="font-medium text-slate-800">{req.reason}</span>
                    </div>
                  )}
                  {req.status === 'REJECTED' && req.rejection_reason && (
                    <div className="text-rose-700 bg-rose-50 border border-rose-100 p-2 rounded-xl text-[11px] font-medium">
                      Lý do từ chối: <strong>{req.rejection_reason}</strong>
                    </div>
                  )}
                </div>

                <div className="flex items-center gap-2 self-start sm:self-auto">
                  {req.status === 'PENDING' && (
                    <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200 flex items-center gap-1">
                      <Clock className="w-3 h-3" /> Chờ phê duyệt
                    </span>
                  )}
                  {req.status === 'APPROVED' && (
                    <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1">
                      <CheckCircle2 className="w-3 h-3" /> Đã phê duyệt
                    </span>
                  )}
                  {req.status === 'REJECTED' && (
                    <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200 flex items-center gap-1">
                      <X className="w-3 h-3" /> Bị từ chối
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Main Classes Tab */}
      {activeTab === 'CLASSES' && (
        <>
      {/* KPI Metric Overview */}
      {user?.role !== 'STUDENT' && (
        <div className={`grid gap-3.5 sm:gap-4 ${isTeacher ? 'grid-cols-1 sm:grid-cols-2' : 'grid-cols-2 lg:grid-cols-4'}`}>
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
              {isTeacher ? 'Lớp bạn phụ trách' : 'Tổng số lớp'}
            </span>
            <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <School className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">
            {isTeacher ? 'Phân công giảng dạy' : 'Toàn bộ chi nhánh'}
          </div>
        </div>

        {!isTeacher && (
          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-emerald-200 hover:-translate-y-0.5 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đang mở tuyển sinh</span>
              <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <UserCheck className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-emerald-600 tabular-nums">{stats.openEnroll}</div>
            <div className="text-[11px] text-emerald-700/80 mt-1 font-medium">Sẵn sàng nhận hồ sơ</div>
          </div>
        )}

        {!isTeacher && (
          <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-sky-200 hover:-translate-y-0.5 transition-all">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đang diễn ra</span>
              <div className="w-8 h-8 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center">
                <BookOpen className="w-4 h-4" />
              </div>
            </div>
            <div className="text-2xl font-black text-sky-600 tabular-nums">{stats.inProgress}</div>
            <div className="text-[11px] text-sky-700/80 mt-1 font-medium">Lớp đang vận hành</div>
          </div>
        )}

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-purple-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
              {isTeacher ? 'Tổng học viên đang dạy' : 'Tổng học viên'}
            </span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
              <Users className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-purple-600 tabular-nums">{stats.totalStudents}</div>
          <div className="text-[11px] text-purple-700/80 mt-1 font-medium">
            {isTeacher ? 'Số lượng học viên các lớp phụ trách' : 'Học viên đang theo học'}
          </div>
        </div>
      </div>
      )}

      {/* Filter and Search Bar */}
      <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
        
        {/* Search Bar */}
        <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
          <Search className="w-4 h-4 text-slate-400 shrink-0" />
          <input
            type="text"
            placeholder="Tìm theo mã lớp (IELTS-65, TOEIC-750) hoặc khóa học..."
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

        {/* Status Filter Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 shrink-0">
          {(user?.role === 'STUDENT'
            ? [
                { id: '', label: 'Tất cả' },
                { id: 'IN_PROGRESS', label: 'Đang học' },
                { id: 'COMPLETED', label: 'Đã xong' },
              ]
            : isTeacher
            ? [
                { id: '', label: 'Tất cả lớp' },
                { id: 'IN_PROGRESS', label: 'Đang dạy' },
                { id: 'COMPLETED', label: 'Đã xong' },
              ]
            : [
                { id: '', label: 'Tất cả' },
                { id: 'OPEN_FOR_ENROLLMENT', label: 'Đang mở' },
                { id: 'IN_PROGRESS', label: 'Đang diễn ra' },
                { id: 'COMPLETED', label: 'Đã xong' },
              ]
          ).map((st) => {
            const isSelected = statusFilter === st.id;
            return (
              <button
                key={st.id}
                type="button"
                onClick={() => setStatusFilter(st.id)}
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

      {/* Classes Table */}
      <div className="bg-white rounded-3xl border border-slate-200/90 overflow-hidden shadow-2xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
              <tr>
                <th className="p-4 pl-5">Mã lớp</th>
                <th className="p-4">Khóa học & Cấp độ</th>
                <th className="p-4">Tình trạng Sĩ số</th>
                <th className="p-4">Giảng viên phụ trách</th>
                <th className="p-4 text-center">Trạng thái lớp</th>
                <th className="p-4 pr-5 text-right">{canManage ? 'Thao tác' : 'Trạng thái'}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {classes.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center text-slate-400 font-medium">
                    <School className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                    {user?.role === 'STUDENT' && !statusFilter && !searchTerm
                      ? 'Bạn hiện chưa được ghi danh vào lớp học nào.'
                      : user?.role === 'TEACHER' && !statusFilter && !searchTerm
                      ? 'Bạn hiện chưa được phân công phụ trách lớp học nào.'
                      : 'Không tìm thấy lớp học nào phù hợp.'}
                  </td>
                </tr>
              ) : (
                classes.map((cls) => {
                  const percentage = Math.min(
                    100,
                    Math.round((cls.current_enrolled / cls.max_capacity) * 100)
                  );
                  const sBadge = getStatusBadge(cls.status);

                  return (
                    <tr key={cls.id} className="hover:bg-slate-50/70 transition-colors">
                      {/* Class Code */}
                      <td className="p-4 pl-5">
                        <span className="font-mono font-black text-indigo-700 bg-indigo-50 border border-indigo-200/70 px-2.5 py-1 rounded-xl shadow-2xs text-xs">
                          {cls.class_code}
                        </span>
                        <div className="text-[10px] text-slate-500 mt-1 flex items-center gap-1">
                          <Calendar className="w-3 h-3 text-slate-400" />
                          <span>Mở: {cls.opening_date || cls.start_date || '--'}</span>
                        </div>
                        <div className="text-[10px] text-slate-400">
                          Học: {cls.start_date || '--'} → {cls.end_date || '--'}
                        </div>
                      </td>

                      {/* Course */}
                      <td className="p-4">
                        <div className="font-bold text-slate-900 text-xs">{cls.course_title}</div>
                        <span className="inline-block text-[10px] bg-indigo-50 text-indigo-700 font-bold px-2 py-0.5 rounded-md mt-0.5 border border-indigo-100/60">
                          {cls.target_level}
                        </span>
                      </td>

                      {/* Capacity Bar */}
                      <td className="p-4 min-w-[200px]">
                        <div className="flex items-center justify-between text-xs font-bold text-slate-700 mb-1.5 tabular-nums">
                          <span>
                            {cls.current_enrolled} / {cls.max_capacity} học viên
                          </span>
                          {cls.is_full ? (
                            <span className="text-[10px] font-bold text-rose-700 bg-rose-50 border border-rose-200 px-2 py-0.5 rounded-full">
                              Đã đủ chỗ
                            </span>
                          ) : (
                            <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2 py-0.5 rounded-full">
                              Còn {cls.max_capacity - cls.current_enrolled} chỗ
                            </span>
                          )}
                        </div>
                        <div className="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                          <div
                            className={`h-full rounded-full transition-all duration-300 ${
                              percentage >= 100
                                ? 'bg-rose-500'
                                : percentage >= 80
                                ? 'bg-amber-500'
                                : 'bg-gradient-to-r from-indigo-500 to-indigo-600'
                            }`}
                            style={{ width: `${percentage}%` }}
                          />
                        </div>
                      </td>

                      {/* Teacher */}
                      <td className="p-4">
                        {canManage ? (
                          <select
                            value={cls.teacher_id || 0}
                            onChange={(e) => handleAssignTeacher(cls.id, Number(e.target.value))}
                            className="border border-slate-200 rounded-xl px-2.5 py-1.5 text-xs text-slate-800 bg-white font-medium outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs max-w-[200px]"
                          >
                            <option value={0}>-- Chưa phân công --</option>
                            {teachers.map((t) => (
                              <option key={t.id} value={t.id}>
                                {t.full_name} ({t.specialty})
                              </option>
                            ))}
                          </select>
                        ) : (
                          <div className="flex items-center gap-2 font-bold text-slate-700">
                            <UserAvatar name={cls.teacher_name} role="TEACHER" size="xs" shape="rounded-lg" />
                            <span>{cls.teacher_name || 'Chưa phân công'}</span>
                          </div>
                        )}
                      </td>

                      {/* Status */}
                      <td className="p-4 text-center">
                        {canManage ? (
                          <select
                            value={cls.status}
                            onChange={(e) => handleUpdateStatus(cls.id, e.target.value)}
                            className="border border-slate-200 rounded-xl px-2.5 py-1.5 text-xs text-slate-800 bg-white font-bold outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
                          >
                            <option value="OPEN_FOR_ENROLLMENT">Đang mở đăng ký</option>
                            <option value="IN_PROGRESS">Đang diễn ra</option>
                            <option value="COMPLETED">Đã hoàn thành</option>
                            <option value="CANCELLED">Đã hủy</option>
                          </select>
                        ) : (
                          <span className={`inline-flex items-center gap-1.5 text-[11px] font-bold px-2.5 py-1 rounded-full border ${sBadge.bg}`}>
                            <span className={`w-1.5 h-1.5 rounded-full ${sBadge.dot}`} />
                            {sBadge.label}
                          </span>
                        )}
                      </td>

                      {/* Actions */}
                      <td className="p-4 pr-5 text-right">
                        {canManage ? (
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              type="button"
                              onClick={() => handleOpenEdit(cls)}
                              className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer"
                              title="Sửa thông tin lớp học"
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </button>
                            <button
                              type="button"
                              onClick={() => handleDeleteClass(cls.id, cls.class_code)}
                              className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition cursor-pointer"
                              title="Xóa lớp học"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        ) : user?.role === 'STUDENT' ? (
                          <div className="flex items-center justify-end gap-2">
                            <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-1.5 rounded-xl border border-emerald-200">
                              <CheckCircle2 className="w-3.5 h-3.5" />
                              Đang theo học
                            </span>
                            {['OPEN_FOR_ENROLLMENT', 'IN_PROGRESS'].includes(cls.status) && (
                              <button
                                type="button"
                                onClick={() => handleOpenTransfer(cls)}
                                className="inline-flex items-center gap-1.5 text-xs font-bold text-indigo-700 bg-indigo-50 hover:bg-indigo-100 hover:border-indigo-300 px-3 py-1.5 rounded-xl border border-indigo-200 transition cursor-pointer shadow-2xs active:scale-95"
                                title="Chuyển sang lớp học khác"
                              >
                                <ArrowRightLeft className="w-3.5 h-3.5" />
                                <span>Chuyển lớp</span>
                              </button>
                            )}
                          </div>
                        ) : user?.role === 'TEACHER' ? (
                          <button
                            type="button"
                            onClick={() => handleOpenRoster(cls)}
                            className="inline-flex items-center gap-1.5 text-xs font-bold text-indigo-700 bg-indigo-50 hover:bg-indigo-100 hover:border-indigo-300 px-3 py-1.5 rounded-xl border border-indigo-200 transition cursor-pointer shadow-2xs"
                            title="Xem danh sách học viên lớp học"
                          >
                            <Users className="w-3.5 h-3.5" />
                            Xem học viên
                          </button>
                        ) : (
                          <span className="text-slate-400 text-xs">-</span>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
      </>
      )}

      {/* ================= SECTION: QUẢN LÝ YÊU CẦU CHUYỂN LỚP (ADMIN / ACADEMIC_STAFF) ================= */}
      {canManage && activeTab === 'TRANSFERS' && (
        <div className="space-y-4">
          {/* Transfer Requests Filter Bar */}
          <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
            <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
              <Search className="w-4 h-4 text-slate-400 shrink-0" />
              <input
                type="text"
                placeholder="Tìm theo mã học viên, tên học viên, mã lớp nguồn/đích..."
                value={transferSearchTerm}
                onChange={(e) => setTransferSearchTerm(e.target.value)}
                className="w-full text-xs outline-hidden text-slate-800 placeholder:text-slate-400 bg-transparent font-medium"
              />
              {transferSearchTerm && (
                <button
                  type="button"
                  onClick={() => setTransferSearchTerm('')}
                  className="text-slate-400 hover:text-slate-600 cursor-pointer p-0.5"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              )}
            </div>

            <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 shrink-0">
              {[
                { id: '', label: 'Tất cả' },
                { id: 'PENDING', label: 'Chờ phê duyệt' },
                { id: 'APPROVED', label: 'Đã phê duyệt' },
                { id: 'REJECTED', label: 'Đã từ chối' },
              ].map((st) => {
                const isSelected = transferStatusFilter === st.id;
                return (
                  <button
                    key={st.id}
                    type="button"
                    onClick={() => setTransferStatusFilter(st.id)}
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

          {/* Transfer Requests Table */}
          <div className="bg-white rounded-3xl border border-slate-200/90 overflow-hidden shadow-2xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
                  <tr>
                    <th className="py-3 px-4">Mã đơn</th>
                    <th className="py-3 px-4">Học viên</th>
                    <th className="py-3 px-4">Lớp hiện tại</th>
                    <th className="py-3 px-4">Lớp muốn chuyển</th>
                    <th className="py-3 px-4">Cấp độ</th>
                    <th className="py-3 px-4">Ngày gửi</th>
                    <th className="py-3 px-4">Trạng thái</th>
                    <th className="py-3 px-4 text-right">Thao tác</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-slate-700 font-medium">
                  {loadingTransfers ? (
                    <tr>
                      <td colSpan={8} className="py-12 text-center text-slate-400">
                        Đang tải danh sách yêu cầu chuyển lớp...
                      </td>
                    </tr>
                  ) : transferRequests.length === 0 ? (
                    <tr>
                      <td colSpan={8} className="py-12 text-center text-slate-400">
                        Không có yêu cầu chuyển lớp nào phù hợp.
                      </td>
                    </tr>
                  ) : (
                    transferRequests.map((req) => (
                      <tr key={req.id} className="hover:bg-slate-50/60 transition">
                        <td className="py-3 px-4 font-mono font-bold text-slate-900">
                          #{req.id}
                        </td>
                        <td className="py-3 px-4">
                          <div className="font-bold text-slate-900">{req.student_name}</div>
                          <div className="text-[11px] font-mono text-slate-400">{req.student_code}</div>
                        </td>
                        <td className="py-3 px-4">
                          <span className="font-mono font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded">
                            {req.source_class_code}
                          </span>
                          <div className="text-[11px] text-slate-500 mt-0.5">{req.source_course_title}</div>
                        </td>
                        <td className="py-3 px-4">
                          <span className="font-mono font-bold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded border border-indigo-100">
                            {req.target_class_code}
                          </span>
                          <div className="text-[11px] text-slate-500 mt-0.5">{req.target_course_title}</div>
                        </td>
                        <td className="py-3 px-4">
                          {req.level_relation === 'SAME_LEVEL' && (
                            <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-indigo-50 text-indigo-700 border border-indigo-100">
                              Cùng cấp độ
                            </span>
                          )}
                          {req.level_relation === 'HIGHER_LEVEL' && (
                            <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-purple-50 text-purple-700 border border-purple-100">
                              Lên cấp độ
                            </span>
                          )}
                          {req.level_relation === 'LOWER_LEVEL' && (
                            <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-100">
                              Xuống cấp độ
                            </span>
                          )}
                          {req.level_relation === 'UNKNOWN_LEVEL' && (
                            <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600">
                              Chưa xác định
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-4 text-slate-500 text-[11px]">
                          {new Date(req.request_date).toLocaleString('vi-VN', {
                            day: '2-digit', month: '2-digit', year: 'numeric',
                            hour: '2-digit', minute: '2-digit'
                          })}
                        </td>
                        <td className="py-3 px-4">
                          {req.status === 'PENDING' && (
                            <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                              Chờ phê duyệt
                            </span>
                          )}
                          {req.status === 'APPROVED' && (
                            <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                              Đã phê duyệt
                            </span>
                          )}
                          {req.status === 'REJECTED' && (
                            <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                              Đã từ chối
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-4 text-right">
                          <button
                            type="button"
                            onClick={() => handleViewTransferDetail(req.id)}
                            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold bg-indigo-50 text-indigo-700 hover:bg-indigo-100 border border-indigo-200 transition cursor-pointer"
                          >
                            <Eye className="w-3.5 h-3.5" />
                            <span>Thẩm định & Chi tiết</span>
                          </button>
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

      {/* ================= MODAL: THÊM LỚP HỌC MỚI ================= */}
      {showAddModal && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Plus className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">Thêm Lớp Học Mới</h3>
                  <span className="text-xs text-slate-400">Khởi tạo lớp và liên kết chương trình đào tạo</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setShowAddModal(false)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateClass} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mã lớp học (Class Code):</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: IELTS-65-02, TOEIC-750-K2..."
                  value={newClass.class_code}
                  onChange={(e) => setNewClass({ ...newClass, class_code: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-mono font-bold outline-hidden focus:border-indigo-600 uppercase"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Khóa học đào tạo:</label>
                <select
                  required
                  value={newClass.course_id}
                  onChange={(e) => handleNewClassCourseChange(e.target.value)}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600"
                >
                  <option value="">-- Chọn khóa học --</option>
                  {courses.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.code} - {c.title} ({c.duration_weeks ? `${c.duration_weeks} tuần` : c.target_level})
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giảng viên phụ trách:</label>
                  <select
                    value={newClass.teacher_id}
                    onChange={(e) => setNewClass({ ...newClass, teacher_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    <option value="">-- Chưa phân công --</option>
                    {teachers.map((t) => (
                      <option key={t.id} value={t.id}>
                        {t.full_name} ({t.specialty})
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa tối đa (HV):</label>
                  <input
                    type="number"
                    min="1"
                    max="100"
                    required
                    value={newClass.max_capacity}
                    onChange={(e) => setNewClass({ ...newClass, max_capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-bold outline-hidden focus:border-indigo-600 tabular-nums"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Thời gian mở lớp:</label>
                  <input
                    type="date"
                    required
                    min={new Date().toISOString().split('T')[0]}
                    value={newClass.opening_date}
                    onChange={(e) => setNewClass({ ...newClass, opening_date: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                  <span className="text-[10px] text-slate-400 block mt-0.5">≥ Hôm nay (OpeningTime)</span>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Ngày bắt đầu học:</label>
                  <input
                    type="date"
                    required
                    min={newClass.opening_date || new Date().toISOString().split('T')[0]}
                    value={newClass.start_date}
                    onChange={(e) => handleNewClassStartDateChange(e.target.value)}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                  <span className="text-[10px] text-slate-400 block mt-0.5">Bắt đầu học thực tế</span>
                </div>
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="font-bold text-slate-700">Ngày kết thúc:</label>
                    {getCourseDurationWeeks(newClass.course_id) && (
                      <span className="text-[10px] font-semibold text-indigo-700 bg-indigo-50 border border-indigo-200 px-1 py-0.5 rounded-md">
                        +{getCourseDurationWeeks(newClass.course_id)} tuần
                      </span>
                    )}
                  </div>
                  <input
                    type="date"
                    value={newClass.end_date}
                    readOnly
                    title="Ngày kết thúc được tự động tính dựa theo số tuần của khóa học"
                    className="w-full border border-slate-200 bg-slate-50/80 p-2.5 rounded-xl font-medium text-slate-600 cursor-not-allowed outline-hidden"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer"
                >
                  Tạo Lớp Học
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: SỬA LỚP HỌC ================= */}
      {showEditModal && editingClass && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Edit2 className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">
                    Cập nhật Lớp: {editingClass.class_code}
                  </h3>
                  <span className="text-xs text-slate-400 font-medium">{editingClass.course_title}</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => {
                  setShowEditModal(false);
                  setEditingClass(null);
                }}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleUpdateClass} className="space-y-3.5 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giảng viên phụ trách:</label>
                  <select
                    value={editForm.teacher_id}
                    onChange={(e) => setEditForm({ ...editForm, teacher_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    <option value="">-- Chưa phân công --</option>
                    {teachers.map((t) => (
                      <option key={t.id} value={t.id}>
                        {t.full_name} ({t.specialty})
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa tối đa (HV):</label>
                  <input
                    type="number"
                    min="1"
                    max="100"
                    required
                    value={editForm.max_capacity}
                    onChange={(e) => setEditForm({ ...editForm, max_capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-bold outline-hidden focus:border-indigo-600 tabular-nums"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Trạng thái lớp học:</label>
                <select
                  value={editForm.status}
                  onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600"
                >
                  <option value="PLANNING">Lập kế hoạch (PLANNING)</option>
                  <option value="OPEN_FOR_ENROLLMENT">Đang mở đăng ký (OPEN_FOR_ENROLLMENT)</option>
                  <option value="IN_PROGRESS">Đang diễn ra (IN_PROGRESS)</option>
                  <option value="COMPLETED">Đã hoàn thành (COMPLETED)</option>
                  <option value="CANCELLED">Đã hủy (CANCELLED)</option>
                </select>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Thời gian mở lớp:</label>
                  <input
                    type="date"
                    min={new Date().toISOString().split('T')[0]}
                    value={editForm.opening_date}
                    onChange={(e) => setEditForm({ ...editForm, opening_date: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                  <span className="text-[10px] text-slate-400 block mt-0.5">≥ Hôm nay</span>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Ngày bắt đầu học:</label>
                  <input
                    type="date"
                    min={editForm.opening_date || new Date().toISOString().split('T')[0]}
                    value={editForm.start_date}
                    onChange={(e) => handleEditStartDateChange(e.target.value)}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                  <span className="text-[10px] text-slate-400 block mt-0.5">Bắt đầu học thực tế</span>
                </div>
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="font-bold text-slate-700">Ngày kết thúc:</label>
                    {getCourseDurationWeeks(editingClass?.course_id) && (
                      <span className="text-[10px] font-semibold text-indigo-700 bg-indigo-50 border border-indigo-200 px-1 py-0.5 rounded-md">
                        +{getCourseDurationWeeks(editingClass?.course_id)} tuần
                      </span>
                    )}
                  </div>
                  <input
                    type="date"
                    value={editForm.end_date}
                    onChange={(e) => setEditForm({ ...editForm, end_date: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => {
                    setShowEditModal(false);
                    setEditingClass(null);
                  }}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer"
                >
                  Lưu Thay Đổi
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: DANH SÁCH LỚP (ROSTER) ================= */}
      {selectedClassRoster && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 text-indigo-600 flex items-center justify-center font-bold">
                  <Users className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900 leading-tight">
                    Danh Sách Học Viên &bull; {selectedClassRoster.code}
                  </h3>
                  <span className="text-xs text-slate-400 font-medium">Hồ sơ học viên đã được phê duyệt ghi danh</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setSelectedClassRoster(null)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer transition"
              >
                ✕
              </button>
            </div>

            <div className="mt-4 max-h-80 overflow-y-auto pr-1">
              {rosterStudents.length === 0 ? (
                <div className="py-12 text-center text-slate-400">
                  <Users className="w-8 h-8 mx-auto mb-2 opacity-40 text-slate-400" />
                  <p className="text-xs font-medium">Lớp học này hiện chưa có học viên nào tham gia.</p>
                </div>
              ) : (
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 text-slate-500 font-bold border-b border-slate-100 text-[11px] uppercase tracking-wider">
                    <tr>
                      <th className="p-3">Học viên</th>
                      <th className="p-3">Mã HV</th>
                      <th className="p-3">Email liên hệ</th>
                      <th className="p-3 text-right">Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {rosterStudents.map((st, i) => (
                      <tr key={i} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-3">
                          <div className="flex items-center gap-2.5">
                            <UserAvatar name={st.full_name} role="STUDENT" size="xs" shape="rounded-lg" />
                            <span className="font-bold text-slate-900">{st.full_name}</span>
                          </div>
                        </td>
                        <td className="p-3 font-mono font-bold text-indigo-700">{st.student_code}</td>
                        <td className="p-3 text-slate-500 font-medium">{st.email}</td>
                        <td className="p-3 text-right">
                          <span className="text-[10px] bg-emerald-50 text-emerald-700 border border-emerald-200/80 px-2.5 py-0.5 rounded-full font-bold">
                            {st.status || 'ACTIVE'}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>

            <div className="mt-5 pt-3 border-t border-slate-100 flex justify-end">
              <button
                type="button"
                onClick={() => setSelectedClassRoster(null)}
                className="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-bold text-xs cursor-pointer transition active:scale-95"
              >
                Đóng Cửa Sổ
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: TẠO YÊU CẦU CHUYỂN LỚP (STUDENT) ================= */}
      {showTransferModal && transferSourceClass && createPortal(
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
                  <ArrowRightLeft className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-extrabold text-base text-slate-900">Tạo yêu cầu chuyển lớp</h3>
                  <p className="text-xs text-slate-500 font-medium mt-0.5">
                    Lớp hiện tại: <span className="font-mono font-bold text-indigo-700">{transferSourceClass.class_code}</span>
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setShowTransferModal(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-xl hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleExecuteTransfer} className="mt-5 space-y-4">
              {/* Current Class Summary Card */}
              <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-200/80 text-xs space-y-1.5">
                <div className="font-bold text-slate-800 flex items-center justify-between">
                  <span>Thông tin lớp hiện tại</span>
                  <span className="font-mono text-indigo-600 bg-indigo-50 border border-indigo-100 px-2 py-0.5 rounded-lg">
                    {transferSourceClass.class_code}
                  </span>
                </div>
                <div className="text-slate-600">Khóa: <span className="font-semibold text-slate-800">{transferSourceClass.course_title}</span></div>
                <div className="text-slate-600">Giảng viên: <span className="font-semibold text-slate-800">{transferSourceClass.teacher_name || 'Chưa phân công'}</span></div>
              </div>

              {/* Target Class Selection */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  Chọn lớp học đích muốn chuyển sang <span className="text-rose-500">*</span>
                </label>
                {loadingTransferTargets ? (
                  <div className="p-4 text-center text-xs text-slate-400">Đang tìm các lớp học phù hợp...</div>
                ) : transferTargets.length === 0 ? (
                  <div className="p-4 bg-amber-50 border border-amber-200/80 rounded-2xl text-xs text-amber-800 space-y-1">
                    <div className="font-bold flex items-center gap-1.5">
                      <AlertCircle className="w-4 h-4 text-amber-600 shrink-0" />
                      Không tìm thấy lớp học thỏa mãn điều kiện
                    </div>
                    <p className="text-[11px] text-amber-700 font-medium">
                      Để chuyển lớp, lớp đích phải khác lớp hiện tại, khác giảng viên, khác khung giờ học và còn chỗ trống. Hiện chưa có lớp nào đáp ứng đủ các điều kiện này.
                    </p>
                  </div>
                ) : (
                  <div className="space-y-2 max-h-56 overflow-y-auto pr-1">
                    {transferTargets.map((target) => {
                      const isFull = target.is_full || (target.max_capacity - (target.current_enrolled || 0)) <= 0;
                      const isBlocked = isFull || target.is_eligible === false;
                      return (
                        <label
                          key={target.id}
                          className={`block p-3 rounded-2xl border transition ${
                            isBlocked
                              ? 'border-slate-200 bg-slate-50/80 opacity-60 cursor-not-allowed'
                              : selectedTargetId === String(target.id)
                              ? 'border-indigo-600 bg-indigo-50/60 ring-2 ring-indigo-100 cursor-pointer'
                              : 'border-slate-200 hover:border-slate-300 bg-white cursor-pointer'
                          }`}
                        >
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                              <input
                                type="radio"
                                name="target_class"
                                value={target.id}
                                disabled={isBlocked}
                                checked={selectedTargetId === String(target.id)}
                                onChange={() => !isBlocked && setSelectedTargetId(String(target.id))}
                                className="text-indigo-600 focus:ring-indigo-500 disabled:opacity-40"
                              />
                              <span className="font-mono font-bold text-slate-900 text-xs">{target.class_code}</span>
                              <span className="text-[10px] bg-slate-100 text-slate-600 font-semibold px-2 py-0.5 rounded-md">
                                {target.course_title}
                              </span>
                            </div>
                            <div className="flex items-center gap-1.5">
                              {target.level_relation === 'SAME_LEVEL' && (
                                <span className="text-[10px] font-bold bg-indigo-50 text-indigo-700 px-2 py-0.5 rounded-full border border-indigo-100">
                                  Cùng cấp độ
                                </span>
                              )}
                              {target.level_relation === 'HIGHER_LEVEL' && (
                                <span className="text-[10px] font-bold bg-purple-50 text-purple-700 px-2 py-0.5 rounded-full border border-purple-100">
                                  Lên cấp độ
                                </span>
                              )}
                              {target.level_relation === 'LOWER_LEVEL' && (
                                <span className="text-[10px] font-bold bg-amber-50 text-amber-700 px-2 py-0.5 rounded-full border border-amber-100">
                                  Xuống cấp độ
                                </span>
                              )}
                              {isFull ? (
                                <span className="text-[11px] font-bold text-rose-700 bg-rose-50 px-2 py-0.5 rounded-full border border-rose-200">
                                  Hết chỗ ({target.current_enrolled || 0}/{target.max_capacity})
                                </span>
                              ) : (
                                <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                                  Còn {target.max_capacity - (target.current_enrolled || 0)} chỗ
                                </span>
                              )}
                            </div>
                          </div>
                          <div className="mt-2 text-[11px] text-slate-600 pl-5 space-y-0.5">
                            <div>GV mới: <strong className="text-slate-800">{target.teacher_name || 'Khác GV hiện tại'}</strong></div>
                            {target.schedule_summary && (
                              <div className="text-indigo-700 font-medium">Lịch học: {target.schedule_summary}</div>
                            )}
                            {target.is_eligible === false && target.ineligible_reason && (
                              <div className="text-rose-600 font-bold mt-1 text-[11px] flex items-center gap-1">
                                <AlertCircle className="w-3.5 h-3.5 shrink-0" />
                                <span>{target.ineligible_reason}</span>
                              </div>
                            )}
                          </div>
                        </label>
                      );
                    })}
                  </div>
                )}
              </div>

              {/* Reason */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Lý do chuyển lớp (tùy chọn)
                </label>
                <textarea
                  value={transferReason}
                  onChange={(e) => setTransferReason(e.target.value)}
                  placeholder="Ví dụ: Trùng lịch học cá nhân, mong muốn đổi ca học..."
                  rows={2}
                  className="w-full text-xs p-3 rounded-2xl border border-slate-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-100 outline-none text-slate-800 font-medium"
                />
              </div>

              {/* Notice */}
              <div className="p-3 bg-indigo-50/70 border border-indigo-100 rounded-2xl text-[11px] text-indigo-900 leading-relaxed">
                <strong>Lưu ý:</strong> Yêu cầu chuyển lớp sẽ được gửi đến Phòng Học vụ/Admin thẩm định và phê duyệt. Hệ thống không tự động chuyển lớp ngay.
              </div>

              {/* Action Buttons */}
              <div className="pt-2 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  onClick={() => setShowTransferModal(false)}
                  className="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Đóng
                </button>
                <button
                  type="submit"
                  disabled={transferSubmitting || !selectedTargetId || transferTargets.length === 0}
                  className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-indigo-600 hover:bg-indigo-700 text-white shadow-xs shadow-indigo-200 transition cursor-pointer disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed"
                >
                  {transferSubmitting ? 'Đang gửi yêu cầu...' : 'Gửi yêu cầu chuyển lớp'}
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: THẨM ĐỊNH & CHI TIẾT YÊU CẦU CHUYỂN LỚP (ADMIN / ACADEMIC_STAFF) ================= */}
      {showTransferDetailModal && selectedTransferDetail && createPortal(
        <div className="fixed inset-0 bg-slate-950/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-2xl bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
                  <FileText className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-black text-base text-slate-900">
                    Thẩm định yêu cầu chuyển lớp #{selectedTransferDetail.id}
                  </h3>
                  <p className="text-xs text-slate-500 font-medium">
                    Học viên: <strong className="text-slate-800">{selectedTransferDetail.student_name}</strong> ({selectedTransferDetail.student_code})
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setShowTransferDetailModal(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-xl hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="mt-5 space-y-4 text-xs">
              {/* Student & Class Cards Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                {/* Source Class */}
                <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-200/80 space-y-1.5">
                  <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Lớp hiện tại (Nguồn)</div>
                  <div className="flex items-center justify-between">
                    <span className="font-mono font-bold text-slate-900 text-sm">{selectedTransferDetail.source_class_code}</span>
                    <span className="text-[10px] bg-slate-200/70 text-slate-700 px-2 py-0.5 rounded font-semibold">
                      {selectedTransferDetail.source_target_level || 'Cấp độ'}
                    </span>
                  </div>
                  <div className="text-slate-600">Khóa: <strong>{selectedTransferDetail.source_course_title}</strong></div>
                  <div className="text-slate-600">Giảng viên: <strong>{selectedTransferDetail.source_teacher_name || 'Chưa phân công'}</strong></div>
                </div>

                {/* Target Class */}
                <div className="p-3.5 bg-indigo-50/60 rounded-2xl border border-indigo-100 space-y-1.5">
                  <div className="text-[11px] font-bold uppercase tracking-wider text-indigo-500">Lớp muốn chuyển (Đích)</div>
                  <div className="flex items-center justify-between">
                    <span className="font-mono font-bold text-indigo-900 text-sm">{selectedTransferDetail.target_class_code}</span>
                    <span className="text-[10px] bg-indigo-100 text-indigo-700 px-2 py-0.5 rounded font-semibold">
                      {selectedTransferDetail.target_target_level || 'Cấp độ'}
                    </span>
                  </div>
                  <div className="text-slate-700">Khóa: <strong>{selectedTransferDetail.target_course_title}</strong></div>
                  <div className="text-slate-700">Giảng viên: <strong>{selectedTransferDetail.target_teacher_name || 'Chưa phân công'}</strong></div>
                  <div className="flex items-center justify-between pt-1 border-t border-indigo-100/60 text-[11px]">
                    <span>Sĩ số: <strong>{selectedTransferDetail.target_current_enrolled}/{selectedTransferDetail.target_max_capacity}</strong></span>
                    <span className="font-bold text-emerald-700">Còn {selectedTransferDetail.target_available_slots} chỗ trống</span>
                  </div>
                </div>
              </div>

              {/* Transfer Reason */}
              {selectedTransferDetail.reason && (
                <div className="p-3.5 bg-slate-50/90 rounded-2xl border border-slate-200/80">
                  <span className="font-bold text-slate-700 block mb-1">Lý do học viên xin chuyển:</span>
                  <p className="text-slate-800 italic">{selectedTransferDetail.reason}</p>
                </div>
              )}

              {/* Automated Condition Checklist */}
              <div>
                <h4 className="font-black text-slate-900 text-xs mb-2 flex items-center gap-1.5">
                  <CheckCircle className="w-4 h-4 text-indigo-600" />
                  <span>Kết quả thẩm định điều kiện tự động</span>
                </h4>
                <div className="divide-y divide-slate-100 border border-slate-200/90 rounded-2xl overflow-hidden bg-white">
                  {selectedTransferDetail.checklist && selectedTransferDetail.checklist.length > 0 ? (
                    selectedTransferDetail.checklist.map((item, idx) => (
                      <div key={idx} className="p-3 flex items-start justify-between gap-3 text-xs hover:bg-slate-50/60 transition">
                        <div className="space-y-0.5">
                          <div className="font-bold text-slate-900">{item.name}</div>
                          <div className="text-slate-600 text-[11px]">{item.message}</div>
                        </div>
                        <div className="shrink-0">
                          {item.passed ? (
                            <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                              <Check className="w-3 h-3 text-emerald-600" /> ĐẠT
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                              <X className="w-3 h-3 text-rose-600" /> KHÔNG ĐẠT
                            </span>
                          )}
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="p-4 text-center text-slate-400 text-xs">Không có dữ liệu checklist thẩm định.</div>
                  )}
                </div>
              </div>

              {/* Status & Review Audit */}
              {selectedTransferDetail.status !== 'PENDING' && (
                <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-200 text-xs space-y-1">
                  <div className="font-bold text-slate-800">
                    Trạng thái: {selectedTransferDetail.status === 'APPROVED' ? 'ĐÃ PHÊ DUYỆT' : 'ĐÃ TỪ CHỐI'}
                  </div>
                  {selectedTransferDetail.reviewer_name && (
                    <div className="text-slate-600">
                      Người duyệt: <strong>{selectedTransferDetail.reviewer_name}</strong> &bull; {new Date(selectedTransferDetail.reviewed_at).toLocaleString('vi-VN')}
                    </div>
                  )}
                  {selectedTransferDetail.status === 'REJECTED' && selectedTransferDetail.rejection_reason && (
                    <div className="text-rose-700 bg-rose-50 border border-rose-100 p-2 rounded-xl text-xs font-semibold mt-1">
                      Lý do từ chối: {selectedTransferDetail.rejection_reason}
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Action Buttons */}
            <div className="mt-5 pt-4 border-t border-slate-100 flex items-center justify-between">
              <button
                type="button"
                onClick={() => setShowTransferDetailModal(false)}
                className="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
              >
                Đóng
              </button>

              {selectedTransferDetail.status === 'PENDING' && (
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    disabled={actionLoading}
                    onClick={() => handleOpenRejectModal(selectedTransferDetail)}
                    className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 transition cursor-pointer disabled:opacity-50"
                  >
                    <X className="w-3.5 h-3.5" />
                    <span>Từ chối</span>
                  </button>

                  <button
                    type="button"
                    disabled={actionLoading || !selectedTransferDetail.can_approve}
                    onClick={() => handleApproveTransfer(selectedTransferDetail.id)}
                    className="flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs shadow-emerald-200 transition cursor-pointer disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed"
                  >
                    <CheckCircle className="w-3.5 h-3.5" />
                    <span>{actionLoading ? 'Đang xử lý...' : 'Phê duyệt chuyển lớp'}</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: TỪ CHỐI YÊU CẦU CHUYỂN LỚP (BẮT BUỘC LÝ DO) ================= */}
      {showRejectModal && selectedTransferDetail && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center font-bold">
                  <X className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-black text-base text-slate-900">Từ chối chuyển lớp</h3>
                  <span className="text-xs text-slate-400">Yêu cầu #{selectedTransferDetail.id}</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setShowRejectModal(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-xl hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleConfirmReject} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">
                  Lý do từ chối <span className="text-rose-500">*</span>
                </label>
                <textarea
                  required
                  rows={3}
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                  placeholder="Nhập lý do cụ thể gửi đến học viên (ví dụ: Lớp đích không phù hợp lộ trình học, lịch học xung đột...)"
                  className="w-full text-xs p-3 rounded-2xl border border-slate-200 focus:border-rose-500 focus:ring-2 focus:ring-rose-100 outline-none text-slate-800 font-medium"
                />
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-2">
                <button
                  type="button"
                  onClick={() => setShowRejectModal(false)}
                  className="px-4 py-2 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={actionLoading || !rejectReason.trim()}
                  className="px-4 py-2 rounded-xl text-xs font-bold bg-rose-600 hover:bg-rose-700 text-white shadow-xs shadow-rose-200 transition cursor-pointer disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed"
                >
                  {actionLoading ? 'Đang lưu...' : 'Xác nhận từ chối'}
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
