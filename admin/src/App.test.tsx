import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { ApiError } from './api/client';
import { clearTokens, setTokens } from './api/tokens';
import { App, shouldRetryQuery } from './App';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

afterEach(() => {
  clearTokens();
});

describe('App', () => {
  it('shows the offline screen and retries into the app shell', async () => {
    setTokens('a', 'r');
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockRejectedValueOnce(new TypeError('Failed to fetch'))
        .mockResolvedValueOnce(json(200, { id: '1', name: 'Борис', surname: '', email: 'boss@mail.ru' })),
    );
    render(<App />);

    expect(await screen.findByRole('alert')).toHaveTextContent('Нет связи с сервером');
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));

    expect(await screen.findByRole('heading', { name: 'Обзор' })).toBeInTheDocument();
    expect(screen.getByText('boss@mail.ru')).toBeInTheDocument();
  });

  it('names a server outage on the offline screen', async () => {
    setTokens('a', 'r');
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(json(503, { code: 'UNAVAILABLE' })));
    render(<App />);

    expect(await screen.findByRole('alert')).toHaveTextContent('Сервер недоступен');
    expect(screen.getByRole('button', { name: 'Повторить' })).toBeInTheDocument();
  });
});

describe('shouldRetryQuery', () => {
  it('retries server and network errors once, never client errors', () => {
    expect(shouldRetryQuery(0, new ApiError(500, undefined, 'x'))).toBe(true);
    expect(shouldRetryQuery(0, new ApiError(0, 'NETWORK', 'x'))).toBe(true);
    expect(shouldRetryQuery(1, new ApiError(500, undefined, 'x'))).toBe(false);
    expect(shouldRetryQuery(0, new ApiError(404, 'NOT_FOUND', 'x'))).toBe(false);
    expect(shouldRetryQuery(0, new ApiError(403, 'FORBIDDEN', 'x'))).toBe(false);
  });
});
