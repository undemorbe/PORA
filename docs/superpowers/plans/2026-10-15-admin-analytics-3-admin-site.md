# Admin-аналитика, план 3 из 3 — сайт `admin/` (React + Vite)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Отдельный сайт админ-аналитики: вход по OTP (`client=admin`), 7 экранов (обзор, retention, вовлечённость, товары, платформы, пользователи, push), деплой nginx-контейнером рядом с бэкендом.

**Architecture:** SPA на Vite + React 18 + TypeScript. Данные — TanStack Query поверх тонкого `apiFetch` (access-токен в памяти, refresh в `localStorage`, автоматический refresh на 401). Период (7/30/90 дней) живёт в URL (`?days=`), таймзона — браузерная. Каждый блок — `ChartCard` с независимыми состояниями загрузки/ошибки/пустоты. Графики по времени — Recharts; списки-доли — CSS-бары. Прод: multi-stage Docker (`node` → `nginx`), nginx проксирует `/api` на `app:5040` — один origin, без CORS.

**Tech Stack:** Node 22, Vite 5, React 18.3, react-router-dom 6, @tanstack/react-query 5, Recharts 2, TypeScript 5.6, Vitest 2 + Testing Library + jsdom, nginx 1.27.

**Spec:** `docs/superpowers/specs/2026-10-15-admin-analytics-design.md` (§1.3, §2.2, §3.4)

**Зависимости:** контракты `/api/admin/*` и `verify-otp` с `client` — план 1 (Tasks 3, 6, 11–14). Сайт можно собирать и тестировать без бэкенда (fetch мокается); ручная проверка — с бэкендом.

**Где что лежит:** `admin/` — в публичном корневом репо (секретов нет, авторизация на сервере). Сервис `admin` в `backend/docker-compose.yml` — коммит в репо бэкенда (`git -C backend …`, см. план 1 Task 0). Docker-контекст `../admin` пересекает репозитории — это нормально для локального деплоя; для CI/CD бэкенда позже понадобится отдельная сборка образа.

---

## Решения, уточнённые при планировании

1. **Refresh-токен идёт в query** (`GET /api/authorize/refresh?refresh-token=…` — существующий контракт бэкенда). Чтобы он не оседал в логах, nginx не пишет access-лог для `/api/authorize/`.
2. **Refresh-токен в `localStorage`** — компромисс ради «не логиниться после перезагрузки». Смягчение: строгий CSP (`script-src 'self'`), без сторонних скриптов и шрифтов, `X-Frame-Options: DENY`.
3. **Отказ админ-прав посреди сессии** (`403` от `/api/admin/*`) переводит приложение на экран «Нет доступа»; неуспешный refresh (`401`) — на логин. Реализовано через `setAuthErrorHandler` в API-клиенте.
4. **UI на русском**, системный шрифт, одна акцентная краска (`#E07A5F`, бренд-цвет иконки приложения), светлая/тёмная тема по `prefers-color-scheme`.
5. **Go отдаёт `null` вместо пустых массивов** там, где слайс не инициализирован — типы помечают такие поля `| null`, код читает `?? []`.
6. **Версии зависимостей зафиксированы** (не диапазоны) — воспроизводимость; обновление — отдельной задачей.

## Карта файлов (`admin/`)

| Файл | Ответственность |
|---|---|
| `package.json`, `package-lock.json`, `tsconfig.json`, `vite.config.ts`, `index.html`, `.gitignore` | каркас |
| `src/main.tsx`, `src/App.tsx` | вход, провайдеры, маршруты |
| `src/styles.css` | токены, светлая/тёмная тема, компоненты |
| `src/api/tokens.ts` | access в памяти, refresh в `localStorage` |
| `src/api/client.ts` | `apiFetch`, `ApiError`, refresh, обработчик 401/403 |
| `src/api/types.ts` | типы ответов (зеркало `dto/responses/admin.go`) |
| `src/api/endpoints.ts` | функции эндпоинтов |
| `src/auth/AuthContext.tsx` | статус сессии, вход/выход |
| `src/lib/format.ts`, `src/lib/series.ts` | форматирование, период, сводка событий |
| `src/hooks/usePeriod.ts`, `src/hooks/useDebounced.ts` | период из URL, debounce поиска |
| `src/components/*.tsx` | `Layout`, `PeriodSwitch`, `ChartCard`, `KpiTile`, `BarList`, `charts` |
| `src/pages/*.tsx` | 7 экранов + логин + «нет доступа» + карточка юзера |
| `src/test/setup.ts`, `src/**/*.test.ts(x)` | тесты |
| `Dockerfile`, `nginx.conf`, `.dockerignore` | прод-сборка |
| `README.md` | запуск, деплой, назначение админа |
| `backend/docker-compose.yml` (mod, репо бэкенда) | сервис `admin` |
| `.github/workflows/ci.yml` (mod, корневой репо) | job `admin` |
| `CLAUDE.md` (mod, локально — в `.gitignore`) | раздел про админку |

## Общие команды

```bash
cd admin && npm run dev          # http://localhost:5173, /api проксируется на localhost:5040
cd admin && npm run typecheck && npm test && npm run build
```

---

### Task 1: Каркас проекта

**Files:**
- Create: `admin/package.json`, `admin/tsconfig.json`, `admin/vite.config.ts`, `admin/index.html`, `admin/.gitignore`
- Create: `admin/src/main.tsx`, `admin/src/App.tsx` (временный), `admin/src/styles.css` (пустой), `admin/src/test/setup.ts`

- [ ] **Step 1: `admin/package.json`**

```json
{
  "name": "pora-admin",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  },
  "dependencies": {
    "@tanstack/react-query": "5.62.7",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "react-router-dom": "6.28.0",
    "recharts": "2.15.0"
  },
  "devDependencies": {
    "@testing-library/dom": "10.4.0",
    "@testing-library/jest-dom": "6.6.3",
    "@testing-library/react": "16.1.0",
    "@testing-library/user-event": "14.5.2",
    "@types/react": "18.3.12",
    "@types/react-dom": "18.3.1",
    "@vitejs/plugin-react": "4.3.4",
    "jsdom": "25.0.1",
    "typescript": "5.6.3",
    "vite": "5.4.11",
    "vitest": "2.1.8"
  }
}
```

- [ ] **Step 2: `admin/tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "isolatedModules": true,
    "noEmit": true,
    "types": ["vitest/globals"]
  },
  "include": ["src", "vite.config.ts"]
}
```

- [ ] **Step 3: `admin/vite.config.ts`**

```ts
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    // Dev: тот же origin, что и в проде через nginx — без CORS.
    proxy: { '/api': 'http://localhost:5040' },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
  },
});
```

- [ ] **Step 4: `admin/index.html`**

```html
<!doctype html>
<html lang="ru">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex, nofollow" />
    <meta name="color-scheme" content="light dark" />
    <title>Pora · Аналитика</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

- [ ] **Step 5: `admin/.gitignore`**

```gitignore
node_modules/
dist/
coverage/
*.local
```

- [ ] **Step 6: Вход, временный `App`, пустые стили, setup тестов**

`admin/src/main.tsx`:

```tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import './styles.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
```

`admin/src/App.tsx` (заменяется в Task 6):

```tsx
export function App() {
  return <p>Pora admin</p>;
}
```

`admin/src/styles.css` — пустой файл (наполняется в Task 5).

`admin/src/test/setup.ts`:

```ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach, vi } from 'vitest';

// Recharts ResponsiveContainer требует ResizeObserver, которого нет в jsdom.
class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}
globalThis.ResizeObserver = ResizeObserverStub as unknown as typeof ResizeObserver;

afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
  localStorage.clear();
});
```

- [ ] **Step 7: Установка и проверка**

```bash
cd admin && npm install
npm run typecheck && npm run build
```

Expected: `npm install` создаёт `package-lock.json` без ошибок резолва; typecheck без вывода; `vite build` → `dist/index.html`. (`npm test` пока скажет `No test files found` — это нормально.)

- [ ] **Step 8: Commit**

```bash
git add admin/package.json admin/package-lock.json admin/tsconfig.json admin/vite.config.ts \
  admin/index.html admin/.gitignore admin/src/main.tsx admin/src/App.tsx admin/src/styles.css admin/src/test/setup.ts
git commit -m "feat(admin): scaffold Vite + React + TS admin site"
```

---

### Task 2: Форматирование, период и сводка событий

**Files:**
- Create: `admin/src/lib/format.ts`, `admin/src/lib/series.ts`
- Test: `admin/src/lib/format.test.ts`, `admin/src/lib/series.test.ts`

- [ ] **Step 1: Падающие тесты**

`admin/src/lib/format.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { daysInRange, formatDay, formatDelta, formatPercent, periodRange, ratio } from './format';

describe('formatDelta', () => {
  it('shows signed percent change', () => {
    expect(formatDelta(12, 10)).toEqual({ text: '+20%', trend: 'up' });
    expect(formatDelta(5, 10)).toEqual({ text: '−50%', trend: 'down' });
    expect(formatDelta(10, 10)).toEqual({ text: '0%', trend: 'flat' });
  });

  it('handles empty previous period', () => {
    expect(formatDelta(0, 0)).toBeNull();
    expect(formatDelta(3, 0)).toEqual({ text: 'новое', trend: 'up' });
  });
});

describe('percent helpers', () => {
  it('formats with comma decimal', () => {
    expect(formatPercent(45)).toBe('45,0%');
    expect(formatPercent(ratio(1, 3))).toBe('33,3%');
    expect(ratio(5, 0)).toBe(0);
  });
});

describe('periodRange', () => {
  it('counts days inclusively in the given timezone', () => {
    // 21:30 UTC 15-го = 00:30 16-го по Москве
    const now = new Date(Date.UTC(2026, 9, 15, 21, 30));
    expect(periodRange(7, now, 'UTC')).toEqual({ from: '2026-10-09', to: '2026-10-15' });
    expect(periodRange(7, now, 'Europe/Moscow')).toEqual({ from: '2026-10-10', to: '2026-10-16' });
  });

  it('crosses month boundaries', () => {
    const now = new Date(Date.UTC(2026, 2, 2, 12));
    expect(periodRange(30, now, 'UTC').from).toBe('2026-02-01');
  });
});

