# Admin-аналитика, план 1 из 3 — Go-бэкенд

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Бэкенд получает admin-доступ (OTP + `is_admin`), таблицу событий `analytics_events` с серверным emit и клиентским ingest, и набор `/api/admin/*` эндпоинтов со статистикой; дыра `/api/system/notify-everyone` закрыта.

**Architecture:** Существующий слоёный паттерн `ports → services → handlers → repositories` (gin + gorm + Postgres, миграции golang-migrate). Серверные события пишутся асинхронно через буферизованный канал (`AnalyticsService.Run`), клиентские — синхронно через `Ingest` с whitelist-валидацией. Агрегаты считаются на лету raw-SQL в `AdminStatsRepository`; период/таймзона — чистый пакет `internal/stats`.

**Tech Stack:** Go 1.25, gin, gorm (pgx), golang-migrate, Postgres 16. Тесты: стандартный `testing` (testify в зависимостях нет — не добавляем), интеграционные — реальный Postgres по `TEST_DATABASE_URL`.

**Spec:** `docs/superpowers/specs/2026-10-15-admin-analytics-design.md`

**Планы-соседи:** план 2 (Flutter) зависит от Task 9 (ingest-эндпоинт); план 3 (admin-сайт) — от Tasks 3, 6, 11–14 (контракты `/api/admin/*`).

---

## Решения, уточнённые при планировании (отклонения от spec отмечены)

1. **`users.status` уже имеет значение `admin`** (`entities.UserStatusAdmin`), но оно никем не выставляется и перезаписывается регистрацией. Используем отдельную колонку `is_admin`, как в spec; `UserStatusAdmin` не трогаем.
2. **Невалидный/отсутствующий токен в существующем коде даёт `400 INVALID_INPUT`**, а не 401. Для `/api/admin/*` вводим `ErrorUnauthorized` → `401`. Истёкший токен остаётся `401 ACCESS_TOKEN_EXPIRED`.
3. **`DeleteItem`/`DeleteItems`/`MarkAsBought` сейчас не проверяют токен вообще.** Для атрибуции событий они начинают декодировать токен (`actorID`) — это заодно закрывает анонимное удаление/отметку чужих товаров. Мобильный клиент всегда шлёт `Authorization` (Dio-интерцептор).
4. **(отклонение от spec §2.2)** Топ товаров и секции считаются по серверным событиям `item_added`/`item_bought`, в props которых сервер кладёт нормализованное название (`lower(trim)`, ≤64 символа) и секцию. Причина: `ProcessCheckedItems` удаляет купленные разовые товары — по таблице `items` топ покупок занижен. Клиентский whitelist названия по-прежнему не пропускает. Медиана «добавлено → куплено» — по `items`. Spec правится в том же коммите, что и план.
5. **Логин админки не создаёт юзеров:** `verify-otp` с `client=admin` для несуществующего юзера или не-админа → `403`.
6. **Refresh админки не пишет `user_logins`** — иначе админ раздувает DAU.
7. **Выход из приложения удаляет только `client=app` токен**, выход из админки (`POST /api/admin/logout`) — только `client=admin`.
8. **Graceful shutdown:** `r.Run` заменяется на `http.Server` + `Shutdown`, чтобы буфер событий успевал записаться (spec §3.2 «drain на shutdown»).
9. **Alpine-образ без tzdata** → `time.LoadLocation("Europe/...")` падает. Добавляем `import _ "time/tzdata"` в `main.go`.
10. **`ADMIN_EMAILS` — источник истины:** на старте `is_admin` синхронизируется со списком (добавленные получают права, убранные — теряют).
11. **Воронка нестрогая:** каждый шаг — число юзеров когорты, у которых есть событие шага (без требования пройти предыдущие). На UI подписываем «дошли до шага».
12. **`backend/` — отдельный git-репозиторий** (решение пользователя 2026-10-15): корневой репо публичный и игнорирует `backend/`. Task 0 создаёт репо; все коммиты — `git -C backend …`, пути относительно `backend/`. CI бэкенда — `backend/.github/workflows/ci.yml`. `DOCKER.md` (корень, в `.gitignore`) правится локально без коммита.

## Карта файлов

| Файл | Ответственность |
|---|---|
| `backend/migrations/20261015120000_admin_and_analytics.{up,down}.sql` | `is_admin`, `refresh_tokens.client`, `analytics_events` |
| `backend/internal/entities/user.go` (mod) | поле `IsAdmin` |
| `backend/internal/entities/refresh_token.go` (mod) | поле `Client`, константы `ClientApp/ClientAdmin`, `NormalizeClient` |
| `backend/internal/entities/analytics_event.go` (new) | сущность события, имена событий, `NormalizeProductName` |
| `backend/internal/errors/{codes,service_errors}.go` (mod) | `ErrorUnauthorized` |
| `backend/internal/middleware/error_handler.go` (mod) | `UNAUTHORIZED` → 401 |
| `backend/internal/middleware/admin.go` (new) | `AdminMiddleware` |
| `backend/internal/config/config.go` (mod) | `AdminConfig{Emails}` |
| `backend/internal/stats/period.go` (new) | `Period`, `ParsePeriod`, `WeekStart` |
| `backend/internal/stats/aggregate.go` (new) | `FillDays`, `BuildCohorts`, row-типы |
| `backend/internal/ports/{repositories,services}.go` (mod) | новые/изменённые интерфейсы |
| `backend/internal/repositories/refresh_token.go` (mod) | `DeleteByUserIDAndClient` |
| `backend/internal/repositories/user.go` (mod) | `SyncAdmins` |
| `backend/internal/repositories/analytics_event.go` (new) | batch insert / cleanup / recent by user |
| `backend/internal/repositories/admin_stats.go` (new) | raw-SQL агрегаты |
| `backend/internal/services/token.go`, `auth.go`, `otp.go` (mod) | client-aware токены, admin-gate, emit signup |
| `backend/internal/services/analytics.go` (new) | emitter (`Emit/Run/Cleanup`) + `Ingest` |
| `backend/internal/services/analytics_validation.go` (new) | whitelist клиентских событий |
| `backend/internal/services/admin_stats.go` (new) | композиция агрегатов |
| `backend/internal/services/{list,item,family}.go` (mod) | emit доменных событий |
| `backend/internal/handlers/admin.go` (new), `analytics.go` (new) | HTTP-слой |
| `backend/internal/handlers/{auth,item}.go` (mod) | logout по client, `actorID` |
| `backend/internal/handlers/system.go` (delete) | переезжает в `admin.go` |
| `backend/internal/dto/requests/{auth,analytics}.go`, `responses/{analytics,admin}.go` | DTO |
| `backend/internal/infrastructure/database/migrations.go` (mod) | `RunMigrationsFromDir` |
| `backend/internal/testutil/db.go` (new) | тестовая БД + сиды |
| `backend/cmd/server/main.go` (mod) | wiring, маршруты, graceful shutdown, tzdata |
| `backend/.gitignore` (new) | секреты и артефакты вне git бэкенда |
| `backend/.github/workflows/ci.yml` (new) | CI бэкенд-репозитория |
| `DOCKER.md` (mod, локально, не коммитится) | `ADMIN_EMAILS`, тестовая БД |

## Общие команды

```bash
cd backend && go build ./... && go vet ./...      # после каждого таска
cd backend && go test -p 1 ./...                   # все тесты; -p 1 обязателен: интеграционные пакеты делят одну БД
```

**Тестовая БД (обновлено 2026-10-16):** отдельный одноразовый контейнер, как в CI. На `localhost:5432` этой машины отвечает host-Postgres, а не Docker — не используй его.

```bash
docker start pora-test-pg 2>/dev/null || docker run -d --name pora-test-pg --restart unless-stopped \
  -e POSTGRES_DB=pora_test -e POSTGRES_USER=pora -e POSTGRES_PASSWORD=pora -p 127.0.0.1:55432:5432 postgres:16
export TEST_DATABASE_URL="host=127.0.0.1 port=55432 user=pora password=pora dbname=pora_test sslmode=disable"
```

Креды одноразовые (не секрет). Без переменной интеграционные тесты делают `t.Skip`. `OpenTestDB` отказывается работать с БД, имя которой не оканчивается на `_test`.

**Где выполняется (обновлено 2026-10-16):** ветка `feat/admin-analytics` вынесена в git worktree `/Users/dolbobob/Programming/FlutterApps/pora/.claude/worktrees/backend-admin` (в `backend/` параллельно работает другая сессия на ветке `feat/account-deletion`). Читай `backend/` в этом плане как корень worktree, `cd backend` — как `cd` в worktree, `git -C backend …` — как `git …` в worktree. `.env` в worktree — симлинк на `backend/.env`.

---

### Task 0: Отдельный git-репозиторий для `backend/`

`backend/` целиком в `.gitignore` публичного корневого репо (0 отслеживаемых файлов). Решение пользователя (2026-10-15): у бэкенда свой git. Все коммиты этого плана — `git -C backend ...`, пути относительно `backend/`.

**Files:**
- Create: `backend/.gitignore`

- [ ] **Step 1: Убедись, что репозитория ещё нет**

Run: `git -C backend rev-parse --show-toplevel`
Expected: путь **корня проекта** (`.../pora`), а не `.../pora/backend` — значит, своего репо у `backend/` нет. Если выводит `.../pora/backend` — репо уже есть, пропусти Steps 2–4.

- [ ] **Step 2: `.gitignore` бэкенда**

`backend/.gitignore`:

```gitignore
# Секреты — никогда в git
.env
*.pem
*.key

# Артефакты рантайма
logs/
uploads/
/server
```

- [ ] **Step 3: Проверь, что секреты не попадут в индекс**

```bash
git -C backend init -b main
git -C backend add -A
git -C backend status --short | grep -E '\.env|\.pem|\.key|uploads/|logs/' && echo "STOP: секрет в индексе" || echo "clean"
```

Expected: `clean`. Если `STOP` — `git -C backend reset`, поправь `.gitignore`, повтори.

- [ ] **Step 4: Исходный коммит (состояние до изменений плана)**

```bash
git -C backend commit -m "chore: import existing backend"
git -C backend log --oneline
```

Expected: один коммит. Корневой репо не меняется (`git status --short` в корне не показывает `backend/`).

---

### Task 1: Миграция, поля сущностей, тестовая инфраструктура

**Files:**
- Create: `backend/migrations/20261015120000_admin_and_analytics.up.sql`
- Create: `backend/migrations/20261015120000_admin_and_analytics.down.sql`
- Create: `backend/internal/entities/analytics_event.go`
- Modify: `backend/internal/entities/user.go` (struct `User`)
- Modify: `backend/internal/entities/refresh_token.go`
- Modify: `backend/internal/infrastructure/database/migrations.go`
- Create: `backend/internal/testutil/db.go`
- Test: `backend/internal/entities/analytics_event_test.go`

- [ ] **Step 1: Проверь фактическое имя UNIQUE-ограничения на `refresh_tokens.user_id` в рабочей БД**

```bash
docker compose -f backend/docker-compose.yml up -d postgres
docker compose -f backend/docker-compose.yml exec postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\d refresh_tokens"'
```

Expected: в `Indexes:` есть `"refresh_tokens_user_id_key" UNIQUE CONSTRAINT, btree (user_id)`. Если имя другое или есть дополнительный unique-индекс по `user_id` — добавь соответствующий `DROP CONSTRAINT IF EXISTS <имя>` / `DROP INDEX IF EXISTS <имя>` в up-миграцию из Step 2.

- [ ] **Step 2: Напиши up-миграцию**

`backend/migrations/20261015120000_admin_and_analytics.up.sql`:

```sql
ALTER TABLE users
ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE refresh_tokens
ADD COLUMN client TEXT NOT NULL DEFAULT 'app';

ALTER TABLE refresh_tokens
DROP CONSTRAINT IF EXISTS refresh_tokens_user_id_key;

CREATE UNIQUE INDEX idx_refresh_tokens_user_client
ON refresh_tokens(user_id, client);

CREATE TABLE analytics_events (
    id UUID PRIMARY KEY,
    user_id UUID,
    name TEXT NOT NULL,
    props JSONB NOT NULL DEFAULT '{}'::jsonb,
    platform TEXT NOT NULL DEFAULT '',
    app_version TEXT NOT NULL DEFAULT '',
    source TEXT NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_analytics_events_name_time
ON analytics_events(name, occurred_at);

CREATE INDEX idx_analytics_events_user_time
ON analytics_events(user_id, occurred_at);
```

- [ ] **Step 3: Напиши down-миграцию**

`backend/migrations/20261015120000_admin_and_analytics.down.sql`:

```sql
DROP TABLE IF EXISTS analytics_events;

DROP INDEX IF EXISTS idx_refresh_tokens_user_client;

DELETE FROM refresh_tokens
WHERE client <> 'app';

ALTER TABLE refresh_tokens
DROP COLUMN client;

ALTER TABLE refresh_tokens
ADD CONSTRAINT refresh_tokens_user_id_key UNIQUE (user_id);

ALTER TABLE users
DROP COLUMN is_admin;
```

- [ ] **Step 4: Добавь `IsAdmin` в `User`**

В `backend/internal/entities/user.go` после строки `Status  UserStatus \`gorm:"not null"\``:

```go
	// IsAdmin - доступ к админ-панели аналитики (синхронизируется с ADMIN_EMAILS)
	IsAdmin bool `gorm:"not null;default:false"`
```

- [ ] **Step 5: Добавь `Client` в `RefreshToken`**

Замени содержимое `backend/internal/entities/refresh_token.go` целиком:

```go
// entities - пакет с сущностями для БД
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Клиенты, для которых выдаются refresh-токены.
// У пользователя может быть по одному токену на каждый клиент
const (
	ClientApp   = "app"
	ClientAdmin = "admin"
)

// NormalizeClient приводит произвольное значение клиента к допустимому.
// Всё, что не "admin", считается мобильным приложением
func NormalizeClient(raw string) string {
	if raw == ClientAdmin {
		return ClientAdmin
	}
	return ClientApp
}

// RefreshToken - структура сущности refresh токена.
// Содержит ID, ID привязанного к нему пользователя, клиент,
// сам токен, время истечения срока действия
type RefreshToken struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey"`
	UserID uuid.UUID `gorm:"type:uuid;uniqueIndex:idx_refresh_tokens_user_client"`
	Client string    `gorm:"not null;default:app;uniqueIndex:idx_refresh_tokens_user_client"`

	Token     string    `gorm:"not null"`
	ExpiresAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствующие поля при создании сущности
func (r *RefreshToken) BeforeCreate(db *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	if r.Client == "" {
		r.Client = ClientApp
	}
	if r.ExpiresAt.IsZero() {
		r.ExpiresAt = time.Now().UTC().Add(15 * 24 * time.Hour)
	}
	return nil
}
```

- [ ] **Step 6: Напиши падающий тест на `NormalizeProductName`**

`backend/internal/entities/analytics_event_test.go`:

```go
package entities

import (
	"strings"
	"testing"
)

func TestNormalizeProductName(t *testing.T) {
	cases := map[string]string{
		"  Молоко ":            "молоко",
		"BREAD":                "bread",
		"":                     "",
		strings.Repeat("я", 80): strings.Repeat("я", 64),
	}

	for input, want := range cases {
		if got := NormalizeProductName(input); got != want {
			t.Errorf("NormalizeProductName(%q) = %q, want %q", input, got, want)
		}
	}
}

func TestNormalizeClient(t *testing.T) {
	if NormalizeClient("admin") != ClientAdmin {
		t.Fatal("admin должен остаться admin")
	}
	for _, raw := range []string{"", "app", "web", "ADMIN"} {
		if NormalizeClient(raw) != ClientApp {
			t.Errorf("NormalizeClient(%q) должен быть app", raw)
		}
	}
}
```

- [ ] **Step 7: Запусти — должен упасть**

Run: `cd backend && go test ./internal/entities/`
Expected: FAIL — `undefined: NormalizeProductName`

- [ ] **Step 8: Создай сущность события**

`backend/internal/entities/analytics_event.go`:

```go
// entities - пакет с сущностями для БД
package entities

