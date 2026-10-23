import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { clearTokens, setTokens } from './api/tokens';
import { App } from './App';

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

    expect(await screen.findByText('Нет связи с сервером')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));

    expect(await screen.findByRole('heading', { name: 'Обзор' })).toBeInTheDocument();
    expect(screen.getByText('boss@mail.ru')).toBeInTheDocument();
  });
});
