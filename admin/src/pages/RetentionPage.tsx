import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { KpiTile } from '../components/KpiTile';
import { usePeriod } from '../hooks/usePeriod';
import { formatDay, formatPercent, ratio } from '../lib/format';

const WEEKS = 8;

// Заливка ячейки пропорциональна retention, но не плотнее 55% акцента: текст остаётся --text
// и читается в обеих темах (≈9.7:1 светлая, ≈4.7:1 тёмная на 100%).
const HEAT_MAX_MIX = 55;

function heatStyle(value: number | null) {
  if (value === null) return undefined;
  const mix = Math.round((Math.min(Math.max(value, 0), 100) / 100) * HEAT_MAX_MIX);
  return { background: `color-mix(in srgb, var(--accent) ${mix}%, transparent)` };
}

export function RetentionPage() {
  const { period } = usePeriod();
  const retention = useQuery({
    queryKey: ['retention', period, WEEKS],
    queryFn: () => adminApi.retention(period, WEEKS),
  });

  return (
    <div className="page">
      <h1>Retention</h1>

      <ChartCard title="Возврат на день N" query={retention} isEmpty={(r) => (r['day-n'] ?? []).length === 0}>
        {(r) => (
          <div className="kpi-grid">
            {(r['day-n'] ?? []).map((d) => (
              <KpiTile
                key={d.day}
                label={`D${d.day}`}
                value={d.eligible === 0 ? '—' : formatPercent(ratio(d.retained, d.eligible))}
                hint={`${d.retained} из ${d.eligible}`}
              />
            ))}
          </div>
        )}
      </ChartCard>

      <ChartCard
        title={`Недельные когорты (последние ${WEEKS} недель)`}
        query={retention}
        isEmpty={(r) => (r.cohorts ?? []).length === 0}
      >
        {(r) => {
          const cohorts = r.cohorts ?? [];
          // Колонок столько, сколько недель пришло в самой длинной когорте (сервер может отдать не WEEKS+1).
          const columns = Math.max(0, ...cohorts.map((c) => (c.retained ?? []).length)) || WEEKS + 1;
          return (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Неделя регистрации</th>
                    <th>Юзеров</th>
                    {Array.from({ length: columns }, (_, n) => (
                      <th key={n}>Нед. {n}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {cohorts.map((cohort) => (
                    <tr key={cohort.week}>
                      <td>с {formatDay(cohort.week)}</td>
                      <td>{cohort.size}</td>
                      {Array.from({ length: columns }, (_, n) => {
                        const value = cohort.retained?.[n] ?? null;
                        return value === null ? (
                          <td key={n} className="heat heat-empty" aria-label="нет данных">
                            ·
                          </td>
                        ) : (
                          <td key={n} className="heat" style={heatStyle(value)}>
                            {formatPercent(value, 0)}
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          );
        }}
      </ChartCard>
      <p className="muted">Активность — вход в приложение или любое событие. Неделя 0 — неделя регистрации (100%).</p>
    </div>
  );
}
