import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { ApiError, setAuthErrorHandler } from '../api/client';
import { adminApi } from '../api/endpoints';
import { clearTokens, getRefresh, setTokens } from '../api/tokens';
import type { AdminMe } from '../api/types';

/** offline — сервер не ответил (нет сети); сессия сохранена, можно повторить. */
export type AuthStatus = 'checking' | 'signedOut' | 'signedIn' | 'forbidden' | 'offline';

interface AuthValue {
  status: AuthStatus;
  me: AdminMe | null;
  signIn: (email: string, otp: string) => Promise<void>;
  signOut: () => Promise<void>;
  /** Повторная проверка сессии после `offline`. */
  retry: () => void;
}

const AuthContext = createContext<AuthValue | null>(null);

export function AuthProvider({ children, onSignOut }: { children: ReactNode; onSignOut?: () => void }) {
  const [status, setStatus] = useState<AuthStatus>('checking');
  const [me, setMe] = useState<AdminMe | null>(null);

  const loadMe = useCallback(async () => {
    try {
      setMe(await adminApi.me());
      setStatus('signedIn');
    } catch (error) {
      if (error instanceof ApiError && error.status === 0) {
        // Нет связи — это не отказ сервера: токены не трогаем, ждём «Повторить».
        setStatus('offline');
      } else if (error instanceof ApiError && error.status === 403) {
        setStatus('forbidden');
      } else {
        clearTokens();
        setStatus('signedOut');
      }
    }
  }, []);

  useEffect(() => {
    // Потеря сессии/прав посреди работы → логин или «нет доступа».
    setAuthErrorHandler((code) => setStatus(code === 403 ? 'forbidden' : 'signedOut'));
    if (getRefresh()) void loadMe();
    else setStatus('signedOut');
    return () => setAuthErrorHandler(null);
  }, [loadMe]);

  const signIn = useCallback(
    async (email: string, otp: string) => {
      const tokens = await adminApi.verifyOtp(email, otp);
      setTokens(tokens['access-token'], tokens['refresh-token']);
      await loadMe();
    },
    [loadMe],
  );

  const signOut = useCallback(async () => {
    try {
      await adminApi.logout();
    } catch {
      // сессия могла уже истечь — локальный выход всё равно выполняем
    }
    clearTokens();
    setMe(null);
    setStatus('signedOut');
    onSignOut?.();
  }, [onSignOut]);

  const retry = useCallback(() => {
    setStatus('checking');
    void loadMe();
  }, [loadMe]);

  const value = useMemo(() => ({ status, me, signIn, signOut, retry }), [status, me, signIn, signOut, retry]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthValue {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth вне AuthProvider');
  return value;
}
