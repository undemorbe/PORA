import { useAuth } from '../auth/AuthContext';

export function ForbiddenPage() {
  const { signOut } = useAuth();
  return (
    <main className="center">
      <section className="card login">
        <h1>Нет доступа</h1>
        <p className="muted">У этого аккаунта нет прав администратора. Права выдаются через ADMIN_EMAILS на сервере.</p>
        <button type="button" className="btn" onClick={() => void signOut()}>
          Войти другим аккаунтом
        </button>
      </section>
    </main>
  );
}