import (
	"strings"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Источники и платформа серверных событий аналитики
const (
	EventSourceServer = "server"
	EventSourceClient = "client"
	PlatformServer    = "server"
)

// Имена событий аналитики. Серверные пишет бэкенд из сервисов,
// клиентские принимаются через ingest-эндпоинт по whitelist
const (
	EventUserSignedUp  = "user_signed_up"
	EventListCreated   = "list_created"
	EventItemAdded     = "item_added"
	EventItemBought    = "item_bought"
	EventItemDeleted   = "item_deleted"
	EventFamilyCreated = "family_created"
	EventFamilyJoined  = "family_joined"

	EventSessionStart       = "session_start"
	EventScreenView         = "screen_view"
	EventAiChatOpened       = "ai_chat_opened"
	EventAiMessageSent      = "ai_message_sent"
	EventAiTipGenerated     = "ai_tip_generated"
	EventRecipeImport       = "recipe_import"
	EventSupportMessageSent = "support_message_sent"
	EventViewModeChanged    = "view_mode_changed"
)

// maxProductNameLen - максимальная длина названия товара в props событий
const maxProductNameLen = 64

// AnalyticsEvent - событие продуктовой аналитики.
// Props хранится как JSON-строка (колонка jsonb)
type AnalyticsEvent struct {
	ID     uuid.UUID  `gorm:"type:uuid;primaryKey"`
	UserID *uuid.UUID `gorm:"type:uuid"`

	Name  string `gorm:"not null"`
	Props string `gorm:"type:jsonb;not null;default:'{}'"`

	Platform   string `gorm:"not null;default:''"`
	AppVersion string `gorm:"not null;default:''"`
	Source     string `gorm:"not null"`

	OccurredAt time.Time `gorm:"not null"`
	ReceivedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствующие поля при создании сущности
func (e *AnalyticsEvent) BeforeCreate(db *gorm.DB) error {
	if e.ID == uuid.Nil {
		e.ID = uuid.New()
	}
	if e.Props == "" {
		e.Props = "{}"
	}
	if e.ReceivedAt.IsZero() {
		e.ReceivedAt = time.Now().UTC()
	}
	return nil
}

// NormalizeProductName приводит название товара к виду для агрегатов:
// нижний регистр, без пробелов по краям, не длиннее 64 символов
func NormalizeProductName(name string) string {
	normalized := []rune(strings.ToLower(strings.TrimSpace(name)))
	if len(normalized) > maxProductNameLen {
		normalized = normalized[:maxProductNameLen]
	}
	return string(normalized)
}
```

- [ ] **Step 9: Запусти — должен пройти**

Run: `cd backend && go test ./internal/entities/`
Expected: `ok  	pora/internal/entities`

- [ ] **Step 10: Вынеси путь миграций в параметр**

Замени `RunMigrations` в `backend/internal/infrastructure/database/migrations.go`:

```go
// RunMigrations применяет существующие миграции к БД
func RunMigrations(db *gorm.DB) error {
	return RunMigrationsFromDir(db, "migrations")
}

// RunMigrationsFromDir применяет миграции из указанной директории
// (используется тестами, которые запускаются не из корня backend)
func RunMigrationsFromDir(db *gorm.DB, dir string) error {
	DB, err := db.DB()
	if err != nil {
		return err
	}

	driver, err := postgres.WithInstance(DB, &postgres.Config{})
	if err != nil {
		return err
	}

	migrations, err := migrate.NewWithDatabaseInstance(
		"file://"+dir,
		"postgres",
		driver,
	)

	if err != nil {
		return err
	}

	err = migrations.Up()
	if err != nil && err != migrate.ErrNoChange {
		return err
	}

	return nil
}
```

- [ ] **Step 11: Создай тестовую инфраструктуру**

`backend/internal/testutil/db.go`:

```go
// testutil - пакет с помощниками для интеграционных тестов на реальном Postgres
package testutil

import (
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"pora/internal/infrastructure/database"

	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"
)

// OpenTestDB подключается к БД из TEST_DATABASE_URL, применяет миграции
// и очищает все таблицы. Без переменной окружения тест пропускается
func OpenTestDB(t *testing.T) *gorm.DB {
	t.Helper()

	dsn := os.Getenv("TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("TEST_DATABASE_URL не задан — интеграционный тест пропущен")
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: gormlogger.Default.LogMode(gormlogger.Silent),
	})
	if err != nil {
		t.Fatalf("подключение к тестовой БД: %v", err)
	}

	if err := database.RunMigrationsFromDir(db, migrationsDir()); err != nil {
		t.Fatalf("миграции тестовой БД: %v", err)
	}

	Exec(t, db, `TRUNCATE analytics_events, user_logins, brief_items, devices,
		items, lists, family_members, families, refresh_tokens, otps, users CASCADE`)

	return db
}

// migrationsDir возвращает абсолютный путь к backend/migrations
func migrationsDir() string {
	_, file, _, _ := runtime.Caller(0)
	return filepath.Join(filepath.Dir(file), "..", "..", "migrations")
}

// Exec выполняет SQL и валит тест при ошибке
func Exec(t *testing.T, db *gorm.DB, query string, args ...any) {
	t.Helper()
	if err := db.Exec(query, args...).Error; err != nil {
		t.Fatalf("exec %q: %v", query, err)
	}
}

// SeedUser создает пользователя с указанным email и временем регистрации
func SeedUser(t *testing.T, db *gorm.DB, email string, createdAt time.Time) uuid.UUID {
	t.Helper()
	id := uuid.New()
	Exec(t, db, `INSERT INTO users (id, email, phone, name, surname, status, created_at, updated_at)
		VALUES (?, ?, '', 'Test', 'User', 'user', ?, ?)`,
		id, email, createdAt.UTC(), createdAt.UTC())
	return id
}

// SeedLogin добавляет запись о входе пользователя
func SeedLogin(t *testing.T, db *gorm.DB, userID uuid.UUID, at time.Time) {
	t.Helper()
	Exec(t, db, `INSERT INTO user_logins (id, user_id, created_at) VALUES (?, ?, ?)`,
		uuid.New(), userID, at.UTC())
}

// SeedEvent добавляет событие аналитики; props - JSON-строка
func SeedEvent(t *testing.T, db *gorm.DB, userID uuid.UUID, name string,
	at time.Time, props string) {
	t.Helper()
	if props == "" {
		props = "{}"
	}
	Exec(t, db, `INSERT INTO analytics_events
		(id, user_id, name, props, platform, app_version, source, occurred_at)
		VALUES (?, ?, ?, CAST(? AS jsonb), 'android', '1.0.0', 'server', ?)`,
		uuid.New(), userID, name, props, at.UTC())
}

// SeedSessionStart добавляет клиентское событие session_start с версией приложения
func SeedSessionStart(t *testing.T, db *gorm.DB, userID uuid.UUID,
	at time.Time, platform string, appVersion string) {
	t.Helper()
	Exec(t, db, `INSERT INTO analytics_events
		(id, user_id, name, props, platform, app_version, source, occurred_at)
		VALUES (?, ?, 'session_start', '{}', ?, ?, 'client', ?)`,
		uuid.New(), userID, platform, appVersion, at.UTC())
}

// SeedDevice добавляет устройство пользователя
func SeedDevice(t *testing.T, db *gorm.DB, userID uuid.UUID, deviceType string) {
	t.Helper()
	Exec(t, db, `INSERT INTO devices (id, user_id, device_token, device_type)
		VALUES (?, ?, ?, ?)`,
		uuid.New(), userID, uuid.NewString(), deviceType)
}
```

- [ ] **Step 12: Прогони миграцию на тестовой БД (up + down + up)**

Run (с `TEST_DATABASE_URL` из «Общих команд»):

```bash
cd backend && go build ./... && go vet ./...
docker compose -f docker-compose.yml exec postgres sh -c 'psql -U "$POSTGRES_USER" -d pora_test -c "SELECT 1"'
```

Expected: build/vet без вывода, `SELECT 1` → `1`. Полная проверка миграции произойдёт в Task 7 (первый интеграционный тест).

- [ ] **Step 13: Commit**

```bash
git -C backend add migrations/20261015120000_admin_and_analytics.up.sql \
  migrations/20261015120000_admin_and_analytics.down.sql \
  internal/entities/analytics_event.go internal/entities/analytics_event_test.go \
  internal/entities/user.go internal/entities/refresh_token.go \
  internal/infrastructure/database/migrations.go internal/testutil/db.go
git -C backend commit -m "feat(backend): admin flag, per-client refresh tokens, analytics_events table"
```

---

### Task 2: `ErrorUnauthorized` → 401

**Files:**
- Modify: `backend/internal/errors/codes.go`
- Modify: `backend/internal/errors/service_errors.go`
- Modify: `backend/internal/middleware/error_handler.go`
- Test: `backend/internal/middleware/error_handler_test.go`

- [ ] **Step 1: Напиши падающий тест**

`backend/internal/middleware/error_handler_test.go`:

```go
package middleware

import (
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"pora/internal/errors"
	"pora/internal/infrastructure/logger"

	"github.com/gin-gonic/gin"
)

func TestMain(m *testing.M) {
	logger.InitLoggerTest()
	gin.SetMode(gin.TestMode)
	os.Exit(m.Run())
}

func TestErrorHandlerMapsUnauthorizedTo401(t *testing.T) {
	r := gin.New()
	r.Use(ErrorHandler())
	r.GET("/", func(c *gin.Context) { c.Error(errors.ErrorUnauthorized) })

	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/", nil))

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want 401", w.Code)
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/middleware/`
Expected: FAIL — `undefined: errors.ErrorUnauthorized`

- [ ] **Step 3: Добавь код и ошибку**

В `backend/internal/errors/codes.go` в блок `const` после `CodeRefreshExpired`:

```go
	CodeUnauthorized   = "UNAUTHORIZED"
```

В `backend/internal/errors/service_errors.go` после `ErrorRefreshExpired`:

```go
	ErrorUnauthorized = AppError{
		Code:    CodeUnauthorized,
		Message: "Требуется авторизация",
	}
```

В `backend/internal/middleware/error_handler.go` замени

```go
			case errors.CodeAccessExpired,
				errors.CodeRefreshExpired:
```

на

```go
			case errors.CodeAccessExpired,
				errors.CodeRefreshExpired,
				errors.CodeUnauthorized:
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test ./internal/middleware/`
Expected: `ok  	pora/internal/middleware`

- [ ] **Step 5: Commit**

```bash
git -C backend add internal/errors/codes.go internal/errors/service_errors.go \
  internal/middleware/error_handler.go internal/middleware/error_handler_test.go
git -C backend commit -m "feat(backend): UNAUTHORIZED error code mapped to 401"
```

---

### Task 3: Refresh-токены по клиентам + admin-gate в OTP

**Files:**
- Modify: `backend/internal/ports/repositories.go` (интерфейс `RefreshTokenRepository`)
- Modify: `backend/internal/ports/services.go` (`TokenService`, `AuthService`)
- Modify: `backend/internal/repositories/refresh_token.go`
- Modify: `backend/internal/services/token.go`
- Modify: `backend/internal/services/auth.go`
- Modify: `backend/internal/services/otp.go`
- Modify: `backend/internal/dto/requests/auth.go`
- Modify: `backend/internal/handlers/auth.go`
- Test: `backend/internal/services/main_test.go`, `backend/internal/services/fakes_test.go`, `backend/internal/services/token_test.go`

- [ ] **Step 1: Создай TestMain и общие фейки для пакета services**

`backend/internal/services/main_test.go`:

```go
package services

import (
	"os"
	"testing"

	"pora/internal/infrastructure/logger"
)

func TestMain(m *testing.M) {
	logger.InitLoggerTest()
	os.Exit(m.Run())
}
```

`backend/internal/services/fakes_test.go`:

```go
package services

import (
	"pora/internal/entities"
	"pora/internal/ports"

	"github.com/google/uuid"
)

// Фейки встраивают интерфейс: невызванные методы остаются nil
// и паникуют, если тест неожиданно их дёрнет

type fakeUserRepo struct {
	ports.UserRepository
	users map[uuid.UUID]*entities.User
}

func (f *fakeUserRepo) FindByID(id uuid.UUID) (*entities.User, error) {
	return f.users[id], nil
}

func (f *fakeUserRepo) UpdateUser(user *entities.User) error { return nil }

type deleteCall struct {
	userID uuid.UUID
	client string
}

type fakeRefreshTokenRepo struct {
	ports.RefreshTokenRepository
	deleted []deleteCall
	created []*entities.RefreshToken
}

func (f *fakeRefreshTokenRepo) DeleteByUserIDAndClient(userID uuid.UUID, client string) error {
	f.deleted = append(f.deleted, deleteCall{userID: userID, client: client})
	return nil
}

func (f *fakeRefreshTokenRepo) CreateRefreshToken(token *entities.RefreshToken) error {
	f.created = append(f.created, token)
	return nil
}

type recordedEvent struct {
	userID uuid.UUID
	name   string
	props  map[string]any
}

type fakeEmitter struct {
	events []recordedEvent
}

func (f *fakeEmitter) Emit(userID uuid.UUID, name string, props map[string]any) {
	f.events = append(f.events, recordedEvent{userID: userID, name: name, props: props})
}
```

- [ ] **Step 2: Напиши падающий тест на `CreateTokens`**

`backend/internal/services/token_test.go`:

```go
package services

import (
	"testing"

	"pora/internal/entities"

	"github.com/google/uuid"
)

func TestCreateTokensReplacesOnlySameClientToken(t *testing.T) {
	t.Setenv("JWT_TOKEN_KEY", "test-secret")

	user := &entities.User{ID: uuid.New()}
	tokens := &fakeRefreshTokenRepo{}
	service := NewTokenService(&fakeUserRepo{}, tokens)

	access, refresh, err := service.CreateTokens(user, entities.ClientAdmin)
	if err != nil {
		t.Fatalf("CreateTokens: %v", err)
	}
	if access == "" || refresh == "" {
		t.Fatal("ожидались непустые токены")
	}

	if len(tokens.deleted) != 1 || tokens.deleted[0] != (deleteCall{user.ID, entities.ClientAdmin}) {
		t.Fatalf("удаление = %+v, ожидалось только (user, admin)", tokens.deleted)
	}
	if len(tokens.created) != 1 || tokens.created[0].Client != entities.ClientAdmin {
		t.Fatalf("создан токен %+v, ожидался client=admin", tokens.created)
	}

	decoded, err := service.DecodeAccessToken("Bearer " + access)
	if err != nil || decoded != user.ID {
		t.Fatalf("DecodeAccessToken = %v, %v; want %v", decoded, err, user.ID)
	}
}
```

- [ ] **Step 3: Запусти — должен упасть**

Run: `cd backend && go test ./internal/services/ -run TestCreateTokens`
Expected: FAIL — ошибки компиляции (`too many arguments in call to service.CreateTokens`, `DeleteByUserIDAndClient` не в интерфейсе).

- [ ] **Step 4: Обнови порты**

В `backend/internal/ports/repositories.go` в интерфейсе `RefreshTokenRepository` замени метод `DeleteByUserID` (с комментарием) на:

```go
	// DeleteByUserIDAndClient удаляет refresh-токен пользователя для конкретного клиента
	DeleteByUserIDAndClient(userID uuid.UUID, client string) error
```

В `backend/internal/ports/services.go`:

в `AuthService` замени `RemoveRefreshToken(userID uuid.UUID) error` на

```go
	// RemoveRefreshToken удаляет refresh-токен пользователя для указанного клиента
	RemoveRefreshToken(userID uuid.UUID, client string) error
```

в `TokenService` замени `CreateTokens(user *entities.User) (string, string, error)` на

```go
	// CreateTokens создает новый access-токен, заменяет refresh-токен
	// пользователя для указанного клиента и возвращает оба токена
	CreateTokens(user *entities.User, client string) (string, string, error)
```

- [ ] **Step 5: Обнови репозиторий**

В `backend/internal/repositories/refresh_token.go` замени `DeleteByUserID` целиком на:

```go
// DeleteByUserIDAndClient удаляет refresh-токен пользователя для конкретного клиента
func (r *RefreshTokenRepo) DeleteByUserIDAndClient(
	userID uuid.UUID, client string) error {

	return r.db.Where("user_id = ? AND client = ?", userID, client).
		Delete(&entities.RefreshToken{}).Error
}
```

- [ ] **Step 6: Обнови `TokenService.CreateTokens`**

В `backend/internal/services/token.go` замени сигнатуру и начало метода:

```go
// CreateTokens создает новый access-токен, заменяет refresh-токен
// пользователя для указанного клиента и возвращает оба токена
func (s *TokenService) CreateTokens(
	user *entities.User, client string) (string, string, error) {

	client = entities.NormalizeClient(client)

	refreshToken, err := s.generateRefreshToken()
	if err != nil {
		logger.Log.Error("Ошибка при генерации refresh-токена: ", err)
		return "", "", err
	}

	err = s.refreshTokenRepo.DeleteByUserIDAndClient(user.ID, client)
	if err != nil {
		logger.Log.Error("Ошибка при обращении к БД: ", err)
		return "", "", err
	}

	newRefreshToken := &entities.RefreshToken{
		UserID: user.ID,
		Client: client,
		Token:  refreshToken,
	}
```

Остаток метода (от `err = s.refreshTokenRepo.CreateRefreshToken(newRefreshToken)` до конца) не меняется.

- [ ] **Step 7: Запусти тест — должен пройти только token_test; пакет ещё не собирается целиком**

Run: `cd backend && go vet ./internal/services/ 2>&1 | head -20`
Expected: ошибки только в `auth.go` и `otp.go` (вызовы `CreateTokens`/`DeleteByUserID`). Исправляем в следующих шагах.

- [ ] **Step 8: Обнови `AuthService`**

В `backend/internal/services/auth.go`, метод `GetNewTokens`: замени

```go
	accessToken, refreshTokenStr, err := s.TokenService.CreateTokens(user)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении токенов пользователя: ", err)
		return responses.RefreshResponse{}, err
	}

	login := &entities.UserLogin{
		UserID: user.ID,
	}

	err = s.userLoginRepo.CreateUserLogin(login)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении времени входа пользователя: ", err)
		return responses.RefreshResponse{}, err
	}
```

на

```go
	accessToken, refreshTokenStr, err := s.TokenService.CreateTokens(
		user, refreshToken.Client)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении токенов пользователя: ", err)
		return responses.RefreshResponse{}, err
	}

	// Вход в админ-панель не считается активностью пользователя приложения
	if refreshToken.Client == entities.ClientApp {
		login := &entities.UserLogin{
			UserID: user.ID,
		}

		err = s.userLoginRepo.CreateUserLogin(login)
		if err != nil {
			logger.Log.Error("Ошибка при сохранении времени входа пользователя: ", err)
			return responses.RefreshResponse{}, err
		}
	}
```

Замени `RemoveRefreshToken` целиком:

```go
// RemoveRefreshToken удаляет refresh-токен пользователя для указанного клиента
func (s *AuthService) RemoveRefreshToken(userID uuid.UUID, client string) error {

	err := s.refreshTokenRepo.DeleteByUserIDAndClient(
		userID, entities.NormalizeClient(client))
	if err != nil {
		logger.Log.Error("Ошибка при удалении Refresh-токена: ", err)
		return err
	}

	return nil
}
```

- [ ] **Step 9: Добавь `client` в запрос verify-otp**

В `backend/internal/dto/requests/auth.go` в `VerifyOtpRequest` после `DeviceType`:

```go

	// Client - "admin" для входа в админ-панель, иначе мобильное приложение
	Client string `json:"client"`
```

- [ ] **Step 10: Admin-gate и client в `OtpService.VerifyOtp`**

В `backend/internal/services/otp.go`, метод `VerifyOtp`. Сразу после блока

```go
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return responses.VerifyOtpResponse{}, err
	}

	userID := uuid.New()
```

вставь перед `userID := uuid.New()`:

```go
	client := entities.NormalizeClient(req.Client)

	// В админ-панель пускаем только существующих администраторов
	// и не создаем новых пользователей через форму входа админки
	if client == entities.ClientAdmin && (user == nil || !user.IsAdmin) {
		logger.Log.Warn("Попытка входа в админ-панель без прав администратора")
		return responses.VerifyOtpResponse{}, errors.ErrorForbidden
	}

```

Замени

```go
	accessToken, refreshToken, err := s.tokenService.CreateTokens(user)
```

на

```go
	accessToken, refreshToken, err := s.tokenService.CreateTokens(user, client)
```

- [ ] **Step 11: Logout приложения удаляет только app-токен**

В `backend/internal/handlers/auth.go`, метод `Logout`: замени

```go
	err = h.authService.RemoveRefreshToken(userID)
```

на

```go
	err = h.authService.RemoveRefreshToken(userID, entities.ClientApp)
```

и добавь `"pora/internal/entities"` в импорты.

- [ ] **Step 12: Сборка и тесты**

Run: `cd backend && go build ./... && go vet ./... && go test ./internal/services/ ./internal/entities/`
Expected: build/vet без вывода; `ok  	pora/internal/services`, `ok  	pora/internal/entities`

- [ ] **Step 13: Commit**

```bash
git -C backend add internal/ports internal/repositories/refresh_token.go \
  internal/services/token.go internal/services/auth.go internal/services/otp.go \
  internal/services/main_test.go internal/services/fakes_test.go internal/services/token_test.go \
  internal/dto/requests/auth.go internal/handlers/auth.go
git -C backend commit -m "feat(backend): per-client refresh tokens and admin-only OTP login"
```

---

### Task 4: Синхронизация администраторов из `ADMIN_EMAILS`

**Files:**
- Modify: `backend/internal/config/config.go`
- Modify: `backend/internal/ports/repositories.go` (`UserRepository`)
- Modify: `backend/internal/repositories/user.go`
- Modify: `backend/cmd/server/main.go`
- Test: `backend/internal/config/config_test.go`, `backend/internal/repositories/user_test.go`, `backend/internal/repositories/main_test.go`

- [ ] **Step 1: Напиши падающий тест на парсинг**

`backend/internal/config/config_test.go`:

```go
package config

import (
	"reflect"
	"testing"
)

