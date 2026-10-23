import { useAuth } from '../auth/AuthContext';

/** Сервер не ответил при проверке сессии: сессия сохранена, предлагаем повторить. */
export function OfflinePage() {
  const { retry } = useAuth();
  return (
    <main className="center">
      <section className="card login" role="alert">
        <h1>Нет связи с сервером</h1>
        <p className="muted">Проверьте подключение к сети и попробуйте ещё раз.</p>
        <button type="button" className="btn btn-primary" onClick={retry}>
          Повторить
        </button>
      </section>
    </main>
  );
}
