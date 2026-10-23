import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { UseQueryResult } from '@tanstack/react-query';
import { describe, expect, it, vi } from 'vitest';
import { ApiError } from '../api/client';
import { ChartCard } from './ChartCard';

const query = (partial: Partial<UseQueryResult<number[]>>) =>
  ({ isPending: false, isError: false, data: undefined, error: null, refetch: vi.fn(), ...partial }) as UseQueryResult<number[]>;

describe('ChartCard', () => {
  it('shows loading', () => {
    render(<ChartCard title="T" query={query({ isPending: true })}>{() => 'data'}</ChartCard>);
    expect(screen.getByText('Загрузка…')).toBeInTheDocument();
  });

  it('shows error with retry', async () => {
    const refetch = vi.fn();
    render(
      <ChartCard title="T" query={query({ isError: true, error: new ApiError(500, 'INTERNAL_ERROR', 'x'), refetch })}>
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByRole('alert')).toHaveTextContent('Сервер недоступен');
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));
    expect(refetch).toHaveBeenCalled();
  });

  it('shows a connection message for network errors', () => {
    render(
      <ChartCard title="T" query={query({ isError: true, error: new ApiError(0, 'NETWORK', 'Нет связи с сервером') })}>
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByRole('alert')).toHaveTextContent('Нет связи с сервером');
  });

  it('shows empty state and data', () => {
    const { rerender } = render(
      <ChartCard title="T" query={query({ data: [] })} isEmpty={(d) => d.length === 0}>
        {(d) => `items: ${d.length}`}
      </ChartCard>,
    );
    expect(screen.getByText('Нет данных за период')).toBeInTheDocument();

    rerender(
      <ChartCard title="T" query={query({ data: [1, 2] })} isEmpty={(d) => d.length === 0}>
        {(d) => `items: ${d.length}`}
      </ChartCard>,
    );
    expect(screen.getByText('items: 2')).toBeInTheDocument();
  });
});
