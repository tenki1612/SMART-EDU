import React, { useState, useRef } from 'react';
import { createPortal } from 'react-dom';
import { useAuth } from '../../context/AuthContext';
import { useToast } from '../../context/ToastContext';
import { accountsApi } from '../../services/api';
import { UserAvatar } from '../common/UserAvatar';
import {
  X,
  Upload,
  Camera,
  Trash2,
  Check,
  Sparkles,
  Link as LinkIcon,
  User,
  Mail,
  Phone,
  RefreshCw,
  KeyRound
} from 'lucide-react';

const PRESET_AVATARS = [
  { id: 'adventurer-1', label: 'Học viên Nam', url: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Felix' },
  { id: 'adventurer-2', label: 'Học viên Nữ', url: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Aneka' },
  { id: 'micah-1', label: 'Giảng viên Nam', url: 'https://api.dicebear.com/7.x/micah/svg?seed=Alexander' },
  { id: 'micah-2', label: 'Giảng viên Nữ', url: 'https://api.dicebear.com/7.x/micah/svg?seed=Sarah' },
  { id: 'notion-1', label: 'Chuyên viên Học vụ', url: 'https://api.dicebear.com/7.x/notionists/svg?seed=Oliver' },
  { id: 'notion-2', label: 'Quản trị viên', url: 'https://api.dicebear.com/7.x/notionists/svg?seed=Emma' },
  { id: 'bot-1', label: 'Robot AI', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=SmartEdu' },
  { id: 'emoji-1', label: 'Năng động', url: 'https://api.dicebear.com/7.x/fun-emoji/svg?seed=Champion' },
];

export const ProfileModal = ({ isOpen, onClose }) => {
  const { user, updateUserProfile } = useAuth();
  const toast = useToast();
  const fileInputRef = useRef(null);

  const [activeTab, setActiveTab] = useState('avatar'); // 'avatar' | 'info' | 'password'
  const [customUrl, setCustomUrl] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [isSavingInfo, setIsSavingInfo] = useState(false);

  // Profile Form state
  const [infoForm, setInfoForm] = useState({
    full_name: user?.full_name || '',
    phone: user?.phone || '',
    email: user?.email || '',
  });

  // Password state
  const [pwdForm, setPwdForm] = useState({
    old_password: '',
    new_password: '',
    confirm_password: '',
  });
  const [isChangingPwd, setIsChangingPwd] = useState(false);

  if (!isOpen || !user) return null;

  // 1. Upload from local file
  const handleFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      toast.warning('Vui lòng chọn tệp định dạng hình ảnh (PNG, JPG, WEBP)!');
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      toast.warning('Kích thước ảnh tối đa cho phép là 5MB!');
      return;
    }

    setIsUploading(true);
    try {
      const res = await accountsApi.uploadMyAvatar(file);
      const newUrl = res.data.avatar_url;
      updateUserProfile({ avatar_url: newUrl });
      toast.success('Tải lên và cập nhật ảnh đại diện thành công!');
    } catch (err) {
      toast.error(err.message || 'Lỗi khi tải ảnh đại diện lên máy chủ.');
    } finally {
      setIsUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  // 2. Select preset avatar
  const handleSelectPreset = async (presetUrl) => {
    setIsUploading(true);
    try {
      const res = await accountsApi.updateMyAvatar(presetUrl);
      updateUserProfile({ avatar_url: res.data.avatar_url });
      toast.success('Đã áp dụng ảnh đại diện mẫu thành công!');
    } catch (err) {
      toast.error(err.message || 'Lỗi khi áp dụng ảnh mẫu.');
    } finally {
      setIsUploading(false);
    }
  };

  // 3. Apply custom URL
  const handleApplyCustomUrl = async (e) => {
    e.preventDefault();
    if (!customUrl.trim()) {
      toast.warning('Vui lòng nhập đường dẫn hình ảnh hợp lệ!');
      return;
    }

    setIsUploading(true);
    try {
      const res = await accountsApi.updateMyAvatar(customUrl.trim());
      updateUserProfile({ avatar_url: res.data.avatar_url });
      toast.success('Đã cập nhật ảnh đại diện từ URL thành công!');
      setCustomUrl('');
    } catch (err) {
      toast.error(err.message || 'Không thể cập nhật ảnh đại diện.');
    } finally {
      setIsUploading(false);
    }
  };

  // 4. Remove avatar
  const handleRemoveAvatar = async () => {
    if (!window.confirm('Bạn có chắc chắn muốn gỡ bỏ ảnh đại diện và quay về chữ cái mặc định?')) {
      return;
    }

    setIsUploading(true);
    try {
      await accountsApi.deleteMyAvatar();
      updateUserProfile({ avatar_url: null });
      toast.success('Đã gỡ ảnh đại diện thành công!');
    } catch (err) {
      toast.error(err.message || 'Không thể gỡ ảnh đại diện.');
    } finally {
      setIsUploading(false);
    }
  };

  // 5. Save personal info
  const handleSaveInfo = async (e) => {
    e.preventDefault();
    setIsSavingInfo(true);
    try {
      const res = await accountsApi.updateMyProfile(infoForm);
      updateUserProfile({
        full_name: res.data.full_name,
        phone: res.data.phone,
        email: res.data.email,
      });
      toast.success('Cập nhật thông tin cá nhân thành công!');
    } catch (err) {
      toast.error(err.message || 'Lỗi khi cập nhật thông tin.');
    } finally {
      setIsSavingInfo(false);
    }
  };

  // 6. Change password
  const handleChangePassword = async (e) => {
    e.preventDefault();
    if (pwdForm.new_password.length < 6) {
      toast.warning('Mật khẩu mới phải có tối thiểu 6 ký tự!');
      return;
    }
    if (pwdForm.new_password !== pwdForm.confirm_password) {
      toast.warning('Mật khẩu xác nhận không khớp!');
      return;
    }

    setIsChangingPwd(true);
    try {
      await accountsApi.changePassword(pwdForm.old_password, pwdForm.new_password);
      toast.success('Đổi mật khẩu thành công!');
      setPwdForm({ old_password: '', new_password: '', confirm_password: '' });
      setActiveTab('info');
    } catch (err) {
      toast.error(err.message || 'Không thể đổi mật khẩu. Vui lòng kiểm tra lại mật khẩu hiện tại.');
    } finally {
      setIsChangingPwd(false);
    }
  };

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

  // Render modal into document.body via Portal to prevent any parent backdrop-filter / transform containing block issues
  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto bg-slate-950/70 backdrop-blur-xs animate-in fade-in duration-200">
      {/* Click backdrop to close */}
      <div
        className="fixed inset-0 bg-transparent"
        onClick={onClose}
        aria-hidden="true"
      />

      <div className="bg-white rounded-3xl max-w-xl w-full p-6 sm:p-8 shadow-2xl border border-slate-200 relative overflow-hidden my-auto max-h-[90vh] flex flex-col z-10">
        
        {/* Header bar */}
        <div className="flex items-center justify-between pb-4 border-b border-slate-100 shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-indigo-50 border border-indigo-100 flex items-center justify-center text-indigo-600 shadow-2xs">
              <Camera className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-lg font-black text-slate-900 tracking-tight">
                Hồ sơ Tài khoản & Ảnh đại diện
              </h3>
              <p className="text-xs text-slate-500">
                Tùy chỉnh ảnh đại diện cá nhân và quản lý thông tin bảo mật
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-600 flex items-center justify-center font-bold text-sm cursor-pointer transition active:scale-95"
            title="Đóng cửa sổ"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Tab Navigation */}
        <div className="flex items-center gap-2 mt-4 pb-2 border-b border-slate-100 text-xs font-bold shrink-0">
          <button
            type="button"
            onClick={() => setActiveTab('avatar')}
            className={`px-3.5 py-2 rounded-xl transition cursor-pointer flex items-center gap-1.5 ${
              activeTab === 'avatar'
                ? 'bg-indigo-600 text-white shadow-xs'
                : 'text-slate-500 hover:bg-slate-100'
            }`}
          >
            <Camera className="w-3.5 h-3.5" />
            <span>Ảnh đại diện</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('info')}
            className={`px-3.5 py-2 rounded-xl transition cursor-pointer flex items-center gap-1.5 ${
              activeTab === 'info'
                ? 'bg-indigo-600 text-white shadow-xs'
                : 'text-slate-500 hover:bg-slate-100'
            }`}
          >
            <User className="w-3.5 h-3.5" />
            <span>Thông tin cá nhân</span>
          </button>

          <button
            type="button"
            onClick={() => setActiveTab('password')}
            className={`px-3.5 py-2 rounded-xl transition cursor-pointer flex items-center gap-1.5 ${
              activeTab === 'password'
                ? 'bg-indigo-600 text-white shadow-xs'
                : 'text-slate-500 hover:bg-slate-100'
            }`}
          >
            <KeyRound className="w-3.5 h-3.5" />
            <span>Đổi mật khẩu</span>
          </button>
        </div>

        {/* Scrollable Content Body */}
        <div className="overflow-y-auto flex-1 py-4 space-y-6 text-xs pr-1">
          
          {/* TAB 1: AVATAR MANAGEMENT */}
          {activeTab === 'avatar' && (
            <div className="space-y-6">
              
              {/* Current Avatar Spotlight */}
              <div className="flex flex-col sm:flex-row items-center gap-5 bg-gradient-to-r from-slate-50 to-indigo-50/40 p-5 rounded-2xl border border-slate-200/80">
                <div className="relative group shrink-0">
                  <UserAvatar
                    avatarUrl={user.avatar_url}
                    name={user.full_name}
                    role={user.role}
                    size="2xl"
                    shape="rounded-3xl"
                    className="ring-4 ring-white shadow-lg"
                  />

                  {/* Overlay upload button */}
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    disabled={isUploading}
                    className="absolute inset-0 bg-slate-900/50 backdrop-blur-2xs rounded-3xl opacity-0 group-hover:opacity-100 transition flex flex-col items-center justify-center text-white text-[10px] font-bold cursor-pointer"
                    title="Bấm để tải ảnh mới từ máy tính"
                  >
                    <Camera className="w-5 h-5 mb-1" />
                    <span>Đổi ảnh</span>
                  </button>
                </div>

                <div className="space-y-2 text-center sm:text-left flex-1 min-w-0">
                  <div>
                    <h4 className="text-base font-black text-slate-900 truncate">{user.full_name}</h4>
                    <span className="text-xs text-slate-500 font-mono">@{user.username}</span>
                  </div>

                  <div className="flex items-center justify-center sm:justify-start gap-2 flex-wrap">
                    <span className={`text-[10px] font-bold px-2.5 py-0.5 rounded-full border ${getRoleBadge(user.role)}`}>
                      {user.role}
                    </span>
                    <span className="text-[10px] text-slate-400 font-mono">ID: #{user.id}</span>
                  </div>

                  {/* Actions for current avatar */}
                  <div className="flex items-center justify-center sm:justify-start gap-2 pt-1 flex-wrap">
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/png,image/jpeg,image/webp,image/gif"
                      className="hidden"
                      onChange={handleFileChange}
                    />
                    <button
                      type="button"
                      disabled={isUploading}
                      onClick={() => fileInputRef.current?.click()}
                      className="px-3.5 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-[11px] flex items-center gap-1.5 cursor-pointer shadow-xs active:scale-95 disabled:opacity-50"
                    >
                      <Upload className="w-3.5 h-3.5" />
                      <span>{isUploading ? 'Đang tải...' : 'Tải ảnh từ máy'}</span>
                    </button>

                    {user.avatar_url && (
                      <button
                        type="button"
                        disabled={isUploading}
                        onClick={handleRemoveAvatar}
                        className="px-3.5 py-2 rounded-xl border border-rose-200 text-rose-600 hover:bg-rose-50 font-bold text-[11px] flex items-center gap-1.5 cursor-pointer active:scale-95 disabled:opacity-50"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                        <span>Gỡ ảnh</span>
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Preset Curated Avatars Library */}
              <div className="space-y-2.5">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-slate-700 text-xs flex items-center gap-1.5">
                    <Sparkles className="w-3.5 h-3.5 text-amber-500" />
                    Bộ sưu tập Ảnh đại diện mẫu (Chọn 1-chạm):
                  </span>
                  <span className="text-[10px] text-slate-400 font-medium">8 phong cách đồ họa</span>
                </div>

                <div className="grid grid-cols-4 sm:grid-cols-8 gap-2.5">
                  {PRESET_AVATARS.map((preset) => {
                    const isSelected = user.avatar_url === preset.url;
                    return (
                      <button
                        key={preset.id}
                        type="button"
                        onClick={() => handleSelectPreset(preset.url)}
                        disabled={isUploading}
                        className={`group relative p-1.5 rounded-2xl border transition-all cursor-pointer aspect-square flex flex-col items-center justify-center hover:scale-105 active:scale-95 ${
                          isSelected
                            ? 'bg-indigo-50 border-indigo-600 ring-2 ring-indigo-200 shadow-sm'
                            : 'bg-slate-50/80 border-slate-200 hover:border-indigo-300'
                        }`}
                        title={preset.label}
                      >
                        <img
                          src={preset.url}
                          alt={preset.label}
                          className="w-full h-full object-contain rounded-xl"
                          loading="lazy"
                        />
                        {isSelected && (
                          <div className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-indigo-600 text-white flex items-center justify-center shadow-xs">
                            <Check className="w-2.5 h-2.5" />
                          </div>
                        )}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Custom Image URL option */}
              <div className="space-y-2 pt-2 border-t border-slate-100">
                <span className="font-bold text-slate-700 text-xs flex items-center gap-1.5">
                  <LinkIcon className="w-3.5 h-3.5 text-slate-400" />
                  Hoặc nhập đường dẫn ảnh trực tuyến (Image URL):
                </span>
                <form onSubmit={handleApplyCustomUrl} className="flex gap-2">
                  <input
                    type="url"
                    placeholder="https://example.com/avatar.png"
                    value={customUrl}
                    onChange={(e) => setCustomUrl(e.target.value)}
                    className="flex-1 border border-slate-300 px-3 py-2 rounded-xl text-xs outline-hidden focus:border-indigo-600 font-mono"
                  />
                  <button
                    type="submit"
                    disabled={isUploading || !customUrl.trim()}
                    className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white font-bold text-xs rounded-xl cursor-pointer disabled:opacity-40 transition"
                  >
                    Áp dụng
                  </button>
                </form>
              </div>

            </div>
          )}

          {/* TAB 2: PROFILE INFORMATION */}
          {activeTab === 'info' && (
            <form onSubmit={handleSaveInfo} className="space-y-4">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Tên đăng nhập (Username):</label>
                <div className="relative">
                  <User className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    disabled
                    value={user.username}
                    className="w-full pl-10 pr-3.5 py-2.5 rounded-xl bg-slate-100 border border-slate-200 text-slate-500 font-mono font-bold cursor-not-allowed text-xs"
                  />
                </div>
                <span className="text-[10px] text-slate-400 mt-0.5 block">Tên đăng nhập không thể thay đổi sau khi tạo.</span>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Họ và tên hiển thị:</label>
                <input
                  type="text"
                  required
                  value={infoForm.full_name}
                  onChange={(e) => setInfoForm({ ...infoForm, full_name: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 outline-hidden font-bold text-xs"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Địa chỉ Email:</label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    required
                    value={infoForm.email}
                    onChange={(e) => setInfoForm({ ...infoForm, email: e.target.value })}
                    className="w-full pl-10 pr-3.5 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 outline-hidden font-medium text-xs"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Số điện thoại liên hệ:</label>
                <div className="relative">
                  <Phone className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    placeholder="0901234567"
                    value={infoForm.phone}
                    onChange={(e) => setInfoForm({ ...infoForm, phone: e.target.value })}
                    className="w-full pl-10 pr-3.5 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 outline-hidden font-medium text-xs"
                  />
                </div>
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  type="submit"
                  disabled={isSavingInfo}
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl shadow-xs cursor-pointer flex items-center gap-1.5 active:scale-95 disabled:opacity-50 transition"
                >
                  {isSavingInfo ? (
                    <>
                      <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                      Đang lưu...
                    </>
                  ) : (
                    <>
                      <Check className="w-3.5 h-3.5" />
                      Lưu thông tin cá nhân
                    </>
                  )}
                </button>
              </div>
            </form>
          )}

          {/* TAB 3: PASSWORD CHANGE */}
          {activeTab === 'password' && (
            <form onSubmit={handleChangePassword} className="space-y-4">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mật khẩu hiện tại:</label>
                <input
                  type="password"
                  required
                  placeholder="Nhập mật khẩu đang dùng..."
                  value={pwdForm.old_password}
                  onChange={(e) => setPwdForm({ ...pwdForm, old_password: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 outline-hidden text-xs"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Mật khẩu mới (tối thiểu 6 ký tự):</label>
                <input
                  type="password"
                  required
                  placeholder="Nhập mật khẩu mới..."
                  value={pwdForm.new_password}
                  onChange={(e) => setPwdForm({ ...pwdForm, new_password: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 outline-hidden text-xs"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Xác nhận mật khẩu mới:</label>
                <input
                  type="password"
                  required
                  placeholder="Nhập lại mật khẩu mới..."
                  value={pwdForm.confirm_password}
                  onChange={(e) => setPwdForm({ ...pwdForm, confirm_password: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 outline-hidden text-xs"
                />
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  type="submit"
                  disabled={isChangingPwd}
                  className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl shadow-xs cursor-pointer flex items-center gap-1.5 active:scale-95 disabled:opacity-50 transition"
                >
                  {isChangingPwd ? (
                    <>
                      <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                      Đang cập nhật...
                    </>
                  ) : (
                    <>
                      <KeyRound className="w-3.5 h-3.5" />
                      Xác nhận đổi mật khẩu
                    </>
                  )}
                </button>
              </div>
            </form>
          )}

        </div>

      </div>
    </div>,
    document.body
  );
};