func TestParseEmails(t *testing.T) {
	got := parseEmails(" Boss@Mail.ru, ,second@x.io,")
	want := []string{"boss@mail.ru", "second@x.io"}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("parseEmails = %v, want %v", got, want)
	}
	if len(parseEmails("")) != 0 {
		t.Fatal("пустая строка должна давать пустой список")
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/config/`
Expected: FAIL — `undefined: parseEmails`

- [ ] **Step 3: Добавь `AdminConfig`**

В `backend/internal/config/config.go`:

в `Config` добавь поле `Admin    AdminConfig` после `Deepseek DeepseekConfig`;

после `DeepseekConfig` добавь тип:

```go
// AdminConfig - конфигурация доступа к админ-панели аналитики
type AdminConfig struct {
	// Emails - почты администраторов (ADMIN_EMAILS через запятую)
	Emails []string
}
```

в литерал `return &Config{ ... }` внутри `Load()` добавь:

```go
		Admin: AdminConfig{
			Emails: parseEmails(os.Getenv("ADMIN_EMAILS")),
		},
```

в конец файла:

```go
// parseEmails разбирает список почт через запятую,
// приводит к нижнему регистру и отбрасывает пустые значения
func parseEmails(raw string) []string {
	var emails []string
	for _, part := range strings.Split(raw, ",") {
		email := strings.ToLower(strings.TrimSpace(part))
		if email != "" {
			emails = append(emails, email)
		}
	}
	return emails
}
```

и `"strings"` в импорты.

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test ./internal/config/`
Expected: `ok  	pora/internal/config`

- [ ] **Step 5: TestMain для пакета repositories и падающий интеграционный тест `SyncAdmins`**

`backend/internal/repositories/main_test.go`:

```go
package repositories

import (
	"os"
	"testing"

	"pora/internal/infrastructure/logger"
)

func TestMain(m *testing.M) {
	logger.InitLoggerTest()
	os.Exit(m.Run())
}
```

`backend/internal/repositories/user_test.go`:

```go
package repositories

import (
	"testing"
	"time"

	"pora/internal/testutil"
)

func TestSyncAdminsGrantsAndRevokes(t *testing.T) {
	db := testutil.OpenTestDB(t)
	now := time.Now()
	boss := testutil.SeedUser(t, db, "Boss@Mail.ru", now)
	former := testutil.SeedUser(t, db, "former@mail.ru", now)
	testutil.Exec(t, db, "UPDATE users SET is_admin = TRUE WHERE id = ?", former)

	repo := NewUserRepository(db)
	changed, err := repo.SyncAdmins([]string{"boss@mail.ru"})
	if err != nil {
		t.Fatalf("SyncAdmins: %v", err)
	}
	if changed != 2 {
		t.Fatalf("changed = %d, want 2", changed)
	}

	bossUser, _ := repo.FindByID(boss)
	formerUser, _ := repo.FindByID(former)
	if !bossUser.IsAdmin || formerUser.IsAdmin {
		t.Fatalf("boss.IsAdmin=%v former.IsAdmin=%v, want true/false",
			bossUser.IsAdmin, formerUser.IsAdmin)
	}
}
```

- [ ] **Step 6: Запусти — должен упасть**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: FAIL — `repo.SyncAdmins undefined`

- [ ] **Step 7: Реализуй `SyncAdmins`**

В `backend/internal/ports/repositories.go`, интерфейс `UserRepository`, после `UpdateUser`:

```go

	// SyncAdmins выставляет is_admin = true пользователям из списка почт
	// и снимает права у остальных. Возвращает число изменённых строк
	SyncAdmins(emails []string) (int64, error)
```

В конец `backend/internal/repositories/user.go`:

```go
// SyncAdmins выставляет is_admin = true пользователям из списка почт
// и снимает права у остальных. Возвращает число изменённых строк
func (r *UserRepo) SyncAdmins(emails []string) (int64, error) {
	if emails == nil {
		emails = []string{}
	}

	result := r.db.Exec(`
		UPDATE users
		SET is_admin = (LOWER(COALESCE(email, '')) = ANY(?))
		WHERE is_admin <> (LOWER(COALESCE(email, '')) = ANY(?))`,
		pq.Array(emails), pq.Array(emails))

	return result.RowsAffected, result.Error
}
```

и `"github.com/lib/pq"` в импорты.

- [ ] **Step 8: Запусти — должен пройти**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: `ok  	pora/internal/repositories` (или `SKIP`, если `TEST_DATABASE_URL` не задан — тогда задай его и повтори; этот тест также впервые проверяет миграцию из Task 1)

- [ ] **Step 9: Синхронизация на старте**

В `backend/cmd/server/main.go` сразу после строки `userLoginRepo := repositories.NewUserLoginRepository(db)`:

```go

	// Синхронизация администраторов с ADMIN_EMAILS
	changedAdmins, err := userRepo.SyncAdmins(cfg.Admin.Emails)
	if err != nil {
		logger.Log.Error("Ошибка при синхронизации администраторов: ", err)
	} else {
		logger.Log.Info("Права администраторов синхронизированы, изменено: ", changedAdmins)
	}
```

- [ ] **Step 10: Сборка и commit**

Run: `cd backend && go build ./... && go vet ./...`
Expected: без вывода.

```bash
git -C backend add internal/config internal/ports/repositories.go \
  internal/repositories/user.go internal/repositories/user_test.go \
  internal/repositories/main_test.go cmd/server/main.go
git -C backend commit -m "feat(backend): sync is_admin from ADMIN_EMAILS on startup"
```

---

### Task 5: `AdminMiddleware`

**Files:**
- Create: `backend/internal/middleware/admin.go`
- Test: `backend/internal/middleware/admin_test.go`

- [ ] **Step 1: Напиши падающие тесты**

`backend/internal/middleware/admin_test.go`:

```go
package middleware

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"pora/internal/entities"
	"pora/internal/errors"
	"pora/internal/ports"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type fakeTokens struct {
	ports.TokenService
	userID uuid.UUID
	err    error
}

func (f fakeTokens) DecodeAccessToken(string) (uuid.UUID, error) { return f.userID, f.err }

type fakeUsers struct {
	ports.UserRepository
	user *entities.User
}

func (f fakeUsers) FindByID(uuid.UUID) (*entities.User, error) { return f.user, nil }

func serveAdmin(t *testing.T, tokens ports.TokenService, users ports.UserRepository,
	authHeader string) (*httptest.ResponseRecorder, uuid.UUID) {
	t.Helper()

	var seen uuid.UUID
	r := gin.New()
	r.Use(ErrorHandler())
	r.GET("/admin", AdminMiddleware(tokens, users), func(c *gin.Context) {
		seen = AdminUserID(c)
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/admin", nil)
	if authHeader != "" {
		req.Header.Set("Authorization", authHeader)
	}
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w, seen
}

func TestAdminMiddleware(t *testing.T) {
	adminID := uuid.New()
	admin := &entities.User{ID: adminID, IsAdmin: true}
	plain := &entities.User{ID: adminID}

	cases := []struct {
		name   string
		tokens fakeTokens
		users  fakeUsers
		header string
		want   int
	}{
		{"нет заголовка", fakeTokens{}, fakeUsers{}, "", http.StatusUnauthorized},
		{"битый токен", fakeTokens{err: errors.ErrorInvalidInput}, fakeUsers{}, "Bearer x", http.StatusUnauthorized},
		{"истёкший токен", fakeTokens{err: errors.ErrorAccessExpired}, fakeUsers{}, "Bearer x", http.StatusUnauthorized},
		{"юзер не найден", fakeTokens{userID: adminID}, fakeUsers{}, "Bearer x", http.StatusForbidden},
		{"не админ", fakeTokens{userID: adminID}, fakeUsers{user: plain}, "Bearer x", http.StatusForbidden},
		{"админ", fakeTokens{userID: adminID}, fakeUsers{user: admin}, "Bearer x", http.StatusOK},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			w, seen := serveAdmin(t, tc.tokens, tc.users, tc.header)
			if w.Code != tc.want {
				t.Fatalf("status = %d, want %d", w.Code, tc.want)
			}
			if tc.want == http.StatusOK && seen != adminID {
				t.Fatalf("AdminUserID = %v, want %v", seen, adminID)
			}
		})
	}
}

func TestAdminMiddlewareKeepsAccessExpiredCode(t *testing.T) {
	w, _ := serveAdmin(t, fakeTokens{err: errors.ErrorAccessExpired}, fakeUsers{}, "Bearer x")
	if body := w.Body.String(); !strings.Contains(body, errors.CodeAccessExpired) {
		t.Fatalf("body = %s, ожидался код %s (по нему клиент делает refresh)", body, errors.CodeAccessExpired)
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/middleware/`
Expected: FAIL — `undefined: AdminMiddleware`, `undefined: AdminUserID`

- [ ] **Step 3: Реализуй middleware**

`backend/internal/middleware/admin.go`:

```go
// middleware - пакет, обечпечивающий взаимодействие между модулями приложения
package middleware

import (
	"pora/internal/errors"
	"pora/internal/infrastructure/logger"
	"pora/internal/ports"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// adminUserIDKey - ключ контекста gin с ID администратора
const adminUserIDKey = "admin-user-id"

// AdminMiddleware пропускает запрос только для пользователей с is_admin.
// Права проверяются по БД на каждый запрос, чтобы отзыв срабатывал сразу
func AdminMiddleware(tokenService ports.TokenService,
	userRepo ports.UserRepository) gin.HandlerFunc {

	return func(c *gin.Context) {
		rawToken := c.GetHeader("Authorization")
		if rawToken == "" {
			c.Error(errors.ErrorUnauthorized)
			c.Abort()
			return
		}

		userID, err := tokenService.DecodeAccessToken(rawToken)
		if err != nil {
			// Истёкший токен отдаём как есть — по его коду клиент делает refresh
			if appErr, ok := err.(errors.AppError); ok &&
				appErr.Code == errors.CodeAccessExpired {
				c.Error(err)
			} else {
				c.Error(errors.ErrorUnauthorized)
			}
			c.Abort()
			return
		}

		user, err := userRepo.FindByID(userID)
		if err != nil {
			logger.Log.Error("Ошибка при поиске администратора: ", err)
			c.Error(err)
			c.Abort()
			return
		}

		if user == nil || !user.IsAdmin {
			logger.Log.Warn("Запрос к админ-API без прав администратора")
			c.Error(errors.ErrorForbidden)
			c.Abort()
			return
		}

		c.Set(adminUserIDKey, userID)
		c.Next()
	}
}

// AdminUserID возвращает ID администратора, сохранённый AdminMiddleware
func AdminUserID(c *gin.Context) uuid.UUID {
	value, ok := c.Get(adminUserIDKey)
	if !ok {
		return uuid.Nil
	}
	userID, _ := value.(uuid.UUID)
	return userID
}
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test ./internal/middleware/`
Expected: `ok  	pora/internal/middleware`

- [ ] **Step 5: Commit**

```bash
git -C backend add internal/middleware/admin.go internal/middleware/admin_test.go
git -C backend commit -m "feat(backend): AdminMiddleware with per-request is_admin check"
```

---

### Task 6: Admin-маршруты (me / logout / push), удаление открытого notify-everyone, tzdata, graceful shutdown

**Files:**
- Create: `backend/internal/handlers/admin.go`
- Delete: `backend/internal/handlers/system.go`
- Modify: `backend/cmd/server/main.go`

`requests.NotifyEveryoneRequest` (`backend/internal/dto/requests/system.go`) остаётся и переиспользуется.

- [ ] **Step 1: Создай `AdminHandler` с базовыми методами**

`backend/internal/handlers/admin.go`:

```go
// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"net/http"
	"pora/internal/dto/requests"
	"pora/internal/dto/responses"
	"pora/internal/entities"
	"pora/internal/errors"
	"pora/internal/infrastructure/logger"
	"pora/internal/middleware"
	"pora/internal/ports"

	"github.com/gin-gonic/gin"
)

// AdminHandler - объект, содержащий методы для обработки
// запросов админ-панели аналитики. Все маршруты под AdminMiddleware
type AdminHandler struct {
	authService ports.AuthService
	userService ports.UserService
	pushService ports.PushService
}

// NewAdminHandler создает и возвращает новый объект AdminHandler
func NewAdminHandler(authService ports.AuthService,
	userService ports.UserService,
	pushService ports.PushService) *AdminHandler {
	return &AdminHandler{
		authService: authService,
		userService: userService,
		pushService: pushService,
	}
}

// Me возвращает профиль текущего администратора
func (h *AdminHandler) Me(c *gin.Context) {
	response, err := h.userService.GetMyInfo(middleware.AdminUserID(c))
	if err != nil {
		c.Error(err)
		return
	}

	c.JSON(http.StatusOK, response)
}

// Logout удаляет refresh-токен админ-панели (токен приложения не трогает)
func (h *AdminHandler) Logout(c *gin.Context) {
	err := h.authService.RemoveRefreshToken(
		middleware.AdminUserID(c), entities.ClientAdmin)
	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Выход из админ-панели выполнен")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// Push отправляет Push-уведомление всем пользователям приложения
func (h *AdminHandler) Push(c *gin.Context) {
	var req requests.NotifyEveryoneRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		logger.Log.Warn("Ошибка при десериализации запроса: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	err = h.pushService.NotifyEveryone(c.Request.Context(), req.Title, req.Body)
	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Рассылка всем пользователям выполнена администратором ",
		middleware.AdminUserID(c))
	c.JSON(http.StatusOK, responses.GenericResponse{})
}
```

- [ ] **Step 2: Удали открытый system-хэндлер**

```bash
git -C backend rm internal/handlers/system.go
```

- [ ] **Step 3: Обнови `main.go`: импорты**

В `backend/cmd/server/main.go` замени блок импортов на:

```go
import (
	"context"
	goErrors "errors"
	"net/http"
	"os"
	"os/signal"
	"pora/internal/config"
	"pora/internal/handlers"
	"pora/internal/infrastructure/database"
	"syscall"
	"time"
	_ "time/tzdata"

	// "pora/internal/infrastructure/deepseek"
	"pora/internal/infrastructure/firebase"
	"pora/internal/infrastructure/logger"
	"pora/internal/infrastructure/storage"
	"pora/internal/middleware"
	"pora/internal/repositories"
	"pora/internal/scheduler"
	"pora/internal/services"
	"pora/internal/websocket"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)
```

Если в файле остался закомментированный импорт `// "net/http"` выше — удали его (теперь `net/http` используется).

- [ ] **Step 4: Обнови `main.go`: контекст остановки**

Удали блок

```go
	// Остановка приложения после завершения контекста
	go func() {
		<-ctx.Done()
		stop()
	}()
```

(остановка теперь обрабатывается в конце `main`, `defer stop()` остаётся).

- [ ] **Step 5: Обнови `main.go`: хэндлер и маршруты**

Замени строку `systemHander := handlers.NewSystemHandler(pushService)` на:

```go
	adminHandler := handlers.NewAdminHandler(authService, userService, pushService)
```

Замени блок

```go
	system := api.Group("/system")
	{
		system.POST("/notify-everyone", systemHander.NotifyEveryone)
	}
```

на

```go
	admin := api.Group("/admin", middleware.AdminMiddleware(tokenService, userRepo))
	{
		admin.GET("/me", adminHandler.Me)
		admin.POST("/logout", adminHandler.Logout)
		admin.POST("/push", adminHandler.Push)
	}
```

- [ ] **Step 6: Обнови `main.go`: graceful shutdown**

Замени хвост `main` от `// Запуск сервера` до конца функции на:

```go
	// Запуск сервера
	port := os.Getenv("PORT")
	server := &http.Server{
		Addr:    ":" + port,
		Handler: r,
	}

	go func() {
		logger.Log.Info("Сервер запущен на порту :" + port)
		err := server.ListenAndServe()
		if err != nil && !goErrors.Is(err, http.ErrServerClosed) {
			logger.Log.Fatal("Ошибка HTTP-сервера: ", err)
		}
	}()

	<-ctx.Done()
	logger.Log.Info("Получен сигнал остановки, завершаем работу")

	shutdownCtx, cancelShutdown := context.WithTimeout(
		context.Background(), 5*time.Second)
	defer cancelShutdown()

	if err := server.Shutdown(shutdownCtx); err != nil {
		logger.Log.Error("Ошибка при остановке HTTP-сервера: ", err)
	}
}
```

- [ ] **Step 7: Сборка**

Run: `cd backend && go build ./... && go vet ./... && go test ./internal/middleware/ ./internal/services/`
Expected: build/vet без вывода, тесты `ok`.

- [ ] **Step 8: Ручная проверка на docker-compose**

Добавь в `backend/.env` строку `ADMIN_EMAILS=<твоя почта, которой логинишься в приложении>` (файл в `.gitignore`, не коммитится), затем:

```bash
docker compose -f backend/docker-compose.yml up -d --build
curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:5040/api/system/notify-everyone -H 'Content-Type: application/json' -d '{"title":"x","body":"y"}'
curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:5040/api/admin/push -H 'Content-Type: application/json' -d '{"title":"x","body":"y"}'
docker compose -f backend/docker-compose.yml logs app | grep -E "Права администраторов|Миграции"
```

Expected: `404` (старый маршрут удалён), `401` (без токена), в логах `Миграции успешно применены` и `Права администраторов синхронизированы, изменено: 1`.

- [ ] **Step 9: Commit**

```bash
git -C backend add internal/handlers/admin.go cmd/server/main.go
git -C backend commit -m "feat(backend): /api/admin group; remove unauthenticated notify-everyone"
```

---

### Task 7: Репозиторий событий

**Files:**
- Modify: `backend/internal/ports/repositories.go`
- Create: `backend/internal/repositories/analytics_event.go`
- Test: `backend/internal/repositories/analytics_event_test.go`

- [ ] **Step 1: Добавь порт**

В конец `backend/internal/ports/repositories.go`:

```go
// AnalyticsEventRepository содержит порты для методов
// работы с событиями продуктовой аналитики
type AnalyticsEventRepository interface {
	// InsertBatch сохраняет события; дубликаты по ID молча пропускаются
	InsertBatch(events []entities.AnalyticsEvent) error

	// DeleteOlderThan удаляет события, произошедшие раньше cutoff
	DeleteOlderThan(cutoff time.Time) (int64, error)

	// FindRecentByUserID возвращает последние события пользователя
	FindRecentByUserID(userID uuid.UUID, limit int) (
		[]entities.AnalyticsEvent, error)
}
```

Добавь `"time"` в импорты файла, если его нет.

- [ ] **Step 2: Напиши падающий интеграционный тест**

`backend/internal/repositories/analytics_event_test.go`:

```go
package repositories

import (
	"testing"
	"time"

	"pora/internal/entities"
	"pora/internal/testutil"

	"github.com/google/uuid"
)

func TestAnalyticsEventRepo(t *testing.T) {
	db := testutil.OpenTestDB(t)
	repo := NewAnalyticsEventRepository(db)

	now := time.Now().UTC()
	userID := testutil.SeedUser(t, db, "events@test.io", now)

	event := entities.AnalyticsEvent{
		ID:         uuid.New(),
		UserID:     &userID,
		Name:       entities.EventItemAdded,
		Props:      `{"name":"молоко"}`,
		Source:     entities.EventSourceServer,
		Platform:   entities.PlatformServer,
		OccurredAt: now,
	}
	old := entities.AnalyticsEvent{
		UserID:     &userID,
		Name:       entities.EventItemBought,
		Source:     entities.EventSourceServer,
		OccurredAt: now.AddDate(-2, 0, 0),
	}

	// Повторная вставка того же ID не должна давать дубль или ошибку
	if err := repo.InsertBatch([]entities.AnalyticsEvent{event, old}); err != nil {
		t.Fatalf("InsertBatch: %v", err)
	}
	if err := repo.InsertBatch([]entities.AnalyticsEvent{event}); err != nil {
		t.Fatalf("повторный InsertBatch: %v", err)
	}

	recent, err := repo.FindRecentByUserID(userID, 10)
	if err != nil || len(recent) != 2 {
		t.Fatalf("FindRecentByUserID = %d событий, %v; want 2", len(recent), err)
	}
	if recent[0].ID != event.ID {
		t.Fatal("события должны идти от новых к старым")
	}

	deleted, err := repo.DeleteOlderThan(now.AddDate(-1, 0, 0))
	if err != nil || deleted != 1 {
		t.Fatalf("DeleteOlderThan = %d, %v; want 1", deleted, err)
	}

	if err := repo.InsertBatch(nil); err != nil {
		t.Fatalf("пустой батч должен быть no-op: %v", err)
	}
}
```

- [ ] **Step 3: Запусти — должен упасть**

Run: `cd backend && go test -p 1 ./internal/repositories/ -run TestAnalyticsEventRepo`
Expected: FAIL — `undefined: NewAnalyticsEventRepository`

- [ ] **Step 4: Реализуй репозиторий**

`backend/internal/repositories/analytics_event.go`:

```go
// repositories - пакет с методами для работы с БД
package repositories

import (
	"pora/internal/entities"
	"pora/internal/ports"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// analyticsInsertBatchSize - размер пачки при вставке событий
const analyticsInsertBatchSize = 100

// AnalyticsEventRepo - объект, содержащий методы для работы с событиями аналитики
type AnalyticsEventRepo struct {
	db *gorm.DB
}

// NewAnalyticsEventRepository создает и возвращает новый объект AnalyticsEventRepo
func NewAnalyticsEventRepository(db *gorm.DB) ports.AnalyticsEventRepository {
	return &AnalyticsEventRepo{db: db}
}

// InsertBatch сохраняет события; дубликаты по ID молча пропускаются
func (r *AnalyticsEventRepo) InsertBatch(events []entities.AnalyticsEvent) error {
	if len(events) == 0 {
		return nil
	}

	return r.db.
		Clauses(clause.OnConflict{DoNothing: true}).
		CreateInBatches(events, analyticsInsertBatchSize).
		Error
}

// DeleteOlderThan удаляет события, произошедшие раньше cutoff
func (r *AnalyticsEventRepo) DeleteOlderThan(cutoff time.Time) (int64, error) {
	result := r.db.
		Where("occurred_at < ?", cutoff).
		Delete(&entities.AnalyticsEvent{})

	return result.RowsAffected, result.Error
}

// FindRecentByUserID возвращает последние события пользователя
func (r *AnalyticsEventRepo) FindRecentByUserID(userID uuid.UUID,
	limit int) ([]entities.AnalyticsEvent, error) {

	var events []entities.AnalyticsEvent

	err := r.db.
		Where("user_id = ?", userID).
		Order("occurred_at DESC").
		Limit(limit).
		Find(&events).
		Error

	return events, err
}
```

- [ ] **Step 5: Запусти — должен пройти**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: `ok  	pora/internal/repositories`

- [ ] **Step 6: Commit**

```bash
git -C backend add internal/ports/repositories.go internal/repositories/analytics_event.go \
  internal/repositories/analytics_event_test.go
git -C backend commit -m "feat(backend): analytics events repository with idempotent batch insert"
```

---

### Task 8: `AnalyticsService` — асинхронный emitter и очистка

**Files:**
- Modify: `backend/internal/ports/services.go`
- Create: `backend/internal/services/analytics.go`
- Create: `backend/internal/dto/requests/analytics.go`
- Create: `backend/internal/dto/responses/analytics.go`
- Test: `backend/internal/services/analytics_test.go`

- [ ] **Step 1: DTO ingest-запроса и ответа**

`backend/internal/dto/requests/analytics.go`:

```go
// requests - пакет, содержащий структуры запросов по Api
package requests

import "time"

// IngestEventsRequest - батч клиентских событий аналитики
type IngestEventsRequest struct {
	Events []ClientEvent `json:"events" binding:"required"`
}

// ClientEvent - одно клиентское событие аналитики.
// ID генерирует клиент (UUID) — по нему отсекаются повторы
type ClientEvent struct {
	ID         string         `json:"id"`
	Name       string         `json:"name"`
	Props      map[string]any `json:"props"`
	Platform   string         `json:"platform"`
	AppVersion string         `json:"app-version"`
	OccurredAt time.Time      `json:"occurred-at"`
}
```

`backend/internal/dto/responses/analytics.go`:

```go
// responses - пакет, содержащий структуры ответов на Api запросы
package responses

// IngestEventsResponse - результат приёма батча клиентских событий
type IngestEventsResponse struct {
	Accepted int `json:"accepted"`
	Rejected int `json:"rejected"`
}
```

- [ ] **Step 2: Порты**

В конец `backend/internal/ports/services.go`:

```go
// EventEmitter содержит порт для записи серверных событий аналитики
type EventEmitter interface {
	// Emit ставит событие в очередь на запись. Никогда не блокирует
	// и не возвращает ошибку: аналитика не должна ломать бизнес-операцию
	Emit(userID uuid.UUID, name string, props map[string]any)
}

// AnalyticsService содержит порты для методов сбора событий аналитики
type AnalyticsService interface {
	EventEmitter

	// Ingest валидирует и сохраняет батч клиентских событий
	Ingest(userID uuid.UUID, req requests.IngestEventsRequest) (
		responses.IngestEventsResponse, error)

	// Run запускает фоновую запись серверных событий до отмены ctx,
	// после чего дописывает оставшийся буфер
	Run(ctx context.Context)

	// Cleanup удаляет события старше срока хранения
	Cleanup(ctx context.Context) error
}
```

- [ ] **Step 3: Напиши падающие тесты emitter'а**

`backend/internal/services/analytics_test.go`:

```go
package services

import (
	"context"
	"encoding/json"
	"sync"
	"testing"
	"time"

	"pora/internal/entities"
	"pora/internal/ports"

	"github.com/google/uuid"
)

type fakeEventRepo struct {
	ports.AnalyticsEventRepository
	mu       sync.Mutex
	inserted []entities.AnalyticsEvent
	cutoff   time.Time
}

func (f *fakeEventRepo) InsertBatch(events []entities.AnalyticsEvent) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.inserted = append(f.inserted, events...)
	return nil
}

func (f *fakeEventRepo) DeleteOlderThan(cutoff time.Time) (int64, error) {
	f.cutoff = cutoff
	return 3, nil
}

func (f *fakeEventRepo) count() int {
	f.mu.Lock()
	defer f.mu.Unlock()
	return len(f.inserted)
}

func TestEmitIsDrainedOnShutdown(t *testing.T) {
	repo := &fakeEventRepo{}
	service := NewAnalyticsService(repo)
	service.flushEvery = time.Hour // флаш только по остановке

	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan struct{})
	go func() { service.Run(ctx); close(done) }()

	userID := uuid.New()
	service.Emit(userID, entities.EventItemBought, map[string]any{"name": "молоко"})
	service.Emit(uuid.Nil, entities.EventUserSignedUp, nil)

	cancel()
	<-done

	if repo.count() != 2 {
		t.Fatalf("записано %d событий, want 2", repo.count())
	}

	first := repo.inserted[0]
	if first.UserID == nil || *first.UserID != userID {
		t.Fatalf("UserID = %v, want %v", first.UserID, userID)
	}
	if first.Source != entities.EventSourceServer || first.Platform != entities.PlatformServer {
		t.Fatalf("source/platform = %s/%s", first.Source, first.Platform)
	}
	var props map[string]any
	if err := json.Unmarshal([]byte(first.Props), &props); err != nil || props["name"] != "молоко" {
		t.Fatalf("props = %s, %v", first.Props, err)
	}
	if repo.inserted[1].UserID != nil {
		t.Fatal("uuid.Nil должен сохраняться как NULL")
	}
}

func TestEmitFlushesFullBatch(t *testing.T) {
	repo := &fakeEventRepo{}
	service := NewAnalyticsService(repo)
	service.flushEvery = time.Hour

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go service.Run(ctx)

	for i := 0; i < analyticsBatchSize; i++ {
		service.Emit(uuid.New(), entities.EventItemAdded, nil)
	}

	deadline := time.Now().Add(2 * time.Second)
	for repo.count() < analyticsBatchSize && time.Now().Before(deadline) {
		time.Sleep(10 * time.Millisecond)
	}
	if repo.count() != analyticsBatchSize {
		t.Fatalf("полный батч не записан: %d", repo.count())
	}
}

func TestEmitDropsWhenQueueFull(t *testing.T) {
	service := NewAnalyticsService(&fakeEventRepo{})
	// Run не запущен — очередь никто не читает; Emit не должен блокироваться
	for i := 0; i < analyticsBufferSize+10; i++ {
		service.Emit(uuid.New(), entities.EventItemAdded, nil)
	}
	if len(service.queue) != analyticsBufferSize {
		t.Fatalf("len(queue) = %d, want %d", len(service.queue), analyticsBufferSize)
	}
}

func TestCleanupUsesRetention(t *testing.T) {
	repo := &fakeEventRepo{}
	service := NewAnalyticsService(repo)
	fixed := time.Date(2026, 10, 15, 12, 0, 0, 0, time.UTC)
	service.now = func() time.Time { return fixed }

	if err := service.Cleanup(context.Background()); err != nil {
		t.Fatalf("Cleanup: %v", err)
	}
	if !repo.cutoff.Equal(fixed.Add(-analyticsRetention)) {
		t.Fatalf("cutoff = %v", repo.cutoff)
	}
}
```

- [ ] **Step 4: Запусти — должен упасть**

Run: `cd backend && go test ./internal/services/ -run 'Emit|Cleanup'`
Expected: FAIL — `undefined: NewAnalyticsService`

- [ ] **Step 5: Реализуй emitter**

`backend/internal/services/analytics.go`:

```go
// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"context"
	"encoding/json"
	"pora/internal/dto/requests"
	"pora/internal/dto/responses"
	"pora/internal/entities"
	"pora/internal/errors"
	"pora/internal/infrastructure/logger"
	"pora/internal/ports"
	"time"

	"github.com/google/uuid"
)

const (
	// analyticsBufferSize - ёмкость очереди серверных событий
	analyticsBufferSize = 1024
	// analyticsBatchSize - сколько событий пишется в БД за раз
	analyticsBatchSize = 100
	// analyticsFlushEvery - как часто сбрасывать неполный батч
	analyticsFlushEvery = 2 * time.Second
	// analyticsRetention - срок хранения событий
	analyticsRetention = 365 * 24 * time.Hour
)

// AnalyticsService - объект, содержащий методы для сбора событий аналитики:
// асинхронную запись серверных событий и приём клиентских батчей
type AnalyticsService struct {
	repo       ports.AnalyticsEventRepository
	queue      chan entities.AnalyticsEvent
	now        func() time.Time
	flushEvery time.Duration
}

// NewAnalyticsService создает и возвращает новый объект AnalyticsService.
// Для записи серверных событий нужно запустить Run в отдельной горутине
func NewAnalyticsService(repo ports.AnalyticsEventRepository) *AnalyticsService {
	return &AnalyticsService{
		repo:       repo,
		queue:      make(chan entities.AnalyticsEvent, analyticsBufferSize),
		now:        func() time.Time { return time.Now().UTC() },
		flushEvery: analyticsFlushEvery,
	}
}

// Emit ставит серверное событие в очередь на запись.
// При переполненной очереди событие отбрасывается с предупреждением
func (s *AnalyticsService) Emit(userID uuid.UUID, name string,
	props map[string]any) {

	event := entities.AnalyticsEvent{
		ID:         uuid.New(),
		Name:       name,
		Props:      encodeProps(props),
		Platform:   entities.PlatformServer,
		Source:     entities.EventSourceServer,
		OccurredAt: s.now(),
	}

	if userID != uuid.Nil {
		id := userID
		event.UserID = &id
	}

	select {
	case s.queue <- event:
	default:
		logger.Log.Warn("Очередь аналитики переполнена, событие отброшено: ", name)
	}
}

// Run записывает события из очереди пачками до отмены ctx,
// после чего дописывает всё, что осталось в очереди
func (s *AnalyticsService) Run(ctx context.Context) {
	ticker := time.NewTicker(s.flushEvery)
	defer ticker.Stop()

	batch := make([]entities.AnalyticsEvent, 0, analyticsBatchSize)

	flush := func() {
		if len(batch) == 0 {
			return
		}
		if err := s.repo.InsertBatch(batch); err != nil {
			logger.Log.Error("Ошибка при сохранении событий аналитики: ", err)
		}
		batch = make([]entities.AnalyticsEvent, 0, analyticsBatchSize)
	}

	add := func(event entities.AnalyticsEvent) {
		batch = append(batch, event)
		if len(batch) >= analyticsBatchSize {
			flush()
		}
	}

	for {
		select {
		case event := <-s.queue:
			add(event)

		case <-ticker.C:
			flush()

		case <-ctx.Done():
			for {
				select {
				case event := <-s.queue:
					add(event)
				default:
					flush()
					return
				}
			}
		}
	}
}

// Cleanup удаляет события старше срока хранения
func (s *AnalyticsService) Cleanup(ctx context.Context) error {
	deleted, err := s.repo.DeleteOlderThan(s.now().Add(-analyticsRetention))
	if err != nil {
		return err
	}

	if deleted > 0 {
		logger.Log.Info("Удалено устаревших событий аналитики: ", deleted)
	}
	return nil
}

// Ingest валидирует и сохраняет батч клиентских событий.
// Невалидные события отбрасываются поштучно и учитываются в Rejected
func (s *AnalyticsService) Ingest(userID uuid.UUID,
	req requests.IngestEventsRequest) (responses.IngestEventsResponse, error) {

	var response responses.IngestEventsResponse

	if len(req.Events) > maxIngestBatch {
		logger.Log.Warn("Слишком большой батч событий: ", len(req.Events))
		return response, errors.ErrorInvalidInput
	}

	now := s.now()
	accepted := make([]entities.AnalyticsEvent, 0, len(req.Events))

	for _, raw := range req.Events {
		event, ok := validateClientEvent(raw, userID, now)
		if !ok {
			response.Rejected++
			continue
		}
		accepted = append(accepted, event)
	}

	if err := s.repo.InsertBatch(accepted); err != nil {
		logger.Log.Error("Ошибка при сохранении клиентских событий: ", err)
		return response, err
	}

	response.Accepted = len(accepted)
	return response, nil
}

// encodeProps сериализует props события в JSON-строку
func encodeProps(props map[string]any) string {
	if len(props) == 0 {
		return "{}"
	}

	raw, err := json.Marshal(props)
	if err != nil {
		logger.Log.Warn("Не удалось сериализовать props события: ", err)
		return "{}"
	}
	return string(raw)
}
```

- [ ] **Step 6: Временная заглушка валидации, чтобы пакет собрался**

Создай `backend/internal/services/analytics_validation.go` (полная реализация — в Task 9):

```go
// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"pora/internal/dto/requests"
	"pora/internal/entities"
	"time"

	"github.com/google/uuid"
)

// maxIngestBatch - максимум событий в одном клиентском батче
const maxIngestBatch = 100

// validateClientEvent проверяет клиентское событие и приводит его к сущности
func validateClientEvent(raw requests.ClientEvent, userID uuid.UUID,
	now time.Time) (entities.AnalyticsEvent, bool) {
	return entities.AnalyticsEvent{}, false
}
```

- [ ] **Step 7: Запусти — должен пройти**

Run: `cd backend && go test -race ./internal/services/ -run 'Emit|Cleanup'`
Expected: `ok  	pora/internal/services`

- [ ] **Step 8: Commit**

```bash
git -C backend add internal/ports/services.go internal/services/analytics.go \
  internal/services/analytics_validation.go internal/services/analytics_test.go \
  internal/dto/requests/analytics.go internal/dto/responses/analytics.go
git -C backend commit -m "feat(backend): async analytics emitter with drain on shutdown"
```

---

### Task 9: Валидация и ingest-эндпоинт клиентских событий

**Files:**
- Modify: `backend/internal/services/analytics_validation.go`
- Create: `backend/internal/handlers/analytics.go`
- Modify: `backend/cmd/server/main.go`
- Test: `backend/internal/services/analytics_validation_test.go`

**Контракт для плана 2 (Flutter):**

```
POST /api/analytics/events
Authorization: Bearer <access>
{"events":[{"id":"<uuid v4>","name":"session_start","props":{},"platform":"ios|android","app-version":"1.4.0","occurred-at":"2026-10-15T10:00:00Z"}]}
→ 202 {"accepted":1,"rejected":0}
→ 400 INVALID_INPUT: >100 событий, тело >64KB, невалидный JSON/дата, битый токен
→ 401 ACCESS_TOKEN_EXPIRED: истёкший токен (Dio-интерцептор делает refresh)
```

- [ ] **Step 1: Напиши падающие тесты валидации**

`backend/internal/services/analytics_validation_test.go`:

```go
package services

import (
	"encoding/json"
	"strings"
	"testing"
	"time"

	"pora/internal/dto/requests"
	"pora/internal/entities"

	"github.com/google/uuid"
)

var validationNow = time.Date(2026, 10, 15, 12, 0, 0, 0, time.UTC)

func validEvent() requests.ClientEvent {
	return requests.ClientEvent{
		ID:         uuid.NewString(),
		Name:       entities.EventRecipeImport,
		Props:      map[string]any{"source": "youtube", "list_id": "secret", "name": "борщ"},
		Platform:   "ios",
		AppVersion: "1.4.0",
		OccurredAt: validationNow.Add(-time.Hour),
	}
}

func TestValidateClientEventAcceptsAndFiltersProps(t *testing.T) {
	userID := uuid.New()
	event, ok := validateClientEvent(validEvent(), userID, validationNow)
	if !ok {
		t.Fatal("валидное событие отклонено")
	}
	if event.Source != entities.EventSourceClient || *event.UserID != userID {
		t.Fatalf("source=%s user=%v", event.Source, event.UserID)
	}

	var props map[string]any
	if err := json.Unmarshal([]byte(event.Props), &props); err != nil {
		t.Fatal(err)
	}
	if len(props) != 1 || props["source"] != "youtube" {
		t.Fatalf("props = %v, ожидался только source (whitelist)", props)
	}
}

func TestValidateClientEventRejects(t *testing.T) {
	cases := map[string]func(e *requests.ClientEvent){
		"неизвестное имя":       func(e *requests.ClientEvent) { e.Name = "item_added" },
		"битый id":              func(e *requests.ClientEvent) { e.ID = "nope" },
		"нулевой id":            func(e *requests.ClientEvent) { e.ID = uuid.Nil.String() },
		"неизвестная платформа": func(e *requests.ClientEvent) { e.Platform = "web" },
		"нет времени":           func(e *requests.ClientEvent) { e.OccurredAt = time.Time{} },
		"слишком старое":        func(e *requests.ClientEvent) { e.OccurredAt = validationNow.AddDate(0, 0, -31) },
		"из будущего":           func(e *requests.ClientEvent) { e.OccurredAt = validationNow.Add(6 * time.Minute) },
	}

	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			event := validEvent()
			mutate(&event)
			if _, ok := validateClientEvent(event, uuid.New(), validationNow); ok {
				t.Fatal("событие должно быть отклонено")
			}
		})
	}
}

func TestValidateClientEventTruncatesStrings(t *testing.T) {
	event := validEvent()
	event.Name = entities.EventScreenView
	event.Props = map[string]any{"screen": strings.Repeat("x", 100)}
	event.AppVersion = strings.Repeat("9", 50)

	result, ok := validateClientEvent(event, uuid.New(), validationNow)
	if !ok {
		t.Fatal("событие отклонено")
	}
	var props map[string]string
	_ = json.Unmarshal([]byte(result.Props), &props)
	if len(props["screen"]) != maxPropStringLen || len(result.AppVersion) != maxAppVersionLen {
		t.Fatalf("screen=%d appVersion=%d", len(props["screen"]), len(result.AppVersion))
	}
}

func TestIngestCountsAcceptedAndRejected(t *testing.T) {
	repo := &fakeEventRepo{}
	service := NewAnalyticsService(repo)
	service.now = func() time.Time { return validationNow }

	bad := validEvent()
	bad.Name = "unknown"

	response, err := service.Ingest(uuid.New(), requests.IngestEventsRequest{
		Events: []requests.ClientEvent{validEvent(), bad},
	})
	if err != nil {
		t.Fatalf("Ingest: %v", err)
	}
	if response.Accepted != 1 || response.Rejected != 1 || repo.count() != 1 {
		t.Fatalf("response=%+v inserted=%d", response, repo.count())
	}
}

func TestIngestRejectsOversizedBatch(t *testing.T) {
	service := NewAnalyticsService(&fakeEventRepo{})
	events := make([]requests.ClientEvent, maxIngestBatch+1)
	if _, err := service.Ingest(uuid.New(), requests.IngestEventsRequest{Events: events}); err == nil {
		t.Fatal("ожидалась ошибка для батча > 100")
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/services/ -run 'Validate|Ingest'`
Expected: FAIL — `undefined: maxPropStringLen`, `undefined: maxAppVersionLen`

- [ ] **Step 3: Реализуй валидацию**

Замени содержимое `backend/internal/services/analytics_validation.go` целиком:

```go
// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"pora/internal/dto/requests"
	"pora/internal/entities"
	"time"

	"github.com/google/uuid"
)

const (
	// maxIngestBatch - максимум событий в одном клиентском батче
	maxIngestBatch = 100
	// maxPropStringLen - максимальная длина строкового значения props
	maxPropStringLen = 64
	// maxAppVersionLen - максимальная длина версии приложения
	maxAppVersionLen = 32
	// ingestPastWindow - насколько старые события принимаются
	ingestPastWindow = 30 * 24 * time.Hour
	// ingestFutureWindow - допустимое опережение часов клиента
	ingestFutureWindow = 5 * time.Minute
)

// clientEventProps - whitelist клиентских событий и разрешённых в них props.
// Названия товаров и свободный текст с клиента не принимаются
var clientEventProps = map[string]map[string]bool{
	entities.EventSessionStart:       {},
	entities.EventScreenView:         {"screen": true},
	entities.EventAiChatOpened:       {},
	entities.EventAiMessageSent:      {},
	entities.EventAiTipGenerated:     {},
	entities.EventRecipeImport:       {"source": true},
	entities.EventSupportMessageSent: {},
	entities.EventViewModeChanged:    {"grid": true},
}

// clientPlatforms - допустимые платформы клиентских событий
var clientPlatforms = map[string]bool{
	"ios":     true,
	"android": true,
}

// validateClientEvent проверяет клиентское событие и приводит его к сущности.
// Неразрешённые props отбрасываются, само событие при этом принимается
func validateClientEvent(raw requests.ClientEvent, userID uuid.UUID,
	now time.Time) (entities.AnalyticsEvent, bool) {

	allowedProps, ok := clientEventProps[raw.Name]
	if !ok {
		return entities.AnalyticsEvent{}, false
	}

	id, err := uuid.Parse(raw.ID)
	if err != nil || id == uuid.Nil {
		return entities.AnalyticsEvent{}, false
	}

	if !clientPlatforms[raw.Platform] {
		return entities.AnalyticsEvent{}, false
	}

	occurredAt := raw.OccurredAt.UTC()
	if raw.OccurredAt.IsZero() ||
		occurredAt.Before(now.Add(-ingestPastWindow)) ||
		occurredAt.After(now.Add(ingestFutureWindow)) {
		return entities.AnalyticsEvent{}, false
	}

	props := make(map[string]any, len(raw.Props))
	for key, value := range raw.Props {
		if !allowedProps[key] {
			continue
		}
		switch typed := value.(type) {
		case string:
			props[key] = truncateRunes(typed, maxPropStringLen)
		case bool, float64:
			props[key] = typed
		}
	}

	owner := userID
	return entities.AnalyticsEvent{
		ID:         id,
		UserID:     &owner,
		Name:       raw.Name,
		Props:      encodeProps(props),
		Platform:   raw.Platform,
		AppVersion: truncateRunes(raw.AppVersion, maxAppVersionLen),
		Source:     entities.EventSourceClient,
		OccurredAt: occurredAt,
	}, true
}

// truncateRunes обрезает строку до max символов (не байт)
func truncateRunes(value string, max int) string {
	runes := []rune(value)
	if len(runes) <= max {
		return value
	}
	return string(runes[:max])
}
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test ./internal/services/`
Expected: `ok  	pora/internal/services`

- [ ] **Step 5: Хэндлер ingest**

`backend/internal/handlers/analytics.go`:

```go
// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"net/http"
	"pora/internal/dto/requests"
	"pora/internal/errors"
	"pora/internal/infrastructure/logger"
	"pora/internal/ports"

	"github.com/gin-gonic/gin"
)

// maxIngestBodyBytes - максимальный размер тела батча событий
const maxIngestBodyBytes = 64 << 10

// AnalyticsHandler - объект, содержащий методы для приёма событий аналитики
type AnalyticsHandler struct {
	analyticsService ports.AnalyticsService
	tokenService     ports.TokenService
}

// NewAnalyticsHandler создает и возвращает новый объект AnalyticsHandler
func NewAnalyticsHandler(analyticsService ports.AnalyticsService,
	tokenService ports.TokenService) *AnalyticsHandler {
	return &AnalyticsHandler{
		analyticsService: analyticsService,
		tokenService:     tokenService,
	}
}

// IngestEvents принимает батч клиентских событий аналитики
func (h *AnalyticsHandler) IngestEvents(c *gin.Context) {

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		logger.Log.Warn("Возникла ошибка при декодировании Access-токена")
		c.Error(err)
		return
	}

	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, maxIngestBodyBytes)

	var req requests.IngestEventsRequest

	err = c.ShouldBindJSON(&req)
	if err != nil {
		logger.Log.Warn("Ошибка при десериализации батча событий: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.analyticsService.Ingest(userID, req)
	if err != nil {
		c.Error(err)
		return
	}

	c.JSON(http.StatusAccepted, response)
}
```

- [ ] **Step 6: Wiring в `main.go`**

После строки `userLoginRepo := repositories.NewUserLoginRepository(db)` (и до блока синхронизации админов) добавь:

```go
	analyticsEventRepo := repositories.NewAnalyticsEventRepository(db)
```

В начало блока «Подключение сервисов» (первой строкой) добавь:

```go
	analyticsService := services.NewAnalyticsService(analyticsEventRepo)
```

В блок хэндлеров:

```go
	analyticsHandler := handlers.NewAnalyticsHandler(analyticsService, tokenService)
```

После `go checkedScheduler.Run(ctx)`:

```go

	// Запись серверных событий аналитики. Отдельный контекст: останавливаем
	// только после HTTP-сервера, чтобы не потерять события последних запросов
	analyticsCtx, stopAnalytics := context.WithCancel(context.Background())
	analyticsDone := make(chan struct{})
	go func() {
		analyticsService.Run(analyticsCtx)
		close(analyticsDone)
	}()

	analyticsCleanupScheduler := scheduler.NewScheduler(24*time.Hour, analyticsService.Cleanup)
	go analyticsCleanupScheduler.Run(ctx)
```

Маршрут — после блока `help := api.Group("/help") { ... }`:

```go
	api.POST("/analytics/events", analyticsHandler.IngestEvents)
```

В конце `main`, после блока `if err := server.Shutdown(shutdownCtx); ...`:

```go

	stopAnalytics()
	<-analyticsDone
	logger.Log.Info("События аналитики записаны, сервер остановлен")
```

- [ ] **Step 7: Сборка и ручная проверка**

Run: `cd backend && go build ./... && go vet ./...`
Expected: без вывода.

```bash
docker compose -f backend/docker-compose.yml up -d --build
curl -s -w "\n%{http_code}\n" -X POST http://localhost:5040/api/analytics/events -H 'Content-Type: application/json' -d '{"events":[]}'
```

Expected: `400` (нет токена → `INVALID_INPUT`, как у остальных пользовательских эндпоинтов).

- [ ] **Step 8: Commit**

```bash
git -C backend add internal/services/analytics_validation.go internal/services/analytics_validation_test.go \
  internal/handlers/analytics.go cmd/server/main.go
git -C backend commit -m "feat(backend): client analytics ingest endpoint with whitelist validation"
```

---

### Task 10: Серверный emit доменных событий

**Files:**
- Modify: `backend/internal/ports/services.go` (`ItemService`)
- Modify: `backend/internal/services/otp.go`, `list.go`, `item.go`, `family.go`
- Modify: `backend/internal/handlers/item.go`
- Modify: `backend/cmd/server/main.go`
- Test: `backend/internal/services/item_test.go`

- [ ] **Step 1: Напиши падающий тест на emit в `ItemService`**

`backend/internal/services/item_test.go`:

```go
package services

import (
	"testing"

	"pora/internal/config"
	"pora/internal/entities"
	"pora/internal/ports"

	"github.com/google/uuid"
)

type fakeItemRepo struct {
	ports.ItemRepository
	items   map[uuid.UUID]*entities.Item
	deleted []uuid.UUID
}

func (f *fakeItemRepo) FindByID(id uuid.UUID) (*entities.Item, error) { return f.items[id], nil }
func (f *fakeItemRepo) UpdateItem(*entities.Item) error                { return nil }
func (f *fakeItemRepo) DeleteItem(item *entities.Item) error {
	f.deleted = append(f.deleted, item.ID)
	return nil
}

type fakeListRepo struct {
	ports.ListRepository
	list *entities.List
}

func (f *fakeListRepo) FindByID(uuid.UUID) (*entities.List, error) { return f.list, nil }
func (f *fakeListRepo) UpdateList(*entities.List) error           { return nil }

func newItemFixture() (*ItemService, *fakeEmitter, *entities.Item) {
	list := &entities.List{ID: uuid.New()}
	item := &entities.Item{ID: uuid.New(), ListID: list.ID, Name: "  Молоко "}
	emitter := &fakeEmitter{}
	service := NewItemService(nil, &fakeListRepo{list: list},
		&fakeItemRepo{items: map[uuid.UUID]*entities.Item{item.ID: item}},
		nil, nil, config.ItemConfig{}, emitter).(*ItemService)
	return service, emitter, item
}

func TestMarkAsBoughtEmitsItemBought(t *testing.T) {
	service, emitter, item := newItemFixture()
	actorID := uuid.New()

	if err := service.MarkAsBought(actorID, item.ID, true); err != nil {
		t.Fatalf("MarkAsBought: %v", err)
	}

	if len(emitter.events) != 1 {
		t.Fatalf("events = %+v, want 1", emitter.events)
	}
	got := emitter.events[0]
	if got.userID != actorID || got.name != entities.EventItemBought || got.props["name"] != "молоко" {
		t.Fatalf("event = %+v", got)
	}
}

func TestUncheckDoesNotEmit(t *testing.T) {
	service, emitter, item := newItemFixture()

	if err := service.MarkAsBought(uuid.New(), item.ID, false); err != nil {
		t.Fatalf("MarkAsBought: %v", err)
	}
	if len(emitter.events) != 0 {
		t.Fatalf("снятие отметки не должно давать событие: %+v", emitter.events)
	}
}

func TestDeleteItemsEmitsPerDeletedItem(t *testing.T) {
	service, emitter, item := newItemFixture()
	actorID := uuid.New()

	if err := service.DeleteItems(actorID, []uuid.UUID{item.ID, uuid.New()}); err != nil {
		t.Fatalf("DeleteItems: %v", err)
	}
	if len(emitter.events) != 1 || emitter.events[0].name != entities.EventItemDeleted {
		t.Fatalf("events = %+v, want один item_deleted (второй id не существует)", emitter.events)
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/services/ -run 'MarkAsBought|Uncheck|DeleteItems'`
Expected: FAIL — `too many arguments in call to NewItemService` и т.п.

- [ ] **Step 3: Обнови порт `ItemService`**

В `backend/internal/ports/services.go`, интерфейс `ItemService`:

```go
	// DeleteItems удаляет товары из списка продуктов от имени actorID
	DeleteItems(actorID uuid.UUID, itemIDs []uuid.UUID) error

	// MarkAsBought ставит значение checked у товара от имени actorID
	MarkAsBought(actorID uuid.UUID, itemID uuid.UUID, checked bool) error
```

(замени существующие объявления этих двух методов вместе с комментариями).

- [ ] **Step 4: `ItemService` — поле, конструктор, emit**

В `backend/internal/services/item.go`:

в struct `ItemService` после `itemConfig config.ItemConfig` добавь `emitter ports.EventEmitter`;

конструктор:

```go
func NewItemService(familyRepo ports.FamilyRepository,
	listRepo ports.ListRepository,
	itemRepo ports.ItemRepository,
	listService ports.ListService,
	pushService ports.PushService,
	itemConfig config.ItemConfig,
	emitter ports.EventEmitter) ports.ItemService {
	return &ItemService{
		familyRepo:  familyRepo,
		listRepo:    listRepo,
		itemRepo:    itemRepo,
		listService: listService,
		pushService: pushService,
		itemConfig:  itemConfig,
		emitter:     emitter,
	}
}
```

`DeleteItems`: сигнатура `func (s *ItemService) DeleteItems(actorID uuid.UUID, itemIDs []uuid.UUID) error`; сразу после успешного удаления

```go
		err = s.itemRepo.DeleteItem(item)
		if err != nil {
			logger.Log.Error("Ошибюка при удалении товара: ", err)
			return err
		}
```

добавь

```go

		s.emitter.Emit(actorID, entities.EventItemDeleted, nil)
```

`MarkAsBought`: сигнатура `func (s *ItemService) MarkAsBought(actorID uuid.UUID, itemID uuid.UUID, checked bool) error`; сразу после

```go
	err = s.itemRepo.UpdateItem(item)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении товара: ", err)
		return err
	}
```

добавь

```go

	if checked {
		s.emitter.Emit(actorID, entities.EventItemBought, map[string]any{
			"name": entities.NormalizeProductName(item.Name),
		})
	}
```

- [ ] **Step 5: Хэндлеры товаров передают `actorID`**

В `backend/internal/handlers/item.go`, в начале тел методов `DeleteItem`, `DeleteItems` и `MarkAsBought` (первой инструкцией) вставь:

```go
	actorID, err := h.tokenService.DecodeAccessToken(c.GetHeader("Authorization"))
	if err != nil {
		logger.Log.Warn("Возникла ошибка при декодировании Access-токена")
		c.Error(err)
		return
	}

```

После этого в `DeleteItems` и `MarkAsBought` замени `err := c.ShouldBindJSON(&req)` на `err = c.ShouldBindJSON(&req)` (переменная `err` уже объявлена). В `DeleteItem` строку `itemID, err := uuid.Parse(rawItemID)` **не трогай** — `:=` там валиден, т.к. объявляет новый `itemID`. Вызовы:

```go
	err = h.itemService.DeleteItems(actorID, []uuid.UUID{itemID})   // DeleteItem
	err = h.itemService.DeleteItems(actorID, req.ItemIDs)           // DeleteItems
	err = h.itemService.MarkAsBought(actorID, itemID, req.Checked)  // MarkAsBought
```

- [ ] **Step 6: `ListService` — emit `list_created`, `item_added`, `item_bought` при создании отмеченным**

В `backend/internal/services/list.go`:

в struct `ListService` после `itemConfig config.ItemConfig` добавь `emitter    ports.EventEmitter`;

в `NewListService` добавь последний параметр `emitter ports.EventEmitter` и поле `emitter: emitter,` в литерал;

в `CreateList` сразу после

```go
	err := s.listRepo.CreateList(newList)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении списка продуктов: ", err)
		return response, err
	}
```

добавь

```go

	s.emitter.Emit(userID, entities.EventListCreated, map[string]any{
		"shared": family != nil,
	})
```

в `createNewItem` замени хвост

```go
	err := s.itemRepo.CreateItem(item)
	if err != nil {
		logger.Log.Error("Ошибка при создании товара в БД: ", err)
		return itemID, err
	}

	return itemID, nil
```

на

```go
	err := s.itemRepo.CreateItem(item)
	if err != nil {
		logger.Log.Error("Ошибка при создании товара в БД: ", err)
		return itemID, err
	}

	productName := entities.NormalizeProductName(item.Name)

	s.emitter.Emit(userID, entities.EventItemAdded, map[string]any{
		"name":    productName,
		"section": item.Section,
	})

	if item.Checked {
		s.emitter.Emit(userID, entities.EventItemBought, map[string]any{
			"name": productName,
		})
	}

	return itemID, nil
```

- [ ] **Step 7: `FamilyService` — emit `family_created`, `family_joined`**

В `backend/internal/services/family.go`:

в struct `FamilyService` добавь поле `emitter ports.EventEmitter`; в `NewFamilyService` — последний параметр `emitter ports.EventEmitter` и `emitter: emitter,` в литерал;

в `CreateFamily` перед `response.ID = familyID`:

```go
	s.emitter.Emit(userID, entities.EventFamilyCreated, nil)

```

в `AddMember` перед финальным `return nil`:

```go
	s.emitter.Emit(userID, entities.EventFamilyJoined, nil)

```

- [ ] **Step 8: `OtpService` — emit `user_signed_up`**

В `backend/internal/services/otp.go`:

в struct `OtpService` добавь поле `emitter ports.EventEmitter`; в `NewOTPService` — последний параметр `emitter ports.EventEmitter` и `emitter: emitter,`;

в `VerifyOtp` внутри `if user == nil { ... }` сразу после

```go
		err := s.userRepo.CreateUser(user)
		if err != nil {
			logger.Log.Error("Ошибка при создании пользователя: ", err)
			return responses.VerifyOtpResponse{}, err
		}
```

добавь

```go

		s.emitter.Emit(user.ID, entities.EventUserSignedUp, nil)
```

- [ ] **Step 9: Wiring конструкторов в `main.go`**

Обнови вызовы (последним аргументом — `analyticsService`):

```go
	otpService := services.NewOTPService(otpRepo, userRepo, deviceRepo, tokenService, analyticsService)
	listService := services.NewListService(userRepo, memberRepo, familyRepo, listRepo, itemRepo, hub, cfg.Item, analyticsService)
	familyService := services.NewFamilyService(userRepo, memberRepo, familyRepo, listService, cfg.DeepLink, analyticsService)
	itemService := services.NewItemService(familyRepo, listRepo, itemRepo, listService, pushService, cfg.Item, analyticsService)
```

- [ ] **Step 10: Сборка и тесты**

Run: `cd backend && go build ./... && go vet ./... && go test ./internal/services/`
Expected: build/vet без вывода; `ok  	pora/internal/services`

- [ ] **Step 11: Ручная проверка end-to-end**

```bash
docker compose -f backend/docker-compose.yml up -d --build
```

В мобильном приложении (debug против локального бэкенда): добавь товар, отметь купленным, удали. Затем:

```bash
docker compose -f backend/docker-compose.yml exec postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT name, props, source FROM analytics_events ORDER BY occurred_at DESC LIMIT 5"'
```

Expected: строки `item_deleted`, `item_bought {"name": "..."}`, `item_added {"name": "...", "section": "..."}` с `source=server`, по одной на действие (без дублей). Если приложение при этом получило 400 на удаление/отметку — значит запрос шёл без `Authorization`: найди вызов в `lib/core/internal/network/api_client/` и сообщи (не обходи проверку).

- [ ] **Step 12: Commit**

```bash
git -C backend add internal/ports/services.go internal/services/otp.go internal/services/list.go \
  internal/services/item.go internal/services/family.go internal/services/item_test.go \
  internal/handlers/item.go cmd/server/main.go
git -C backend commit -m "feat(backend): emit domain analytics events; require auth on item delete/bought"
```

---

### Task 11: Период, агрегаты-хелперы, overview / active-users / signups

**Files:**
- Create: `backend/internal/stats/period.go`
- Create: `backend/internal/stats/aggregate.go`
- Create: `backend/internal/dto/responses/admin.go`
- Modify: `backend/internal/ports/repositories.go`, `backend/internal/ports/services.go`
- Create: `backend/internal/repositories/admin_stats.go`
- Create: `backend/internal/services/admin_stats.go`
- Modify: `backend/internal/handlers/admin.go`, `backend/cmd/server/main.go`
- Test: `backend/internal/stats/period_test.go`, `backend/internal/stats/aggregate_test.go`, `backend/internal/repositories/admin_stats_test.go`

**Контракт для плана 3 (общие query-параметры периодных эндпоинтов):** `from`, `to` — `YYYY-MM-DD` (включительно, в таймзоне `tz`); `tz` — IANA (`Europe/Moscow`), по умолчанию `UTC`. Без `from/to` — последние 30 дней по сегодня. Невалидные значения, `from > to`, период > 366 дней → `400 INVALID_INPUT`.

- [ ] **Step 1: Падающие тесты периода**

`backend/internal/stats/period_test.go`:

```go
package stats

import (
	"testing"
	"time"
)

var periodNow = time.Date(2026, 10, 15, 21, 30, 0, 0, time.UTC)

func TestParsePeriodDefaults(t *testing.T) {
	p, err := ParsePeriod("", "", "", periodNow)
	if err != nil {
		t.Fatal(err)
	}
	if p.Days != 30 || p.TZ() != "UTC" {
		t.Fatalf("days=%d tz=%s", p.Days, p.TZ())
	}
	keys := p.DayKeys()
	if keys[0] != "2026-09-16" || keys[29] != "2026-10-15" {
		t.Fatalf("keys = %s..%s", keys[0], keys[29])
	}
}

func TestParsePeriodUsesTimezoneForToday(t *testing.T) {
	// 21:30 UTC = 00:30 следующего дня по Москве
	p, err := ParsePeriod("", "", "Europe/Moscow", periodNow)
	if err != nil {
		t.Fatal(err)
	}
	if last := p.DayKeys()[p.Days-1]; last != "2026-10-16" {
		t.Fatalf("последний день = %s, want 2026-10-16", last)
	}
}

func TestParsePeriodAcrossDST(t *testing.T) {
	p, err := ParsePeriod("2026-03-28", "2026-03-30", "Europe/Berlin", periodNow)
	if err != nil {
		t.Fatal(err)
	}
	if p.Days != 3 {
		t.Fatalf("days = %d, want 3", p.Days)
	}
	if hours := p.End.Sub(p.Start).Hours(); hours != 71 {
		t.Fatalf("длительность = %v ч, want 71 (переход на летнее время)", hours)
	}
}

func TestParsePeriodPrevious(t *testing.T) {
	p, _ := ParsePeriod("2026-10-08", "2026-10-14", "UTC", periodNow)
	prev := p.Previous()
	if prev.Days != 7 || prev.DayKeys()[0] != "2026-10-01" || !prev.End.Equal(p.Start) {
		t.Fatalf("prev = %+v", prev.DayKeys())
	}
}

func TestParsePeriodRejects(t *testing.T) {
	cases := [][3]string{
		{"2026-10-10", "2026-10-01", "UTC"},
		{"2024-01-01", "2026-01-01", "UTC"},
		{"bad", "", "UTC"},
		{"", "", "Mars/Olympus"},
		{"", "", "Local"},
	}
	for _, c := range cases {
		if _, err := ParsePeriod(c[0], c[1], c[2], periodNow); err == nil {
			t.Errorf("ParsePeriod(%v) должен вернуть ошибку", c)
		}
	}
}

func TestWeekStartIsMonday(t *testing.T) {
	sunday := time.Date(2026, 10, 18, 0, 0, 0, 0, time.UTC)
	if got := WeekStart(sunday); got.Format(DateLayout) != "2026-10-12" {
		t.Fatalf("WeekStart = %s", got.Format(DateLayout))
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/stats/`
Expected: FAIL — `no Go files` / `undefined: ParsePeriod`

- [ ] **Step 3: Реализуй период**

`backend/internal/stats/period.go`:

```go
// stats - пакет с календарными периодами и чистыми хелперами агрегатов
// для админ-аналитики
package stats

import (
	"math"
	"pora/internal/errors"
	"time"
)

const (
	// DateLayout - формат дат в query-параметрах и ответах админ-API
	DateLayout = "2006-01-02"

	defaultPeriodDays = 30
	maxPeriodDays     = 366
)

// Period - календарный период [Start, End) в таймзоне Location.
// Start и End - полночь соответствующих дней в этой таймзоне
type Period struct {
	Start    time.Time
	End      time.Time
	Location *time.Location
	Days     int
}

// ParsePeriod разбирает query-параметры from/to (YYYY-MM-DD, включительно)
// и tz (IANA). Пустые значения: tz = UTC, to = сегодня, from = to - 29 дней
func ParsePeriod(rawFrom, rawTo, rawTZ string, now time.Time) (Period, error) {
	tz := rawTZ
	if tz == "" {
		tz = "UTC"
	}
	if tz == "Local" {
		return Period{}, errors.ErrorInvalidInput
	}

	location, err := time.LoadLocation(tz)
	if err != nil {
		return Period{}, errors.ErrorInvalidInput
	}

	to := DayStart(now.In(location))
	if rawTo != "" {
		to, err = time.ParseInLocation(DateLayout, rawTo, location)
		if err != nil {
			return Period{}, errors.ErrorInvalidInput
		}
	}

	from := to.AddDate(0, 0, -(defaultPeriodDays - 1))
	if rawFrom != "" {
		from, err = time.ParseInLocation(DateLayout, rawFrom, location)
		if err != nil {
			return Period{}, errors.ErrorInvalidInput
		}
	}

	if from.After(to) {
		return Period{}, errors.ErrorInvalidInput
	}

	end := to.AddDate(0, 0, 1)
	days := daysBetween(from, end)
	if days > maxPeriodDays {
		return Period{}, errors.ErrorInvalidInput
	}

	return Period{Start: from, End: end, Location: location, Days: days}, nil
}

// TZ возвращает IANA-имя таймзоны периода (передаётся в SQL как AT TIME ZONE)
func (p Period) TZ() string {
	return p.Location.String()
}

// DayKeys возвращает даты всех дней периода в формате YYYY-MM-DD
func (p Period) DayKeys() []string {
	keys := make([]string, 0, p.Days)
	for day := p.Start; day.Before(p.End); day = day.AddDate(0, 0, 1) {
		keys = append(keys, day.Format(DateLayout))
	}
	return keys
}

// Previous возвращает период той же длины, идущий сразу перед текущим
func (p Period) Previous() Period {
	return Period{
		Start:    p.Start.AddDate(0, 0, -p.Days),
		End:      p.Start,
		Location: p.Location,
		Days:     p.Days,
	}
}

// LastDay возвращает полночь последнего дня периода
func (p Period) LastDay() time.Time {
	return p.End.AddDate(0, 0, -1)
}

// DayStart возвращает полночь дня t в его таймзоне
func DayStart(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

// WeekStart возвращает понедельник недели, в которую попадает день
// (совпадает с date_trunc('week') в Postgres)
func WeekStart(day time.Time) time.Time {
	offset := (int(day.Weekday()) + 6) % 7
	return DayStart(day).AddDate(0, 0, -offset)
}

// daysBetween считает календарные дни между полуночами (устойчиво к DST)
func daysBetween(from, to time.Time) int {
	return int(math.Round(to.Sub(from).Hours() / 24))
}
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test ./internal/stats/`
Expected: `ok  	pora/internal/stats`

- [ ] **Step 5: DTO ответов админ-API**

`backend/internal/dto/responses/admin.go`:

```go
// responses - пакет, содержащий структуры ответов на Api запросы
package responses

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// DayCount - значение метрики за один день
type DayCount struct {
	Date  string `json:"date"`
	Count int64  `json:"count"`
}

// NameCount - значение метрики для именованной категории
type NameCount struct {
	Name  string `json:"name"`
	Count int64  `json:"count"`
}

// AdminOverview - KPI за период и за предыдущий период той же длины
type AdminOverview struct {
	TotalUsers      int64 `json:"total-users"`
	NewUsers        int64 `json:"new-users"`
	NewUsersPrev    int64 `json:"new-users-prev"`
	DAU             int64 `json:"dau"`
	WAU             int64 `json:"wau"`
	MAU             int64 `json:"mau"`
	ItemsAdded      int64 `json:"items-added"`
	ItemsAddedPrev  int64 `json:"items-added-prev"`
	ItemsBought     int64 `json:"items-bought"`
	ItemsBoughtPrev int64 `json:"items-bought-prev"`
}

// AdminActiveUsers - DAU по дням + WAU/MAU на конец периода
type AdminActiveUsers struct {
	Days []DayCount `json:"days"`
	WAU  int64      `json:"wau"`
	MAU  int64      `json:"mau"`
}

// AdminSeries - дневной ряд значений
type AdminSeries struct {
	Days []DayCount `json:"days"`
}

// CohortRow - недельная когорта: retained[n] - % вернувшихся на неделе n,
// null - неделя ещё не наступила
type CohortRow struct {
	Week     string     `json:"week"`
	Size     int64      `json:"size"`
	Retained []*float64 `json:"retained"`
}

// DayNRetention - сколько из доступных для замера юзеров вернулись на день N
type DayNRetention struct {
	Day      int   `json:"day"`
	Eligible int64 `json:"eligible"`
	Retained int64 `json:"retained"`
}

// AdminRetention - когорты по неделям регистрации и D1/D7/D30
type AdminRetention struct {
	Cohorts []CohortRow     `json:"cohorts"`
	DayN    []DayNRetention `json:"day-n"`
}

// FunnelStep - число юзеров когорты, дошедших до шага
type FunnelStep struct {
	Step  string `json:"step"`
	Users int64  `json:"users"`
}

// AdminFunnel - нестрогая воронка активации
type AdminFunnel struct {
	Steps []FunnelStep `json:"steps"`
}

// FeatureAdoption - доля MAU, использовавших фичу (share в процентах)
type FeatureAdoption struct {
	Feature string  `json:"feature"`
	Users   int64   `json:"users"`
	Share   float64 `json:"share"`
}

// AdminFeatures - adoption фич за 30 дней до конца периода
type AdminFeatures struct {
	MAU      int64             `json:"mau"`
	Features []FeatureAdoption `json:"features"`
}

// EventDayCount - число событий с именем за день
type EventDayCount struct {
	Date  string `json:"date"`
	Name  string `json:"name"`
	Count int64  `json:"count"`
}

// AdminEventSeries - события по типам во времени
type AdminEventSeries struct {
	Points []EventDayCount `json:"points"`
}

// AdminTopProducts - топ товаров по добавлениям/покупкам
type AdminTopProducts struct {
	Kind             string      `json:"kind"`
	Items            []NameCount `json:"items"`
	MedianHoursToBuy *float64    `json:"median-hours-to-buy"`
}

// AdminSections - распределение добавленных товаров по секциям
type AdminSections struct {
	Sections []NameCount `json:"sections"`
}

// AdminPlatforms - платформы устройств и версии приложения активных юзеров
type AdminPlatforms struct {
	Platforms []NameCount `json:"platforms"`
	Versions  []NameCount `json:"versions"`
}

// AdminUserRow - строка таблицы пользователей админки
type AdminUserRow struct {
	ID           uuid.UUID  `json:"id"`
	Email        string     `json:"email"`
	Phone        string     `json:"phone"`
	Name         string     `json:"name"`
	Surname      string     `json:"surname"`
	Status       string     `json:"status"`
	IsAdmin      bool       `json:"is-admin"`
	CreatedAt    time.Time  `json:"created-at"`
	LastActiveAt *time.Time `json:"last-active-at"`
	Lists        int64      `json:"lists"`
	Items        int64      `json:"items"`
	Families     int64      `json:"families"`
}

// AdminUsersPage - страница таблицы пользователей
type AdminUsersPage struct {
	Users    []AdminUserRow `json:"users"`
	Total    int64          `json:"total"`
	Page     int            `json:"page"`
	PageSize int            `json:"page-size"`
}

// AdminEvent - событие в карточке пользователя
type AdminEvent struct {
	ID         uuid.UUID       `json:"id"`
	Name       string          `json:"name"`
	Props      json.RawMessage `json:"props"`
	Platform   string          `json:"platform"`
	AppVersion string          `json:"app-version"`
	Source     string          `json:"source"`
	OccurredAt time.Time       `json:"occurred-at"`
}

// AdminUserDetail - карточка пользователя с последними событиями
type AdminUserDetail struct {
	User   AdminUserRow `json:"user"`
	Events []AdminEvent `json:"events"`
}
```

- [ ] **Step 6: Падающий тест `FillDays`**

`backend/internal/stats/aggregate_test.go`:

```go
package stats

import (
	"testing"

	"pora/internal/dto/responses"
)

func TestFillDaysAddsZeros(t *testing.T) {
	keys := []string{"2026-10-13", "2026-10-14", "2026-10-15"}
	rows := []responses.DayCount{{Date: "2026-10-14", Count: 5}}

	got := FillDays(keys, rows)
	if len(got) != 3 || got[0].Count != 0 || got[1].Count != 5 || got[2].Date != "2026-10-15" {
		t.Fatalf("FillDays = %+v", got)
	}
}
```

- [ ] **Step 7: Запусти — должен упасть**

Run: `cd backend && go test ./internal/stats/`
Expected: FAIL — `undefined: FillDays`

- [ ] **Step 8: Реализуй `aggregate.go` (FillDays + row-типы; BuildCohorts — в Task 12)**

`backend/internal/stats/aggregate.go`:

```go
// stats - пакет с календарными периодами и чистыми хелперами агрегатов
// для админ-аналитики
package stats

import "pora/internal/dto/responses"

// FillDays возвращает ряд по всем дням keys, подставляя 0 для дней без данных
func FillDays(keys []string, rows []responses.DayCount) []responses.DayCount {
	byDate := make(map[string]int64, len(rows))
	for _, row := range rows {
		byDate[row.Date] = row.Count
	}

	filled := make([]responses.DayCount, 0, len(keys))
	for _, key := range keys {
		filled = append(filled, responses.DayCount{Date: key, Count: byDate[key]})
	}
	return filled
}
```

Run: `cd backend && go test ./internal/stats/` → Expected: `ok  	pora/internal/stats`

- [ ] **Step 9: Порты агрегатов (полный набор — реализуется в Tasks 11–14)**

В конец `backend/internal/ports/repositories.go` (добавь импорт `"pora/internal/dto/responses"` и `"pora/internal/stats"`):

```go
// AdminStatsRepository содержит порты для raw-SQL агрегатов админ-аналитики.
// Все границы времени - моменты (timestamptz), tz - IANA-имя для группировки по дням
type AdminStatsRepository interface {
	// CountUsers возвращает общее число пользователей
	CountUsers() (int64, error)

	// CountSignups возвращает число регистраций в [start, end)
	CountSignups(start, end time.Time) (int64, error)

	// CountEvents возвращает число событий с именем в [start, end)
	CountEvents(name string, start, end time.Time) (int64, error)

	// CountActiveUsers возвращает число уникальных активных юзеров в [start, end)
	CountActiveUsers(start, end time.Time) (int64, error)

	// DailyActiveUsers возвращает DAU по дням (дни без активности отсутствуют)
	DailyActiveUsers(start, end time.Time, tz string) ([]responses.DayCount, error)

	// DailySignups возвращает регистрации по дням
	DailySignups(start, end time.Time, tz string) ([]responses.DayCount, error)

	// WeeklyRetention возвращает размеры недельных когорт и возвраты по неделям
	WeeklyRetention(since time.Time, tz string) (
		[]stats.CohortSize, []stats.CohortCell, error)

	// DayNRetention возвращает D1/D7/D30 для регистраций начиная с since
	DayNRetention(since time.Time, today string, tz string) (
		[]responses.DayNRetention, error)

	// FunnelCounts возвращает шаги воронки для регистраций в [start, end)
	FunnelCounts(start, end time.Time) (stats.FunnelCounts, error)

	// FeatureUsers возвращает число юзеров по фичам в [start, end)
	FeatureUsers(start, end time.Time) ([]responses.NameCount, error)

	// EventTimeseries возвращает события по дням и именам (names пустой - все)
	EventTimeseries(start, end time.Time, tz string, names []string) (
		[]responses.EventDayCount, error)

	// TopProducts возвращает топ названий товаров из props события
	TopProducts(event string, start, end time.Time, limit int) (
		[]responses.NameCount, error)

	// SectionCounts возвращает распределение item_added по секциям
	SectionCounts(start, end time.Time) ([]responses.NameCount, error)

	// MedianHoursToBuy возвращает медиану часов от добавления до покупки
	MedianHoursToBuy(start, end time.Time) (*float64, error)

	// PlatformUsers возвращает число юзеров по типам устройств
	PlatformUsers() ([]responses.NameCount, error)

	// AppVersionUsers возвращает версии приложения активных юзеров
	AppVersionUsers(start, end time.Time) ([]responses.NameCount, error)

	// ListUsers возвращает страницу пользователей с поиском и общее число
	ListUsers(query string, limit, offset int) ([]responses.AdminUserRow, int64, error)

	// FindUserRow возвращает строку пользователя (nil, если не найден)
	FindUserRow(userID uuid.UUID) (*responses.AdminUserRow, error)
}
```

В конец `backend/internal/ports/services.go` (добавь импорт `"pora/internal/stats"`):

```go
// AdminStatsService содержит порты для методов статистики админ-панели
type AdminStatsService interface {
	Overview(p stats.Period) (responses.AdminOverview, error)
	ActiveUsers(p stats.Period) (responses.AdminActiveUsers, error)
	Signups(p stats.Period) (responses.AdminSeries, error)
	Retention(p stats.Period, weeks int) (responses.AdminRetention, error)
	Funnel(p stats.Period) (responses.AdminFunnel, error)
	Features(p stats.Period) (responses.AdminFeatures, error)
	EventTimeseries(p stats.Period, names []string) (responses.AdminEventSeries, error)
	TopProducts(p stats.Period, kind string, limit int) (responses.AdminTopProducts, error)
	Sections(p stats.Period) (responses.AdminSections, error)
	Platforms(p stats.Period) (responses.AdminPlatforms, error)
	Users(query string, page int) (responses.AdminUsersPage, error)
	UserDetail(userID uuid.UUID) (responses.AdminUserDetail, error)
}
```

И добавь row-типы в конец `backend/internal/stats/aggregate.go` (нужны портам уже сейчас):

```go
// CohortSize - размер недельной когорты регистраций
type CohortSize struct {
	CohortWeek string
	Size       int64
}

// CohortCell - число юзеров когорты, активных на неделе WeekN (WeekN >= 1)
type CohortCell struct {
	CohortWeek string
	WeekN      int
	Users      int64
}

// FunnelCounts - сырые счётчики шагов воронки
type FunnelCounts struct {
	SignedUp     int64
	CreatedList  int64
	AddedItem    int64
	BoughtItem   int64
	JoinedFamily int64
}
```

- [ ] **Step 10: Падающий интеграционный тест для overview-запросов**

`backend/internal/repositories/admin_stats_test.go`:

```go
package repositories

import (
	"testing"
	"time"

	"pora/internal/entities"
	"pora/internal/testutil"

	"gorm.io/gorm"
)

// day возвращает момент day-го октября 2026 в 12:00 UTC
func day(d int) time.Time {
	return time.Date(2026, 10, d, 12, 0, 0, 0, time.UTC)
}

func utcDay(d int) time.Time {
	return time.Date(2026, 10, d, 0, 0, 0, 0, time.UTC)
}

func newStatsRepo(t *testing.T) (*AdminStatsRepo, *gorm.DB) {
	db := testutil.OpenTestDB(t)
	return NewAdminStatsRepository(db).(*AdminStatsRepo), db
}

func TestAdminStatsActivityAndSignups(t *testing.T) {
	repo, db := newStatsRepo(t)

	alice := testutil.SeedUser(t, db, "alice@test.io", day(1))
	bob := testutil.SeedUser(t, db, "bob@test.io", day(10))
	testutil.SeedUser(t, db, "carol@test.io", day(11))

	testutil.SeedLogin(t, db, alice, day(10))
	testutil.SeedEvent(t, db, alice, entities.EventItemAdded, day(10), "")
	testutil.SeedEvent(t, db, bob, entities.EventItemAdded, day(11), "")
	testutil.SeedEvent(t, db, bob, entities.EventItemBought, day(11), "")

	if n, err := repo.CountUsers(); err != nil || n != 3 {
		t.Fatalf("CountUsers = %d, %v", n, err)
	}
	if n, err := repo.CountSignups(utcDay(10), utcDay(12)); err != nil || n != 2 {
		t.Fatalf("CountSignups = %d, %v", n, err)
	}
	if n, err := repo.CountEvents(entities.EventItemAdded, utcDay(1), utcDay(31)); err != nil || n != 2 {
		t.Fatalf("CountEvents = %d, %v", n, err)
	}
	// alice: логин + событие в один день — один активный юзер
	if n, err := repo.CountActiveUsers(utcDay(10), utcDay(11)); err != nil || n != 1 {
		t.Fatalf("CountActiveUsers(10) = %d, %v", n, err)
	}

	dau, err := repo.DailyActiveUsers(utcDay(10), utcDay(12), "UTC")
	if err != nil || len(dau) != 2 || dau[0].Date != "2026-10-10" || dau[0].Count != 1 || dau[1].Count != 1 {
		t.Fatalf("DailyActiveUsers = %+v, %v", dau, err)
	}

	signups, err := repo.DailySignups(utcDay(1), utcDay(12), "UTC")
	if err != nil || len(signups) != 3 {
		t.Fatalf("DailySignups = %+v, %v", signups, err)
	}
}

func TestAdminStatsDailyBucketsUseTimezone(t *testing.T) {
	repo, db := newStatsRepo(t)
	user := testutil.SeedUser(t, db, "tz@test.io", day(1))

	// 22:30 UTC 14-го = 01:30 15-го по Москве
	testutil.SeedEvent(t, db, user, entities.EventItemAdded,
		time.Date(2026, 10, 14, 22, 30, 0, 0, time.UTC), "")

	moscow, _ := time.LoadLocation("Europe/Moscow")
	start := time.Date(2026, 10, 14, 0, 0, 0, 0, moscow)
	end := time.Date(2026, 10, 16, 0, 0, 0, 0, moscow)

	dau, err := repo.DailyActiveUsers(start, end, "Europe/Moscow")
	if err != nil || len(dau) != 1 || dau[0].Date != "2026-10-15" {
		t.Fatalf("DailyActiveUsers(Moscow) = %+v, %v", dau, err)
	}
}
```

- [ ] **Step 11: Запусти — должен упасть**

Run: `cd backend && go test -p 1 ./internal/repositories/ -run TestAdminStats`
Expected: FAIL — `undefined: NewAdminStatsRepository`

- [ ] **Step 12: Реализуй репозиторий (overview-часть) и заглушки остальных методов**

`backend/internal/repositories/admin_stats.go`:

```go
// repositories - пакет с методами для работы с БД
package repositories

import (
	"pora/internal/dto/responses"
	"pora/internal/ports"
	"pora/internal/stats"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// users.created_at хранится как TIMESTAMP без зоны в UTC —
// приводим к моменту времени выражением ниже
const userCreatedAt = "(users.created_at AT TIME ZONE 'UTC')"

// activityUnion - активность пользователей: входы и события аналитики
const activityUnion = `
	SELECT user_id, created_at AS ts
	FROM user_logins
	WHERE created_at >= @start AND created_at < @end
	UNION ALL
	SELECT user_id, occurred_at AS ts
	FROM analytics_events
	WHERE user_id IS NOT NULL AND occurred_at >= @start AND occurred_at < @end`

// AdminStatsRepo - объект с raw-SQL агрегатами для админ-аналитики
type AdminStatsRepo struct {
	db *gorm.DB
}

// NewAdminStatsRepository создает и возвращает новый объект AdminStatsRepo
func NewAdminStatsRepository(db *gorm.DB) ports.AdminStatsRepository {
	return &AdminStatsRepo{db: db}
}

// window - именованные параметры границ периода
func window(start, end time.Time) map[string]any {
	return map[string]any{"start": start, "end": end}
}

// scanCount выполняет запрос, возвращающий одно число
func (r *AdminStatsRepo) scanCount(query string, args map[string]any) (int64, error) {
	var count int64
	err := r.db.Raw(query, args).Scan(&count).Error
	return count, err
}

// CountUsers возвращает общее число пользователей
func (r *AdminStatsRepo) CountUsers() (int64, error) {
	var count int64
	err := r.db.Raw("SELECT COUNT(*) FROM users").Scan(&count).Error
	return count, err
}

// CountSignups возвращает число регистраций в [start, end)
func (r *AdminStatsRepo) CountSignups(start, end time.Time) (int64, error) {
	return r.scanCount(`
		SELECT COUNT(*) FROM users
		WHERE `+userCreatedAt+` >= @start AND `+userCreatedAt+` < @end`,
		window(start, end))
}

// CountEvents возвращает число событий с именем в [start, end)
func (r *AdminStatsRepo) CountEvents(name string, start, end time.Time) (int64, error) {
	args := window(start, end)
	args["name"] = name
	return r.scanCount(`
		SELECT COUNT(*) FROM analytics_events
		WHERE name = @name AND occurred_at >= @start AND occurred_at < @end`,
		args)
}

// CountActiveUsers возвращает число уникальных активных юзеров в [start, end)
func (r *AdminStatsRepo) CountActiveUsers(start, end time.Time) (int64, error) {
	return r.scanCount(`
		SELECT COUNT(DISTINCT user_id) FROM (`+activityUnion+`) activity`,
		window(start, end))
}

// DailyActiveUsers возвращает DAU по дням (дни без активности отсутствуют)
func (r *AdminStatsRepo) DailyActiveUsers(start, end time.Time,
	tz string) ([]responses.DayCount, error) {

	args := window(start, end)
	args["tz"] = tz

	var rows []responses.DayCount
	err := r.db.Raw(`
		SELECT TO_CHAR(CAST(ts AT TIME ZONE @tz AS date), 'YYYY-MM-DD') AS date,
			COUNT(DISTINCT user_id) AS count
		FROM (`+activityUnion+`) activity
		GROUP BY 1
		ORDER BY 1`, args).Scan(&rows).Error
	return rows, err
}

// DailySignups возвращает регистрации по дням
func (r *AdminStatsRepo) DailySignups(start, end time.Time,
	tz string) ([]responses.DayCount, error) {

	args := window(start, end)
	args["tz"] = tz

	var rows []responses.DayCount
	err := r.db.Raw(`
		SELECT TO_CHAR(CAST(`+userCreatedAt+` AT TIME ZONE @tz AS date), 'YYYY-MM-DD') AS date,
			COUNT(*) AS count
		FROM users
		WHERE `+userCreatedAt+` >= @start AND `+userCreatedAt+` < @end
		GROUP BY 1
		ORDER BY 1`, args).Scan(&rows).Error
	return rows, err
}

// --- Реализуются в Tasks 12–14 ---

// WeeklyRetention реализуется в Task 12
func (r *AdminStatsRepo) WeeklyRetention(since time.Time, tz string) (
	[]stats.CohortSize, []stats.CohortCell, error) {
	return nil, nil, nil
}

// DayNRetention реализуется в Task 12
func (r *AdminStatsRepo) DayNRetention(since time.Time, today string,
	tz string) ([]responses.DayNRetention, error) {
	return nil, nil
}

// FunnelCounts реализуется в Task 12
func (r *AdminStatsRepo) FunnelCounts(start, end time.Time) (stats.FunnelCounts, error) {
	return stats.FunnelCounts{}, nil
}

// FeatureUsers реализуется в Task 12
func (r *AdminStatsRepo) FeatureUsers(start, end time.Time) ([]responses.NameCount, error) {
	return nil, nil
}

// EventTimeseries реализуется в Task 13
func (r *AdminStatsRepo) EventTimeseries(start, end time.Time, tz string,
	names []string) ([]responses.EventDayCount, error) {
	return nil, nil
}

// TopProducts реализуется в Task 13
func (r *AdminStatsRepo) TopProducts(event string, start, end time.Time,
	limit int) ([]responses.NameCount, error) {
	return nil, nil
}

// SectionCounts реализуется в Task 13
func (r *AdminStatsRepo) SectionCounts(start, end time.Time) ([]responses.NameCount, error) {
	return nil, nil
}

// MedianHoursToBuy реализуется в Task 13
func (r *AdminStatsRepo) MedianHoursToBuy(start, end time.Time) (*float64, error) {
	return nil, nil
}

// PlatformUsers реализуется в Task 13
func (r *AdminStatsRepo) PlatformUsers() ([]responses.NameCount, error) {
	return nil, nil
}

// AppVersionUsers реализуется в Task 13
func (r *AdminStatsRepo) AppVersionUsers(start, end time.Time) ([]responses.NameCount, error) {
	return nil, nil
}

// ListUsers реализуется в Task 14
func (r *AdminStatsRepo) ListUsers(query string, limit,
	offset int) ([]responses.AdminUserRow, int64, error) {
	return nil, 0, nil
}

// FindUserRow реализуется в Task 14
func (r *AdminStatsRepo) FindUserRow(userID uuid.UUID) (*responses.AdminUserRow, error) {
	return nil, nil
}
```

- [ ] **Step 13: Запусти — должен пройти**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: `ok  	pora/internal/repositories`

- [ ] **Step 14: Сервис (overview / active-users / signups) и заглушки остальных**

`backend/internal/services/admin_stats.go`:

```go
// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"pora/internal/dto/responses"
	"pora/internal/entities"
	"pora/internal/ports"
	"pora/internal/stats"

	"github.com/google/uuid"
)

// AdminStatsService - объект, собирающий статистику для админ-панели
type AdminStatsService struct {
	repo      ports.AdminStatsRepository
	eventRepo ports.AnalyticsEventRepository
}

// NewAdminStatsService создает и возвращает новый объект AdminStatsService
func NewAdminStatsService(repo ports.AdminStatsRepository,
	eventRepo ports.AnalyticsEventRepository) ports.AdminStatsService {
	return &AdminStatsService{repo: repo, eventRepo: eventRepo}
}

// Overview собирает KPI за период и за предыдущий период той же длины
func (s *AdminStatsService) Overview(p stats.Period) (responses.AdminOverview, error) {
	var overview responses.AdminOverview
	var err error
	prev := p.Previous()

	steps := []struct {
		target *int64
		load   func() (int64, error)
	}{
		{&overview.TotalUsers, s.repo.CountUsers},
		{&overview.NewUsers, func() (int64, error) { return s.repo.CountSignups(p.Start, p.End) }},
		{&overview.NewUsersPrev, func() (int64, error) { return s.repo.CountSignups(prev.Start, prev.End) }},
		{&overview.DAU, func() (int64, error) { return s.repo.CountActiveUsers(p.LastDay(), p.End) }},
		{&overview.WAU, func() (int64, error) { return s.repo.CountActiveUsers(p.End.AddDate(0, 0, -7), p.End) }},
		{&overview.MAU, func() (int64, error) { return s.repo.CountActiveUsers(p.End.AddDate(0, 0, -30), p.End) }},
		{&overview.ItemsAdded, func() (int64, error) { return s.repo.CountEvents(entities.EventItemAdded, p.Start, p.End) }},
		{&overview.ItemsAddedPrev, func() (int64, error) { return s.repo.CountEvents(entities.EventItemAdded, prev.Start, prev.End) }},
		{&overview.ItemsBought, func() (int64, error) { return s.repo.CountEvents(entities.EventItemBought, p.Start, p.End) }},
		{&overview.ItemsBoughtPrev, func() (int64, error) { return s.repo.CountEvents(entities.EventItemBought, prev.Start, prev.End) }},
	}

	for _, step := range steps {
		if *step.target, err = step.load(); err != nil {
			return overview, err
		}
	}
	return overview, nil
}

// ActiveUsers возвращает DAU по всем дням периода и WAU/MAU на его конец
func (s *AdminStatsService) ActiveUsers(p stats.Period) (responses.AdminActiveUsers, error) {
	var result responses.AdminActiveUsers

	rows, err := s.repo.DailyActiveUsers(p.Start, p.End, p.TZ())
	if err != nil {
		return result, err
	}
	result.Days = stats.FillDays(p.DayKeys(), rows)

	if result.WAU, err = s.repo.CountActiveUsers(p.End.AddDate(0, 0, -7), p.End); err != nil {
		return result, err
	}
	if result.MAU, err = s.repo.CountActiveUsers(p.End.AddDate(0, 0, -30), p.End); err != nil {
		return result, err
	}
	return result, nil
}

// Signups возвращает регистрации по всем дням периода
func (s *AdminStatsService) Signups(p stats.Period) (responses.AdminSeries, error) {
	rows, err := s.repo.DailySignups(p.Start, p.End, p.TZ())
	if err != nil {
		return responses.AdminSeries{}, err
	}
	return responses.AdminSeries{Days: stats.FillDays(p.DayKeys(), rows)}, nil
}

// --- Реализуются в Tasks 12–14 ---

// Retention реализуется в Task 12
func (s *AdminStatsService) Retention(p stats.Period, weeks int) (responses.AdminRetention, error) {
	return responses.AdminRetention{}, nil
}

// Funnel реализуется в Task 12
func (s *AdminStatsService) Funnel(p stats.Period) (responses.AdminFunnel, error) {
	return responses.AdminFunnel{}, nil
}

// Features реализуется в Task 12
func (s *AdminStatsService) Features(p stats.Period) (responses.AdminFeatures, error) {
	return responses.AdminFeatures{}, nil
}

// EventTimeseries реализуется в Task 13
func (s *AdminStatsService) EventTimeseries(p stats.Period,
	names []string) (responses.AdminEventSeries, error) {
	return responses.AdminEventSeries{}, nil
}

// TopProducts реализуется в Task 13
func (s *AdminStatsService) TopProducts(p stats.Period, kind string,
	limit int) (responses.AdminTopProducts, error) {
	return responses.AdminTopProducts{}, nil
}

// Sections реализуется в Task 13
func (s *AdminStatsService) Sections(p stats.Period) (responses.AdminSections, error) {
	return responses.AdminSections{}, nil
}

// Platforms реализуется в Task 13
func (s *AdminStatsService) Platforms(p stats.Period) (responses.AdminPlatforms, error) {
	return responses.AdminPlatforms{}, nil
}

// Users реализуется в Task 14
func (s *AdminStatsService) Users(query string, page int) (responses.AdminUsersPage, error) {
	return responses.AdminUsersPage{}, nil
}

// UserDetail реализуется в Task 14
func (s *AdminStatsService) UserDetail(userID uuid.UUID) (responses.AdminUserDetail, error) {
	return responses.AdminUserDetail{}, nil
}
```

- [ ] **Step 15: Хэндлеры периодных эндпоинтов**

В `backend/internal/handlers/admin.go`:

добавь поле `statsService ports.AdminStatsService` в `AdminHandler`, параметр `statsService ports.AdminStatsService` последним в `NewAdminHandler` и `statsService: statsService,` в литерал;

добавь в импорты `"pora/internal/stats"` и `"time"`;

в конец файла:

```go
// withPeriod разбирает from/to/tz и отдаёт результат fn как JSON
func (h *AdminHandler) withPeriod(c *gin.Context,
	fn func(p stats.Period) (any, error)) {

	period, err := stats.ParsePeriod(
		c.Query("from"), c.Query("to"), c.Query("tz"), time.Now())
	if err != nil {
		logger.Log.Warn("Некорректный период в запросе статистики")
		c.Error(err)
		return
	}

	result, err := fn(period)
	if err != nil {
		c.Error(err)
		return
	}

	c.JSON(http.StatusOK, result)
}

// Overview обрабатывает запрос KPI за период
func (h *AdminHandler) Overview(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Overview(p)
	})
}

// ActiveUsers обрабатывает запрос DAU/WAU/MAU
func (h *AdminHandler) ActiveUsers(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.ActiveUsers(p)
	})
}

// Signups обрабатывает запрос регистраций по дням
func (h *AdminHandler) Signups(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Signups(p)
	})
}
```

- [ ] **Step 16: Wiring в `main.go`**

После `analyticsEventRepo := ...`:

```go
	adminStatsRepo := repositories.NewAdminStatsRepository(db)
```

В блок сервисов (после `statisticsService := ...`):

```go
	adminStatsService := services.NewAdminStatsService(adminStatsRepo, analyticsEventRepo)
```

Замени `adminHandler := handlers.NewAdminHandler(authService, userService, pushService)` на:

```go
	adminHandler := handlers.NewAdminHandler(authService, userService, pushService, adminStatsService)
```

В группу `admin` добавь:

```go
		admin.GET("/overview", adminHandler.Overview)
		admin.GET("/active-users", adminHandler.ActiveUsers)
		admin.GET("/signups", adminHandler.Signups)
```

- [ ] **Step 17: Сборка, тесты, commit**

Run: `cd backend && go build ./... && go vet ./... && go test -p 1 ./...`
Expected: все пакеты `ok` (интеграционные — `ok` при заданном `TEST_DATABASE_URL`).

```bash
git -C backend add internal/stats internal/dto/responses/admin.go internal/ports \
  internal/repositories/admin_stats.go internal/repositories/admin_stats_test.go \
  internal/services/admin_stats.go internal/handlers/admin.go cmd/server/main.go
git -C backend commit -m "feat(backend): admin overview, active users and signups endpoints"
```

---

### Task 12: Retention, воронка, adoption фич

**Files:**
- Modify: `backend/internal/stats/aggregate.go`, `backend/internal/stats/aggregate_test.go`
- Modify: `backend/internal/repositories/admin_stats.go`, `backend/internal/repositories/admin_stats_test.go`
- Modify: `backend/internal/services/admin_stats.go`
- Modify: `backend/internal/handlers/admin.go`, `backend/cmd/server/main.go`

- [ ] **Step 1: Падающий тест `BuildCohorts`**

Добавь в `backend/internal/stats/aggregate_test.go` (и `"time"` в импорты):

```go
func TestBuildCohorts(t *testing.T) {
	currentWeek := time.Date(2026, 10, 12, 0, 0, 0, 0, time.UTC)
	sizes := []CohortSize{
		{CohortWeek: "2026-09-28", Size: 10},
		{CohortWeek: "2026-10-12", Size: 4},
	}
	cells := []CohortCell{
		{CohortWeek: "2026-09-28", WeekN: 1, Users: 5},
		{CohortWeek: "2026-09-28", WeekN: 2, Users: 3},
	}

	rows := BuildCohorts(sizes, cells, 3, currentWeek)
	if len(rows) != 2 {
		t.Fatalf("rows = %d", len(rows))
	}

	old := rows[0].Retained
	if len(old) != 4 || *old[0] != 100 || *old[1] != 50 || *old[2] != 30 || old[3] != nil {
		t.Fatalf("старая когорта: %v", derefAll(old))
	}

	fresh := rows[1].Retained
	if *fresh[0] != 100 || fresh[1] != nil {
		t.Fatalf("текущая неделя: будущие недели должны быть nil, got %v", derefAll(fresh))
	}
}

func derefAll(values []*float64) []any {
	out := make([]any, len(values))
	for i, v := range values {
		if v != nil {
			out[i] = *v
		}
	}
	return out
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test ./internal/stats/`
Expected: FAIL — `undefined: BuildCohorts`

- [ ] **Step 3: Реализуй `BuildCohorts`**

Добавь в `backend/internal/stats/aggregate.go` (импорты: `"math"`, `"time"`, `"fmt"`):

```go
// BuildCohorts строит таблицу недельных когорт. retained[0] = 100%,
// недели после currentWeek (понедельник текущей недели, UTC-дата) - nil
func BuildCohorts(sizes []CohortSize, cells []CohortCell, weeks int,
	currentWeek time.Time) []responses.CohortRow {

	users := make(map[string]int64, len(cells))
	for _, cell := range cells {
		users[fmt.Sprintf("%s/%d", cell.CohortWeek, cell.WeekN)] = cell.Users
	}

	rows := make([]responses.CohortRow, 0, len(sizes))
	for _, size := range sizes {
		cohortStart, err := time.Parse(DateLayout, size.CohortWeek)
		if err != nil || size.Size == 0 {
			continue
		}

		elapsed := int(math.Round(currentWeek.Sub(cohortStart).Hours() / (24 * 7)))
		retained := make([]*float64, weeks+1)

		for n := 0; n <= weeks && n <= elapsed; n++ {
			share := 100.0
			if n > 0 {
				returned := users[fmt.Sprintf("%s/%d", size.CohortWeek, n)]
				share = math.Round(float64(returned)/float64(size.Size)*1000) / 10
			}
			retained[n] = &share
		}

		rows = append(rows, responses.CohortRow{
			Week:     size.CohortWeek,
			Size:     size.Size,
			Retained: retained,
		})
	}
	return rows
}
```

Run: `cd backend && go test ./internal/stats/` → Expected: `ok`

- [ ] **Step 4: Падающие интеграционные тесты retention/funnel/features**

Добавь в `backend/internal/repositories/admin_stats_test.go`:

```go
func TestAdminStatsRetention(t *testing.T) {
	repo, db := newStatsRepo(t)

	// Когорта недели 2026-09-28 (понедельник): двое
	stays := testutil.SeedUser(t, db, "stays@test.io", time.Date(2026, 9, 29, 10, 0, 0, 0, time.UTC))
	testutil.SeedUser(t, db, "leaves@test.io", time.Date(2026, 9, 30, 10, 0, 0, 0, time.UTC))
	// stays вернулся через неделю и на следующий день после регистрации
	testutil.SeedLogin(t, db, stays, time.Date(2026, 10, 6, 10, 0, 0, 0, time.UTC))
	testutil.SeedEvent(t, db, stays, entities.EventItemAdded, time.Date(2026, 9, 30, 9, 0, 0, 0, time.UTC), "")

	since := time.Date(2026, 9, 21, 0, 0, 0, 0, time.UTC)
	sizes, cells, err := repo.WeeklyRetention(since, "UTC")
	if err != nil {
		t.Fatalf("WeeklyRetention: %v", err)
	}
	if len(sizes) != 1 || sizes[0].CohortWeek != "2026-09-28" || sizes[0].Size != 2 {
		t.Fatalf("sizes = %+v", sizes)
	}
	if len(cells) != 1 || cells[0].WeekN != 1 || cells[0].Users != 1 {
		t.Fatalf("cells = %+v", cells)
	}

	dayN, err := repo.DayNRetention(since, "2026-10-15", "UTC")
	if err != nil || len(dayN) != 3 {
		t.Fatalf("DayNRetention = %+v, %v", dayN, err)
	}
	d1 := dayN[0]
	if d1.Day != 1 || d1.Eligible != 2 || d1.Retained != 1 {
		t.Fatalf("D1 = %+v, want eligible 2 / retained 1", d1)
	}
	if d30 := dayN[2]; d30.Day != 30 || d30.Eligible != 0 {
		t.Fatalf("D30 = %+v: 30 дней ещё не прошло, eligible должен быть 0", d30)
	}
}

func TestAdminStatsFunnelAndFeatures(t *testing.T) {
	repo, db := newStatsRepo(t)

	full := testutil.SeedUser(t, db, "full@test.io", day(5))
	testutil.SeedUser(t, db, "idle@test.io", day(6))
	testutil.SeedEvent(t, db, full, entities.EventListCreated, day(5), "")
	testutil.SeedEvent(t, db, full, entities.EventItemAdded, day(5), "")
	testutil.SeedEvent(t, db, full, entities.EventItemAdded, day(6), "")
	testutil.SeedEvent(t, db, full, entities.EventItemBought, day(6), "")
	testutil.SeedEvent(t, db, full, entities.EventFamilyJoined, day(7), "")
	testutil.SeedEvent(t, db, full, entities.EventAiMessageSent, day(7), "")

	funnel, err := repo.FunnelCounts(utcDay(1), utcDay(10))
	if err != nil {
		t.Fatalf("FunnelCounts: %v", err)
	}
	want := (stats.FunnelCounts{SignedUp: 2, CreatedList: 1, AddedItem: 1, BoughtItem: 1, JoinedFamily: 1})
	if funnel != want {
		t.Fatalf("funnel = %+v, want %+v", funnel, want)
	}

	features, err := repo.FeatureUsers(utcDay(1), utcDay(10))
	if err != nil {
		t.Fatalf("FeatureUsers: %v", err)
	}
	got := map[string]int64{}
	for _, f := range features {
		got[f.Name] = f.Count
	}
	if got["ai_chat"] != 1 || got["families"] != 1 || got["recipes"] != 0 {
		t.Fatalf("features = %+v", got)
	}
}
```

Добавь `"pora/internal/stats"` в импорты теста.

- [ ] **Step 5: Запусти — должен упасть**

Run: `cd backend && go test -p 1 ./internal/repositories/ -run 'Retention|Funnel'`
Expected: FAIL — заглушки возвращают пустые значения (`sizes = []`, `funnel = {0 0 0 0 0}`).

- [ ] **Step 6: Реализуй SQL**

В `backend/internal/repositories/admin_stats.go` замени заглушки `WeeklyRetention`, `DayNRetention`, `FunnelCounts`, `FeatureUsers`:

```go
// WeeklyRetention возвращает размеры недельных когорт и возвраты по неделям
func (r *AdminStatsRepo) WeeklyRetention(since time.Time, tz string) (
	[]stats.CohortSize, []stats.CohortCell, error) {

	args := map[string]any{"since": since, "tz": tz}

	var sizes []stats.CohortSize
	err := r.db.Raw(`
		SELECT TO_CHAR(CAST(date_trunc('week', `+userCreatedAt+` AT TIME ZONE @tz) AS date), 'YYYY-MM-DD') AS cohort_week,
			COUNT(*) AS size
		FROM users
		WHERE `+userCreatedAt+` >= @since
		GROUP BY 1
		ORDER BY 1`, args).Scan(&sizes).Error
	if err != nil {
		return nil, nil, err
	}

	var cells []stats.CohortCell
	err = r.db.Raw(`
		WITH cohort AS (
			SELECT id AS user_id,
				CAST(date_trunc('week', `+userCreatedAt+` AT TIME ZONE @tz) AS date) AS cohort_week
			FROM users
			WHERE `+userCreatedAt+` >= @since
		),
		activity AS (
			SELECT user_id, CAST(date_trunc('week', created_at AT TIME ZONE @tz) AS date) AS week
			FROM user_logins
			WHERE created_at >= @since
			UNION
			SELECT user_id, CAST(date_trunc('week', occurred_at AT TIME ZONE @tz) AS date)
			FROM analytics_events
			WHERE user_id IS NOT NULL AND occurred_at >= @since
		)
		SELECT TO_CHAR(c.cohort_week, 'YYYY-MM-DD') AS cohort_week,
			(a.week - c.cohort_week) / 7 AS week_n,
			COUNT(DISTINCT a.user_id) AS users
		FROM cohort c
		JOIN activity a ON a.user_id = c.user_id AND a.week > c.cohort_week
		GROUP BY c.cohort_week, a.week
		ORDER BY c.cohort_week, a.week`, args).Scan(&cells).Error
	if err != nil {
		return nil, nil, err
	}

	return sizes, cells, nil
}

// DayNRetention возвращает D1/D7/D30 для регистраций начиная с since.
// eligible - юзеры, у которых день N уже наступил к today
func (r *AdminStatsRepo) DayNRetention(since time.Time, today string,
	tz string) ([]responses.DayNRetention, error) {

	var rows []responses.DayNRetention
	err := r.db.Raw(`
		WITH cohort AS (
			SELECT id AS user_id,
				CAST(`+userCreatedAt+` AT TIME ZONE @tz AS date) AS d0
			FROM users
			WHERE `+userCreatedAt+` >= @since
		),
		activity AS (
			SELECT DISTINCT user_id, d FROM (
				SELECT user_id, CAST(created_at AT TIME ZONE @tz AS date) AS d
				FROM user_logins
				WHERE created_at >= @since
				UNION ALL
				SELECT user_id, CAST(occurred_at AT TIME ZONE @tz AS date)
				FROM analytics_events
				WHERE user_id IS NOT NULL AND occurred_at >= @since
			) raw
		)
		SELECT v.n AS day,
			COUNT(*) FILTER (WHERE c.d0 + v.n <= CAST(@today AS date)) AS eligible,
			COUNT(*) FILTER (WHERE c.d0 + v.n <= CAST(@today AS date)
				AND a.user_id IS NOT NULL) AS retained
		FROM cohort c
		CROSS JOIN (VALUES (1), (7), (30)) AS v(n)
		LEFT JOIN activity a ON a.user_id = c.user_id AND a.d = c.d0 + v.n
		GROUP BY v.n
		ORDER BY v.n`,
		map[string]any{"since": since, "today": today, "tz": tz}).Scan(&rows).Error
	return rows, err
}

// FunnelCounts возвращает шаги нестрогой воронки для регистраций в [start, end)
func (r *AdminStatsRepo) FunnelCounts(start, end time.Time) (stats.FunnelCounts, error) {
	var counts stats.FunnelCounts
	err := r.db.Raw(`
		WITH cohort AS (
			SELECT id FROM users
			WHERE `+userCreatedAt+` >= @start AND `+userCreatedAt+` < @end
		),
		reached AS (
			SELECT DISTINCT e.user_id, e.name
			FROM analytics_events e
			JOIN cohort c ON c.id = e.user_id
			WHERE e.name IN ('list_created', 'item_added', 'item_bought',
				'family_created', 'family_joined')
		)
		SELECT
			(SELECT COUNT(*) FROM cohort) AS signed_up,
			(SELECT COUNT(*) FROM reached WHERE name = 'list_created') AS created_list,
			(SELECT COUNT(*) FROM reached WHERE name = 'item_added') AS added_item,
			(SELECT COUNT(*) FROM reached WHERE name = 'item_bought') AS bought_item,
			(SELECT COUNT(DISTINCT user_id) FROM reached
				WHERE name IN ('family_created', 'family_joined')) AS joined_family`,
		window(start, end)).Scan(&counts).Error
	return counts, err
}

// FeatureUsers возвращает число юзеров по фичам в [start, end)
func (r *AdminStatsRepo) FeatureUsers(start, end time.Time) ([]responses.NameCount, error) {
	var rows []responses.NameCount
	err := r.db.Raw(`
		SELECT f.feature AS name, COUNT(DISTINCT e.user_id) AS count
		FROM analytics_events e
		JOIN (VALUES
			('ai_chat', 'ai_chat_opened'),
			('ai_chat', 'ai_message_sent'),
			('recipes', 'recipe_import'),
			('families', 'family_created'),
			('families', 'family_joined')
		) AS f(feature, event) ON f.event = e.name
		WHERE e.user_id IS NOT NULL AND e.occurred_at >= @start AND e.occurred_at < @end
		GROUP BY f.feature`, window(start, end)).Scan(&rows).Error
	return rows, err
}
```

Примечание к `WeeklyRetention`: группировка идёт по `a.week` (входная колонка), а `week_n` вычисляется из неё — так не возникает неоднозначности алиаса в `GROUP BY`.

- [ ] **Step 7: Запусти — должен пройти**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: `ok  	pora/internal/repositories`

- [ ] **Step 8: Сервис**

В `backend/internal/services/admin_stats.go` замени заглушки `Retention`, `Funnel`, `Features` (добавь импорты `"math"`, `"time"`, `"pora/internal/errors"`):

```go
const (
	// retentionDayNWindowDays - за сколько дней брать регистрации для D1/D7/D30
	retentionDayNWindowDays = 120
	maxRetentionWeeks       = 12
)

// features - фичи для adoption в фиксированном порядке
var features = []string{"ai_chat", "recipes", "families"}

// Retention возвращает когорты по неделям регистрации и D1/D7/D30
// на последний день периода
func (s *AdminStatsService) Retention(p stats.Period,
	weeks int) (responses.AdminRetention, error) {

	var result responses.AdminRetention

	if weeks < 1 || weeks > maxRetentionWeeks {
		return result, errors.ErrorInvalidInput
	}

	today := p.LastDay()
	currentWeek := stats.WeekStart(today)
	since := currentWeek.AddDate(0, 0, -7*weeks)

	sizes, cells, err := s.repo.WeeklyRetention(since, p.TZ())
	if err != nil {
		return result, err
	}

	currentWeekKey, _ := time.Parse(stats.DateLayout, currentWeek.Format(stats.DateLayout))
	result.Cohorts = stats.BuildCohorts(sizes, cells, weeks, currentWeekKey)

	result.DayN, err = s.repo.DayNRetention(
		today.AddDate(0, 0, -retentionDayNWindowDays),
		today.Format(stats.DateLayout), p.TZ())
	if err != nil {
		return result, err
	}

	return result, nil
}

// Funnel возвращает нестрогую воронку активации для регистраций периода
func (s *AdminStatsService) Funnel(p stats.Period) (responses.AdminFunnel, error) {
	counts, err := s.repo.FunnelCounts(p.Start, p.End)
	if err != nil {
		return responses.AdminFunnel{}, err
	}

	return responses.AdminFunnel{Steps: []responses.FunnelStep{
		{Step: "signed_up", Users: counts.SignedUp},
		{Step: "created_list", Users: counts.CreatedList},
		{Step: "added_item", Users: counts.AddedItem},
		{Step: "bought_item", Users: counts.BoughtItem},
		{Step: "joined_family", Users: counts.JoinedFamily},
	}}, nil
}

// Features возвращает долю MAU, использовавших фичи, за 30 дней до конца периода
func (s *AdminStatsService) Features(p stats.Period) (responses.AdminFeatures, error) {
	var result responses.AdminFeatures

	start := p.End.AddDate(0, 0, -30)

	mau, err := s.repo.CountActiveUsers(start, p.End)
	if err != nil {
		return result, err
	}
	result.MAU = mau

	rows, err := s.repo.FeatureUsers(start, p.End)
	if err != nil {
		return result, err
	}

	byFeature := make(map[string]int64, len(rows))
	for _, row := range rows {
		byFeature[row.Name] = row.Count
	}

	for _, feature := range features {
		users := byFeature[feature]
		share := 0.0
		if mau > 0 {
			share = math.Round(float64(users)/float64(mau)*1000) / 10
		}
		result.Features = append(result.Features, responses.FeatureAdoption{
			Feature: feature,
			Users:   users,
			Share:   share,
		})
	}

	return result, nil
}
```

- [ ] **Step 9: Хэндлеры и маршруты**

В `backend/internal/handlers/admin.go` (добавь `"strconv"` в импорты):

```go
// Retention обрабатывает запрос когорт (weeks: 1..12, по умолчанию 8)
func (h *AdminHandler) Retention(c *gin.Context) {
	weeks, err := strconv.Atoi(c.DefaultQuery("weeks", "8"))
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Retention(p, weeks)
	})
}

// Funnel обрабатывает запрос воронки активации
func (h *AdminHandler) Funnel(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Funnel(p)
	})
}

// Features обрабатывает запрос adoption фич
func (h *AdminHandler) Features(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Features(p)
	})
}
```

В `main.go`, группа `admin`:

```go
		admin.GET("/retention", adminHandler.Retention)
		admin.GET("/funnel", adminHandler.Funnel)
		admin.GET("/features", adminHandler.Features)
```

- [ ] **Step 10: Сборка, тесты, commit**

Run: `cd backend && go build ./... && go vet ./... && go test -p 1 ./...`
Expected: все `ok`.

```bash
git -C backend add internal/stats internal/repositories/admin_stats.go \
  internal/repositories/admin_stats_test.go internal/services/admin_stats.go \
  internal/handlers/admin.go cmd/server/main.go
git -C backend commit -m "feat(backend): admin retention cohorts, activation funnel, feature adoption"
```

---

### Task 13: События по времени, товары, платформы

**Files:**
- Modify: `backend/internal/repositories/admin_stats.go`, `backend/internal/repositories/admin_stats_test.go`
- Modify: `backend/internal/services/admin_stats.go`
- Modify: `backend/internal/handlers/admin.go`, `backend/cmd/server/main.go`

- [ ] **Step 1: Падающие интеграционные тесты**

Добавь в `backend/internal/repositories/admin_stats_test.go`:

```go
func TestAdminStatsProductsAndPlatforms(t *testing.T) {
	repo, db := newStatsRepo(t)
	user := testutil.SeedUser(t, db, "shop@test.io", day(1))
	other := testutil.SeedUser(t, db, "other@test.io", day(1))

	testutil.SeedEvent(t, db, user, entities.EventItemAdded, day(5), `{"name":"молоко","section":"Молочное"}`)
	testutil.SeedEvent(t, db, other, entities.EventItemAdded, day(5), `{"name":"молоко","section":"Молочное"}`)
	testutil.SeedEvent(t, db, user, entities.EventItemAdded, day(6), `{"name":"хлеб","section":""}`)
	testutil.SeedEvent(t, db, user, entities.EventItemBought, day(6), `{"name":"хлеб"}`)

	top, err := repo.TopProducts(entities.EventItemAdded, utcDay(1), utcDay(10), 10)
	if err != nil || len(top) != 2 || top[0].Name != "молоко" || top[0].Count != 2 {
		t.Fatalf("TopProducts = %+v, %v", top, err)
	}

	sections, err := repo.SectionCounts(utcDay(1), utcDay(10))
	if err != nil || len(sections) != 2 || sections[0].Name != "Молочное" || sections[0].Count != 2 {
		t.Fatalf("SectionCounts = %+v, %v", sections, err)
	}

	series, err := repo.EventTimeseries(utcDay(1), utcDay(10), "UTC", []string{entities.EventItemBought})
	if err != nil || len(series) != 1 || series[0].Date != "2026-10-06" || series[0].Count != 1 {
		t.Fatalf("EventTimeseries = %+v, %v", series, err)
	}
	all, err := repo.EventTimeseries(utcDay(1), utcDay(10), "UTC", nil)
	if err != nil || len(all) != 3 {
		t.Fatalf("EventTimeseries(все) = %+v, %v", all, err)
	}

	testutil.SeedDevice(t, db, user, "ios")
	testutil.SeedDevice(t, db, other, "android")
	testutil.SeedDevice(t, db, other, "android")
	platforms, err := repo.PlatformUsers()
	if err != nil || len(platforms) != 2 {
		t.Fatalf("PlatformUsers = %+v, %v", platforms, err)
	}
	for _, p := range platforms {
		if p.Count != 1 {
			t.Fatalf("платформа %s: %d юзеров, want 1 (distinct user)", p.Name, p.Count)
		}
	}

	testutil.SeedSessionStart(t, db, user, day(3), "ios", "1.3.0")
	testutil.SeedSessionStart(t, db, user, day(7), "ios", "1.4.0")
	testutil.SeedSessionStart(t, db, other, day(7), "android", "1.4.0")
	versions, err := repo.AppVersionUsers(utcDay(1), utcDay(10))
	if err != nil || len(versions) != 1 || versions[0].Name != "1.4.0" || versions[0].Count != 2 {
		t.Fatalf("AppVersionUsers = %+v, %v (учитывается последняя версия юзера)", versions, err)
	}
}

func TestAdminStatsMedianHoursToBuy(t *testing.T) {
	repo, db := newStatsRepo(t)
	user := testutil.SeedUser(t, db, "median@test.io", day(1))

	if median, err := repo.MedianHoursToBuy(utcDay(1), utcDay(10)); err != nil || median != nil {
		t.Fatalf("без покупок медиана должна быть nil: %v, %v", median, err)
	}

	listID := uuid.New()
	testutil.Exec(t, db, `INSERT INTO lists (id, user_id, name) VALUES (?, ?, 'Тест')`, listID, user)
	for _, hours := range []int{2, 4, 30} {
		created := day(5)
		testutil.Exec(t, db, `INSERT INTO items (id, list_id, name, quantity, added_by_id, created_at, checked, checked_at)
			VALUES (?, ?, 'x', 1, ?, ?, TRUE, ?)`,
			uuid.New(), listID, user, created, created.Add(time.Duration(hours)*time.Hour))
	}

	median, err := repo.MedianHoursToBuy(utcDay(1), utcDay(10))
	if err != nil || median == nil || *median != 4 {
		t.Fatalf("MedianHoursToBuy = %v, %v; want 4", median, err)
	}
}
```

Добавь `"github.com/google/uuid"` в импорты теста.

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test -p 1 ./internal/repositories/ -run 'Products|Median'`
Expected: FAIL — заглушки возвращают `nil`.

- [ ] **Step 3: Реализуй SQL**

В `backend/internal/repositories/admin_stats.go` замени заглушки `EventTimeseries`, `TopProducts`, `SectionCounts`, `MedianHoursToBuy`, `PlatformUsers`, `AppVersionUsers`:

```go
// EventTimeseries возвращает события по дням и именам (names пустой - все)
func (r *AdminStatsRepo) EventTimeseries(start, end time.Time, tz string,
	names []string) ([]responses.EventDayCount, error) {

	args := window(start, end)
	args["tz"] = tz

	filter := ""
	if len(names) > 0 {
		filter = " AND name IN @names"
		args["names"] = names
	}

	var rows []responses.EventDayCount
	err := r.db.Raw(`
		SELECT TO_CHAR(CAST(occurred_at AT TIME ZONE @tz AS date), 'YYYY-MM-DD') AS date,
			name, COUNT(*) AS count
		FROM analytics_events
		WHERE occurred_at >= @start AND occurred_at < @end`+filter+`
		GROUP BY 1, 2
		ORDER BY 1, 2`, args).Scan(&rows).Error
	return rows, err
}

// TopProducts возвращает топ названий товаров из props события
func (r *AdminStatsRepo) TopProducts(event string, start, end time.Time,
	limit int) ([]responses.NameCount, error) {

	args := window(start, end)
	args["event"] = event
	args["limit"] = limit

	var rows []responses.NameCount
	err := r.db.Raw(`
		SELECT props->>'name' AS name, COUNT(*) AS count
		FROM analytics_events
		WHERE name = @event AND occurred_at >= @start AND occurred_at < @end
			AND COALESCE(props->>'name', '') <> ''
		GROUP BY 1
		ORDER BY 2 DESC, 1
		LIMIT @limit`, args).Scan(&rows).Error
	return rows, err
}

// SectionCounts возвращает распределение item_added по секциям
// ("" - товары без секции)
func (r *AdminStatsRepo) SectionCounts(start, end time.Time) ([]responses.NameCount, error) {
	var rows []responses.NameCount
	err := r.db.Raw(`
		SELECT COALESCE(props->>'section', '') AS name, COUNT(*) AS count
		FROM analytics_events
		WHERE name = 'item_added' AND occurred_at >= @start AND occurred_at < @end
		GROUP BY 1
		ORDER BY 2 DESC, 1`, window(start, end)).Scan(&rows).Error
	return rows, err
}

// MedianHoursToBuy возвращает медиану часов от добавления до покупки
// для товаров, купленных в [start, end); nil - покупок не было
func (r *AdminStatsRepo) MedianHoursToBuy(start, end time.Time) (*float64, error) {
	var median *float64
	err := r.db.Raw(`
		SELECT percentile_cont(0.5) WITHIN GROUP (
			ORDER BY EXTRACT(EPOCH FROM (checked_at - created_at)) / 3600.0)
		FROM items
		WHERE checked_at >= @start AND checked_at < @end AND checked_at > created_at`,
		window(start, end)).Row().Scan(&median)
	return median, err
}

// PlatformUsers возвращает число уникальных юзеров по типам устройств
func (r *AdminStatsRepo) PlatformUsers() ([]responses.NameCount, error) {
	var rows []responses.NameCount
	err := r.db.Raw(`
		SELECT device_type AS name, COUNT(DISTINCT user_id) AS count
		FROM devices
		GROUP BY 1
		ORDER BY 2 DESC, 1`).Scan(&rows).Error
	return rows, err
}

// AppVersionUsers возвращает распределение последней версии приложения
// среди юзеров с session_start в [start, end)
func (r *AdminStatsRepo) AppVersionUsers(start, end time.Time) ([]responses.NameCount, error) {
	var rows []responses.NameCount
	err := r.db.Raw(`
		SELECT COALESCE(NULLIF(app_version, ''), 'unknown') AS name, COUNT(*) AS count
		FROM (
			SELECT DISTINCT ON (user_id) user_id, app_version
			FROM analytics_events
			WHERE name = 'session_start' AND user_id IS NOT NULL
				AND occurred_at >= @start AND occurred_at < @end
			ORDER BY user_id, occurred_at DESC
		) latest
		GROUP BY 1
		ORDER BY 2 DESC, 1`, window(start, end)).Scan(&rows).Error
	return rows, err
}
```

`items.created_at` — `TIMESTAMPTZ` (миграция `family_and_lists_flow`), поэтому вычитание `checked_at - created_at` корректно без приведения зон.

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: `ok  	pora/internal/repositories`

- [ ] **Step 5: Сервис**

В `backend/internal/services/admin_stats.go` замени заглушки `EventTimeseries`, `TopProducts`, `Sections`, `Platforms`:

```go
const (
	defaultTopLimit = 20
	maxTopLimit     = 100
)

// knownEvents - события, доступные для графика по времени
var knownEvents = map[string]bool{
	entities.EventUserSignedUp: true, entities.EventListCreated: true,
	entities.EventItemAdded: true, entities.EventItemBought: true,
	entities.EventItemDeleted: true, entities.EventFamilyCreated: true,
	entities.EventFamilyJoined: true, entities.EventSessionStart: true,
	entities.EventScreenView: true, entities.EventAiChatOpened: true,
	entities.EventAiMessageSent: true, entities.EventAiTipGenerated: true,
	entities.EventRecipeImport: true, entities.EventSupportMessageSent: true,
	entities.EventViewModeChanged: true,
}

// EventTimeseries возвращает события по дням; неизвестные имена игнорируются
func (s *AdminStatsService) EventTimeseries(p stats.Period,
	names []string) (responses.AdminEventSeries, error) {

	filtered := make([]string, 0, len(names))
	for _, name := range names {
		if knownEvents[name] {
			filtered = append(filtered, name)
		}
	}

	points, err := s.repo.EventTimeseries(p.Start, p.End, p.TZ(), filtered)
	if err != nil {
		return responses.AdminEventSeries{}, err
	}
	return responses.AdminEventSeries{Points: points}, nil
}

// TopProducts возвращает топ товаров по добавлениям (kind=added)
// или покупкам (kind=bought) и медиану времени до покупки
func (s *AdminStatsService) TopProducts(p stats.Period, kind string,
	limit int) (responses.AdminTopProducts, error) {

	result := responses.AdminTopProducts{Kind: kind}

	var event string
	switch kind {
	case "added":
		event = entities.EventItemAdded
	case "bought":
		event = entities.EventItemBought
	default:
		return result, errors.ErrorInvalidInput
	}

	if limit <= 0 {
		limit = defaultTopLimit
	}
	if limit > maxTopLimit {
		limit = maxTopLimit
	}

	items, err := s.repo.TopProducts(event, p.Start, p.End, limit)
	if err != nil {
		return result, err
	}
	result.Items = items

	result.MedianHoursToBuy, err = s.repo.MedianHoursToBuy(p.Start, p.End)
	if err != nil {
		return result, err
	}

	return result, nil
}

// Sections возвращает распределение добавленных товаров по секциям
func (s *AdminStatsService) Sections(p stats.Period) (responses.AdminSections, error) {
	sections, err := s.repo.SectionCounts(p.Start, p.End)
	if err != nil {
		return responses.AdminSections{}, err
	}
	return responses.AdminSections{Sections: sections}, nil
}

// Platforms возвращает платформы устройств (за всё время) и версии приложения
// активных в периоде юзеров
func (s *AdminStatsService) Platforms(p stats.Period) (responses.AdminPlatforms, error) {
	var result responses.AdminPlatforms
	var err error

	if result.Platforms, err = s.repo.PlatformUsers(); err != nil {
		return result, err
	}
	if result.Versions, err = s.repo.AppVersionUsers(p.Start, p.End); err != nil {
		return result, err
	}
	return result, nil
}
```

- [ ] **Step 6: Хэндлеры и маршруты**

В `backend/internal/handlers/admin.go` (добавь `"strings"` в импорты):

```go
// EventTimeseries обрабатывает запрос событий по времени (names=a,b)
func (h *AdminHandler) EventTimeseries(c *gin.Context) {
	var names []string
	if raw := c.Query("names"); raw != "" {
		names = strings.Split(raw, ",")
	}

	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.EventTimeseries(p, names)
	})
}

