const numberFormat = new Intl.NumberFormat('ru-RU');

export type Trend = 'up' | 'down' | 'flat';

export interface Delta {
  text: string;
  trend: Trend;
}

export function formatNumber(value: number): string {
  return numberFormat.format(value);
}

/** Изменение к прошлому периоду; null — сравнивать не с чем. */
export function formatDelta(current: number, previous: number): Delta | null {
  if (previous === 0) return current === 0 ? null : { text: 'новое', trend: 'up' };
  const pct = Math.round(((current - previous) / previous) * 100);
  if (pct === 0) return { text: '0%', trend: 'flat' };
  return { text: `${pct > 0 ? '+' : '−'}${Math.abs(pct)}%`, trend: pct > 0 ? 'up' : 'down' };
}

export function ratio(part: number, whole: number): number {
  return whole === 0 ? 0 : (part / whole) * 100;
}

export function formatPercent(value: number, digits = 1): string {
  return `${value.toFixed(digits).replace('.', ',')}%`;
}

/** 'YYYY-MM-DD' → 'dd.mm' для подписей осей. */
export function formatDay(date: string): string {
  const [, month, day] = date.split('-');
  return `${day}.${month}`;
}

export function formatDateTime(iso: string, timeZone: string): string {
  return new Intl.DateTimeFormat('ru-RU', {
    dateStyle: 'short',
    timeStyle: 'short',
    timeZone,
  }).format(new Date(iso));
}

/** Сегодня в таймзоне tz как 'YYYY-MM-DD' (собираем из частей, не завися от формата локали). */
function todayIn(now: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(now);
  const part = (type: 'year' | 'month' | 'day') => parts.find((p) => p.type === type)?.value ?? '';
  return `${part('year')}-${part('month')}-${part('day')}`;
}

function shiftDay(date: string, days: number): string {
  const [year, month, day] = date.split('-').map(Number);
  return new Date(Date.UTC(year, month - 1, day + days)).toISOString().slice(0, 10);
}

/** Последние `days` дней по сегодня включительно, в таймзоне `timeZone`. */
export function periodRange(days: number, now: Date, timeZone: string): { from: string; to: string } {
  const to = todayIn(now, timeZone);
  return { from: shiftDay(to, -(days - 1)), to };
}

/** Все даты от from до to включительно. */
export function daysInRange(from: string, to: string): string[] {
  const days: string[] = [];
  for (let day = from; day <= to; day = shiftDay(day, 1)) days.push(day);
  return days;
}
