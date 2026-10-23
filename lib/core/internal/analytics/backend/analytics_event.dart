import 'dart:math';

/// Клиентское событие аналитики в очереди `BackendEventSink`.
///
/// [id] генерируется на клиенте — по нему сервер отсекает повторную
/// отправку (`ON CONFLICT DO NOTHING`). Платформа и версия приложения
/// подставляются в момент отправки.
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.id,
    required this.name,
    required this.props,
    required this.occurredAt,
  });

  final String id;
  final String name;
  final Map<String, Object> props;
  final DateTime occurredAt;

  /// Формат `POST /api/analytics/events` (ключи kebab-case).
  Map<String, dynamic> toJson({
    required String platform,
    required String appVersion,
  }) => {
    'id': id,
    'name': name,
    'props': props,
    'platform': platform,
    'app-version': appVersion,
    'occurred-at': occurredAt.toUtc().toIso8601String(),
  };

  /// Формат хранения очереди на диске.
  Map<String, dynamic> toStorage() => {
    'id': id,
    'name': name,
    'props': props,
    'at': occurredAt.toUtc().toIso8601String(),
  };

  /// Восстанавливает событие из [toStorage]; битую запись пропускает (null).
  static AnalyticsEvent? fromStorage(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final at = DateTime.tryParse('${raw['at']}');
    if (id is! String || name is! String || at == null) return null;
    final rawProps = raw['props'];
    return AnalyticsEvent(
      id: id,
      name: name,
      props: rawProps is Map
          ? {
              for (final e in rawProps.entries)
                if (e.value != null) '${e.key}': e.value as Object,
            }
          : const {},
      occurredAt: at,
    );
  }
}

/// UUID v4 (RFC 4122) без внешних зависимостей.
String uuidV4([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // версия 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // вариант RFC 4122
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
