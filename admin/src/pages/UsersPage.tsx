import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { useDebounced } from '../hooks/useDebounced';
import { formatDateTime } from '../lib/format';
import { displayName } from '../lib/users';

const TZ = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
/** Сервер обрезает `q` до 100 символов — не даём ввести больше. */
const QUERY_MAX = 100;

export function UsersPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const query = useDebounced(search.trim().slice(0, QUERY_MAX));

  const users = useQuery({
    queryKey: ['users', query, page],
    queryFn: () => adminApi.users(query, page),
    placeholderData: keepPreviousData,
  });

  const onSearch = (value: string) => {
    setSearch(value);
    setPage(1);
  };

  return (
    <div className="page">
      <h1>Пользователи</h1>
      <label className="field">
        <span>Поиск по почте, телефону, имени</span>
        <input
          className="input"
          type="search"
          maxLength={QUERY_MAX}
          value={search}
          onChange={(e) => onSearch(e.target.value)}
        />
      </label>

      <ChartCard
        title="Список"
        query={users}
        isEmpty={(u) => (u.users ?? []).length === 0}
        emptyText={query ? 'Никого не нашли' : 'Пользователей пока нет'}
      >
        {(u) => {
          const pages = Math.max(1, Math.ceil(u.total / u['page-size']));
          return (
            <>
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Пользователь</th>
                      <th>Контакт</th>
                      <th>Регистрация</th>
                      <th>Последняя активность</th>
                      <th>Списки</th>
                      <th>Товары</th>
                      <th>Семьи</th>
                    </tr>
                  </thead>
                  <tbody>
                    {u.users.map((user) => (
                      <tr key={user.id} className="clickable" onClick={() => navigate(`/users/${user.id}`)}>
                        <td>
                          {/* Ссылка — для клавиатуры и «открыть в новой вкладке»; клик по строке — для мыши. */}
                          <Link to={`/users/${user.id}`} onClick={(e) => e.stopPropagation()}>
                            {displayName(user)}
                          </Link>{' '}
                          {user['is-admin'] && <span className="badge">админ</span>}
                        </td>
                        <td className="muted">{user.email || user.phone}</td>
                        <td>{formatDateTime(user['created-at'], TZ)}</td>
                        <td>{user['last-active-at'] ? formatDateTime(user['last-active-at'], TZ) : '—'}</td>
                        <td>{user.lists}</td>
                        <td>{user.items}</td>
                        <td>{user.families}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="pager">
                <span className="muted">
                  {u.total} всего · стр. {u.page} из {pages}
                </span>
                <button type="button" className="btn" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
                  Назад
                </button>
                <button type="button" className="btn" disabled={page >= pages} onClick={() => setPage((p) => p + 1)}>
                  Вперёд
                </button>
              </div>
            </>
          );
        }}
      </ChartCard>
    </div>
  );
}
