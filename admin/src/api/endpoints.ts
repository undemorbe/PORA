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

  /** Вход в админку только по email; не-админ или неизвестный email → 403 FORBIDDEN. */
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
