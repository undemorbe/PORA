import { describe, expect, it, vi } from 'vitest';
import { adminApi } from './endpoints';

const period = { from: '2026-10-01', to: '2026-10-15', tz: 'Europe/Moscow' };

function mockFetch() {
  const fetchMock = vi.fn(async () => new Response('{}', { status: 200 }));
  vi.stubGlobal('fetch', fetchMock);
  return fetchMock;
}

function requestOf(fetchMock: ReturnType<typeof mockFetch>) {
  const [input, init] = fetchMock.mock.calls[0] as unknown as [string, RequestInit];
  const url = new URL(input, 'http://admin.test');
  return { path: url.pathname, params: url.searchParams, init };
}

describe('adminApi', () => {
  it('eventSeries joins names with a comma', async () => {
    const fetchMock = mockFetch();
    await adminApi.eventSeries(period, ['item_added', 'item_bought']);

    const { path, params } = requestOf(fetchMock);
    expect(path).toBe('/api/admin/events/timeseries');
    expect(params.get('names')).toBe('item_added,item_bought');
    expect(params.get('from')).toBe('2026-10-01');
    expect(params.get('to')).toBe('2026-10-15');
    expect(params.get('tz')).toBe('Europe/Moscow');
  });

  it('topProducts sends kind and limit=20', async () => {
    const fetchMock = mockFetch();
    await adminApi.topProducts(period, 'bought');

    const { path, params } = requestOf(fetchMock);
    expect(path).toBe('/api/admin/products/top');
    expect(params.get('kind')).toBe('bought');
    expect(params.get('limit')).toBe('20');
  });

  it('retention sends weeks', async () => {
    const fetchMock = mockFetch();
    await adminApi.retention(period, 8);

    const { path, params } = requestOf(fetchMock);
    expect(path).toBe('/api/admin/retention');
    expect(params.get('weeks')).toBe('8');
  });

  it('users drops an empty search query', async () => {
    const fetchMock = mockFetch();
    await adminApi.users('', 2);

    const { path, params } = requestOf(fetchMock);
    expect(path).toBe('/api/admin/users');
    expect(params.has('q')).toBe(false);
    expect(params.get('page')).toBe('2');
  });

  it('verifyOtp posts the admin client marker without auth', async () => {
    const fetchMock = mockFetch();
    await adminApi.verifyOtp('admin@example.com', '123456');

    const { path, init } = requestOf(fetchMock);
    expect(path).toBe('/api/authorize/verify-otp');
    expect(init.method).toBe('POST');
    expect(JSON.parse(init.body as string)).toEqual({ email: 'admin@example.com', otp: '123456', client: 'admin' });
    expect((init.headers as Record<string, string>).Authorization).toBeUndefined();
  });
});
