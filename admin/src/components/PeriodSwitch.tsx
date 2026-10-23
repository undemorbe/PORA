import { PERIODS } from '../hooks/usePeriod';

interface Props {
  value: number;
  onChange: (days: number) => void;
}

export function PeriodSwitch({ value, onChange }: Props) {
  return (
    <div className="segmented" role="group" aria-label="Период">
      {PERIODS.map((days) => (
        <button key={days} type="button" aria-pressed={value === days} onClick={() => onChange(days)}>
          {days} дней
        </button>
      ))}
    </div>
  );
}
