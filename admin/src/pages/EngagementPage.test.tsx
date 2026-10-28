import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { json, renderWithProviders } from '../test/render';
import { EngagementPage } from './EngagementPage';

describe('EngagementPage', () => {
  it('asks to pick events when every chip is deselected and does not query with empty names', async () => {
    const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      if (url.startsWith('/api/admin/funnel')) return json(200, { steps: [{ step: 'signed_up', users: 0 }] });
      if (url.startsWith('/api/admin/features')) return json(200, { mau: 0, features: null });
      return json(200, { points: [{ date: '2026-10-15', name: 'session_start', count: 4 }] });
    });
    vi.stubGlobal('fetch', fetchMock);
    renderWithProviders(<EngagementPage />);

    const chips = within(screen.getByRole('group', { name: 'События' }));
    for (const chip of chips.getAllByRole('button', { pressed: true })) await userEvent.click(chip);

    expect(chips.queryAllByRole('button', { pressed: true })).toHaveLength(0);
    expect(await screen.findByText('Выберите события')).toBeInTheDocument();

    const seriesUrls = fetchMock.mock.calls.map(([u]) => String(u)).filter((u) => u.includes('/events/timeseries'));
    expect(seriesUrls.length).toBeGreaterThan(0);
    for (const url of seriesUrls) expect(new URL(url, 'http://x').searchParams.get('names')).not.toBe('');
    expect(seriesUrls.every((u) => u.includes('names='))).toBe(true);
  });

  it('requests events in canonical order regardless of click order', async () => {
    const fetchMock = vi.fn(async (_input: RequestInfo | URL) => json(200, { points: [], steps: [], mau: 0, features: null }));
    vi.stubGlobal('fetch', fetchMock);
    renderWithProviders(<EngagementPage />);

    const chips = within(screen.getByRole('group', { name: 'События' }));
    // Снимаем «Товар добавлен» (первый в EVENT_LABELS) и включаем обратно — он должен остаться первым, а не уйти в конец.
    await userEvent.click(chips.getByRole('button', { name: 'Товар добавлен' }));
    await userEvent.click(chips.getByRole('button', { name: 'Товар добавлен' }));

    const last = fetchMock.mock.calls
      .map(([u]) => String(u))
      .filter((u) => u.includes('/events/timeseries'))
      .at(-1);
    expect(new URL(String(last), 'http://x').searchParams.get('names')).toBe(
      'item_added,item_bought,session_start,ai_message_sent,recipe_import',
    );
  });
});
