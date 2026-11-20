import axios from 'axios';

export const apiClient = axios.create({
    baseURL: import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000/api/v1',
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request Interceptor: Attach JWT Token
apiClient.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => Promise.reject(error));

// Response Interceptor
apiClient.interceptors.response.use((response) => response, (error) => {
    const status = error.response?.status;
    const message = error.response?.data?.detail ||
        error.response?.data?.message ||
        'Đã xảy ra lỗi khi kết nối máy chủ.';

    // Token hết hạn / không hợp lệ: xóa session và tải lại để về màn hình đăng nhập.
    if (status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        if (typeof window !== 'undefined') window.location.reload();
    }

    const wrapped = new Error(message);
    wrapped.status = status;
    return Promise.reject(wrapped);
});

// 1. Auth API
export const authApi = {
    login: async (username, password) => {
        const res = await apiClient.post('/auth/login', { username, password });
        return res.data;
    },
    getMe: async () => {
        const res = await apiClient.get('/auth/me');
        return res.data;
    },
    getRolesPermissions: async () => {
        const res = await apiClient.get('/auth/roles-permissions');
        return res.data;
    },
    forgotPassword: async (params) => {
        const payload = typeof params === 'string'
            ? { email: params, identifier: params, channel: 'EMAIL' }
            : { channel: 'EMAIL', ...params };
        const res = await apiClient.post('/auth/forgot-password', payload);
        return res.data;
    },
    resetPassword: async (identifier, reset_code, new_password) => {
        const res = await apiClient.post('/auth/reset-password', { identifier, reset_code, new_password });
        return res.data;
    },
    register: async (userData) => {
        const res = await apiClient.post('/auth/register', userData);
        return res.data;
    },
};

// 2. Accounts API
export const accountsApi = {
    list: async (q, role) => {
        const res = await apiClient.get('/accounts/', { params: { q, role } });
        return res.data;
    },
    create: async (data) => {
        const res = await apiClient.post('/accounts/', data);
        return res.data;
    },
    update: async (id, data) => {
        const res = await apiClient.put(`/accounts/${id}`, data);
        return res.data;
    },
    delete: async (id) => {
        const res = await apiClient.delete(`/accounts/${id}`);
        return res.data;
    },
    changePassword: async (old_password, new_password) => {
        const res = await apiClient.post('/accounts/change-password', {
            old_password,
            new_password,
        });
        return res.data;
    },
    updateRole: async (id, role) => {
        const res = await apiClient.patch(`/accounts/${id}/role`, { role });
        return res.data;
    },
    toggleLock: async (id) => {
        const res = await apiClient.patch(`/accounts/${id}/toggle-lock`);
        return res.data;
    },
    adminResetPassword: async (id, new_password) => {
        const res = await apiClient.post(`/accounts/${id}/reset-password`, { new_password });
        return res.data;
    },
    getRelatedStudents: async (userId) => {
        const res = await apiClient.get(`/accounts/${userId}/related-students`);
        return res.data;
    },
    getMe: async () => {
        const res = await apiClient.get('/accounts/me');
        return res.data;
    },
    updateMyProfile: async (data) => {
        const res = await apiClient.put('/accounts/me', data);
        return res.data;
    },
    updateMyAvatar: async (avatar_url) => {
        const res = await apiClient.patch('/accounts/me/avatar', { avatar_url });
        return res.data;
    },
    uploadMyAvatar: async (file) => {
        const formData = new FormData();
        formData.append('file', file);
        const res = await apiClient.post('/accounts/me/avatar/upload', formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
        });
        return res.data;
    },
    deleteMyAvatar: async () => {
        const res = await apiClient.delete('/accounts/me/avatar');
        return res.data;
    },
};

// 3. Courses API
export const coursesApi = {
    list: async (q, only_active = false) => {
        const res = await apiClient.get('/courses/', {
            params: { q, only_active },
        });
        return res.data;
    },
    create: async (data) => {
        const res = await apiClient.post('/courses/', data);
        return res.data;
    },
    update: async (id, data) => {
        const res = await apiClient.put(`/courses/${id}`, data);
        return res.data;
    },
    toggleStatus: async (id) => {
        const res = await apiClient.patch(`/courses/${id}/toggle-status`);
        return res.data;
    },
    delete: async (id) => {
        const res = await apiClient.delete(`/courses/${id}`);
        return res.data;
    },
};

// 4. Students API
export const studentsApi = {
    list: async (q) => {
        const res = await apiClient.get('/students/', { params: { q } });
        return res.data;
    },
    getHistory: async (id) => {
        const res = await apiClient.get(`/students/${id}/history`);
        return res.data;
    },
};

// 5. Teachers API
export const teachersApi = {
    list: async (q) => {
        const res = await apiClient.get('/teachers/', { params: { q } });
        return res.data;
    },
    getSchedule: async (id) => {
        const res = await apiClient.get(`/teachers/${id}/schedule`);
        return res.data;
    },
};

