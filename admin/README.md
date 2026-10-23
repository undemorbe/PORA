# Pora · админ-панель аналитики

SPA (Vite + React + TypeScript) для владельца: DAU/WAU/MAU, retention-когорты, воронка активации, adoption функций, топ товаров, платформы и версии, пользователи, push-рассылка.

## Доступ

- Вход только по **email**: тот же OTP-код по почте, что и в приложении (`send-otp` → `verify-otp` с `client=admin`). Телефонного входа в админке нет.
- Пускает только пользователей с `users.is_admin`. Не-админ или неизвестный email получает `403` → «У этой почты нет прав администратора».
- `is_admin` синхронизируется **на старте бэкенда** из `ADMIN_EMAILS` в `backend/.env` (через запятую). Поменял список — перезапусти `app`.
- Бэкенд выдаёт JWT с клиентом `admin`: эта сессия живёт отдельно от мобильной, вход в админку не разлогинивает приложение. `/api/admin/*` под `AdminMiddleware` — права проверяются на каждый запрос.
- Access-токен — только в памяти, refresh — в `localStorage` (`pora-admin-refresh`), поэтому перезагрузка страницы сессию не теряет. Права отозвали посреди сессии (`403`) → экран «Нет доступа»; refresh отклонён (`4xx`) → экран логина.
- Нет сети или бэкенд отвечает `5xx` при проверке сессии → экран «Нет связи с сервером» / «Сервер недоступен» с кнопкой «Повторить». Сессия при этом **не** сбрасывается.

## Особенности данных

- Период 7/30/90 дней хранится в URL (`?days=`), таймзона — браузерная (передаётся в каждый запрос).
- «Медиана до покупки» (`median-hours-to-buy`) считается по событиям `item_bought` с `hours_to_buy` — сервер пишет его только для разовых (не повторяющихся) товаров и только с момента появления событийной аналитики. Пока таких покупок за период нет, поле `null` и KPI показывает «появится после новых покупок».
- Go может вернуть `null` вместо пустого массива — UI читает такие поля как `?? []`.

## Разработка

```bash
docker compose -f backend/docker-compose.yml up -d --build   # API на :5040
cd admin && npm install && npm run dev                       # http://localhost:5173
```

Vite проксирует `/api` на `localhost:5040` — тот же origin, что и в проде.

## Проверки

```bash
npm run typecheck && npm test && npm run build
```

То же гоняет job `admin` в `.github/workflows/ci.yml` (Node 22, `npm ci`).

## Деплой

Сервис `admin` в `backend/docker-compose.yml` (build context `../admin`): multi-stage образ `node:22-alpine` → `nginx:1.27-alpine`, порт `5041`.

- nginx отдаёт статику и проксирует `/api` на `app:5040` (один origin, без CORS). Имя `app` резолвится через Docker DNS на каждый запрос: nginx стартует, даже если бэкенд ещё не поднят (`502`), и переживает пересоздание контейнера `app`.
- SPA-fallback: любой путь, кроме `/api/` и `/assets/`, отдаёт `index.html` (`Cache-Control: no-store`). Хэшированные `/assets/*` — `public, max-age=31536000, immutable`; отсутствующий ассет — `404`, а не `index.html`.
- Заголовки на всех ответах: строгий CSP (`script-src 'self'`; `style-src` с `'unsafe-inline'` только ради inline-стилей Recharts), `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`. Сборка не содержит inline-скриптов.
- `/api/authorize/` не пишется ни в access-лог, ни в error-лог ниже `crit` — refresh-токен идёт в query.

Перед публикацией наружу — только через HTTPS (TLS-терминация на внешнем прокси).
