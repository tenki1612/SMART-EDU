import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { classroomsApi } from '../services/api';
import { Wrench, CheckCircle, Plus, Edit2, Trash2, Building2, MapPin, Users } from 'lucide-react';

export const ClassroomsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(false);

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

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
            <Building2 className="w-5 h-5 text-indigo-600" />
            Quản lý Phòng học & Sức chứa
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Theo dõi danh sách phòng học, sức chứa tối đa và cập nhật trạng thái bảo trì phục vụ xếp lịch giảng dạy.
          </p>
        </div>

        {canManage && (
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white px-4 py-2.5 rounded-xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer"
          >
            <Plus className="w-4 h-4" /> Thêm phòng học mới
          </button>
        )}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {rooms.map((r) => (
          <div
            key={r.id}
            className={`bg-white rounded-2xl border p-5 shadow-2xs flex flex-col justify-between transition-all card-hover ${
              r.status === 'MAINTENANCE' ? 'border-amber-200 bg-amber-50/20' : 'border-slate-200/90'
            }`}
          >
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="font-mono text-base font-bold text-indigo-700">{r.room_code}</span>
                <span
                  className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
                    r.status === 'AVAILABLE'
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                      : 'bg-amber-50 text-amber-800 border-amber-200'
                  }`}
                >
                  {r.status === 'AVAILABLE' ? 'Đang sử dụng' : 'Bảo trì'}
                </span>
              </div>
              <p className="text-xs text-slate-500 font-medium flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-slate-400" /> {r.building}
              </p>

              <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                <span className="text-slate-500 font-medium flex items-center gap-1">
                  <Users className="w-3.5 h-3.5 text-slate-400" /> Sức chứa:
                </span>
                <span className="font-bold text-slate-800 tabular-nums">
                  {r.capacity} chỗ ngồi
                </span>
              </div>
            </div>

            {canManage && (
              <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between">
                <button
                  onClick={() => handleToggleStatus(r)}
                  className={`text-xs font-bold px-2.5 py-1 rounded-lg transition cursor-pointer flex items-center gap-1 ${
                    r.status === 'AVAILABLE'
                      ? 'bg-amber-50 hover:bg-amber-100 text-amber-700'
                      : 'bg-emerald-50 hover:bg-emerald-100 text-emerald-700'
                  }`}
                >
                  {r.status === 'AVAILABLE' ? (
                    <>
                      <Wrench className="w-3 h-3" /> Bảo trì
                    </>
                  ) : (
                    <>
                      <CheckCircle className="w-3 h-3" /> Mở lại
                    </>
                  )}
                </button>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleOpenEdit(r)}
                    className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition cursor-pointer"
                    title="Sửa phòng học"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteRoom(r.id, r.room_code)}
                    className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition cursor-pointer"
                    title="Xóa phòng học"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Modal: Thêm phòng học */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-lg font-black text-slate-900">
                Thêm Phòng học mới
              </h3>
              <button
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
                  placeholder="Ví dụ: LAB-101 hoặc P.204"
                  value={newRoom.room_code}
                  onChange={(e) => setNewRoom({ ...newRoom, room_code: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-mono font-medium outline-hidden focus:border-indigo-600 uppercase"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Tòa nhà / Cơ sở:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: Tòa nhà A, Tầng 2"
                  value={newRoom.building}
                  onChange={(e) => setNewRoom({ ...newRoom, building: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa (Chỗ ngồi):</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={newRoom.capacity}
                    onChange={(e) => setNewRoom({ ...newRoom, capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600 tabular-nums"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Trạng thái:</label>
                  <select
                    value={newRoom.status}
                    onChange={(e) => setNewRoom({ ...newRoom, status: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-semibold outline-hidden focus:border-indigo-600"
                  >
                    <option value="AVAILABLE">Sẵn sàng (AVAILABLE)</option>
                    <option value="MAINTENANCE">Bảo trì (MAINTENANCE)</option>
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
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Tạo phòng học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Sửa phòng học */}
      {showEditModal && editingRoom && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-lg font-black text-slate-900">
                Cập nhật Phòng học: {editingRoom.room_code}
              </h3>
              <button
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
                <label className="font-bold text-slate-700 block mb-1">Tòa nhà / Khu vực:</label>
                <input
                  type="text"
                  required
                  value={editRoomForm.building}
                  onChange={(e) => setEditRoomForm({ ...editRoomForm, building: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa (Chỗ ngồi):</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={editRoomForm.capacity}
                    onChange={(e) => setEditRoomForm({ ...editRoomForm, capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600 tabular-nums"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Trạng thái phòng:</label>
                  <select
                    value={editRoomForm.status}
                    onChange={(e) => setEditRoomForm({ ...editRoomForm, status: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-semibold outline-hidden focus:border-indigo-600"
                  >
                    <option value="AVAILABLE">Sẵn sàng (AVAILABLE)</option>
                    <option value="MAINTENANCE">Bảo trì (MAINTENANCE)</option>
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
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Lưu thay đổi
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
