import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { ApiError, setAuthErrorHandler } from '../api/client';
import { adminApi } from '../api/endpoints';
import { clearTokens, getRefresh, setTokens } from '../api/tokens';
import type { AdminMe } from '../api/types';

/** offline — сервер не ответил или упал; сессия сохранена, можно повторить. */
export type AuthStatus = 'checking' | 'signedOut' | 'signedIn' | 'forbidden' | 'offline';

/** network — нет связи; server — сервер ответил 5xx. */
export type OfflineReason = 'network' | 'server';

interface AuthValue {
  status: AuthStatus;
  me: AdminMe | null;
  /** Причина последнего `offline`; null в остальных статусах. */
  offlineReason: OfflineReason | null;
  signIn: (email: string, otp: string) => Promise<void>;
  signOut: () => Promise<void>;
  /** Повторная проверка сессии после `offline`. */
  retry: () => void;
}

const AuthContext = createContext<AuthValue | null>(null);

type LoadMode = 'restore' | 'signIn';

export function AuthProvider({ children, onSignOut }: { children: ReactNode; onSignOut?: () => void }) {
  const [status, setStatus] = useState<AuthStatus>('checking');
  const [me, setMe] = useState<AdminMe | null>(null);
  const [offlineReason, setOfflineReason] = useState<OfflineReason | null>(null);

  // Ref, чтобы новый колбэк из props не перезапускал эффект с проверкой сессии.
  const onSignOutRef = useRef(onSignOut);
  onSignOutRef.current = onSignOut;

  /** Загружает профиль; возвращает ошибку, если вход не состоялся. */
  const loadMe = useCallback(async (mode: LoadMode): Promise<unknown> => {
    try {
      setMe(await adminApi.me());
      setOfflineReason(null);
      setStatus('signedIn');
      return null;
    } catch (error) {
      const code = error instanceof ApiError ? error.status : 0;
      if (code === 401) {
        // Сессия отвергнута: токены уже сброшены клиентом.
        setMe(null);
        setStatus('signedOut');
      } else if (code === 403) {
        setStatus('forbidden');
      } else if (mode === 'signIn') {
        // Код принят, но профиль не загрузился: остаёмся на логине и показываем ошибку там.
        clearTokens();
        setMe(null);
        setStatus('signedOut');
      } else {
        // Сеть или сбой сервера — не отказ: сессию храним, ждём «Повторить».
        setOfflineReason(code >= 500 ? 'server' : 'network');
        setStatus('offline');
      }
      return error;
    }
  }, []);

  useEffect(() => {
    // Потеря сессии/прав посреди работы → логин (с очисткой кэша) или «нет доступа».
    setAuthErrorHandler((code) => {
      if (code === 403) {
        setStatus('forbidden');
        return;
      }
      setMe(null);
      setStatus('signedOut');
      onSignOutRef.current?.();
    });
    if (getRefresh()) void loadMe('restore');
    else setStatus('signedOut');
    return () => setAuthErrorHandler(null);
  }, [loadMe]);

  const signIn = useCallback(
    async (email: string, otp: string) => {
      const tokens = await adminApi.verifyOtp(email, otp);
      setTokens(tokens['access-token'], tokens['refresh-token']);
      const error = await loadMe('signIn');
      if (error) throw error;
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
    onSignOutRef.current?.();
  }, []);

  const retry = useCallback(() => {
    setStatus('checking');
    void loadMe('restore');
  }, [loadMe]);

  const value = useMemo(
    () => ({ status, me, offlineReason, signIn, signOut, retry }),
    [status, me, offlineReason, signIn, signOut, retry],
  );
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthValue {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth вне AuthProvider');
  return value;
}
