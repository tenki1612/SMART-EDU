import React, { createContext, useContext, useState, useCallback } from 'react';
import { CheckCircle2, AlertTriangle, XCircle, Info, X } from 'lucide-react';
const ToastContext = createContext(undefined);
export const ToastProvider = ({ children }) => {
    const [toasts, setToasts] = useState([]);
    const addToast = useCallback((type, message) => {
        const id = Date.now() + Math.random();
        setToasts((prev) => [...prev, { id, type, message }]);
        setTimeout(() => {
            setToasts((prev) => prev.filter((t) => t.id !== id));
        }, 4000);
    }, []);
    const removeToast = (id) => {
        setToasts((prev) => prev.filter((t) => t.id !== id));
    };
    const success = (msg) => addToast('success', msg);
    const error = (msg) => addToast('error', msg);
    const warning = (msg) => addToast('warning', msg);
    const info = (msg) => addToast('info', msg);
    const icons = {
        success: <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0"/>,
        error: <XCircle className="w-4 h-4 text-red-600 shrink-0"/>,
        warning: <AlertTriangle className="w-4 h-4 text-amber-600 shrink-0"/>,
        info: <Info className="w-4 h-4 text-blue-600 shrink-0"/>,
    };
    const borders = {
        success: 'border-emerald-200 bg-emerald-50 text-emerald-900',
        error: 'border-red-200 bg-red-50 text-red-900',
        warning: 'border-amber-200 bg-amber-50 text-amber-900',
        info: 'border-blue-200 bg-blue-50 text-blue-900',
    };
    return (<ToastContext.Provider value={{ success, error, warning, info }}>
      {children}
      {/* Toast Notification Container */}
      <div className="fixed bottom-5 right-5 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none px-4 sm:px-0">
        {toasts.map((t) => (<div key={t.id} className={`pointer-events-auto flex items-center justify-between gap-3 p-3.5 rounded-xl border shadow-lg text-xs font-semibold backdrop-blur-xs transition-all duration-200 ${borders[t.type]}`}>
            <div className="flex items-center gap-2">
              {icons[t.type]}
              <span>{t.message}</span>
            </div>
            <button onClick={() => removeToast(t.id)} className="text-slate-400 hover:text-slate-700 cursor-pointer p-0.5">
              <X className="w-3.5 h-3.5"/>
            </button>
          </div>))}
      </div>
    </ToastContext.Provider>);
};
export const useToast = () => {
    const ctx = useContext(ToastContext);
    if (!ctx)
        throw new Error('useToast must be used within ToastProvider');
    return ctx;
};
