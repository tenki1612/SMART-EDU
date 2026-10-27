import React, { createContext, useContext, useState, useRef, useCallback } from 'react';
import { createPortal } from 'react-dom';
import { AlertTriangle, Trash2, Info, X, ShieldAlert } from 'lucide-react';

const ConfirmDialogContext = createContext(null);

export const ConfirmDialogProvider = ({ children }) => {
  const [dialogState, setDialogState] = useState({
    isOpen: false,
    title: '',
    message: '',
    confirmText: 'Xác nhận',
    cancelText: 'Hủy bỏ',
    type: 'danger', // 'danger' | 'warning' | 'info'
    resolve: null,
  });

  const confirm = useCallback(({
    title = 'Xác nhận hành động',
    message = 'Bạn có chắc chắn muốn thực hiện thao tác này?',
    confirmText = 'Xác nhận',
    cancelText = 'Hủy bỏ',
    type = 'danger',
  }) => {
    return new Promise((resolve) => {
      setDialogState({
        isOpen: true,
        title,
        message,
        confirmText,
        cancelText,
        type,
        resolve,
      });
    });
  }, []);

  const handleClose = (result) => {
    if (dialogState.resolve) {
      dialogState.resolve(result);
    }
    setDialogState((prev) => ({ ...prev, isOpen: false, resolve: null }));
  };

  const getVisualConfig = () => {
    switch (dialogState.type) {
      case 'danger':
        return {
          icon: <Trash2 className="w-6 h-6 text-rose-600" />,
          iconBg: 'bg-rose-50 border-rose-200 text-rose-600',
          confirmBtn: 'bg-rose-600 hover:bg-rose-700 focus:ring-rose-500 shadow-rose-200 text-white',
        };
      case 'warning':
        return {
          icon: <AlertTriangle className="w-6 h-6 text-amber-600" />,
          iconBg: 'bg-amber-50 border-amber-200 text-amber-600',
          confirmBtn: 'bg-amber-600 hover:bg-amber-700 focus:ring-amber-500 shadow-amber-200 text-white',
        };
      case 'info':
      default:
        return {
          icon: <Info className="w-6 h-6 text-indigo-600" />,
          iconBg: 'bg-indigo-50 border-indigo-200 text-indigo-600',
          confirmBtn: 'bg-indigo-600 hover:bg-indigo-700 focus:ring-indigo-500 shadow-indigo-200 text-white',
        };
    }
  };

  const visual = getVisualConfig();

  return (
    <ConfirmDialogContext.Provider value={confirm}>
      {children}
      {dialogState.isOpen &&
        createPortal(
          <div
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-xs animate-in fade-in duration-200 select-none"
            onClick={() => handleClose(false)}
          >
            <div
              className="relative w-full max-w-md bg-white rounded-3xl p-6 sm:p-7 shadow-2xl border border-slate-200 transform transition-all animate-in zoom-in-95 duration-200"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Header Icon + Close */}
              <div className="flex items-start justify-between gap-4">
                <div
                  className={`w-12 h-12 rounded-2xl flex items-center justify-center border shadow-xs shrink-0 ${visual.iconBg}`}
                >
                  {visual.icon}
                </div>
                <button
                  type="button"
                  onClick={() => handleClose(false)}
                  className="w-8 h-8 rounded-full flex items-center justify-center text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                  aria-label="Đóng hộp thoại"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* Title & Message */}
              <div className="mt-4">
                <h3 className="text-base font-extrabold text-slate-900 leading-snug">
                  {dialogState.title}
                </h3>
                <p className="mt-2 text-xs font-medium text-slate-600 leading-relaxed">
                  {dialogState.message}
                </p>
              </div>

              {/* Action Buttons */}
              <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => handleClose(false)}
                  className="px-4 py-2.5 rounded-xl text-xs font-bold text-slate-700 hover:bg-slate-100 border border-slate-300 transition cursor-pointer active:scale-95"
                >
                  {dialogState.cancelText}
                </button>
                <button
                  type="button"
                  onClick={() => handleClose(true)}
                  className={`px-4 py-2.5 rounded-xl text-xs font-bold shadow-md transition cursor-pointer active:scale-95 focus:outline-none focus:ring-2 focus:ring-offset-2 ${visual.confirmBtn}`}
                >
                  {dialogState.confirmText}
                </button>
              </div>
            </div>
          </div>,
          document.body
        )}
    </ConfirmDialogContext.Provider>
  );
};

export const useConfirm = () => {
  const context = useContext(ConfirmDialogContext);
  if (!context) {
    throw new Error('useConfirm must be used within a ConfirmDialogProvider');
  }
  return context;
};

