# PORA

PORA is a Flutter mobile app for shared household grocery planning. The app is
currently an early product scaffold with screen-level flows, clean architecture
boundaries, generated routing, localization, and networking foundations in
place.

## Current Scope

- Phone and OTP authentication flow.
- Onboarding screens for first-time users.
- Shared household grocery list with grouped items and member markers.
- Add item, item detail, search, notifications, household, settings, and
  insights screens.
- Prediction and replenishment screens for "time to restock" suggestions.
- Order checkout UI with cart rows, delivery slots, totals, and CTA.
- API client, token refresh, secure token storage, local storage, routing,
  theming, and localization infrastructure.

Many screens still use demo data. Data sources and stores should be connected
feature by feature as backend contracts stabilize.

## Tech Stack

- Flutter with Dart SDK `^3.12.2`.
- `auto_route` for generated navigation.
- `mobx` and `flutter_mobx` for state management.
- `get_it` for dependency injection.
- `dio` and `retrofit` for HTTP clients.
- `flutter_secure_storage` for token storage.
- `hive` and `hive_flutter` for local storage.
- `flutter_dotenv` for runtime environment configuration.
- `flutter_gen-l10n` ARB localization.
- `talker_flutter` for logging and route observation.

## Project Layout

```text
lib/
  main.dart
  app/
    features/        Feature modules split into data/domain/presentation layers.
    internal/        App-wide infrastructure, theme, DI, routing, storage, l10n.
assets/
  fonts/            Inter font family.
android/
ios/
test/
```

Generated files live next to their sources (`*.g.dart`, `app_router.gr.dart`,
and `l10n/generated/*`). Do not edit generated files by hand.

## Environment

Create a local `.env` file in the project root:

```dotenv
API_URL=https://your-api.example.com
```

The `.env` file is listed as a Flutter asset and is intentionally ignored by
Git. CI creates a minimal `.env` during validation and release builds.

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

Run on a specific target:

```bash
flutter run -d ios
flutter run -d android
```

## Development Commands

```bash
flutter analyze
flutter test
dart format .
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
flutter gen-l10n
```

Run a single test file or test name:

```bash
flutter test test/dummy_test.dart
flutter test --name "pattern"
```

## CI/CD

GitHub Actions workflow: `.github/workflows/dart.yml`.

The validation job runs on pull requests to `main` and `dev`, and checks:

- dependency installation;
- Dart formatting;
- Flutter static analysis;
- unit and widget tests with coverage.

The Android delivery job runs only after a successful push to `main`. It builds
a release App Bundle (`.aab`) and uploads it as a workflow artifact.

Required Android release secrets:

- `ANDROID_KEYSTORE_BASE64`: base64-encoded release keystore.
- `ANDROID_KEY_PROPERTIES`: contents of `android/key.properties`.

Optional runtime configuration:

- `API_URL`: GitHub Actions variable or secret used to generate `.env`.

## Notes

- `InjectionContainer.init()` must complete before `runApp`.
- Update generated code after editing routes, Retrofit clients, JSON models, or
  MobX stores.
- Keep feature code inside `lib/app/features/<feature>/` and shared UI or
  infrastructure inside `lib/app/internal/`.
