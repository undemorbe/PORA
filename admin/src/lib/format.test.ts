import { describe, expect, it } from 'vitest';
import { daysInRange, formatDay, formatDelta, formatPercent, periodRange, ratio } from './format';

describe('formatDelta', () => {
  it('shows signed percent change', () => {
    expect(formatDelta(12, 10)).toEqual({ text: '+20%', trend: 'up' });
    expect(formatDelta(5, 10)).toEqual({ text: '−50%', trend: 'down' });
    expect(formatDelta(10, 10)).toEqual({ text: '0%', trend: 'flat' });
  });

  it('handles empty previous period', () => {
    expect(formatDelta(0, 0)).toBeNull();
    expect(formatDelta(3, 0)).toEqual({ text: 'новое', trend: 'up' });
  });
});

describe('percent helpers', () => {
  it('formats with comma decimal', () => {
    expect(formatPercent(45)).toBe('45,0%');
    expect(formatPercent(ratio(1, 3))).toBe('33,3%');
    expect(ratio(5, 0)).toBe(0);
  });
});

describe('periodRange', () => {
  it('counts days inclusively in the given timezone', () => {
    // 21:30 UTC 15-го = 00:30 16-го по Москве
    const now = new Date(Date.UTC(2026, 9, 15, 21, 30));
    expect(periodRange(7, now, 'UTC')).toEqual({ from: '2026-10-09', to: '2026-10-15' });
    expect(periodRange(7, now, 'Europe/Moscow')).toEqual({ from: '2026-10-10', to: '2026-10-16' });
  });

  it('crosses month boundaries', () => {
    const now = new Date(Date.UTC(2026, 2, 2, 12));
    expect(periodRange(30, now, 'UTC').from).toBe('2026-02-01');
  });
});

describe('dates', () => {
  it('lists every day of a range', () => {
    expect(daysInRange('2026-02-27', '2026-03-02')).toEqual([
      '2026-02-27',
      '2026-02-28',
      '2026-03-01',
      '2026-03-02',
    ]);
  });

  it('formats day as dd.mm', () => {
    expect(formatDay('2026-03-02')).toBe('02.03');
  });
});
