import React, { createContext, useContext, useState, useEffect } from 'react';
import { authApi } from '../services/api';
const AuthContext = createContext(undefined);
export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [token, setToken] = useState(localStorage.getItem('token'));
    const [isLoading, setIsLoading] = useState(true);
    const fetchCurrentUser = async () => {
        try {
            const res = await authApi.getMe();
            if (res.success && res.data) {
                setUser(res.data);
            }
            else {
                logout();
            }
        }
        catch (err) {
            logout();
        }
        finally {
            setIsLoading(false);
        }
    };
    useEffect(() => {
        if (token) {
            fetchCurrentUser();
        }
        else {
            setIsLoading(false);
        }
    }, [token]);
    const login = async (username, password) => {
        setIsLoading(true);
        try {
            const res = await authApi.login(username, password);
            if (res.success && res.data) {
                const { access_token, user_id, username: uName, full_name, role } = res.data;
                localStorage.setItem('token', access_token);
                setToken(access_token);
                setUser({
                    id: user_id,
                    username: uName,
                    email: `${uName}@center.edu.vn`,
                    full_name,
                    role,
                    is_active: true,
                });
            }
        }
        finally {
            setIsLoading(false);
        }
    };
    const logout = () => {
        localStorage.removeItem('token');
        setToken(null);
        setUser(null);
    };
    const hasRole = (roles) => {
        if (!user)
            return false;
        return roles.includes(user.role);
    };
    return (<AuthContext.Provider value={{
            user,
            token,
            isLoading,
            login,
            logout,
            hasRole,
        }}>
      {children}
    </AuthContext.Provider>);
};
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
