import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { authApi } from '../services/api';
import { 
  GraduationCap, ArrowRight, Lock, User, KeyRound, 
  ShieldAlert, CheckCircle2, ArrowLeft, Mail, RefreshCw, 
  AlertTriangle, Eye, EyeOff, Sparkles, Award, Users, BookOpen
} from 'lucide-react';

export const LoginView = () => {
  const { login, isLoading } = useAuth();
  
  // Login form state
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  // Forgot password flow state: 'login' | 'forgot_request' | 'forgot_reset'
  const [authMode, setAuthMode] = useState('login');
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
    try {
      await login(username, password);
    } catch (err) {
      setErrorMsg(err.message || 'Đăng nhập thất bại.');
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
      setForgotMsg(`Mã xác thực OTP đã được tạo: ${res.data.reset_code}`);
      setAuthMode('forgot_reset');
    } catch (err) {
      setForgotError(err.message || 'Không thể tạo yêu cầu đặt lại mật khẩu.');
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
      setForgotMsg(res.message || 'Đặt lại mật khẩu thành công!');
      setTimeout(() => {
        setUsername(forgotIdentifier);
        setPassword('');
        setErrorMsg('');
        setAuthMode('login');
        setForgotMsg('Tài khoản đã được mở khóa! Vui lòng nhập mật khẩu mới để đăng nhập.');
      }, 1500);
    } catch (err) {
      setForgotError(err.message || 'Không thể đặt lại mật khẩu.');
    } finally {
      setIsForgotLoading(false);
    }
  };

  const isLockoutError = errorMsg.includes('khóa tạm thời') || errorMsg.includes('5 lần');

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col justify-center relative overflow-hidden font-sans">
      
      {/* Dynamic Background Mesh Glows */}
      <div className="absolute top-0 left-1/4 w-[600px] h-[600px] bg-gradient-to-br from-indigo-600/20 via-purple-600/10 to-transparent rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute bottom-0 right-1/4 w-[500px] h-[500px] bg-gradient-to-tr from-blue-600/15 via-emerald-600/10 to-transparent rounded-full blur-[140px] pointer-events-none" />

      {/* Main Container */}
      <div className="max-w-6xl w-full mx-auto p-4 sm:p-6 lg:p-8 relative z-10">
        <div className="bg-slate-900/90 backdrop-blur-2xl rounded-3xl border border-slate-800 shadow-2xl overflow-hidden grid grid-cols-1 lg:grid-cols-12 min-h-[620px]">
          
          {/* LEFT COLUMN: HERO SHOWCASE (5 Cols) */}
          <div className="lg:col-span-5 bg-gradient-to-br from-indigo-900 via-slate-900 to-slate-950 p-8 sm:p-10 flex flex-col justify-between border-b lg:border-b-0 lg:border-r border-slate-800 relative overflow-hidden">
            <div className="relative z-10">
              {/* Brand Logo */}
              <div className="flex items-center gap-3 mb-8">
                <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-indigo-500 to-indigo-600 flex items-center justify-center text-white shadow-lg shadow-indigo-500/30 ring-2 ring-indigo-400/30">
                  <GraduationCap className="w-7 h-7" />
                </div>
                <div>
                  <span className="font-black text-2xl tracking-tight text-white block leading-tight">
                    SMART-EDU
                  </span>
                  <span className="text-[11px] font-bold text-indigo-300 uppercase tracking-widest flex items-center gap-1.5">
                    <Sparkles className="w-3 h-3 text-indigo-400" />
                    Language Center LMS
                  </span>
                </div>
              </div>

              {/* Tagline */}
              <div className="space-y-3 mt-6">
                <h1 className="text-2xl sm:text-3xl font-black text-white tracking-tight leading-snug">
                  Nền Tảng Quản Lý & Khảo Thí Ngoại Ngữ Chuẩn Quốc Tế
                </h1>
                <p className="text-xs sm:text-sm text-slate-300 leading-relaxed font-normal">
                  Tối ưu hóa quản trị đào tạo, xếp lịch thông minh chống trùng giờ, sổ điểm bảo mật và cổng kết nối đa vai trò.
                </p>
              </div>

              {/* Value Badges */}
              <div className="grid grid-cols-2 gap-3 mt-8">
                <div className="bg-white/5 border border-white/10 p-3.5 rounded-2xl backdrop-blur-md">
                  <div className="flex items-center gap-2 text-indigo-400 mb-1">
                    <Award className="w-4 h-4" />
                    <span className="text-xs font-bold uppercase tracking-wider text-white">IELTS &bull; TOEIC</span>
                  </div>
                  <p className="text-[11px] text-slate-400">Chuẩn hóa lộ trình 8 cấp độ</p>
                </div>

                <div className="bg-white/5 border border-white/10 p-3.5 rounded-2xl backdrop-blur-md">
                  <div className="flex items-center gap-2 text-emerald-400 mb-1">
                    <Users className="w-4 h-4" />
                    <span className="text-xs font-bold uppercase tracking-wider text-white">5 Phân Quyền</span>
                  </div>
                  <p className="text-[11px] text-slate-400">Bảo mật dữ liệu tuyệt đối</p>
                </div>
              </div>
            </div>

            {/* Bottom System Info */}
            <div className="relative z-10 pt-6 mt-6 border-t border-slate-800/80 flex items-center justify-between text-[11px] text-slate-400">
              <span className="font-semibold text-slate-300">FastAPI &bull; React 19</span>
              <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-emerald-950/80 border border-emerald-700/50 text-emerald-400 font-mono font-bold text-[10px]">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                ONLINE
              </span>
            </div>
          </div>

          {/* RIGHT COLUMN: LOGIN FORM (7 Cols) */}
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

                {/* Error Banner */}
                {errorMsg && (
                  <div className={`mt-4 p-4 rounded-2xl border text-xs font-semibold flex items-start gap-3 transition-all ${
                    isLockoutError 
                      ? 'bg-rose-50 border-rose-200 text-rose-800' 
                      : 'bg-amber-50 border-amber-200 text-amber-800'
                  }`}>
                    {isLockoutError ? (
                      <ShieldAlert className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
                    ) : (
                      <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                    )}
                    <div className="flex-1 leading-relaxed">
                      <p>{errorMsg}</p>
                      {isLockoutError && (
                        <button
                          type="button"
                          onClick={() => {
                            setForgotIdentifier(username);
                            setAuthMode('forgot_request');
                            setErrorMsg('');
                          }}
                          className="mt-2 inline-flex items-center gap-1.5 text-xs font-bold text-indigo-700 hover:text-indigo-900 underline cursor-pointer"
                        >
                          <KeyRound className="w-3.5 h-3.5" />
                          Mở khóa tài khoản ngay qua chức năng Quên mật khẩu &rarr;
                        </button>
                      )}
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
                    disabled={isLoading}
                    className="w-full mt-4 bg-gradient-to-r from-indigo-600 to-indigo-700 hover:from-indigo-700 hover:to-indigo-800 active:scale-[0.99] text-white py-3.5 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/25 transition-all cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isLoading ? (
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
                </form>
              </div>
            )}

            {/* MODE 2: FORGOT PASSWORD - STEP 1 (REQUEST OTP) */}
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
                        placeholder="Nhập username hoặc email của bạn..."
                        value={forgotIdentifier}
                        onChange={(e) => setForgotIdentifier(e.target.value)}
                        className="w-full pl-10 pr-3.5 py-3 rounded-2xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden font-medium transition"
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={isForgotLoading}
                    className="w-full mt-4 bg-gradient-to-r from-indigo-600 to-indigo-700 hover:from-indigo-700 hover:to-indigo-800 active:scale-[0.99] text-white py-3.5 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/25 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
                  >
                    {isForgotLoading ? (
                      <>
                        <RefreshCw className="w-4 h-4 animate-spin" />
                        Đang tạo mã OTP...
                      </>
                    ) : (
                      <>
                        Nhận mã xác thực OTP
                        <ArrowRight className="w-4 h-4" />
                      </>
                    )}
                  </button>
                </form>
              </div>
            )}

            {/* MODE 3: FORGOT PASSWORD - STEP 2 (RESET WITH OTP) */}
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
                  Đổi tài khoản khác
                </button>

                <div className="space-y-1">
                  <h2 className="text-2xl font-black text-slate-900 tracking-tight">Đặt lại mật khẩu</h2>
                  <p className="text-xs text-slate-500">
                    Nhập mã OTP và tạo mật khẩu mới cho tài khoản <strong className="text-indigo-600">{forgotIdentifier}</strong>
                  </p>
                </div>

                {generatedOtp && (
                  <div className="mt-4 p-3.5 rounded-2xl bg-amber-50 border border-amber-200 text-amber-900 text-xs font-semibold">
                    <div className="flex items-center gap-2">
                      <KeyRound className="w-4 h-4 text-amber-600 shrink-0" />
                      <span>Mã OTP xác thực mẫu: <strong className="font-mono text-sm tracking-wider text-amber-950 bg-amber-200/80 px-2.5 py-0.5 rounded-lg">{generatedOtp}</strong></span>
                    </div>
                    <p className="mt-1 text-[11px] text-amber-700 font-normal">
                      (Mã có hiệu lực trong 15 phút. Hệ thống đã tự động điền sẵn vào ô bên dưới)
                    </p>
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
                      placeholder="Nhập mã 6 chữ số..."
                      value={resetCode}
                      onChange={(e) => setResetCode(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-2xl border border-slate-300 font-mono tracking-widest text-center text-sm font-bold focus:border-indigo-600 focus:ring-4 focus:ring-indigo-100 outline-hidden transition"
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
                    className="w-full mt-4 bg-gradient-to-r from-indigo-600 to-indigo-700 hover:from-indigo-700 hover:to-indigo-800 active:scale-[0.99] text-white py-3.5 rounded-2xl font-bold text-xs shadow-lg shadow-indigo-600/25 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
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
