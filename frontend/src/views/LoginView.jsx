import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { authApi } from '../services/api';
import { 
  GraduationCap, ArrowRight, Lock, User, KeyRound, 
  ShieldAlert, CheckCircle2, ArrowLeft, Mail, RefreshCw, 
  AlertTriangle, Eye, EyeOff, Sparkles, Award, Users, BookOpen,
  UserPlus, UserX, Trash2, Phone, AlertCircle
} from 'lucide-react';

export const LoginView = () => {
  const { login, register } = useAuth();
  const toast = useToast();
  
  // Login form state
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  // Mode: 'login' | 'register' | 'forgot_request' | 'forgot_reset'
  const [authMode, setAuthMode] = useState('login');

  // Register form state
  const [regForm, setRegForm] = useState({
    username: '',
    full_name: '',
    email: '',
    phone: '',
    password: '',
    confirm_password: '',
    role: 'STUDENT',
  });
  const [showRegPassword, setShowRegPassword] = useState(false);
  const [regError, setRegError] = useState('');
  const [isRegistering, setIsRegistering] = useState(false);

  // Forgot password flow state
  const [forgotIdentifier, setForgotIdentifier] = useState('');
  const [resetCode, setResetCode] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [forgotMsg, setForgotMsg] = useState('');
  const [forgotError, setForgotError] = useState('');
  const [isForgotLoading, setIsForgotLoading] = useState(false);
  const [generatedOtp, setGeneratedOtp] = useState('');

  // Handle standard login
  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setIsLoggingIn(true);
    try {
      await login(username, password);
      toast.success('Đăng nhập thành công!');
    } catch (err) {
      const msg = err.message || 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin tài khoản.';
      setErrorMsg(msg);
      toast.error(msg);
    } finally {
      setIsLoggingIn(false);
    }
  };

  // Handle student / parent self-registration
  const handleRegister = async (e) => {
    e.preventDefault();
    setRegError('');

    if (regForm.username.trim().length < 3) {
      setRegError('Tên đăng nhập phải có tối thiểu 3 ký tự.');
      return;
    }
    if (regForm.password.length < 6) {
      setRegError('Mật khẩu phải có tối thiểu 6 ký tự.');
      return;
    }
    if (regForm.password !== regForm.confirm_password) {
      setRegError('Mật khẩu xác nhận không khớp với mật khẩu mới.');
      return;
    }

    setIsRegistering(true);
    try {
      await register({
        username: regForm.username.trim().toLowerCase(),
        full_name: regForm.full_name.trim(),
        email: regForm.email.trim().toLowerCase(),
        phone: regForm.phone ? regForm.phone.trim() : null,
        password: regForm.password,
        role: regForm.role,
      });
      toast.success('Đăng ký tài khoản thành công!');
    } catch (err) {
      const msg = err.message || 'Đăng ký tài khoản thất bại.';
      setRegError(msg);
      toast.error(msg);
    } finally {
      setIsRegistering(false);
    }
  };

  // Step 1: Request OTP for password reset
  const handleRequestOtp = async (e) => {
    e.preventDefault();
    setForgotError('');
    setForgotMsg('');
    setIsForgotLoading(true);

    try {
      const res = await authApi.forgotPassword(forgotIdentifier);
      setGeneratedOtp(res.data.reset_code);
      setResetCode(res.data.reset_code);
      const msg = `Mã xác thực OTP đã được tạo: ${res.data.reset_code}`;
      setForgotMsg(msg);
      toast.success('Mã OTP khôi phục đã được tạo thành công!');
      setAuthMode('forgot_reset');
    } catch (err) {
      const msg = err.message || 'Không thể tạo yêu cầu đặt lại mật khẩu.';
      setForgotError(msg);
      toast.error(msg);
    } finally {
      setIsForgotLoading(false);
    }
  };

  // Step 2: Submit new password with OTP
  const handleResetPassword = async (e) => {
    e.preventDefault();
    setForgotError('');
    setForgotMsg('');

    if (newPassword.length < 6) {
      setForgotError('Mật khẩu mới phải có tối thiểu 6 ký tự.');
      return;
    }
    if (newPassword !== confirmPassword) {
      setForgotError('Mật khẩu xác nhận không khớp với mật khẩu mới.');
      return;
    }

    setIsForgotLoading(true);
    try {
      const res = await authApi.resetPassword(forgotIdentifier, resetCode, newPassword);
      const msg = res.message || 'Đặt lại mật khẩu thành công!';
      setForgotMsg(msg);
      toast.success(msg);
      setTimeout(() => {
        setUsername(forgotIdentifier);
        setPassword('');
        setErrorMsg('');
        setAuthMode('login');
        setForgotMsg('Tài khoản đã được mở khóa! Vui lòng nhập mật khẩu mới để đăng nhập.');
      }, 1500);
    } catch (err) {
      const msg = err.message || 'Không thể đặt lại mật khẩu.';
      setForgotError(msg);
      toast.error(msg);
    } finally {
      setIsForgotLoading(false);
    }
  };

  // Error Classification
  const isNotFoundError = errorMsg.includes('không tồn tại');
  const isDeletedError = errorMsg.includes('bị xóa');
  const isAdminLockError = errorMsg.includes('khóa hoặc vô hiệu hóa') || errorMsg.includes('Quản trị viên khóa');
  const isLockoutError = errorMsg.includes('khóa tạm thời') || errorMsg.includes('5 lần');
  const isWrongPasswordError = errorMsg.includes('Mật khẩu không chính xác');

  return (
    <div className="min-h-screen flex flex-col justify-center relative overflow-hidden font-sans" style={{ background: 'linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%)' }}>
      
      {/* Dynamic Background Mesh Glows */}
      <div className="absolute top-0 left-1/4 w-[600px] h-[600px] bg-gradient-to-br from-violet-600/30 via-indigo-600/15 to-transparent rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute bottom-0 right-1/4 w-[500px] h-[500px] bg-gradient-to-tr from-cyan-500/25 via-sky-600/10 to-transparent rounded-full blur-[130px] pointer-events-none" />
      <div className="absolute top-1/2 left-0 w-[300px] h-[300px] bg-gradient-to-tr from-purple-600/15 to-transparent rounded-full blur-[100px] pointer-events-none" />

      {/* Main Split Portal Card */}
      <div className="relative z-10 max-w-5xl w-full mx-auto p-4 sm:p-6 lg:p-8">
        <div className="rounded-3xl overflow-hidden grid grid-cols-1 lg:grid-cols-12" style={{ boxShadow: '0 32px 80px -12px rgba(0,0,0,0.6), 0 0 0 1px rgba(99,102,241,0.2)' }}>
          
          {/* LEFT COLUMN: BRANDING & SYSTEM SHOWCASE (5 Cols) */}
          <div className="lg:col-span-5 relative p-8 sm:p-10 flex flex-col justify-between border-b lg:border-b-0 lg:border-r border-indigo-400/20 overflow-hidden"
            style={{ background: 'linear-gradient(145deg, #4f46e5 0%, #7c3aed 55%, #6d28d9 100%)' }}>
            {/* Decorative blur orbs */}
            <div className="absolute -top-16 -right-16 w-56 h-56 bg-cyan-400/25 rounded-full blur-3xl pointer-events-none" />
            <div className="absolute -bottom-12 -left-12 w-48 h-48 bg-rose-400/20 rounded-full blur-2xl pointer-events-none" />
            <div className="absolute top-1/2 right-6 w-20 h-20 bg-amber-300/20 rounded-full blur-xl pointer-events-none" />
            {/* Floating dots */}
            <div className="absolute inset-0 pointer-events-none overflow-hidden">
              {[{t:'12%',l:'10%'},{t:'25%',l:'80%'},{t:'55%',l:'6%'},{t:'70%',l:'88%'},{t:'85%',l:'25%'},{t:'90%',l:'60%'}].map((d,i)=>
                <div key={i} className="absolute w-1.5 h-1.5 rounded-full bg-white/15" style={{top:d.t,left:d.l}} />
              )}
            </div>
            <div className="relative">
              {/* Center Logo & Badges */}
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-2xl bg-white/20 backdrop-blur-sm border border-white/30 flex items-center justify-center text-white shadow-lg shadow-black/20">
                  <GraduationCap className="w-6 h-6" />
                </div>
                <div>
                  <h1 className="text-xl font-black text-white tracking-tight flex items-center gap-1.5">
                    SMART-EDU
                    <Sparkles className="w-4 h-4 text-amber-400" />
                  </h1>
                  <span className="text-[10px] font-bold uppercase tracking-wider text-indigo-200 block">
                    Language Center LMS 2.0
                  </span>
                </div>
              </div>

              {/* Tagline & Subheading */}
              <div className="mt-8">
                <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-bold bg-white/20 text-white border border-white/30 mb-3">
                  <Award className="w-3.5 h-3.5 text-amber-300" />
                  Chuẩn Đào Tạo Quốc Tế
                </span>
                <h2 className="text-2xl sm:text-3xl font-black text-white tracking-tight leading-snug">
                  Hệ thống Quản lý <br className="hidden sm:inline" />
                  <span className="bg-gradient-to-r from-cyan-200 via-white to-amber-200 bg-clip-text text-transparent">
                    Đào tạo &amp; Khảo thí
                  </span>
                </h2>
                <p className="mt-3 text-xs text-indigo-100 leading-relaxed">
                  Giải pháp toàn diện tối ưu hóa xếp lịch ma trận tuần, sổ điểm số hóa, phát hiện xung đột phòng học và theo dõi lộ trình IELTS & TOEIC.
                </p>
              </div>
            </div>

            {/* Bottom System Status */}
            <div className="relative mt-8 pt-4 border-t border-white/20 flex items-center justify-between text-[11px] text-indigo-100">
              <span className="flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-emerald-300 animate-ping" />
                Hệ thống máy chủ
              </span>
              <span className="text-emerald-300 font-bold font-mono flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-300 animate-pulse" />
                ONLINE
              </span>
            </div>
          </div>

          {/* RIGHT COLUMN: LOGIN / REGISTER / FORGOT FORM (7 Cols) */}
          <div className="lg:col-span-7 bg-white p-8 sm:p-12 flex flex-col justify-between">
            
            {/* MODE 1: LOGIN FORM */}
            {authMode === 'login' && (
              <div>
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h2 className="text-2xl font-black text-slate-900 tracking-tight">Đăng nhập tài khoản</h2>
                    <p className="text-xs text-slate-500 mt-1">
                      Nhập thông tin xác thực để truy cập bảng điều khiển hệ thống
                    </p>
                  </div>
                </div>

                {/* Error Banner with Differentiated Cues */}
                {errorMsg && (
                  <div className={`mt-4 p-4 rounded-2xl border text-xs font-semibold flex items-start gap-3 transition-all ${
                    isNotFoundError
                      ? 'bg-rose-50 border-rose-200 text-rose-800'
                      : isDeletedError
                      ? 'bg-slate-100 border-slate-300 text-slate-800'
                      : isAdminLockError
                      ? 'bg-red-50 border-red-200 text-red-800'
                      : isLockoutError
                      ? 'bg-rose-50 border-rose-200 text-rose-800'
                      : isWrongPasswordError
                      ? 'bg-amber-50 border-amber-200 text-amber-800'
                      : 'bg-rose-50 border-rose-200 text-rose-800'
                  }`}>
                    {isNotFoundError ? (
                      <UserX className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
                    ) : isDeletedError ? (
                      <Trash2 className="w-5 h-5 text-slate-600 shrink-0 mt-0.5" />
                    ) : isAdminLockError ? (
                      <Lock className="w-5 h-5 text-red-600 shrink-0 mt-0.5" />
                    ) : isLockoutError ? (
                      <ShieldAlert className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
                    ) : isWrongPasswordError ? (
                      <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                    ) : (
                      <AlertCircle className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
                    )}
                    <div className="flex-1 leading-relaxed">
                      <p>{errorMsg}</p>
                    </div>
                  </div>
                )}

                {/* Success Message Banner */}
                {forgotMsg && !errorMsg && (
                  <div className="mt-4 p-3.5 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                    <span>{forgotMsg}</span>
                  </div>
                )}

                {/* Login Form */}
                <form onSubmit={handleSubmit} className="mt-6 space-y-4 text-xs">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1.5">Tên đăng nhập / Email:</label>
                    <div className="relative">
                      <User className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type="text"
                        required
                        placeholder="Nhập username hoặc email..."
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        className="w-full pl-10 pr-3.5 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                    </div>
                  </div>

                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className="font-bold text-slate-700">Mật khẩu:</label>
                      <button
                        type="button"
                        onClick={() => {
                          setForgotIdentifier(username);
                          setForgotError('');
                          setForgotMsg('');
                          setAuthMode('forgot_request');
                        }}
                        className="text-xs font-bold text-indigo-600 hover:text-indigo-800 hover:underline transition cursor-pointer"
                      >
                        Quên mật khẩu?
                      </button>
                    </div>
                    <div className="relative">
                      <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type={showPassword ? 'text' : 'password'}
                        required
                        placeholder="Nhập mật khẩu..."
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="w-full pl-10 pr-10 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1 cursor-pointer"
                      >
                        {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </button>
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isLoggingIn}
                    className="w-full mt-4 bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 active:scale-[0.99] text-white py-3.5 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/30 transition-all cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isLoggingIn ? (
                      <>
                        <RefreshCw className="w-4 h-4 animate-spin" />
                        Đang xác thực thông tin...
                      </>
                    ) : (
                      <>
                        Đăng nhập vào hệ thống
                        <ArrowRight className="w-4 h-4" />
                      </>
                    )}
                  </button>

                  {/* Switch to Register */}
                  <div className="mt-5 pt-4 border-t border-slate-100 text-center">
                    <p className="text-xs text-slate-500">
                      Chưa có tài khoản?{' ' }
                      <button
                        type="button"
                        onClick={() => {
                          setAuthMode('register');
                          setErrorMsg('');
                          setRegError('');
                        }}
                        className="font-bold text-indigo-600 hover:text-indigo-800 hover:underline transition cursor-pointer inline-flex items-center gap-1"
                      >
                        <UserPlus className="w-3.5 h-3.5 inline" />
                        Đăng ký tài khoản ngay
                      </button>
                    </p>
                  </div>
                </form>
              </div>
            )}

            {/* MODE 2: REGISTER FORM */}
            {authMode === 'register' && (
              <div>
                <button
                  type="button"
                  onClick={() => {
                    setAuthMode('login');
                    setRegError('');
                  }}
                  className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-500 hover:text-slate-800 mb-4 transition cursor-pointer"
                >
                  <ArrowLeft className="w-3.5 h-3.5" />
                  Quay lại đăng nhập
                </button>

                <div className="space-y-1 mb-4">
                  <h2 className="text-2xl font-black text-slate-900 tracking-tight">Đăng ký tài khoản</h2>
                  <p className="text-xs text-slate-500">
                    Khởi tạo tài khoản học tập để tham gia lộ trình IELTS & TOEIC chuẩn quốc tế
                  </p>
                </div>

                {/* Register Error Banner */}
                {regError && (
                  <div className="mb-4 p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0 text-rose-600" />
                    <span>{regError}</span>
                  </div>
                )}

                <form onSubmit={handleRegister} className="space-y-3 text-xs">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="font-bold text-slate-700 block mb-1">Tên đăng nhập:</label>
                      <div className="relative">
                        <User className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                        <input
                          type="text"
                          required
                          placeholder="ví dụ: khang2026"
                          value={regForm.username}
                          onChange={(e) => setRegForm({ ...regForm, username: e.target.value })}
                          className="w-full pl-10 pr-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-mono font-medium transition"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="font-bold text-slate-700 block mb-1">Họ và tên đầy đủ:</label>
                      <input
                        type="text"
                        required
                        placeholder="ví dụ: Phạm Minh Khang"
                        value={regForm.full_name}
                        onChange={(e) => setRegForm({ ...regForm, full_name: e.target.value })}
                        className="w-full px-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="font-bold text-slate-700 block mb-1">Địa chỉ Email:</label>
                      <div className="relative">
                        <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                        <input
                          type="email"
                          required
                          placeholder="email@example.com"
                          value={regForm.email}
                          onChange={(e) => setRegForm({ ...regForm, email: e.target.value })}
                          className="w-full pl-10 pr-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
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
                          value={regForm.phone}
                          onChange={(e) => setRegForm({ ...regForm, phone: e.target.value })}
                          className="w-full pl-10 pr-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                        />
                      </div>
                    </div>
                  </div>

                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Vai trò đăng ký:</label>
                    <div className="grid grid-cols-2 gap-2">
                      <label className={`flex items-center gap-2 p-2.5 rounded-xl border cursor-pointer font-bold text-xs ${
                        regForm.role === 'STUDENT' ? 'bg-indigo-50 border-indigo-600 text-indigo-700' : 'bg-slate-50 border-slate-200 text-slate-600'
                      }`}>
                        <input
                          type="radio"
                          name="regRole"
                          value="STUDENT"
                          checked={regForm.role === 'STUDENT'}
                          onChange={(e) => setRegForm({ ...regForm, role: e.target.value })}
                          className="text-indigo-600 focus:ring-indigo-500"
                        />
                        <span>🎒 Học viên</span>
                      </label>
                      <label className={`flex items-center gap-2 p-2.5 rounded-xl border cursor-pointer font-bold text-xs ${
                        regForm.role === 'PARENT' ? 'bg-indigo-50 border-indigo-600 text-indigo-700' : 'bg-slate-50 border-slate-200 text-slate-600'
                      }`}>
                        <input
                          type="radio"
                          name="regRole"
                          value="PARENT"
                          checked={regForm.role === 'PARENT'}
                          onChange={(e) => setRegForm({ ...regForm, role: e.target.value })}
                          className="text-indigo-600 focus:ring-indigo-500"
                        />
                        <span>👨‍👩‍👧 Phụ huynh</span>
                      </label>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="font-bold text-slate-700 block mb-1">Mật khẩu (tối thiểu 6 ký tự):</label>
                      <div className="relative">
                        <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                        <input
                          type={showRegPassword ? 'text' : 'password'}
                          required
                          placeholder="••••••••"
                          value={regForm.password}
                          onChange={(e) => setRegForm({ ...regForm, password: e.target.value })}
                          className="w-full pl-10 pr-9 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                        />
                        <button
                          type="button"
                          onClick={() => setShowRegPassword(!showRegPassword)}
                          className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1 cursor-pointer"
                        >
                          {showRegPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                        </button>
                      </div>
                    </div>

                    <div>
                      <label className="font-bold text-slate-700 block mb-1">Xác nhận mật khẩu:</label>
                      <div className="relative">
                        <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                        <input
                          type="password"
                          required
                          placeholder="Nhập lại mật khẩu..."
                          value={regForm.confirm_password}
                          onChange={(e) => setRegForm({ ...regForm, confirm_password: e.target.value })}
                          className="w-full pl-10 pr-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                        />
                      </div>
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isRegistering}
                    className="w-full mt-2 bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 active:scale-[0.99] text-white py-3 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/30 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isRegistering ? (
                      <>
                        <RefreshCw className="w-4 h-4 animate-spin" />
                        Đang tạo tài khoản & đăng nhập...
                      </>
                    ) : (
                      <>
                        Hoàn tất đăng ký & Bắt đầu học ngay
                        <ArrowRight className="w-4 h-4" />
                      </>
                    )}
                  </button>

                  <div className="text-center pt-2">
                    <button
                      type="button"
                      onClick={() => {
                        setAuthMode('login');
                        setRegError('');
                      }}
                      className="text-xs font-bold text-slate-500 hover:text-indigo-600 cursor-pointer"
                    >
                      Đã có tài khoản? <span className="text-indigo-600 underline">Đăng nhập ngay</span>
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* MODE 3: FORGOT PASSWORD - STEP 1 (REQUEST OTP) */}
            {authMode === 'forgot_request' && (
              <div>
                <button
                  type="button"
                  onClick={() => {
                    setAuthMode('login');
                    setForgotError('');
                    setForgotMsg('');
                  }}
                  className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-500 hover:text-slate-800 mb-6 transition cursor-pointer"
                >
                  <ArrowLeft className="w-3.5 h-3.5" />
                  Quay lại đăng nhập
                </button>

                <div className="space-y-1">
                  <h2 className="text-2xl font-black text-slate-900 tracking-tight">Quên mật khẩu</h2>
                  <p className="text-xs text-slate-500">
                    Nhập tên đăng nhập hoặc email đã đăng ký để nhận mã OTP xác thực khôi phục tài khoản
                  </p>
                </div>

                {forgotError && (
                  <div className="mt-4 p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0 text-rose-600" />
                    <span>{forgotError}</span>
                  </div>
                )}

                <form onSubmit={handleRequestOtp} className="mt-6 space-y-4 text-xs">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1.5">Tên đăng nhập hoặc Email:</label>
                    <div className="relative">
                      <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type="text"
                        required
                        placeholder="Nhập username hoặc email..."
                        value={forgotIdentifier}
                        onChange={(e) => setForgotIdentifier(e.target.value)}
                        className="w-full pl-10 pr-3.5 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isForgotLoading}
                    className="w-full mt-2 bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 active:scale-[0.99] text-white py-3.5 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/30 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isForgotLoading ? (
                      <>
                        <RefreshCw className="w-4 h-4 animate-spin" />
                        Đang tạo mã OTP...
                      </>
                    ) : (
                      <>
                        Gửi mã xác thực OTP
                        <ArrowRight className="w-4 h-4" />
                      </>
                    )}
                  </button>
                </form>
              </div>
            )}

            {/* MODE 4: FORGOT PASSWORD - STEP 2 (RESET WITH OTP) */}
            {authMode === 'forgot_reset' && (
              <div>
                <button
                  type="button"
                  onClick={() => {
                    setAuthMode('forgot_request');
                    setForgotError('');
                  }}
                  className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-500 hover:text-slate-800 mb-6 transition cursor-pointer"
                >
                  <ArrowLeft className="w-3.5 h-3.5" />
                  Yêu cầu mã khác
                </button>

                <div className="space-y-1">
                  <h2 className="text-2xl font-black text-slate-900 tracking-tight">Đặt lại mật khẩu</h2>
                  <p className="text-xs text-slate-500">
                    Nhập mã xác thực OTP gồm 6 chữ số và thiết lập mật khẩu mới
                  </p>
                </div>

                {generatedOtp && (
                  <div className="mt-4 p-3.5 rounded-2xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-4 h-4 text-amber-600" />
                      <span>Mã OTP của bạn: <strong className="font-mono text-sm text-indigo-700">{generatedOtp}</strong></span>
                    </div>
                    <span className="text-[10px] text-amber-700 font-semibold">(Hiệu lực 15 phút)</span>
                  </div>
                )}

                {forgotError && (
                  <div className="mt-4 p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center gap-2">
                    <AlertTriangle className="w-4 h-4 shrink-0 text-rose-600" />
                    <span>{forgotError}</span>
                  </div>
                )}

                <form onSubmit={handleResetPassword} className="mt-5 space-y-3.5 text-xs">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Mã xác thực OTP (6 chữ số):</label>
                    <input
                      type="text"
                      required
                      maxLength={6}
                      placeholder="ví dụ: 123456"
                      value={resetCode}
                      onChange={(e) => setResetCode(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-mono font-bold tracking-widest text-center text-sm transition"
                    />
                  </div>

                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Mật khẩu mới (tối thiểu 6 ký tự):</label>
                    <div className="relative">
                      <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type="password"
                        required
                        placeholder="Nhập mật khẩu mới..."
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        className="w-full pl-10 pr-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Xác nhận mật khẩu mới:</label>
                    <div className="relative">
                      <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                      <input
                        type="password"
                        required
                        placeholder="Nhập lại mật khẩu mới..."
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        className="w-full pl-10 pr-3.5 py-2.5 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isForgotLoading}
                    className="w-full mt-4 bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 active:scale-[0.99] text-white py-3.5 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/30 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isForgotLoading ? (
                      <>
                        <RefreshCw className="w-4 h-4 animate-spin" />
                        Đang đặt lại mật khẩu...
                      </>
                    ) : (
                      <>
                        Xác nhận & Mở khóa tài khoản
                        <CheckCircle2 className="w-4 h-4" />
                      </>
                    )}
                  </button>
                </form>
              </div>
            )}

            {/* Footer */}
            <div className="mt-8 pt-4 border-t border-slate-100 text-[11px] text-slate-400 flex items-center justify-between">
              <span>Bảo mật dữ liệu 3NF &bull; Bcrypt Hash</span>
              <span className="text-slate-500 font-medium">&copy; SMART-EDU 2026</span>
            </div>

          </div>

        </div>
      </div>
    </div>
  );
};
