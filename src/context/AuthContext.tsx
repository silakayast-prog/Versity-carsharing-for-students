import React, { createContext, useContext, useState, useEffect } from 'react';
import { apiClient, setAuthToken } from '../api/client';

export interface UserProfile {
  id: string;
  ad_soyad: string;
  okul_email: string;
  is_premium: boolean;
  kalan_ucretsiz_binis: number;
  aktif_rol: 'sofor' | 'yolcu' | 'belirsiz';
  puan: number;
  profil_foto_url?: string;
  ozel_ihtiyac?: string;
  driver_points?: {
    toplam_puan: number;
    rozet_seviyesi: 'baslangic' | 'guvenilir' | 'yildiz' | 'elit';
    aylik_yolculuk: number;
  };
  vehicles?: Array<{
    id: string;
    marka_model: string;
    plaka: string;
    kapasite: number;
  }>;
}

interface AuthContextType {
  user: UserProfile | null;
  token: string | null;
  isLoading: boolean;
  activeRole: 'sofor' | 'yolcu';
  login: (okul_email: string, sifre: string) => Promise<void>;
  register: (data: { ad_soyad: string; okul_email: string; sifre: string; yas_onay: boolean; kvkk_onay: boolean }) => Promise<void>;
  logout: () => void;
  switchRole: (role: 'sofor' | 'yolcu') => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [activeRole, setActiveRole] = useState<'sofor' | 'yolcu'>('yolcu');

  const login = async (okul_email: string, sifre: string) => {
    setIsLoading(true);
    try {
      const res: any = await apiClient.post('/auth/login', { okul_email, sifre });
      const { user: userData, accessToken } = res.data;
      
      setUser(userData);
      setToken(accessToken);
      setAuthToken(accessToken);
      if (userData.aktif_rol === 'sofor' || userData.aktif_rol === 'yolcu') {
        setActiveRole(userData.aktif_rol);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (data: any) => {
    setIsLoading(true);
    try {
      const res: any = await apiClient.post('/auth/register', data);
      const { user: userData, accessToken } = res.data;

      setUser(userData);
      setToken(accessToken);
      setAuthToken(accessToken);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    setAuthToken(null);
  };

  const switchRole = async (role: 'sofor' | 'yolcu') => {
    if (!token) return;
    try {
      await apiClient.patch('/users/role', { aktif_rol: role });
      setActiveRole(role);
      if (user) {
        setUser({ ...user, aktif_rol: role });
      }
    } catch (e) {
      console.warn('Role switch failed', e);
    }
  };

  const refreshProfile = async () => {
    if (!token) return;
    try {
      const res: any = await apiClient.get('/users/me');
      setUser(res.data);
    } catch (e) {
      console.warn('Failed to refresh profile', e);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        activeRole,
        login,
        register,
        logout,
        switchRole,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
