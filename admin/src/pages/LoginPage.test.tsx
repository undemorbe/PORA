import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { AuthProvider } from '../auth/AuthContext';
import { LoginPage } from './LoginPage';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

function renderLogin() {
  return render(
    <AuthProvider>
      <LoginPage />
    </AuthProvider>,
  );
}

describe('LoginPage', () => {
  it('requests code, then verifies with client=admin', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(json(200, {}))
      .mockResolvedValueOnce(json(200, { 'access-token': 'a', 'refresh-token': 'r' }))
      .mockResolvedValueOnce(json(200, { id: '1', name: 'Борис', surname: '' }));
    vi.stubGlobal('fetch', fetchMock);
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'boss@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    await userEvent.type(await screen.findByLabelText('Код из письма'), '123456');
    await userEvent.click(screen.getByRole('button', { name: 'Войти' }));

    await vi.waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(3));
    const verifyBody = JSON.parse((fetchMock.mock.calls[1][1] as RequestInit).body as string);
    expect(verifyBody).toEqual({ email: 'boss@mail.ru', otp: '123456', client: 'admin' });
  });

  it('explains missing admin rights', async () => {
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(200, {}))
        .mockResolvedValueOnce(json(403, { code: 'FORBIDDEN', message: 'нет прав' })),
    );
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'user@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    await userEvent.type(await screen.findByLabelText('Код из письма'), '123456');
    await userEvent.click(screen.getByRole('button', { name: 'Войти' }));

    expect(await screen.findByText('У этой почты нет прав администратора')).toBeInTheDocument();
  });
});
