import React, { createContext, useState, useContext, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const extractUserInfo = (decodedToken) => {
    if (!decodedToken) return null;
    return {
      ...decodedToken,
      id: decodedToken["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"],
      name: decodedToken["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"], 
      phone: decodedToken["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone"],
      role: decodedToken["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"],
    };
  };

  useEffect(() => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      try {
        const decoded = jwtDecode(token);
        setUser(extractUserInfo(decoded)); 
      } catch (e) {
        localStorage.clear();
      }
    }
    setLoading(false);
  }, []);

  const login = (tokens) => {
    localStorage.setItem('accessToken', tokens.accessToken);
    localStorage.setItem('refreshToken', tokens.refreshToken);
    const decoded = jwtDecode(tokens.accessToken);
    setUser(extractUserInfo(decoded)); 
  };
  const logout = () => {
    localStorage.clear();
    setUser(null);
    window.location.href = '/login';
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isAuthenticated: !!user }}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);