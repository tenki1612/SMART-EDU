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
  HelpCircle,
  AlertCircle,
  Calendar,
  School,
  User,
  ShieldCheck,
  GraduationCap,
  Sparkles,
  ArrowRight,
  RotateCcw
} from 'lucide-react';

export const TicketsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const headerSlot = useHeaderSlot();

  const userRole = user?.role || 'STUDENT';
  const isAdminOrStaff = ['ADMIN', 'ACADEMIC_STAFF'].includes(userRole);

  const [activeTab, setActiveTab] = useState('inbox'); // 'inbox' | 'sent'
  const [inboxTickets, setInboxTickets] = useState([]);
  const [sentTickets, setSentTickets] = useState([]);
  const [loading, setLoading] = useState(false);

  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('ALL'); // 'ALL' | 'COMPLAINT' | 'REQUEST'
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Classes & teachers list for creating ticket
  const [classesList, setClassesList] = useState([]);
  const [teachersList, setTeachersList] = useState([]);

  // Create Ticket Modal
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createForm, setCreateForm] = useState({
    ticket_type: 'REQUEST',
    receiver_role: 'ACADEMIC_STAFF',
    receiver_id: '',
    category: 'OTHER',
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

  const loadData = async () => {
    setLoading(true);
    try {
      const [resInbox, resSent] = await Promise.all([
        ticketsApi.listInbox().catch(() => ({ data: [] })),
        ticketsApi.listSent().catch(() => ({ data: [] })),
      ]);
      setInboxTickets(resInbox.data || []);
      setSentTickets(resSent.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách đơn: ' + e.message);
    } finally {
      setLoading(false);
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
    loadMetadata();
  }, []);

  // When selecting class in Create Modal, check deadline if ticket_type is COMPLAINT
  const handleClassChangeInCreate = async (classId) => {
    setCreateForm((prev) => ({ ...prev, related_class_id: classId }));
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

  const handleTypeChangeInCreate = async (newType) => {
    setCreateForm((prev) => ({ ...prev, ticket_type: newType }));
    if (newType === 'COMPLAINT' && createForm.related_class_id) {
      setIsCheckingDeadline(true);
      try {
        const res = await ticketsApi.checkDeadline(createForm.related_class_id);
        setDeadlineCheckResult(res.data);
      } catch (e) {
        setDeadlineCheckResult(null);
      } finally {
        setIsCheckingDeadline(false);
      }
    } else {
      setDeadlineCheckResult(null);
    }
  };

  const handleCreateTicketSubmit = async (e) => {
    e.preventDefault();
    if (!createForm.title.trim() || !createForm.content.trim()) {
      toast.warning('Vui lòng nhập đầy đủ tiêu đề và nội dung đơn.');
      return;
    }
    if (createForm.ticket_type === 'COMPLAINT' && deadlineCheckResult?.is_expired) {
      toast.error('Không thể gửi khiếu nại do đã quá thời hạn cho phép đối với lớp học này.');
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
        createForm.ticket_type === 'COMPLAINT'
          ? 'Đã gửi Đơn khiếu nại thành công!'
          : 'Đã gửi Đơn yêu cầu thành công!'
      );
      setShowCreateModal(false);
      setCreateForm({
        ticket_type: 'REQUEST',
        receiver_role: 'ACADEMIC_STAFF',
        receiver_id: '',
        category: 'OTHER',
        related_class_id: '',
        title: '',
        content: ''
      });
      setDeadlineCheckResult(null);
      setActiveTab('sent');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Open detail modal
  const handleOpenDetail = async (ticketId) => {
    setSelectedTicketId(ticketId);
    setReplyContent('');
    try {
      const res = await ticketsApi.getDetail(ticketId);
      setTicketDetail(res.data);
    } catch (e) {
      toast.error('Lỗi tải chi tiết đơn: ' + e.message);
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
    } catch (e) {
      toast.error(e.message);
    } finally {
      setIsSubmittingReply(false);
    }
  };

  const handleUpdateStatus = async (newStatus) => {
    try {
      await ticketsApi.updateStatus(selectedTicketId, newStatus);
      toast.success(`Đã cập nhật trạng thái đơn thành ${newStatus}`);
      const res = await ticketsApi.getDetail(selectedTicketId);
      setTicketDetail(res.data);
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Filtered lists
  const currentList = activeTab === 'inbox' ? inboxTickets : sentTickets;
  const filteredList = useMemo(() => {
    return currentList.filter((item) => {
      if (typeFilter !== 'ALL' && item.ticket_type !== typeFilter) return false;
      if (statusFilter !== 'ALL' && item.status !== statusFilter) return false;
      if (searchTerm.trim()) {
        const term = searchTerm.toLowerCase();
        const matchCode = item.ticket_code?.toLowerCase().includes(term);
        const matchTitle = item.title?.toLowerCase().includes(term);
        const matchSender = item.sender_name?.toLowerCase().includes(term);
        const matchClass = item.class_code?.toLowerCase().includes(term);
        if (!matchCode && !matchTitle && !matchSender && !matchClass) return false;
      }
      return true;
    });
  }, [currentList, typeFilter, statusFilter, searchTerm]);

  // Statistics
  const stats = useMemo(() => {
    const all = [...inboxTickets, ...sentTickets];
    // Distinct by ID
    const uniqueMap = new Map();
    all.forEach(t => uniqueMap.set(t.id, t));
    const unique = Array.from(uniqueMap.values());
    return {
      total: unique.length,
      pending: unique.filter(t => t.status === 'PENDING').length,
      processing: unique.filter(t => t.status === 'PROCESSING').length,
      resolved: unique.filter(t => ['RESOLVED', 'CLOSED'].includes(t.status)).length,
      complaints: unique.filter(t => t.ticket_type === 'COMPLAINT').length,
    };
  }, [inboxTickets, sentTickets]);

  const getStatusBadge = (status) => {
    switch (status) {
      case 'PENDING':
        return <span className="inline-flex items-center gap-1 text-[11px] font-bold text-amber-700 bg-amber-50 border border-amber-200/80 px-2.5 py-1 rounded-xl"><Clock className="w-3 h-3 text-amber-600" /> Chờ xử lý</span>;
      case 'PROCESSING':
        return <span className="inline-flex items-center gap-1 text-[11px] font-bold text-blue-700 bg-blue-50 border border-blue-200/80 px-2.5 py-1 rounded-xl"><RotateCcw className="w-3 h-3 text-blue-600" /> Đang xử lý</span>;
      case 'RESOLVED':
        return <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200/80 px-2.5 py-1 rounded-xl"><CheckCircle2 className="w-3 h-3 text-emerald-600" /> Đã giải quyết</span>;
      case 'CLOSED':
        return <span className="inline-flex items-center gap-1 text-[11px] font-bold text-slate-600 bg-slate-100 border border-slate-200 px-2.5 py-1 rounded-xl">Đã đóng</span>;
      default:
        return <span className="text-[11px] font-medium text-slate-500">{status}</span>;
    }
  };

  const getCategoryLabel = (cat) => {
    switch (cat) {
      case 'GRADE': return 'Điểm số / Đánh giá';
      case 'SCHEDULE': return 'Lịch học / Phòng học';
      case 'ENROLLMENT': return 'Đăng ký / Tuyển sinh';
      default: return 'Ý kiến / Khác';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Slot: Button Tạo đơn mới */}
      {headerSlot && createPortal(
        <button
          type="button"
          onClick={() => {
            setCreateForm({
              ticket_type: 'REQUEST',
              receiver_role: 'ACADEMIC_STAFF',
              receiver_id: '',
              category: 'OTHER',
              related_class_id: '',
              title: '',
              content: ''
            });
            setDeadlineCheckResult(null);
            setShowCreateModal(true);
          }}
          className="flex items-center gap-1.5 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-indigo-200 transition cursor-pointer active:scale-95"
        >
          <Plus className="w-4 h-4" />
          <span>Tạo đơn mới</span>
        </button>,
        headerSlot
      )}

      {/* KPI Overview */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider block">Hộp thư đơn từ</span>
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

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-blue-600 uppercase tracking-wider block">Đang trao đổi</span>
            <span className="text-2xl font-black text-blue-700 mt-0.5 block tabular-nums">{stats.processing}</span>
          </div>
          <div className="w-10 h-10 rounded-xl bg-blue-50 border border-blue-200/60 flex items-center justify-center text-blue-600">
            <Send className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-[11px] font-bold text-emerald-600 uppercase tracking-wider block">Đã giải quyết</span>
            <span className="text-2xl font-black text-emerald-700 mt-0.5 block tabular-nums">{stats.resolved}</span>
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
              onClick={() => setActiveTab('inbox')}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
                activeTab === 'inbox'
                  ? 'bg-white text-indigo-700 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Inbox className="w-3.5 h-3.5" />
              <span>Hộp thư đến</span>
              <span className="text-[10px] font-mono px-1.5 py-0.2 rounded-full bg-slate-100 text-slate-700">
                {inboxTickets.length}
              </span>
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('sent')}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
                activeTab === 'sent'
                  ? 'bg-white text-indigo-700 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Send className="w-3.5 h-3.5" />
              <span>Đơn đã gửi</span>
              <span className="text-[10px] font-mono px-1.5 py-0.2 rounded-full bg-slate-100 text-slate-700">
                {sentTickets.length}
              </span>
            </button>
          </div>

          {/* Type Filter pills */}
          <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
            {[
              { id: 'ALL', label: 'Tất cả loại' },
              { id: 'COMPLAINT', label: 'Đơn khiếu nại' },
              { id: 'REQUEST', label: 'Đơn yêu cầu' },
            ].map((t) => (
              <button
                key={t.id}
                type="button"
                onClick={() => setTypeFilter(t.id)}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition cursor-pointer border ${
                  typeFilter === t.id
                    ? 'bg-indigo-50 text-indigo-700 border-indigo-200'
                    : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
                }`}
              >
                {t.label}
              </button>
            ))}
          </div>
        </div>

        {/* Search & Status Filters */}
        <div className="flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3 pt-2 border-t border-slate-100">
          <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
            <Search className="w-4 h-4 text-slate-400 shrink-0" />
            <input
              type="text"
              placeholder="Tìm theo mã đơn (KN-..., YC-...), tiêu đề, người gửi hoặc mã lớp..."
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

          <div className="flex items-center gap-2 shrink-0">
            <span className="text-xs font-bold text-slate-500">Trạng thái:</span>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-800 bg-white font-bold outline-hidden cursor-pointer"
            >
              <option value="ALL">Tất cả trạng thái</option>
              <option value="PENDING">Chờ tiếp nhận (PENDING)</option>
              <option value="PROCESSING">Đang xử lý (PROCESSING)</option>
              <option value="RESOLVED">Đã giải quyết (RESOLVED)</option>
              <option value="CLOSED">Đã đóng (CLOSED)</option>
            </select>
          </div>
        </div>
      </div>

      {/* Tickets Table */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase text-[11px] tracking-wider">
              <tr>
                <th className="p-4 pl-5">Mã & Loại đơn</th>
                <th className="p-4">Tiêu đề & Nội dung</th>
                <th className="p-4">Lĩnh vực & Lớp</th>
                <th className="p-4">{activeTab === 'inbox' ? 'Người gửi' : 'Người/Vai trò nhận'}</th>
                <th className="p-4 text-center">Trạng thái</th>
                <th className="p-4 pr-5 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredList.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center text-slate-400 font-medium">
                    <MessageSquare className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                    {activeTab === 'inbox'
                      ? 'Hộp thư đến của bạn hiện chưa có đơn nào.'
                      : 'Bạn chưa gửi đơn khiếu nại hay yêu cầu nào.'}
                  </td>
                </tr>
              ) : (
                filteredList.map((t) => (
                  <tr key={t.id} className="hover:bg-slate-50/70 transition-colors">
                    {/* Code & Type */}
                    <td className="p-4 pl-5 align-top">
                      <div className="font-mono font-bold text-slate-900 text-xs">{t.ticket_code}</div>
                      <div className="mt-1">
                        {t.ticket_type === 'COMPLAINT' ? (
                          <span className="inline-block px-2 py-0.5 rounded-md text-[10px] font-black bg-rose-50 text-rose-700 border border-rose-200/70">
                            Khiếu nại
                          </span>
                        ) : (
                          <span className="inline-block px-2 py-0.5 rounded-md text-[10px] font-black bg-indigo-50 text-indigo-700 border border-indigo-200/70">
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
                          <MessageSquare className="w-3 h-3" /> {t.messages_count} phản hồi
                        </span>
                      )}
                    </td>

                    {/* Category & Class */}
                    <td className="p-4 align-top">
                      <span className="text-xs font-semibold text-slate-700 block">
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
                          <span className="text-[10px] font-medium text-slate-400 block">
                            Vai trò: {t.sender_role}
                          </span>
                        </div>
                      ) : (
                        <div>
                          <div className="font-bold text-slate-800 text-xs">
                            {t.receiver_name || `Bộ phận: ${t.receiver_role || 'Trung tâm'}`}
                          </div>
                          {t.receiver_role && (
                            <span className="text-[10px] font-medium text-slate-400 block">
                              Vai trò: {t.receiver_role}
                            </span>
                          )}
                        </div>
                      )}
                    </td>

                    {/* Status */}
                    <td className="p-4 align-top text-center">
                      {getStatusBadge(t.status)}
                    </td>

                    {/* Action */}
                    <td className="p-4 pr-5 align-top text-right">
                      <button
                        type="button"
                        onClick={() => handleOpenDetail(t.id)}
                        className="px-3 py-1.5 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold rounded-xl text-xs transition cursor-pointer active:scale-95 inline-flex items-center gap-1"
                      >
                        <span>Xem & Phản hồi</span>
                        <ArrowRight className="w-3 h-3" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
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
                  <h3 className="text-base font-black text-slate-900">Tạo Đơn Khiếu Nại / Yêu Cầu</h3>
                  <span className="text-xs text-slate-400">Giao tiếp nội bộ giữa các vai trò trong hệ thống</span>
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
              {/* Type Selection */}
              <div>
                <label className="font-bold text-slate-700 block mb-1">Loại đơn gửi đi:</label>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => handleTypeChangeInCreate('REQUEST')}
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
                    <p className="text-[11px] text-slate-500 mt-1">
                      Yêu cầu hỗ trợ, điều chỉnh lịch, mở khóa điểm, chuyển lớp... Không giới hạn thời hạn gửi.
                    </p>
                  </button>

                  <button
                    type="button"
                    onClick={() => handleTypeChangeInCreate('COMPLAINT')}
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
                    <p className="text-[11px] text-slate-500 mt-1">
                      Khiếu nại về điểm số, giảng viên... Chỉ gửi được trong thời hạn quy định (7 ngày sau kết thúc lớp).
                    </p>
                  </button>
                </div>
              </div>

              {/* Category & Related Class */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Lĩnh vực:</label>
                  <select
                    value={createForm.category}
                    onChange={(e) => setCreateForm({ ...createForm, category: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600"
                  >
                    <option value="GRADE">Điểm số / Đánh giá</option>
                    <option value="SCHEDULE">Lịch học / Thời khóa biểu</option>
                    <option value="ENROLLMENT">Đăng ký lớp / Khóa học</option>
                    <option value="OTHER">Vấn đề khác</option>
                  </select>
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Lớp học liên quan (nếu có):</label>
                  <select
                    value={createForm.related_class_id}
                    onChange={(e) => handleClassChangeInCreate(e.target.value)}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    <option value="">-- Không liên quan lớp cụ thể --</option>
                    {classesList.map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.class_code} - {c.course_title} (KT: {c.end_date || 'Chưa xếp'})
                      </option>
                    ))}
                  </select>
                </div>
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
                        Hệ thống từ chối tiếp nhận khiếu nại mới vì đã quá thời hạn quy định.
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Receiver selection */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Gửi đến bộ phận / vai trò:</label>
                  <select
                    value={createForm.receiver_role}
                    onChange={(e) => setCreateForm({ ...createForm, receiver_role: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600"
                  >
                    <option value="ACADEMIC_STAFF">Phòng Học vụ (Academic Staff)</option>
                    <option value="ADMIN">Ban Quản trị (Admin)</option>
                    <option value="TEACHER">Giáo viên phụ trách (Teacher)</option>
                    <option value="STUDENT">Học viên (Student)</option>
                  </select>
                </div>

                <div>
                  <label className="font-bold text-slate-700 block mb-1">Người nhận đích danh (Tùy chọn):</label>
                  <select
                    value={createForm.receiver_id}
                    onChange={(e) => setCreateForm({ ...createForm, receiver_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    <option value="">-- Mọi người trong vai trò này --</option>
                    {createForm.receiver_role === 'TEACHER' && teachersList.map((t) => (
                      <option key={t.user_id || t.id} value={t.user_id}>
                        {t.full_name} ({t.specialty})
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Title & Content */}
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tiêu đề đơn:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: Đề nghị xem xét phúc khảo điểm thi cuối kỳ, Yêu cầu đổi lịch học..."
                  value={createForm.title}
                  onChange={(e) => setCreateForm({ ...createForm, title: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-bold outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Nội dung chi tiết:</label>
                <textarea
                  rows={4}
                  required
                  placeholder="Trình bày rõ ràng lý do, căn cứ, nội dung khiếu nại hoặc nội dung cần hỗ trợ..."
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
                      : 'bg-indigo-600 hover:bg-indigo-700'
                  }`}
                >
                  Gửi đơn đi
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: CHI TIẾT & TRAO ĐỔI / PHẢN HỒI ================= */}
      {selectedTicketId && ticketDetail && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200 max-h-[88vh] flex flex-col overflow-hidden">
            
            {/* Modal Header */}
            <div className="flex items-start justify-between pb-3 border-b border-slate-100 shrink-0">
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-mono font-bold text-xs bg-slate-100 px-2.5 py-0.5 rounded-lg text-slate-700">
                    {ticketDetail.ticket_code}
                  </span>
                  {ticketDetail.ticket_type === 'COMPLAINT' ? (
                    <span className="text-[10px] font-black bg-rose-50 text-rose-700 border border-rose-200 px-2 py-0.5 rounded-lg">
                      Đơn khiếu nại
                    </span>
                  ) : (
                    <span className="text-[10px] font-black bg-indigo-50 text-indigo-700 border border-indigo-200 px-2 py-0.5 rounded-lg">
                      Đơn yêu cầu
                    </span>
                  )}
                  {getStatusBadge(ticketDetail.status)}
                </div>
                <h3 className="text-base font-black text-slate-900 mt-2">{ticketDetail.title}</h3>
                <div className="text-xs text-slate-400 mt-0.5 flex items-center gap-3">
                  <span>Người gửi: <strong className="text-slate-700">{ticketDetail.sender_name} ({ticketDetail.sender_role})</strong></span>
                  {ticketDetail.class_code && <span>Lớp: <strong className="text-indigo-600">{ticketDetail.class_code}</strong></span>}
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

            {/* Status Transition Toolbar (For Receiver, Staff, Admin) */}
            <div className="bg-slate-50 p-2.5 rounded-2xl border border-slate-100 mt-3 flex items-center justify-between text-xs shrink-0">
              <span className="font-bold text-slate-600">Cập nhật tiến độ xử lý:</span>
              <div className="flex items-center gap-1.5">
                {['PROCESSING', 'RESOLVED', 'CLOSED'].map((st) => (
                  <button
                    key={st}
                    type="button"
                    disabled={ticketDetail.status === st}
                    onClick={() => handleUpdateStatus(st)}
                    className={`px-2.5 py-1 rounded-xl text-[11px] font-bold transition cursor-pointer border ${
                      ticketDetail.status === st
                        ? 'bg-slate-200 text-slate-400 border-slate-300 cursor-not-allowed'
                        : st === 'RESOLVED'
                        ? 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                        : st === 'PROCESSING'
                        ? 'bg-blue-50 text-blue-700 border-blue-200 hover:bg-blue-100'
                        : 'bg-slate-100 text-slate-700 border-slate-200 hover:bg-slate-200'
                    }`}
                  >
                    {st === 'PROCESSING' ? 'Đang xử lý' : st === 'RESOLVED' ? 'Đã giải quyết' : 'Đóng đơn'}
                  </button>
                ))}
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
                    return (
                      <div
                        key={m.id}
                        className={`p-3.5 rounded-2xl border ${
                          isMyMsg
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
                        <p className="text-slate-800 whitespace-pre-wrap font-medium pl-8">{m.content}</p>
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
                  placeholder="Nhập nội dung phản hồi trao đổi..."
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

    </div>
  );
};