describe('dates', () => {
  it('lists every day of a range', () => {
    expect(daysInRange('2026-02-27', '2026-03-02')).toEqual([
      '2026-02-27',
      '2026-02-28',
      '2026-03-01',
      '2026-03-02',
    ]);
  });

  it('formats day as dd.mm', () => {
    expect(formatDay('2026-03-02')).toBe('02.03');
  });
});
```

`admin/src/lib/series.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { pivotEvents } from './series';

describe('pivotEvents', () => {
  it('builds one row per day with zero-filled event columns', () => {
    const rows = pivotEvents(
      [
        { date: '2026-10-14', name: 'item_added', count: 3 },
        { date: '2026-10-15', name: 'item_bought', count: 1 },
      ],
      ['2026-10-14', '2026-10-15'],
      ['item_added', 'item_bought'],
    );

    expect(rows).toEqual([
      { date: '2026-10-14', item_added: 3, item_bought: 0 },
      { date: '2026-10-15', item_added: 0, item_bought: 1 },
    ]);
  });
});
```

- [ ] **Step 2: Запусти — должны упасть**

Run: `cd admin && npm test`
Expected: FAIL — `Failed to resolve import "./format"` / `"./series"`.

- [ ] **Step 3: `admin/src/lib/format.ts`**

```ts
const numberFormat = new Intl.NumberFormat('ru-RU');

export type Trend = 'up' | 'down' | 'flat';

export interface Delta {
  text: string;
  trend: Trend;
}

export function formatNumber(value: number): string {
  return numberFormat.format(value);
}

/** Изменение к прошлому периоду; null — сравнивать не с чем. */
export function formatDelta(current: number, previous: number): Delta | null {
  if (previous === 0) return current === 0 ? null : { text: 'новое', trend: 'up' };
  const pct = Math.round(((current - previous) / previous) * 100);
  if (pct === 0) return { text: '0%', trend: 'flat' };
  return { text: `${pct > 0 ? '+' : '−'}${Math.abs(pct)}%`, trend: pct > 0 ? 'up' : 'down' };
}

export function ratio(part: number, whole: number): number {
  return whole === 0 ? 0 : (part / whole) * 100;
}

export function formatPercent(value: number, digits = 1): string {
  return `${value.toFixed(digits).replace('.', ',')}%`;
}

/** 'YYYY-MM-DD' → 'dd.mm' для подписей осей. */
export function formatDay(date: string): string {
  const [, month, day] = date.split('-');
  return `${day}.${month}`;
}

export function formatDateTime(iso: string, timeZone: string): string {
  return new Intl.DateTimeFormat('ru-RU', {
    dateStyle: 'short',
    timeStyle: 'short',
    timeZone,
  }).format(new Date(iso));
}

/** Сегодня в таймзоне tz как 'YYYY-MM-DD'. */
function todayIn(now: Date, timeZone: string): string {
  // en-CA форматирует дату как YYYY-MM-DD.
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(now);
}

function shiftDay(date: string, days: number): string {
  const [year, month, day] = date.split('-').map(Number);
  return new Date(Date.UTC(year, month - 1, day + days)).toISOString().slice(0, 10);
}

/** Последние `days` дней по сегодня включительно, в таймзоне `timeZone`. */
export function periodRange(days: number, now: Date, timeZone: string): { from: string; to: string } {
  const to = todayIn(now, timeZone);
  return { from: shiftDay(to, -(days - 1)), to };
}

/** Все даты от from до to включительно. */
export function daysInRange(from: string, to: string): string[] {
  const days: string[] = [];
  for (let day = from; day <= to; day = shiftDay(day, 1)) days.push(day);
  return days;
}
```

- [ ] **Step 4: `admin/src/lib/series.ts`**

```ts
export interface EventPoint {
  date: string;
  name: string;
  count: number;
}

export type PivotRow = { date: string } & Record<string, number | string>;

/** Точки событий → строки по дням с колонкой на каждое событие (0, если не было). */
export function pivotEvents(points: EventPoint[], days: string[], names: string[]): PivotRow[] {
  const counts = new Map<string, number>();
  for (const point of points) counts.set(`${point.date}|${point.name}`, point.count);

  return days.map((date) => {
    const row: PivotRow = { date };
    for (const name of names) row[name] = counts.get(`${date}|${name}`) ?? 0;
    return row;
  });
}
```

- [ ] **Step 5: Запусти — должно пройти**

Run: `cd admin && npm test && npm run typecheck`
Expected: все тесты `passed`, typecheck без вывода.

- [ ] **Step 6: Commit**

```bash
git add admin/src/lib
git commit -m "feat(admin): formatting, period range and event pivot helpers"
```

---

### Task 3: API-клиент с refresh и обработкой 401/403

**Files:**
- Create: `admin/src/api/tokens.ts`, `admin/src/api/client.ts`
- Test: `admin/src/api/client.test.ts`

- [ ] **Step 1: Падающие тесты**

`admin/src/api/client.test.ts`:

```ts
import { afterEach, describe, expect, it, vi } from 'vitest';
import { ApiError, apiFetch, setAuthErrorHandler } from './client';
import { clearTokens, getRefresh, setTokens } from './tokens';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

const headerOf = (call: unknown[], name: string) =>
  ((call[1] as RequestInit).headers as Record<string, string>)[name];

afterEach(() => {
  clearTokens();
  setAuthErrorHandler(null);
});

describe('apiFetch', () => {
  it('adds bearer token and query params', async () => {
    setTokens('access-1', 'refresh-1');
    const fetchMock = vi.fn().mockResolvedValue(json(200, { dau: 3 }));
    vi.stubGlobal('fetch', fetchMock);

    const result = await apiFetch<{ dau: number }>('/api/admin/overview', {
      query: { from: '2026-10-01', to: '2026-10-15', tz: 'UTC', empty: '' },
    });

    expect(result.dau).toBe(3);
    expect(fetchMock.mock.calls[0][0]).toBe('/api/admin/overview?from=2026-10-01&to=2026-10-15&tz=UTC');
    expect(headerOf(fetchMock.mock.calls[0], 'Authorization')).toBe('Bearer access-1');
  });

  it('refreshes once on 401 and retries with the new token', async () => {
    setTokens('old', 'r1');
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(json(401, { code: 'ACCESS_TOKEN_EXPIRED' }))
      .mockResolvedValueOnce(json(200, { 'access-token': 'new', 'refresh-token': 'r2' }))
      .mockResolvedValueOnce(json(200, { ok: true }));
    vi.stubGlobal('fetch', fetchMock);

    await apiFetch('/api/admin/me');

    expect(String(fetchMock.mock.calls[1][0])).toBe('/api/authorize/refresh?refresh-token=r1');
    expect(headerOf(fetchMock.mock.calls[2], 'Authorization')).toBe('Bearer new');
    expect(getRefresh()).toBe('r2');
  });

  it('clears session and notifies on failed refresh', async () => {
    setTokens('old', 'r1');
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(401, { code: 'UNAUTHORIZED' }))
        .mockResolvedValueOnce(json(404, { code: 'NOT_FOUND' })),
    );

    await expect(apiFetch('/api/admin/me')).rejects.toMatchObject({ status: 401 });
    expect(getRefresh()).toBeNull();
    expect(onAuthError).toHaveBeenCalledWith(401);
  });

  it('notifies on 403 and exposes server error code', async () => {
    const onAuthError = vi.fn();
    setAuthErrorHandler(onAuthError);
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(json(403, { code: 'FORBIDDEN', message: 'Нет прав' })));

    const error = await apiFetch('/api/admin/overview').catch((e: unknown) => e);

    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ status: 403, code: 'FORBIDDEN', message: 'Нет прав' });
    expect(onAuthError).toHaveBeenCalledWith(403);
  });

  it('does not attach auth or refresh for public calls', async () => {
    setTokens('access-1', 'refresh-1');
    const fetchMock = vi.fn().mockResolvedValue(json(400, { code: 'OTP_INCORRECT' }));
    vi.stubGlobal('fetch', fetchMock);

    await expect(
      apiFetch('/api/authorize/verify-otp', { method: 'POST', body: { otp: '1' }, auth: false }),
    ).rejects.toMatchObject({ status: 400, code: 'OTP_INCORRECT' });
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(headerOf(fetchMock.mock.calls[0], 'Authorization')).toBeUndefined();
  });
});
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd admin && npm test -- src/api`
Expected: FAIL — `Failed to resolve import "./client"`.

- [ ] **Step 3: `admin/src/api/tokens.ts`**

```ts
const REFRESH_KEY = 'pora-admin-refresh';

// Access-токен только в памяти: живёт час и не переживает перезагрузку.
let accessToken: string | null = null;

export function getAccess(): string | null {
  return accessToken;
}

export function getRefresh(): string | null {
  try {
    return localStorage.getItem(REFRESH_KEY);
  } catch {
    return null; // хранилище недоступно (приватный режим, политика сайта)
  }
}

export function setTokens(access: string, refresh: string): void {
  accessToken = access;
  try {
    localStorage.setItem(REFRESH_KEY, refresh);
  } catch {
    // без хранилища сессия просто не переживёт перезагрузку
  }
}

export function clearTokens(): void {
  accessToken = null;
  try {
    localStorage.removeItem(REFRESH_KEY);
  } catch {
    // нечего чистить
  }
}
```

- [ ] **Step 4: `admin/src/api/client.ts`**

```ts
import { clearTokens, getAccess, getRefresh, setTokens } from './tokens';

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string | undefined,
    message: string,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

type Query = Record<string, string | number | undefined>;

interface RequestOptions {
  method?: 'GET' | 'POST';
  query?: Query;
  body?: unknown;
  /** false — публичный вызов: без токена и без refresh. */
  auth?: boolean;
}

type AuthErrorHandler = (status: 401 | 403) => void;

let authErrorHandler: AuthErrorHandler | null = null;
let refreshing: Promise<boolean> | null = null;

/** Реакция приложения на потерю сессии (401) или прав (403). */
export function setAuthErrorHandler(handler: AuthErrorHandler | null): void {
  authErrorHandler = handler;
}

/** Обновляет access-токен; параллельные вызовы делят один запрос. */
export function refreshSession(): Promise<boolean> {
  refreshing ??= doRefresh().finally(() => {
    refreshing = null;
  });
  return refreshing;
}