// 6. Classes API
export const classesApi = {
    list: async (q, status, teacher_id, my_classes) => {
        let params = {};
        if (typeof q === 'object' && q !== null) {
            params = q;
        } else {
            if (q) params.q = q;
            if (status) params.status = status;
            if (teacher_id) params.teacher_id = teacher_id;
            if (my_classes) params.my_classes = my_classes;
        }
        const res = await apiClient.get('/classes/', { params });
        return res.data;
    },
    create: async (data) => {
        const res = await apiClient.post('/classes/', data);
        return res.data;
    },
    update: async (classId, data) => {
        const res = await apiClient.put(`/classes/${classId}`, data);
        return res.data;
    },
    delete: async (classId) => {
        const res = await apiClient.delete(`/classes/${classId}`);
        return res.data;
    },
    assignTeacher: async (classId, teacherId) => {
        const res = await apiClient.patch(`/classes/${classId}/assign-teacher`, null, {
            params: { teacher_id: teacherId },
        });
        return res.data;
    },
    getRoster: async (classId) => {
        const res = await apiClient.get(`/classes/${classId}/students`);
        return res.data;
    },
    updateStatus: async (classId, status) => {
        const res = await apiClient.patch(`/classes/${classId}/status`, null, {
            params: { new_status: status },
        });
        return res.data;
    },
    getTransferTargets: async (classId) => {
        const res = await apiClient.get(`/classes/${classId}/transfer-targets`);
        return res.data;
    },
    createTransferRequest: async (data) => {
        const res = await apiClient.post('/classes/transfer-requests', data);
        return res.data;
    },
    listTransferRequests: async (params) => {
        const res = await apiClient.get('/classes/transfer-requests', { params });
        return res.data;
    },
    getTransferRequest: async (requestId) => {
        const res = await apiClient.get(`/classes/transfer-requests/${requestId}`);
        return res.data;
    },
    approveTransferRequest: async (requestId) => {
        const res = await apiClient.post(`/classes/transfer-requests/${requestId}/approve`);
        return res.data;
    },
    rejectTransferRequest: async (requestId, data) => {
        const res = await apiClient.post(`/classes/transfer-requests/${requestId}/reject`, data);
        return res.data;
    },
    transfer: async (data) => {
        const res = await apiClient.post('/classes/transfer', data);
        return res.data;
    },
};

// 7. Classrooms API
export const classroomsApi = {
    list: async (status) => {
        const res = await apiClient.get('/classrooms/', { params: { status } });
        return res.data;
    },
    create: async (data) => {
        const res = await apiClient.post('/classrooms/', data);
        return res.data;
    },
    update: async (id, data) => {
        const res = await apiClient.put(`/classrooms/${id}`, data);
        return res.data;
    },
    delete: async (id) => {
        const res = await apiClient.delete(`/classrooms/${id}`);
        return res.data;
    },
    updateCapacity: async (id, capacity) => {
        const res = await apiClient.patch(`/classrooms/${id}/capacity`, null, {
            params: { capacity },
        });
        return res.data;
    },
    updateStatus: async (id, status) => {
        const res = await apiClient.patch(`/classrooms/${id}/status`, null, {
            params: { status },
        });
        return res.data;
    },
};

// 8. Enrollments API
export const enrollmentsApi = {
    listAll: async (status) => {
        const res = await apiClient.get('/enrollments/', {
            params: { status },
        });
        return res.data;
    },
    getMyRequests: async () => {
        const res = await apiClient.get('/enrollments/my-requests');
        return res.data;
    },
    createRequest: async (class_id, note) => {
        const res = await apiClient.post('/enrollments/', {
            class_id,
            note,
        });
        return res.data;
    },
    cancelRequest: async (id) => {
        const res = await apiClient.patch(`/enrollments/${id}/cancel`);
        return res.data;
    },
    approve: async (id) => {
        const res = await apiClient.patch(`/enrollments/${id}/approve`);
        return res.data;
    },
    reject: async (id, rejection_reason) => {
        const res = await apiClient.patch(`/enrollments/${id}/reject`, {
            rejection_reason,
        });
        return res.data;
    },
    checkPrerequisite: async (classId, studentId) => {
        const params = { class_id: classId };
        if (studentId) params.student_id = studentId;
        const res = await apiClient.get('/enrollments/check-prerequisite', { params });
        return res.data;
    },
};

// 9. Schedules API
export const schedulesApi = {
    list: async (classId, teacherId) => {
        const res = await apiClient.get('/schedules/', {
            params: { class_id: classId, teacher_id: teacherId },
        });
        return res.data;
    },
    getPersonal: async () => {
        const res = await apiClient.get('/schedules/personal');
        return res.data;
    },
    create: async (data) => {
        const res = await apiClient.post('/schedules/', data);
        return res.data;
    },
    createRecurring: async (data) => {
        const res = await apiClient.post('/schedules/recurring', data);
        return res.data;
    },
    update: async (id, data) => {
        const res = await apiClient.put(`/schedules/${id}`, data);
        return res.data;
    },
    cancel: async (id) => {
        const res = await apiClient.patch(`/schedules/${id}/cancel`);
        return res.data;
    },
    delete: async (id) => {
        const res = await apiClient.delete(`/schedules/${id}`);
        return res.data;
    },
    checkConflicts: async (data) => {
        const res = await apiClient.post('/schedules/check-conflicts', data);
        return res.data;
    },
    confirmSchedule: async (classId) => {
        const res = await apiClient.patch(`/schedules/classes/${classId}/confirm`);
        return res.data;
    },
};

