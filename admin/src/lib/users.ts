import type { AdminUserRow } from '../api/types';

/** Имя для списка: «Имя Фамилия», иначе почта / телефон / id. */
export function displayName(user: AdminUserRow): string {
  const full = `${user.name} ${user.surname}`.trim();
  return full || user.email || user.phone || user.id;
}
