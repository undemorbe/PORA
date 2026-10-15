# Admin-аналитика и рефакторинг статистики — дизайн

**Дата:** 2026-10-15
**Статус:** утверждён в брейншторме, ожидает ревью spec
**Scope:** (1) рефакторинг клиентской статистики, (2) серверный сбор событий, (3) отдельный админ-сайт аналитики. Рефакторинг остального приложения — вне scope.

## Решения, принятые с пользователем

| Вопрос | Решение |
|---|---|
| Аудитория сайта | Админ-панель для владельца (агрегаты по всем юзерам) |
| Рефакторинг | Только статистика/аналитика |
| Стек сайта | Отдельный проект `admin/`: React + Vite + TypeScript + Recharts, nginx-контейнер в `backend/docker-compose.yml` |
| Вход в админку | Тот же OTP-логин + флаг `users.is_admin` |
| Сбор событий | Гибрид: доменные события пишет Go-бэкенд, client-only события шлёт клиент батчами |

## 1. Архитектура

```
Flutter app ──batch──▶ POST /api/analytics/events ─┐
Go services (item/list/family/auth) ── emit ───────┼─▶ analytics_events (Postgres)
                                                   │
admin/ (React+Vite+Recharts) ──JWT + is_admin──▶ /api/admin/*  ─▶ SQL-агрегаты
       nginx-контейнер, проксирует /api → app:5040
```

### 1.1 Бэкенд (Go)

**Миграции** (одна новая пара up/down в `backend/migrations/`):

- `users.is_admin BOOLEAN NOT NULL DEFAULT FALSE`.
- `refresh_tokens`: добавить `client TEXT NOT NULL DEFAULT 'app'`; снять `UNIQUE(user_id)`, добавить `UNIQUE(user_id, client)`. Причина: сейчас один refresh-токен на юзера — логин в админке разлогинил бы мобильное приложение.
- Таблица событий:

```sql
CREATE TABLE analytics_events (
    id          UUID PRIMARY KEY,               -- генерит отправитель (идемпотентность)
    user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    props       JSONB NOT NULL DEFAULT '{}',
    platform    TEXT,                           -- ios | android | server
    app_version TEXT,
    source      TEXT NOT NULL,                  -- client | server
    occurred_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_analytics_events_name_time ON analytics_events(name, occurred_at);
CREATE INDEX idx_analytics_events_user_time ON analytics_events(user_id, occurred_at);
```

**Новые компоненты** (по текущему паттерну `ports/` → `services/` → `handlers/` → `repositories/`):

- `repositories/analytics_event.go` — batch insert `ON CONFLICT (id) DO NOTHING`, delete older-than.
- `services/analytics.go` — `AnalyticsService`: `Emit(ctx, event)` (асинхронный, см. §3.2) и `Ingest(userID, batch)` (валидация клиентских событий).
- `services/admin_stats.go` — `AdminStatsService`: все агрегаты для `/api/admin/*`.
- `handlers/analytics.go`, `handlers/admin.go`.
- `middleware/admin.go` — `AdminMiddleware` (§3.3).
- `TokenService.CreateTokens` получает параметр `client` (`app` | `admin`).
- Конфиг: `ADMIN_EMAILS` (через запятую) в `config.Load()`; на старте сервер выставляет `is_admin=true` найденным юзерам (идемпотентно, лог при отсутствии юзера).
- `/api/system/notify-everyone` переезжает на `POST /api/admin/push` под `AdminMiddleware`; старый маршрут удаляется. **Закрывает текущую дыру: эндпоинт сейчас без авторизации.**

### 1.2 Flutter (рефакторинг статистики)

- `AnalyticsService` (`lib/core/internal/analytics/analytics_service.dart`) становится фасадом над sink'ами:
  - `FirebaseSink` — текущая логика `_log` (Firebase Analytics).
  - `UsageTracker` — без изменений поведения (локальная статистика Insights).
  - `BackendEventSink` — новый, §3.1.
