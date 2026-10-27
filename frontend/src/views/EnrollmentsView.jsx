import React, { useEffect, useState, useMemo } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { useConfirm } from '../context/ConfirmDialogContext';
import { enrollmentsApi, classesApi } from '../services/api';
import { UserAvatar } from '../components/common/UserAvatar';
import {
  CheckCircle2,
  XCircle,
  Clock,
  Send,
  Ban,
  Trash2,
  AlertCircle,
  Search,
  School,
  UserCheck,
  Sparkles,
  Calendar,
  X,
  FileCheck2
} from 'lucide-react';

export const EnrollmentsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const confirm = useConfirm();
  const isStudent = user?.role === 'STUDENT';
  const isStaffOrAdmin = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [openClasses, setOpenClasses] = useState([]);
  const [requests, setRequests] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedClassToRegister, setSelectedClassToRegister] = useState(null);
  const [registerNote, setRegisterNote] = useState('');
  const [rejectingRequestId, setRejectingRequestId] = useState(null);
  const [rejectionReason, setRejectionReason] = useState('');
  const [filterStatus, setFilterStatus] = useState('ALL');

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
        const resReq = await enrollmentsApi.listAll(
          filterStatus === 'ALL' ? undefined : filterStatus
        );
        setRequests(resReq.data || []);
      }
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    loadData();
  }, [filterStatus, user?.role]);

  const handleRegister = async (e) => {
    e.preventDefault();
    if (!selectedClassToRegister) return;
    try {
      await enrollmentsApi.createRequest(selectedClassToRegister.id, registerNote);
      toast.success('Đã gửi yêu cầu chuyển khóa học thành công! Vui lòng chờ Admin hoặc Học vụ phê duyệt.');
      setSelectedClassToRegister(null);
      setRegisterNote('');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleApprove = async (id) => {
    const isConfirmed = await confirm({
      title: 'Phê duyệt chuyển khóa học',
      message: 'Xác nhận duyệt yêu cầu đăng ký này và ghi danh học viên vào lớp học?',
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
      title: 'Hủy đơn đăng ký lớp',
      message: 'Bạn có chắc chắn muốn hủy đơn đăng ký lớp học này không? Sau khi hủy, yêu cầu sẽ được chuyển sang trạng thái HỦY BỎ.',
      confirmText: 'Xác nhận hủy',
      cancelText: 'Giữ lại đơn',
      type: 'warning',
    });
    if (!isConfirmed) return;
    try {
      await enrollmentsApi.cancelRequest(id);
      toast.success('Đã hủy yêu cầu đăng ký lớp học thành công!');
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
      toast.info('Đã từ chối đơn đăng ký và gửi thông báo phản hồi.');
      setRejectingRequestId(null);
      setRejectionReason('');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // KPI Calculations
  const stats = useMemo(() => {
    const total = requests.length;
    const pending = requests.filter((r) => r.status === 'PENDING').length;
    const approved = requests.filter((r) => r.status === 'APPROVED').length;
    const rejectedOrCancelled = requests.filter((r) => ['REJECTED', 'CANCELLED'].includes(r.status)).length;
    return { total, pending, approved, rejectedOrCancelled };
  }, [requests]);

  // Filtered requests by search
  const filteredRequests = useMemo(() => {
    return requests.filter((r) => {
      const matchSearch =
        r.student_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.student_code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.class_code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.course_title?.toLowerCase().includes(searchTerm.toLowerCase());
      return matchSearch;
    });
  }, [requests, searchTerm]);

  return (
    <div className="space-y-6">
      


      {/* KPI Metric Overview */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng số đơn</span>
            <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <Send className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">Đơn ghi danh ghi nhận</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-amber-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Chờ xét duyệt</span>
            <div className="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
              <Clock className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-amber-600 tabular-nums">{stats.pending}</div>
          <div className="text-[11px] text-amber-700/80 mt-1 font-medium">Cần học vụ xử lý</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-emerald-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đã phê duyệt</span>
            <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <CheckCircle2 className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-emerald-600 tabular-nums">{stats.approved}</div>
          <div className="text-[11px] text-emerald-700/80 mt-1 font-medium">Đã vào danh sách lớp</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-rose-200 hover:-translate-y-0.5 transition-all">
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

      {/* Student: Open Classes to Register */}
      {isStudent && (
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

      {/* Filter and Search Bar for Requests */}
      <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
        
        {/* Search Input */}
        <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
          <Search className="w-4 h-4 text-slate-400 shrink-0" />
          <input
            type="text"
            placeholder="Tìm theo tên học viên, mã HV (HV-...), mã lớp hoặc khóa học..."
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
        {isStaffOrAdmin && (
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
        )}
      </div>

      {/* Requests Table */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
              <tr>
                <th className="p-4 pl-5">Mã đơn</th>
                <th className="p-4">Học viên</th>
                <th className="p-4">Lớp đăng ký</th>
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
                    Không tìm thấy yêu cầu đăng ký nào trong danh sách.
                  </td>
                </tr>
              ) : (
                filteredRequests.map((r) => (
                  <tr key={r.id} className="hover:bg-slate-50/70 transition-colors">
                    {/* Order ID */}
                    <td className="p-4 pl-5 font-mono font-bold text-slate-500">
                      #{r.id}
                    </td>

                    {/* Student */}
                    <td className="p-4">
                      <div className="flex items-center gap-2.5">
                        <UserAvatar name={r.student_name} role="STUDENT" size="xs" shape="rounded-lg" />
                        <div>
                          <div className="font-bold text-slate-900">{r.student_name}</div>
                          <div className="font-mono text-[10px] text-indigo-600 font-bold">{r.student_code}</div>
                        </div>
                      </div>
                    </td>

                    {/* Class */}
                    <td className="p-4">
                      <div className="font-mono font-bold text-indigo-700 bg-indigo-50 border border-indigo-200/60 px-2 py-0.5 rounded-lg inline-block text-[11px]">
                        {r.class_code}
                      </div>
                      <div className="text-[11px] text-slate-500 font-medium mt-0.5">{r.course_title}</div>
                    </td>

                    {/* Date */}
                    <td className="p-4 text-slate-500 tabular-nums font-medium">
                      {new Date(r.request_date).toLocaleDateString('vi-VN')}
                    </td>

                    {/* Status */}
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

                    {/* Note / Rejection Reason */}
                    <td className="p-4 text-slate-600 max-w-[200px]">
                      {r.rejection_reason ? (
                        <div className="text-rose-600 text-[11px] font-semibold bg-rose-50 border border-rose-100 p-2 rounded-xl">
                          Lý do: {r.rejection_reason}
                        </div>
                      ) : (
                        <span className="text-slate-500 text-[11px] font-medium">{r.note || '--'}</span>
                      )}
                    </td>

                    {/* Actions */}
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
                                Duyệt đơn
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
                              title="Hủy đơn đăng ký lớp này (khi đang chờ duyệt)"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                              <span>Hủy đăng ký</span>
                            </button>
                          ) : r.status === 'APPROVED' ? (
                            <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-1 rounded-xl">
                              Đã vào lớp
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

      {/* ================= MODAL: XÁC NHẬN ĐĂNG KÝ HỌC VIÊN ================= */}
      {selectedClassToRegister && createPortal(
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
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleRegister} className="space-y-4 text-xs">
              <div className="bg-indigo-50/60 p-3.5 rounded-2xl border border-indigo-100 text-indigo-900 space-y-1.5">
                <div className="font-bold">Khóa đào tạo đích: {selectedClassToRegister.course_title}</div>
                <div className="text-[11px] text-indigo-700">Mục tiêu đầu ra: {selectedClassToRegister.target_level}</div>
                <div className="text-[11px] text-slate-500">Giáo viên: {selectedClassToRegister.teacher_name || 'Đang phân công'}</div>
                <div className="text-[11px] text-amber-900 bg-amber-50/80 p-2.5 rounded-xl border border-amber-200 mt-2">
                  <span className="font-bold block">Điều kiện chuyển khóa:</span>
                  <span>Học viên gửi yêu cầu lên khóa cao hơn. Hệ thống kiểm tra điều kiện chuẩn đầu ra và Ban Quản trị / Nhân viên học vụ sẽ xét duyệt.</span>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">
                  Ghi chú gửi Phòng Học vụ (tùy chọn):
                </label>
                <textarea
                  rows={3}
                  placeholder="Ví dụ: Đã nộp học phí qua chuyển khoản ngân hàng ngày..."
                  value={registerNote}
                  onChange={(e) => setRegisterNote(e.target.value)}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 text-xs font-medium"
                />
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setSelectedClassToRegister(null)}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-bold shadow-xs cursor-pointer flex items-center gap-1.5 active:scale-95"
                >
                  <Send className="w-3.5 h-3.5" />
                  <span>Gửi Yêu Cầu Chuyển Khóa</span>
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: TỪ CHỐI ĐƠN ĐĂNG KÝ ================= */}
      {rejectingRequestId && createPortal(
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-rose-50 border border-rose-100 flex items-center justify-center text-rose-600">
                  <Ban className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">
                    Từ chối đơn #{rejectingRequestId}
                  </h3>
                  <span className="text-xs text-slate-400">Yêu cầu ghi rõ lý do gửi phản hồi</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setRejectingRequestId(null)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleReject} className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Lý do từ chối đơn:</label>
                <textarea
                  rows={3}
                  required
                  placeholder="Ví dụ: Học viên chưa hoàn thành học phí hoặc chưa đạt điều kiện khóa tiên quyết..."
                  value={rejectionReason}
                  onChange={(e) => setRejectionReason(e.target.value)}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-rose-600 text-xs font-medium"
                />
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setRejectingRequestId(null)}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-rose-600 hover:bg-rose-700 text-white rounded-xl font-bold shadow-xs cursor-pointer active:scale-95"
                >
                  Xác nhận Từ Chối
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
