import React, { useEffect, useState, useMemo } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { classroomsApi } from '../services/api';
import {
  Wrench,
  CheckCircle,
  Plus,
  Edit2,
  Trash2,
  Building2,
  MapPin,
  Users,
  Search,
  CheckCircle2,
  Sparkles,
  X,
  Layers
} from 'lucide-react';

export const ClassroomsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Add Room Modal
  const [showAddModal, setShowAddModal] = useState(false);
  const [newRoom, setNewRoom] = useState({
    room_code: '',
    building: 'Tòa nhà A',
    capacity: 30,
    status: 'AVAILABLE',
  });

  // Edit Room Modal
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingRoom, setEditingRoom] = useState(null);
  const [editRoomForm, setEditRoomForm] = useState({
    building: '',
    capacity: 30,
    status: 'AVAILABLE',
  });

  const loadRooms = async () => {
    setLoading(true);
    try {
      const res = await classroomsApi.list();
      setRooms(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách phòng học: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRooms();
  }, []);

  const handleToggleStatus = async (room) => {
    const nextStatus = room.status === 'AVAILABLE' ? 'MAINTENANCE' : 'AVAILABLE';
    try {
      await classroomsApi.updateStatus(room.id, nextStatus);
      toast.success(
        nextStatus === 'MAINTENANCE'
          ? `Phòng ${room.room_code} đã chuyển sang chế độ bảo trì.`
          : `Phòng ${room.room_code} đã sẵn sàng sử dụng.`
      );
      loadRooms();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleCreateRoom = async (e) => {
    e.preventDefault();
    if (!newRoom.room_code.trim()) {
      toast.warning('Vui lòng nhập mã phòng học.');
      return;
    }
    try {
      await classroomsApi.create({
        room_code: newRoom.room_code.trim().toUpperCase(),
        building: newRoom.building.trim(),
        capacity: Number(newRoom.capacity),
        status: newRoom.status,
      });
      toast.success('Thêm phòng học mới thành công!');
      setShowAddModal(false);
      setNewRoom({
        room_code: '',
        building: 'Tòa nhà A',
        capacity: 30,
        status: 'AVAILABLE',
      });
      loadRooms();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleOpenEdit = (room) => {
    setEditingRoom(room);
    setEditRoomForm({
      building: room.building,
      capacity: room.capacity,
      status: room.status,
    });
    setShowEditModal(true);
  };

  const handleUpdateRoom = async (e) => {
    e.preventDefault();
    try {
      await classroomsApi.update(editingRoom.id, {
        building: editRoomForm.building.trim(),
        capacity: Number(editRoomForm.capacity),
        status: editRoomForm.status,
      });
      toast.success(`Cập nhật phòng học ${editingRoom.room_code} thành công!`);
      setShowEditModal(false);
      setEditingRoom(null);
      loadRooms();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleDeleteRoom = async (roomId, roomCode) => {
    if (!window.confirm(`Bạn có chắc chắn muốn XÓA vĩnh viễn phòng học "${roomCode}"?`)) return;
    try {
      await classroomsApi.delete(roomId);
      toast.success(`Đã xóa phòng học ${roomCode} thành công!`);
      loadRooms();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // KPI Metrics
  const stats = useMemo(() => {
    const total = rooms.length;
    const available = rooms.filter((r) => r.status === 'AVAILABLE').length;
    const maintenance = rooms.filter((r) => r.status === 'MAINTENANCE').length;
    const totalCapacity = rooms.reduce((acc, r) => acc + (r.capacity || 0), 0);
    return { total, available, maintenance, totalCapacity };
  }, [rooms]);

  // Filtered rooms
  const filteredRooms = useMemo(() => {
    return rooms.filter((r) => {
      const matchSearch =
        r.room_code?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.building?.toLowerCase().includes(searchTerm.toLowerCase());
      if (!matchSearch) return false;
      if (statusFilter === 'AVAILABLE') return r.status === 'AVAILABLE';
      if (statusFilter === 'MAINTENANCE') return r.status === 'MAINTENANCE';
      return true;
    });
  }, [rooms, searchTerm, statusFilter]);

  return (
    <div className="space-y-6">
      
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600 shadow-2xs">
              <Building2 className="w-5 h-5" />
            </div>
            <span>Phòng Học & Cơ Sở Vật Chất</span>
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Theo dõi danh sách phòng học, sức chứa tối đa và cập nhật trạng thái bảo trì phục vụ xếp lịch giảng dạy.
          </p>
        </div>

        {canManage && (
          <button
            type="button"
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 active:scale-95 text-white px-4 py-2.5 rounded-2xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer shrink-0"
          >
            <Plus className="w-4 h-4" />
            <span>Thêm phòng học mới</span>
          </button>
        )}
      </div>

      {/* KPI Metric Overview */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng phòng học</span>
            <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <Building2 className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">Cơ sở trung tâm</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-emerald-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đang sẵn sàng</span>
            <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <CheckCircle className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-emerald-600 tabular-nums">{stats.available}</div>
          <div className="text-[11px] text-emerald-700/80 mt-1 font-medium">Có thể xếp lịch</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-amber-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đang bảo trì</span>
            <div className="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
              <Wrench className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-amber-600 tabular-nums">{stats.maintenance}</div>
          <div className="text-[11px] text-amber-700/80 mt-1 font-medium">Tạm ngưng xếp lịch</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-sky-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng sức chứa</span>
            <div className="w-8 h-8 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center">
              <Users className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.totalCapacity} chỗ</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">Ghế ngồi phục vụ</div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
        
        {/* Search */}
        <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
          <Search className="w-4 h-4 text-slate-400 shrink-0" />
          <input
            type="text"
            placeholder="Tìm kiếm phòng học theo mã phòng (P.101, P.202) hoặc tòa nhà..."
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

        {/* Filter Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 shrink-0">
          {[
            { id: 'ALL', label: 'Tất cả' },
            { id: 'AVAILABLE', label: 'Sẵn sàng' },
            { id: 'MAINTENANCE', label: 'Bảo trì' },
          ].map((st) => {
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

          <span className="text-[11px] font-bold text-slate-500 bg-slate-100 border border-slate-200/60 px-3 py-1.5 rounded-xl ml-1">
            {filteredRooms.length} phòng
          </span>
        </div>

      </div>

      {/* Classrooms Grid Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {filteredRooms.length === 0 ? (
          <div className="col-span-full py-16 text-center text-slate-400 bg-white rounded-3xl border border-slate-200/90 shadow-2xs">
            <Building2 className="w-10 h-10 mx-auto mb-3 text-slate-300" />
            <h4 className="text-sm font-bold text-slate-700">Không tìm thấy phòng học phù hợp</h4>
            <p className="text-xs text-slate-400 mt-1">Vui lòng điều chỉnh lại từ khóa hoặc bộ lọc trạng thái.</p>
          </div>
        ) : (
          filteredRooms.map((r) => {
            const isAvail = r.status === 'AVAILABLE';
            return (
              <div
                key={r.id}
                className={`bg-white rounded-3xl border p-5 shadow-2xs flex flex-col justify-between transition-all duration-200 hover:shadow-md hover:border-indigo-200 ${
                  !isAvail ? 'border-amber-200/80 bg-amber-50/20' : 'border-slate-200/90'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <span className="font-mono text-base font-black text-indigo-700 bg-indigo-50 border border-indigo-200/60 px-2.5 py-0.5 rounded-xl shadow-2xs">
                      {r.room_code}
                    </span>
                    <span
                      className={`inline-flex items-center gap-1.5 text-[10px] font-bold px-2.5 py-0.5 rounded-full border ${
                        isAvail
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                          : 'bg-amber-50 text-amber-800 border-amber-200/80'
                      }`}
                    >
                      <span className={`w-1.5 h-1.5 rounded-full ${isAvail ? 'bg-emerald-500' : 'bg-amber-500'}`} />
                      {isAvail ? 'Sẵn sàng' : 'Bảo trì'}
                    </span>
                  </div>

                  <p className="text-xs text-slate-500 font-semibold flex items-center gap-1.5">
                    <MapPin className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                    <span>{r.building}</span>
                  </p>

                  <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                    <span className="text-slate-500 font-medium flex items-center gap-1.5">
                      <Users className="w-3.5 h-3.5 text-slate-400" /> Sức chứa:
                    </span>
                    <span className="font-black text-slate-900 tabular-nums bg-slate-100 px-2.5 py-0.5 rounded-lg">
                      {r.capacity} chỗ ngồi
                    </span>
                  </div>
                </div>

                {canManage && (
                  <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between gap-2">
                    <button
                      type="button"
                      onClick={() => handleToggleStatus(r)}
                      className={`text-xs font-bold px-3 py-1.5 rounded-xl transition cursor-pointer flex items-center gap-1.5 shadow-2xs active:scale-95 ${
                        isAvail
                          ? 'bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-200/60'
                          : 'bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200/60'
                      }`}
                    >
                      {isAvail ? (
                        <>
                          <Wrench className="w-3.5 h-3.5 text-amber-600" />
                          <span>Bảo trì</span>
                        </>
                      ) : (
                        <>
                          <CheckCircle className="w-3.5 h-3.5 text-emerald-600" />
                          <span>Mở lại</span>
                        </>
                      )}
                    </button>

                    <div className="flex items-center gap-1">
                      <button
                        type="button"
                        onClick={() => handleOpenEdit(r)}
                        className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer"
                        title="Sửa phòng học"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDeleteRoom(r.id, r.room_code)}
                        className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition cursor-pointer"
                        title="Xóa phòng học"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>

      {/* ================= MODAL: THÊM PHÒNG HỌC ================= */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Plus className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">Thêm Phòng Học Mới</h3>
                  <span className="text-xs text-slate-400">Khởi tạo phòng và thiết lập sức chứa</span>
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

            <form onSubmit={handleCreateRoom} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mã phòng học (Room Code):</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: P.101, P.204, LAB-01..."
                  value={newRoom.room_code}
                  onChange={(e) => setNewRoom({ ...newRoom, room_code: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-mono font-bold outline-hidden focus:border-indigo-600 uppercase text-xs"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Tòa nhà / Cơ sở:</label>
                <input
                  type="text"
                  required
                  value={newRoom.building}
                  onChange={(e) => setNewRoom({ ...newRoom, building: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600 text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa tối đa (ghế):</label>
                  <input
                    type="number"
                    min="1"
                    max="500"
                    required
                    value={newRoom.capacity}
                    onChange={(e) => setNewRoom({ ...newRoom, capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-bold outline-hidden focus:border-indigo-600 tabular-nums text-xs"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Trạng thái khởi tạo:</label>
                  <select
                    value={newRoom.status}
                    onChange={(e) => setNewRoom({ ...newRoom, status: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600 text-xs"
                  >
                    <option value="AVAILABLE">Sẵn sàng sử dụng</option>
                    <option value="MAINTENANCE">Đang bảo trì</option>
                  </select>
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
                  Thêm Phòng Học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ================= MODAL: SỬA PHÒNG HỌC ================= */}
      {showEditModal && editingRoom && (
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Edit2 className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">
                    Cập nhật Phòng: {editingRoom.room_code}
                  </h3>
                  <span className="text-xs text-slate-400">Điều chỉnh cơ sở và sức chứa</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => {
                  setShowEditModal(false);
                  setEditingRoom(null);
                }}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleUpdateRoom} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tòa nhà / Cơ sở:</label>
                <input
                  type="text"
                  required
                  value={editRoomForm.building}
                  onChange={(e) => setEditRoomForm({ ...editRoomForm, building: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600 text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa (ghế):</label>
                  <input
                    type="number"
                    min="1"
                    max="500"
                    required
                    value={editRoomForm.capacity}
                    onChange={(e) => setEditRoomForm({ ...editRoomForm, capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-bold outline-hidden focus:border-indigo-600 tabular-nums text-xs"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Trạng thái:</label>
                  <select
                    value={editRoomForm.status}
                    onChange={(e) => setEditRoomForm({ ...editRoomForm, status: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600 text-xs"
                  >
                    <option value="AVAILABLE">Sẵn sàng sử dụng</option>
                    <option value="MAINTENANCE">Đang bảo trì</option>
                  </select>
                </div>
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => {
                    setShowEditModal(false);
                    setEditingRoom(null);
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
        </div>
      )}

    </div>
  );
};
