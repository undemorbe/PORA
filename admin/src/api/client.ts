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

/** ok — токены обновлены; refused — сервер отказал (сессия сброшена); network — нет связи (сессия сохранена). */
export type RefreshResult = 'ok' | 'refused' | 'network';

let authErrorHandler: AuthErrorHandler | null = null;
let refreshing: Promise<RefreshResult> | null = null;

/** Реакция приложения на потерю сессии (401) или прав (403). */
export function setAuthErrorHandler(handler: AuthErrorHandler | null): void {
  authErrorHandler = handler;
}

/** Обновляет access-токен; параллельные вызовы делят один запрос. */
export function refreshSession(): Promise<RefreshResult> {
  refreshing ??= doRefresh().finally(() => {
    refreshing = null;
  });
  return refreshing;
}

async function doRefresh(): Promise<RefreshResult> {
  const refresh = getRefresh();
  if (!refresh) return 'refused';
  try {
    // Контракт бэкенда: refresh-токен в query. nginx не логирует /api/authorize/.
    // Любой отказ (401 REFRESH_TOKEN_EXPIRED, 403 — админ-права отозваны) → сессия сброшена.
    const res = await fetch(`/api/authorize/refresh?${new URLSearchParams({ 'refresh-token': refresh })}`);
    if (!res.ok) {
      clearTokens();
      return 'refused';
    }
    const body = (await res.json()) as { 'access-token': string; 'refresh-token': string };
    setTokens(body['access-token'], body['refresh-token']);
    return 'ok';
  } catch {
    // Сеть моргнула (или ответ не прочитался) — не разлогиниваем, refresh-токен остаётся.
    return 'network';
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

async function errorFrom(res: Response): Promise<ApiError> {
  const payload: unknown = await res.json().catch(() => null);
  const fields = payload !== null && typeof payload === 'object' ? (payload as Record<string, unknown>) : {};
  const code = typeof fields.code === 'string' ? fields.code : undefined;
  const message =
    typeof fields.message === 'string' && fields.message ? fields.message : res.statusText || `HTTP ${res.status}`;
  return new ApiError(res.status, code, message);
}

export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = 'GET', query, body, auth = true } = options;

  const send = (token: string | null) => {
    const headers: Record<string, string> = { Accept: 'application/json' };
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    if (auth && token) headers.Authorization = `Bearer ${token}`;
    return fetch(buildUrl(path, query), {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  };

  const usedToken = getAccess();
  let res = await send(usedToken);

  if (auth && res.status === 401) {
    const current = getAccess();
    if (current && current !== usedToken) {
      // Поздний 401: пока запрос летел, кто-то уже обновил токен — просто повторяем.
      res = await send(current);
    } else {
      const result = await refreshSession();
      if (result === 'network') throw new ApiError(0, 'NETWORK', 'Нет связи с сервером');
      if (result === 'ok') res = await send(getAccess());
    }
  }

  if (!res.ok) {
    const error = await errorFrom(res);
    if (auth && (res.status === 401 || res.status === 403)) {
      if (res.status === 401) clearTokens();
      authErrorHandler?.(res.status);
    }
    throw error;
  }

  const text = await res.text();
  if (!text) return undefined as T;
  try {
    return JSON.parse(text) as T;
  } catch {
    throw new ApiError(res.status, 'BAD_RESPONSE', 'Некорректный ответ сервера');
  }
}
