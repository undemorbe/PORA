import { useState, type FormEvent } from 'react';
import { ApiError } from '../api/client';
import { adminApi } from '../api/endpoints';
import { useAuth } from '../auth/AuthContext';

function loginError(error: unknown): string {
  if (error instanceof ApiError) {
    if (error.status === 403) return 'У этой почты нет прав администратора';
    if (error.code === 'OTP_INCORRECT') return 'Неверный код';
    if (error.code === 'OTP_EXPIRED') return 'Код истёк — запросите новый';
    if (error.status >= 500) return 'Сервер недоступен';
    return error.message;
  }
  return 'Нет связи с сервером';
}

export function LoginPage() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<'email' | 'code'>('email');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const run = async (action: () => Promise<void>) => {
    setBusy(true);
    setError(null);
    try {
      await action();
    } catch (e) {
      setError(loginError(e));
    } finally {
      setBusy(false);
    }
  };

  const changeEmail = () => {
    setStep('email');
    setOtp('');
    setError(null);
  };

  const onSubmit = (event: FormEvent) => {
    event.preventDefault();
    if (step === 'email') {
      void run(async () => {
        await adminApi.sendOtp(email.trim());
        setStep('code');
      });
    } else {
      void run(() => signIn(email.trim(), otp.trim()));
    }
  };

  return (
    <main className="center">
      <form className="card login" onSubmit={onSubmit}>
        <h1>Pora · Аналитика</h1>
        <label className="field">
          <span>Почта</span>
          <input
            className="input"
            type="email"
            autoComplete="email"
            required
            value={email}
            disabled={step === 'code'}
            onChange={(e) => setEmail(e.target.value)}
          />
        </label>
        {step === 'code' && (
          <label className="field">
            <span>Код из письма</span>
            <input
              className="input"
              inputMode="numeric"
              autoComplete="one-time-code"
              required
              autoFocus
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
            />
          </label>
        )}
        {error && (
          <p className="error-text" role="alert">
            {error}
          </p>
        )}
        <button type="submit" className="btn btn-primary" disabled={busy} aria-busy={busy}>
          {step === 'email' ? 'Получить код' : 'Войти'}
        </button>
        {step === 'code' && (
          <button type="button" className="btn" disabled={busy} onClick={changeEmail}>
            Другая почта
          </button>
        )}
      </form>
    </main>
  );
}