// TopProducts обрабатывает запрос топа товаров (kind=added|bought, limit)
func (h *AdminHandler) TopProducts(c *gin.Context) {
	limit, err := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}
	kind := c.DefaultQuery("kind", "added")

	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.TopProducts(p, kind, limit)
	})
}

// Sections обрабатывает запрос распределения по секциям
func (h *AdminHandler) Sections(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Sections(p)
	})
}

// Platforms обрабатывает запрос платформ и версий приложения
func (h *AdminHandler) Platforms(c *gin.Context) {
	h.withPeriod(c, func(p stats.Period) (any, error) {
		return h.statsService.Platforms(p)
	})
}
```

В `main.go`, группа `admin`:

```go
		admin.GET("/events/timeseries", adminHandler.EventTimeseries)
		admin.GET("/products/top", adminHandler.TopProducts)
		admin.GET("/products/sections", adminHandler.Sections)
		admin.GET("/platforms", adminHandler.Platforms)
```

- [ ] **Step 7: Сборка, тесты, commit**

Run: `cd backend && go build ./... && go vet ./... && go test -p 1 ./...`
Expected: все `ok`.

```bash
git -C backend add internal/repositories/admin_stats.go internal/repositories/admin_stats_test.go \
  internal/services/admin_stats.go internal/handlers/admin.go cmd/server/main.go
