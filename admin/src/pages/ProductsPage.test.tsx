import { screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { json, renderWithProviders } from '../test/render';
import { ProductsPage } from './ProductsPage';

function stubFetch(median: number | null) {
  vi.stubGlobal(
    'fetch',
    vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      if (url.startsWith('/api/admin/products/top')) {
        const kind = new URL(url, 'http://x').searchParams.get('kind');
        return json(200, { kind, items: [{ name: 'молоко', count: 3 }], 'median-hours-to-buy': median });
      }
      return json(200, { sections: null });
    }),
  );
}

describe('ProductsPage', () => {
  it('shows a dash and a hint while the median is unknown', async () => {
    stubFetch(null);
    renderPage();

    expect(await screen.findByText('появится после новых покупок')).toBeInTheDocument();
    expect(screen.getByText('—')).toBeInTheDocument();
  });

  it('formats a known median in hours', async () => {
    stubFetch(5.25);
    renderPage();

    expect(await screen.findByText('5,3 ч')).toBeInTheDocument();
    expect(screen.getByText('по купленным за период')).toBeInTheDocument();
  });
});

function renderPage() {
  return renderWithProviders(<ProductsPage />);
}