async function doRefresh(): Promise<boolean> {
  const refresh = getRefresh();
  if (!refresh) return false;
  try {
    // Контракт бэкенда: refresh-токен в query. nginx не логирует /api/authorize/.
    const res = await fetch(`/api/authorize/refresh?${new URLSearchParams({ 'refresh-token': refresh })}`);
    if (!res.ok) {
      clearTokens();
      return false;
    }
    const body = (await res.json()) as { 'access-token': string; 'refresh-token': string };
    setTokens(body['access-token'], body['refresh-token']);
    return true;
  } catch {
    return false;
  }
}

function buildUrl(path: string, query?: Query): string {
  if (!query) return path;
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== '') params.set(key, String(value));
  }
  const search = params.toString();
  return search ? `${path}?${search}` : path;
}

export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = 'GET', query, body, auth = true } = options;

  const send = () => {
    const headers: Record<string, string> = { Accept: 'application/json' };
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    const token = getAccess();
    if (auth && token) headers.Authorization = `Bearer ${token}`;
    return fetch(buildUrl(path, query), {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  };

  let res = await send();
  if (auth && res.status === 401 && (await refreshSession())) {
    res = await send();
  }

  if (!res.ok) {
    const payload = (await res.json().catch(() => ({}))) as { code?: string; message?: string };
    if (auth && (res.status === 401 || res.status === 403)) {
      if (res.status === 401) clearTokens();
      authErrorHandler?.(res.status);
    }
    throw new ApiError(res.status, payload.code, payload.message ?? res.statusText);
  }

  const text = await res.text();
  return (text ? JSON.parse(text) : undefined) as T;
}
```

- [ ] **Step 5: Запусти — должно пройти**

Run: `cd admin && npm test -- src/api && npm run typecheck`
Expected: все тесты `passed`.

- [ ] **Step 6: Commit**

```bash
git add admin/src/api/tokens.ts admin/src/api/client.ts admin/src/api/client.test.ts
git commit -m "feat(admin): API client with token refresh and auth error handling"
```

---

### Task 4: Типы ответов и эндпоинты

**Files:**
- Create: `admin/src/api/types.ts`, `admin/src/api/endpoints.ts`

- [ ] **Step 1: `admin/src/api/types.ts`** (зеркало `backend/internal/dto/responses/admin.go`)

```ts
export interface DayCount {
  date: string;
  count: number;
}

export interface NameCount {
  name: string;
  count: number;
}

export interface TokensResponse {
  'access-token': string;
  'refresh-token': string;
  status?: string;
}

export interface AdminMe {
  id: string;
  name: string;
  surname: string;
  email?: string;
  phone?: string;
}

export interface AdminOverview {
  'total-users': number;
  'new-users': number;
  'new-users-prev': number;
  dau: number;
  wau: number;
  mau: number;
  'items-added': number;
  'items-added-prev': number;
  'items-bought': number;
  'items-bought-prev': number;
}

export interface AdminActiveUsers {
  days: DayCount[];
  wau: number;
  mau: number;
}

export interface AdminSeries {
  days: DayCount[];
}

export interface CohortRow {
  week: string;
  size: number;
  retained: (number | null)[];
}

export interface DayNRetention {
  day: number;
  eligible: number;
  retained: number;
}

export interface AdminRetention {
  cohorts: CohortRow[] | null;
  'day-n': DayNRetention[] | null;
}

export interface AdminFunnel {
  steps: { step: string; users: number }[];
}

export interface AdminFeatures {
  mau: number;
  features: { feature: string; users: number; share: number }[] | null;
}

export interface AdminEventSeries {
  points: { date: string; name: string; count: number }[] | null;
}

export interface AdminTopProducts {
  kind: 'added' | 'bought';
  items: NameCount[] | null;
  'median-hours-to-buy': number | null;
}

export interface AdminSections {
  sections: NameCount[] | null;
}

export interface AdminPlatforms {
  platforms: NameCount[] | null;
  versions: NameCount[] | null;
}

export interface AdminUserRow {
  id: string;
  email: string;
  phone: string;
  name: string;
  surname: string;
  status: string;
  'is-admin': boolean;
  'created-at': string;
  'last-active-at': string | null;
  lists: number;
  items: number;
  families: number;
}

export interface AdminUsersPage {
  users: AdminUserRow[];
  total: number;
  page: number;
  'page-size': number;
}

export interface AdminEvent {
  id: string;
  name: string;
  props: Record<string, unknown>;
  platform: string;
  'app-version': string;
  source: 'server' | 'client';
  'occurred-at': string;
}

export interface AdminUserDetail {
  user: AdminUserRow;
  events: AdminEvent[];
}
```

- [ ] **Step 2: `admin/src/api/endpoints.ts`**

```ts
import { apiFetch } from './client';
import type {
  AdminActiveUsers,
  AdminEventSeries,
  AdminFeatures,
  AdminFunnel,
  AdminMe,
  AdminOverview,
  AdminPlatforms,
  AdminRetention,
  AdminSections,
  AdminSeries,
  AdminTopProducts,
  AdminUserDetail,
  AdminUsersPage,
  TokensResponse,
} from './types';

export interface Period {
  from: string;
  to: string;
  tz: string;
}

export const adminApi = {
  sendOtp: (email: string) =>
    apiFetch<void>('/api/authorize/send-otp', { method: 'POST', body: { email }, auth: false }),

  verifyOtp: (email: string, otp: string) =>
    apiFetch<TokensResponse>('/api/authorize/verify-otp', {
      method: 'POST',
      body: { email, otp, client: 'admin' },
      auth: false,
    }),

  me: () => apiFetch<AdminMe>('/api/admin/me'),
  logout: () => apiFetch<void>('/api/admin/logout', { method: 'POST' }),

  overview: (p: Period) => apiFetch<AdminOverview>('/api/admin/overview', { query: { ...p } }),
  activeUsers: (p: Period) => apiFetch<AdminActiveUsers>('/api/admin/active-users', { query: { ...p } }),
  signups: (p: Period) => apiFetch<AdminSeries>('/api/admin/signups', { query: { ...p } }),
  retention: (p: Period, weeks: number) =>
    apiFetch<AdminRetention>('/api/admin/retention', { query: { ...p, weeks } }),
  funnel: (p: Period) => apiFetch<AdminFunnel>('/api/admin/funnel', { query: { ...p } }),
  features: (p: Period) => apiFetch<AdminFeatures>('/api/admin/features', { query: { ...p } }),
  eventSeries: (p: Period, names: string[]) =>
    apiFetch<AdminEventSeries>('/api/admin/events/timeseries', { query: { ...p, names: names.join(',') } }),
  topProducts: (p: Period, kind: 'added' | 'bought') =>
    apiFetch<AdminTopProducts>('/api/admin/products/top', { query: { ...p, kind, limit: 20 } }),
  sections: (p: Period) => apiFetch<AdminSections>('/api/admin/products/sections', { query: { ...p } }),
  platforms: (p: Period) => apiFetch<AdminPlatforms>('/api/admin/platforms', { query: { ...p } }),

  users: (q: string, page: number) => apiFetch<AdminUsersPage>('/api/admin/users', { query: { q, page } }),
  user: (id: string) => apiFetch<AdminUserDetail>(`/api/admin/users/${encodeURIComponent(id)}`),

  push: (title: string, body: string) =>
    apiFetch<void>('/api/admin/push', { method: 'POST', body: { title, body } }),
};
```

- [ ] **Step 3: Typecheck и commit**

Run: `cd admin && npm run typecheck`
Expected: без вывода.

```bash
git add admin/src/api/types.ts admin/src/api/endpoints.ts
git commit -m "feat(admin): typed admin API endpoints"
```

---

### Task 5: Стили и базовые компоненты

**Files:**
- Modify: `admin/src/styles.css`
- Create: `admin/src/components/ChartCard.tsx`, `KpiTile.tsx`, `BarList.tsx`, `PeriodSwitch.tsx`, `charts.tsx`
- Create: `admin/src/hooks/usePeriod.ts`, `admin/src/hooks/useDebounced.ts`
- Test: `admin/src/components/ChartCard.test.tsx`

- [ ] **Step 1: `admin/src/styles.css`**

```css
:root {
  --bg: #f7f6f4;
  --surface: #ffffff;
  --surface-2: #f1efec;
  --border: #e4e1dc;
  --text: #1d1b19;
  --text-muted: #6b6560;
  --accent: #e07a5f;
  --accent-strong: #c4583d;
  --accent-soft: #fbe9e3;
  --up: #2f855a;
  --down: #c53030;
  --radius: 12px;
  --gap: 16px;
  --font: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --mono: ui-monospace, 'SF Mono', Menlo, monospace;
  color-scheme: light;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: #151413;
    --surface: #1e1c1b;
    --surface-2: #282624;
    --border: #36322f;
    --text: #f2efec;
    --text-muted: #a39d97;
    --accent: #ec9278;
    --accent-strong: #f4a991;
    --accent-soft: #3a2620;
    --up: #68d391;
    --down: #fc8181;
    color-scheme: dark;
  }
}

* { box-sizing: border-box; }

body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font: 14px/1.45 var(--font);
  -webkit-font-smoothing: antialiased;
}

h1 { font-size: 22px; margin: 0 0 var(--gap); letter-spacing: -0.01em; }
h2 { font-size: 15px; margin: 0; font-weight: 600; }
a { color: var(--accent-strong); }

/* Каркас */
.shell { display: grid; grid-template-columns: 220px 1fr; min-height: 100vh; }
.sidebar { background: var(--surface); border-right: 1px solid var(--border); padding: 20px 12px; display: flex; flex-direction: column; gap: 4px; }
.brand { font-weight: 700; font-size: 16px; padding: 4px 12px 16px; }
.nav-link { display: block; padding: 8px 12px; border-radius: 8px; color: var(--text-muted); text-decoration: none; }
.nav-link:hover { background: var(--surface-2); color: var(--text); }
.nav-link.active { background: var(--accent-soft); color: var(--accent-strong); font-weight: 600; }
.sidebar-foot { margin-top: auto; padding: 12px; color: var(--text-muted); font-size: 12px; display: grid; gap: 8px; }
.main { padding: 24px clamp(16px, 3vw, 40px); min-width: 0; }
.topbar { display: flex; justify-content: space-between; align-items: center; gap: var(--gap); flex-wrap: wrap; margin-bottom: 20px; }
.page { display: grid; gap: var(--gap); }
.grid-2 { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 420px), 1fr)); gap: var(--gap); }

