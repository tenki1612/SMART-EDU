import React, { useEffect, useState, useMemo } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
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
  ArrowRight
} from 'lucide-react';

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
        max_capacity: Number(editForm.max_capacity) || 25,
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
    if (!window.confirm(`Bạn có chắc chắn muốn XÓA vĩnh viễn lớp học ${code}?`)) return;
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
    try {
      const res = await classesApi.getRoster(cls.id);
      setRosterStudents(res.data || []);
      setSelectedClassRoster({ id: cls.id, code: cls.class_code });
    } catch (e) {
      toast.error('Lỗi khi tải danh sách học viên: ' + e.message);
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
      case 'OPEN_FOR_ENROLLMENT':
        return { label: 'Đang mở đăng ký', bg: 'bg-emerald-50 text-emerald-700 border-emerald-200/80', dot: 'bg-emerald-500' };
      case 'IN_PROGRESS':
        return { label: 'Đang giảng dạy', bg: 'bg-sky-50 text-sky-700 border-sky-200/80', dot: 'bg-sky-500' };
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
      
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600 shadow-2xs">
              <School className="w-5 h-5" />
            </div>
            <span>Lớp Học & Quản Lý Sĩ Số</span>
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Theo dõi sức chứa sĩ số, số hiện có, phân công giảng viên và trạng thái tuyển sinh lớp học.
          </p>
        </div>

        {canManage && (
          <button
            type="button"
            onClick={() => {
              if (courses.length > 0) {
                setNewClass((prev) => ({ ...prev, course_id: courses[0].id }));
              }
              setShowAddModal(true);
            }}
            className="flex items-center gap-2 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 active:scale-95 text-white px-4 py-2.5 rounded-2xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer shrink-0"
          >
            <Plus className="w-4 h-4" />
            <span>Thêm lớp học mới</span>
          </button>
        )}
      </div>

      {/* KPI Metric Overview */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng số lớp</span>
            <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <School className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">Toàn bộ chi nhánh</div>
        </div>

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

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-sky-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đang giảng dạy</span>
            <div className="w-8 h-8 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center">
              <BookOpen className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-sky-600 tabular-nums">{stats.inProgress}</div>
          <div className="text-[11px] text-sky-700/80 mt-1 font-medium">Lớp đang vận hành</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-purple-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng học viên</span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
              <Users className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-purple-600 tabular-nums">{stats.totalStudents}</div>
          <div className="text-[11px] text-purple-700/80 mt-1 font-medium">Học viên đang theo học</div>
        </div>
      </div>

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
          {[
            { id: '', label: 'Tất cả' },
            { id: 'OPEN_FOR_ENROLLMENT', label: 'Đang mở' },
            { id: 'IN_PROGRESS', label: 'Đang học' },
            { id: 'COMPLETED', label: 'Đã xong' },
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
            {classes.length} lớp
          </span>
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
                <th className="p-4 pr-5 text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {classes.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center text-slate-400 font-medium">
                    <School className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                    Không tìm thấy lớp học nào phù hợp.
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
                            <option value="IN_PROGRESS">Đang giảng dạy</option>
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
                        <div className="flex items-center justify-end gap-1.5">
                          <button
                            type="button"
                            onClick={() => handleOpenRoster(cls)}
                            className="inline-flex items-center gap-1.5 bg-slate-100 hover:bg-indigo-50 text-slate-700 hover:text-indigo-700 font-bold px-3 py-1.5 rounded-xl transition cursor-pointer border border-slate-200/60 hover:border-indigo-200"
                            title="Xem danh sách học viên trong lớp"
                          >
                            <Users className="w-3.5 h-3.5" />
                            <span>DS Lớp</span>
                          </button>

                          {canManage && (
                            <>
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

      {/* ================= MODAL: THÊM LỚP HỌC MỚI ================= */}
      {showAddModal && (
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
                  onChange={(e) => setNewClass({ ...newClass, course_id: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600"
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
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer"
                >
                  Tạo Lớp Học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ================= MODAL: SỬA LỚP HỌC ================= */}
      {showEditModal && editingClass && (
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
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-bold shadow-xs active:scale-95 cursor-pointer"
                >
                  Lưu Thay Đổi
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ================= MODAL: DANH SÁCH LỚP (ROSTER) ================= */}
      {selectedClassRoster && (
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
        </div>
      )}

    </div>
  );
};
