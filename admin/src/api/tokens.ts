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
