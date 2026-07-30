import 'package:equatable/equatable.dart';

class TipEntity extends Equatable {
  final String title;
  final String subtitle;
  final String? emoji;

  const TipEntity({required this.title, required this.subtitle, this.emoji});

  @override
  List<Object?> get props => [title, subtitle, emoji];
}
