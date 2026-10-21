import React, { useEffect, useState, useMemo } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { schedulesApi, classroomsApi, teachersApi, classesApi } from '../services/api';
import {
  CalendarDays, AlertTriangle, CheckCircle, Clock, MapPin, UserCheck,
  ShieldCheck, Plus, Edit2, Trash2, ChevronLeft, ChevronRight,
  LayoutGrid, List, Ban, X, Filter, Sparkles
} from 'lucide-react';

export const SchedulesView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  // Data states
  const [schedules, setSchedules] = useState([]);
  const [classrooms, setClassrooms] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [classesList, setClassesList] = useState([]);
  const [loading, setLoading] = useState(false);

  // View & Filter states
  const [viewMode, setViewMode] = useState('grid'); // 'grid' (timetable) | 'list'
  const [showPersonalOnly, setShowPersonalOnly] = useState(false);
  const [historyFilter, setHistoryFilter] = useState('all'); // 'all' | 'upcoming' | 'past'
  const [selectedClassId, setSelectedClassId] = useState('');
  const [selectedTeacherId, setSelectedTeacherId] = useState('');

  // Weekly Timetable Navigation (starts from current week's Monday)
  const [currentWeekStart, setCurrentWeekStart] = useState(() => {
    const now = new Date();
    const day = now.getDay();
    const diff = (day === 0 ? -6 : 1) - day; // Monday
    const monday = new Date(now);
    monday.setDate(now.getDate() + diff);
    monday.setHours(0, 0, 0, 0);
    return monday;
  });

  // Modals
  const [showAddModal, setShowAddModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingSession, setEditingSession] = useState(null);

  // Form states
  const [addForm, setAddForm] = useState({
    class_id: '',
    classroom_id: '',
    teacher_id: '',
    session_date: new Date().toISOString().split('T')[0],
    start_time: '18:00',
    end_time: '20:00',
    slot_name: 'Ca tối (18:00 - 20:00)',
  });

  const [editForm, setEditForm] = useState({
    classroom_id: '',
    teacher_id: '',
    session_date: '',
    start_time: '',
    end_time: '',
    slot_name: '',
    status: 'ACTIVE',
  });

  // Modal Conflict check result
  const [modalConflict, setModalConflict] = useState(null);

  // Live Conflict Checker Bar Form
  const [checkForm, setCheckForm] = useState({
    classroom_id: 1,
    teacher_id: 1,
    session_date: new Date().toISOString().split('T')[0],
    start_time: '18:00',
    end_time: '20:00',
  });
  const [conflictResult, setConflictResult] = useState(null);

  // Preset time slots
  const TIME_SLOTS = [
    { label: 'Ca sáng (08:00 - 10:00)', start: '08:00', end: '10:00' },
    { label: 'Ca chiều (14:00 - 16:00)', start: '14:00', end: '16:00' },
    { label: 'Ca tối (18:00 - 20:00)', start: '18:00', end: '20:00' },
    { label: 'Ca tối 2 (20:00 - 22:00)', start: '20:00', end: '22:00' },
  ];

  const loadData = async () => {
    setLoading(true);
    try {
      const [resSchedules, resRooms, resTeachers, resClasses] = await Promise.all([
        showPersonalOnly ? schedulesApi.getPersonal() : schedulesApi.list(),
        classroomsApi.list().catch(() => ({ data: [] })),
        teachersApi.list().catch(() => ({ data: [] })),
        classesApi.list().catch(() => ({ data: [] })),
      ]);
      setSchedules(resSchedules.data || []);
      setClassrooms(resRooms.data || []);
      setTeachers(resTeachers.data || []);
      setClassesList(resClasses.data || []);

      if (resRooms.data?.length > 0 && !addForm.classroom_id) {
        setAddForm(prev => ({
          ...prev,
          classroom_id: resRooms.data[0].id,
          teacher_id: resTeachers.data?.[0]?.id || '',
          class_id: resClasses.data?.[0]?.id || '',
        }));
        setCheckForm(prev => ({
          ...prev,
          classroom_id: resRooms.data[0].id,
          teacher_id: resTeachers.data?.[0]?.id || 1,
        }));
      }
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải dữ liệu lịch học: ' + e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [showPersonalOnly]);

  // Compute 7 days for the current week
  const weekDays = useMemo(() => {
    const days = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(currentWeekStart);
      d.setDate(currentWeekStart.getDate() + i);
      days.push(d);
    }
    return days;
  }, [currentWeekStart]);

  const todayStr = useMemo(() => new Date().toISOString().split('T')[0], []);

  // Filter schedules based on historyFilter, selectedClassId, selectedTeacherId
  const filteredSchedules = useMemo(() => {
    return schedules.filter(s => {
      if (selectedClassId && s.class_id !== Number(selectedClassId)) return false;
      if (selectedTeacherId && s.teacher_id !== Number(selectedTeacherId)) return false;

      const sDate = s.session_date;
      if (historyFilter === 'upcoming') {
        return sDate >= todayStr;
      } else if (historyFilter === 'past') {
        return sDate < todayStr;
      }
      return true;
    });
  }, [schedules, historyFilter, selectedClassId, selectedTeacherId, todayStr]);

  // Counts for tabs
  const upcomingCount = useMemo(() => {
    return schedules.filter(s => s.session_date >= todayStr).length;
  }, [schedules, todayStr]);

  const pastCount = useMemo(() => {
    return schedules.filter(s => s.session_date < todayStr).length;
  }, [schedules, todayStr]);

  // Navigation handlers for week
  const handlePrevWeek = () => {
    const prev = new Date(currentWeekStart);
    prev.setDate(prev.getDate() - 7);
    setCurrentWeekStart(prev);
  };

  const handleNextWeek = () => {
    const next = new Date(currentWeekStart);
    next.setDate(next.getDate() + 7);
    setCurrentWeekStart(next);
  };

  const handleCurrentWeek = () => {
    const now = new Date();
    const day = now.getDay();
    const diff = (day === 0 ? -6 : 1) - day;
    const monday = new Date(now);
    monday.setDate(now.getDate() + diff);
    monday.setHours(0, 0, 0, 0);
    setCurrentWeekStart(monday);
  };

  // Conflict check standalone form
  const handleTestConflict = async (e) => {
    e.preventDefault();
    try {
      const res = await schedulesApi.checkConflicts(checkForm);
      setConflictResult(res.data);
      if (res.data.has_conflict) {
        toast.warning(res.data.message);
      } else {
        toast.success('Lịch hoàn toàn hợp lệ, không có xung đột!');
      }
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Check conflict inside Add / Edit Modal
  const checkModalConflict = async (form, excludeId = null) => {
    if (!form.classroom_id || !form.teacher_id || !form.session_date || !form.start_time || !form.end_time) {
      return null;
    }
    try {
      const res = await schedulesApi.checkConflicts({
        classroom_id: Number(form.classroom_id),
        teacher_id: Number(form.teacher_id),
        session_date: form.session_date,
        start_time: form.start_time,
        end_time: form.end_time,
        exclude_session_id: excludeId,
      });
      setModalConflict(res.data);
      return res.data;
    } catch (e) {
      console.error(e);
      return null;
    }
  };

  // Create session
  const handleCreateSession = async (e) => {
    e.preventDefault();
    try {
      const conflict = await checkModalConflict(addForm);
      if (conflict && conflict.has_conflict) {
        toast.error('Không thể tạo do xung đột lịch: ' + conflict.message);
        return;
      }
      await schedulesApi.create({
        class_id: Number(addForm.class_id),
        classroom_id: Number(addForm.classroom_id),
        teacher_id: Number(addForm.teacher_id),
        session_date: addForm.session_date,
        start_time: addForm.start_time,
        end_time: addForm.end_time,
        slot_name: addForm.slot_name,
      });
      toast.success('Thêm buổi học vào thời khóa biểu thành công!');
      setShowAddModal(false);
      setModalConflict(null);
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Open Edit Modal
  const handleOpenEdit = (session) => {
    setEditingSession(session);
    setEditForm({
      classroom_id: session.classroom_id,
      teacher_id: session.teacher_id,
      session_date: session.session_date,
      start_time: session.start_time,
      end_time: session.end_time,
      slot_name: session.slot_name,
      status: session.status || 'ACTIVE',
    });
    setModalConflict(null);
    setShowEditModal(true);
  };

  // Submit Edit
  const handleUpdateSession = async (e) => {
    e.preventDefault();
    try {
      const conflict = await checkModalConflict(editForm, editingSession.id);
      if (conflict && conflict.has_conflict) {
        toast.error('Không thể cập nhật do xung đột lịch: ' + conflict.message);
        return;
      }
      await schedulesApi.update(editingSession.id, {
        classroom_id: Number(editForm.classroom_id),
        teacher_id: Number(editForm.teacher_id),
        session_date: editForm.session_date,
        start_time: editForm.start_time,
        end_time: editForm.end_time,
        slot_name: editForm.slot_name,
        status: editForm.status,
      });
      toast.success('Đã cập nhật buổi học thành công!');
      setShowEditModal(false);
      setEditingSession(null);
      setModalConflict(null);
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Cancel session
  const handleCancelSession = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn hủy buổi học này?')) return;
    try {
      await schedulesApi.cancel(id);
      toast.success('Đã hủy buổi học!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Delete session
  const handleDeleteSession = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn XÓA vĩnh viễn buổi học này khỏi thời khóa biểu?')) return;
    try {
      await schedulesApi.delete(id);
      toast.success('Đã xóa buổi học thành công!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Confirm schedule for class
  const handleConfirmSchedule = async (classId) => {
    try {
      await schedulesApi.confirmSchedule(classId);
      toast.success('Đã xác nhận thời khóa biểu chính thức thành công!');
      loadData();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Quick schedule from empty cell
  const handleQuickAdd = (dateStr, slot) => {
    setAddForm(prev => ({
      ...prev,
      session_date: dateStr,
      start_time: slot.start,
      end_time: slot.end,
      slot_name: slot.label,
    }));
    setModalConflict(null);
    setShowAddModal(true);
  };

  const formatDateVN = (d) => {
    return d.toLocaleDateString('vi-VN', {
      weekday: 'short',
      day: '2-digit',
      month: '2-digit',
    });
  };

  const weekTitle = `${weekDays[0].toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })} — ${weekDays[6].toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })}`;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
            <CalendarDays className="w-5 h-5 text-indigo-600" />
            Thời khóa biểu & Lịch học
          </h2>
          <p className="text-xs text-slate-500 mt-1">
            Tra cứu lịch theo dạng Bảng Tuần (Timetable) hoặc Danh Sách, theo dõi lịch sử học tập và quản lý ca học.
          </p>
        </div>

        <div className="flex items-center flex-wrap gap-2.5">
          {['TEACHER', 'STUDENT', 'PARENT'].includes(user?.role || '') && (
            <button
              onClick={() => setShowPersonalOnly(!showPersonalOnly)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer border ${
                showPersonalOnly
                  ? 'bg-indigo-600 text-white border-indigo-600 shadow-sm shadow-indigo-200'
                  : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
              }`}
            >
              {showPersonalOnly ? 'Hiển thị tất cả lịch' : 'Xem lịch cá nhân của tôi'}
            </button>
          )}

          {canManage && (
            <button
              onClick={() => {
                setModalConflict(null);
                setShowAddModal(true);
              }}
              className="flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-sm shadow-indigo-200 transition cursor-pointer"
            >
              <Plus className="w-4 h-4" /> Thêm buổi học mới
            </button>
          )}

          {/* View Mode Toggle */}
          <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200">
            <button
              onClick={() => setViewMode('grid')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                viewMode === 'grid'
                  ? 'bg-white text-indigo-700 shadow-2xs font-extrabold'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <LayoutGrid className="w-3.5 h-3.5" /> Bảng tuần
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                viewMode === 'list'
                  ? 'bg-white text-indigo-700 shadow-2xs font-extrabold'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <List className="w-3.5 h-3.5" /> Danh sách
            </button>
          </div>
        </div>
      </div>

      {/* Filter Toolbar: History & Class/Teacher filter */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-200/90 shadow-2xs flex flex-col md:flex-row items-center justify-between gap-3">
        {/* Student Schedule History Tabs (Requirement 1) */}
        <div className="flex items-center gap-1.5 bg-slate-100/90 p-1 rounded-xl border border-slate-200/60 w-full md:w-auto">
          <button
            onClick={() => setHistoryFilter('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
              historyFilter === 'all'
                ? 'bg-white text-slate-900 shadow-2xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Tất cả ({schedules.length})
          </button>
          <button
            onClick={() => setHistoryFilter('upcoming')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
              historyFilter === 'upcoming'
                ? 'bg-white text-indigo-700 shadow-2xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-indigo-500 animate-pulse"></span>
            Lịch sắp tới ({upcomingCount})
          </button>
          <button
            onClick={() => setHistoryFilter('past')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
              historyFilter === 'past'
                ? 'bg-white text-slate-900 shadow-2xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            Lịch sử buổi học đã qua ({pastCount})
          </button>
        </div>

        {/* Dropdown Filters */}
        <div className="flex items-center gap-2 w-full md:w-auto justify-end">
          <select
            value={selectedClassId}
            onChange={(e) => setSelectedClassId(e.target.value)}
            className="border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-700 bg-white font-medium outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
          >
            <option value="">-- Tất cả lớp học --</option>
            {classesList.map(c => (
              <option key={c.id} value={c.id}>{c.class_code} - {c.course_title}</option>
            ))}
          </select>

          <select
            value={selectedTeacherId}
            onChange={(e) => setSelectedTeacherId(e.target.value)}
            className="border border-slate-200 rounded-xl px-3 py-1.5 text-xs text-slate-700 bg-white font-medium outline-hidden hover:border-slate-300 cursor-pointer shadow-2xs"
          >
            <option value="">-- Tất cả giáo viên --</option>
            {teachers.map(t => (
              <option key={t.id} value={t.id}>{t.full_name}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Timetable Weekly Matrix View (Requirement 2) */}
      {viewMode === 'grid' && (
        <div className="space-y-3">
          {/* Week Navigation bar */}
          <div className="flex items-center justify-between bg-white px-4 py-3 rounded-2xl border border-slate-200/90 shadow-2xs">
            <div className="flex items-center gap-2">
              <button
                onClick={handlePrevWeek}
                className="p-1.5 rounded-xl border border-slate-200 hover:bg-slate-50 text-slate-600 cursor-pointer transition"
                title="Tuần trước"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button
                onClick={handleCurrentWeek}
                className="px-3 py-1 rounded-xl text-xs font-bold border border-slate-200 hover:bg-slate-50 text-slate-700 cursor-pointer transition"
              >
                Tuần này
              </button>
              <button
                onClick={handleNextWeek}
                className="p-1.5 rounded-xl border border-slate-200 hover:bg-slate-50 text-slate-600 cursor-pointer transition"
                title="Tuần sau"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>

            <div className="font-extrabold text-sm text-slate-800 tracking-tight flex items-center gap-2">
              <CalendarDays className="w-4 h-4 text-indigo-600" />
              <span>{weekTitle}</span>
            </div>

            <span className="text-xs text-slate-400 font-medium hidden sm:inline">
              Lưới 7 ngày (Thứ 2 - Chủ Nhật)
            </span>
          </div>

          {/* Timetable Grid Table */}
          <div className="bg-white rounded-2xl border border-slate-200/90 shadow-2xs overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse min-w-[900px]">
                <thead>
                  <tr className="bg-slate-50 border-b border-slate-200 text-xs font-bold text-slate-600">
                    <th className="p-3 w-32 border-r border-slate-200 text-center uppercase tracking-wider text-[11px]">
                      Ca học
                    </th>
                    {weekDays.map((d, i) => {
                      const dStr = d.toISOString().split('T')[0];
                      const isToday = dStr === todayStr;
                      return (
                        <th
                          key={i}
                          className={`p-3 text-center border-r border-slate-200 last:border-r-0 ${
                            isToday ? 'bg-indigo-50/70 text-indigo-900 font-black' : ''
                          }`}
                        >
                          <div className="text-xs uppercase">{formatDateVN(d)}</div>
                          <div className={`text-[11px] font-mono mt-0.5 ${isToday ? 'text-indigo-600 font-extrabold' : 'text-slate-400'}`}>
                            {dStr}
                          </div>
                        </th>
                      );
                    })}
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-xs">
                  {TIME_SLOTS.map((slot, slotIdx) => (
                    <tr key={slotIdx} className="hover:bg-slate-50/40 transition">
                      {/* Slot Header column */}
                      <td className="p-3 bg-slate-50/60 border-r border-slate-200 text-center font-bold text-slate-700 align-top">
                        <div className="font-mono text-xs text-indigo-700">{slot.start} - {slot.end}</div>
                        <div className="text-[10px] text-slate-400 font-medium mt-0.5">{slot.label.split(' ')[0]}</div>
                      </td>

                      {/* 7 Days columns */}
                      {weekDays.map((d, dayIdx) => {
                        const dateStr = d.toISOString().split('T')[0];
                        const isToday = dateStr === todayStr;

                        // Find sessions matching this date and time range
                        const cellSessions = filteredSchedules.filter(s => {
                          if (s.session_date !== dateStr) return false;
                          // match slot start/end or overlap
                          return s.start_time >= slot.start && s.start_time < slot.end;
                        });

                        return (
                          <td
                            key={dayIdx}
                            className={`p-2 border-r border-slate-100 last:border-r-0 align-top h-32 ${
                              isToday ? 'bg-indigo-50/15' : ''
                            }`}
                          >
                            <div className="space-y-2 h-full flex flex-col">
                              {cellSessions.map(session => {
                                const isPast = session.session_date < todayStr;
                                const isCancelled = session.status === 'CANCELLED';

                                return (
                                  <div
                                    key={session.id}
                                    className={`p-2.5 rounded-xl border text-xs shadow-2xs transition-all relative group ${
                                      isCancelled
                                        ? 'bg-slate-100 border-slate-300 opacity-60 text-slate-500'
                                        : isPast
                                        ? 'bg-slate-50 border-slate-200 text-slate-700'
                                        : 'bg-indigo-50/60 border-indigo-200 text-indigo-950 hover:border-indigo-400 hover:shadow-xs'
                                    }`}
                                  >
                                    <div className="flex items-center justify-between gap-1 mb-1">
                                      <span className="font-mono font-black text-indigo-700 text-xs">
                                        {session.class_code}
                                      </span>
                                      {session.is_confirmed ? (
                                        <span className="text-[9px] font-bold bg-emerald-100 text-emerald-800 px-1.5 py-0.2 rounded">
                                          Đã duyệt
                                        </span>
                                      ) : (
                                        <span className="text-[9px] font-bold bg-amber-100 text-amber-800 px-1.5 py-0.2 rounded">
                                          Nháp
                                        </span>
                                      )}
                                    </div>

                                    <div className="font-semibold text-slate-800 truncate text-[11px]" title={session.course_title}>
                                      {session.course_title}
                                    </div>

                                    <div className="mt-1.5 space-y-0.5 text-[10px] text-slate-500">
                                      <div className="flex items-center gap-1">
                                        <Clock className="w-3 h-3 text-slate-400" />
                                        <span className="font-mono">{session.start_time} - {session.end_time}</span>
                                      </div>
                                      <div className="flex items-center gap-1 font-semibold text-amber-800">
                                        <MapPin className="w-3 h-3 text-amber-600" />
                                        <span>{session.room_code}</span>
                                      </div>
                                      <div className="flex items-center gap-1 text-slate-700">
                                        <UserCheck className="w-3 h-3 text-indigo-500" />
                                        <span className="truncate">{session.teacher_name}</span>
                                      </div>
                                    </div>

                                    {/* Action buttons on card hover for Admin/Staff */}
                                    {canManage && (
                                      <div className="mt-2 pt-1.5 border-t border-slate-200/80 flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition">
                                        <button
                                          onClick={() => handleOpenEdit(session)}
                                          className="p-1 text-slate-600 hover:text-indigo-600 hover:bg-white rounded transition cursor-pointer"
                                          title="Sửa buổi học"
                                        >
                                          <Edit2 className="w-3 h-3" />
                                        </button>
                                        <button
                                          onClick={() => handleCancelSession(session.id)}
                                          className="p-1 text-slate-600 hover:text-amber-600 hover:bg-white rounded transition cursor-pointer"
                                          title="Hủy buổi học"
                                        >
                                          <Ban className="w-3 h-3" />
                                        </button>
                                        <button
                                          onClick={() => handleDeleteSession(session.id)}
                                          className="p-1 text-slate-600 hover:text-rose-600 hover:bg-white rounded transition cursor-pointer"
                                          title="Xóa buổi học"
                                        >
                                          <Trash2 className="w-3 h-3" />
                                        </button>
                                      </div>
                                    )}
                                  </div>
                                );
                              })}

                              {/* Quick add placeholder when empty and can manage */}
                              {cellSessions.length === 0 && canManage && (
                                <button
                                  onClick={() => handleQuickAdd(dateStr, slot)}
                                  className="w-full h-full min-h-[50px] border border-dashed border-slate-200 hover:border-indigo-400 rounded-xl flex items-center justify-center text-slate-300 hover:text-indigo-600 hover:bg-indigo-50/30 transition cursor-pointer group"
                                  title={`Thêm buổi học vào ngày ${dateStr}`}
                                >
                                  <Plus className="w-4 h-4 opacity-0 group-hover:opacity-100 transition" />
                                </button>
                              )}
                            </div>
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* List View Mode */}
      {viewMode === 'list' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-2xs overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-600 uppercase text-[11px]">
                <tr>
                  <th className="p-4">Ngày học</th>
                  <th className="p-4">Khung giờ buổi học</th>
                  <th className="p-4">Lớp học</th>
                  <th className="p-4">Phòng học</th>
                  <th className="p-4">Giáo viên phụ trách</th>
                  <th className="p-4">Trạng thái phê duyệt</th>
                  {canManage && <th className="p-4 text-right">Thao tác</th>}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredSchedules.length === 0 ? (
                  <tr>
                    <td colSpan={canManage ? 7 : 6} className="p-8 text-center text-slate-400 font-medium">
                      Không có buổi học nào phù hợp với bộ lọc hiện tại.
                    </td>
                  </tr>
                ) : (
                  filteredSchedules.map((s) => {
                    const isPast = s.session_date < todayStr;
                    return (
                      <tr key={s.id} className="hover:bg-slate-50/80 transition-colors">
                        <td className="p-4 font-bold text-slate-900">
                          <div className="flex items-center gap-1.5">
                            <span>
                              {new Date(s.session_date).toLocaleDateString('vi-VN', {
                                weekday: 'short',
                                year: 'numeric',
                                month: 'numeric',
                                day: 'numeric',
                              })}
                            </span>
                            {isPast ? (
                              <span className="text-[10px] font-semibold text-slate-500 bg-slate-100 px-2 py-0.5 rounded-full">
                                Đã qua
                              </span>
                            ) : (
                              <span className="text-[10px] font-semibold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded-full border border-indigo-100">
                                Sắp tới
                              </span>
                            )}
                          </div>
                        </td>
                        <td className="p-4">
                          <div className="font-mono font-bold text-slate-800 flex items-center gap-1.5 tabular-nums">
                            <Clock className="w-3.5 h-3.5 text-indigo-500" /> {s.start_time} - {s.end_time}
                          </div>
                          <span className="text-[10px] text-slate-400 font-medium">{s.slot_name}</span>
                        </td>
                        <td className="p-4">
                          <div className="font-mono font-bold text-indigo-700">{s.class_code}</div>
                          <div className="text-[11px] text-slate-500 truncate max-w-xs">{s.course_title}</div>
                        </td>
                        <td className="p-4">
                          <span className="inline-flex items-center gap-1.5 font-bold bg-amber-50 text-amber-800 px-2.5 py-1 rounded-lg border border-amber-200/80">
                            <MapPin className="w-3 h-3 text-amber-600" /> {s.room_code}
                          </span>
                        </td>
                        <td className="p-4 font-semibold text-slate-800">
                          <div className="flex items-center gap-1.5">
                            <UserCheck className="w-3.5 h-3.5 text-indigo-500" /> {s.teacher_name}
                          </div>
                        </td>
                        <td className="p-4">
                          {s.is_confirmed ? (
                            <span className="inline-flex items-center gap-1.5 text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200">
                              <CheckCircle className="w-3.5 h-3.5" /> Đã xác nhận chính thức
                            </span>
                          ) : (
                            <div className="flex items-center gap-2">
                              <span className="text-[11px] font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200/60">
                                Bản nháp
                              </span>
                              {canManage && (
                                <button
                                  onClick={() => handleConfirmSchedule(s.class_id)}
                                  className="text-[10px] bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-bold px-2.5 py-1 rounded-lg border border-indigo-200 cursor-pointer transition"
                                >
                                  Xác nhận áp dụng
                                </button>
                              )}
                            </div>
                          )}
                        </td>
                        {canManage && (
                          <td className="p-4 text-right">
                            <div className="flex items-center justify-end gap-1.5">
                              <button
                                onClick={() => handleOpenEdit(s)}
                                className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition cursor-pointer"
                                title="Sửa thông tin buổi học"
                              >
                                <Edit2 className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleCancelSession(s.id)}
                                className="p-1.5 text-slate-500 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition cursor-pointer"
                                title="Hủy buổi học"
                              >
                                <Ban className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleDeleteSession(s.id)}
                                className="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition cursor-pointer"
                                title="Xóa buổi học"
                              >
                                <Trash2 className="w-4 h-4" />
                              </button>
                            </div>
                          </td>
                        )}
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Live Conflict Checker Standalone Box (FR-65) */}
      {canManage && (
        <div className="bg-gradient-to-br from-white to-indigo-50/30 rounded-3xl border border-indigo-100 p-6 shadow-2xs">
          <div className="flex items-center gap-2 text-indigo-900 font-extrabold text-sm mb-1.5">
            <ShieldCheck className="w-4 h-4 text-indigo-600" />
            Công cụ phát hiện xung đột lịch thời gian thực (Thuật toán FR-65)
          </div>
          <p className="text-xs text-slate-500 mb-5 leading-relaxed">
            Hệ thống tự động rà soát va chạm thời gian giữa phòng học và giáo viên phụ trách để ngăn chặn xếp trùng lịch.
          </p>

          <form onSubmit={handleTestConflict} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3.5 text-xs">
            <div>
              <label className="font-bold text-slate-700 block mb-1">Phòng học kiểm tra:</label>
              <select
                value={checkForm.classroom_id}
                onChange={(e) => setCheckForm({ ...checkForm, classroom_id: Number(e.target.value) })}
                className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
              >
                {classrooms.map((r) => (
                  <option key={r.id} value={r.id}>
                    {r.room_code} ({r.building})
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="font-bold text-slate-700 block mb-1">Giảng viên giảng dạy:</label>
              <select
                value={checkForm.teacher_id}
                onChange={(e) => setCheckForm({ ...checkForm, teacher_id: Number(e.target.value) })}
                className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
              >
                {teachers.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.full_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="font-bold text-slate-700 block mb-1">Ngày học dự kiến:</label>
              <input
                type="date"
                value={checkForm.session_date}
                onChange={(e) => setCheckForm({ ...checkForm, session_date: e.target.value })}
                className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
              />
            </div>
            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Bắt đầu:</label>
                <input
                  type="text"
                  value={checkForm.start_time}
                  onChange={(e) => setCheckForm({ ...checkForm, start_time: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-mono font-medium outline-hidden focus:border-indigo-600 text-center"
                />
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Kết thúc:</label>
                <input
                  type="text"
                  value={checkForm.end_time}
                  onChange={(e) => setCheckForm({ ...checkForm, end_time: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-mono font-medium outline-hidden focus:border-indigo-600 text-center"
                />
              </div>
            </div>
            <div className="flex items-end">
              <button
                type="submit"
                className="w-full bg-slate-900 hover:bg-slate-800 text-white p-2.5 rounded-xl font-bold transition shadow-xs cursor-pointer"
              >
                Kiểm tra xung đột
              </button>
            </div>
          </form>

          {/* Conflict Result Banner */}
          {conflictResult && (
            <div
              className={`mt-4 p-4 rounded-2xl border text-xs flex items-start gap-3 transition-all ${
                conflictResult.has_conflict
                  ? 'bg-rose-50 border-rose-200 text-rose-900'
                  : 'bg-emerald-50 border-emerald-200 text-emerald-900'
              }`}
            >
              {conflictResult.has_conflict ? (
                <AlertTriangle className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
              ) : (
                <CheckCircle className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
              )}
              <div>
                <span className="font-extrabold text-sm block">
                  {conflictResult.has_conflict ? 'Phát hiện xung đột lịch học!' : 'Lịch hoàn toàn hợp lệ!'}
                </span>
                <p className="mt-1 leading-relaxed">{conflictResult.message}</p>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Modal: Thêm buổi học mới */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-lg font-black text-slate-900">
                Thêm Buổi học vào Thời khóa biểu
              </h3>
              <button
                onClick={() => setShowAddModal(false)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateSession} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Chọn Lớp học:</label>
                <select
                  required
                  value={addForm.class_id}
                  onChange={(e) => setAddForm({ ...addForm, class_id: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                >
                  <option value="">-- Chọn lớp học --</option>
                  {classesList.map(c => (
                    <option key={c.id} value={c.id}>
                      {c.class_code} - {c.course_title} ({c.current_enrolled}/{c.max_capacity} HV)
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Phòng học:</label>
                  <select
                    required
                    value={addForm.classroom_id}
                    onChange={(e) => setAddForm({ ...addForm, classroom_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    {classrooms.map(r => (
                      <option key={r.id} value={r.id}>
                        {r.room_code} ({r.building}) - {r.capacity} chỗ
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giảng viên giảng dạy:</label>
                  <select
                    required
                    value={addForm.teacher_id}
                    onChange={(e) => setAddForm({ ...addForm, teacher_id: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    {teachers.map(t => (
                      <option key={t.id} value={t.id}>{t.full_name}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Ngày diễn ra buổi học:</label>
                <input
                  type="date"
                  required
                  value={addForm.session_date}
                  onChange={(e) => setAddForm({ ...addForm, session_date: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              {/* Preset Slots */}
              <div>
                <label className="font-bold text-slate-700 block mb-1">Chọn khung ca học chuẩn:</label>
                <div className="grid grid-cols-2 gap-2">
                  {TIME_SLOTS.map((slot, i) => (
                    <button
                      type="button"
                      key={i}
                      onClick={() => setAddForm({
                        ...addForm,
                        start_time: slot.start,
                        end_time: slot.end,
                        slot_name: slot.label,
                      })}
                      className={`p-2 rounded-xl border text-[11px] font-semibold text-left transition cursor-pointer ${
                        addForm.start_time === slot.start && addForm.end_time === slot.end
                          ? 'border-indigo-600 bg-indigo-50/70 text-indigo-700 font-bold'
                          : 'border-slate-200 hover:bg-slate-50 text-slate-700'
                      }`}
                    >
                      {slot.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giờ bắt đầu:</label>
                  <input
                    type="text"
                    required
                    value={addForm.start_time}
                    onChange={(e) => setAddForm({ ...addForm, start_time: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-mono font-medium outline-hidden focus:border-indigo-600 text-center"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giờ kết thúc:</label>
                  <input
                    type="text"
                    required
                    value={addForm.end_time}
                    onChange={(e) => setAddForm({ ...addForm, end_time: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-mono font-medium outline-hidden focus:border-indigo-600 text-center"
                  />
                </div>
              </div>

              {/* Conflict Status check feedback */}
              {modalConflict && modalConflict.has_conflict && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-900 text-xs flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-rose-600 shrink-0" />
                  <span>{modalConflict.message}</span>
                </div>
              )}

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
                  Lưu buổi học
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Sửa buổi học */}
      {showEditModal && editingSession && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div>
                <h3 className="text-lg font-black text-slate-900">
                  Điều chỉnh Buổi học: {editingSession.class_code}
                </h3>
                <span className="text-xs text-slate-400 font-medium">{editingSession.course_title}</span>
              </div>
              <button
                onClick={() => {
                  setShowEditModal(false);
                  setEditingSession(null);
                }}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleUpdateSession} className="space-y-3.5 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Phòng học:</label>
                  <select
                    value={editForm.classroom_id}
                    onChange={(e) => setEditForm({ ...editForm, classroom_id: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    {classrooms.map(r => (
                      <option key={r.id} value={r.id}>
                        {r.room_code} ({r.building})
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giảng viên giảng dạy:</label>
                  <select
                    value={editForm.teacher_id}
                    onChange={(e) => setEditForm({ ...editForm, teacher_id: Number(e.target.value) })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  >
                    {teachers.map(t => (
                      <option key={t.id} value={t.id}>{t.full_name}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Ngày học:</label>
                <input
                  type="date"
                  value={editForm.session_date}
                  onChange={(e) => setEditForm({ ...editForm, session_date: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giờ bắt đầu:</label>
                  <input
                    type="text"
                    value={editForm.start_time}
                    onChange={(e) => setEditForm({ ...editForm, start_time: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-mono font-medium outline-hidden focus:border-indigo-600 text-center"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Giờ kết thúc:</label>
                  <input
                    type="text"
                    value={editForm.end_time}
                    onChange={(e) => setEditForm({ ...editForm, end_time: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-mono font-medium outline-hidden focus:border-indigo-600 text-center"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Tên ca học:</label>
                  <input
                    type="text"
                    value={editForm.slot_name}
                    onChange={(e) => setEditForm({ ...editForm, slot_name: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-medium outline-hidden focus:border-indigo-600"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Trạng thái buổi học:</label>
                  <select
                    value={editForm.status}
                    onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-semibold outline-hidden focus:border-indigo-600"
                  >
                    <option value="ACTIVE">Hoạt động (ACTIVE)</option>
                    <option value="CANCELLED">Đã hủy (CANCELLED)</option>
                  </select>
                </div>
              </div>

              {/* Conflict Status feedback */}
              {modalConflict && modalConflict.has_conflict && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-900 text-xs flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-rose-600 shrink-0" />
                  <span>{modalConflict.message}</span>
                </div>
              )}

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => {
                    setShowEditModal(false);
                    setEditingSession(null);
                  }}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer"
                >
                  Cập nhật thay đổi
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
