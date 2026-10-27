import React, { Component, StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import './App.css';
import App from './App.jsx';

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, info: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, info) {
    console.error('CRITICAL REACT CRASH:', error, info);
    this.setState({ error, info });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: 40, fontFamily: 'sans-serif', color: '#b91c1c', background: '#fef2f2', minHeight: '100vh' }}>
          <h1 style={{ fontSize: 24, fontWeight: 'bold' }}>⚠️ Ứng dụng gặp lỗi khi khởi chạy:</h1>
          <pre style={{ background: '#fff', padding: 20, borderRadius: 8, border: '1px solid #fecaca', overflowX: 'auto', marginTop: 16 }}>
            {this.state.error?.toString()}
            {'\n\n'}
            {this.state.info?.componentStack || this.state.error?.stack}
          </pre>
          <button
            type="button"
            onClick={() => { localStorage.clear(); window.location.reload(); }}
            style={{ marginTop: 20, padding: '10px 20px', background: '#dc2626', color: '#fff', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 'bold' }}
          >
            Xóa dữ liệu phiên &amp; Khởi động lại
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </StrictMode>
);