git -C backend commit -m "feat(backend): admin event timeseries, product tops, platforms and versions"
```

---

### Task 14: Пользователи (список и карточка)

**Files:**
- Modify: `backend/internal/repositories/admin_stats.go`, `backend/internal/repositories/admin_stats_test.go`
- Modify: `backend/internal/services/admin_stats.go`
- Modify: `backend/internal/handlers/admin.go`, `backend/cmd/server/main.go`

- [ ] **Step 1: Падающий интеграционный тест**

Добавь в `backend/internal/repositories/admin_stats_test.go`:

```go
func TestAdminStatsUsers(t *testing.T) {
	repo, db := newStatsRepo(t)

	anna := testutil.SeedUser(t, db, "anna@test.io", day(1))
	testutil.SeedUser(t, db, "boris@test.io", day(2))
	testutil.SeedUser(t, db, "under_score@test.io", day(3))
	testutil.SeedLogin(t, db, anna, day(4))
	testutil.SeedEvent(t, db, anna, entities.EventItemAdded, day(9), "")
	testutil.Exec(t, db, `INSERT INTO lists (id, user_id, name) VALUES (?, ?, 'Дом')`, uuid.New(), anna)

	rows, total, err := repo.ListUsers("", 2, 0)
	if err != nil || total != 3 || len(rows) != 2 || rows[0].Email != "under_score@test.io" {
		t.Fatalf("ListUsers(страница) = %+v, total=%d, %v", rows, total, err)
	}

	rows, total, err = repo.ListUsers("ANNA", 50, 0)
	if err != nil || total != 1 || rows[0].ID != anna || rows[0].Lists != 1 {
		t.Fatalf("ListUsers(поиск) = %+v, total=%d, %v", rows, total, err)
	}
	if rows[0].LastActiveAt == nil || !rows[0].LastActiveAt.Equal(day(9)) {
		t.Fatalf("LastActiveAt = %v, want %v", rows[0].LastActiveAt, day(9))
	}

	// "_" в запросе — литерал, а не wildcard LIKE: находит только
	// "under_score@…"; без экранирования совпал бы и "boris@…" (r-i-s)
	if _, total, _ = repo.ListUsers("r_s", 50, 0); total != 1 {
		t.Fatalf("ListUsers(\"r_s\") total = %d, want 1", total)
	}

	row, err := repo.FindUserRow(anna)
	if err != nil || row == nil || row.Email != "anna@test.io" {
		t.Fatalf("FindUserRow = %+v, %v", row, err)
	}
	if row, err = repo.FindUserRow(uuid.New()); err != nil || row != nil {
		t.Fatalf("FindUserRow(нет такого) = %+v, %v", row, err)
	}
}
```

- [ ] **Step 2: Запусти — должен упасть**

Run: `cd backend && go test -p 1 ./internal/repositories/ -run TestAdminStatsUsers`
Expected: FAIL — заглушки.

- [ ] **Step 3: Реализуй SQL**

В `backend/internal/repositories/admin_stats.go` добавь константы и замени заглушки `ListUsers`, `FindUserRow` (импорт `"strings"`):

```go
// userRowSelect - строка пользователя для админки со счётчиками и последней активностью
const userRowSelect = `
	SELECT u.id,
		COALESCE(u.email, '') AS email,
		COALESCE(u.phone, '') AS phone,
		COALESCE(u.name, '') AS name,
		COALESCE(u.surname, '') AS surname,
		u.status,
		u.is_admin,
		u.created_at,
		GREATEST(
			(SELECT MAX(l.created_at) FROM user_logins l WHERE l.user_id = u.id),
			(SELECT MAX(e.occurred_at) FROM analytics_events e WHERE e.user_id = u.id)
		) AS last_active_at,
		(SELECT COUNT(*) FROM lists li WHERE li.user_id = u.id) AS lists,
		(SELECT COUNT(*) FROM items i WHERE i.added_by_id = u.id) AS items,
		(SELECT COUNT(*) FROM family_members fm WHERE fm.user_id = u.id) AS families
	FROM users u`

