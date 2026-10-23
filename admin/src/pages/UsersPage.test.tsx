import { act, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';
import type { AdminUserRow } from '../api/types';
import { json, renderWithProviders } from '../test/render';
import { UsersPage } from './UsersPage';

const row = (id: string): AdminUserRow => ({
  id,
  email: `${id}@example.com`,
  phone: '',
  name: `User ${id}`,
  surname: '',
  status: 'active',
  'is-admin': false,
  'created-at': '2026-10-01T10:00:00Z',
  'last-active-at': null,
  lists: 1,
  items: 2,
  families: 0,
});

/** 45 юзеров по 20 на странице → 3 страницы. */
function stubUsers() {
  const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
    const params = new URL(String(input), 'http://x').searchParams;
    const page = Number(params.get('page') ?? 1);
    return json(200, { users: [row(`u${page}`)], total: 45, page, 'page-size': 20 });
  });
  vi.stubGlobal('fetch', fetchMock);
  return fetchMock;
}

const usersCalls = (fetchMock: ReturnType<typeof stubUsers>) =>
  fetchMock.mock.calls.map(([u]) => new URL(String(u), 'http://x').searchParams);

afterEach(() => {
  vi.useRealTimers();
});

describe('UsersPage', () => {
  it('searches with the trimmed query after the debounce', async () => {
    vi.useFakeTimers({ shouldAdvanceTime: true });
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
    const fetchMock = stubUsers();
    renderWithProviders(<UsersPage />, '/users');

    expect(await screen.findByText('User u1')).toBeInTheDocument();
    expect(usersCalls(fetchMock)).toHaveLength(1);
    expect(usersCalls(fetchMock)[0].has('q')).toBe(false);

    await user.type(screen.getByLabelText('Поиск по почте, телефону, имени'), '  anna ');
    await act(async () => {
      await vi.advanceTimersByTimeAsync(300);
    });

    // Ровно один запрос с поиском — промежуточные «a», «an»… не уходят; пробелы обрезаны.
    await waitFor(() => expect(usersCalls(fetchMock).filter((p) => p.has('q'))).toHaveLength(1));
    const [searchCall] = usersCalls(fetchMock).filter((p) => p.has('q'));
    expect(searchCall.get('q')).toBe('anna');
    expect(searchCall.get('page')).toBe('1');
  });

  it('disables pagination buttons at the bounds', async () => {
    stubUsers();
    renderWithProviders(<UsersPage />, '/users');

    expect(await screen.findByText('45 всего · стр. 1 из 3')).toBeInTheDocument();
    const back = screen.getByRole('button', { name: 'Назад' });
    const next = screen.getByRole('button', { name: 'Вперёд' });
    expect(back).toBeDisabled();
    expect(next).toBeEnabled();

    await userEvent.click(next);
    expect(await screen.findByText('45 всего · стр. 2 из 3')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Назад' })).toBeEnabled();

    await userEvent.click(screen.getByRole('button', { name: 'Вперёд' }));
    expect(await screen.findByText('45 всего · стр. 3 из 3')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Вперёд' })).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Назад' })).toBeEnabled();
  });

  it('falls back to the last page when the list shrinks under the current one', async () => {
    const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
      const page = Number(new URL(String(input), 'http://x').searchParams.get('page') ?? 1);
      // К моменту запроса стр. 2 пользователей стало 20 → одна страница, стр. 2 пуста.
      return page === 1
        ? json(200, { users: [row('u1')], total: 45, page: 1, 'page-size': 20 })
        : json(200, { users: [], total: 20, page, 'page-size': 20 });
    });
    vi.stubGlobal('fetch', fetchMock);
    renderWithProviders(<UsersPage />, '/users');

    await userEvent.click(await screen.findByRole('button', { name: 'Вперёд' }));

    await waitFor(() => expect(usersCalls(fetchMock).some((p) => p.get('page') === '2')).toBe(true));
    // Пустая стр. 2 пришла → вернулись на стр. 1 (на стр. 2 «Назад» был бы активен).
    await waitFor(() => expect(screen.getByRole('button', { name: 'Назад' })).toBeDisabled());
    expect(screen.getByText('45 всего · стр. 1 из 3')).toBeInTheDocument();
    expect(screen.getByText('User u1')).toBeInTheDocument();
  });
});

