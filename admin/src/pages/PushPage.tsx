import { useMutation } from '@tanstack/react-query';
import { useEffect, useRef, useState, type FormEvent } from 'react';
import { ApiError } from '../api/client';
import { adminApi } from '../api/endpoints';

// Лимиты сервера (считаются после trim): >65 / >240 или пустое после trim → 400.
const TITLE_MAX = 65;
const BODY_MAX = 240;

interface PushMessage {
  title: string;
  body: string;
}

function pushErrorText(error: unknown): string {
  if (error instanceof ApiError) {
    if (error.status === 0) return 'Нет связи с сервером';
    if (error.status >= 500) return 'Сервер недоступен';
    if (error.code === 'INVALID_INPUT') return 'Заголовок до 65 и текст до 240 символов, оба не пустые';
    // 400 — сервер объясняет, что не так с текстом.
    return error.message;
  }
  return 'Нет связи с сервером';
}

export function PushPage() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [confirming, setConfirming] = useState(false);
  const titleRef = useRef<HTMLInputElement>(null);
  const submitRef = useRef<HTMLButtonElement>(null);
  const cancelRef = useRef<HTMLButtonElement>(null);
  const wasConfirming = useRef(false);

  const push = useMutation({
    mutationFn: (message: PushMessage) => adminApi.push(message.title, message.body),
    onSuccess: () => {
      // Отправленный текст стираем, чтобы случайно не разослать его повторно.
      setTitle('');
      setBody('');
    },
    onSettled: () => setConfirming(false),
  });

  const message: PushMessage = { title: title.trim(), body: body.trim() };
  const ready = message.title !== '' && message.body !== '';

  // Кнопка, на которой был фокус, исчезает при смене режима — переносим фокус явно.
  // В подтверждении по умолчанию — «Отмена» (безопасный выбор для Enter).
  useEffect(() => {
    if (confirming) {
      cancelRef.current?.focus();
    } else if (wasConfirming.current) {
      (submitRef.current && !submitRef.current.disabled ? submitRef.current : titleRef.current)?.focus();
    }
    wasConfirming.current = confirming;
  }, [confirming]);

  const onSubmit = (event: FormEvent) => {
    event.preventDefault();
    if (ready) {
      push.reset();
      setConfirming(true);
    }
  };

  return (
    <div className="page">
      <h1>Рассылка</h1>
      <div className="grid-2">
        <form className="card page" onSubmit={onSubmit}>
          <label className="field">
            <span>Заголовок</span>
            <input
              ref={titleRef}
              className="input"
              maxLength={TITLE_MAX}
              value={title}
              disabled={confirming}
              onChange={(e) => setTitle(e.target.value)}
            />
          </label>
          <label className="field">
            <span>Текст</span>
            <textarea
              className="input"
              maxLength={BODY_MAX}
              value={body}
              disabled={confirming}
              onChange={(e) => setBody(e.target.value)}
            />
          </label>
          <span className="muted">
            {message.title.length}/{TITLE_MAX} · {message.body.length}/{BODY_MAX}
          </span>

          {confirming ? (
            <div role="group" aria-label="Подтверждение" className="chips">
              <span>Уведомление получат все пользователи приложения. Отменить после отправки нельзя.</span>
              <button
                ref={cancelRef}
                type="button"
                className="btn"
                disabled={push.isPending}
                onClick={() => setConfirming(false)}
              >
                Отмена
              </button>
              <button
                type="button"
                className="btn btn-danger"
                disabled={push.isPending}
                onClick={() => push.mutate(message)}
              >
                Да, отправить
              </button>
            </div>
          ) : (
            <button ref={submitRef} type="submit" className="btn btn-primary" disabled={!ready}>
              Отправить всем
            </button>
          )}

          {push.isSuccess && (
            <p className="success-text" role="status">
              Рассылка отправлена
            </p>
          )}
          {push.isError && (
            <p className="error-text" role="alert">
              {pushErrorText(push.error)}
            </p>
          )}
        </form>

        <section className="card">
          <header className="card-head">
            <h2>Превью</h2>
          </header>
          <div className="push-preview">
            <strong>{message.title || 'Заголовок'}</strong>
            <span className="muted">{message.body || 'Текст уведомления'}</span>
          </div>
        </section>
      </div>
    </div>
  );
}
