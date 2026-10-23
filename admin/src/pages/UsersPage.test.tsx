import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
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

describe('UsersPage', () => {
  it('searches with the trimmed query after the debounce', async () => {
    const fetchMock = stubUsers();
    renderWithProviders(<UsersPage />, '/users');

    expect(await screen.findByText('User u1')).toBeInTheDocument();
    expect(usersCalls(fetchMock)[0].has('q')).toBe(false);

    await userEvent.type(screen.getByLabelText('Поиск по почте, телефону, имени'), '  anna ');
    // Пока debounce не истёк, промежуточные «a», «an»… не уходят на сервер.
    expect(usersCalls(fetchMock).some((p) => p.has('q'))).toBe(false);

    await waitFor(() => expect(usersCalls(fetchMock).some((p) => p.get('q') === 'anna')).toBe(true));
    expect(usersCalls(fetchMock).filter((p) => p.has('q')).map((p) => p.get('q'))).toEqual(['anna']);
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
});
