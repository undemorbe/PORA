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
});