// userSearchFilter - поиск по почте, телефону, имени и фамилии
const userSearchFilter = `
	WHERE @like = ''
		OR u.email ILIKE @like OR u.phone ILIKE @like
		OR u.name ILIKE @like OR u.surname ILIKE @like`

// likeEscaper экранирует спецсимволы LIKE, чтобы поиск был буквальным
var likeEscaper = strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`)

// ListUsers возвращает страницу пользователей (новые сверху) и общее число
func (r *AdminStatsRepo) ListUsers(query string, limit,
	offset int) ([]responses.AdminUserRow, int64, error) {

	like := ""
	if trimmed := strings.TrimSpace(query); trimmed != "" {
		like = "%" + likeEscaper.Replace(trimmed) + "%"
	}

	var total int64
	err := r.db.Raw(`SELECT COUNT(*) FROM users u`+userSearchFilter,
		map[string]any{"like": like}).Scan(&total).Error
	if err != nil {
		return nil, 0, err
	}

	var rows []responses.AdminUserRow
	err = r.db.Raw(userRowSelect+userSearchFilter+`
		ORDER BY u.created_at DESC
		LIMIT @limit OFFSET @offset`,
		map[string]any{"like": like, "limit": limit, "offset": offset}).
		Scan(&rows).Error
	if err != nil {
		return nil, 0, err
	}

	return rows, total, nil
}

// FindUserRow возвращает строку пользователя (nil, если не найден)
func (r *AdminStatsRepo) FindUserRow(userID uuid.UUID) (*responses.AdminUserRow, error) {
	var rows []responses.AdminUserRow
	err := r.db.Raw(userRowSelect+` WHERE u.id = @id`,
		map[string]any{"id": userID}).Scan(&rows).Error
	if err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return nil, nil
	}
	return &rows[0], nil
}
```