- Каждое типизированное событие декларирует, в какие sink'и оно идёт. **Доменные события, которые пишет сервер** (`item_added`, `item_bought`, `item_deleted`, `list_created`, …), в `BackendEventSink` **не** отправляются — иначе двойной счёт.
- Новое событие `session_start` (из `UsageSessionListener`), несёт `platform` + `app_version` (новая зависимость `package_info_plus`; в `pubspec.yaml` её пока нет).
- Новый метод в retrofit `ApiClient`: `POST /api/analytics/events`. Codegen через `dart run build_runner build`.
- `insights_screen.dart` (481 строка) распиливается на section-виджеты в `insights/presentation/widgets/sections/`; вычисления, оставшиеся в экране, переезжают в `StatisticsStore` (`@computed`). Поведение и внешний вид экрана не меняются.

### 1.3 Админ-сайт `admin/`

- Vite + React 18 + TypeScript + Recharts + react-router. Без UI-кита; собственные лёгкие компоненты (KPI-плитка, карточка графика, таблица).
- Data-fetching: тонкий `api.ts` поверх `fetch` + TanStack Query (кэш по ключу `[endpoint, period, tz]`, retry 1, независимые loading/error на каждый график).
- Токены: access в памяти, refresh в `localStorage`; `401` → попытка refresh → иначе на логин.
- Деплой: multi-stage Dockerfile (`node` build → `nginx` static), сервис `admin` в `backend/docker-compose.yml`, порт `5041`, `location /api/ { proxy_pass http://app:5040; }`. Dev: `vite` с proxy `/api` → `localhost:5040`.

## 2. Метрики и экраны

### 2.1 Таксономия событий

| Источник | События |
|---|---|
| Go-сервисы (`source=server`) | `user_signed_up`, `list_created{shared}`, `item_added{section}`, `item_bought`, `item_deleted`, `family_created`, `family_joined` |
| Клиент (`source=client`) | `session_start`, `screen_view{screen}`, `ai_chat_opened`, `ai_message_sent`, `ai_tip_generated`, `recipe_import{source}`, `support_message_sent`, `view_mode_changed{grid}` |

- Логины продолжают писаться в `user_logins`.
- Props клиентских событий — whitelist на сервере (по имени события). Названия товаров с клиента **не** принимаются; товарная аналитика берётся из таблицы `items`.

**Активный юзер за день** = есть запись в `user_logins` **или** любое событие в `analytics_events` за этот день (в таймзоне запроса).

### 2.2 Экраны

1. **Обзор** — KPI: всего юзеров, новые за период (+дельта к предыдущему периоду), DAU (сегодня), WAU, MAU, stickiness DAU/MAU, товаров добавлено, товаров куплено. Графики: DAU по дням (линия), регистрации по дням (столбцы). Переключатель периода 7/30/90, tz из браузера (`Intl.DateTimeFormat().resolvedOptions().timeZone`).
2. **Retention** — недельные когорты по неделе регистрации × неделя N (0..8), % вернувшихся, heatmap-таблица; отдельно D1/D7/D30.
3. **Вовлечённость** — воронка: регистрация → первый список → первый товар → первая покупка → вступил/создал семью (по юзерам, зарегистрированным в периоде). Adoption фич как % MAU: AI-чат, импорт рецептов, семьи. События по типам во времени (stacked area).
4. **Товары** — топ-20 добавляемых и покупаемых по всем юзерам (`lower(trim(name))`), распределение по секциям, медиана `checked_at − created_at`.
5. **Платформы и версии** — доля iOS/Android (`devices.device_type`, distinct users), распределение `app_version` среди активных за период (по последнему `session_start`).
6. **Пользователи** — таблица с поиском по email/телефону, пагинация 50: последняя активность, кол-во списков, товаров, семей. Карточка юзера: последние 100 событий.
7. **Push** — форма рассылки всем (title/body), превью, встроенное подтверждение (без `confirm()`).

### 2.3 API (`/api/admin/*`, всё под `AdminMiddleware`)

Общие query-параметры для периодных эндпоинтов: `from`, `to` (ISO date), `tz` (IANA, default `UTC`; невалидная → `400`).

