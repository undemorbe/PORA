import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { DailyBars, DailyLine } from '../components/charts';
import { KpiTile } from '../components/KpiTile';
import { usePeriod } from '../hooks/usePeriod';
import { formatDelta, formatNumber, formatPercent, ratio } from '../lib/format';

export function OverviewPage() {
  const { period } = usePeriod();
  const overview = useQuery({ queryKey: ['overview', period], queryFn: () => adminApi.overview(period) });
  const active = useQuery({ queryKey: ['active-users', period], queryFn: () => adminApi.activeUsers(period) });
  const signups = useQuery({ queryKey: ['signups', period], queryFn: () => adminApi.signups(period) });

  return (
    <div className="page">
      <h1>Обзор</h1>

      <ChartCard title="Ключевые метрики" query={overview}>
        {(o) => (
          <div className="kpi-grid">
            <KpiTile label="Всего пользователей" value={formatNumber(o['total-users'])} />
            <KpiTile
              label="Новые за период"
              value={formatNumber(o['new-users'])}
              delta={formatDelta(o['new-users'], o['new-users-prev'])}
            />
            <KpiTile label="DAU" value={formatNumber(o.dau)} hint="последний день" />
            <KpiTile label="WAU" value={formatNumber(o.wau)} />
            <KpiTile label="MAU" value={formatNumber(o.mau)} />
            <KpiTile label="Stickiness" value={formatPercent(ratio(o.dau, o.mau))} hint="DAU / MAU" />
            <KpiTile
              label="Добавлено товаров"
              value={formatNumber(o['items-added'])}
              delta={formatDelta(o['items-added'], o['items-added-prev'])}
            />
            <KpiTile
              label="Куплено товаров"
              value={formatNumber(o['items-bought'])}
              delta={formatDelta(o['items-bought'], o['items-bought-prev'])}
            />
          </div>
        )}
      </ChartCard>

      <div className="grid-2">
        <ChartCard title="Активные пользователи" query={active} isEmpty={(a) => a.days.every((d) => d.count === 0)}>
          {(a) => <DailyLine data={a.days} label="DAU" />}
        </ChartCard>
        <ChartCard title="Регистрации" query={signups} isEmpty={(s) => s.days.every((d) => d.count === 0)}>
          {(s) => <DailyBars data={s.days} label="Регистрации" />}
        </ChartCard>
      </div>
    </div>
  );
}
