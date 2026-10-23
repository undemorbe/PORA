import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { clearTokens, getRefresh, setTokens } from '../api/tokens';
import { AuthProvider, useAuth } from './AuthContext';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

function Probe() {
  const { status, me, retry } = useAuth();
  return (
    <div>
      <output aria-label="status">{status}</output>
      <span>{me?.name}</span>
      <button type="button" onClick={retry}>
        retry
      </button>
    </div>
  );
}

function renderProvider() {
  return render(
    <AuthProvider>
      <Probe />
    </AuthProvider>,
  );
}

const status = () => screen.getByLabelText('status');

afterEach(() => {
  clearTokens();
});

describe('AuthProvider', () => {
  it('is signedOut without a stored refresh token', async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);
    renderProvider();

    await waitFor(() => expect(status()).toHaveTextContent('signedOut'));
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('goes offline on a network error, keeps the session, and recovers on retry', async () => {
    setTokens('a', 'r');
    const fetchMock = vi
      .fn()
      .mockRejectedValueOnce(new TypeError('Failed to fetch'))
      .mockResolvedValueOnce(json(200, { id: '1', name: 'Борис', surname: '' }));
    vi.stubGlobal('fetch', fetchMock);
    renderProvider();

    await waitFor(() => expect(status()).toHaveTextContent('offline'));
    expect(getRefresh()).toBe('r');

    await userEvent.click(screen.getByRole('button', { name: 'retry' }));

    await waitFor(() => expect(status()).toHaveTextContent('signedIn'));
    expect(screen.getByText('Борис')).toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('signs out when the session is refused (401)', async () => {
    setTokens('a', 'r');
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
        .mockResolvedValueOnce(json(401, { code: 'REFRESH_TOKEN_EXPIRED' })),
    );
    renderProvider();

    await waitFor(() => expect(status()).toHaveTextContent('signedOut'));
    expect(getRefresh()).toBeNull();
  });

  it('shows forbidden when admin rights are missing (403)', async () => {
    setTokens('a', 'r');
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(json(403, { code: 'FORBIDDEN', message: 'нет прав' })));
    renderProvider();

    await waitFor(() => expect(status()).toHaveTextContent('forbidden'));
  });
});
