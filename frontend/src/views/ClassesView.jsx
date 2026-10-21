import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { classesApi, teachersApi, coursesApi } from '../services/api';
import { Users, Search, School, UserCheck, Plus, Edit2, Trash2 } from 'lucide-react';

export const ClassesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

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
    start_date: '',
    end_date: '',
  });

  // Edit Class Modal
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingClass, setEditingClass] = useState(null);
  const [editForm, setEditForm] = useState({
    teacher_id: '',
    max_capacity: 25,
    start_date: '',
    end_date: '',
    status: 'OPEN_FOR_ENROLLMENT',
  });

  const loadData = async () => {
    try {
      const [resCls, resTea, resCou] = await Promise.all([
        classesApi.list(searchTerm, statusFilter || undefined),
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

  const handleCreateClass = async (e) => {
    e.preventDefault();
    if (!newClass.class_code || !newClass.course_id) {
      toast.warning('Vui lòng nhập đầy đủ mã lớp và chọn khóa học.');
      return;
    }
    try {
      await classesApi.create({
        class_code: newClass.class_code.trim().toUpperCase(),
        course_id: Number(newClass.course_id),
        teacher_id: newClass.teacher_id ? Number(newClass.teacher_id) : null,
        max_capacity: Number(newClass.max_capacity) || 25,
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
        start_date: '',
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
      start_date: cls.start_date || '',
      end_date: cls.end_date || '',
      status: cls.status,
    });
    setShowEditModal(true);
  };

  const handleUpdateClass = async (e) => {
    e.preventDefault();
    try {
      await classesApi.update(editingClass.id, {
        teacher_id: editForm.teacher_id ? Number(editForm.teacher_id) : null,
        max_capacity: Number(editForm.max_capacity),
        start_date: editForm.start_date || null,
        end_date: editForm.end_date || null,
        status: editForm.status,
      });
      toast.success('Đã cập nhật thông tin lớp học thành công!');
      setShowEditModal(false);
      setEditingClass(null);
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleDeleteClass = async (classId, classCode) => {
    if (!window.confirm(`Bạn có chắc chắn muốn XÓA vĩnh viễn lớp học "${classCode}"? Tất cả lịch học liên quan sẽ bị ảnh hưởng.`)) {
      return;
    }
    try {
      await classesApi.delete(classId);
      toast.success(`Đã xóa lớp học ${classCode} thành công!`);
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleAssignTeacher = async (classId, teacherId) => {
    try {
      await classesApi.assignTeacher(classId, teacherId);
      toast.success('Đã phân công giáo viên phụ trách lớp!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleUpdateStatus = async (classId, newStatus) => {
    try {
      await classesApi.updateStatus(classId, newStatus);
      toast.success('Đã cập nhật trạng thái lớp học!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleOpenRoster = async (cls) => {
    setSelectedClassRoster({ id: cls.id, code: cls.class_code });
    try {
      const res = await classesApi.getRoster(cls.id);
      setRosterStudents(res.data || []);
    } catch (e) {
      toast.error(e.message);
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
            <School className="w-5 h-5 text-indigo-600" />
            Lớp học & Quản lý Sĩ số
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Theo dõi sức chứa tối đa, sĩ số hiện tại, phân công giáo viên và quản lý danh sách học viên trong từng lớp.
          </p>
        </div>

        {canManage && (
          <button
            onClick={() => {
              if (courses.length > 0 && !newClass.course_id) {
                setNewClass(prev => ({ ...prev, course_id: courses[0].id }));
              }
              setShowAddModal(true);
            }}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white px-4 py-2.5 rounded-xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer"
          >
            <Plus className="w-4 h-4" /> Thêm lớp học mới
          </button>
        )}
      </div>

      {/* Search and Filters Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col sm:flex-row items-center justify-between gap-3">
        <div className="flex items-center gap-2.5 flex-1 w-full sm:w-auto">
          <Search className="w-4 h-4 text-slate-400 shrink-0 ml-1" />
          <input
            type="text"
            placeholder="Tìm kiếm theo mã lớp học..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs outline-hidden text-slate-800 placeholder:text-slate-400"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto justify-end">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-700 bg-white font-medium outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
          >
            <option value="">-- Tất cả trạng thái --</option>
            <option value="OPEN_FOR_ENROLLMENT">Đang mở đăng ký</option>
            <option value="IN_PROGRESS">Đang giảng dạy</option>
            <option value="COMPLETED">Đã hoàn thành</option>
            <option value="CANCELLED">Đã hủy</option>
          </select>

          <span className="text-[11px] font-bold text-slate-500 bg-slate-100 px-2.5 py-1.5 rounded-xl shrink-0">
            {classes.length} lớp học
          </span>
        </div>
      </div>

      {/* Classes Table */}
      <div className="bg-white rounded-2xl border border-slate-200/90 overflow-hidden shadow-2xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase tracking-wider text-[11px]">
              <tr>
                <th className="p-4">Mã lớp</th>
                <th className="p-4">Khóa học / Cấp độ</th>
                <th className="p-4">Tình trạng Sĩ số</th>
                <th className="p-4">Giáo viên phụ trách</th>
                <th className="p-4">Trạng thái lớp</th>
                <th className="p-4 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {classes.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-slate-400 font-medium">
                    Không tìm thấy lớp học nào.
                  </td>
                </tr>
              ) : (
                classes.map((cls) => {
                  const percentage = Math.min(
                    100,
                    Math.round((cls.current_enrolled / cls.max_capacity) * 100)
                  );
                  return (
                    <tr key={cls.id} className="hover:bg-slate-50/80 transition-colors">
                      <td className="p-4 font-mono font-bold text-indigo-700 text-xs">
                        {cls.class_code}
                      </td>
                      <td className="p-4">
                        <div className="font-bold text-slate-900">{cls.course_title}</div>
                        <span className="inline-block text-[10px] bg-indigo-50 text-indigo-700 font-semibold px-2 py-0.5 rounded mt-0.5 border border-indigo-100/60">
                          {cls.target_level}
                        </span>
                      </td>
                      <td className="p-4 min-w-[180px]">
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
                                : 'bg-indigo-600'
                            }`}
                            style={{ width: `${percentage}%` }}
                          />
                        </div>
                      </td>
                      <td className="p-4">
                        {canManage ? (
                          <select
                            value={cls.teacher_id || 0}
                            onChange={(e) => handleAssignTeacher(cls.id, Number(e.target.value))}
                            className="border border-slate-200 rounded-xl px-2.5 py-1.5 text-xs text-slate-800 bg-white font-medium outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
                          >
                            <option value={0}>-- Chưa phân công --</option>
                            {teachers.map((t) => (
                              <option key={t.id} value={t.id}>
                                {t.full_name} ({t.specialty})
                              </option>
                            ))}
                          </select>
                        ) : (
                          <div className="flex items-center gap-1.5 font-semibold text-slate-700">
                            <UserCheck className="w-3.5 h-3.5 text-indigo-500" />
                            <span>{cls.teacher_name || 'Chưa phân công'}</span>
                          </div>
                        )}
                      </td>
                      <td className="p-4">
                        {canManage ? (
                          <select
                            value={cls.status}
                            onChange={(e) => handleUpdateStatus(cls.id, e.target.value)}
                            className="border border-slate-200 rounded-xl px-2.5 py-1.5 text-xs text-slate-800 bg-white font-semibold outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
                          >
                            <option value="OPEN_FOR_ENROLLMENT">Đang mở đăng ký</option>
                            <option value="IN_PROGRESS">Đang giảng dạy</option>
                            <option value="COMPLETED">Đã hoàn thành</option>
                            <option value="CANCELLED">Đã hủy</option>
                          </select>
                        ) : (
                          <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-slate-100 text-slate-700 border border-slate-200/60">
                            {cls.status}
                          </span>
                        )}
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <button
                            onClick={() => handleOpenRoster(cls)}
                            className="inline-flex items-center gap-1.5 bg-slate-100 hover:bg-indigo-50 text-slate-700 hover:text-indigo-700 font-bold px-3 py-1.5 rounded-xl transition cursor-pointer border border-slate-200/60 hover:border-indigo-200"
                            title="Xem danh sách học viên"
                          >
                            <Users className="w-3.5 h-3.5" /> DS Lớp
                          </button>

                          {canManage && (
                            <>
                              <button
                                onClick={() => handleOpenEdit(cls)}
                                className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer border border-transparent hover:border-indigo-100"
                                title="Sửa thông tin lớp học"
                              >
                                <Edit2 className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleDeleteClass(cls.id, cls.class_code)}
                                className="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition cursor-pointer border border-transparent hover:border-rose-100"
                                title="Xóa lớp học"
                              >
                                <Trash2 className="w-4 h-4" />
                              </button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: Thêm lớp học mới */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-lg font-black text-slate-900">
                Thêm Lớp học mới
              </h3>
              <button
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
                  placeholder="Ví dụ: IELTS-65-02"
                  value={newClass.class_code}
                  onChange={(e) => setNewClass({ ...newClass, class_code: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-mono font-medium outline-hidden focus:border-indigo-600 uppercase"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Khóa học đào tạo:</label>
                <select
                  required
                  value={newClass.course_id}
                  onChange={(e) => setNewClass({ ...newClass, course_id: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                >
                  <option value="">-- Chọn khóa học --</option>
                  {courses.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.code} - {c.title} ({c.target_level})
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giáo viên phụ trách:</label>
                  <select
                    value={newClass.teacher_id}
                    onChange={(e) => setNewClass({ ...newClass, teacher_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    <option value="">-- Chưa phân công --</option>
                    {teachers.map((t) => (
                      <option key={t.id} value={t.id}>
                        {t.full_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa tối đa (HV):</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={newClass.max_capacity}
                    onChange={(e) => setNewClass({ ...newClass, max_capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600 tabular-nums"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Ngày bắt đầu:</label>
                  <input
                    type="date"
                    value={newClass.start_date}
                    onChange={(e) => setNewClass({ ...newClass, start_date: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Ngày kết thúc:</label>
                  <input
                    type="date"
                    value={newClass.end_date}
                    onChange={(e) => setNewClass({ ...newClass, end_date: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
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
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Tạo lớp học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Sửa lớp học */}
      {showEditModal && editingClass && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div>
                <h3 className="text-lg font-black text-slate-900">
                  Cập nhật Lớp học: {editingClass.class_code}
                </h3>
                <span className="text-xs text-slate-400 font-medium">{editingClass.course_title}</span>
              </div>
              <button
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
                  <label className="font-bold text-slate-700 block mb-1">Giáo viên phụ trách:</label>
                  <select
                    value={editForm.teacher_id}
                    onChange={(e) => setEditForm({ ...editForm, teacher_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    <option value="">-- Chưa phân công --</option>
                    {teachers.map((t) => (
                      <option key={t.id} value={t.id}>
                        {t.full_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Sức chứa tối đa (HV):</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={editForm.max_capacity}
                    onChange={(e) => setEditForm({ ...editForm, max_capacity: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600 tabular-nums"
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
                  <option value="OPEN_FOR_ENROLLMENT">Đang mở đăng ký (OPEN_FOR_ENROLLMENT)</option>
                  <option value="IN_PROGRESS">Đang giảng dạy (IN_PROGRESS)</option>
                  <option value="COMPLETED">Đã hoàn thành (COMPLETED)</option>
                  <option value="CANCELLED">Đã hủy (CANCELLED)</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Ngày bắt đầu:</label>
                  <input
                    type="date"
                    value={editForm.start_date}
                    onChange={(e) => setEditForm({ ...editForm, start_date: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Ngày kết thúc:</label>
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
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Lưu thay đổi
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Class Roster Modal */}
      {selectedClassRoster && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
                  <Users className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-extrabold text-slate-900 leading-tight">
                    Danh sách học viên lớp {selectedClassRoster.code}
                  </h3>
                  <span className="text-xs text-slate-400 font-medium">Hồ sơ học viên đã được phê duyệt tham gia</span>
                </div>
              </div>
              <button
                onClick={() => setSelectedClassRoster(null)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer transition"
              >
                ✕
              </button>
            </div>

            <div className="mt-4 max-h-80 overflow-y-auto">
              {rosterStudents.length === 0 ? (
                <p className="text-xs text-slate-500 py-8 text-center font-medium">
                  Lớp học này hiện chưa có học viên nào đăng ký tham gia.
                </p>
              ) : (
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 text-slate-500 font-bold border-b border-slate-100 text-[11px] uppercase">
                    <tr>
                      <th className="p-3">Mã HV</th>
                      <th className="p-3">Họ và tên</th>
                      <th className="p-3">Email liên hệ</th>
                      <th className="p-3 text-right">Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {rosterStudents.map((st, i) => (
                      <tr key={i} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-3 font-mono font-bold text-slate-700">{st.student_code}</td>
                        <td className="p-3 font-bold text-slate-900">{st.full_name}</td>
                        <td className="p-3 text-slate-500 font-medium">{st.email}</td>
                        <td className="p-3 text-right">
                          <span className="text-[10px] bg-emerald-50 text-emerald-700 border border-emerald-200/80 px-2.5 py-0.5 rounded-full font-bold">
                            {st.status}
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
                onClick={() => setSelectedClassRoster(null)}
                className="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl font-bold text-xs cursor-pointer transition"
              >
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
