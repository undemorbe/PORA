import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { BarList } from '../components/BarList';
import { ChartCard } from '../components/ChartCard';
import { KpiTile } from '../components/KpiTile';
import { usePeriod } from '../hooks/usePeriod';

function formatHours(hours: number | null): string {
  if (hours === null) return '—';
  if (hours < 48) return `${hours.toFixed(1).replace('.', ',')} ч`;
  return `${(hours / 24).toFixed(1).replace('.', ',')} дн`;
}

export function ProductsPage() {
  const { period } = usePeriod();
  const added = useQuery({ queryKey: ['top', period, 'added'], queryFn: () => adminApi.topProducts(period, 'added') });
  const bought = useQuery({ queryKey: ['top', period, 'bought'], queryFn: () => adminApi.topProducts(period, 'bought') });
  const sections = useQuery({ queryKey: ['sections', period], queryFn: () => adminApi.sections(period) });

  return (
    <div className="page">
      <h1>Товары</h1>

      <ChartCard title="Скорость покупки" query={bought}>
        {(b) => (
          <div className="kpi-grid">
            <KpiTile
              label="Медиана «добавлено → куплено»"
              value={formatHours(b['median-hours-to-buy'])}
              hint={b['median-hours-to-buy'] === null ? 'появится после новых покупок' : 'по купленным за период'}
            />
          </div>
        )}
      </ChartCard>

      <div className="grid-2">
        <ChartCard title="Чаще всего добавляют" query={added} isEmpty={(a) => (a.items ?? []).length === 0}>
          {(a) => <BarList items={(a.items ?? []).map((i) => ({ name: i.name, value: i.count }))} />}
        </ChartCard>
        <ChartCard title="Чаще всего покупают" query={bought} isEmpty={(b) => (b.items ?? []).length === 0}>
          {(b) => <BarList items={(b.items ?? []).map((i) => ({ name: i.name, value: i.count }))} />}
        </ChartCard>
      </div>

      <ChartCard title="Секции добавленных товаров" query={sections} isEmpty={(s) => (s.sections ?? []).length === 0}>
        {(s) => (
          <BarList items={(s.sections ?? []).map((i) => ({ name: i.name || 'Без секции', value: i.count }))} />
        )}
      </ChartCard>
      <p className="muted">Названия нормализованы (нижний регистр). Данные — с момента включения серверной аналитики.</p>
    </div>
  );
}
