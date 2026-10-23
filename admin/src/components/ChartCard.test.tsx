import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { UseQueryResult } from '@tanstack/react-query';
import { describe, expect, it, vi } from 'vitest';
import { ApiError } from '../api/client';
import { ChartCard } from './ChartCard';

const query = (partial: Partial<UseQueryResult<number[]>>) =>
  ({
    isPending: false,
    isLoading: false,
    isFetching: false,
    isError: false,
    data: undefined,
    error: null,
    refetch: vi.fn(),
    ...partial,
  }) as UseQueryResult<number[]>;

describe('ChartCard', () => {
  it('shows loading', () => {
    render(<ChartCard title="T" query={query({ isPending: true, isLoading: true, isFetching: true })}>{() => 'data'}</ChartCard>);
    expect(screen.getByText('Загрузка…')).toBeInTheDocument();
  });

  it('does not show loading for a disabled query', () => {
    render(<ChartCard title="T" query={query({ isPending: true })}>{() => 'data'}</ChartCard>);
    expect(screen.queryByText('Загрузка…')).not.toBeInTheDocument();
    expect(screen.getByText('Нет данных за период')).toBeInTheDocument();
  });

  it('disables retry while refetching', () => {
    render(
      <ChartCard
        title="T"
        query={query({ isError: true, isFetching: true, error: new ApiError(500, 'INTERNAL_ERROR', 'x') })}
      >
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByRole('button', { name: 'Повторить' })).toBeDisabled();
  });

  it('shows error with retry', async () => {
    const refetch = vi.fn();
    render(
      <ChartCard title="T" query={query({ isError: true, error: new ApiError(500, 'INTERNAL_ERROR', 'x'), refetch })}>
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByRole('status')).toHaveTextContent('Сервер недоступен');
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));
    expect(refetch).toHaveBeenCalled();
  });

  it('shows a connection message for network errors', () => {
    render(
      <ChartCard title="T" query={query({ isError: true, error: new ApiError(0, 'NETWORK', 'Нет связи с сервером') })}>
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByRole('status')).toHaveTextContent('Нет связи с сервером');
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

  it('uses a custom empty text', () => {
    render(
      <ChartCard title="T" query={query({ isPending: true })} emptyText="Выберите события">
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByText('Выберите события')).toBeInTheDocument();
    expect(screen.queryByText('Нет данных за период')).not.toBeInTheDocument();
  });
});
