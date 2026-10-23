import { screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { json, renderWithProviders } from '../test/render';
import { RetentionPage } from './RetentionPage';

describe('RetentionPage', () => {
  it('marks missing cohort weeks and dashes D-N without eligible users', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue(
        json(200, {
          'day-n': [
            { day: 1, eligible: 10, retained: 4 },
            { day: 30, eligible: 0, retained: 0 },
          ],
          cohorts: [
            { week: '2026-10-05', size: 10, retained: [100, 40, null] },
            { week: '2026-10-12', size: 5, retained: [100, null] },
          ],
        }),
      ),
    );
    renderWithProviders(<RetentionPage />);

    expect(await screen.findByText('40,0%')).toBeInTheDocument();
    expect(screen.getByText('—')).toBeInTheDocument();
    expect(screen.getByText('0 из 0')).toBeInTheDocument();

    const table = screen.getByRole('table');
    // Колонки — по самой длинной когорте: «Нед. 0…2».
    expect(within(table).getAllByRole('columnheader').map((th) => th.textContent)).toEqual([
      'Неделя регистрации',
      'Юзеров',
      'Нед. 0',
      'Нед. 1',
      'Нед. 2',
    ]);
    const empty = within(table).getAllByLabelText('нет данных');
    // null у первой когорты + null и недостающая неделя у второй.
    expect(empty).toHaveLength(3);
    for (const cell of empty) expect(cell).toHaveTextContent('·');
  });
});