| Метод | Путь | Ответ |
|---|---|---|
| GET | `/me` | профиль админа |
| GET | `/overview` | KPI + дельты |
| GET | `/active-users` | `[{date, dau}]` + WAU/MAU на `to` |
| GET | `/signups` | `[{date, count}]` |
| GET | `/retention?weeks=8` | когорты + D1/D7/D30 |
| GET | `/funnel` | шаги воронки с count |
| GET | `/features` | adoption % MAU |
| GET | `/events/timeseries?names=a,b` | `[{date, name, count}]` |
| GET | `/products/top?kind=added\|bought&limit=20` | топ товаров |
| GET | `/products/sections` | распределение по секциям |
| GET | `/platforms` | платформы + версии |
| GET | `/users?q=&page=` | список |
| GET | `/users/:id` | карточка + события |
| POST | `/push` | рассылка (бывший notify-everyone) |

JSON-ключи — kebab-case, как во всём API.

### 2.4 Вне scope (YAGNI)

Rollup-таблицы/materialized views (агрегируем на лету; индексы заложены), роли кроме `is_admin`, экспорт CSV, realtime-обновление дашборда, коррекция времени offline-replay.

## 3. Поведение и обработка ошибок

### 3.1 Клиент — `BackendEventSink`

- Отдельный Hive box `pora-analytics-queue` (не `Outbox`: тот гарантирует порядок write-операций, аналитика lossy-tolerant).
- Cap 1000 событий, при переполнении — drop oldest.
- Каждое событие получает UUID на клиенте → повторная отправка безопасна.
- Flush: каждые 30 с, при ≥ 50 событиях в очереди, при `AppLifecycleState.paused`. Батч ≤ 100.
- До логина события копятся; уходят после входа (атрибутируются залогиненному юзеру).
- Logout: best-effort flush → `clear()` (рядом с существующим `UsageTracker.instance.clear()`).
- Сеть / 5xx → батч остаётся, экспоненциальный backoff (30 с → … → 10 мин). 4xx → батч удаляется + `Logger.talker.warning` (битые данные не должны блокировать очередь).

### 3.2 Сервер — приём и emit

- Ingest `POST /api/analytics/events` (JWT обязателен): ≤ 100 событий, тело ≤ 64 KB, whitelist имён и props, `occurred_at` clamp-окно [−30 дней, +5 мин]. Невалидные события отбрасываются поштучно. Ответ `202 {"accepted": n, "rejected": m}`.
- Server emit: буферизованный канал (1024) + воркер, пишущий батчами (по 100 или раз в 2 с). При переполнении канала событие дропается с warn. На shutdown (`ctx.Done()`) — drain буфера. **Ошибка записи события никогда не ломает бизнес-операцию.**
- Известное ограничение: offline-операция клиента проигрывается позже → серверное событие получает время replay. Для дневных агрегатов приемлемо.
- Retention: события старше 365 дней удаляются задачей в существующем `scheduler` (раз в сутки).

### 3.3 `AdminMiddleware`

- Декодирует access JWT через `TokenService.DecodeAccessToken`, затем грузит юзера и проверяет `is_admin` **из БД на каждый запрос** (мгновенный отзыв прав).
- Нет/невалидный токен → `401`; не админ → `403`. Через существующие `errors` + `ErrorHandler` (`ErrorForbidden` уже есть в `errors/service_errors.go`).

### 3.4 Админ-сайт

- `401` → refresh → иначе редирект на `/login`. `403` → экран «Нет доступа».
- Каждый график/плитка — независимые состояния loading / error («Повторить») / empty. Падение одного запроса не роняет страницу.
- Тёмная/светлая тема по `prefers-color-scheme`; адаптив до ~400px.

### 3.5 Приватность

- `analytics_events.user_id ON DELETE CASCADE` — удаление аккаунта удаляет его события.
- Клиент не шлёт названия товаров и свободный текст (AI-сообщения, support).
- Админка показывает email/телефон — допустимо: доступ только у владельца.

## 4. Тестирование

