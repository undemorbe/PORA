import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { DayCount } from '../api/types';
import { formatDay } from '../lib/format';
import type { PivotRow } from '../lib/series';

// Палитра серий: акцент + приглушённые нейтрали, различимые в обеих темах.
export const SERIES_COLORS = ['#e07a5f', '#3d7ea6', '#81b29a', '#f2cc8f', '#8d6a9f', '#6b6560'];

const axis = { stroke: 'var(--text-muted)', fontSize: 12 };
const tooltipStyle = {
  background: 'var(--surface)',
  border: '1px solid var(--border)',
  borderRadius: 8,
  color: 'var(--text)',
};

export function DailyLine({ data, label }: { data: DayCount[]; label: string }) {
  return (
    <ResponsiveContainer width="100%" height={240}>
      <LineChart data={data} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
        <CartesianGrid stroke="var(--border)" vertical={false} />
        <XAxis dataKey="date" tickFormatter={formatDay} {...axis} />
        <YAxis allowDecimals={false} {...axis} />
        <Tooltip contentStyle={tooltipStyle} labelFormatter={(d) => formatDay(String(d))} />
        <Line type="monotone" dataKey="count" name={label} stroke="var(--accent)" strokeWidth={2} dot={false} />
      </LineChart>
    </ResponsiveContainer>
  );
}

export function DailyBars({ data, label }: { data: DayCount[]; label: string }) {
  return (
    <ResponsiveContainer width="100%" height={240}>
      <BarChart data={data} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
        <CartesianGrid stroke="var(--border)" vertical={false} />
        <XAxis dataKey="date" tickFormatter={formatDay} {...axis} />
        <YAxis allowDecimals={false} {...axis} />
        <Tooltip contentStyle={tooltipStyle} labelFormatter={(d) => formatDay(String(d))} />
        <Bar dataKey="count" name={label} fill="var(--accent)" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}

export function StackedEvents({ rows, names, labels }: { rows: PivotRow[]; names: string[]; labels: Record<string, string> }) {
  return (
    <ResponsiveContainer width="100%" height={280}>
      <AreaChart data={rows} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
        <CartesianGrid stroke="var(--border)" vertical={false} />
        <XAxis dataKey="date" tickFormatter={formatDay} {...axis} />
        <YAxis allowDecimals={false} {...axis} />
        <Tooltip contentStyle={tooltipStyle} labelFormatter={(d) => formatDay(String(d))} />
        <Legend />
        {names.map((name, index) => (
          <Area
            key={name}
            type="monotone"
            dataKey={name}
            name={labels[name] ?? name}
            stackId="events"
            stroke={SERIES_COLORS[index % SERIES_COLORS.length]}
            fill={SERIES_COLORS[index % SERIES_COLORS.length]}
            fillOpacity={0.35}
          />
        ))}
      </AreaChart>
    </ResponsiveContainer>
  );
}
