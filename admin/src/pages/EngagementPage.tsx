import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { adminApi } from '../api/endpoints';
import { BarList } from '../components/BarList';
import { ChartCard } from '../components/ChartCard';
import { StackedEvents } from '../components/charts';
import { usePeriod } from '../hooks/usePeriod';
import { daysInRange, formatPercent, ratio } from '../lib/format';
import { EVENT_LABELS, FEATURE_LABELS, FUNNEL_LABELS } from '../lib/labels';
import { pivotEvents } from '../lib/series';

const DEFAULT_EVENTS = ['session_start', 'item_added', 'item_bought', 'ai_message_sent', 'recipe_import'];

export function EngagementPage() {
  const { period } = usePeriod();
  const [selected, setSelected] = useState<string[]>(DEFAULT_EVENTS);

  const funnel = useQuery({ queryKey: ['funnel', period], queryFn: () => adminApi.funnel(period) });
  const features = useQuery({ queryKey: ['features', period], queryFn: () => adminApi.features(period) });
  // Канонический порядок (как в EVENT_LABELS): цвета и легенда не зависят от порядка кликов.
  const names = Object.keys(EVENT_LABELS).filter((name) => selected.includes(name));
  const events = useQuery({
    queryKey: ['events', period, names],
    queryFn: () => adminApi.eventSeries(period, names),
    enabled: names.length > 0,
  });

  const toggle = (name: string) =>
    setSelected((current) => (current.includes(name) ? current.filter((n) => n !== name) : [...current, name]));

  return (
    <div className="page">
      <h1>Вовлечённость</h1>

      <div className="grid-2">
        <ChartCard title="Активация зарегистрированных за период" query={funnel} isEmpty={(f) => (f.steps[0]?.users ?? 0) === 0}>
          {(f) => {
            const base = f.steps[0]?.users ?? 0;
            return (
              <BarList
                items={f.steps.map((s) => ({
                  name: FUNNEL_LABELS[s.step] ?? s.step,
                  value: s.users,
                  display: `${s.users} · ${formatPercent(ratio(s.users, base), 0)}`,
                }))}
              />
            );
          }}
        </ChartCard>

        <ChartCard title="Использование функций (доля MAU)" query={features} isEmpty={(f) => f.mau === 0}>
          {(f) => (
            <BarList
              items={(f.features ?? []).map((item) => ({
                name: FEATURE_LABELS[item.feature] ?? item.feature,
                value: item.share,
                display: `${formatPercent(item.share)} · ${item.users}`,
              }))}
            />
          )}
        </ChartCard>
      </div>

      <ChartCard
        title="События по дням"
        query={events}
        isEmpty={(e) => (e.points ?? []).length === 0}
        emptyText={names.length === 0 ? 'Выберите события' : undefined}
        action={
          <div className="chips" role="group" aria-label="События">
            {Object.keys(EVENT_LABELS).map((name) => (
              <button
                key={name}
                type="button"
                className="chip"
                aria-pressed={selected.includes(name)}
                onClick={() => toggle(name)}
              >
                {EVENT_LABELS[name]}
              </button>
            ))}
          </div>
        }
      >
        {(e) => (
          <StackedEvents
            rows={pivotEvents(e.points ?? [], daysInRange(period.from, period.to), names)}
            names={names}
            labels={EVENT_LABELS}
          />
        )}
      </ChartCard>
      <p className="muted">Воронка нестрогая: каждый шаг — юзеры, у которых было это действие, независимо от предыдущих.</p>
    </div>
  );
}