// 10. Grades API
export const gradesApi = {
    getGradingSheet: async (classId) => {
        const res = await apiClient.get(`/grades/classes/${classId}/sheet`);
        return res.data;
    },
    saveGrades: async (classId, grades) => {
        const res = await apiClient.post('/grades/batch', {
            class_id: classId,
            grades,
        });
        return res.data;
    },
    confirmGrades: async (classId, reason) => {
        const res = await apiClient.patch(`/grades/classes/${classId}/confirm`, { reason });
        return res.data;
    },
    unlockGrades: async (classId, reason) => {
        const res = await apiClient.patch(`/grades/classes/${classId}/unlock`, { reason });
        return res.data;
    },
    getLockStatus: async (classId) => {
        const res = await apiClient.get(`/grades/classes/${classId}/lock-status`);
        return res.data;
    },
    getLockHistory: async (classId) => {
        const res = await apiClient.get(`/grades/classes/${classId}/lock-history`);
        return res.data;
    },
    addStudentToGradeSheet: async (classId, data) => {
        const res = await apiClient.post(`/grades/classes/${classId}/students`, data);
        return res.data;
    },
    deleteStudentFromGradeSheet: async (classId, studentId) => {
        const res = await apiClient.delete(`/grades/classes/${classId}/students/${studentId}`);
        return res.data;
    },
    getMyGrades: async () => {
        const res = await apiClient.get('/grades/my-grades');
        return res.data;
    },
};

// 11. Progression & Parent API
export const progressionParentApi = {
    listAll: async (status, student_id) => {
        const res = await apiClient.get('/progression/', {
            params: { status, student_id },
        });
        return res.data;
    },
    getMyProgressions: async () => {
        const res = await apiClient.get('/progression/my-progressions');
        return res.data;
    },
    getAvailableCourses: async () => {
        const res = await apiClient.get('/progression/available-courses');
        return res.data;
    },
    requestProgression: async (data) => {
        const res = await apiClient.post('/progression/request', data);
        return res.data;
    },
    cancelProgression: async (id) => {
        const res = await apiClient.patch(`/progression/${id}/cancel`);
        return res.data;
    },
    rejectProgression: async (id, reason) => {
        const res = await apiClient.patch(`/progression/${id}/reject`, { reason });
        return res.data;
    },
    checkEligibility: async (student_id, current_course_id, next_course_id) => {
        const res = await apiClient.post('/progression/check-eligibility', {
            student_id,
            current_course_id,
            next_course_id,
        });
        return res.data;
    },
    confirmProgression: async (progressionId) => {
        const res = await apiClient.patch(`/progression/${progressionId}/confirm`);
        return res.data;
    },
    registerNextCourse: async (target_class_id) => {
        const res = await apiClient.post('/progression/register-next', null, {
            params: { target_class_id },
        });
        return res.data;
    },
    getParentWards: async () => {
        const res = await apiClient.get('/progression/parent/my-wards');
        return res.data;
    },
    getWardEnrollmentStatus: async (studentId) => {
        const res = await apiClient.get(`/progression/parent/wards/${studentId}/enrollment-status`);
        return res.data;
    },
    getWardGrades: async (studentId) => {
        const res = await apiClient.get(`/progression/parent/wards/${studentId}/grades`);
        return res.data;
    },
};

// 12. Tickets & Complaints / Requests API
export const ticketsApi = {
    create: async (data) => {
        const res = await apiClient.post('/tickets/', data);
        return res.data;
    },
    listSent: async (params = null) => {
        const res = await apiClient.get('/tickets/sent', { params });
        return res.data;
    },
    listInbox: async (params = null) => {
        const res = await apiClient.get('/tickets/inbox', { params });
        return res.data;
    },
    getDetail: async (id) => {
        const res = await apiClient.get(`/tickets/${id}`);
        return res.data;
    },
    sendMessage: async (id, content) => {
        const res = await apiClient.post(`/tickets/${id}/messages`, { content });
        return res.data;
    },
    updateStatus: async (id, status, reason = null) => {
        const res = await apiClient.patch(`/tickets/${id}/status`, { status, reason });
        return res.data;
    },
    checkDeadline: async (classId) => {
        const res = await apiClient.get(`/tickets/check-deadline/${classId}`);
        return res.data;
    },
    getStats: async () => {
        const res = await apiClient.get('/tickets/stats');
        return res.data;
    },
};
