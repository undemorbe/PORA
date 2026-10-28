// Зеркало backend/internal/dto/responses/admin.go.
// Go отдаёт null вместо пустого слайса там, где он не инициализирован, — такие поля `| null`.

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

/**
 * `GET /api/admin/me` отдаёт ту же форму, что и `GetMyInfo` приложения
 * (`id, name, surname, email?, phone?, image-url?, lists`); здесь — только используемые поля.
 */
export interface AdminMe {
  id: string;
  name: string;
  surname: string;
  email?: string;
  phone?: string;
  'image-url'?: string;
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

/** Если в `names` только неизвестные события — `{points: []}`. */
export interface AdminEventSeries {
  points: { date: string; name: string; count: number }[] | null;
}

export interface AdminTopProducts {
  kind: 'added' | 'bought';
  items: NameCount[] | null;
  /** null, пока нет событий покупки с временем добавления (считается только по разовым товарам). */
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
