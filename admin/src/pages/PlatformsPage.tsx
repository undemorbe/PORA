import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { BarList } from '../components/BarList';
import { ChartCard } from '../components/ChartCard';
import { usePeriod } from '../hooks/usePeriod';
import { PLATFORM_LABELS } from '../lib/labels';

export function PlatformsPage() {
  const { period } = usePeriod();
  const platforms = useQuery({ queryKey: ['platforms', period], queryFn: () => adminApi.platforms(period) });

  return (
    <div className="page">
      <h1>Платформы и версии</h1>
      <div className="grid-2">
        <ChartCard
          title="Устройства (за всё время)"
          query={platforms}
          isEmpty={(p) => (p.platforms ?? []).length === 0}
        >
          {(p) => (
            <BarList
              items={(p.platforms ?? []).map((i) => ({ name: PLATFORM_LABELS[i.name] ?? i.name, value: i.count }))}
            />
          )}
        </ChartCard>
        <ChartCard
          title="Версии приложения у активных за период"
          query={platforms}
          isEmpty={(p) => (p.versions ?? []).length === 0}
        >
          {(p) => <BarList items={(p.versions ?? []).map((i) => ({ name: i.name, value: i.count }))} />}
        </ChartCard>
      </div>
    </div>
  );
}
