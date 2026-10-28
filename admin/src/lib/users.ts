import type { AdminUserRow } from '../api/types';

/** Имя для списка: «Имя Фамилия», иначе почта / телефон / id. */
export function displayName(user: AdminUserRow): string {
  const full = `${user.name} ${user.surname}`.trim();
  return full || user.email || user.phone || user.id;
}

/** Статусы `entities.UserStatus` бэкенда; неизвестный — как есть. */
const STATUS_LABELS: Record<string, string> = {
  user: 'активен',
  admin: 'активен',
  notRegistered: 'не завершил регистрацию',
  notFound: 'не найден',
  deleted: 'удалён',
};

export function statusLabel(status: string): string {
  return STATUS_LABELS[status] ?? status;
}

/** «почта · телефон · статус …» только из непустых частей. */
export function contactLine(user: AdminUserRow): string {
  return [user.email, user.phone, user.status ? `статус: ${statusLabel(user.status)}` : '']
    .filter(Boolean)
    .join(' · ');
}
