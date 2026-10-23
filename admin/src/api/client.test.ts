import { afterEach, describe, expect, it, vi } from 'vitest';
import { ApiError, apiFetch, setAuthErrorHandler } from './client';
import { clearTokens, getRefresh, setTokens } from './tokens';

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

    expect(String(fetchMock.mock.calls[1][0])).toBe('/api/authorize/refresh?refresh-token=r1');
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
});
