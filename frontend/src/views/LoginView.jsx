import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { authApi } from '../services/api';
import { 
  GraduationCap, ArrowRight, Lock, User, KeyRound, 
  ShieldAlert, CheckCircle2, ArrowLeft, Mail, RefreshCw, AlertTriangle
} from 'lucide-react';

export const LoginView = () => {
  const { login, isLoading } = useAuth();
  
  // Login form state
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
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
      setResetCode(res.data.reset_code); // Tự động điền mã OTP mẫu để người dùng thuận tiện thao tác
      setForgotMsg(`Mã xác thực OTP đã được tạo thành công! (Mã của bạn: ${res.data.reset_code})`);
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
      // Tự động chuyển về màn hình đăng nhập sau 1.5 giây
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
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-indigo-950 to-slate-900 flex items-center justify-center p-4 sm:p-6 relative overflow-hidden">
      {/* Background Ambient Glows */}
      <div className="absolute top-1/4 left-1/4 -translate-x-1/2 -translate-y-1/2 w-96 h-96 rounded-full bg-indigo-500/10 blur-[120px] pointer-events-none" />
      <div className="absolute bottom-1/4 right-1/4 translate-x-1/2 translate-y-1/2 w-96 h-96 rounded-full bg-purple-500/10 blur-[120px] pointer-events-none" />

      <div className="max-w-md w-full bg-white rounded-3xl shadow-2xl p-8 sm:p-10 border border-slate-200/60 relative z-10">
        
        {/* Brand Header */}
        <div className="flex items-center gap-3 mb-8">
          <div className="w-11 h-11 rounded-2xl bg-indigo-600 flex items-center justify-center text-white shadow-md shadow-indigo-200">
            <GraduationCap className="w-6 h-6" />
          </div>
          <div>
            <span className="font-extrabold text-xl tracking-tight text-slate-900 block leading-tight">
              SMART-EDU
            </span>
            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-widest">
              Center LMS
            </span>
          </div>
        </div>

        {/* MODE 1: LOGIN FORM */}
        {authMode === 'login' && (
          <div>
            <div className="space-y-1">
              <h2 className="text-2xl font-black text-slate-900 tracking-tight">Đăng nhập</h2>
              <p className="text-xs text-slate-500">
                Vui lòng nhập tài khoản và mật khẩu được cấp để truy cập hệ thống
              </p>
            </div>

            {/* Error Message & Warning Display */}
            {errorMsg && (
              <div className={`mt-4 p-3.5 rounded-2xl border text-xs font-semibold flex items-start gap-2.5 transition-all ${
                isLockoutError 
                  ? 'bg-rose-50 border-rose-200 text-rose-800' 
                  : 'bg-amber-50 border-amber-200 text-amber-800'
              }`}>
                {isLockoutError ? (
                  <ShieldAlert className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
                ) : (
                  <AlertTriangle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
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

            {/* Success Message (e.g. after password reset) */}
            {forgotMsg && !errorMsg && (
              <div className="mt-4 p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                <span>{forgotMsg}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} className="mt-6 space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1.5">Tên đăng nhập / Email:</label>
                <div className="relative">
                  <User className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    required
                    placeholder="Nhập username hoặc email..."
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden font-medium transition"
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
                  <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    required
                    placeholder="Nhập mật khẩu..."
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden font-medium transition"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full mt-2 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white py-3 rounded-xl font-bold text-xs shadow-md shadow-indigo-200 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
              >
                {isLoading ? 'Đang xác thực...' : 'Đăng nhập vào hệ thống'}
                <ArrowRight className="w-4 h-4" />
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
              className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-500 hover:text-slate-800 mb-4 transition cursor-pointer"
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
              <div className="mt-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 shrink-0 text-rose-600" />
                <span>{forgotError}</span>
              </div>
            )}

            <form onSubmit={handleRequestOtp} className="mt-6 space-y-4 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1.5">Tên đăng nhập hoặc Email:</label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    required
                    placeholder="Nhập username hoặc email của bạn..."
                    value={forgotIdentifier}
                    onChange={(e) => setForgotIdentifier(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden font-medium transition"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isForgotLoading}
                className="w-full mt-2 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white py-3 rounded-xl font-bold text-xs shadow-md shadow-indigo-200 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
              >
                {isForgotLoading ? (
                  <>
                    <RefreshCw className="w-4 h-4 animate-spin" />
                    Đang gửi yêu cầu...
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

        {/* MODE 3: FORGOT PASSWORD - STEP 2 (VERIFY OTP & RESET PASSWORD) */}
        {authMode === 'forgot_reset' && (
          <div>
            <button
              type="button"
              onClick={() => {
                setAuthMode('forgot_request');
                setForgotError('');
              }}
              className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-500 hover:text-slate-800 mb-4 transition cursor-pointer"
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

            {/* OTP notification banner */}
            {generatedOtp && (
              <div className="mt-4 p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs font-semibold">
                <div className="flex items-center gap-2">
                  <KeyRound className="w-4 h-4 text-amber-600 shrink-0" />
                  <span>Mã OTP xác thực mẫu: <strong className="font-mono text-sm tracking-wider text-amber-950 bg-amber-200/80 px-2 py-0.5 rounded-md">{generatedOtp}</strong></span>
                </div>
                <p className="mt-1 text-[11px] text-amber-700 font-normal">
                  (Mã này có hiệu lực trong 15 phút. Hệ thống đã tự động điền vào ô bên dưới)
                </p>
              </div>
            )}

            {forgotError && (
              <div className="mt-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 shrink-0 text-rose-600" />
                <span>{forgotError}</span>
              </div>
            )}

            {forgotMsg && !forgotError && (
              <div className="mt-4 p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-semibold flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                <span>{forgotMsg}</span>
              </div>
            )}

            <form onSubmit={handleResetPassword} className="mt-6 space-y-3.5 text-xs">
              <div>
                <label className="font-bold text-slate-700 block mb-1">Mã xác thực OTP (6 chữ số):</label>
                <input
                  type="text"
                  required
                  maxLength={6}
                  placeholder="Nhập mã 6 chữ số..."
                  value={resetCode}
                  onChange={(e) => setResetCode(e.target.value)}
                  className="w-full px-3 py-2.5 rounded-xl border border-slate-300 font-mono tracking-widest text-center text-sm font-bold focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden transition"
                />
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Mật khẩu mới (tối thiểu 6 ký tự):</label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    required
                    placeholder="Nhập mật khẩu mới..."
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden font-medium transition"
                  />
                </div>
              </div>

              <div>
                <label className="font-bold text-slate-700 block mb-1">Xác nhận mật khẩu mới:</label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="password"
                    required
                    placeholder="Nhập lại mật khẩu mới..."
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-300 focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100 outline-hidden font-medium transition"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isForgotLoading}
                className="w-full mt-2 bg-indigo-600 hover:bg-indigo-700 active:scale-[0.99] text-white py-3 rounded-xl font-bold text-xs shadow-md shadow-indigo-200 transition cursor-pointer flex items-center justify-center gap-2 disabled:opacity-50"
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

        <div className="mt-8 pt-4 border-t border-slate-100 text-[11px] text-slate-400 text-center">
          Hệ thống Quản lý Đào tạo Ngoại ngữ &bull; Bảo mật thông tin đa vai trò
        </div>
      </div>
    </div>
  );
};
