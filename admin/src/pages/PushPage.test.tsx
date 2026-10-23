import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { json, renderWithProviders } from '../test/render';
import { PushPage } from './PushPage';

function renderPage() {
  return renderWithProviders(<PushPage />, '/push');
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

  it('explains INVALID_INPUT in plain words', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(json(400, { code: 'INVALID_INPUT', message: 'bad input' })));
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'A');
    await userEvent.type(screen.getByLabelText('Текст'), 'B');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    const group = screen.getByRole('group', { name: 'Подтверждение' });
    // Безопасный вариант первым и с фокусом.
    expect(group.querySelectorAll('button')[0]).toHaveTextContent('Отмена');
    expect(screen.getByRole('button', { name: 'Отмена' })).toHaveFocus();
    await userEvent.click(screen.getByRole('button', { name: 'Да, отправить' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('Заголовок до 65 и текст до 240 символов, оба не пустые');
  });

  it('shows the server message on other 400s and keeps the text', async () => {
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

