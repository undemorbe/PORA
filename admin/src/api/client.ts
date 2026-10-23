import { clearTokens, getAccess, getRefresh, setTokens } from './tokens';

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string | undefined,
    message: string,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

type Query = Record<string, string | number | undefined>;

interface RequestOptions {
  method?: 'GET' | 'POST';
  query?: Query;
  body?: unknown;
  /** false — публичный вызов: без токена и без refresh. */
  auth?: boolean;
}

type AuthErrorHandler = (status: 401 | 403) => void;

let authErrorHandler: AuthErrorHandler | null = null;
let refreshing: Promise<boolean> | null = null;

/** Реакция приложения на потерю сессии (401) или прав (403). */
export function setAuthErrorHandler(handler: AuthErrorHandler | null): void {
  authErrorHandler = handler;
}

/** Обновляет access-токен; параллельные вызовы делят один запрос. */
export function refreshSession(): Promise<boolean> {
  refreshing ??= doRefresh().finally(() => {
    refreshing = null;
  });
  return refreshing;
}

async function doRefresh(): Promise<boolean> {
  const refresh = getRefresh();
  if (!refresh) return false;
  try {
    // Контракт бэкенда: refresh-токен в query. nginx не логирует /api/authorize/.
    // Любой неуспех (401 REFRESH_TOKEN_EXPIRED, 403 — админ-права отозваны) → сессия сброшена.
    const res = await fetch(`/api/authorize/refresh?${new URLSearchParams({ 'refresh-token': refresh })}`);
    if (!res.ok) {
      clearTokens();
      return false;
    }
    const body = (await res.json()) as { 'access-token': string; 'refresh-token': string };
    setTokens(body['access-token'], body['refresh-token']);
    return true;
  } catch {
    return false;
  }
}

function buildUrl(path: string, query?: Query): string {
  if (!query) return path;
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== '') params.set(key, String(value));
  }
  const search = params.toString();
  return search ? `${path}?${search}` : path;
}

export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = 'GET', query, body, auth = true } = options;

  const send = () => {
    const headers: Record<string, string> = { Accept: 'application/json' };
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    const token = getAccess();
    if (auth && token) headers.Authorization = `Bearer ${token}`;
    return fetch(buildUrl(path, query), {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  };

  let res = await send();
  if (auth && res.status === 401 && (await refreshSession())) {
    res = await send();
  }

  if (!res.ok) {
    const payload = (await res.json().catch(() => ({}))) as { code?: string; message?: string };
    if (auth && (res.status === 401 || res.status === 403)) {
      if (res.status === 401) clearTokens();
      authErrorHandler?.(res.status);
    }
    throw new ApiError(res.status, payload.code, payload.message ?? res.statusText);
  }

  const text = await res.text();
  return (text ? JSON.parse(text) : undefined) as T;
}