- [ ] **Step 4: Запусти — должен пройти**

Run: `cd backend && go test -p 1 ./internal/repositories/`
Expected: `ok  	pora/internal/repositories`

- [ ] **Step 5: Сервис**

В `backend/internal/services/admin_stats.go` замени заглушки `Users`, `UserDetail` (импорт `"encoding/json"`):

```go
const (
	usersPageSize    = 50
	userDetailEvents = 100
)

// Users возвращает страницу пользователей (page с 1)
func (s *AdminStatsService) Users(query string, page int) (responses.AdminUsersPage, error) {
	if page < 1 {
		page = 1
	}

	rows, total, err := s.repo.ListUsers(query, usersPageSize, (page-1)*usersPageSize)
	if err != nil {
		return responses.AdminUsersPage{}, err
	}
	if rows == nil {
		rows = []responses.AdminUserRow{}
	}

	return responses.AdminUsersPage{
		Users:    rows,
		Total:    total,
		Page:     page,
		PageSize: usersPageSize,
	}, nil
}

// UserDetail возвращает карточку пользователя с последними событиями
func (s *AdminStatsService) UserDetail(userID uuid.UUID) (responses.AdminUserDetail, error) {
	var detail responses.AdminUserDetail

	row, err := s.repo.FindUserRow(userID)
	if err != nil {
		return detail, err
	}
	if row == nil {
		return detail, errors.ErrorUserNotFound
	}
	detail.User = *row

	events, err := s.eventRepo.FindRecentByUserID(userID, userDetailEvents)
	if err != nil {
		return detail, err
	}

	detail.Events = make([]responses.AdminEvent, 0, len(events))
	for _, event := range events {
		detail.Events = append(detail.Events, responses.AdminEvent{
			ID:         event.ID,
			Name:       event.Name,
			Props:      json.RawMessage(event.Props),
			Platform:   event.Platform,
			AppVersion: event.AppVersion,
			Source:     event.Source,
			OccurredAt: event.OccurredAt,
		})
	}

	return detail, nil
}
```

