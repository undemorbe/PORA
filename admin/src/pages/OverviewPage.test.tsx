import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it, vi } from 'vitest';
import { OverviewPage } from './OverviewPage';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

const overview = {
  'total-users': 120,
  'new-users': 12,
  'new-users-prev': 10,
  dau: 9,
  wau: 15,
  mau: 20,
  'items-added': 40,
  'items-added-prev': 50,
  'items-bought': 30,
  'items-bought-prev': 30,
};

function renderPage() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter initialEntries={['/?days=7']}>
        <OverviewPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe('OverviewPage', () => {
  it('renders KPIs with deltas and passes the period', async () => {
    const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      if (url.startsWith('/api/admin/overview')) return json(200, overview);
      if (url.startsWith('/api/admin/active-users')) {
        return json(200, { days: [{ date: '2026-10-15', count: 9 }], wau: 15, mau: 20 });
      }
      return json(200, { days: [{ date: '2026-10-15', count: 2 }] });
    });
    vi.stubGlobal('fetch', fetchMock);

    renderPage();

    expect(await screen.findByText('120')).toBeInTheDocument();
    expect(screen.getByText('+20%')).toBeInTheDocument();
    expect(screen.getByText('−20%')).toBeInTheDocument();
    expect(screen.getByText('45,0%')).toBeInTheDocument();

    const overviewUrl = String(fetchMock.mock.calls.find(([u]) => String(u).includes('overview'))?.[0]);
    expect(overviewUrl).toMatch(/from=\d{4}-\d{2}-\d{2}&to=\d{4}-\d{2}-\d{2}&tz=/);
  });

  it('retries a failed block independently', async () => {
    let overviewCalls = 0;
    vi.stubGlobal(
      'fetch',
      vi.fn(async (input: RequestInfo | URL) => {
        const url = String(input);
        if (url.startsWith('/api/admin/overview')) {
          overviewCalls += 1;
          return overviewCalls === 1 ? json(500, { code: 'INTERNAL_ERROR' }) : json(200, overview);
        }
        return json(200, { days: [], wau: 0, mau: 0 });
      }),
    );

    renderPage();

    expect(await screen.findByText('Сервер недоступен')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));
    expect(await screen.findByText('120')).toBeInTheDocument();
  });
});