| Слой | Что |
|---|---|
| Go (сейчас тестов нет) | unit: валидация ingest (whitelist, clamp, лимиты), `AdminMiddleware` через `httptest` с фейковым repo, emitter (батчинг, drain). Integration: SQL-агрегаты `AdminStatsService` на реальном Postgres по `TEST_DATABASE_URL` (skip, если не задан) с фикстурами |
| Flutter | `BackendEventSink`: cap, триггеры flush, retry/backoff, 4xx-drop, logout. `AnalyticsService` fan-out: серверные доменные события не уходят в backend sink. Widget-тесты section-виджетов Insights. Все существующие тесты зелёные |
| admin/ | Vitest + React Testing Library: `api.ts` (refresh на 401), форматтеры, страница Обзор с замоканным fetch. `tsc --noEmit` + `vite build` |
| CI | `ci.yml`: новые job'ы `backend` (`go vet ./...`, `go test ./...`) и `admin` (`npm ci`, typecheck, test, build) |

## 5. Порядок реализации

Каждый шаг — отдельный коммит, проверяемый независимо.

1. **Backend foundation** — миграция (`is_admin`, `refresh_tokens.client`, `analytics_events`), `TokenService` с `client`, `ADMIN_EMAILS`, `AdminMiddleware`, перенос `notify-everyone` → `/api/admin/push`, `/api/admin/me`. Тесты middleware.
2. **Backend events** — repo + emitter + emit в list/item/family/auth-сервисах, ingest-эндпоинт, retention-задача. Тесты ingest/emitter.
3. **Flutter refactor** — fan-out `AnalyticsService`, `BackendEventSink`, `ApiClient` + codegen, `session_start` с `app_version`, распил `insights_screen`. Тесты. `dart format` + `flutter analyze` + `flutter test`.
4. **Admin API** — `AdminStatsService` + handlers всех `/api/admin/*`. Integration-тесты.
5. **`admin/` сайт** — каркас, логин (OTP, `client=admin`), 7 экранов, Dockerfile + nginx, сервис в compose, CI job.
6. **Документация** — `docs/ADMIN.md` (запуск, назначение админа, метрики), обновить `DOCKER.md`, `CLAUDE.md`.

## 6. Критерии готовности

- `docker compose -f backend/docker-compose.yml up -d --build` поднимает `postgres`, `app`, `admin`; админка на `http://localhost:5041`.
- Юзер из `ADMIN_EMAILS` входит по OTP и видит все 7 экранов с данными; не-админ получает «Нет доступа»; мобильное приложение того же юзера при этом остаётся залогиненным.
- `/api/system/notify-everyone` больше не существует; `/api/admin/push` без admin-токена → `401/403`.
- Действия в приложении (добавить/купить товар, AI-чат, импорт рецепта) появляются в `analytics_events` без дублей.
- CI зелёный: format, analyze, flutter test, go vet/test, admin typecheck/test/build.

## 7. Уточнения после планирования (2026-10-15)

Зафиксированы в планах `docs/superpowers/plans/2026-10-15-admin-analytics-{1-backend,2-flutter,3-admin-site}.md`; при расхождении с разделами выше действуют эти пункты.

- **Товары (§2.1, §2.2):** топ добавляемых/покупаемых и секции считаются по **серверным** событиям `item_added`/`item_bought`, в props которых сервер кладёт нормализованное название (`lower(trim)`, ≤64 символа) и секцию. Причина: `ProcessCheckedItems` удаляет купленные разовые товары — по таблице `items` топ покупок занижен. Медиана «добавлено → куплено» — по `items`. Клиентский whitelist названия товаров по-прежнему не пропускает.
- **Очередь клиента (§3.1):** хранится ключом `analytics-queue-v1` в `LocalDBNames.settings` (как `UsageTracker`), а не отдельным Hive-box — тестируемость через `FakeLocalDB`.
- **Репозитории:** `backend/` — отдельный git-репозиторий (корневой репо публичный, `backend/` в его `.gitignore`); CI бэкенда — в `backend/.github/workflows/`. `admin/` — в корневом репо.
- **Безопасность, найдено при планировании:** `DeleteItem`/`DeleteItems`/`MarkAsBought` не проверяли токен — теперь требуют его (нужен `actorID` для событий). Выход из приложения удаляет только `client=app` refresh-токен, выход из админки — только `client=admin`.
- **Логин админки** (`verify-otp` с `client=admin`) не создаёт пользователей: несуществующий или не-админ → `403`. Refresh админки не пишет `user_logins`.
