import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { usePeriod } from '../hooks/usePeriod';
import { PeriodSwitch } from './PeriodSwitch';

const NAV = [
  { to: '/', label: 'Обзор', end: true },
  { to: '/retention', label: 'Retention' },
  { to: '/engagement', label: 'Вовлечённость' },
  { to: '/products', label: 'Товары' },
  { to: '/platforms', label: 'Платформы' },
  { to: '/users', label: 'Пользователи' },
  { to: '/push', label: 'Рассылка' },
];

// Экраны без периода: переключатель там не нужен.
const NO_PERIOD = ['/users', '/push'];

export function Layout() {
  const { me, signOut } = useAuth();
  const { days, setDays } = usePeriod();
  const { pathname, search } = useLocation();
  const showPeriod = !NO_PERIOD.some((prefix) => pathname.startsWith(prefix));

  return (
    <div className="shell">
      <nav className="sidebar" aria-label="Разделы">
        <div className="brand">Pora · Аналитика</div>
        {NAV.map((item) => (
          <NavLink
            key={item.to}
            to={{ pathname: item.to, search }}
            end={item.end}
            className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}
          >
            {item.label}
          </NavLink>
        ))}
        <div className="sidebar-foot">
          <span>{me?.email ?? me?.name}</span>
          <button type="button" className="btn" onClick={() => void signOut()}>
            Выйти
          </button>
        </div>
      </nav>
      <main className="main">
        {showPeriod && (
          <div className="topbar">
            <span className="muted">Таймзона: {Intl.DateTimeFormat().resolvedOptions().timeZone}</span>
            <PeriodSwitch value={days} onChange={setDays} />
          </div>
        )}
        <Outlet />
      </main>
    </div>
  );
}
