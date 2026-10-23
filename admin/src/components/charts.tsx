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

// Палитра серий: контраст ≥3:1 и к светлой (#ffffff), и к тёмной (#1e1c1b) поверхности.
export const SERIES_COLORS = ['#d4694e', '#3d7ea6', '#4a9572', '#a87a26', '#8d6a9f', '#c0699a'];

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
