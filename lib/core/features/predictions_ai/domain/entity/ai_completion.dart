import 'package:equatable/equatable.dart';

/// Ответ chat-completions, очищенный от транспортных деталей.
/// Используется в UI и store'ах.
class AiCompletionEntity extends Equatable {
  const AiCompletionEntity({required this.content});

  final String content;

  @override
  List<Object?> get props => [content];
}
