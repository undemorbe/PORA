import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? title;
  final String message;

  const MessageEntity({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}
