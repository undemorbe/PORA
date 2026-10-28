export interface EventPoint {
  date: string;
  name: string;
  count: number;
}

export type PivotRow = { date: string } & Record<string, number | string>;

/** Точки событий → строки по дням с колонкой на каждое событие (0, если не было). */
export function pivotEvents(points: EventPoint[], days: string[], names: string[]): PivotRow[] {
  const counts = new Map<string, number>();
  for (const point of points) counts.set(`${point.date}|${point.name}`, point.count);

  return days.map((date) => {
    const row: PivotRow = { date };
    for (const name of names) row[name] = counts.get(`${date}|${name}`) ?? 0;
    return row;
  });
}
