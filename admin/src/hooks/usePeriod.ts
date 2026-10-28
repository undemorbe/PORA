import { useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import type { Period } from '../api/endpoints';
import { periodRange } from '../lib/format';

export const PERIODS = [7, 30, 90] as const;
const DEFAULT_DAYS = 30;

function browserTimeZone(): string {
  return Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
}

/** Период из `?days=` (7/30/90), таймзона — браузерная. */
export function usePeriod() {
  const [params, setParams] = useSearchParams();
  const raw = Number(params.get('days'));
  const days = (PERIODS as readonly number[]).includes(raw) ? raw : DEFAULT_DAYS;
  const tz = browserTimeZone();
  const { from, to } = periodRange(days, new Date(), tz);

  const period = useMemo<Period>(() => ({ from, to, tz }), [from, to, tz]);

  const setDays = (next: number) =>
    setParams(
      (prev) => {
        const updated = new URLSearchParams(prev);
        updated.set('days', String(next));
        return updated;
      },
      { replace: true },
    );

  return { days, setDays, period };
}