@media (max-width: 760px) {
  .shell { grid-template-columns: 1fr; }
  .sidebar { flex-direction: row; overflow-x: auto; border-right: 0; border-bottom: 1px solid var(--border); padding: 8px; }
  .brand, .sidebar-foot { display: none; }
  .nav-link { white-space: nowrap; }
}

/* Карточки и состояния */
.card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 16px; min-width: 0; }
.card-head { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 12px; }
.state { min-height: 120px; display: grid; place-items: center; gap: 8px; color: var(--text-muted); text-align: center; }
.state-error { color: var(--down); }

/* KPI */
.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; }
.kpi { background: var(--surface-2); border-radius: 10px; padding: 12px 14px; }
.kpi-label { color: var(--text-muted); font-size: 12px; }
.kpi-value { font-size: 24px; font-weight: 700; font-variant-numeric: tabular-nums; margin-top: 2px; }
.kpi-foot { display: flex; gap: 8px; align-items: baseline; font-size: 12px; color: var(--text-muted); margin-top: 2px; }
.delta-up { color: var(--up); font-weight: 600; }
.delta-down { color: var(--down); font-weight: 600; }
.delta-flat { color: var(--text-muted); font-weight: 600; }

/* Бар-списки */
.bars { display: grid; gap: 8px; list-style: none; margin: 0; padding: 0; }
.bar-row { display: grid; grid-template-columns: minmax(90px, 34%) 1fr auto; gap: 10px; align-items: center; }
.bar-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.bar-track { background: var(--surface-2); border-radius: 999px; height: 8px; overflow: hidden; }
.bar-fill { background: var(--accent); height: 100%; border-radius: 999px; }
.bar-value { font-variant-numeric: tabular-nums; color: var(--text-muted); min-width: 64px; text-align: right; }

/* Контролы */
.btn { font: inherit; border: 1px solid var(--border); background: var(--surface); color: var(--text); border-radius: 8px; padding: 7px 12px; cursor: pointer; }
.btn:hover:not(:disabled) { border-color: var(--accent); }
.btn:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-primary { background: var(--accent); border-color: var(--accent); color: #fff; }
.btn-primary:hover:not(:disabled) { background: var(--accent-strong); }
.btn-danger { background: var(--down); border-color: var(--down); color: #fff; }
.segmented { display: inline-flex; background: var(--surface-2); border-radius: 9px; padding: 3px; gap: 2px; }
.segmented button { font: inherit; border: 0; background: transparent; color: var(--text-muted); padding: 5px 12px; border-radius: 7px; cursor: pointer; }
.segmented button[aria-pressed='true'] { background: var(--surface); color: var(--text); font-weight: 600; box-shadow: 0 1px 2px rgb(0 0 0 / 0.08); }
.chips { display: flex; flex-wrap: wrap; gap: 6px; }
.chip { font: inherit; font-size: 12px; border: 1px solid var(--border); background: var(--surface); color: var(--text-muted); border-radius: 999px; padding: 3px 10px; cursor: pointer; }
.chip[aria-pressed='true'] { border-color: var(--accent); color: var(--accent-strong); background: var(--accent-soft); }
.field { display: grid; gap: 6px; }
.field span { font-size: 12px; color: var(--text-muted); }
.input { font: inherit; width: 100%; padding: 9px 12px; border: 1px solid var(--border); border-radius: 8px; background: var(--surface); color: var(--text); }
.input:focus { outline: 2px solid var(--accent-soft); border-color: var(--accent); }
textarea.input { resize: vertical; min-height: 96px; }

/* Таблицы */
.table-wrap { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; font-variant-numeric: tabular-nums; }
th, td { text-align: left; padding: 8px 10px; border-bottom: 1px solid var(--border); white-space: nowrap; }
th { font-size: 12px; color: var(--text-muted); font-weight: 600; }
tbody tr.clickable { cursor: pointer; }
tbody tr.clickable:hover { background: var(--surface-2); }
.heat { text-align: center; border-radius: 4px; }
.muted { color: var(--text-muted); }
.mono { font-family: var(--mono); font-size: 12px; }
.badge { display: inline-block; font-size: 11px; padding: 1px 8px; border-radius: 999px; background: var(--accent-soft); color: var(--accent-strong); }
.pager { display: flex; gap: 8px; align-items: center; justify-content: flex-end; margin-top: 12px; }

/* Логин */
.center { min-height: 100vh; display: grid; place-items: center; padding: 16px; }
.login { width: min(100%, 380px); display: grid; gap: 14px; }
.error-text { color: var(--down); margin: 0; }
.success-text { color: var(--up); margin: 0; }

/* Push-превью */
.push-preview { background: var(--surface-2); border-radius: 14px; padding: 12px 14px; max-width: 360px; }
.push-preview strong { display: block; }
```

- [ ] **Step 2: Хуки**

`admin/src/hooks/usePeriod.ts`:

```ts
import { useMemo } from 'react';
import { useSearchParams } from 'react-router-dom';
import type { Period } from '../api/endpoints';
import { periodRange } from '../lib/format';

export const PERIODS = [7, 30, 90] as const;
const DEFAULT_DAYS = 30;

function browserTimeZone(): string {
  return Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
}

/** Период из `?days=` (7/30/90), таймзона — браузерная. */
export function usePeriod() {
  const [params, setParams] = useSearchParams();
  const raw = Number(params.get('days'));
  const days = (PERIODS as readonly number[]).includes(raw) ? raw : DEFAULT_DAYS;
  const tz = browserTimeZone();
  const { from, to } = periodRange(days, new Date(), tz);

  const period = useMemo<Period>(() => ({ from, to, tz }), [from, to, tz]);

  const setDays = (next: number) =>
    setParams(
      (prev) => {
        const updated = new URLSearchParams(prev);
        updated.set('days', String(next));
        return updated;
      },
      { replace: true },
    );

  return { days, setDays, period };
}
```

`admin/src/hooks/useDebounced.ts`:

```ts
import { useEffect, useState } from 'react';

export function useDebounced<T>(value: T, delayMs = 300): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timer);
  }, [value, delayMs]);
  return debounced;
}
```

- [ ] **Step 3: Падающий тест `ChartCard`**

`admin/src/components/ChartCard.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { UseQueryResult } from '@tanstack/react-query';
import { describe, expect, it, vi } from 'vitest';
import { ApiError } from '../api/client';
import { ChartCard } from './ChartCard';

const query = (partial: Partial<UseQueryResult<number[]>>) =>
  ({ isPending: false, isError: false, data: undefined, error: null, refetch: vi.fn(), ...partial }) as UseQueryResult<number[]>;

describe('ChartCard', () => {
  it('shows loading', () => {
    render(<ChartCard title="T" query={query({ isPending: true })}>{() => 'data'}</ChartCard>);
    expect(screen.getByText('Загрузка…')).toBeInTheDocument();
  });

  it('shows error with retry', async () => {
    const refetch = vi.fn();
    render(
      <ChartCard title="T" query={query({ isError: true, error: new ApiError(500, 'INTERNAL_ERROR', 'x'), refetch })}>
        {() => 'data'}
      </ChartCard>,
    );
    expect(screen.getByRole('alert')).toHaveTextContent('Сервер недоступен');
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));
    expect(refetch).toHaveBeenCalled();
  });

  it('shows empty state and data', () => {
    const { rerender } = render(
      <ChartCard title="T" query={query({ data: [] })} isEmpty={(d) => d.length === 0}>
        {(d) => `items: ${d.length}`}
      </ChartCard>,
    );
    expect(screen.getByText('Нет данных за период')).toBeInTheDocument();

    rerender(
      <ChartCard title="T" query={query({ data: [1, 2] })} isEmpty={(d) => d.length === 0}>
        {(d) => `items: ${d.length}`}
      </ChartCard>,
    );
    expect(screen.getByText('items: 2')).toBeInTheDocument();
  });
});
```

Run: `cd admin && npm test -- src/components` → Expected: FAIL — `Failed to resolve import "./ChartCard"`.

- [ ] **Step 4: Компоненты**

`admin/src/components/ChartCard.tsx`:

```tsx
import type { UseQueryResult } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { ApiError } from '../api/client';

interface Props<T> {
  title: string;
  query: UseQueryResult<T>;
  isEmpty?: (data: T) => boolean;
  action?: ReactNode;
  children: (data: T) => ReactNode;
}

function errorText(error: unknown): string {
  if (error instanceof ApiError) {
    return error.status >= 500 ? 'Сервер недоступен' : error.message;
  }
  return 'Нет связи с сервером';
}

