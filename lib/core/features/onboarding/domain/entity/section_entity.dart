import 'package:equatable/equatable.dart';

abstract class SectionEntity extends Equatable {
  final String title;

  const SectionEntity({required this.title});

  @override
  List<Object?> get props => [title];
}
