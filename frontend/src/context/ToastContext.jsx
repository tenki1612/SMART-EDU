import React, { createContext, useContext, useState, useCallback } from 'react';
import { createPortal } from 'react-dom';
import { CheckCircle2, AlertTriangle, XCircle, Info, X } from 'lucide-react';

const ToastContext = createContext(undefined);

export const ToastProvider = ({ children }) => {
  const [toasts, setToasts] = useState([]);

  const addToast = useCallback((type, message) => {
    const id = Date.now() + Math.random();
    setToasts((prev) => [...prev, { id, type, message }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4500);
  }, []);

  const removeToast = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const success = (msg) => addToast('success', msg);
  const error = (msg) => addToast('error', msg);
  const warning = (msg) => addToast('warning', msg);
  const info = (msg) => addToast('info', msg);

  const configs = {
    success: {
      icon: <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />,
      style: 'border-emerald-200/90 bg-emerald-50/95 text-emerald-950 shadow-emerald-500/10',
      badge: 'Thành công',
    },
    error: {
      icon: <XCircle className="w-4 h-4 text-rose-600 shrink-0" />,
      style: 'border-rose-200/90 bg-rose-50/95 text-rose-950 shadow-rose-500/10',
      badge: 'Lỗi',
    },
    warning: {
      icon: <AlertTriangle className="w-4 h-4 text-amber-600 shrink-0" />,
      style: 'border-amber-200/90 bg-amber-50/95 text-amber-950 shadow-amber-500/10',
      badge: 'Cảnh báo',
    },
    info: {
      icon: <Info className="w-4 h-4 text-indigo-600 shrink-0" />,
      style: 'border-indigo-200/90 bg-indigo-50/95 text-indigo-950 shadow-indigo-500/10',
      badge: 'Thông báo',
    },
  };

  return (
    <ToastContext.Provider value={{ success, error, warning, info }}>
      {children}
      {createPortal(
        <div className="fixed bottom-5 right-5 z-50 flex flex-col gap-2.5 max-w-sm w-full pointer-events-none px-4 sm:px-0">
          {toasts.map((t) => {
            const conf = configs[t.type] || configs.info;
            return (
              <div
                key={t.id}
                className={`pointer-events-auto flex items-start justify-between gap-3 p-3.5 rounded-2xl border shadow-xl text-xs font-semibold backdrop-blur-md transition-all duration-200 animate-in slide-in-from-bottom-2 fade-in ${conf.style}`}
              >
                <div className="flex items-start gap-2.5 min-w-0">
                  <div className="mt-0.5">{conf.icon}</div>
                  <div className="min-w-0">
                    <p className="text-xs font-bold leading-snug break-words">
                      {t.message}
                    </p>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => removeToast(t.id)}
                  className="text-slate-400 hover:text-slate-700 cursor-pointer p-0.5 rounded-md shrink-0 transition"
                  aria-label="Đóng thông báo"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>
            );
          })}
        </div>,
        document.body
      )}
    </ToastContext.Provider>
  );
};

export const useToast = () => {
  const ctx = useContext(ToastContext);
  if (!ctx) {
    throw new Error('useToast must be used within ToastProvider');
  }
  return ctx;
};
