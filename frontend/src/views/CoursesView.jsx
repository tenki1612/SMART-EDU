import React, { useEffect, useState, useMemo } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { coursesApi } from '../services/api';
import {
  Plus,
  Search,
  Tag,
  Clock,
  DollarSign,
  ToggleLeft,
  ToggleRight,
  Trash2,
  BookOpen,
  Edit2,
  CheckCircle2,
  Sparkles,
  X,
  Layers,
  GraduationCap
} from 'lucide-react';

export const CoursesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [courses, setCourses] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedLevel, setSelectedLevel] = useState('ALL');

  // Add Course Modal
  const [showAddModal, setShowAddModal] = useState(false);
  const [newCourse, setNewCourse] = useState({
    code: '',
    title: '',
    description: '',
    target_level: 'IELTS 6.5',
    duration_weeks: 12,
    fee: 8500000,
  });

  // Edit Course Modal
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingCourse, setEditingCourse] = useState(null);
  const [editCourseForm, setEditCourseForm] = useState({
    title: '',
    description: '',
    target_level: '',
    duration_weeks: 12,
    fee: 0,
    is_active: true,
  });

  const loadCourses = async () => {
    try {
      const res = await coursesApi.list(searchTerm);
      if (res.success) {
        setCourses(res.data || []);
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách khóa học: ' + e.message);
    }
  };

  useEffect(() => {
    loadCourses();
  }, [searchTerm]);

  const handleToggleStatus = async (id) => {
    try {
      await coursesApi.toggleStatus(id);
      toast.success('Đã thay đổi trạng thái khóa học!');
      loadCourses();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleDelete = async (id, title) => {
    if (!window.confirm(`Bạn có chắc chắn muốn XÓA vĩnh viễn khóa học "${title}"?`)) return;
    try {
      await coursesApi.delete(id);
      toast.success('Đã xóa khóa học thành công!');
      loadCourses();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleCreateCourse = async (e) => {
    e.preventDefault();
    try {
      await coursesApi.create({
        code: newCourse.code.trim().toUpperCase(),
        title: newCourse.title.trim(),
        description: newCourse.description.trim(),
        target_level: newCourse.target_level.trim(),
        duration_weeks: Number(newCourse.duration_weeks),
        fee: Number(newCourse.fee),
      });
      toast.success('Đã tạo khóa học mới thành công!');
      setShowAddModal(false);
      setNewCourse({
        code: '',
        title: '',
        description: '',
        target_level: 'IELTS 6.5',
        duration_weeks: 12,
        fee: 8500000,
      });
      loadCourses();
    } catch (e) {
      toast.error(e.message);
    }
  };

  const handleOpenEdit = (course) => {
    setEditingCourse(course);
    setEditCourseForm({
      title: course.title,
      description: course.description || '',
      target_level: course.target_level,
      duration_weeks: course.duration_weeks,
      fee: course.fee,
      is_active: course.is_active,
    });
    setShowEditModal(true);
  };

  const handleUpdateCourse = async (e) => {
    e.preventDefault();
    try {
      await coursesApi.update(editingCourse.id, {
        title: editCourseForm.title.trim(),
        description: editCourseForm.description.trim(),
        target_level: editCourseForm.target_level.trim(),
        duration_weeks: Number(editCourseForm.duration_weeks),
        fee: Number(editCourseForm.fee),
        is_active: editCourseForm.is_active,
      });
      toast.success('Đã cập nhật thông tin khóa học thành công!');
      setShowEditModal(false);
      setEditingCourse(null);
      loadCourses();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // KPI Calculations
  const stats = useMemo(() => {
    const total = courses.length;
    const active = courses.filter((c) => c.is_active).length;
    const avgFee = total > 0 ? Math.round(courses.reduce((acc, c) => acc + (c.fee || 0), 0) / total) : 0;
    const avgWeeks = total > 0 ? Math.round(courses.reduce((acc, c) => acc + (c.duration_weeks || 0), 0) / total) : 0;
    return { total, active, avgFee, avgWeeks };
  }, [courses]);

  // Filtered by selectedLevel
  const filteredCourses = useMemo(() => {
    return courses.filter((c) => {
      if (selectedLevel === 'ALL') return true;
      if (selectedLevel === 'IELTS') return c.target_level?.toUpperCase().includes('IELTS');
      if (selectedLevel === 'TOEIC') return c.target_level?.toUpperCase().includes('TOEIC');
      if (selectedLevel === 'COMMUNICATION') return c.target_level?.toLowerCase().includes('tiếp') || c.title?.toLowerCase().includes('giao tiếp');
      return true;
    });
  }, [courses, selectedLevel]);

  return (
    <div className="space-y-6">
      
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-black text-slate-900 tracking-tight flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-200/80 flex items-center justify-center text-indigo-600 shadow-2xs">
              <BookOpen className="w-5 h-5" />
            </div>
            <span>Chương Trình & Khóa Học</span>
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Quản lý lộ trình đào tạo, chuẩn đầu ra quốc tế (IELTS / TOEIC), thời lượng và biểu phí niêm yết.
          </p>
        </div>

        {canManage && (
          <button
            type="button"
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 active:scale-95 text-white px-4 py-2.5 rounded-2xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer shrink-0"
          >
            <Plus className="w-4 h-4" />
            <span>Thêm khóa học mới</span>
          </button>
        )}
      </div>

      {/* KPI Metric Overview */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-indigo-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Tổng khóa học</span>
            <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <Layers className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.total}</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">Toàn bộ chương trình</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-emerald-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Đang tuyển sinh</span>
            <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <CheckCircle2 className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-emerald-600 tabular-nums">{stats.active}</div>
          <div className="text-[11px] text-emerald-700/80 mt-1 font-medium">Sẵn sàng mở lớp</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-amber-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Học phí trung bình</span>
            <div className="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
              <DollarSign className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">
            {stats.avgFee > 0 ? (stats.avgFee / 1000000).toFixed(1) + ' tr' : '0 đ'}
          </div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">Mỗi khóa đào tạo</div>
        </div>

        <div className="bg-white p-4 sm:p-5 rounded-3xl border border-slate-200/90 shadow-2xs hover:border-purple-200 hover:-translate-y-0.5 transition-all">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Thời lượng TB</span>
            <div className="w-8 h-8 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
              <Clock className="w-4 h-4" />
            </div>
          </div>
          <div className="text-2xl font-black text-slate-900 tabular-nums">{stats.avgWeeks} tuần</div>
          <div className="text-[11px] text-slate-500 mt-1 font-medium">~{Math.round(stats.avgWeeks / 4)} tháng học tập</div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-3.5 rounded-3xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
        
        {/* Search Input */}
        <div className="flex items-center gap-2.5 flex-1 bg-slate-50/80 border border-slate-200/80 rounded-2xl px-3.5 py-2">
          <Search className="w-4 h-4 text-slate-400 shrink-0" />
          <input
            type="text"
            placeholder="Tìm theo tên khóa học hoặc chuẩn đầu ra (IELTS 6.5, TOEIC 750)..."
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

        {/* Level Filter Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 shrink-0">
          {[
            { id: 'ALL', label: 'Tất cả' },
            { id: 'IELTS', label: 'IELTS' },
            { id: 'TOEIC', label: 'TOEIC' },
            { id: 'COMMUNICATION', label: 'Giao tiếp' },
          ].map((lvl) => {
            const isSelected = selectedLevel === lvl.id;
            return (
              <button
                key={lvl.id}
                type="button"
                onClick={() => setSelectedLevel(lvl.id)}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
                  isSelected
                    ? 'bg-indigo-600 text-white shadow-xs'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200/70'
                }`}
              >
                {lvl.label}
              </button>
            );
          })}

          <span className="text-[11px] font-bold text-slate-500 bg-slate-100 border border-slate-200/60 px-3 py-1.5 rounded-xl ml-1">
            {filteredCourses.length} khóa
          </span>
        </div>

      </div>

      {/* Course Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filteredCourses.length === 0 ? (
          <div className="col-span-full py-16 text-center text-slate-400 bg-white rounded-3xl border border-slate-200/90 shadow-2xs">
            <BookOpen className="w-10 h-10 mx-auto mb-3 text-slate-300" />
            <h4 className="text-sm font-bold text-slate-700">Không tìm thấy khóa học nào</h4>
            <p className="text-xs text-slate-400 mt-1">Hãy thử tìm kiếm với từ khóa khác hoặc điều chỉnh bộ lọc.</p>
          </div>
        ) : (
          filteredCourses.map((course) => (
            <div
              key={course.id}
              className={`bg-white rounded-3xl border p-6 flex flex-col justify-between shadow-2xs hover:shadow-md hover:border-indigo-200 transition-all duration-200 ${
                course.is_active ? 'border-slate-200/90' : 'border-slate-200/70 bg-slate-50/50 opacity-80'
              }`}
            >
              <div>
                {/* Header Badge */}
                <div className="flex items-center justify-between gap-2 mb-3.5">
                  <span className="font-mono text-xs font-black bg-indigo-50 text-indigo-700 border border-indigo-200/60 px-2.5 py-1 rounded-xl shadow-2xs">
                    {course.code}
                  </span>
                  <span
                    className={`inline-flex items-center gap-1.5 text-[11px] font-bold px-2.5 py-0.5 rounded-full border ${
                      course.is_active
                        ? 'bg-emerald-50 text-emerald-700 border-emerald-200/80'
                        : 'bg-slate-100 text-slate-600 border-slate-200'
                    }`}
                  >
                    <span
                      className={`w-1.5 h-1.5 rounded-full ${
                        course.is_active ? 'bg-emerald-500' : 'bg-slate-400'
                      }`}
                    />
                    {course.is_active ? 'Đang mở' : 'Tạm dừng'}
                  </span>
                </div>

                {/* Course Title & Description */}
                <h3 className="font-black text-base text-slate-900 leading-snug hover:text-indigo-600 transition-colors">
                  {course.title}
                </h3>
                <p className="text-xs text-slate-500 mt-2 line-clamp-2 leading-relaxed">
                  {course.description || 'Chương trình đào tạo tiêu chuẩn theo lộ trình chuẩn hóa quốc tế.'}
                </p>

                {/* Details Breakdown */}
                <div className="mt-5 pt-4 border-t border-slate-100 space-y-2.5 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5 text-slate-500 font-medium">
                      <Tag className="w-3.5 h-3.5 text-indigo-500" /> Cấp độ đầu ra:
                    </span>
                    <span className="font-black text-indigo-700 bg-indigo-50 border border-indigo-200/60 px-2.5 py-0.5 rounded-xl shadow-2xs">
                      {course.target_level}
                    </span>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5 text-slate-500 font-medium">
                      <Clock className="w-3.5 h-3.5 text-slate-400" /> Thời lượng học:
                    </span>
                    <span className="font-bold text-slate-700 tabular-nums">
                      {course.duration_weeks} tuần (~{Math.round(course.duration_weeks / 4)} tháng)
                    </span>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1.5 text-slate-500 font-medium">
                      <DollarSign className="w-3.5 h-3.5 text-amber-500" /> Học phí niêm yết:
                    </span>
                    <span className="font-black text-slate-900 text-sm tabular-nums text-indigo-600">
                      {course.fee?.toLocaleString('vi-VN')} đ
                    </span>
                  </div>
                </div>
              </div>

              {/* Management Actions */}
              {canManage && (
                <div className="mt-6 pt-3.5 border-t border-slate-100 flex items-center justify-between text-xs">
                  <button
                    type="button"
                    onClick={() => handleToggleStatus(course.id)}
                    className="flex items-center gap-1.5 font-bold text-slate-600 hover:text-indigo-600 transition cursor-pointer"
                  >
                    {course.is_active ? (
                      <>
                        <ToggleRight className="w-4 h-4 text-emerald-600" />
                        <span>Đang hoạt động</span>
                      </>
                    ) : (
                      <>
                        <ToggleLeft className="w-4 h-4 text-slate-400" />
                        <span>Đang tắt</span>
                      </>
                    )}
                  </button>

                  <div className="flex items-center gap-1">
                    <button
                      type="button"
                      onClick={() => handleOpenEdit(course)}
                      className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer"
                      title="Chỉnh sửa khóa học"
                    >
                      <Edit2 className="w-3.5 h-3.5" />
                    </button>
                    <button
                      type="button"
                      onClick={() => handleDelete(course.id, course.title)}
                      className="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition cursor-pointer"
                      title="Xóa khóa học vĩnh viễn"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              )}
            </div>
          ))
        )}
      </div>

      {/* ================= MODAL THÊM KHÓA HỌC ================= */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Plus className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">Thêm Khóa Học Mới</h3>
                  <span className="text-xs text-slate-400">Khởi tạo chương trình đào tạo chuẩn</span>
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

            <form onSubmit={handleCreateCourse} className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mã khóa học (Course Code):</label>
                <input
                  type="text"
                  required
                  placeholder="VD: IELTS-65, TOEIC-750..."
                  value={newCourse.code}
                  onChange={(e) => setNewCourse({ ...newCourse, code: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 font-mono uppercase text-xs outline-hidden font-bold"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Tên khóa học:</label>
                <input
                  type="text"
                  required
                  placeholder="VD: Luyện thi IELTS Chuyên Sâu 6.5+..."
                  value={newCourse.title}
                  onChange={(e) => setNewCourse({ ...newCourse, title: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Mô tả chương trình:</label>
                <textarea
                  rows={2}
                  placeholder="Tóm tắt nội dung và kỹ năng trọng tâm..."
                  value={newCourse.description}
                  onChange={(e) => setNewCourse({ ...newCourse, description: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-medium"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Chuẩn đầu ra:</label>
                  <input
                    type="text"
                    required
                    placeholder="VD: IELTS 6.5"
                    value={newCourse.target_level}
                    onChange={(e) => setNewCourse({ ...newCourse, target_level: e.target.value })}
                    className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Thời lượng (tuần):</label>
                  <input
                    type="number"
                    min="1"
                    max="104"
                    required
                    value={newCourse.duration_weeks}
                    onChange={(e) => setNewCourse({ ...newCourse, duration_weeks: e.target.value })}
                    className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold tabular-nums"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Học phí niêm yết (VNĐ):</label>
                <input
                  type="number"
                  min="0"
                  step="50000"
                  required
                  value={newCourse.fee}
                  onChange={(e) => setNewCourse({ ...newCourse, fee: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold tabular-nums"
                />
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
                  Xác nhận Tạo Khóa Học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ================= MODAL CHỈNH SỬA KHÓA HỌC ================= */}
      {showEditModal && editingCourse && (
        <div className="fixed inset-0 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 relative overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Edit2 className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">Chỉnh Sửa Khóa Học</h3>
                  <span className="text-xs text-slate-400 font-mono">Mã: {editingCourse.code}</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => {
                  setShowEditModal(false);
                  setEditingCourse(null);
                }}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleUpdateCourse} className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tên khóa học:</label>
                <input
                  type="text"
                  required
                  value={editCourseForm.title}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, title: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Mô tả chương trình:</label>
                <textarea
                  rows={2}
                  value={editCourseForm.description}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, description: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-medium"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Chuẩn đầu ra:</label>
                  <input
                    type="text"
                    required
                    value={editCourseForm.target_level}
                    onChange={(e) => setEditCourseForm({ ...editCourseForm, target_level: e.target.value })}
                    className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Thời lượng (tuần):</label>
                  <input
                    type="number"
                    min="1"
                    max="104"
                    required
                    value={editCourseForm.duration_weeks}
                    onChange={(e) => setEditCourseForm({ ...editCourseForm, duration_weeks: e.target.value })}
                    className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold tabular-nums"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Học phí niêm yết (VNĐ):</label>
                <input
                  type="number"
                  min="0"
                  step="50000"
                  required
                  value={editCourseForm.fee}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, fee: e.target.value })}
                  className="w-full border border-slate-300 focus:border-indigo-600 rounded-xl p-2.5 text-xs outline-hidden font-bold tabular-nums"
                />
              </div>

              <div className="flex items-center gap-2 pt-1">
                <input
                  type="checkbox"
                  id="courseActiveCheck"
                  checked={editCourseForm.is_active}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, is_active: e.target.checked })}
                  className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4 cursor-pointer"
                />
                <label htmlFor="courseActiveCheck" className="text-xs font-bold text-slate-700 cursor-pointer">
                  Khóa học đang hoạt động (cho phép mở lớp và tuyển sinh)
                </label>
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => {
                    setShowEditModal(false);
                    setEditingCourse(null);
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
