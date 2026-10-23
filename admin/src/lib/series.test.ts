import { describe, expect, it } from 'vitest';
import { pivotEvents } from './series';

describe('pivotEvents', () => {
  it('builds one row per day with zero-filled event columns', () => {
    const rows = pivotEvents(
      [
        { date: '2026-10-14', name: 'item_added', count: 3 },
        { date: '2026-10-15', name: 'item_bought', count: 1 },
      ],
      ['2026-10-14', '2026-10-15'],
      ['item_added', 'item_bought'],
    );

    expect(rows).toEqual([
      { date: '2026-10-14', item_added: 3, item_bought: 0 },
      { date: '2026-10-15', item_added: 0, item_bought: 1 },
    ]);
  });
});