/** Карточка блока с независимыми состояниями: загрузка / ошибка / пусто / данные. */
export function ChartCard<T>({ title, query, isEmpty, action, children }: Props<T>) {
  let body: ReactNode;
  if (query.isPending) {
    body = (
      <div className="state" aria-busy="true">
        Загрузка…
      </div>
    );
  } else if (query.isError) {
    body = (
      <div className="state state-error" role="alert">
        <p>{errorText(query.error)}</p>
        <button type="button" className="btn" onClick={() => void query.refetch()}>
          Повторить
        </button>
      </div>
    );
  } else if (query.data === undefined || isEmpty?.(query.data)) {
    body = <div className="state">Нет данных за период</div>;
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
```

`admin/src/components/KpiTile.tsx`:

```tsx
import type { Delta } from '../lib/format';

interface Props {
  label: string;
  value: string;
  delta?: Delta | null;
  hint?: string;
}

export function KpiTile({ label, value, delta, hint }: Props) {
  return (
    <div className="kpi">
      <div className="kpi-label">{label}</div>
      <div className="kpi-value">{value}</div>
      {(delta || hint) && (
        <div className="kpi-foot">
          {delta && <span className={`delta-${delta.trend}`}>{delta.text}</span>}
          {hint && <span>{hint}</span>}
        </div>
      )}
    </div>
  );
}
```

`admin/src/components/BarList.tsx`:

```tsx
export interface BarItem {
  name: string;
  value: number;
  /** Подпись справа; по умолчанию — само значение. */
  display?: string;
}

/** Горизонтальные доли: ширина бара — доля от максимума. */
export function BarList({ items }: { items: BarItem[] }) {
  const max = Math.max(0, ...items.map((item) => item.value));
  return (
    <ul className="bars">
      {items.map((item) => (
        <li key={item.name} className="bar-row">
          <span className="bar-name" title={item.name}>
            {item.name}
          </span>
          <span className="bar-track" aria-hidden="true">
            <span className="bar-fill" style={{ display: 'block', width: `${max === 0 ? 0 : (item.value / max) * 100}%` }} />
          </span>
          <span className="bar-value">{item.display ?? item.value}</span>
        </li>
      ))}
    </ul>
  );
}
```

`admin/src/components/PeriodSwitch.tsx`:

```tsx
import { PERIODS } from '../hooks/usePeriod';

interface Props {
  value: number;
  onChange: (days: number) => void;
}

export function PeriodSwitch({ value, onChange }: Props) {
  return (
    <div className="segmented" role="group" aria-label="Период">
      {PERIODS.map((days) => (
        <button key={days} type="button" aria-pressed={value === days} onClick={() => onChange(days)}>
          {days} дней
        </button>
      ))}
    </div>
  );
}
```

`admin/src/components/charts.tsx`:

```tsx
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { DayCount } from '../api/types';
import { formatDay } from '../lib/format';
import type { PivotRow } from '../lib/series';

// Палитра серий: акцент + приглушённые нейтрали, различимые в обеих темах.
export const SERIES_COLORS = ['#e07a5f', '#3d7ea6', '#81b29a', '#f2cc8f', '#8d6a9f', '#6b6560'];

const axis = { stroke: 'var(--text-muted)', fontSize: 12 };
const tooltipStyle = {
  background: 'var(--surface)',
  border: '1px solid var(--border)',
  borderRadius: 8,
  color: 'var(--text)',
};

export function DailyLine({ data, label }: { data: DayCount[]; label: string }) {
  return (
    <ResponsiveContainer width="100%" height={240}>
      <LineChart data={data} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
        <CartesianGrid stroke="var(--border)" vertical={false} />
        <XAxis dataKey="date" tickFormatter={formatDay} {...axis} />
        <YAxis allowDecimals={false} {...axis} />
        <Tooltip contentStyle={tooltipStyle} labelFormatter={(d) => formatDay(String(d))} />
        <Line type="monotone" dataKey="count" name={label} stroke="var(--accent)" strokeWidth={2} dot={false} />
      </LineChart>
    </ResponsiveContainer>
  );
}

export function DailyBars({ data, label }: { data: DayCount[]; label: string }) {
  return (
    <ResponsiveContainer width="100%" height={240}>
      <BarChart data={data} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
        <CartesianGrid stroke="var(--border)" vertical={false} />
        <XAxis dataKey="date" tickFormatter={formatDay} {...axis} />
        <YAxis allowDecimals={false} {...axis} />
        <Tooltip contentStyle={tooltipStyle} labelFormatter={(d) => formatDay(String(d))} />
        <Bar dataKey="count" name={label} fill="var(--accent)" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}

export function StackedEvents({ rows, names, labels }: { rows: PivotRow[]; names: string[]; labels: Record<string, string> }) {
  return (
    <ResponsiveContainer width="100%" height={280}>
      <AreaChart data={rows} margin={{ top: 8, right: 8, bottom: 0, left: -16 }}>
        <CartesianGrid stroke="var(--border)" vertical={false} />
        <XAxis dataKey="date" tickFormatter={formatDay} {...axis} />
        <YAxis allowDecimals={false} {...axis} />
        <Tooltip contentStyle={tooltipStyle} labelFormatter={(d) => formatDay(String(d))} />
        <Legend />
        {names.map((name, index) => (
          <Area
            key={name}
            type="monotone"
            dataKey={name}
            name={labels[name] ?? name}
            stackId="events"
            stroke={SERIES_COLORS[index % SERIES_COLORS.length]}
            fill={SERIES_COLORS[index % SERIES_COLORS.length]}
            fillOpacity={0.35}
          />
        ))}
      </AreaChart>
    </ResponsiveContainer>
  );
}
```

- [ ] **Step 5: Тесты и typecheck**

Run: `cd admin && npm test && npm run typecheck`
Expected: все тесты `passed`, typecheck без вывода.

- [ ] **Step 6: Commit**

```bash
git add admin/src/styles.css admin/src/components admin/src/hooks
git commit -m "feat(admin): design tokens, cards, KPI tiles, bar lists and charts"
```

---

### Task 6: Сессия, логин, каркас приложения

**Files:**
- Create: `admin/src/auth/AuthContext.tsx`
- Create: `admin/src/pages/LoginPage.tsx`, `admin/src/pages/ForbiddenPage.tsx`
- Create: `admin/src/components/Layout.tsx`
- Modify: `admin/src/App.tsx`
- Create: `admin/src/pages/OverviewPage.tsx` (заглушка; полностью — Task 7)
- Test: `admin/src/pages/LoginPage.test.tsx`

- [ ] **Step 1: `admin/src/auth/AuthContext.tsx`**

```tsx
import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { ApiError, setAuthErrorHandler } from '../api/client';
import { adminApi } from '../api/endpoints';
import { clearTokens, getRefresh, setTokens } from '../api/tokens';
import type { AdminMe } from '../api/types';

export type AuthStatus = 'checking' | 'signedOut' | 'signedIn' | 'forbidden';

interface AuthValue {
  status: AuthStatus;
  me: AdminMe | null;
  signIn: (email: string, otp: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthValue | null>(null);

export function AuthProvider({ children, onSignOut }: { children: ReactNode; onSignOut?: () => void }) {
  const [status, setStatus] = useState<AuthStatus>('checking');
  const [me, setMe] = useState<AdminMe | null>(null);

  const loadMe = useCallback(async () => {
    try {
      setMe(await adminApi.me());
      setStatus('signedIn');
    } catch (error) {
      if (error instanceof ApiError && error.status === 403) {
        setStatus('forbidden');
      } else {
        clearTokens();
        setStatus('signedOut');
      }
    }
  }, []);

  useEffect(() => {
    // Потеря сессии/прав посреди работы → логин или «нет доступа».
    setAuthErrorHandler((code) => setStatus(code === 403 ? 'forbidden' : 'signedOut'));
    if (getRefresh()) void loadMe();
    else setStatus('signedOut');
    return () => setAuthErrorHandler(null);
  }, [loadMe]);

  const signIn = useCallback(
    async (email: string, otp: string) => {
      const tokens = await adminApi.verifyOtp(email, otp);
      setTokens(tokens['access-token'], tokens['refresh-token']);
      await loadMe();
    },
    [loadMe],
  );

  const signOut = useCallback(async () => {
    try {
      await adminApi.logout();
    } catch {
      // сессия могла уже истечь — локальный выход всё равно выполняем
    }
    clearTokens();
    setMe(null);
    setStatus('signedOut');
    onSignOut?.();
  }, [onSignOut]);

  const value = useMemo(() => ({ status, me, signIn, signOut }), [status, me, signIn, signOut]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthValue {
  const value = useContext(AuthContext);
  if (!value) throw new Error('useAuth вне AuthProvider');
  return value;
}
```

- [ ] **Step 2: Падающий тест логина**

`admin/src/pages/LoginPage.test.tsx`:

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { AuthProvider } from '../auth/AuthContext';
import { LoginPage } from './LoginPage';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

function renderLogin() {
  return render(
    <AuthProvider>
      <LoginPage />
    </AuthProvider>,
  );
}

describe('LoginPage', () => {
  it('requests code, then verifies with client=admin', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(json(200, {}))
      .mockResolvedValueOnce(json(200, { 'access-token': 'a', 'refresh-token': 'r' }))
      .mockResolvedValueOnce(json(200, { id: '1', name: 'Борис', surname: '' }));
    vi.stubGlobal('fetch', fetchMock);
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'boss@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    await userEvent.type(await screen.findByLabelText('Код из письма'), '123456');
    await userEvent.click(screen.getByRole('button', { name: 'Войти' }));

    await vi.waitFor(() => expect(fetchMock).toHaveBeenCalledTimes(3));
    const verifyBody = JSON.parse((fetchMock.mock.calls[1][1] as RequestInit).body as string);
    expect(verifyBody).toEqual({ email: 'boss@mail.ru', otp: '123456', client: 'admin' });
  });

  it('explains missing admin rights', async () => {
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(json(200, {}))
        .mockResolvedValueOnce(json(403, { code: 'FORBIDDEN', message: 'нет прав' })),
    );
    renderLogin();

    await userEvent.type(await screen.findByLabelText('Почта'), 'user@mail.ru');
    await userEvent.click(screen.getByRole('button', { name: 'Получить код' }));
    await userEvent.type(await screen.findByLabelText('Код из письма'), '123456');
    await userEvent.click(screen.getByRole('button', { name: 'Войти' }));

    expect(await screen.findByText('У этой почты нет прав администратора')).toBeInTheDocument();
  });
});
```

Run: `cd admin && npm test -- src/pages` → Expected: FAIL — `Failed to resolve import "./LoginPage"`.

- [ ] **Step 3: `admin/src/pages/LoginPage.tsx`**

```tsx
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
        <button type="submit" className="btn btn-primary" disabled={busy}>
          {step === 'email' ? 'Получить код' : 'Войти'}
        </button>
        {step === 'code' && (
          <button type="button" className="btn" disabled={busy} onClick={() => setStep('email')}>
            Другая почта
          </button>
        )}
      </form>
    </main>
  );
}
```

- [ ] **Step 4: `admin/src/pages/ForbiddenPage.tsx`**

```tsx
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
```

- [ ] **Step 5: `admin/src/components/Layout.tsx`**

```tsx
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
```

- [ ] **Step 6: Заглушки экранов и `App.tsx`**

Создай заглушки (каждая заменяется полной версией в Tasks 7–10), по одной на файл: `admin/src/pages/OverviewPage.tsx`, `RetentionPage.tsx`, `EngagementPage.tsx`, `ProductsPage.tsx`, `PlatformsPage.tsx`, `UsersPage.tsx`, `UserDetailPage.tsx`, `PushPage.tsx`. Шаблон (имя функции = имя файла, заголовок — по разделу):

```tsx
export function OverviewPage() {
  return <h1>Обзор</h1>;
}
```

Замени `admin/src/App.tsx`:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { Layout } from './components/Layout';
import { EngagementPage } from './pages/EngagementPage';
import { ForbiddenPage } from './pages/ForbiddenPage';
import { LoginPage } from './pages/LoginPage';
import { OverviewPage } from './pages/OverviewPage';
import { PlatformsPage } from './pages/PlatformsPage';
import { ProductsPage } from './pages/ProductsPage';
import { PushPage } from './pages/PushPage';
import { RetentionPage } from './pages/RetentionPage';
import { UserDetailPage } from './pages/UserDetailPage';
import { UsersPage } from './pages/UsersPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: 1, staleTime: 60_000, refetchOnWindowFocus: false },
  },
});

function AppRoutes() {
  const { status } = useAuth();
  if (status === 'checking') {
    return (
      <main className="center" aria-busy="true">
        Загрузка…
      </main>
    );
  }
  if (status === 'signedOut') return <LoginPage />;
  if (status === 'forbidden') return <ForbiddenPage />;

  return (
    <Routes>
      <Route element={<Layout />}>
        <Route index element={<OverviewPage />} />
        <Route path="retention" element={<RetentionPage />} />
        <Route path="engagement" element={<EngagementPage />} />
        <Route path="products" element={<ProductsPage />} />
        <Route path="platforms" element={<PlatformsPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="users/:id" element={<UserDetailPage />} />
        <Route path="push" element={<PushPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Route>
    </Routes>
  );
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AuthProvider onSignOut={() => queryClient.clear()}>
          <AppRoutes />
        </AuthProvider>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
```

- [ ] **Step 7: Тесты, typecheck, commit**

Run: `cd admin && npm test && npm run typecheck && npm run build`
Expected: всё зелёное.

```bash
git add admin/src
git commit -m "feat(admin): OTP login, session handling and app shell"
```

---

### Task 7: Обзор и Retention

**Files:**
- Modify: `admin/src/pages/OverviewPage.tsx`, `admin/src/pages/RetentionPage.tsx`
- Test: `admin/src/pages/OverviewPage.test.tsx`

- [ ] **Step 1: Падающий тест обзора**

`admin/src/pages/OverviewPage.test.tsx`:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it, vi } from 'vitest';
import { OverviewPage } from './OverviewPage';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

const overview = {
  'total-users': 120,
  'new-users': 12,
  'new-users-prev': 10,
  dau: 9,
  wau: 15,
  mau: 20,
  'items-added': 40,
  'items-added-prev': 50,
  'items-bought': 30,
  'items-bought-prev': 30,
};

function renderPage() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter initialEntries={['/?days=7']}>
        <OverviewPage />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe('OverviewPage', () => {
  it('renders KPIs with deltas and passes the period', async () => {
    const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      if (url.startsWith('/api/admin/overview')) return json(200, overview);
      if (url.startsWith('/api/admin/active-users')) {
        return json(200, { days: [{ date: '2026-10-15', count: 9 }], wau: 15, mau: 20 });
      }
      return json(200, { days: [{ date: '2026-10-15', count: 2 }] });
    });
    vi.stubGlobal('fetch', fetchMock);

    renderPage();

    expect(await screen.findByText('120')).toBeInTheDocument();
    expect(screen.getByText('+20%')).toBeInTheDocument();
    expect(screen.getByText('−20%')).toBeInTheDocument();
    expect(screen.getByText('45,0%')).toBeInTheDocument();

    const overviewUrl = String(fetchMock.mock.calls.find(([u]) => String(u).includes('overview'))?.[0]);
    expect(overviewUrl).toMatch(/from=\d{4}-\d{2}-\d{2}&to=\d{4}-\d{2}-\d{2}&tz=/);
  });

  it('retries a failed block independently', async () => {
    let overviewCalls = 0;
    vi.stubGlobal(
      'fetch',
      vi.fn(async (input: RequestInfo | URL) => {
        const url = String(input);
        if (url.startsWith('/api/admin/overview')) {
          overviewCalls += 1;
          return overviewCalls === 1 ? json(500, { code: 'INTERNAL_ERROR' }) : json(200, overview);
        }
        return json(200, { days: [], wau: 0, mau: 0 });
      }),
    );

    renderPage();

    expect(await screen.findByText('Сервер недоступен')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button', { name: 'Повторить' }));
    expect(await screen.findByText('120')).toBeInTheDocument();
  });
});
```

Run: `cd admin && npm test -- OverviewPage` → Expected: FAIL (заглушка не рендерит KPI).

- [ ] **Step 2: `admin/src/pages/OverviewPage.tsx`**

```tsx
import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { DailyBars, DailyLine } from '../components/charts';
import { KpiTile } from '../components/KpiTile';
import { usePeriod } from '../hooks/usePeriod';
import { formatDelta, formatNumber, formatPercent, ratio } from '../lib/format';

export function OverviewPage() {
  const { period } = usePeriod();
  const overview = useQuery({ queryKey: ['overview', period], queryFn: () => adminApi.overview(period) });
  const active = useQuery({ queryKey: ['active-users', period], queryFn: () => adminApi.activeUsers(period) });
  const signups = useQuery({ queryKey: ['signups', period], queryFn: () => adminApi.signups(period) });

  return (
    <div className="page">
      <h1>Обзор</h1>

      <ChartCard title="Ключевые метрики" query={overview}>
        {(o) => (
          <div className="kpi-grid">
            <KpiTile label="Всего пользователей" value={formatNumber(o['total-users'])} />
            <KpiTile
              label="Новые за период"
              value={formatNumber(o['new-users'])}
              delta={formatDelta(o['new-users'], o['new-users-prev'])}
            />
            <KpiTile label="DAU" value={formatNumber(o.dau)} hint="последний день" />
            <KpiTile label="WAU" value={formatNumber(o.wau)} />
            <KpiTile label="MAU" value={formatNumber(o.mau)} />
            <KpiTile label="Stickiness" value={formatPercent(ratio(o.dau, o.mau))} hint="DAU / MAU" />
            <KpiTile
              label="Добавлено товаров"
              value={formatNumber(o['items-added'])}
              delta={formatDelta(o['items-added'], o['items-added-prev'])}
            />
            <KpiTile
              label="Куплено товаров"
              value={formatNumber(o['items-bought'])}
              delta={formatDelta(o['items-bought'], o['items-bought-prev'])}
            />
          </div>
        )}
      </ChartCard>

      <div className="grid-2">
        <ChartCard title="Активные пользователи" query={active} isEmpty={(a) => a.days.every((d) => d.count === 0)}>
          {(a) => <DailyLine data={a.days} label="DAU" />}
        </ChartCard>
        <ChartCard title="Регистрации" query={signups} isEmpty={(s) => s.days.every((d) => d.count === 0)}>
          {(s) => <DailyBars data={s.days} label="Регистрации" />}
        </ChartCard>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: `admin/src/pages/RetentionPage.tsx`**

```tsx
import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { KpiTile } from '../components/KpiTile';
import { usePeriod } from '../hooks/usePeriod';
import { formatDay, formatPercent, ratio } from '../lib/format';

const WEEKS = 8;

function heatStyle(value: number | null) {
  if (value === null) return undefined;
  return { background: `color-mix(in srgb, var(--accent) ${Math.round(value)}%, transparent)` };
}

export function RetentionPage() {
  const { period } = usePeriod();
  const retention = useQuery({
    queryKey: ['retention', period, WEEKS],
    queryFn: () => adminApi.retention(period, WEEKS),
  });

  return (
    <div className="page">
      <h1>Retention</h1>

      <ChartCard title="Возврат на день N" query={retention} isEmpty={(r) => (r['day-n'] ?? []).length === 0}>
        {(r) => (
          <div className="kpi-grid">
            {(r['day-n'] ?? []).map((d) => (
              <KpiTile
                key={d.day}
                label={`D${d.day}`}
                value={d.eligible === 0 ? '—' : formatPercent(ratio(d.retained, d.eligible))}
                hint={`${d.retained} из ${d.eligible}`}
              />
            ))}
          </div>
        )}
      </ChartCard>

      <ChartCard
        title={`Недельные когорты (последние ${WEEKS} недель)`}
        query={retention}
        isEmpty={(r) => (r.cohorts ?? []).length === 0}
      >
        {(r) => (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Неделя регистрации</th>
                  <th>Юзеров</th>
                  {Array.from({ length: WEEKS + 1 }, (_, n) => (
                    <th key={n}>Нед. {n}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {(r.cohorts ?? []).map((cohort) => (
                  <tr key={cohort.week}>
                    <td>с {formatDay(cohort.week)}</td>
                    <td>{cohort.size}</td>
                    {cohort.retained.map((value, n) => (
                      <td key={n} className="heat" style={heatStyle(value)}>
                        {value === null ? '' : formatPercent(value, 0)}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </ChartCard>
      <p className="muted">Активность — вход в приложение или любое событие. Неделя 0 — неделя регистрации (100%).</p>
    </div>
  );
}
```

- [ ] **Step 4: Тесты, typecheck, commit**

Run: `cd admin && npm test && npm run typecheck`
Expected: всё зелёное.

```bash
git add admin/src/pages/OverviewPage.tsx admin/src/pages/OverviewPage.test.tsx admin/src/pages/RetentionPage.tsx
git commit -m "feat(admin): overview KPIs/charts and retention cohorts"
```

---

### Task 8: Вовлечённость, товары, платформы

**Files:**
- Modify: `admin/src/pages/EngagementPage.tsx`, `ProductsPage.tsx`, `PlatformsPage.tsx`
- Create: `admin/src/lib/labels.ts`

- [ ] **Step 1: `admin/src/lib/labels.ts`**

```ts
export const EVENT_LABELS: Record<string, string> = {
  user_signed_up: 'Регистрация',
  list_created: 'Список создан',
  item_added: 'Товар добавлен',
  item_bought: 'Товар куплен',
  item_deleted: 'Товар удалён',
  family_created: 'Семья создана',
  family_joined: 'Вступление в семью',
  session_start: 'Сессия',
  screen_view: 'Экран',
  ai_chat_opened: 'AI-чат открыт',
  ai_message_sent: 'AI-сообщение',
  ai_tip_generated: 'AI-совет',
  recipe_import: 'Импорт рецепта',
  support_message_sent: 'Поддержка',
  view_mode_changed: 'Режим отображения',
};

export const FUNNEL_LABELS: Record<string, string> = {
  signed_up: 'Зарегистрировались',
  created_list: 'Создали список',
  added_item: 'Добавили товар',
  bought_item: 'Купили товар',
  joined_family: 'В семье',
};

export const FEATURE_LABELS: Record<string, string> = {
  ai_chat: 'AI-чат',
  recipes: 'Импорт рецептов',
  families: 'Семьи',
};

export const PLATFORM_LABELS: Record<string, string> = {
  ios: 'iOS',
  android: 'Android',
};
```

- [ ] **Step 2: `admin/src/pages/EngagementPage.tsx`**

```tsx
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { adminApi } from '../api/endpoints';
import { BarList } from '../components/BarList';
import { ChartCard } from '../components/ChartCard';
import { StackedEvents } from '../components/charts';
import { usePeriod } from '../hooks/usePeriod';
import { daysInRange, formatPercent, ratio } from '../lib/format';
import { EVENT_LABELS, FEATURE_LABELS, FUNNEL_LABELS } from '../lib/labels';
import { pivotEvents } from '../lib/series';

const DEFAULT_EVENTS = ['session_start', 'item_added', 'item_bought', 'ai_message_sent', 'recipe_import'];

export function EngagementPage() {
  const { period } = usePeriod();
  const [selected, setSelected] = useState<string[]>(DEFAULT_EVENTS);

  const funnel = useQuery({ queryKey: ['funnel', period], queryFn: () => adminApi.funnel(period) });
  const features = useQuery({ queryKey: ['features', period], queryFn: () => adminApi.features(period) });
  const events = useQuery({
    queryKey: ['events', period, selected],
    queryFn: () => adminApi.eventSeries(period, selected),
    enabled: selected.length > 0,
  });

  const toggle = (name: string) =>
    setSelected((current) => (current.includes(name) ? current.filter((n) => n !== name) : [...current, name]));

  return (
    <div className="page">
      <h1>Вовлечённость</h1>

      <div className="grid-2">
        <ChartCard title="Активация зарегистрированных за период" query={funnel} isEmpty={(f) => f.steps[0]?.users === 0}>
          {(f) => {
            const base = f.steps[0]?.users ?? 0;
            return (
              <BarList
                items={f.steps.map((s) => ({
                  name: FUNNEL_LABELS[s.step] ?? s.step,
                  value: s.users,
                  display: `${s.users} · ${formatPercent(ratio(s.users, base), 0)}`,
                }))}
              />
            );
          }}
        </ChartCard>

        <ChartCard title="Использование функций (доля MAU)" query={features} isEmpty={(f) => f.mau === 0}>
          {(f) => (
            <BarList
              items={(f.features ?? []).map((item) => ({
                name: FEATURE_LABELS[item.feature] ?? item.feature,
                value: item.share,
                display: `${formatPercent(item.share)} · ${item.users}`,
              }))}
            />
          )}
        </ChartCard>
      </div>

      <ChartCard
        title="События по дням"
        query={events}
        isEmpty={(e) => (e.points ?? []).length === 0}
        action={
          <div className="chips" role="group" aria-label="События">
            {Object.keys(EVENT_LABELS).map((name) => (
              <button
                key={name}
                type="button"
                className="chip"
                aria-pressed={selected.includes(name)}
                onClick={() => toggle(name)}
              >
                {EVENT_LABELS[name]}
              </button>
            ))}
          </div>
        }
      >
        {(e) => (
          <StackedEvents
            rows={pivotEvents(e.points ?? [], daysInRange(period.from, period.to), selected)}
            names={selected}
            labels={EVENT_LABELS}
          />
        )}
      </ChartCard>
      <p className="muted">Воронка нестрогая: каждый шаг — юзеры, у которых было это действие, независимо от предыдущих.</p>
    </div>
  );
}
```

При `selected.length === 0` запрос выключен (`enabled: false`) и TanStack держит `isPending: true` — карточка покажет «Загрузка…». Это допустимо; если хочется «Выберите события» — добавь проверку `selected.length === 0` перед `ChartCard` (не обязательно).

- [ ] **Step 3: `admin/src/pages/ProductsPage.tsx`**

```tsx
import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { BarList } from '../components/BarList';
import { ChartCard } from '../components/ChartCard';
import { KpiTile } from '../components/KpiTile';
import { usePeriod } from '../hooks/usePeriod';

function formatHours(hours: number | null): string {
  if (hours === null) return '—';
  if (hours < 48) return `${hours.toFixed(1).replace('.', ',')} ч`;
  return `${(hours / 24).toFixed(1).replace('.', ',')} дн`;
}

export function ProductsPage() {
  const { period } = usePeriod();
  const added = useQuery({ queryKey: ['top', period, 'added'], queryFn: () => adminApi.topProducts(period, 'added') });
  const bought = useQuery({ queryKey: ['top', period, 'bought'], queryFn: () => adminApi.topProducts(period, 'bought') });
  const sections = useQuery({ queryKey: ['sections', period], queryFn: () => adminApi.sections(period) });

  return (
    <div className="page">
      <h1>Товары</h1>

      <ChartCard title="Скорость покупки" query={bought}>
        {(b) => (
          <div className="kpi-grid">
            <KpiTile
              label="Медиана «добавлено → куплено»"
              value={formatHours(b['median-hours-to-buy'])}
              hint="по купленным за период"
            />
          </div>
        )}
      </ChartCard>

      <div className="grid-2">
        <ChartCard title="Чаще всего добавляют" query={added} isEmpty={(a) => (a.items ?? []).length === 0}>
          {(a) => <BarList items={(a.items ?? []).map((i) => ({ name: i.name, value: i.count }))} />}
        </ChartCard>
        <ChartCard title="Чаще всего покупают" query={bought} isEmpty={(b) => (b.items ?? []).length === 0}>
          {(b) => <BarList items={(b.items ?? []).map((i) => ({ name: i.name, value: i.count }))} />}
        </ChartCard>
      </div>

      <ChartCard title="Секции добавленных товаров" query={sections} isEmpty={(s) => (s.sections ?? []).length === 0}>
        {(s) => (
          <BarList items={(s.sections ?? []).map((i) => ({ name: i.name || 'Без секции', value: i.count }))} />
        )}
      </ChartCard>
      <p className="muted">Названия нормализованы (нижний регистр). Данные — с момента включения серверной аналитики.</p>
    </div>
  );
}
```

- [ ] **Step 4: `admin/src/pages/PlatformsPage.tsx`**

```tsx
import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../api/endpoints';
import { BarList } from '../components/BarList';
import { ChartCard } from '../components/ChartCard';
import { usePeriod } from '../hooks/usePeriod';
import { PLATFORM_LABELS } from '../lib/labels';

export function PlatformsPage() {
  const { period } = usePeriod();
  const platforms = useQuery({ queryKey: ['platforms', period], queryFn: () => adminApi.platforms(period) });

  return (
    <div className="page">
      <h1>Платформы и версии</h1>
      <div className="grid-2">
        <ChartCard
          title="Устройства (за всё время)"
          query={platforms}
          isEmpty={(p) => (p.platforms ?? []).length === 0}
        >
          {(p) => (
            <BarList
              items={(p.platforms ?? []).map((i) => ({ name: PLATFORM_LABELS[i.name] ?? i.name, value: i.count }))}
            />
          )}
        </ChartCard>
        <ChartCard
          title="Версии приложения у активных за период"
          query={platforms}
          isEmpty={(p) => (p.versions ?? []).length === 0}
        >
          {(p) => <BarList items={(p.versions ?? []).map((i) => ({ name: i.name, value: i.count }))} />}
        </ChartCard>
      </div>
    </div>
  );
}
```

- [ ] **Step 5: Typecheck, тесты, commit**

Run: `cd admin && npm run typecheck && npm test`
Expected: всё зелёное.

```bash
git add admin/src/lib/labels.ts admin/src/pages/EngagementPage.tsx admin/src/pages/ProductsPage.tsx admin/src/pages/PlatformsPage.tsx
git commit -m "feat(admin): engagement funnel/features/events, products and platforms"
```

---

### Task 9: Пользователи и карточка пользователя

**Files:**
- Modify: `admin/src/pages/UsersPage.tsx`, `admin/src/pages/UserDetailPage.tsx`

- [ ] **Step 1: `admin/src/pages/UsersPage.tsx`**

```tsx
import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminApi } from '../api/endpoints';
import type { AdminUserRow } from '../api/types';
import { ChartCard } from '../components/ChartCard';
import { useDebounced } from '../hooks/useDebounced';
import { formatDateTime } from '../lib/format';

const TZ = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';

export function displayName(user: AdminUserRow): string {
  const full = `${user.name} ${user.surname}`.trim();
  return full || user.email || user.phone || user.id;
}

export function UsersPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const query = useDebounced(search.trim());

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
        <input className="input" type="search" value={search} onChange={(e) => onSearch(e.target.value)} />
      </label>

      <ChartCard title="Список" query={users} isEmpty={(u) => u.users.length === 0}>
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
                          {displayName(user)} {user['is-admin'] && <span className="badge">админ</span>}
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
```

- [ ] **Step 2: `admin/src/pages/UserDetailPage.tsx`**

```tsx
import { useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router-dom';
import { adminApi } from '../api/endpoints';
import { ChartCard } from '../components/ChartCard';
import { KpiTile } from '../components/KpiTile';
import { formatDateTime } from '../lib/format';
import { EVENT_LABELS } from '../lib/labels';
import { displayName } from './UsersPage';

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

      <ChartCard title="Последние 100 событий" query={detail} isEmpty={(d) => d.events.length === 0}>
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
                {events.map((event) => (
                  <tr key={event.id}>
                    <td>{formatDateTime(event['occurred-at'], TZ)}</td>
                    <td>{EVENT_LABELS[event.name] ?? event.name}</td>
                    <td className="mono">
                      {Object.keys(event.props).length > 0 ? JSON.stringify(event.props) : ''}
                    </td>
                    <td>{event.source === 'server' ? 'сервер' : 'клиент'}</td>
                    <td className="muted">
                      {event.platform} {event['app-version']}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </ChartCard>
    </div>
  );
}
```

`displayName` экспортируется из `UsersPage.tsx` — если линтер/рефакторинг потребует, вынеси в `src/lib/users.ts` (не обязательно).

- [ ] **Step 3: Typecheck, commit**

Run: `cd admin && npm run typecheck && npm test`
Expected: всё зелёное.

```bash
git add admin/src/pages/UsersPage.tsx admin/src/pages/UserDetailPage.tsx
git commit -m "feat(admin): users list with search/pagination and user detail"
```

---

### Task 10: Рассылка

**Files:**
- Modify: `admin/src/pages/PushPage.tsx`
- Test: `admin/src/pages/PushPage.test.tsx`

- [ ] **Step 1: Падающий тест**

`admin/src/pages/PushPage.test.tsx`:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { PushPage } from './PushPage';

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

function renderPage() {
  const client = new QueryClient({ defaultOptions: { mutations: { retry: false } } });
  return render(
    <QueryClientProvider client={client}>
      <PushPage />
    </QueryClientProvider>,
  );
}

describe('PushPage', () => {
  it('sends only after explicit confirmation', async () => {
    const fetchMock = vi.fn().mockResolvedValue(json(200, {}));
    vi.stubGlobal('fetch', fetchMock);
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'Обновление');
    await userEvent.type(screen.getByLabelText('Текст'), 'Новые рецепты');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    expect(fetchMock).not.toHaveBeenCalled();

    await userEvent.click(screen.getByRole('button', { name: 'Да, отправить' }));
    expect(await screen.findByText('Рассылка отправлена')).toBeInTheDocument();
    const body = JSON.parse((fetchMock.mock.calls[0][1] as RequestInit).body as string);
    expect(body).toEqual({ title: 'Обновление', body: 'Новые рецепты' });
  });

  it('cancel returns to the form without sending', async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);
    renderPage();

    await userEvent.type(screen.getByLabelText('Заголовок'), 'A');
    await userEvent.type(screen.getByLabelText('Текст'), 'B');
    await userEvent.click(screen.getByRole('button', { name: 'Отправить всем' }));
    await userEvent.click(screen.getByRole('button', { name: 'Отмена' }));

    expect(fetchMock).not.toHaveBeenCalled();
    expect(screen.getByRole('button', { name: 'Отправить всем' })).toBeInTheDocument();
  });
});
```

Run: `cd admin && npm test -- PushPage` → Expected: FAIL (заглушка).

- [ ] **Step 2: `admin/src/pages/PushPage.tsx`**

```tsx
import { useMutation } from '@tanstack/react-query';
import { useState, type FormEvent } from 'react';
import { ApiError } from '../api/client';
import { adminApi } from '../api/endpoints';

const TITLE_MAX = 65;
const BODY_MAX = 240;

export function PushPage() {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [confirming, setConfirming] = useState(false);

  const push = useMutation({
    mutationFn: () => adminApi.push(title.trim(), body.trim()),
    onSettled: () => setConfirming(false),
  });

  const ready = title.trim() !== '' && body.trim() !== '';

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
            {title.length}/{TITLE_MAX} · {body.length}/{BODY_MAX}
          </span>

          {confirming ? (
            <div role="group" aria-label="Подтверждение" className="chips">
              <span>Уведомление получат все пользователи приложения. Отменить после отправки нельзя.</span>
              <button type="button" className="btn btn-danger" disabled={push.isPending} onClick={() => push.mutate()}>
                Да, отправить
              </button>
              <button type="button" className="btn" disabled={push.isPending} onClick={() => setConfirming(false)}>
                Отмена
              </button>
            </div>
          ) : (
            <button type="submit" className="btn btn-primary" disabled={!ready}>
              Отправить всем
            </button>
          )}

          {push.isSuccess && <p className="success-text">Рассылка отправлена</p>}
          {push.isError && (
            <p className="error-text" role="alert">
              {push.error instanceof ApiError ? push.error.message : 'Нет связи с сервером'}
            </p>
          )}
        </form>

        <section className="card">
          <header className="card-head">
            <h2>Превью</h2>
          </header>
          <div className="push-preview">
            <strong>{title || 'Заголовок'}</strong>
            <span className="muted">{body || 'Текст уведомления'}</span>
          </div>
        </section>
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Тесты, typecheck, build, commit**

Run: `cd admin && npm test && npm run typecheck && npm run build`
Expected: всё зелёное.

```bash
git add admin/src/pages/PushPage.tsx admin/src/pages/PushPage.test.tsx
git commit -m "feat(admin): broadcast push with in-page confirmation"
```

---

### Task 11: Docker, nginx, compose

**Files:**
- Create: `admin/Dockerfile`, `admin/nginx.conf`, `admin/.dockerignore`
- Modify: `backend/docker-compose.yml` (репо бэкенда)

- [ ] **Step 1: `admin/Dockerfile`**

```dockerfile
# Build stage
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build


# Runtime stage
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
```

- [ ] **Step 2: `admin/nginx.conf`**

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;

    server_tokens off;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'" always;

    # refresh-токен передаётся в query — не пишем его в access-лог
    location /api/authorize/ {
        access_log off;
        proxy_pass http://app:5040;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /api/ {
        proxy_pass http://app:5040;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable" always;
        add_header X-Content-Type-Options "nosniff" always;
    }

    location / {
        try_files $uri /index.html;
        add_header Cache-Control "no-store" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer" always;
        add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'" always;
    }
}
```

(`add_header` внутри `location` отменяет наследование серверных заголовков — поэтому security-заголовки продублированы в `location /`, отдающем `index.html`.)

- [ ] **Step 3: `admin/.dockerignore`**

```gitignore
node_modules
dist
coverage
.git
*.local
```

- [ ] **Step 4: Сервис в `backend/docker-compose.yml`**

В секцию `services:` после сервиса `app` добавь:

```yaml
  admin:
    build:
      context: ../admin
      dockerfile: Dockerfile

    depends_on:
      - app

    ports:
      - "5041:80"

    restart: unless-stopped
```

- [ ] **Step 5: Сборка и проверка**

```bash
docker compose -f backend/docker-compose.yml up -d --build
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5041/
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5041/users
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5041/api/admin/me
curl -sI http://localhost:5041/ | grep -i content-security-policy
```

Expected: `200`, `200` (SPA fallback), `401` (прокси до Go работает, без токена), строка CSP присутствует.

- [ ] **Step 6: Ручная проверка в браузере**

Открой `http://localhost:5041`, войди почтой из `ADMIN_EMAILS` (код придёт письмом). Пройди все 7 разделов, переключи период 7/30/90, перезагрузи страницу (сессия сохраняется), выйди. Проверь узкий экран (~400px): навигация — горизонтальная лента, таблицы скроллятся внутри карточек. Войди почтой **не** из списка → «У этой почты нет прав администратора».

- [ ] **Step 7: Commit (два репо)**

```bash
git add admin/Dockerfile admin/nginx.conf admin/.dockerignore
git commit -m "feat(admin): production Docker image with hardened nginx"
git -C backend add docker-compose.yml
git -C backend commit -m "feat: admin site service in compose"
```

---

### Task 12: CI и документация

**Files:**
- Modify: `.github/workflows/ci.yml` (корневой репо)
- Create: `admin/README.md`
- Modify: `CLAUDE.md` (локально, в `.gitignore` — не коммитится)

- [ ] **Step 1: Job `admin` в `.github/workflows/ci.yml`**

В секцию `jobs:` перед `quality:` добавь:

```yaml
  admin:
    name: Admin · typecheck · test · build
    runs-on: ubuntu-latest
    timeout-minutes: 10
    defaults:
      run:
        working-directory: admin
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          cache-dependency-path: admin/package-lock.json

      - run: npm ci
      - run: npm run typecheck
      - run: npm test
      - run: npm run build
```

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && echo OK` → Expected: `OK`

- [ ] **Step 2: `admin/README.md`**

````markdown
# Pora · админ-панель аналитики

SPA (Vite + React + TypeScript) для владельца: DAU/WAU/MAU, retention-когорты, воронка активации, adoption функций, топ товаров, платформы и версии, пользователи, push-рассылка.

## Доступ

Вход — тем же OTP-кодом по почте, что и в приложении (`verify-otp` с `client=admin`). Пускает только пользователей с `users.is_admin`; права синхронизируются на старте бэкенда из `ADMIN_EMAILS` в `backend/.env`. Вход в админку не разлогинивает приложение.

## Разработка

```bash
docker compose -f backend/docker-compose.yml up -d --build   # API на :5040
cd admin && npm install && npm run dev                       # http://localhost:5173
```

Vite проксирует `/api` на `localhost:5040`.

## Проверки

```bash
npm run typecheck && npm test && npm run build
```

## Деплой

Сервис `admin` в `backend/docker-compose.yml`: nginx на `:5041` отдаёт статику и проксирует `/api` на `app:5040` (один origin, без CORS). Строгий CSP, `X-Frame-Options: DENY`; `/api/authorize/` не пишется в access-лог (refresh-токен в query).

Перед публикацией наружу — только через HTTPS (TLS-терминация на внешнем прокси).
````

- [ ] **Step 3: `CLAUDE.md` (локально)**

В раздел `## Gotchas` добавь пункты:

```markdown
- **Админ-аналитика** — сайт `admin/` (Vite+React+TS, `npm run dev` → :5173, прокси `/api` → :5040; прод — сервис `admin` в compose, :5041). Вход OTP с `client=admin`, права — `users.is_admin` из `ADMIN_EMAILS`. Эндпоинты `/api/admin/*` под `AdminMiddleware`. Spec/планы: `docs/superpowers/{specs,plans}/2026-10-15-admin-analytics*`.
- **События аналитики** — доменные (`item_added/bought/deleted`, `list_created`, `family_*`, `user_signed_up`) пишет **сервер** из сервисов; клиент шлёт только client-only (`session_start`, `screen_view`, AI, рецепты, поддержка, `view_mode_changed`) через `BackendEventSink` → `POST /api/analytics/events`. Новое client-only событие = whitelist в `backend/internal/services/analytics_validation.go` + `_backend.track` в `AnalyticsService`. Доменное событие в sink не шли — двойной счёт.
- **`backend/` — отдельный git-репо** (корневой репо публичный, `backend/` в его `.gitignore`). Коммиты бэкенда: `git -C backend …`.
```

- [ ] **Step 4: Commit (корневой репо)**

```bash
git add .github/workflows/ci.yml admin/README.md
git commit -m "ci: admin site typecheck/test/build; admin README"
```

---

## Проверка плана целиком

```bash
cd admin && npm ci && npm run typecheck && npm test && npm run build
docker compose -f backend/docker-compose.yml up -d --build && curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5041/
```

Expected: всё зелёное, `200`. Ручная проверка — Task 11 Step 6.
