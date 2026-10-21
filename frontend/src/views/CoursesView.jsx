import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { coursesApi } from '../services/api';
import { Plus, Search, Tag, Clock, DollarSign, ToggleLeft, ToggleRight, Trash2, BookOpen, Edit2 } from 'lucide-react';

export const CoursesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [courses, setCourses] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');

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
        setCourses(res.data);
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

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
            <BookOpen className="w-5 h-5 text-indigo-600" />
            Khóa học & Chuẩn đầu ra
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Quản lý chương trình đào tạo, thời lượng, mức học phí và cấp độ mục tiêu đầu ra (IELTS / TOEIC).
          </p>
        </div>
        {canManage && (
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white px-4 py-2.5 rounded-xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer"
          >
            <Plus className="w-4 h-4" /> Thêm khóa học mới
          </button>
        )}
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center justify-between gap-3">
        <div className="flex items-center gap-2.5 flex-1">
          <Search className="w-4 h-4 text-slate-400 shrink-0 ml-1" />
          <input
            type="text"
            placeholder="Tìm kiếm theo tên khóa học hoặc chuẩn đầu ra (IELTS 6.5, TOEIC 750)..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full text-xs outline-hidden text-slate-800 placeholder:text-slate-400"
          />
        </div>
        <span className="text-[11px] font-bold text-slate-500 bg-slate-100 px-2.5 py-1 rounded-lg shrink-0">
          {courses.length} khóa học
        </span>
      </div>

      {/* Course Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {courses.map((course) => (
          <div
            key={course.id}
            className={`bg-white rounded-2xl border p-6 flex flex-col justify-between shadow-2xs card-hover ${
              course.is_active ? 'border-slate-200/90' : 'border-slate-200/70 bg-slate-50/60 opacity-80'
            }`}
          >
            <div>
              <div className="flex items-center justify-between gap-2 mb-3">
                <span className="font-mono text-xs font-bold bg-slate-100 text-slate-700 px-2.5 py-1 rounded-md">
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
                  {course.is_active ? 'Đang mở' : 'Ngừng sử dụng'}
                </span>
              </div>

              <h3 className="font-bold text-base text-slate-900 leading-snug">
                {course.title}
              </h3>
              <p className="text-xs text-slate-500 mt-2 line-clamp-2 leading-relaxed">
                {course.description || 'Chương trình đào tạo tiêu chuẩn theo lộ trình chuẩn quốc tế.'}
              </p>

              <div className="mt-5 pt-4 border-t border-slate-100 space-y-2.5 text-xs">
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-1.5 text-slate-500 font-medium">
                    <Tag className="w-3.5 h-3.5 text-indigo-500" /> Cấp độ đầu ra:
                  </span>
                  <span className="font-bold text-indigo-700 bg-indigo-50 border border-indigo-100 px-2.5 py-0.5 rounded-md">
                    {course.target_level}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-1.5 text-slate-500 font-medium">
                    <Clock className="w-3.5 h-3.5 text-slate-400" /> Thời lượng học:
                  </span>
                  <span className="font-semibold text-slate-700">{course.duration_weeks} tuần</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-1.5 text-slate-500 font-medium">
                    <DollarSign className="w-3.5 h-3.5 text-slate-400" /> Học phí niêm yết:
                  </span>
                  <span className="font-bold text-slate-900 text-sm tabular-nums">
                    {course.fee.toLocaleString('vi-VN')} đ
                  </span>
                </div>
              </div>
            </div>

            {canManage && (
              <div className="mt-6 pt-3.5 border-t border-slate-100 flex items-center justify-between text-xs">
                <button
                  onClick={() => handleToggleStatus(course.id)}
                  className="flex items-center gap-1.5 font-semibold text-slate-600 hover:text-indigo-600 transition cursor-pointer"
                >
                  {course.is_active ? (
                    <>
                      <ToggleRight className="w-4 h-4 text-emerald-600" /> Ngừng kích hoạt
                    </>
                  ) : (
                    <>
                      <ToggleLeft className="w-4 h-4 text-slate-400" /> Mở kích hoạt
                    </>
                  )}
                </button>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleOpenEdit(course)}
                    className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition cursor-pointer"
                    title="Sửa khóa học"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(course.id, course.title)}
                    className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition cursor-pointer"
                    title="Xóa khóa học"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Add Course Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <h3 className="text-lg font-black text-slate-900 mb-1">
              Thêm Khóa học mới
            </h3>
            <p className="text-xs text-slate-500 mb-5">
              Thiết lập thông tin khóa học và cấp độ mục tiêu đầu ra (IELTS / TOEIC)
            </p>

            <form onSubmit={handleCreateCourse} className="space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mã khóa học:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: IELTS-ADV-70"
                  value={newCourse.code}
                  onChange={(e) => setNewCourse({ ...newCourse, code: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-mono font-medium uppercase"
                />
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tên khóa học:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: Luyện thi IELTS Nâng cao 7.0+"
                  value={newCourse.title}
                  onChange={(e) => setNewCourse({ ...newCourse, title: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Cấp độ mục tiêu:</label>
                  <input
                    type="text"
                    required
                    placeholder="Ví dụ: IELTS 7.0"
                    value={newCourse.target_level}
                    onChange={(e) => setNewCourse({ ...newCourse, target_level: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Thời lượng (tuần):</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={newCourse.duration_weeks}
                    onChange={(e) => setNewCourse({ ...newCourse, duration_weeks: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium tabular-nums"
                  />
                </div>
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Học phí (VNĐ):</label>
                <input
                  type="number"
                  min="0"
                  required
                  value={newCourse.fee}
                  onChange={(e) => setNewCourse({ ...newCourse, fee: Number(e.target.value) })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium tabular-nums"
                />
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mô tả khóa học:</label>
                <textarea
                  rows={2}
                  value={newCourse.description}
                  onChange={(e) => setNewCourse({ ...newCourse, description: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
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
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Lưu khóa học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Course Modal */}
      {showEditModal && editingCourse && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div>
                <h3 className="text-lg font-black text-slate-900">
                  Cập nhật Khóa học: {editingCourse.code}
                </h3>
                <span className="text-xs text-slate-400 font-medium">Chỉnh sửa chi tiết chương trình đào tạo</span>
              </div>
              <button
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
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Cấp độ mục tiêu:</label>
                  <input
                    type="text"
                    required
                    value={editCourseForm.target_level}
                    onChange={(e) => setEditCourseForm({ ...editCourseForm, target_level: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Thời lượng (tuần):</label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={editCourseForm.duration_weeks}
                    onChange={(e) => setEditCourseForm({ ...editCourseForm, duration_weeks: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium tabular-nums"
                  />
                </div>
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Học phí (VNĐ):</label>
                <input
                  type="number"
                  min="0"
                  required
                  value={editCourseForm.fee}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, fee: Number(e.target.value) })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium tabular-nums"
                />
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mô tả khóa học:</label>
                <textarea
                  rows={2}
                  value={editCourseForm.description}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, description: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl outline-hidden focus:border-indigo-600 font-medium"
                />
              </div>
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="courseActiveCheck"
                  checked={editCourseForm.is_active}
                  onChange={(e) => setEditCourseForm({ ...editCourseForm, is_active: e.target.checked })}
                  className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4 cursor-pointer"
                />
                <label htmlFor="courseActiveCheck" className="text-xs font-bold text-slate-700 cursor-pointer">
                  Khóa học đang hoạt động và mở tuyển sinh
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
