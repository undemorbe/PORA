import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { useEffect, useState, type ReactNode } from 'react';
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

  // Новый (уже debounced) запрос → с первой страницы.
  useEffect(() => setPage(1), [query]);

  const users = useQuery({
    queryKey: ['users', query, page],
    queryFn: () => adminApi.users(query, page),
    placeholderData: keepPreviousData,
  });

  const data = users.data;
  const pages = data ? Math.max(1, Math.ceil(data.total / Math.max(1, data['page-size']))) : 1;
  const stale = users.isPlaceholderData;

  // Список сжался (кого-то удалили, сменился поиск), а мы за его концом — на последнюю страницу.
  useEffect(() => {
    if (data && !stale && page > pages) setPage(pages);
  }, [data, stale, page, pages]);

  const pager = (current: number, total: number): ReactNode => (
    <div className="pager">
      <span className="muted">
        {total} всего · стр. {current} из {pages}
      </span>
      <button type="button" className="btn" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
        Назад
      </button>
      <button type="button" className="btn" disabled={page >= pages} onClick={() => setPage((p) => p + 1)}>
        Вперёд
      </button>
    </div>
  );

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
          onChange={(e) => setSearch(e.target.value)}
        />
      </label>

      <ChartCard
        title="Список"
        query={users}
        // На странице >1 пустой ответ — не «никого нет», а «ушли за конец»: оставляем пагинацию.
        isEmpty={(u) => (u.users ?? []).length === 0 && page <= 1}
        emptyText={query ? 'Никого не нашли' : 'Пользователей пока нет'}
      >
        {(u) => {
          if ((u.users ?? []).length === 0) {
            return (
              <>
                <div className="state">На этой странице никого нет</div>
                {pager(u.page, u.total)}
              </>
            );
          }
          return (
            <div className={stale ? 'is-stale' : undefined} aria-busy={stale}>
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
              {pager(u.page, u.total)}
            </div>
          );
        }}
      </ChartCard>
    </div>
  );
}
