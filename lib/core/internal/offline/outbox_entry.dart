/// Одна отложенная write-операция в offline-очереди.
class OutboxEntry {
  OutboxEntry({
    required this.id,
    required this.kind,
    required this.args,
    required this.createdAt,
    this.attempts = 0,
  });

  /// Уникальный id записи (ключ в Hive).
  final String id;

  /// Тип операции, например `item.markBought`. По нему OutboxReplayer
  /// находит обработчик.
  final String kind;

  /// Аргументы операции (JSON-совместимые).
  final Map<String, dynamic> args;

  /// Unix-ms создания — очередь проигрывается в порядке создания.
  final int createdAt;

  /// Сколько раз пытались проиграть (для диагностики / backoff).
  int attempts;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'args': args,
    'created-at': createdAt,
    'attempts': attempts,
  };

  factory OutboxEntry.fromJson(Map<String, dynamic> json) => OutboxEntry(
    id: json['id'] as String,
    kind: json['kind'] as String,
    args: Map<String, dynamic>.from(json['args'] as Map),
    createdAt: json['created-at'] as int,
    attempts: (json['attempts'] as int?) ?? 0,
  );
}
