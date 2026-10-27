import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { useConfirm } from '../context/ConfirmDialogContext';
import { useHeaderSlot } from '../context/HeaderSlotContext';
import { accountsApi } from '../services/api';
import { UserAvatar } from '../components/common/UserAvatar';
import {
  Plus,
  Search,
  KeyRound,
  Edit2,
  Trash2,
  ShieldCheck,
  ShieldAlert,
  UserCheck,
  UserX,
  Lock,
  Unlock,
  Phone,
  Mail,
  Sparkles,
  Shield,
  ArrowUpRight,
  CheckCircle2,
  AlertTriangle,
  Copy,
  Check,
  Users,
  GraduationCap,
  BookOpen
} from 'lucide-react';

export const AccountsView = () => {
  const { user } = useAuth();
  const toast = useToast();
  const confirm = useConfirm();
  const isAdmin = user?.role === 'ADMIN';
  const headerSlot = useHeaderSlot();
  const canManage = ['ADMIN', 'ACADEMIC_STAFF'].includes(user?.role || '');

  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL'); // ALL, ACTIVE, LOCKED
  const [isLoading, setIsLoading] = useState(false);

  // Modals state
  const [showAddModal, setShowAddModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [showRoleModal, setShowRoleModal] = useState(false);
  const [showResetPwdModal, setShowResetPwdModal] = useState(false);

  // Selected users for operations
  const [editingUser, setEditingUser] = useState(null);
  const [targetUserForRole, setTargetUserForRole] = useState(null);
  const [newSelectedRole, setNewSelectedRole] = useState('STUDENT');
  const [targetUserForPwd, setTargetUserForPwd] = useState(null);
  // Modal danh sách học sinh liên quan (Yêu cầu 5)
  const [relatedModal, setRelatedModal] = useState({
    isOpen: false,
    user: null,
    students: [],
    isLoading: false,
  });

  const handleOpenRelatedStudents = async (u) => {
    setRelatedModal({ isOpen: true, user: u, students: [], isLoading: true });
    try {
      const res = await accountsApi.getRelatedStudents(u.id);
      setRelatedModal({ isOpen: true, user: u, students: res.data || [], isLoading: false });
    } catch (e) {
      toast.error('Lỗi khi tải học sinh liên quan: ' + e.message);
      setRelatedModal({ isOpen: false, user: null, students: [], isLoading: false });
    }
  };
  const [adminNewPassword, setAdminNewPassword] = useState('SmartEdu@2026');
  const [copied, setCopied] = useState(false);

  // Form states
  const [newUser, setNewUser] = useState({
    username: '',
    email: '',
    full_name: '',
    password: '',
    role: 'STUDENT',
    phone: '',
  });

  const [editUserForm, setEditUserForm] = useState({
    full_name: '',
    email: '',
    phone: '',
    is_active: true,
  });

  const [passwordForm, setPasswordForm] = useState({
    old_password: '',
    new_password: '',
  });

  // Load accounts list
  const loadAccounts = async () => {
    setIsLoading(true);
    try {
      const res = await accountsApi.list(search, roleFilter || undefined);
      setUsers(res.data || []);
    } catch (e) {
      console.error(e);
      toast.error('Lỗi tải danh sách tài khoản: ' + e.message);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadAccounts();
  }, [search, roleFilter]);

  // Handle Add Account
  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await accountsApi.create({
        username: newUser.username.trim(),
        email: newUser.email.trim(),
        full_name: newUser.full_name.trim(),
        password: newUser.password,
        role: newUser.role,
        phone: newUser.phone ? newUser.phone.trim() : null,
      });
      toast.success('Tạo tài khoản mới thành công!');
      setShowAddModal(false);
      setNewUser({
        username: '',
        email: '',
        full_name: '',
        password: '',
        role: 'STUDENT',
        phone: '',
      });
      loadAccounts();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Handle Open Edit
  const handleOpenEdit = (u) => {
    setEditingUser(u);
    setEditUserForm({
      full_name: u.full_name,
      email: u.email,
      phone: u.phone || '',
      avatar_url: u.avatar_url || '',
      is_active: u.is_active,
    });
    setShowEditModal(true);
  };

  // Handle Update Profile
  const handleUpdate = async (e) => {
    e.preventDefault();
    try {
      await accountsApi.update(editingUser.id, {
        full_name: editUserForm.full_name.trim(),
        email: editUserForm.email.trim(),
        phone: editUserForm.phone ? editUserForm.phone.trim() : null,
        avatar_url: editUserForm.avatar_url ? editUserForm.avatar_url.trim() : null,
        is_active: editUserForm.is_active,
      });
      toast.success(`Cập nhật thông tin tài khoản ${editingUser.username} thành công!`);
      setShowEditModal(false);
      setEditingUser(null);
      loadAccounts();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Handle Promote / Change Role
  const handleOpenRoleModal = (u) => {
    setTargetUserForRole(u);
    setNewSelectedRole(u.role);
    setShowRoleModal(true);
  };

  const handleUpdateRole = async (e) => {
    e.preventDefault();
    if (!targetUserForRole) return;
    try {
      await accountsApi.updateRole(targetUserForRole.id, newSelectedRole);
      toast.success(`Đã nâng/đổi quyền tài khoản "${targetUserForRole.username}" sang "${newSelectedRole}" thành công!`);
      setShowRoleModal(false);
      setTargetUserForRole(null);
      loadAccounts();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Handle Lock / Unlock Account
  const handleToggleLock = async (u) => {
    if (u.id === user?.id) {
      toast.warning('Bạn không thể tự khóa tài khoản của chính mình!');
      return;
    }
    const isCurrentlyLocked = !u.is_active || u.is_locked;
    const actionName = isCurrentlyLocked ? 'Mở khóa' : 'Khóa';
    const isConfirmed = await confirm({
      title: `${actionName} tài khoản người dùng`,
      message: `Bạn có chắc chắn muốn ${actionName.toLowerCase()} tài khoản "${u.username}" (${u.full_name})?`,
      confirmText: actionName,
      cancelText: 'Hủy bỏ',
      type: isCurrentlyLocked ? 'info' : 'warning',
    });
    if (!isConfirmed) return;

    try {
      const res = await accountsApi.toggleLock(u.id);
      toast.success(res.message || `Đã ${actionName.toLowerCase()} tài khoản thành công!`);
      loadAccounts();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Handle Admin Reset Password
  const handleOpenResetPwdModal = (u) => {
    setTargetUserForPwd(u);
    setAdminNewPassword('SmartEdu@2026');
    setShowResetPwdModal(true);
  };

  const generateRandomPassword = () => {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%';
    let pass = 'Edu@';
    for (let i = 0; i < 6; i++) {
      pass += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    setAdminNewPassword(pass);
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(adminNewPassword);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleAdminResetPassword = async (e) => {
    e.preventDefault();
    if (!targetUserForPwd) return;
    if (adminNewPassword.length < 6) {
      toast.warning('Mật khẩu mới phải có tối thiểu 6 ký tự!');
      return;
    }
    try {
      await accountsApi.adminResetPassword(targetUserForPwd.id, adminNewPassword);
      toast.success(`Đã cấp lại mật khẩu cho tài khoản "${targetUserForPwd.username}" thành công! Mật khẩu mới: ${adminNewPassword}`);
      setShowResetPwdModal(false);
      setTargetUserForPwd(null);
      loadAccounts();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Handle Delete Account
  const handleDelete = async (userId, username) => {
    if (userId === user?.id) {
      toast.warning('Bạn không thể tự xóa tài khoản đang đăng nhập!');
      return;
    }
    const isConfirmed = await confirm({
      title: 'Xóa tài khoản người dùng',
      message: `Bạn có chắc chắn muốn XÓA tài khoản "${username}"? Dữ liệu người dùng sẽ được lưu trữ an toàn (soft delete) và tài khoản sẽ bị vô hiệu hóa.`,
      confirmText: 'Xác nhận xóa',
      cancelText: 'Hủy bỏ',
      type: 'danger',
    });
    if (!isConfirmed) return;
    try {
      await accountsApi.delete(userId);
      toast.success(`Đã xóa tài khoản ${username} thành công!`);
      loadAccounts();
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Handle Personal Change Password
  const handleChangePassword = async (e) => {
    e.preventDefault();
    try {
      await accountsApi.changePassword(passwordForm.old_password, passwordForm.new_password);
      toast.success('Đổi mật khẩu tài khoản thành công!');
      setShowPasswordModal(false);
      setPasswordForm({ old_password: '', new_password: '' });
    } catch (e) {
      toast.error(e.message);
    }
  };

  // Filter accounts by status
  const filteredUsers = users.filter((u) => {
    if (statusFilter === 'ACTIVE') return u.is_active && !u.is_locked;
    if (statusFilter === 'LOCKED') return !u.is_active || u.is_locked;
    return true;
  });

  // KPI Metrics
  const totalCount = users.length;
  const activeCount = users.filter((u) => u.is_active && !u.is_locked).length;
  const lockedCount = users.filter((u) => !u.is_active || u.is_locked).length;
  const adminStaffCount = users.filter((u) => ['ADMIN', 'ACADEMIC_STAFF'].includes(u.role)).length;

  const getRoleBadge = (role) => {
    switch (role) {
      case 'ADMIN':
        return 'bg-rose-50 text-rose-700 border-rose-200';
      case 'ACADEMIC_STAFF':
        return 'bg-purple-50 text-purple-700 border-purple-200';
      case 'TEACHER':
        return 'bg-sky-50 text-sky-700 border-sky-200';
      case 'STUDENT':
        return 'bg-emerald-50 text-emerald-700 border-emerald-200';
      case 'PARENT':
        return 'bg-amber-50 text-amber-800 border-amber-200';
      default:
        return 'bg-slate-100 text-slate-700 border-slate-200';
    }
  };

  const getRoleLabel = (role) => {
    switch (role) {
      case 'ADMIN':
        return '👑 Quản trị viên';
      case 'ACADEMIC_STAFF':
        return '📋 Nhân viên học vụ';
      case 'TEACHER':
        return '🎓 Giảng viên';
      case 'STUDENT':
        return '🎒 Học viên';
      case 'PARENT':
        return '👨‍👩‍👧 Phụ huynh';
      default:
        return role;
    }
  };

  return (
    <div className="space-y-6">
      {/* Top Header Action Buttons */}
      {headerSlot && createPortal(
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setShowPasswordModal(true)}
            className="flex items-center gap-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 px-3 py-1.5 rounded-xl text-xs font-bold cursor-pointer transition active:scale-95 border border-slate-200/80"
          >
            <KeyRound className="w-3.5 h-3.5 text-slate-500" />
            <span>Đổi mật khẩu</span>
          </button>
          {canManage && (
            <button
              type="button"
              onClick={() => setShowAddModal(true)}
              className="flex items-center gap-1.5 bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-700 hover:to-indigo-600 active:scale-95 text-white px-3.5 py-1.5 rounded-xl text-xs font-bold shadow-xs shadow-indigo-200 cursor-pointer transition"
            >
              <Plus className="w-4 h-4" />
              <span>Thêm tài khoản mới</span>
            </button>
          )}
        </div>,
        headerSlot
      )}

      {/* KPI METRICS CARDS */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Tổng tài khoản</p>
            <p className="text-2xl font-black text-slate-900 mt-1">{totalCount}</p>
          </div>
          <div className="w-11 h-11 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
            <Users className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Đang hoạt động</p>
            <p className="text-2xl font-black text-emerald-600 mt-1">{activeCount}</p>
          </div>
          <div className="w-11 h-11 rounded-2xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600">
            <UserCheck className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Đang bị khóa / Tạm dừng</p>
            <p className="text-2xl font-black text-rose-600 mt-1">{lockedCount}</p>
          </div>
          <div className="w-11 h-11 rounded-2xl bg-rose-50 border border-rose-100 flex items-center justify-center text-rose-600">
            <Lock className="w-5 h-5" />
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center justify-between">
          <div>
            <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Quản trị & Học vụ</p>
            <p className="text-2xl font-black text-purple-600 mt-1">{adminStaffCount}</p>
          </div>
          <div className="w-11 h-11 rounded-2xl bg-purple-50 border border-purple-100 flex items-center justify-center text-purple-600">
            <Shield className="w-5 h-5" />
          </div>
        </div>
      </div>

      {/* FILTER & SEARCH CONTROLS */}
      <div className="grid grid-cols-1 sm:grid-cols-12 gap-3">
        <div className="sm:col-span-6 bg-white p-3 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center gap-2.5">
          <Search className="w-4 h-4 text-slate-400 shrink-0 ml-1" />
          <input
            type="text"
            placeholder="Tìm kiếm tài khoản theo username, email, họ tên..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full text-xs outline-hidden text-slate-800 placeholder:text-slate-400 font-medium"
          />
        </div>

        <div className="sm:col-span-3 bg-white p-2.5 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center">
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="w-full text-xs font-semibold text-slate-700 bg-white outline-hidden cursor-pointer"
          >
            <option value="">-- Tất cả vai trò --</option>
            <option value="ADMIN">Quản trị viên (ADMIN)</option>
            <option value="ACADEMIC_STAFF">Nhân viên học vụ (ACADEMIC_STAFF)</option>
            <option value="TEACHER">Giáo viên (TEACHER)</option>
            <option value="STUDENT">Học viên (STUDENT)</option>
            <option value="PARENT">Phụ huynh (PARENT)</option>
          </select>
        </div>

        <div className="sm:col-span-3 bg-white p-2.5 rounded-2xl border border-slate-200/90 shadow-2xs flex items-center">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full text-xs font-semibold text-slate-700 bg-white outline-hidden cursor-pointer"
          >
            <option value="ALL">-- Tất cả trạng thái --</option>
            <option value="ACTIVE">🟢 Đang hoạt động ({activeCount})</option>
            <option value="LOCKED">🔒 Đang bị khóa ({lockedCount})</option>
          </select>
        </div>
      </div>

      {/* ACCOUNTS DATA TABLE */}
      <div className="bg-white rounded-3xl border border-slate-200/90 shadow-2xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 border-b border-slate-200/80 font-bold text-slate-500 uppercase text-[11px] tracking-wider">
              <tr>
                <th className="p-4 pl-5">Người dùng / Định danh</th>
                <th className="p-4">Email & Liên hệ</th>
                <th className="p-4">Vai trò (Role)</th>
                <th className="p-4">Trạng thái Khóa / An ninh</th>
                <th className="p-4 pr-5 text-right">Thao tác Quản trị</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center text-slate-400 font-medium">
                    <ShieldAlert className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                    Không tìm thấy tài khoản người dùng nào phù hợp.
                  </td>
                </tr>
              ) : (
                filteredUsers.map((u) => {
                  const isLockedByAdmin = !u.is_active;
                  const isLockedByFailedAttempts = u.is_locked && u.is_active;
                  const isNormalActive = u.is_active && !u.is_locked;

                  return (
                    <tr key={u.id} className="hover:bg-slate-50/70 transition-colors">
                      {/* USER IDENTITY */}
                      <td className="p-4 pl-5">
                        <div className="flex items-center gap-3">
                          <UserAvatar
                            avatarUrl={u.avatar_url}
                            name={u.full_name}
                            role={u.role}
                            size="md"
                            shape="rounded-2xl"
                          />
                          <div>
                            <div className="flex items-center gap-1.5">
                              <span className="font-bold text-slate-900 text-xs">{u.full_name}</span>
                              {u.id === user?.id && (
                                <span className="text-[10px] bg-indigo-50 text-indigo-700 border border-indigo-200 px-1.5 py-0.2 rounded-md font-bold">
                                  Bạn
                                </span>
                              )}
                            </div>
                            <div className="flex items-center gap-2 mt-0.5">
                              <span className="font-mono text-[11px] font-bold text-indigo-600 bg-indigo-50/70 px-1.5 py-0.2 rounded-md">
                                @{u.username}
                              </span>
                              <span className="text-[10px] text-slate-400 font-mono">#{u.id}</span>
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* CONTACT */}
                      <td className="p-4">
                        <div className="space-y-1">
                          <div className="flex items-center gap-1.5 text-slate-600">
                            <Mail className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                            <span className="truncate max-w-[200px]">{u.email}</span>
                          </div>
                          {u.phone ? (
                            <div className="flex items-center gap-1.5 text-slate-500 text-[11px]">
                              <Phone className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                              <span>{u.phone}</span>
                            </div>
                          ) : (
                            <span className="text-[11px] text-slate-400 italic">Chưa có SĐT</span>
                          )}
                        </div>
                      </td>

                      {/* ROLE BADGE */}
                      <td className="p-4">
                        <div className="flex items-center gap-2">
                          <span className={`inline-flex items-center gap-1.5 font-bold text-[11px] px-2.5 py-1 rounded-xl border ${getRoleBadge(u.role)}`}>
                            {getRoleLabel(u.role)}
                          </span>
                        </div>
                      </td>

                      {/* LOCK / SECURITY STATUS */}
                      <td className="p-4">
                        {isLockedByAdmin && (
                          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                            <Lock className="w-3.5 h-3.5 text-rose-600" />
                            <span>Đã bị Admin khóa</span>
                          </div>
                        )}
                        {isLockedByFailedAttempts && (
                          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-[11px] font-bold bg-amber-50 text-amber-800 border border-amber-200">
                            <AlertTriangle className="w-3.5 h-3.5 text-amber-600 animate-pulse" />
                            <span>Khóa tạm thời 15p (Sai 5 lần)</span>
                          </div>
                        )}
                        {isNormalActive && (
                          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                            <span>Đang hoạt động</span>
                          </div>
                        )}
                      </td>

                      {/* ACTIONS */}
                      <td className="p-4 pr-5 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          {/* NÂNG / ĐỔI QUYỀN (ADMIN ONLY) */}
                          {isAdmin && (
                            <button
                              onClick={() => handleOpenRoleModal(u)}
                              className="px-2.5 py-1.5 text-slate-700 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer border border-slate-200/80 hover:border-indigo-200 font-bold text-[11px] flex items-center gap-1 active:scale-95"
                              title="Nâng quyền / Đổi vai trò tài khoản"
                            >
                              <Shield className="w-3.5 h-3.5 text-indigo-600" />
                              <span className="hidden md:inline">Đổi quyền</span>
                            </button>
                          )}

                          {/* KHÓA / MỞ KHÓA TỨC THÌ (ADMIN ONLY) */}
                          {isAdmin && u.id !== user?.id && (
                            <button
                              onClick={() => handleToggleLock(u)}
                              className={`px-2.5 py-1.5 rounded-xl transition cursor-pointer border font-bold text-[11px] flex items-center gap-1 active:scale-95 ${
                                !u.is_active || u.is_locked
                                  ? 'bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border-emerald-200'
                                  : 'bg-rose-50 hover:bg-rose-100 text-rose-700 border-rose-200'
                              }`}
                              title={!u.is_active || u.is_locked ? 'Mở khóa tài khoản ngay' : 'Khóa tài khoản này'}
                            >
                              {!u.is_active || u.is_locked ? (
                                <>
                                  <Unlock className="w-3.5 h-3.5 text-emerald-600" />
                                  <span className="hidden md:inline">Mở khóa</span>
                                </>
                              ) : (
                                <>
                                  <Lock className="w-3.5 h-3.5 text-rose-600" />
                                  <span className="hidden md:inline">Khóa</span>
                                </>
                              )}
                            </button>
                          )}

                          {/* XEM HỌC SINH LIÊN QUAN (Yêu cầu 5) */}
                          {['PARENT', 'TEACHER', 'STUDENT'].includes(u.role) && (
                            <button
                              onClick={() => handleOpenRelatedStudents(u)}
                              className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer border border-slate-200/80 hover:border-indigo-200 active:scale-95"
                              title="Xem danh sách học sinh liên quan đến tài khoản này"
                            >
                              <Users className="w-3.5 h-3.5" />
                            </button>
                          )}

                          {/* SỬA THÔNG TIN */}
                          {canManage && (
                            <button
                              onClick={() => handleOpenEdit(u)}
                              className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 rounded-xl transition cursor-pointer border border-slate-200/80 hover:border-indigo-200 active:scale-95"
                              title="Sửa thông tin tài khoản"
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </button>
                          )}

                          {/* XÓA TÀI KHOẢN */}
                          {canManage && u.id !== user?.id && (
                            <button
                              onClick={() => handleDelete(u.id, u.username)}
                              className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition cursor-pointer border border-slate-200/80 hover:border-rose-200 active:scale-95"
                              title="Xóa tài khoản (Soft Delete)"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
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

      {/* ================= MODAL: NÂNG QUYỀN / ĐỔI VAI TRÒ (ADMIN ONLY) ================= */}
      {showRoleModal && targetUserForRole && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 animate-in fade-in zoom-in duration-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Shield className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">
                    Nâng quyền / Đổi vai trò
                  </h3>
                  <span className="text-xs text-slate-400">
                    Tài khoản: <strong className="text-indigo-600">@{targetUserForRole.username}</strong> ({targetUserForRole.full_name})
                  </span>
                </div>
              </div>
              <button
                onClick={() => {
                  setShowRoleModal(false);
                  setTargetUserForRole(null);
                }}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleUpdateRole} className="space-y-4 text-xs">
              <div className="bg-slate-50 p-3 rounded-2xl border border-slate-200/80 text-[11px] space-y-1">
                <span className="text-slate-500 block">Vai trò hiện tại:</span>
                <span className={`inline-block font-bold text-xs px-2.5 py-1 rounded-xl border ${getRoleBadge(targetUserForRole.role)}`}>
                  {getRoleLabel(targetUserForRole.role)}
                </span>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-2">Chọn vai trò mới muốn nâng / gán:</label>
                <div className="space-y-2">
                  {[
                    { role: 'ADMIN', label: 'Quản trị viên (ADMIN)', desc: 'Toàn quyền cấu hình, tài khoản, khóa và nâng quyền.' },
                    { role: 'ACADEMIC_STAFF', label: 'Nhân viên học vụ (STAFF)', desc: 'Quản lý khóa học, lớp học, phòng học, duyệt ghi danh.' },
                    { role: 'TEACHER', label: 'Giảng viên (TEACHER)', desc: 'Nhập điểm, cập nhật kết quả và quản lý sổ điểm học viên.' },
                    { role: 'STUDENT', label: 'Học viên (STUDENT)', desc: 'Đăng ký học, xem thời khóa biểu và tra cứu điểm cá nhân.' },
                    { role: 'PARENT', label: 'Phụ huynh (PARENT)', desc: 'Giám sát tiến độ học tập và kết quả của con em.' },
                  ].map((item) => (
                    <label
                      key={item.role}
                      className={`flex items-start gap-3 p-3 rounded-2xl border cursor-pointer transition ${
                        newSelectedRole === item.role
                          ? 'bg-indigo-50/70 border-indigo-500 ring-2 ring-indigo-200'
                          : 'bg-white border-slate-200 hover:bg-slate-50'
                      }`}
                    >
                      <input
                        type="radio"
                        name="newRole"
                        value={item.role}
                        checked={newSelectedRole === item.role}
                        onChange={(e) => setNewSelectedRole(e.target.value)}
                        className="mt-1 text-indigo-600 focus:ring-indigo-500"
                      />
                      <div>
                        <span className="font-bold text-slate-900 block text-xs">{item.label}</span>
                        <span className="text-[11px] text-slate-500 leading-relaxed block mt-0.5">{item.desc}</span>
                      </div>
                    </label>
                  ))}
                </div>
              </div>

              <div className="flex justify-end gap-2.5 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => {
                    setShowRoleModal(false);
                    setTargetUserForRole(null);
                  }}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer active:scale-95"
                >
                  Xác nhận Nâng / Đổi quyền
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: DANH SÁCH HỌC SINH LIÊN QUAN (Yêu cầu 5) ================= */}
      {relatedModal.isOpen && relatedModal.user && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-slate-200 flex flex-col max-h-[85vh] overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4 shrink-0">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600">
                  <Users className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base font-black text-slate-900">
                    Học Sinh Liên Quan
                  </h3>
                  <span className="text-xs text-slate-400">
                    Tài khoản: <strong className="text-indigo-600">{relatedModal.user.full_name}</strong> (@{relatedModal.user.username})
                  </span>
                </div>
              </div>
              <button
                onClick={() => setRelatedModal({ isOpen: false, user: null, students: [], isLoading: false })}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <div className="flex-1 overflow-y-auto pr-1">
              {relatedModal.isLoading ? (
                <div className="py-12 text-center text-xs text-slate-400">Đang tải danh sách học sinh liên quan...</div>
              ) : relatedModal.students.length === 0 ? (
                <div className="py-12 text-center text-slate-400 bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                  <Users className="w-8 h-8 mx-auto mb-2 opacity-30 text-slate-400" />
                  <p className="text-xs font-medium">Chưa có học sinh nào liên kết với tài khoản này.</p>
                </div>
              ) : (
                <div className="space-y-2.5">
                  {relatedModal.students.map((st, idx) => (
                    <div key={idx} className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80 flex items-center justify-between gap-3 text-xs">
                      <div>
                        <span className="font-bold text-slate-900 block text-sm">{st.full_name}</span>
                        <div className="flex items-center gap-2 text-[11px] text-slate-500 font-mono mt-0.5">
                          <span className="font-bold text-indigo-600 bg-indigo-50 border border-indigo-100 px-1.5 py-0.2 rounded">{st.student_code}</span>
                          {st.email && <span>{st.email}</span>}
                        </div>
                        <span className="text-[11px] font-semibold text-indigo-700 mt-1 block">
                          • {st.relation}
                        </span>
                      </div>
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-extrabold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        {st.status || 'STUDYING'}
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div className="pt-4 border-t border-slate-100 flex justify-end shrink-0 mt-4">
              <button
                type="button"
                onClick={() => setRelatedModal({ isOpen: false, user: null, students: [], isLoading: false })}
                className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition cursor-pointer"
              >
                Đóng
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: THÊM TÀI KHOẢN MỚI ================= */}
      {showAddModal && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 animate-in fade-in zoom-in duration-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-base font-black text-slate-900">
                Thêm Tài khoản Người dùng mới
              </h3>
              <button
                onClick={() => setShowAddModal(false)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreate} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tên đăng nhập (Username):</label>
                <input
                  type="text"
                  required
                  placeholder="ví dụ: nguyenvana"
                  value={newUser.username}
                  onChange={(e) => setNewUser({ ...newUser, username: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-mono font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Họ và tên đầy đủ:</label>
                <input
                  type="text"
                  required
                  placeholder="ví dụ: Nguyễn Văn A"
                  value={newUser.full_name}
                  onChange={(e) => setNewUser({ ...newUser, full_name: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Địa chỉ Email:</label>
                <input
                  type="email"
                  required
                  placeholder="email@example.com"
                  value={newUser.email}
                  onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Mật khẩu khởi tạo:</label>
                  <input
                    type="password"
                    required
                    placeholder="Tối thiểu 6 ký tự"
                    value={newUser.password}
                    onChange={(e) => setNewUser({ ...newUser, password: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                  />
                </div>
                <div>
                  <label className="font-bold text-slate-700 block mb-1">Vai trò hệ thống:</label>
                  <select
                    value={newUser.role}
                    onChange={(e) => setNewUser({ ...newUser, role: e.target.value })}
                    className="w-full border border-slate-300 p-2.5 rounded-xl bg-white font-bold outline-hidden focus:border-indigo-600 cursor-pointer"
                  >
                    <option value="ADMIN">ADMIN</option>
                    <option value="ACADEMIC_STAFF">ACADEMIC_STAFF</option>
                    <option value="TEACHER">TEACHER</option>
                    <option value="STUDENT">STUDENT</option>
                    <option value="PARENT">PARENT</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Số điện thoại liên hệ:</label>
                <input
                  type="text"
                  placeholder="090..."
                  value={newUser.phone}
                  onChange={(e) => setNewUser({ ...newUser, phone: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
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
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer active:scale-95"
                >
                  Tạo tài khoản
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: SỬA THÔNG TIN TÀI KHOẢN ================= */}
      {showEditModal && editingUser && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-slate-200 animate-in fade-in zoom-in duration-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div>
                <h3 className="text-base font-black text-slate-900">
                  Cập nhật Thông tin: @{editingUser.username}
                </h3>
                <span className="text-xs text-slate-400 font-medium">Vai trò: {editingUser.role}</span>
              </div>
              <button
                onClick={() => {
                  setShowEditModal(false);
                  setEditingUser(null);
                }}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleUpdate} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Họ và tên đầy đủ:</label>
                <input
                  type="text"
                  required
                  value={editUserForm.full_name}
                  onChange={(e) => setEditUserForm({ ...editUserForm, full_name: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Địa chỉ Email:</label>
                <input
                  type="email"
                  required
                  value={editUserForm.email}
                  onChange={(e) => setEditUserForm({ ...editUserForm, email: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Số điện thoại liên hệ:</label>
                <input
                  type="text"
                  value={editUserForm.phone}
                  onChange={(e) => setEditUserForm({ ...editUserForm, phone: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Đường dẫn ảnh đại diện (Avatar URL):</label>
                <div className="flex items-center gap-3">
                  <UserAvatar
                    avatarUrl={editUserForm.avatar_url}
                    name={editUserForm.full_name}
                    role={editingUser?.role}
                    size="md"
                    shape="rounded-2xl"
                  />
                  <input
                    type="url"
                    placeholder="https://..."
                    value={editUserForm.avatar_url}
                    onChange={(e) => setEditUserForm({ ...editUserForm, avatar_url: e.target.value })}
                    className="flex-1 border border-slate-300 p-2.5 rounded-xl font-mono text-[11px] outline-hidden focus:border-indigo-600"
                  />
                </div>
              </div>

              <div className="flex items-center gap-2 pt-1">
                <input
                  type="checkbox"
                  id="userActiveCheck"
                  checked={editUserForm.is_active}
                  onChange={(e) => setEditUserForm({ ...editUserForm, is_active: e.target.checked })}
                  className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4 cursor-pointer"
                />
                <label htmlFor="userActiveCheck" className="text-xs font-bold text-slate-700 cursor-pointer">
                  Tài khoản đang hoạt động (cho phép đăng nhập vào hệ thống)
                </label>
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => {
                    setShowEditModal(false);
                    setEditingUser(null);
                  }}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer active:scale-95"
                >
                  Lưu thay đổi
                </button>
              </div>
            </form>
          </div>
        </div>,
        document.body
      )}

      {/* ================= MODAL: ĐỔI MẬT KHẨU CÁ NHÂN ================= */}
      {showPasswordModal && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-sm w-full p-6 sm:p-7 shadow-2xl border border-slate-200 animate-in fade-in zoom-in duration-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <h3 className="text-base font-black text-slate-900">
                Đổi Mật khẩu Cá nhân
              </h3>
              <button
                onClick={() => setShowPasswordModal(false)}
                className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleChangePassword} className="space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mật khẩu hiện tại:</label>
                <input
                  type="password"
                  required
                  value={passwordForm.old_password}
                  onChange={(e) => setPasswordForm({ ...passwordForm, old_password: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mật khẩu mới:</label>
                <input
                  type="password"
                  required
                  placeholder="Tối thiểu 6 ký tự"
                  value={passwordForm.new_password}
                  onChange={(e) => setPasswordForm({ ...passwordForm, new_password: e.target.value })}
                  className="w-full border border-slate-300 p-2.5 rounded-xl font-medium outline-hidden focus:border-indigo-600"
                />
              </div>
              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setShowPasswordModal(false)}
                  className="px-4 py-2.5 border border-slate-300 rounded-xl font-bold text-slate-600 hover:bg-slate-50 cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-bold hover:bg-indigo-700 shadow-sm shadow-indigo-200 cursor-pointer active:scale-95"
                >
                  Xác nhận đổi
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
