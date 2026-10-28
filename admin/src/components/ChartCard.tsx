import type { UseQueryResult } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { ApiError } from '../api/client';

interface Props<T> {
  title: string;
  query: UseQueryResult<T>;
  isEmpty?: (data: T) => boolean;
  /** Текст пустого состояния (и выключенного запроса); по умолчанию «Нет данных за период». */
  emptyText?: string;
  /** Доступное имя кнопки «Повторить», когда на экране несколько карточек с одной ошибкой. */
  retryLabel?: string;
  action?: ReactNode;
  children: (data: T) => ReactNode;
}

function errorText(error: unknown): string {
  if (error instanceof ApiError) {
    if (error.status === 0) return 'Нет связи с сервером';
    return error.status >= 500 ? 'Сервер недоступен' : error.message;
  }
  return 'Нет связи с сервером';
}

/** Карточка блока с независимыми состояниями: загрузка / ошибка / пусто / данные. */
export function ChartCard<T>({
  title,
  query,
  isEmpty,
  emptyText = 'Нет данных за период',
  retryLabel,
  action,
  children,
}: Props<T>) {
  let body: ReactNode;
  // isLoading (v5) = первая загрузка идёт; у выключенного запроса isPending без загрузки.
  if (query.isLoading) {
    body = (
      <div className="state" aria-busy="true">
        Загрузка…
      </div>
    );
  } else if (query.isError) {
    body = (
      <div className="state state-error" role="status">
        <p>{errorText(query.error)}</p>
        <button
          type="button"
          className="btn"
          aria-label={retryLabel}
          disabled={query.isFetching}
          onClick={() => void query.refetch()}
        >
          Повторить
        </button>
      </div>
    );
  } else if (query.data === undefined || isEmpty?.(query.data)) {
    body = <div className="state">{emptyText}</div>;
  } else {
    body = children(query.data);
  }

  return (
    <section className="card">
      <header className="card-head">
        <h2>{title}</h2>
        {action}
      </header>
      {body}
    </section>
  );
}
