import { useAuth } from '../auth/AuthContext';

/** Сессию не удалось проверить (нет сети или сбой сервера): сессия сохранена, предлагаем повторить. */
export function OfflinePage() {
  const { retry, offlineReason } = useAuth();
  const server = offlineReason === 'server';
  return (
    <main className="center">
      <section className="card login">
        <h1 role="alert">{server ? 'Сервер недоступен' : 'Нет связи с сервером'}</h1>
        <p className="muted">
          {server ? 'Сервер временно не отвечает. Попробуйте чуть позже.' : 'Проверьте подключение к сети и попробуйте ещё раз.'}
        </p>
        <button type="button" className="btn btn-primary" onClick={retry}>
          Повторить
        </button>
      </section>
    </main>
  );
}
