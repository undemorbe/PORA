import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool unread;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    required this.unread,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? receivedAt,
    bool? unread,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      unread: unread ?? this.unread,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'data': data,
    'receivedAt': receivedAt.toIso8601String(),
    'unread': unread,
  };

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      NotificationEntity(
        id: json['id'] as String,
        title: json['title'] as String?,
        body: json['body'] as String?,
        data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        receivedAt:
            DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
            DateTime.now(),
        unread: (json['unread'] as bool?) ?? true,
      );

  @override
  List<Object?> get props => [id, title, body, data, receivedAt, unread];
}
