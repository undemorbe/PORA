import { afterEach, describe, expect, it, vi } from 'vitest';
import { ApiError, apiFetch, setAuthErrorHandler } from './client';
import { clearTokens, getAccess, getRefresh, setTokens } from './tokens';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

const headerOf = (call: unknown[], name: string) =>
  ((call[1] as RequestInit).headers as Record<string, string>)[name];

afterEach(() => {
  clearTokens();
  setAuthErrorHandler(null);
});

describe('apiFetch', () => {
  it('adds bearer token and query params', async () => {
    setTokens('access-1', 'refresh-1');
    const fetchMock = vi.fn().mockResolvedValue(json(200, { dau: 3 }));
    vi.stubGlobal('fetch', fetchMock);

    const result = await apiFetch<{ dau: number }>('/api/admin/overview', {
      query: { from: '2026-10-01', to: '2026-10-15', tz: 'UTC', empty: '' },
    });

    expect(result.dau).toBe(3);
    expect(fetchMock.mock.calls[0][0]).toBe('/api/admin/overview?from=2026-10-01&to=2026-10-15&tz=UTC');
    expect(headerOf(fetchMock.mock.calls[0], 'Authorization')).toBe('Bearer access-1');
  });

  it('refreshes once on 401 and retries with the new token', async () => {
    setTokens('old', 'r1');
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
      .mockResolvedValueOnce(json(200, { 'access-token': 'new', 'refresh-token': 'r2' }))
      .mockResolvedValueOnce(json(200, { ok: true }));
    vi.stubGlobal('fetch', fetchMock);

    await apiFetch('/api/admin/me');

    // Токен уходит в теле POST, не в URL (query попадает в логи)
    const [refreshUrl, refreshInit] = fetchMock.mock.calls[1];
    expect(String(refreshUrl)).toBe('/api/authorize/refresh');
    expect(refreshInit?.method).toBe('POST');
    expect(JSON.parse(String(refreshInit?.body))).toEqual({ 'refresh-token': 'r1' });
    expect(headerOf(fetchMock.mock.calls[2], 'Authorization')).toBe('Bearer new');
    expect(getRefresh()).toBe('r2');
  });

  it('clears session and notifies on failed refresh', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'UNAUTHORIZED' }))
        .mockResolvedValueOnce(json(404, { code: 'NOT_FOUND' })),
    );

    await expect(apiFetch('/api/admin/me')).rejects.toMatchObject({ status: 401 });
    expect(getRefresh()).toBeNull();
    expect(onAuthError).toHaveBeenCalledWith(401);
  });

  it('clears session when refresh is refused because admin rights were revoked', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockResolvedValueOnce(json(403, { code: 'FORBIDDEN' })),
    );

    await expect(apiFetch('/api/admin/me')).rejects.toMatchObject({ status: 401 });
    expect(getRefresh()).toBeNull();
    expect(onAuthError).toHaveBeenCalledWith(401);
  });

  it('notifies on 403 and exposes server error code', async () => {
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(json(403, { code: 'FORBIDDEN', message: 'Нет прав' })));

    const error = await apiFetch('/api/admin/overview').catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ status: 403, code: 'FORBIDDEN', message: 'Нет прав' });
    expect(onAuthError).toHaveBeenCalledWith(403);
  });

  it('does not attach auth or refresh for public calls', async () => {
    setTokens('access-1', 'refresh-1');
    const fetchMock = vi.fn().mockResolvedValue(json(400, { code: 'OTP_INCORRECT' }));
    vi.stubGlobal('fetch', fetchMock);

    await expect(
      apiFetch('/api/authorize/verify-otp', { method: 'POST', body: { otp: '1' }, auth: false }),
    ).rejects.toMatchObject({ status: 400, code: 'OTP_INCORRECT' });
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(headerOf(fetchMock.mock.calls[0], 'Authorization')).toBeUndefined();
  });

  it('shares one refresh between parallel 401s and retries both with the new token', async () => {
    setTokens('old', 'r1');
    let releaseRefresh!: () => void;
    const refreshGate = new Promise<void>((resolve) => {
      releaseRefresh = resolve;
    });
    const fetchMock = vi.fn(async (url: string, init?: RequestInit) => {
      if (url.startsWith('/api/authorize/refresh')) {
        await refreshGate;
        return json(200, { 'access-token': 'new', 'refresh-token': 'r2' });
      }
      const auth = (init?.headers as Record<string, string>).Authorization;
      return auth === 'Bearer new' ? json(200, { url }) : json(401, { code: 'ACCESS_TOKEN_EXPIRED' });
    });
    vi.stubGlobal('fetch', fetchMock);

    const both = Promise.all([apiFetch<{ url: string }>('/api/admin/a'), apiFetch<{ url: string }>('/api/admin/b')]);
    await vi.waitFor(() => expect(fetchMock.mock.calls.filter(([u]) => u.startsWith('/api/authorize/refresh'))).toHaveLength(1));
    await new Promise((resolve) => setTimeout(resolve, 0)); // оба 401 уже получены, refresh ещё висит
    releaseRefresh();

    expect(await both).toEqual([{ url: '/api/admin/a' }, { url: '/api/admin/b' }]);
    const refreshCalls = fetchMock.mock.calls.filter(([u]) => u.startsWith('/api/authorize/refresh'));
    expect(refreshCalls).toHaveLength(1);
    const retries = fetchMock.mock.calls.filter((call) => call[1] && headerOf(call, 'Authorization') === 'Bearer new');
    expect(retries.map(([u]) => u).sort()).toEqual(['/api/admin/a', '/api/admin/b']);
  });

  it('keeps the session and reports NETWORK when the refresh request itself fails', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockRejectedValueOnce(new TypeError('Failed to fetch')),
    );

    const error = await apiFetch('/api/admin/me').catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ status: 0, code: 'NETWORK', message: 'Нет связи с сервером' });
    expect(getRefresh()).toBe('r1');
    expect(getAccess()).toBe('old');
    expect(onAuthError).not.toHaveBeenCalled();
  });

  it('wraps a failed request into a NETWORK error without touching the session', async () => {
    setTokens('access-1', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('Failed to fetch')));

    const error = await apiFetch('/api/admin/me').catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ status: 0, code: 'NETWORK', message: 'Нет связи с сервером' });
    expect(getRefresh()).toBe('r1');
    expect(getAccess()).toBe('access-1');
    expect(onAuthError).not.toHaveBeenCalled();
  });

  it('wraps a failed retry after refresh into a NETWORK error', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockResolvedValueOnce(json(200, { 'access-token': 'new', 'refresh-token': 'r2' }))
        .mockRejectedValueOnce(new TypeError('Failed to fetch')),
    );

    const error = await apiFetch('/api/admin/me').catch((e: unknown) => e);

    expect(error).toMatchObject({ status: 0, code: 'NETWORK' });
    expect(getRefresh()).toBe('r2');
    expect(onAuthError).not.toHaveBeenCalled();
  });

  it('keeps the session and reports SERVER when refresh hits a 5xx', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockResolvedValueOnce(new Response('<html>Bad Gateway</html>', { status: 502 })),
    );

    const error = await apiFetch('/api/admin/me').catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ status: 502, code: 'SERVER', message: 'Сервер недоступен' });
    expect(getRefresh()).toBe('r1');
    expect(getAccess()).toBe('old');
    expect(onAuthError).not.toHaveBeenCalled();
  });

  it('keeps the session and reports SERVER when a 200 refresh body is unreadable', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockResolvedValueOnce(new Response('<!doctype html>', { status: 200 })),
    );

    const error = await apiFetch('/api/admin/me').catch((e: unknown) => e);

    expect(error).toMatchObject({ code: 'SERVER', message: 'Сервер недоступен' });
    expect((error as ApiError).status).toBeGreaterThanOrEqual(500);
    expect(getRefresh()).toBe('r1');
    expect(onAuthError).not.toHaveBeenCalled();
  });

  it('treats any 4xx from refresh as refused', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockResolvedValueOnce(json(400, { code: 'BAD_REQUEST' })),
    );

    await expect(apiFetch('/api/admin/me')).rejects.toMatchObject({ status: 401 });
    expect(getRefresh()).toBeNull();
    expect(onAuthError).toHaveBeenCalledWith(401);
  });

  it('retries a late 401 with the already refreshed token without refreshing again', async () => {
    setTokens('old', 'r1');
    const fetchMock = vi
      .fn()
      .mockImplementationOnce(async () => {
        // Пока запрос летел, другой вызов уже обновил токены.
        setTokens('new', 'r2');
        return json(401, { code: 'ACCESS_TOKEN_EXPIRED' });
      })
      .mockResolvedValueOnce(json(200, { ok: true }));
    vi.stubGlobal('fetch', fetchMock);

    await expect(apiFetch('/api/admin/me')).resolves.toEqual({ ok: true });

    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(headerOf(fetchMock.mock.calls[0], 'Authorization')).toBe('Bearer old');
    expect(headerOf(fetchMock.mock.calls[1], 'Authorization')).toBe('Bearer new');
    expect(getRefresh()).toBe('r2');
  });

  it('falls back to status text when the error body is not an object', async () => {
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(new Response('null', { status: 500 }))
        .mockResolvedValueOnce(new Response('<html>oops</html>', { status: 502, statusText: 'Bad Gateway' })),
    );

    await expect(apiFetch('/api/admin/overview')).rejects.toMatchObject({
      status: 500,
      code: undefined,
      message: 'HTTP 500',
    });
    await expect(apiFetch('/api/admin/overview')).rejects.toMatchObject({
      status: 502,
      code: undefined,
      message: 'Bad Gateway',
    });
  });

  it('rejects a 2xx response whose body is not JSON', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        new Response('<!doctype html><html></html>', { status: 200, headers: { 'Content-Type': 'text/html' } }),
      ),
    );

    const error = await apiFetch('/api/admin/overview').catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ status: 200, code: 'BAD_RESPONSE', message: 'Некорректный ответ сервера' });
  });
});
