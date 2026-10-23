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

  it('handles DST transition days in America/New_York', () => {
    const tz = 'America/New_York';
    // 2026-03-08: переход EST → EDT в 02:00 местного.
    expect(periodRange(1, new Date('2026-03-08T04:30:00Z'), tz).to).toBe('2026-03-07'); // 23:30 EST
    expect(periodRange(1, new Date('2026-03-09T03:30:00Z'), tz).to).toBe('2026-03-08'); // 23:30 EDT
    expect(periodRange(7, new Date('2026-03-08T12:00:00Z'), tz)).toEqual({ from: '2026-03-02', to: '2026-03-08' });
    // 2026-11-01: переход EDT → EST в 02:00 местного.
    expect(periodRange(1, new Date('2026-11-01T03:30:00Z'), tz).to).toBe('2026-10-31'); // 23:30 EDT
    expect(periodRange(1, new Date('2026-11-02T04:30:00Z'), tz).to).toBe('2026-11-01'); // 23:30 EST
    expect(periodRange(7, new Date('2026-11-02T04:30:00Z'), tz)).toEqual({ from: '2026-10-26', to: '2026-11-01' });
  });

  it('handles extreme offsets (UTC+14 and UTC−11)', () => {
    const now = new Date('2026-10-15T10:30:00Z');
    expect(periodRange(7, now, 'Pacific/Kiritimati')).toEqual({ from: '2026-10-10', to: '2026-10-16' }); // 00:30 16-го
    expect(periodRange(7, now, 'Pacific/Pago_Pago')).toEqual({ from: '2026-10-08', to: '2026-10-14' }); // 23:30 14-го
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
