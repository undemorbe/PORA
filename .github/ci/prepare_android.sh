#!/usr/bin/env bash
# Готовит файлы, которые не хранятся в репозитории, из CI-секретов:
#   .env, android/app/google-services.json, keystore + android/key.properties.
#
# Режимы:
#   prepare_android.sh test     — только минимальный .env (для analyze/test).
#   prepare_android.sh debug    — минимальный .env + google-services.json
#                                 (smoke-сборка debug APK без подписи).
#   prepare_android.sh release  — всё для подписанной release-сборки; падает,
#                                 если чего-то не хватает.
#
# Переменные окружения (GitHub secrets / vars):
#   DOT_ENV                   полный .env (raw или base64). Иначе собирается
#                             из API_URL, WS_URL, AI_API_URL, AI_CHAT_MODEL,
#                             AI_TIP_MODEL, AI_RECIPE_SCRAPPER_URL, PRIVACY_POLICY_URL.
#   EMBED_AI_KEY=true         оставить AI_API_KEY в .env. По умолчанию ключ
#                             вырезается: .env пакуется в APK как asset и из
#                             публичного релиза достаётся распаковкой архива.
#   GOOGLE_SERVICES_JSON      google-services.json (raw или base64).
#   ANDROID_KEYSTORE_BASE64   upload keystore (.jks) в base64.
#   ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD
#                             — либо legacy ANDROID_KEY_PROPERTIES (весь файл).
set -euo pipefail

MODE="${1:-release}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() { echo "::error::$*" >&2; exit 1; }

# raw-или-base64: если строка валидно декодируется в то, что начинается с
# ожидаемого префикса — берём декод, иначе как есть.
decode_maybe() {
  local value="$1" prefix="$2" decoded
  if decoded="$(printf '%s' "$value" | base64 --decode 2>/dev/null)" &&
    [[ "$decoded" == "$prefix"* ]]; then
    printf '%s' "$decoded"
  else
    printf '%s' "$value"
  fi
}

write_env() {
  if [[ -n "${DOT_ENV:-}" ]]; then
    local decoded
    if decoded="$(printf '%s' "$DOT_ENV" | base64 --decode 2>/dev/null)" &&
      grep -qE '^[A-Z_][A-Z0-9_]*=' <<<"$decoded"; then
      printf '%s\n' "$decoded" >.env.tmp
    else
      printf '%s\n' "$DOT_ENV" >.env.tmp
    fi
  else
    : >.env.tmp
    for key in API_URL WS_URL AI_API_URL AI_CHAT_MODEL AI_TIP_MODEL \
      AI_RECIPE_SCRAPPER_URL PRIVACY_POLICY_URL; do
      if [[ -n "${!key:-}" ]]; then
        printf '%s=%s\n' "$key" "${!key}" >>.env.tmp
      fi
    done
  fi

  if [[ "${EMBED_AI_KEY:-false}" != "true" ]]; then
    sed -i.bak '/^AI_API_KEY=/d' .env.tmp && rm -f .env.tmp.bak
  fi
  mv .env.tmp .env

  if [[ "$MODE" != "release" ]]; then
    grep -q '^API_URL=' .env || printf 'API_URL=https://example.invalid\n' >>.env
    return
  fi

  # dotenv.get(...) без fallback бросает исключение в рантайме — ловим заранее.
  local missing=()
  for key in API_URL AI_CHAT_MODEL AI_TIP_MODEL AI_RECIPE_SCRAPPER_URL \
    PRIVACY_POLICY_URL; do
    grep -qE "^${key}=.+" .env || missing+=("$key")
  done
  ((${#missing[@]} == 0)) || fail ".env: missing required keys: ${missing[*]}"
  echo ".env: $(grep -c '=' .env) keys written (AI_API_KEY embedded: ${EMBED_AI_KEY:-false})"
}

write_google_services() {
  [[ -n "${GOOGLE_SERVICES_JSON:-}" ]] || fail "GOOGLE_SERVICES_JSON secret is required"
  decode_maybe "$GOOGLE_SERVICES_JSON" "{" >android/app/google-services.json
  python3 -c 'import json,sys; json.load(open(sys.argv[1]))' \
    android/app/google-services.json || fail "google-services.json is not valid JSON"
}

write_signing() {
  [[ -n "${ANDROID_KEYSTORE_BASE64:-}" ]] || fail "ANDROID_KEYSTORE_BASE64 secret is required"
  local jks="$ROOT/android/app/upload-keystore.jks"
  printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64 --decode >"$jks"
  [[ -s "$jks" ]] || fail "decoded keystore is empty"

  if [[ -n "${ANDROID_KEYSTORE_PASSWORD:-}" ]]; then
    : "${ANDROID_KEY_ALIAS:?ANDROID_KEY_ALIAS is required}"
    {
      printf 'storePassword=%s\n' "$ANDROID_KEYSTORE_PASSWORD"
      printf 'keyPassword=%s\n' "${ANDROID_KEY_PASSWORD:-$ANDROID_KEYSTORE_PASSWORD}"
      printf 'keyAlias=%s\n' "$ANDROID_KEY_ALIAS"
    } >android/key.properties
  elif [[ -n "${ANDROID_KEY_PROPERTIES:-}" ]]; then
    # Legacy-секрет: путь storeFile из него не совпадает с раннером — подменяем.
    printf '%s\n' "$ANDROID_KEY_PROPERTIES" | grep -v '^storeFile=' >android/key.properties
  else
    fail "ANDROID_KEYSTORE_PASSWORD/ANDROID_KEY_ALIAS or ANDROID_KEY_PROPERTIES is required"
  fi
  printf 'storeFile=%s\n' "$jks" >>android/key.properties
  for key in storePassword keyPassword keyAlias; do
    grep -qE "^${key}=.+" android/key.properties || fail "key.properties: missing $key"
  done
  echo "Signing configured (alias: $(grep '^keyAlias=' android/key.properties | cut -d= -f2-))"
}

case "$MODE" in
  test) write_env ;;
  debug) write_env && write_google_services ;;
  release) write_env && write_google_services && write_signing ;;
  *) fail "unknown mode '$MODE' (test|debug|release)" ;;
esac
