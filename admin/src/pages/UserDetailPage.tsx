import { useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router-dom';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { KpiTile } from '../components/KpiTile';
import { formatDateTime } from '../lib/format';
import { EVENT_LABELS } from '../lib/labels';
import { displayName } from '../lib/users';

const TZ = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';

export function UserDetailPage() {
  const { id = '' } = useParams();
  const detail = useQuery({ queryKey: ['user', id], queryFn: () => adminApi.user(id), enabled: id !== '' });

  return (
    <div className="page">
      <Link to="/users">← Все пользователи</Link>

      <ChartCard title="Профиль" query={detail}>
        {({ user }) => (
          <>
            <h1>
              {displayName(user)} {user['is-admin'] && <span className="badge">админ</span>}
            </h1>
            <p className="muted">
              {[user.email, user.phone].filter(Boolean).join(' · ')} · статус {user.status}
            </p>
            <div className="kpi-grid">
              <KpiTile label="Регистрация" value={formatDateTime(user['created-at'], TZ)} />
              <KpiTile
                label="Последняя активность"
                value={user['last-active-at'] ? formatDateTime(user['last-active-at'], TZ) : '—'}
              />
              <KpiTile label="Списки" value={String(user.lists)} />
              <KpiTile label="Товары" value={String(user.items)} />
              <KpiTile label="Семьи" value={String(user.families)} />
            </div>
          </>
        )}
      </ChartCard>

      <ChartCard
        title="Последние 100 событий"
        query={detail}
        isEmpty={(d) => (d.events ?? []).length === 0}
        emptyText="Событий пока нет"
      >
        {({ events }) => (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Время</th>
                  <th>Событие</th>
                  <th>Параметры</th>
                  <th>Источник</th>
                  <th>Платформа</th>
                </tr>
              </thead>
              <tbody>
                {(events ?? []).map((event) => {
                  const props = event.props && Object.keys(event.props).length > 0 ? JSON.stringify(event.props) : '';
                  return (
                    <tr key={event.id}>
                      <td>{formatDateTime(event['occurred-at'], TZ)}</td>
                      <td>{EVENT_LABELS[event.name] ?? event.name}</td>
                      <td className="mono props-cell" title={props || undefined}>
                        {props}
                      </td>
                      <td>{event.source === 'server' ? 'сервер' : 'клиент'}</td>
                      <td className="muted">
                        {event.platform} {event['app-version']}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </ChartCard>
    </div>
  );
}
