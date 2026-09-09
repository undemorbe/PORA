# Нативные и платформенные фичи PORA

Документ описывает добавленные iOS/Android-эксклюзивы и LiveActivity: что уже
работает из Dart (проверено `flutter analyze`, 0 ошибок), а что требует ручной
нативной сборки в Xcode / Android Studio (нельзя собрать в CI-среде вслепую).

Статусы:
- **ГОТОВО** — Dart-код написан и компилируется, фича работает без доп. шагов.
- **ГОТОВО + нативный шаг** — Dart готов, но для полного эффекта нужен ручной
  нативный шаг (ниже по пунктам).
- **СКЕЛЕТ** — нативный код написан, но его нужно подключить в Xcode/Gradle
  (target membership, entitlements) и собрать на устройстве.

---

## 1. LiveActivity (iOS) + кросс-платформенное «важное напоминание»

Задача: показывать «Купи X от Y пользователя!», пока не отмечен checkbox.

### Что сделано

**Кросс-платформенный слой — ГОТОВО**
`lib/core/internal/notifications/important_reminder_service.dart`
- `ongoing` (несмахиваемое) уведомление на Android + time-sensitive на iOS с
  кнопкой **«Куплено»**.
- Висит, пока пользователь не нажмёт «Куплено» → вызывается
  `MarkItemBoughtUseCase` (и синхронизируется через offline-outbox) и
  напоминание снимается.
- Триггерится автоматически во `NotificationService._onForeground`, когда
  приходит FCM с `data.type == "urgent"` и `item-id` (контракт из
  `deep_link_handler.dart`). Поля `item-name`/`from` берутся из payload, иначе —
  из текста пуша.