- [ ] **Step 6: Хэндлеры и маршруты**

В `backend/internal/handlers/admin.go` (импорт `"github.com/google/uuid"`):

```go
// Users обрабатывает запрос списка пользователей (q, page)
func (h *AdminHandler) Users(c *gin.Context) {
	page, err := strconv.Atoi(c.DefaultQuery("page", "1"))
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.statsService.Users(c.Query("q"), page)
	if err != nil {
		c.Error(err)
		return
	}

	c.JSON(http.StatusOK, response)
}

// UserDetail обрабатывает запрос карточки пользователя
func (h *AdminHandler) UserDetail(c *gin.Context) {
	userID, err := uuid.Parse(c.Param("user_id"))
	if err != nil {
		logger.Log.Warn("Некорректный uuid в запросе: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.statsService.UserDetail(userID)
	if err != nil {
		c.Error(err)
		return
	}

	c.JSON(http.StatusOK, response)
}
```

В `main.go`, группа `admin`:

```go
		admin.GET("/users", adminHandler.Users)
		admin.GET("/users/:user_id", adminHandler.UserDetail)
```

- [ ] **Step 7: Сборка, тесты, ручная проверка, commit**

Run: `cd backend && go build ./... && go vet ./... && go test -p 1 ./...`
Expected: все `ok`.

Ручная проверка всех эндпоинтов с admin-токеном:

```bash
docker compose -f backend/docker-compose.yml up -d --build
# 1) запроси OTP на почту из ADMIN_EMAILS
curl -s -X POST http://localhost:5040/api/authorize/send-otp -H 'Content-Type: application/json' -d '{"email":"<почта из ADMIN_EMAILS>"}'
# 2) подтверди код из письма, сохрани access-token в переменную (не печатай его)
ACCESS=$(curl -s -X POST http://localhost:5040/api/authorize/verify-otp -H 'Content-Type: application/json' \
  -d '{"email":"<почта>","otp":"<код>","client":"admin"}' | python3 -c 'import sys,json;print(json.load(sys.stdin)["access-token"])')
for path in me overview active-users signups retention funnel features events/timeseries "products/top?kind=bought" products/sections platforms users; do
  printf "%-28s " "$path"; curl -s -o /dev/null -w "%{http_code}\n" "http://localhost:5040/api/admin/$path" -H "Authorization: Bearer $ACCESS"
done
```

Expected: все `200`. Мобильное приложение того же юзера после этого остаётся залогиненным (refresh в приложении проходит).

```bash
git -C backend add internal/repositories/admin_stats.go internal/repositories/admin_stats_test.go \
  internal/services/admin_stats.go internal/handlers/admin.go cmd/server/main.go
git -C backend commit -m "feat(backend): admin users list and user detail with recent events"
```

---

### Task 15: CI бэкенд-репозитория и документация

**Files:**
- Create: `backend/.github/workflows/ci.yml` (в репозитории `backend/`, заработает после push бэкенда в GitHub)
- Modify: `DOCKER.md` (корень проекта; файл в `.gitignore` публичного репо — правится локально, **не коммитится**)

- [ ] **Step 1: Workflow в репозитории бэкенда**

`backend/.github/workflows/ci.yml`:

```yaml
name: Backend CI

on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: backend-ci-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  test:
    name: vet · test
    runs-on: ubuntu-latest
    timeout-minutes: 15
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: pora_test
          POSTGRES_USER: pora
          POSTGRES_PASSWORD: pora
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U pora -d pora_test"
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10
    env:
      TEST_DATABASE_URL: host=localhost port=5432 user=pora password=pora dbname=pora_test sslmode=disable
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
          cache-dependency-path: go.sum

      - name: Vet
        run: go vet ./...

      # -p 1: интеграционные пакеты делят одну тестовую БД
      - name: Test
        run: go test -p 1 ./...
```

Креды `pora/pora` — только для одноразового Postgres-контейнера CI, не продовые.

- [ ] **Step 2: Документация (локально)**

В корневой `DOCKER.md` добавь раздел в конец файла:

````markdown
## Админ-панель и аналитика

- `ADMIN_EMAILS` в `backend/.env` — почты администраторов через запятую. При старте сервер синхронизирует `users.is_admin` с этим списком (убранные из списка теряют права). Админ входит в панель тем же OTP-кодом, что и в приложение; вход админки не разлогинивает приложение.
- `/api/system/notify-everyone` удалён; рассылка — `POST /api/admin/push` (только админ).
- События аналитики: таблица `analytics_events`, хранятся 365 дней. Серверные события пишутся из сервисов асинхронно; клиентские — `POST /api/analytics/events`.
- `backend/` — отдельный git-репозиторий (корневой репо публичный, `backend/` в его `.gitignore`). Коммиты бэкенда: `git -C backend ...`.

### Тесты бэкенда

```bash
docker compose -f backend/docker-compose.yml up -d postgres
docker compose -f backend/docker-compose.yml exec postgres sh -c 'createdb -U "$POSTGRES_USER" pora_test'
export TEST_DATABASE_URL="host=localhost port=5432 user=<DB_USER> password=<DB_PASSWORD> dbname=pora_test sslmode=disable"
cd backend && go test -p 1 ./...
```

Без `TEST_DATABASE_URL` интеграционные тесты пропускаются. `-p 1` обязателен.
````

- [ ] **Step 3: Проверка YAML и commit (только бэкенд-репо)**

Run: `python3 -c "import yaml; yaml.safe_load(open('backend/.github/workflows/ci.yml'))" && echo OK`
Expected: `OK`

```bash
git -C backend add .github/workflows/ci.yml
git -C backend commit -m "ci: vet and tests with Postgres service"
```

---

## Проверка плана целиком (после Task 15)

```bash
cd backend && go build ./... && go vet ./... && go test -p 1 -race ./...
docker compose -f backend/docker-compose.yml up -d --build && docker compose -f backend/docker-compose.yml logs --tail 20 app
```

Expected: все тесты `ok`; в логах `Миграции успешно применены`, `Права администраторов синхронизированы`, `Сервер запущен на порту :5040`. `docker compose stop app` → в логах `События аналитики записаны, сервер остановлен`.
