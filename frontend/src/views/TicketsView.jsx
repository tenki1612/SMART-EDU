import React, { useEffect, useState, useMemo } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { useHeaderSlot } from '../context/HeaderSlotContext';
import { ticketsApi, classesApi, teachersApi } from '../services/api';
import { UserAvatar } from '../components/common/UserAvatar';
import {
  MessageSquare,
  Send,
  AlertTriangle,
  CheckCircle2,
  Clock,
  Inbox,
  Search,
  Filter,
  Plus,
  X,
  FileText,
  AlertCircle,
  Calendar,
  School,
  User,
  ShieldCheck,
  GraduationCap,
  Sparkles,
  ArrowRight,
  RotateCcw,
  Lock,
  Unlock,
  Check,
  BookOpen,
  Info
} from 'lucide-react';

export const TicketsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const headerSlot = useHeaderSlot();

  const userRole = user?.role || 'STUDENT';
  const isAdminOrStaff = ['ADMIN', 'ACADEMIC_STAFF'].includes(userRole);
  const isTeacher = userRole === 'TEACHER';
  const isStudent = userRole === 'STUDENT';

  // Quy tắc xác định khiếu nại điểm thống nhất (F-01)
  const isScoreComplaint = (ticket) => {
    if (!ticket) return false;
    const cat = (ticket.category || '').toUpperCase();
    const type = (ticket.ticket_type || '').toUpperCase();
    if (['GRADE_UNLOCK', 'UNLOCK_GRADE'].includes(cat)) return false;
    if (type === 'COMPLAINT') return true;
    if (['GRADE', 'GRADE_COMPLAINT'].includes(cat)) return true;
    return false;
  };

  // Active Tab: default to 'sent' for students, 'inbox' for teachers/staff/admin
  const [activeTab, setActiveTab] = useState(isStudent ? 'sent' : 'inbox');
  const [inboxTickets, setInboxTickets] = useState([]);
  const [sentTickets, setSentTickets] = useState([]);
  const [serverStats, setServerStats] = useState(null);
  const [loading, setLoading] = useState(false);
  const [fetchError, setFetchError] = useState(null);

  // Phân trang phía Server (F-06)
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(15);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);

  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState('ALL'); // 'ALL' | 'COMPLAINT' | 'REQUEST'
  const [categoryFilter, setCategoryFilter] = useState('ALL'); // 'ALL' | 'GRADE' | 'GRADE_UNLOCK' | 'SCHEDULE' | 'ENROLLMENT'
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Debounce search term 300ms (F-06)
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchTerm);
      setPage(1);
    }, 300);
    return () => clearTimeout(timer);
  }, [searchTerm]);

  // Metadata
  const [classesList, setClassesList] = useState([]);
  const [teachersList, setTeachersList] = useState([]);

  // Create Ticket Modal
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createForm, setCreateForm] = useState({
    ticket_type: 'COMPLAINT',
    receiver_role: 'TEACHER',
    receiver_id: '',
    category: 'GRADE',
    related_class_id: '',
    title: '',
    content: ''
  });
  const [deadlineCheckResult, setDeadlineCheckResult] = useState(null);
  const [isCheckingDeadline, setIsCheckingDeadline] = useState(false);

  // Detail & Discussion Modal
  const [selectedTicketId, setSelectedTicketId] = useState(null);
  const [ticketDetail, setTicketDetail] = useState(null);
  const [replyContent, setReplyContent] = useState('');
  const [isSubmittingReply, setIsSubmittingReply] = useState(false);

  // Action Confirmation Modals (Approve, Reject, Resolve)
  const [showApproveModal, setShowApproveModal] = useState(false);
  const [approveNote, setApproveNote] = useState('');
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [showResolveModal, setShowResolveModal] = useState(false);
  const [resolveNote, setResolveNote] = useState('');
  const [isProcessingAction, setIsProcessingAction] = useState(false);

  // F-05: Tải dữ liệu có quản lý rõ ràng loading, error, empty, success; không nuốt lỗi
  const loadData = async () => {
    setLoading(true);
    setFetchError(null);
    try {
      const params = {
        page,
        limit,
        q: debouncedSearch.trim() || undefined,
        category: categoryFilter !== 'ALL' ? categoryFilter : undefined,
        status: statusFilter !== 'ALL' ? statusFilter : undefined,
        ticket_type: typeFilter !== 'ALL' ? typeFilter : undefined,
      };

      if (activeTab === 'inbox') {
        const res = await ticketsApi.listInbox(params);
        const data = res.data;
        if (data && typeof data === 'object' && Array.isArray(data.items)) {
          setInboxTickets(data.items);
          setTotalCount(data.total);
          setTotalPages(data.total_pages);
        } else {
          const list = Array.isArray(data) ? data : [];
          setInboxTickets(list);
          setTotalCount(list.length);
          setTotalPages(Math.ceil(list.length / limit) || 1);
        }
      } else {
        const res = await ticketsApi.listSent(params);
        const data = res.data;
        if (data && typeof data === 'object' && Array.isArray(data.items)) {
          setSentTickets(data.items);
          setTotalCount(data.total);
          setTotalPages(data.total_pages);
        } else {
          const list = Array.isArray(data) ? data : [];
          setSentTickets(list);
          setTotalCount(list.length);
          setTotalPages(Math.ceil(list.length / limit) || 1);
        }
      }
    } catch (e) {
      console.error(e);
      const errMsg = e.response?.data?.message || e.message || 'Lỗi tải danh sách đơn';
      setFetchError(errMsg);
      toast.error('Lỗi tải danh sách đơn: ' + errMsg);
    } finally {
      setLoading(false);
    }
  };

  const loadStats = async () => {
    try {
      const res = await ticketsApi.getStats();
      if (res && res.data) {
        setServerStats(res.data);
      }
    } catch (e) {
      console.warn('Could not load ticket stats:', e);
    }
  };

  const loadMetadata = async () => {
    try {
      const [resCls, resTea] = await Promise.all([
        classesApi.list().catch(() => ({ data: [] })),
        teachersApi.list().catch(() => ({ data: [] })),
      ]);
      setClassesList(resCls.data || []);
      setTeachersList(resTea.data || []);
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    loadData();
    loadStats();
  }, [activeTab, page, limit, debouncedSearch, categoryFilter, statusFilter, typeFilter]);

  useEffect(() => {
    loadMetadata();
    loadStats();
  }, []);

  // When class changes in Create modal
  const handleClassChangeInCreate = async (classId) => {
    const selectedClass = classesList.find((c) => String(c.id) === String(classId));
    setCreateForm((prev) => {
      const next = { ...prev, related_class_id: classId };
      // Auto-set teacher if available
      if (selectedClass?.teacher_user_id) {
        next.receiver_id = selectedClass.teacher_user_id;
      }
      // If teacher is creating unlock request, auto-generate title
      if (prev.category === 'GRADE_UNLOCK' && selectedClass) {
        next.title = `Yêu cầu mở sổ điểm lớp ${selectedClass.class_code}`;
      }
      return next;
    });

    if (!classId || createForm.ticket_type !== 'COMPLAINT') {
      setDeadlineCheckResult(null);
      return;
    }

    setIsCheckingDeadline(true);
    try {
      const res = await ticketsApi.checkDeadline(classId);
      setDeadlineCheckResult(res.data);
    } catch (e) {
      setDeadlineCheckResult(null);
    } finally {
      setIsCheckingDeadline(false);
    }
  };

  // Open Create Modal specialized for Student Complaint
  const openStudentComplaintModal = () => {
    setCreateForm({
      ticket_type: 'COMPLAINT',
      receiver_role: 'TEACHER',
      receiver_id: '',
      category: 'GRADE',
      related_class_id: classesList.length > 0 ? String(classesList[0].id) : '',
      title: 'Khiếu nại kết quả điểm số',
      content: ''
    });
    setDeadlineCheckResult(null);
    if (classesList.length > 0) {
      handleClassChangeInCreate(classesList[0].id);
    }
    setShowCreateModal(true);
  };

  // Open Create Modal specialized for Teacher Unlock Request
  const openTeacherUnlockRequestModal = () => {
    const defaultCls = classesList.length > 0 ? classesList[0] : null;
    setCreateForm({
      ticket_type: 'REQUEST',
      receiver_role: 'ACADEMIC_STAFF',
      receiver_id: '',
      category: 'GRADE_UNLOCK',
      related_class_id: defaultCls ? String(defaultCls.id) : '',
      title: defaultCls ? `Yêu cầu mở sổ điểm lớp ${defaultCls.class_code}` : 'Yêu cầu mở khóa sổ điểm lớp học',
      content: ''
    });
    setDeadlineCheckResult(null);
    setShowCreateModal(true);
  };

  // Open General Create Modal
  const openGeneralCreateModal = () => {
    setCreateForm({
      ticket_type: isStudent ? 'COMPLAINT' : 'REQUEST',
      receiver_role: isStudent ? 'TEACHER' : 'ACADEMIC_STAFF',
      receiver_id: '',
      category: isStudent ? 'GRADE' : isTeacher ? 'GRADE_UNLOCK' : 'OTHER',
      related_class_id: classesList.length > 0 ? String(classesList[0].id) : '',
      title: '',
      content: ''
    });
    setDeadlineCheckResult(null);
    setShowCreateModal(true);
  };

  const handleCreateTicketSubmit = async (e) => {
    e.preventDefault();
    if (!createForm.title.trim() || !createForm.content.trim()) {
      toast.warning('Vui lòng nhập đầy đủ tiêu đề và nội dung đơn.');
      return;
    }

    if (createForm.ticket_type === 'COMPLAINT' && !createForm.related_class_id) {
      toast.warning('Vui lòng chọn lớp học phần cần khiếu nại.');
      return;
    }

    if (createForm.ticket_type === 'COMPLAINT' && deadlineCheckResult?.is_expired) {
      toast.error('Không thể gửi khiếu nại do đã quá thời hạn cho phép đối với lớp học này.');
      return;
    }

    if (createForm.category === 'GRADE_UNLOCK' && !createForm.related_class_id) {
      toast.warning('Vui lòng chọn lớp học phần cần yêu cầu mở sổ điểm.');
      return;
    }

    try {
      await ticketsApi.create({
        ticket_type: createForm.ticket_type,
        receiver_role: createForm.receiver_role || undefined,
        receiver_id: createForm.receiver_id ? Number(createForm.receiver_id) : undefined,
        category: createForm.category,
        related_class_id: createForm.related_class_id ? Number(createForm.related_class_id) : undefined,
        title: createForm.title.trim(),
        content: createForm.content.trim(),
      });

      toast.success(
        createForm.category === 'GRADE_UNLOCK'
          ? 'Đã gửi Yêu cầu mở sổ điểm tới Phòng Học vụ thành công!'
          : createForm.ticket_type === 'COMPLAINT'
          ? 'Đã gửi Đơn khiếu nại điểm số thành công!'
          : 'Đã gửi Đơn yêu cầu thành công!'
      );

      setShowCreateModal(false);
      setDeadlineCheckResult(null);
      setActiveTab('sent');
      loadData();
      loadStats();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Open detail modal (F-01, F-10)
  const handleOpenDetail = async (ticketId) => {
    const target = [...inboxTickets, ...sentTickets].find(t => t.id === ticketId);
    if (isAdminOrStaff && target && isScoreComplaint(target)) {
      toast.error('Quản trị viên và Nhân viên học vụ không có quyền truy cập dữ liệu khiếu nại điểm.');
      return;
    }
    setSelectedTicketId(ticketId);
    setReplyContent('');
    try {
      const res = await ticketsApi.getDetail(ticketId);
      if (isAdminOrStaff && isScoreComplaint(res.data)) {
        toast.error('Quản trị viên và Nhân viên học vụ không có quyền truy cập dữ liệu khiếu nại điểm.');
        setSelectedTicketId(null);
        return;
      }
      setTicketDetail(res.data);
    } catch (e) {
      toast.error('Lỗi tải chi tiết đơn: ' + e.message);
      setSelectedTicketId(null);
    }
  };

  const handleSendReply = async (e) => {
    e.preventDefault();
    if (!replyContent.trim()) return;
    setIsSubmittingReply(true);
    try {
      await ticketsApi.sendMessage(selectedTicketId, replyContent.trim());
      toast.success('Đã gửi phản hồi thành công!');
      setReplyContent('');
      // Reload detail
      const res = await ticketsApi.getDetail(selectedTicketId);
      setTicketDetail(res.data);
      loadData();
      loadStats();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setIsSubmittingReply(false);
    }
  };

  // Approve Unlock Request (Staff & Admin)
  const handleApproveUnlock = async () => {
    setIsProcessingAction(true);
    try {
      await ticketsApi.updateStatus(selectedTicketId, 'APPROVED', approveNote.trim() || undefined);
      toast.success('Đã phê duyệt yêu cầu và mở khóa sổ điểm thành công!');
      setShowApproveModal(false);
      setApproveNote('');
      const res = await ticketsApi.getDetail(selectedTicketId);
      setTicketDetail(res.data);
      loadData();
      loadStats();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setIsProcessingAction(false);
    }
  };

  // Reject Unlock Request (Staff & Admin) - Reason is MANDATORY
  const handleRejectUnlock = async () => {
    if (!rejectReason.trim()) {
      toast.warning('Vui lòng nhập lý do từ chối yêu cầu.');
      return;
    }
    setIsProcessingAction(true);
    try {
      await ticketsApi.updateStatus(selectedTicketId, 'REJECTED', rejectReason.trim());
      toast.success('Đã từ chối yêu cầu mở sổ điểm.');
      setShowRejectModal(false);
      setRejectReason('');
      const res = await ticketsApi.getDetail(selectedTicketId);
      setTicketDetail(res.data);
      loadData();
      loadStats();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setIsProcessingAction(false);
    }
  };

  // Resolve Complaint (Teacher, Staff, Admin)
  const handleResolveComplaint = async () => {
    setIsProcessingAction(true);
    try {
      await ticketsApi.updateStatus(selectedTicketId, 'RESOLVED', resolveNote.trim() || undefined);
      toast.success('Đã cập nhật giải quyết khiếu nại thành công!');
      setShowResolveModal(false);
      setResolveNote('');
      const res = await ticketsApi.getDetail(selectedTicketId);
      setTicketDetail(res.data);
      loadData();
      loadStats();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setIsProcessingAction(false);
    }
  };

  // Simple status transition (Processing, Closed)
  const handleSimpleStatusUpdate = async (newStatus) => {
    try {
      await ticketsApi.updateStatus(selectedTicketId, newStatus);
      toast.success(`Đã cập nhật trạng thái đơn thành ${newStatus}`);
      const res = await ticketsApi.getDetail(selectedTicketId);
      setTicketDetail(res.data);
      loadData();
      loadStats();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Filtered lists: server already handles q, category, status, and role scope
  const currentList = activeTab === 'inbox' ? inboxTickets : sentTickets;
  const filteredList = useMemo(() => {
    return currentList.filter((item) => {
      // Safety client-side check: Admin and Staff never see score complaints (F-01, F-04)
      if (isAdminOrStaff && isScoreComplaint(item)) return false;
      return true;
    });
  }, [currentList, isAdminOrStaff]);

  // Statistics (N-03: Reflects full scope via GET /api/v1/tickets/stats; strictly avoids falling back to page count)
  const stats = useMemo(() => {
    if (serverStats) {
      return {
        total: serverStats.total ?? 0,
        pending: serverStats.pending ?? 0,
        approved: serverStats.approved ?? 0,
        resolved: (serverStats.resolved ?? 0) + (serverStats.closed ?? 0),
        complaints: serverStats.complaints ?? 0,
        unlockRequests: serverStats.unlock_requests ?? 0,
      };
    }
    const all = [...inboxTickets, ...sentTickets];
    const uniqueMap = new Map();
    all.forEach(t => uniqueMap.set(t.id, t));
    const unique = Array.from(uniqueMap.values()).filter(t => !isAdminOrStaff || !isScoreComplaint(t));
    return {
      total: unique.length,
      pending: unique.filter(t => t.status === 'PENDING').length,
      approved: unique.filter(t => t.status === 'APPROVED').length,
      resolved: unique.filter(t => ['RESOLVED', 'CLOSED'].includes(t.status)).length,
      complaints: unique.filter(t => isScoreComplaint(t)).length,
      unlockRequests: unique.filter(t => ['GRADE_UNLOCK', 'UNLOCK_GRADE'].includes((t.category || '').toUpperCase())).length,
    };
  }, [serverStats, inboxTickets, sentTickets, isAdminOrStaff]);

  const getStatusBadge = (status) => {
    switch (status) {
      case 'PENDING':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-amber-700 bg-amber-50 border border-amber-200/80 px-2.5 py-1 rounded-xl">
            <Clock className="w-3 h-3 text-amber-600" /> Chờ xử lý
          </span>
        );
      case 'PROCESSING':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-blue-700 bg-blue-50 border border-blue-200/80 px-2.5 py-1 rounded-xl">
            <RotateCcw className="w-3 h-3 text-blue-600 animate-spin" /> Đang xử lý
          </span>
        );
      case 'APPROVED':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200/80 px-2.5 py-1 rounded-xl">
            <CheckCircle2 className="w-3 h-3 text-emerald-600" /> Đã phê duyệt
          </span>
        );
      case 'REJECTED':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-rose-700 bg-rose-50 border border-rose-200/80 px-2.5 py-1 rounded-xl">
            <X className="w-3 h-3 text-rose-600" /> Đã từ chối
          </span>
        );
      case 'RESOLVED':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-teal-700 bg-teal-50 border border-teal-200/80 px-2.5 py-1 rounded-xl">
            <CheckCircle2 className="w-3 h-3 text-teal-600" /> Đã giải quyết
          </span>
        );
      case 'CLOSED':
        return (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-slate-600 bg-slate-100 border border-slate-200 px-2.5 py-1 rounded-xl">
            Đã đóng
          </span>
        );
      default:
        return <span className="text-[11px] font-medium text-slate-500">{status}</span>;
    }
  };

  const getCategoryLabel = (cat) => {
    switch (cat) {
      case 'GRADE': return 'Khiếu nại điểm số';
      case 'GRADE_UNLOCK':
      case 'UNLOCK_GRADE': return 'Yêu cầu mở sổ điểm';
      case 'SCHEDULE': return 'Lịch học / Phòng học';
      case 'ENROLLMENT': return 'Đăng ký / Tuyển sinh';
      default: return 'Ý kiến / Khác';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Slot Actions: Admin & Academic Staff are strictly forbidden from creating tickets */}
      {headerSlot && !isAdminOrStaff && createPortal(
        <div className="flex items-center gap-2">
          {isStudent && (
            <button
              type="button"
              onClick={openStudentComplaintModal}
              className="flex items-center gap-1.5 bg-gradient-to-r from-rose-600 to-rose-500 hover:from-rose-700 hover:to-rose-600 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-rose-200 transition cursor-pointer active:scale-95"
            >
              <AlertTriangle className="w-4 h-4" />
              <span>Khiếu nại điểm</span>
            </button>
          )}

          {isTeacher && (
            <button
              type="button"
              onClick={openTeacherUnlockRequestModal}
              className="flex items-center gap-1.5 bg-gradient-to-r from-amber-600 to-amber-500 hover:from-amber-700 hover:to-amber-600 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-amber-200 transition cursor-pointer active:scale-95"
            >
              <Unlock className="w-4 h-4" />
              <span>Yêu cầu mở sổ điểm</span>
            </button>
          )}

          <button
            type="button"
            onClick={openGeneralCreateModal}
            className="flex items-center gap-1.5 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-indigo-200 transition cursor-pointer active:scale-95"
          >
            <Plus className="w-4 h-4" />
            <span>{isStudent ? 'Gửi yêu cầu hỗ trợ' : 'Tạo đơn mới'}</span>
          </button>
        </div>,
        headerSlot
      )}

      {/* KPI Overview Cards: Admin & Staff strictly do NOT see complaints */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider block">
              {isTeacher
                ? 'Tổng đơn liên quan'
                : isAdminOrStaff
                ? 'Tổng yêu cầu tiếp nhận'
                : isStudent
                ? 'Tổng đơn của tôi'
                : 'Tổng đơn'}
            </span>
            <span className="text-2xl font-black text-slate-900 mt-0.5 block tabular-nums">{stats.total}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-600">
            <MessageSquare className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-amber-600 uppercase tracking-wider block">Chờ xử lý</span>
            <span className="text-2xl font-black text-amber-700 mt-0.5 block tabular-nums">{stats.pending}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-amber-50 border border-amber-200/60 flex items-center justify-center text-amber-600">
            <Clock className="w-5 h-5" />
          </div>
        </div>

        {isAdminOrStaff ? (
          <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold text-amber-600 uppercase tracking-wider block">Yêu cầu mở sổ điểm</span>
              <span className="text-2xl font-black text-amber-700 mt-0.5 block tabular-nums">{stats.unlockRequests}</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-amber-50 border border-amber-200/60 flex items-center justify-center text-amber-600">
              <Unlock className="w-5 h-5" />
            </div>
          </div>
        ) : (
          <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
            <div>
              <span className="text-[11px] font-bold text-rose-600 uppercase tracking-wider block">Khiếu nại điểm</span>
              <span className="text-2xl font-black text-rose-700 mt-0.5 block tabular-nums">{stats.complaints}</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-rose-50 border border-rose-200/60 flex items-center justify-center text-rose-600">
              <AlertTriangle className="w-5 h-5" />
            </div>
          </div>
        )}

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-emerald-600 uppercase tracking-wider block">
              {isAdminOrStaff ? 'Đã duyệt & Giải quyết' : 'Mở điểm & Giải quyết'}
            </span>
            <span className="text-2xl font-black text-emerald-700 mt-0.5 block tabular-nums">{stats.approved + stats.resolved}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-200/60 flex items-center justify-center text-emerald-600">
            <CheckCircle2 className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* Tabs & Search Filter Bar */}
      <div className="bg-white p-3.5 sm:p-4 rounded-3xl border border-slate-200/90 shadow-2xs space-y-3">
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
          
          {/* Main Tabs: Inbox vs Sent */}
          <div className="flex items-center gap-1 bg-slate-100/80 p-1 rounded-2xl shrink-0">
            <button
              type="button"
              onClick={() => { setActiveTab('inbox'); setPage(1); }}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
                activeTab === 'inbox'
                  ? 'bg-white text-indigo-700 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Inbox className="w-3.5 h-3.5" />
              <span>{isTeacher ? 'Khiếu nại từ học viên' : isStudent ? 'Hộp thư đến' : 'Hộp thư tiếp nhận'}</span>
              <span className="text-[10px] font-mono px-1.5 py-0.2 rounded-full bg-slate-100 text-slate-700">
                {activeTab === 'inbox' ? totalCount : inboxTickets.length}
              </span>
            </button>

            {!isAdminOrStaff && (
              <button
                type="button"
                onClick={() => { setActiveTab('sent'); setPage(1); }}
                className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
                  activeTab === 'sent'
                    ? 'bg-white text-indigo-700 shadow-xs'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <Send className="w-3.5 h-3.5" />
                <span>{isStudent ? 'Khiếu nại & Đơn của tôi' : isTeacher ? 'Yêu cầu mở điểm của tôi' : 'Đơn đã gửi'}</span>
                <span className="text-[10px] font-mono px-1.5 py-0.2 rounded-full bg-slate-100 text-slate-700">
                  {activeTab === 'sent' ? totalCount : sentTickets.length}
                </span>
              </button>
            )}
          </div>

          {/* Category Filter Pills: Exclude GRADE for Admin/Staff */}
          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
            {[
              { id: 'ALL', label: 'Tất cả' },
              ...(!isAdminOrStaff ? [{ id: 'GRADE', label: 'Khiếu nại điểm' }] : []),
              { id: 'GRADE_UNLOCK', label: 'Yêu cầu mở sổ điểm' },
              { id: 'SCHEDULE', label: 'Lịch học' },
              { id: 'ENROLLMENT', label: 'Tuyển sinh' },
            ].map((cat) => (
              <button
                key={cat.id}
                type="button"
                onClick={() => { setCategoryFilter(cat.id); setPage(1); }}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition cursor-pointer whitespace-nowrap ${
                  categoryFilter === cat.id
                    ? 'bg-indigo-50 text-indigo-700 border border-indigo-200'
                    : 'text-slate-500 hover:bg-slate-100 border border-transparent'
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>
        </div>

        {/* Search & Status Filters */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 pt-2 border-t border-slate-100">
          <div className="sm:col-span-2 relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Tìm theo mã đơn, tiêu đề, lớp học, người gửi..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-xl text-xs outline-hidden focus:border-indigo-600 font-medium"
            />
          </div>

          <div className="flex items-center gap-2">
            <select
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
              className="w-full border border-slate-200 rounded-xl px-3 py-2 text-xs font-bold outline-hidden focus:border-indigo-600 bg-white"
            >
              <option value="ALL">-- Tất cả trạng thái --</option>
              <option value="PENDING">Chờ xử lý (Pending)</option>
              <option value="PROCESSING">Đang xử lý (Processing)</option>
              <option value="APPROVED">Đã phê duyệt (Approved)</option>
              <option value="REJECTED">Đã từ chối (Rejected)</option>
              <option value="RESOLVED">Đã giải quyết (Resolved)</option>
              <option value="CLOSED">Đã đóng (Closed)</option>
            </select>
          </div>
        </div>
      </div>

      {/* Error state alert (F-05) */}
      {fetchError && !loading && (
        <div className="bg-rose-50 border border-rose-200 rounded-2xl p-4 flex items-center justify-between gap-3 text-rose-800 animate-in fade-in">
          <div className="flex items-center gap-2">
            <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
            <div>
              <p className="font-bold text-xs">Đã xảy ra lỗi khi tải danh sách đơn</p>
              <p className="text-[11px] text-rose-600 mt-0.5">{fetchError}</p>
            </div>
          </div>
          <button
            type="button"
            onClick={() => loadData()}
            className="px-3.5 py-1.5 bg-rose-600 hover:bg-rose-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 cursor-pointer shrink-0 shadow-xs active:scale-95"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Thử lại</span>
          </button>
        </div>
      )}

      {/* Tickets List Table */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-200/80 bg-slate-50/70 text-[11px] font-black uppercase tracking-wider text-slate-500">
                <th className="p-4 pl-5">Mã đơn & Thời gian</th>
                <th className="p-4">Tiêu đề & Nội dung</th>
                <th className="p-4">Lĩnh vực & Lớp học</th>
                <th className="p-4">{activeTab === 'inbox' ? 'Người gửi' : 'Nơi nhận'}</th>
                <th className="p-4 text-center">Trạng thái</th>
                <th className="p-4 pr-5 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium text-slate-700">
              {loading ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <RotateCcw className="w-6 h-6 animate-spin mx-auto mb-2 text-indigo-600" />
                    <span>Đang tải danh sách đơn...</span>
                  </td>
                </tr>
              ) : filteredList.length === 0 ? (
                <tr>
                  <td colSpan="6" className="p-12 text-center text-slate-400">
                    <Inbox className="w-10 h-10 mx-auto mb-3 text-slate-300" />
                    <p className="font-bold text-slate-700">Không có đơn khiếu nại hoặc yêu cầu nào</p>
                    <span className="text-xs text-slate-400 block mt-1">
                      {searchTerm ? 'Không tìm thấy kết quả phù hợp với bộ lọc' : 'Hộp thư hiện đang trống.'}
                    </span>
                  </td>
                </tr>
              ) : (
                filteredList.map((t) => (
                  <tr key={t.id} className="hover:bg-slate-50/80 transition-colors">
                    {/* Code & Time */}
                    <td className="p-4 pl-5 align-top">
                      <span className="font-mono font-bold text-xs bg-slate-100 px-2.5 py-1 rounded-lg text-slate-800 block w-fit">
                        {t.ticket_code}
                      </span>
                      <div className="flex items-center gap-1 mt-1.5">
                        {t.ticket_type === 'COMPLAINT' ? (
                          <span className="text-[10px] font-black bg-rose-50 text-rose-700 border border-rose-200 px-1.5 py-0.2 rounded">
                            Khiếu nại
                          </span>
                        ) : ['GRADE_UNLOCK', 'UNLOCK_GRADE'].includes(t.category) ? (
                          <span className="text-[10px] font-black bg-amber-50 text-amber-700 border border-amber-200 px-1.5 py-0.2 rounded">
                            Mở sổ điểm
                          </span>
                        ) : (
                          <span className="text-[10px] font-black bg-indigo-50 text-indigo-700 border border-indigo-200 px-1.5 py-0.2 rounded">
                            Yêu cầu
                          </span>
                        )}
                      </div>
                      <span className="text-[10px] text-slate-400 block mt-1">
                        {new Date(t.created_at).toLocaleDateString('vi-VN')}
                      </span>
                    </td>

                    {/* Title & Preview */}
                    <td className="p-4 align-top max-w-xs">
                      <div className="font-black text-slate-900 text-xs line-clamp-1">{t.title}</div>
                      <div className="text-slate-500 text-[11px] mt-1 line-clamp-2 font-medium">
                        {t.content}
                      </div>
                      {t.messages_count > 0 && (
                        <span className="inline-flex items-center gap-1 text-[10px] font-bold text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded-full mt-1.5">
                          <MessageSquare className="w-3 h-3" /> {t.messages_count} trao đổi
                        </span>
                      )}
                    </td>

                    {/* Category & Class */}
                    <td className="p-4 align-top">
                      <span className="text-xs font-bold text-slate-800 block">
                        {getCategoryLabel(t.category)}
                      </span>
                      {t.class_code && (
                        <span className="font-mono text-[11px] font-bold text-indigo-600 block mt-0.5">
                          Lớp: {t.class_code}
                        </span>
                      )}
                      {t.deadline_at && (
                        <div className="text-[10px] text-slate-400 mt-1 flex items-center gap-1">
                          <Clock className="w-3 h-3 text-slate-400" />
                          <span>Hạn: {new Date(t.deadline_at).toLocaleDateString('vi-VN')}</span>
                        </div>
                      )}
                    </td>

                    {/* Sender / Receiver */}
                    <td className="p-4 align-top">
                      {activeTab === 'inbox' ? (
                        <div>
                          <div className="font-bold text-slate-800 text-xs">{t.sender_name}</div>
                          <span className="text-[10px] font-semibold text-slate-400 block">
                            {t.sender_role}
                          </span>
                        </div>
                      ) : (
                        <div>
                          <div className="font-bold text-slate-800 text-xs">
                            {t.receiver_name || `Bộ phận: ${t.receiver_role || 'Trung tâm'}`}
                          </div>
                          {t.receiver_role && (
                            <span className="text-[10px] font-semibold text-slate-400 block">
                              {t.receiver_role}
                            </span>
                          )}
                        </div>
                      )}
                    </td>

                    {/* Status */}
                    <td className="p-4 align-top text-center">
                      {getStatusBadge(t.status)}
                    </td>

                    {/* Actions */}
                    <td className="p-4 pr-5 align-top text-right">
                      <button
                        type="button"
                        onClick={() => handleOpenDetail(t.id)}
                        className="px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold rounded-xl text-xs transition cursor-pointer active:scale-95 inline-flex items-center gap-1"
                      >
                        <span>Chi tiết</span>
                        <ArrowRight className="w-3 h-3" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Server Pagination Bar (F-06) */}
        <div className="px-5 py-3.5 bg-slate-50/60 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-600">
          <div className="font-medium">
            {totalCount > 0 ? (
              <span>
                Hiển thị <span className="font-bold text-slate-900">{(page - 1) * limit + 1}</span> - <span className="font-bold text-slate-900">{Math.min(page * limit, totalCount)}</span> trong tổng số <span className="font-bold text-slate-900">{totalCount}</span> đơn
              </span>
            ) : (
              <span>Không có bản ghi nào</span>
            )}
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              disabled={page <= 1 || loading}
              onClick={() => setPage((prev) => Math.max(1, prev - 1))}
              className="px-3 py-1.5 border border-slate-200 rounded-xl bg-white font-bold text-slate-700 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition cursor-pointer"
            >
              Trang trước
            </button>
            <span className="font-bold text-slate-800 px-2 font-mono text-[11px]">
              Trang {page} / {totalPages || 1}
            </span>
            <button
              type="button"
              disabled={page >= totalPages || loading}
              onClick={() => setPage((prev) => Math.min(totalPages, prev + 1))}
              className="px-3 py-1.5 border border-slate-200 rounded-xl bg-white font-bold text-slate-700 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition cursor-pointer"
            >
              Trang sau
            </button>
          </div>
        </div>
      </div>

      {/* ================= MODAL: TẠO ĐƠN MỚI ================= */}
      {showCreateModal && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <MessageSquare className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">
                    {createForm.category === 'GRADE_UNLOCK'
                      ? 'Yêu Cầu Mở Khóa Sổ Điểm'
                      : createForm.ticket_type === 'COMPLAINT'
                      ? 'Tạo Đơn Khiếu Nại Điểm Số'
                      : 'Tạo Đơn Yêu Cầu Hỗ Trợ'}
                  </h3>
                  <span className="text-xs text-slate-400">Giao tiếp và xử lý nội bộ theo quy trình SMART-EDU</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setShowCreateModal(false)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateTicketSubmit} className="space-y-4 text-xs">
              
              {/* Type Selection (Disabled or customized for students and teachers) */}
              {!isStudent && !isTeacher && (
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Loại đơn gửi đi:</label>
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      onClick={() => setCreateForm({ ...createForm, ticket_type: 'REQUEST', category: 'OTHER' })}
                      className={`p-3 rounded-2xl border text-left transition cursor-pointer ${
                        createForm.ticket_type === 'REQUEST'
                          ? 'bg-indigo-50/70 border-indigo-400 ring-2 ring-indigo-100'
                          : 'bg-white border-slate-200 hover:bg-slate-50'
                      }`}
                    >
                      <div className="font-bold text-slate-900 flex items-center gap-1.5">
                        <FileText className="w-4 h-4 text-indigo-600" />
                        <span>Đơn yêu cầu (Request)</span>
                      </div>
                      <p className="text-[11px] text-slate-500 mt-1">Yêu cầu mở khóa điểm, chuyển lớp, hỗ trợ đào tạo...</p>
                    </button>

                    <button
                      type="button"
                      onClick={() => setCreateForm({ ...createForm, ticket_type: 'COMPLAINT', category: 'GRADE' })}
                      className={`p-3 rounded-2xl border text-left transition cursor-pointer ${
                        createForm.ticket_type === 'COMPLAINT'
                          ? 'bg-rose-50/70 border-rose-400 ring-2 ring-rose-100'
                          : 'bg-white border-slate-200 hover:bg-slate-50'
                      }`}
                    >
                      <div className="font-bold text-slate-900 flex items-center gap-1.5">
                        <AlertTriangle className="w-4 h-4 text-rose-600" />
                        <span>Đơn khiếu nại (Complaint)</span>
                      </div>
                      <p className="text-[11px] text-slate-500 mt-1">Khiếu nại về điểm số, phúc khảo bài thi...</p>
                    </button>
                  </div>
                </div>
              )}

              {/* Class selection */}
              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  Lớp học phần liên quan <span className="text-rose-500">*</span>:
                </label>
                <select
                  required
                  value={createForm.related_class_id}
                  onChange={(e) => handleClassChangeInCreate(e.target.value)}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                >
                  <option value="">-- Chọn lớp học phần --</option>
                  {classesList.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.class_code} - {c.course_title} (GV: {c.teacher_name || 'Chưa phân công'})
                    </option>
                  ))}
                </select>
                <span className="text-[10px] text-slate-400 block mt-1">
                  {isStudent
                    ? 'Danh sách hiển thị các lớp học bạn đang hoặc đã theo học.'
                    : isTeacher
                    ? 'Danh sách hiển thị các lớp học do bạn trực tiếp giảng dạy.'
                    : 'Chọn lớp học phần cần gắn kết với đơn.'}
                </span>
              </div>

              {/* Deadline Check Alert Banner for Complaints */}
              {createForm.ticket_type === 'COMPLAINT' && deadlineCheckResult && (
                <div
                  className={`p-3 rounded-2xl border text-xs font-semibold flex items-start gap-2.5 ${
                    deadlineCheckResult.is_expired
                      ? 'bg-rose-50 border-rose-200 text-rose-900'
                      : 'bg-emerald-50 border-emerald-200 text-emerald-900'
                  }`}
                >
                  {deadlineCheckResult.is_expired ? (
                    <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                  ) : (
                    <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                  )}
                  <div>
                    <div>{deadlineCheckResult.message}</div>
                    {deadlineCheckResult.is_expired && (
                      <div className="text-[11px] text-rose-700 font-bold mt-1">
                        Hệ thống từ chối tiếp nhận khiếu nại do đã quá hạn 7 ngày kể từ khi lớp kết thúc.
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Title & Content */}
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tiêu đề đơn <span className="text-rose-500">*</span>:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: Đề nghị phúc khảo điểm thi cuối kỳ, Yêu cầu mở sổ điểm để chỉnh sửa..."
                  value={createForm.title}
                  onChange={(e) => setCreateForm({ ...createForm, title: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-bold outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  {createForm.category === 'GRADE_UNLOCK' ? 'Lý do xin mở sổ điểm' : 'Nội dung chi tiết khiếu nại / yêu cầu'}{' '}
                  <span className="text-rose-500">*</span>:
                </label>
                <textarea
                  rows={4}
                  required
                  placeholder={
                    createForm.category === 'GRADE_UNLOCK'
                      ? 'Nhập lý do cụ thể cần mở sổ điểm (Ví dụ: Giảng viên nhập nhầm cột điểm giữa kỳ của học viên, cần chỉnh sửa lại)...'
                      : 'Trình bày rõ ràng lý do, căn cứ, bài thi hoặc câu hỏi cần phúc khảo...'
                  }
                  value={createForm.content}
                  onChange={(e) => setCreateForm({ ...createForm, content: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
                />
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={createForm.ticket_type === 'COMPLAINT' && deadlineCheckResult?.is_expired}
                  className={`px-5 py-2.5 rounded-xl font-bold text-white shadow-xs transition active:scale-95 cursor-pointer ${
                    createForm.ticket_type === 'COMPLAINT' && deadlineCheckResult?.is_expired
                      ? 'bg-slate-300 cursor-not-allowed'
                      : createForm.category === 'GRADE_UNLOCK'
                      ? 'bg-amber-600 hover:bg-amber-700'
                      : 'bg-indigo-600 hover:bg-indigo-700'
                  }`}
                >
                  {createForm.category === 'GRADE_UNLOCK' ? 'Gửi yêu cầu mở sổ điểm' : 'Gửi đơn đi'}
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: CHI TIẾT ĐƠN & THAO TÁC XỬ LÝ ================= */}
      {selectedTicketId && ticketDetail && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200 max-h-[90vh] flex flex-col overflow-hidden">
            
            {/* Modal Header */}
            <div className="flex items-start justify-between pb-3 border-b border-slate-100 shrink-0">
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-mono font-bold text-xs bg-slate-100 px-2.5 py-0.5 rounded-lg text-slate-700">
                    {ticketDetail.ticket_code}
                  </span>
                  {ticketDetail.ticket_type === 'COMPLAINT' ? (
                    <span className="text-[10px] font-black bg-rose-50 text-rose-700 border border-rose-200 px-2 py-0.5 rounded-lg">
                      Khiếu nại điểm
                    </span>
                  ) : ['GRADE_UNLOCK', 'UNLOCK_GRADE'].includes(ticketDetail.category) ? (
                    <span className="text-[10px] font-black bg-amber-50 text-amber-700 border border-amber-200 px-2 py-0.5 rounded-lg">
                      Yêu cầu mở sổ điểm
                    </span>
                  ) : (
                    <span className="text-[10px] font-black bg-indigo-50 text-indigo-700 border border-indigo-200 px-2 py-0.5 rounded-lg">
                      Đơn yêu cầu
                    </span>
                  )}
                  {getStatusBadge(ticketDetail.status)}
                </div>
                <h3 className="text-base font-black text-slate-900 mt-2">{ticketDetail.title}</h3>
                <div className="text-xs text-slate-500 mt-1 flex flex-wrap items-center gap-3">
                  <span>Người gửi: <strong className="text-slate-800">{ticketDetail.sender_name} ({ticketDetail.sender_role})</strong></span>
                  {ticketDetail.class_code && (
                    <span>Lớp: <strong className="text-indigo-600">{ticketDetail.class_code}</strong></span>
                  )}
                </div>
              </div>
              <button
                type="button"
                onClick={() => setSelectedTicketId(null)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer shrink-0"
              >
                ✕
              </button>
            </div>

            {/* Special Highlight: Student Grade Snapshot (For Grade Complaints) */}
            {ticketDetail.current_grade && (
              <div className="mt-3 p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80 shrink-0 text-xs">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-bold text-slate-700 flex items-center gap-1.5">
                    <GraduationCap className="w-4 h-4 text-indigo-600" />
                    <span>Điểm số hiện tại của học viên:</span>
                  </span>
                  <span className="text-[11px] font-semibold text-slate-500">
                    Kết quả: <strong className={ticketDetail.current_grade.result_status === 'PASSED' ? 'text-emerald-600' : 'text-slate-700'}>{ticketDetail.current_grade.result_status || 'Chưa tổng kết'}</strong>
                  </span>
                </div>
                <div className="grid grid-cols-4 gap-2 text-center">
                  <div className="p-2 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 block">Chuyên cần</span>
                    <span className="font-black text-slate-800 text-sm">{ticketDetail.current_grade.attendance_score ?? '-'}</span>
                  </div>
                  <div className="p-2 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 block">Giữa kỳ</span>
                    <span className="font-black text-slate-800 text-sm">{ticketDetail.current_grade.midterm_score ?? '-'}</span>
                  </div>
                  <div className="p-2 rounded-xl bg-white border border-slate-200">
                    <span className="text-[10px] text-slate-400 block">Cuối kỳ</span>
                    <span className="font-black text-slate-800 text-sm">{ticketDetail.current_grade.final_score ?? '-'}</span>
                  </div>
                  <div className="p-2 rounded-xl bg-indigo-50 border border-indigo-200">
                    <span className="text-[10px] text-indigo-600 font-bold block">Tổng kết</span>
                    <span className="font-black text-indigo-900 text-sm">{ticketDetail.current_grade.total_score ?? '-'}</span>
                  </div>
                </div>
              </div>
            )}

            {/* Special Highlight: Teacher Unlock Request Box (For Grade Unlock Requests) */}
            {['GRADE_UNLOCK', 'UNLOCK_GRADE'].includes(ticketDetail.category) && (
              <div className="mt-3 p-3.5 rounded-2xl bg-amber-50/70 border border-amber-200 shrink-0 text-xs">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center font-bold">
                      <Unlock className="w-4 h-4" />
                    </div>
                    <div>
                      <span className="font-black text-amber-900 block">Yêu cầu mở khóa bảng điểm lớp học</span>
                      <span className="text-[11px] text-amber-700">Lớp: {ticketDetail.class_code} {ticketDetail.course_title ? `- ${ticketDetail.course_title}` : ''}</span>
                    </div>
                  </div>
                  <span className="font-mono text-xs font-bold text-amber-800">
                    Sổ điểm: {ticketDetail.is_grade_locked ? 'Đang bị khóa' : 'Đang mở'}
                  </span>
                </div>
              </div>
            )}

            {/* Action Bar based on Role & Ticket State */}
            <div className="mt-3 p-2.5 rounded-2xl bg-slate-50 border border-slate-200/80 flex items-center justify-between shrink-0 text-xs">
              <span className="font-bold text-slate-600">Thao tác xử lý:</span>

              <div className="flex items-center gap-2">
                {/* 1. Academic Staff / Admin: Approve or Reject Grade Unlock Request */}
                {isAdminOrStaff && ['GRADE_UNLOCK', 'UNLOCK_GRADE'].includes(ticketDetail.category) && ticketDetail.status === 'PENDING' && (
                  <>
                    <button
                      type="button"
                      onClick={() => {
                        setApproveNote('');
                        setShowApproveModal(true);
                      }}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs transition cursor-pointer flex items-center gap-1 shadow-xs active:scale-95"
                    >
                      <Check className="w-3.5 h-3.5" />
                      <span>Phê duyệt mở sổ điểm</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setRejectReason('');
                        setShowRejectModal(true);
                      }}
                      className="px-3 py-1.5 bg-rose-600 hover:bg-rose-700 text-white font-bold rounded-xl text-xs transition cursor-pointer flex items-center gap-1 shadow-xs active:scale-95"
                    >
                      <X className="w-3.5 h-3.5" />
                      <span>Từ chối</span>
                    </button>
                  </>
                )}

                {/* 2. Teacher Only: Resolve Student Complaint (Admin & Staff MUST NOT resolve complaints) */}
                {isTeacher && ticketDetail.ticket_type === 'COMPLAINT' && ['PENDING', 'PROCESSING'].includes(ticketDetail.status) && (
                  <>
                    {ticketDetail.status === 'PENDING' && (
                      <button
                        type="button"
                        onClick={() => handleSimpleStatusUpdate('PROCESSING')}
                        className="px-3 py-1.5 bg-blue-50 text-blue-700 border border-blue-200 hover:bg-blue-100 font-bold rounded-xl text-xs transition cursor-pointer active:scale-95"
                      >
                        Tiếp nhận xử lý
                      </button>
                    )}
                    <button
                      type="button"
                      onClick={() => {
                        setResolveNote('');
                        setShowResolveModal(true);
                      }}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs transition cursor-pointer flex items-center gap-1 shadow-xs active:scale-95"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      <span>Giải quyết khiếu nại</span>
                    </button>
                  </>
                )}

                {/* 3. Student: Close their own ticket */}
                {isStudent && ticketDetail.sender_id === user?.id && ticketDetail.status !== 'CLOSED' && (
                  <button
                    type="button"
                    onClick={() => handleSimpleStatusUpdate('CLOSED')}
                    className="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl text-xs transition cursor-pointer active:scale-95"
                  >
                    Đóng khiếu nại
                  </button>
                )}

                {/* Display final status message if resolved/approved/rejected */}
                {ticketDetail.status === 'APPROVED' && (
                  <span className="text-emerald-700 font-bold flex items-center gap-1 text-xs">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600" /> Sổ điểm đã được mở khóa
                  </span>
                )}
                {ticketDetail.status === 'REJECTED' && (
                  <span className="text-rose-700 font-bold flex items-center gap-1 text-xs">
                    <X className="w-4 h-4 text-rose-600" /> Yêu cầu đã bị từ chối
                  </span>
                )}
                {ticketDetail.status === 'RESOLVED' && (
                  <span className="text-teal-700 font-bold flex items-center gap-1 text-xs">
                    <CheckCircle2 className="w-4 h-4 text-teal-600" /> Khiếu nại đã giải quyết
                  </span>
                )}
              </div>
            </div>

            {/* Conversation Messages Thread */}
            <div className="overflow-y-auto flex-1 my-3 pr-1 space-y-3 text-xs">
              {/* Original Content from Sender */}
              <div className="p-4 rounded-2xl bg-indigo-50/50 border border-indigo-100">
                <div className="flex items-center justify-between mb-1.5">
                  <div className="flex items-center gap-2">
                    <UserAvatar name={ticketDetail.sender_name} size="xs" />
                    <span className="font-bold text-slate-900">{ticketDetail.sender_name}</span>
                    <span className="text-[10px] bg-indigo-100 text-indigo-800 px-1.5 py-0.2 rounded font-semibold">
                      {ticketDetail.sender_role}
                    </span>
                  </div>
                  <span className="text-[10px] text-slate-400 font-mono">
                    {new Date(ticketDetail.created_at).toLocaleString('vi-VN')}
                  </span>
                </div>
                <p className="text-slate-800 whitespace-pre-wrap font-medium pl-8">{ticketDetail.content}</p>
              </div>

              {/* Replies Thread */}
              {ticketDetail.messages && ticketDetail.messages.length > 0 && (
                <div className="space-y-2.5 pt-2">
                  <div className="text-[11px] font-black uppercase tracking-wider text-slate-400 px-1">
                    Trao đổi & Phản hồi ({ticketDetail.messages.length})
                  </div>
                  {ticketDetail.messages.map((m) => {
                    const isMyMsg = m.sender_id === user?.id;
                    const isSystemNotice = m.content.startsWith('[HỆ THỐNG]') || m.content.startsWith('[PHÊ DUYỆT]') || m.content.startsWith('[TỪ CHỐI]') || m.content.startsWith('[KẾT QUẢ XỬ LÝ]');

                    return (
                      <div
                        key={m.id}
                        className={`p-3.5 rounded-2xl border ${
                          isSystemNotice
                            ? 'bg-amber-50/70 border-amber-200'
                            : isMyMsg
                            ? 'bg-slate-50 border-slate-200 ml-6'
                            : 'bg-white border-slate-200/90 mr-6 shadow-2xs'
                        }`}
                      >
                        <div className="flex items-center justify-between mb-1">
                          <div className="flex items-center gap-2">
                            <UserAvatar name={m.sender_name} size="xs" />
                            <span className="font-bold text-slate-900">{m.sender_name}</span>
                            <span className="text-[10px] bg-slate-100 text-slate-600 px-1.5 py-0.2 rounded font-semibold">
                              {m.sender_role}
                            </span>
                            {isMyMsg && (
                              <span className="text-[10px] text-indigo-600 font-bold">(Bạn)</span>
                            )}
                          </div>
                          <span className="text-[10px] text-slate-400 font-mono">
                            {new Date(m.created_at).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })} - {new Date(m.created_at).toLocaleDateString('vi-VN')}
                          </span>
                        </div>
                        <p className={`whitespace-pre-wrap font-medium pl-8 ${isSystemNotice ? 'text-amber-900 font-semibold' : 'text-slate-800'}`}>
                          {m.content}
                        </p>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Reply Form */}
            <form onSubmit={handleSendReply} className="pt-3 border-t border-slate-100 shrink-0 space-y-2">
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  required
                  placeholder="Nhập nội dung phản hồi, trao đổi hoặc giải thích..."
                  value={replyContent}
                  onChange={(e) => setReplyContent(e.target.value)}
                  className="flex-1 border border-slate-300 p-2.5 rounded-xl text-xs outline-hidden focus:border-indigo-600 font-medium"
                />
                <button
                  type="submit"
                  disabled={isSubmittingReply || !replyContent.trim()}
                  className="px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 disabled:bg-slate-300 text-white rounded-xl font-bold text-xs shadow-xs transition active:scale-95 cursor-pointer flex items-center gap-1.5 shrink-0"
                >
                  <Send className="w-3.5 h-3.5" />
                  <span>Gửi phản hồi</span>
                </button>
              </div>
            </form>

          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: XÁC NHẬN PHÊ DUYỆT MỞ SỔ ĐIỂM ================= */}
      {showApproveModal && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 text-xs">
            <div className="w-10 h-10 rounded-2xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600 mb-3">
              <Unlock className="w-5 h-5" />
            </div>
            <h3 className="text-base font-black text-slate-900">Phê Duyệt Mở Khóa Sổ Điểm</h3>
            <p className="text-slate-500 mt-1">
              Bạn có chắc chắn muốn phê duyệt yêu cầu này? Sổ điểm của lớp{' '}
              <strong className="text-indigo-600">{ticketDetail?.class_code}</strong> sẽ được mở khóa ngay lập tức để giảng viên nhập và chỉnh sửa điểm.
            </p>

            <div className="mt-4">
              <label className="font-bold text-slate-700 block mb-1">Ghi chú phê duyệt (Tùy chọn):</label>
              <textarea
                rows={3}
                placeholder="Nhập ghi chú hoặc căn cứ phê duyệt..."
                value={approveNote}
                onChange={(e) => setApproveNote(e.target.value)}
                className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-emerald-600 font-medium"
              />
            </div>

            <div className="flex justify-end gap-2.5 mt-5 pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setShowApproveModal(false)}
                className="px-4 py-2 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
              >
                Hủy
              </button>
              <button
                type="button"
                disabled={isProcessingAction}
                onClick={handleApproveUnlock}
                className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer flex items-center gap-1.5"
              >
                <Check className="w-4 h-4" />
                <span>Xác nhận mở sổ điểm</span>
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: TỪ CHỐI YÊU CẦU MỞ SỔ ĐIỂM (BẮT BUỘC LÝ DO) ================= */}
      {showRejectModal && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 text-xs">
            <div className="w-10 h-10 rounded-2xl bg-rose-50 border border-rose-100 flex items-center justify-center text-rose-600 mb-3">
              <X className="w-5 h-5" />
            </div>
            <h3 className="text-base font-black text-slate-900">Từ Chối Yêu Cầu Mở Sổ Điểm</h3>
            <p className="text-slate-500 mt-1">
              Sổ điểm của lớp học sẽ tiếp tục bị khóa. Theo quy định, bạn bắt buộc phải nhập lý do từ chối để thông báo cho giảng viên.
            </p>

            <div className="mt-4">
              <label className="font-bold text-slate-700 block mb-1">
                Lý do từ chối <span className="text-rose-500">*</span>:
              </label>
              <textarea
                rows={3}
                required
                placeholder="Ví dụ: Đã quá thời hạn chỉnh sửa điểm của học kỳ, hoặc lý do yêu cầu chưa hợp lệ..."
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-rose-600 font-medium"
              />
            </div>

            <div className="flex justify-end gap-2.5 mt-5 pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setShowRejectModal(false)}
                className="px-4 py-2 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
              >
                Hủy
              </button>
              <button
                type="button"
                disabled={isProcessingAction || !rejectReason.trim()}
                onClick={handleRejectUnlock}
                className="px-5 py-2 bg-rose-600 hover:bg-rose-700 disabled:bg-slate-300 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer flex items-center gap-1.5"
              >
                <X className="w-4 h-4" />
                <span>Xác nhận từ chối</span>
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: KẾT QUẢ GIẢI QUYẾT KHIẾU NẠI ================= */}
      {showResolveModal && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 text-xs">
            <div className="w-10 h-10 rounded-2xl bg-teal-50 border border-teal-100 flex items-center justify-center text-teal-600 mb-3">
              <CheckCircle2 className="w-5 h-5" />
            </div>
            <h3 className="text-base font-black text-slate-900">Giải Quyết Khiếu Nại Điểm</h3>
            <p className="text-slate-500 mt-1">
              Ghi nhận kết quả xử lý và kết luận khiếu nại cho học viên{' '}
              <strong className="text-slate-800">{ticketDetail?.sender_name}</strong>.
            </p>

            <div className="mt-4">
              <label className="font-bold text-slate-700 block mb-1">Kết luận / Giải thích kết quả xử lý:</label>
              <textarea
                rows={3}
                placeholder="Ví dụ: Đã kiểm tra lại bài thi cuối kỳ, phát hiện chấm sót câu 4. Điểm cuối kỳ được cập nhật từ 6.5 lên 7.5..."
                value={resolveNote}
                onChange={(e) => setResolveNote(e.target.value)}
                className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-teal-600 font-medium"
              />
            </div>

            <div className="flex justify-end gap-2.5 mt-5 pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setShowResolveModal(false)}
                className="px-4 py-2 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
              >
                Hủy
              </button>
              <button
                type="button"
                disabled={isProcessingAction}
                onClick={handleResolveComplaint}
                className="px-5 py-2 bg-teal-600 hover:bg-teal-700 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer flex items-center gap-1.5"
              >
                <CheckCircle2 className="w-4 h-4" />
                <span>Hoàn tất giải quyết</span>
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

    </div>
  );
};
