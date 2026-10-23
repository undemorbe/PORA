export interface BarItem {
  name: string;
  value: number;
  /** Подпись справа; по умолчанию — само значение. */
  display?: string;
}

/** Горизонтальные доли: ширина бара — доля от максимума. */
export function BarList({ items }: { items: BarItem[] }) {
  const max = Math.max(0, ...items.map((item) => item.value));
  return (
    <ul className="bars">
      {items.map((item) => (
        <li key={item.name} className="bar-row">
          <span className="bar-name" title={item.name}>
            {item.name}
          </span>
          <span className="bar-track" aria-hidden="true">
            <span className="bar-fill" style={{ display: 'block', width: `${max === 0 ? 0 : (item.value / max) * 100}%` }} />
          </span>
          <span className="bar-value">{item.display ?? item.value}</span>
        </li>
      ))}
    </ul>
  );
}
