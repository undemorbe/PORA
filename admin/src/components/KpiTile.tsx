import type { Delta } from '../lib/format';

interface Props {
  label: string;
  value: string;
  delta?: Delta | null;
  hint?: string;
}

export function KpiTile({ label, value, delta, hint }: Props) {
  return (
    <div className="kpi">
      <div className="kpi-label">{label}</div>
      <div className="kpi-value">{value}</div>
      {(delta || hint) && (
        <div className="kpi-foot">
          {delta && <span className={`delta-${delta.trend}`}>{delta.text}</span>}
          {hint && <span>{hint}</span>}
        </div>
      )}
    </div>
  );
}