**Нативный ActivityKit — ГОТОВО (собрано + встроено, проверено на симуляторе)**
Widget Extension target `PoraLiveActivityWidget` уже создан в проекте
(скриптом через gem `xcodeproj`) и всё подключено:
- Swift:
  - `ios/Runner/LiveActivity/PoraActivityAttributes.swift` — атрибуты (в обоих
    target'ах: Runner + widget).
  - `ios/Runner/LiveActivity/LiveActivityManager.swift` — обработчик канала (в
    Runner).
  - `ios/PoraLiveActivityWidget/PoraLiveActivityWidget.swift` — `@main`
    WidgetBundle + UI (Dynamic Island + Lock Screen).
  - `ios/PoraLiveActivityWidget/Info.plist` — `NSExtensionPointIdentifier =
    com.apple.widgetkit-extension`.
- `NSSupportsLiveActivities = YES` в `ios/Runner/Info.plist`.
- Регистрация канала в `AppDelegate.didInitializeImplicitFlutterEngine` через
  `registrar(forPlugin:).messenger()`.
- Build phase «Embed Foundation Extensions» встроена в Runner (перед «Thin
  Binary», иначе Xcode ругается на build-cycle).

Проверено: `flutter build ios --simulator` → сборка успешна,
`Runner.app/PlugIns/PoraLiveActivityWidget.appex` на месте, приложение
запускается на iPhone 16e.

**Что осталось только протестировать вживую (нельзя в headless-среде):**
- **Dynamic Island** виден только на симуляторе/устройстве iPhone 14 Pro и новее
  (у iPhone 16e острова нет — там Lock Screen баннер).
- **End-to-end триггер**: LiveActivity поднимается по FCM `type=urgent` + `item-id`
  → нужен вход в аккаунт + пуш. Для ручного теста можно временно дёрнуть
  `NotificationService.instance.importantReminder.show(itemId: 'x',
  productName: 'Молоко', fromUser: 'Аня')`.
- На устройстве Live Activities должны быть разрешены в системных настройках.

---

## 2. Android-эксклюзивы

### 2.1 App Shortcuts — ГОТОВО
`lib/core/internal/platform/app_shortcuts_service.dart` (пакет `quick_actions`).
Long-press по иконке → «Добавить товар», «Pora-AI», «Открыть списки». Навигация
через `AppRouter`. Инициализируется в `AppBootstrap._initPlatformIntegrations`
с локализованными подписями (ключ `shortcutAddItem` + `navList`/`navPora`).

Опционально: добавить кастомные иконки шорткатов — положить drawable
`ic_shortcut_*` в `android/app/src/main/res/drawable/` и передать их имена в
`ShortcutItem(icon: ...)`.

### 2.2 Share-to-app (импорт рецептов) — ГОТОВО + нативный шаг
`lib/core/internal/platform/share_intent_service.dart` (пакет
`receive_sharing_intent`).
Поток: поделиться ссылкой/текстом в PORA → вычленяем первый URL → кладём в
`SharedContentHolder` → ведём к спискам → при открытии экрана импорта рецепта
URL автоматически префиллится (`recipe_import_screen.dart`).

- **Android**: intent-filter `SEND`/`text/*` уже добавлен в `AndroidManifest.xml`.
- **iOS** (опционально): нужен отдельный **Share Extension** target — сервис
  намеренно ограничен Android (`Platform.isAndroid`).

### 2.3 Material You + edge-to-edge + predictive back — ГОТОВО
- **Material You**: `lib/core/internal/app/app.dart` — `DynamicColorBuilder`.
  На Android, если система отдаёт палитру из обоев, она гармонизируется в
  `ThemeData.colorScheme` (тинт Material-виджетов: ripple, selection). Бренд-цвета
  `PoraColors.*` (терракота) НЕ меняются — они используются напрямую, не через
  `colorScheme`. На iOS динамика игнорируется.
- **edge-to-edge**: `lib/main.dart` — `SystemUiMode.edgeToEdge` + прозрачные
  system bars. Проверьте, что контент учитывает `SafeArea`.
- **predictive back**: `android:enableOnBackInvokedCallback="true"` в
  `AndroidManifest.xml`.

### 2.4 Home-screen widget — СКЕЛЕТ
`lib/core/internal/platform/home_widget_service.dart` (пакет `home_widget`)
толкает сводку (кол-во списков + первые названия) в нативный виджет. Вызывается
из `GroupsStore` после загрузки.

Нативная часть уже добавлена:
- `android/app/src/main/kotlin/com/boris/pora/PoraWidgetProvider.kt`
- `android/app/src/main/res/xml/pora_widget_info.xml`
- `android/app/src/main/res/layout/pora_widget.xml`
- `<receiver>` в `AndroidManifest.xml`

Шаги для сборки:
1. Убедиться, что Gradle тянет зависимость `home_widget` (flutter pub get уже
   сделал; при проблемах — `flutter clean`).
2. Собрать APK, добавить виджет на рабочий стол (long-press → Widgets → PORA).
3. iOS home-screen widget — отдельная нативная работа (WidgetKit target), здесь
   не делалась.

---

## 3. Crashlytics + Analytics — ГОТОВО (проверено на симуляторе)

Firebase уже был в проекте (core + messaging, конфиги на месте). Добавлено:
- Пакеты `firebase_crashlytics`, `firebase_analytics` (линкуются через SPM;
  проверено — Crashlytics в `Runner.debug.dylib`, `FirebaseAnalytics.framework`
  в бандле).
- Android: gradle-плагин `com.google.firebase.crashlytics` в
  `settings.gradle.kts` + `app/build.gradle.kts`.
- **Crashlytics**: `lib/core/internal/errors/error_zone.dart` — все три ловушки
  (`FlutterError.onError`, `PlatformDispatcher.onError`, `runZonedGuarded`)
  дублируют ошибки в Crashlytics (guard по `Firebase.apps`, т.к. Firebase
  инициализируется отложенно). Сбор включается в release
  (`setCrashlyticsCollectionEnabled(!kDebugMode)` в AppBootstrap).
- **Analytics**: `lib/core/internal/analytics/analytics_service.dart` —
  типизированные события (`list_opened`, `item_added`, `ai_chat_opened`,
  `recipe_import`, `ai_config_saved`, `home_view_mode`, `support_message_sent`
  и др.). Инициализация + `logAppOpen` после `Firebase.initializeApp`. Точечные
  вызовы уже расставлены (settings, ai-config, home toggle) — остальные добавляй
  по мере надобности.

Примечание: в debug сбор аналитики/крашей выключен намеренно. Тестовый краш:
`FirebaseCrashlytics.instance.crash()` (только вне debug и после init).

## Новые пакеты (pubspec.yaml)
`quick_actions`, `receive_sharing_intent`, `dynamic_color`, `home_widget`,
`firebase_crashlytics`, `firebase_analytics`.

## Проверка
- `flutter analyze lib` → **0 ошибок**.
- `flutter build ios --simulator` → сборка успешна (Runner + widget extension
  `PoraLiveActivityWidget.appex`), приложение запущено на iPhone 16e.
- Crashlytics/Analytics слинкованы (SPM), LiveActivity target собран и встроен.

Осталось протестировать вживую (нужны аккаунт/пуш/устройство): Dynamic Island
на iPhone 14 Pro+, end-to-end LiveActivity по FCM, Android home-widget и
Share-to-app на Android-устройстве.
