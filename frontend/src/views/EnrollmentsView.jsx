import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { enrollmentsApi, classesApi } from '../services/api';
import { CheckCircle2, XCircle, Clock, Send, Ban, Trash2, AlertCircle } from 'lucide-react';

export const EnrollmentsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const isStudent = user?.role === 'STUDENT';
  const isStaffOrAdmin = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [openClasses, setOpenClasses] = useState([]);
  const [requests, setRequests] = useState([]);
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
      toast.success('Đã gửi yêu cầu đăng ký lớp học thành công!');
      setSelectedClassToRegister(null);
      setRegisterNote('');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleApprove = async (id) => {
    if (!window.confirm('Xác nhận duyệt yêu cầu đăng ký này và thêm học viên vào lớp?')) return;
    try {
      await enrollmentsApi.approve(id);
      toast.success('Đã duyệt đơn và thêm học viên vào lớp!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleCancelRequest = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn hủy đơn đăng ký lớp học này không?')) return;
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
      toast.info('Đã từ chối đơn đăng ký và lưu lý do.');
      setRejectingRequestId(null);
      setRejectionReason('');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-bold text-slate-800">
          08. Đăng ký & Xét duyệt lớp học (FR-50 đến FR-60)
        </h2>
        <p className="text-xs text-slate-500 mt-0.5">
          Quy trình tiếp nhận đơn đăng ký, kiểm tra điều kiện, xét duyệt và tự động cập nhật sĩ số lớp.
        </p>
      </div>

      {/* Student: Open Classes to Register */}
      {isStudent && (
        <div className="space-y-4">
          <h3 className="text-sm font-bold text-slate-700 uppercase tracking-wider">
            Các lớp học đang mở đăng ký (FR-50, FR-51)
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {openClasses.map((cls) => (
              <div
                key={cls.id}
                className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-mono text-xs font-bold bg-indigo-50 text-indigo-700 px-2 py-0.5 rounded">
                      {cls.class_code}
                    </span>
                    <span className="text-xs text-slate-500 font-semibold">
                      Sĩ số: {cls.current_enrolled}/{cls.max_capacity}
                    </span>
                  </div>
                  <h4 className="font-bold text-slate-800 text-sm">{cls.course_title}</h4>
                  <p className="text-xs text-indigo-600 font-semibold mt-1">
                    Chuẩn đầu ra: {cls.target_level}
                  </p>
                </div>
                <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between">
                  <span className="text-xs text-slate-500">
                    GV: {cls.teacher_name || 'Đang cập nhật'}
                  </span>
                  <button
                    disabled={cls.is_full}
                    onClick={() => setSelectedClassToRegister(cls)}
                    className={`px-3 py-1.5 rounded-xl text-xs font-semibold shadow-xs transition cursor-pointer ${
                      cls.is_full
                        ? 'bg-slate-100 text-slate-400 cursor-not-allowed'
                        : 'bg-indigo-600 hover:bg-indigo-700 text-white'
                    }`}
                  >
                    {cls.is_full ? 'Hết chỗ' : 'Đăng ký ngay (FR-52)'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Requests Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-4 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-slate-50/50">
          <div>
            <h3 className="font-bold text-sm text-slate-800">
              {isStudent ? 'Danh sách yêu cầu đăng ký của tôi (FR-53)' : 'Quản lý duyệt đơn đăng ký'}
            </h3>
            <span className="text-[11px] text-slate-400">
              Tổng số: {requests.length} đơn đăng ký
            </span>
          </div>

          {isStaffOrAdmin && (
            <div className="flex items-center gap-2">
              <span className="text-xs font-semibold text-slate-600">Lọc theo:</span>
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="text-xs font-semibold border border-slate-300 rounded-lg px-2.5 py-1.5 bg-white outline-hidden cursor-pointer"
              >
                <option value="ALL">-- Tất cả trạng thái --</option>
                <option value="PENDING">Chờ duyệt (PENDING)</option>
                <option value="APPROVED">Đã phê duyệt (APPROVED)</option>
                <option value="REJECTED">Bị từ chối (REJECTED)</option>
                <option value="CANCELLED">Đã hủy (CANCELLED)</option>
              </select>
            </div>
          )}
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 border-b border-slate-200 font-semibold text-slate-600 uppercase">
              <tr>
                <th className="p-4">Mã đơn</th>
                <th className="p-4">Học viên</th>
                <th className="p-4">Lớp đăng ký</th>
                <th className="p-4">Ngày yêu cầu</th>
                <th className="p-4">Trạng thái</th>
                <th className="p-4">Ghi chú / Lý do</th>
                <th className="p-4 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {requests.length === 0 ? (
                <tr>
                  <td colSpan={7} className="p-6 text-center text-slate-400">
                    Không có yêu cầu đăng ký nào trong danh sách.
                  </td>
                </tr>
              ) : (
                requests.map((r) => (
                  <tr key={r.id} className="hover:bg-slate-50/80 transition">
                    <td className="p-4 font-mono font-bold text-slate-600">#{r.id}</td>
                    <td className="p-4">
                      <div className="font-bold text-slate-800">{r.student_name}</div>
                      <div className="font-mono text-[10px] text-slate-500">{r.student_code}</div>
                    </td>
                    <td className="p-4">
                      <div className="font-semibold text-indigo-700 font-mono">{r.class_code}</div>
                      <div className="text-[11px] text-slate-600">{r.course_title}</div>
                    </td>
                    <td className="p-4 text-slate-500">
                      {new Date(r.request_date).toLocaleDateString('vi-VN')}
                    </td>
                    <td className="p-4">
                      <span
                        className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full font-bold text-[10px] ${
                          r.status === 'APPROVED'
                            ? 'bg-emerald-100 text-emerald-800'
                            : r.status === 'REJECTED'
                            ? 'bg-red-100 text-red-800'
                            : r.status === 'CANCELLED'
                            ? 'bg-slate-100 text-slate-600'
                            : 'bg-amber-100 text-amber-800'
                        }`}
                      >
                        {r.status === 'APPROVED' ? (
                          <CheckCircle2 className="w-3 h-3" />
                        ) : r.status === 'REJECTED' ? (
                          <XCircle className="w-3 h-3" />
                        ) : (
                          <Clock className="w-3 h-3" />
                        )}
                        {r.status === 'APPROVED'
                          ? 'Đã duyệt (APPROVED)'
                          : r.status === 'REJECTED'
                          ? 'Bị từ chối'
                          : r.status === 'CANCELLED'
                          ? 'Đã hủy (CANCELLED)'
                          : 'Chờ duyệt (PENDING)'}
                      </span>
                    </td>
                    <td className="p-4 text-slate-600 max-w-[200px]">
                      {r.rejection_reason ? (
                        <span className="text-red-600 font-medium">
                          Lý do từ chối: {r.rejection_reason}
                        </span>
                      ) : (
                        r.note || '--'
                      )}
                    </td>
                    <td className="p-4 text-right">
                      {isStaffOrAdmin && (
                        <div className="space-x-2 inline-flex items-center justify-end">
                          {r.status === 'PENDING' ? (
                            <>
                              <button
                                type="button"
                                onClick={() => handleApprove(r.id)}
                                className="px-2.5 py-1 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-lg shadow-xs cursor-pointer"
                              >
                                Duyệt (FR-57)
                              </button>
                              <button
                                type="button"
                                onClick={() => setRejectingRequestId(r.id)}
                                className="px-2.5 py-1 bg-red-100 hover:bg-red-200 text-red-700 font-semibold rounded-lg cursor-pointer"
                              >
                                Từ chối (FR-58)
                              </button>
                            </>
                          ) : (
                            <span className="text-slate-400 font-medium">Đã xử lý</span>
                          )}
                        </div>
                      )}
                      {isStudent && (
                        <div className="flex justify-end">
                          {r.status === 'PENDING' ? (
                            <button
                              type="button"
                              onClick={() => handleCancelRequest(r.id)}
                              className="inline-flex items-center gap-1.5 px-3 py-1 bg-rose-50 hover:bg-rose-100 text-rose-700 font-bold border border-rose-200 rounded-lg cursor-pointer transition text-xs shadow-2xs"
                              title="Hủy đơn đăng ký lớp này (khi đang chờ duyệt)"
                            >
                              <Trash2 className="w-3.5 h-3.5" /> Hủy đăng ký
                            </button>
                          ) : r.status === 'APPROVED' ? (
                            <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 px-2.5 py-1 rounded-lg">
                              Đã duyệt &bull; Không thể hủy
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

      {/* Registration Modal for Student */}
      {selectedClassToRegister && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-200">
            <h3 className="text-base font-bold text-slate-800 mb-2">
              Xác nhận đăng ký lớp {selectedClassToRegister.class_code}
            </h3>
            <p className="text-xs text-slate-500 mb-4">
              Khóa học: {selectedClassToRegister.course_title} ({selectedClassToRegister.target_level})
            </p>
            <form onSubmit={handleRegister} className="space-y-4 text-xs">
              <div>
                <label className="font-semibold text-slate-700 block mb-1">
                  Ghi chú cho Học vụ (tùy chọn):
                </label>
                <textarea
                  rows={3}
                  placeholder="Ví dụ: Đã đóng học phí chuyển khoản..."
                  value={registerNote}
                  onChange={(e) => setRegisterNote(e.target.value)}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600"
                />
              </div>
              <div className="flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setSelectedClassToRegister(null)}
                  className="px-4 py-2 border border-slate-300 rounded-xl font-semibold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 shadow-xs cursor-pointer flex items-center gap-1.5"
                >
                  <Send className="w-3.5 h-3.5" /> Gửi đơn đăng ký
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Rejection Modal for Staff */}
      {rejectingRequestId && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-slate-200">
            <h3 className="text-base font-bold text-slate-800 mb-2 flex items-center gap-2 text-red-600">
              <Ban className="w-4 h-4" /> Từ chối yêu cầu đăng ký #{rejectingRequestId}
            </h3>
            <p className="text-xs text-slate-500 mb-4">
              Theo quy định FR-58, nhân viên học vụ bắt buộc phải ghi rõ lý do từ chối để thông báo lại cho học viên.
            </p>
            <form onSubmit={handleReject} className="space-y-4 text-xs">
              <div>
                <label className="font-semibold text-slate-700 block mb-1">Lý do từ chối:</label>
                <textarea
                  rows={3}
                  required
                  placeholder="Ví dụ: Học viên chưa hoàn thành học phí hoặc chưa đạt điều kiện đầu vào..."
                  value={rejectionReason}
                  onChange={(e) => setRejectionReason(e.target.value)}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-red-600"
                />
              </div>
              <div className="flex justify-end gap-2">
                <button
                  type="button"
                  onClick={() => setRejectingRequestId(null)}
                  className="px-4 py-2 border border-slate-300 rounded-xl font-semibold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-red-600 text-white rounded-xl font-semibold hover:bg-red-700 shadow-xs cursor-pointer"
                >
                  Xác nhận từ chối
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
