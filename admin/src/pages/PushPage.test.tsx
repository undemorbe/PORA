import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { PushPage } from './PushPage';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

function renderPage() {
  const client = new QueryClient({ defaultOptions: { mutations: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PushPage />
    </QueryClientProvider>,
  );
}

describe('PushPage', () => {
  it('sends only after explicit confirmation', async () => {
    const fetchMock = vi.fn().mockResolvedValue(json(200, {}));
    vi.stubGlobal('fetch', fetchMock);
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'Обновление');
    await userEvent.type(screen.getByLabelText('Текст'), 'Новые рецепты');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    expect(fetchMock).not.toHaveBeenCalled();

    await userEvent.click(screen.getByRole('button', { name: 'Да, отправить' }));
    expect(await screen.findByText('Рассылка отправлена')).toBeInTheDocument();
    const body = JSON.parse((fetchMock.mock.calls[0][1] as RequestInit).body as string);
    expect(body).toEqual({ title: 'Обновление', body: 'Новые рецепты' });
  });

  it('cancel returns to the form without sending', async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'A');
    await userEvent.type(screen.getByLabelText('Текст'), 'B');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    await userEvent.click(screen.getByRole('button', { name: 'Отмена' }));

    expect(fetchMock).not.toHaveBeenCalled();
    expect(screen.getByRole('button', { name: 'Отправить всем' })).toBeInTheDocument();
  });

  it('trims the text and keeps submit disabled for whitespace-only input', async () => {
    const fetchMock = vi.fn().mockResolvedValue(json(200, {}));
    vi.stubGlobal('fetch', fetchMock);
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), '   ');
    await userEvent.type(screen.getByLabelText('Текст'), '  ');
    expect(screen.getByRole('button', { name: 'Отправить всем' })).toBeDisabled();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'Привет ');
    await userEvent.type(screen.getByLabelText('Текст'), 'мир  ');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    await userEvent.click(screen.getByRole('button', { name: 'Да, отправить' }));

    expect(await screen.findByText('Рассылка отправлена')).toBeInTheDocument();
    const sent = JSON.parse((fetchMock.mock.calls[0][1] as RequestInit).body as string);
    expect(sent).toEqual({ title: 'Привет', body: 'мир' });
  });

  it('shows the server message on 400 and keeps the text', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(json(400, { code: 'VALIDATION_ERROR', message: 'title is too long' })),
    );
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'A');
    await userEvent.type(screen.getByLabelText('Текст'), 'B');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    await userEvent.click(screen.getByRole('button', { name: 'Да, отправить' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('title is too long');
    expect(screen.getByLabelText('Заголовок')).toHaveValue('A');
    expect(screen.getByRole('button', { name: 'Отправить всем' })).toBeEnabled();
  });
});

