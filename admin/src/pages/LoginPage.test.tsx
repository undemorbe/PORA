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

  it('shows the server error when the code is accepted but /me fails', async () => {
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(200, {}))
        .mockResolvedValueOnce(json(200, { 'access-token': 'a', 'refresh-token': 'r' }))
        .mockResolvedValueOnce(json(500, { code: 'INTERNAL_ERROR' })),
    );
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'boss@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    await userEvent.type(await screen.findByLabelText('Код из письма'), '123456');
    await userEvent.click(screen.getByRole('button', { name: 'Войти' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('Сервер недоступен');
    expect(screen.getByRole('button', { name: 'Войти' })).toBeInTheDocument();
  });

  it('resets the code and error when switching to another email', async () => {
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(200, {}))
        .mockResolvedValueOnce(json(400, { code: 'OTP_INCORRECT', message: 'bad' }))
        .mockResolvedValueOnce(json(200, {})),
    );
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'boss@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    await userEvent.type(await screen.findByLabelText('Код из письма'), '111111');
    await userEvent.click(screen.getByRole('button', { name: 'Войти' }));
    expect(await screen.findByText('Неверный код')).toBeInTheDocument();

    await userEvent.click(screen.getByRole('button', { name: 'Другая почта' }));
    expect(screen.queryByText('Неверный код')).not.toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    expect(await screen.findByLabelText('Код из письма')).toHaveValue('');
  });

  it('marks the submit button busy while a request is in flight', async () => {
    let release!: (res: Response) => void;
    vi.stubGlobal(
      'fetch',
      vi.fn().mockReturnValueOnce(
        new Promise<Response>((resolve) => {
          release = resolve;
        }),
      ),
    );
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'boss@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    expect(screen.getByRole('button', { name: 'Получить код' })).toHaveAttribute('aria-busy', 'true');

    release(json(200, {}));
    expect(await screen.findByLabelText('Код из письма')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Войти' })).toHaveAttribute('aria-busy', 'false');
  });
});
