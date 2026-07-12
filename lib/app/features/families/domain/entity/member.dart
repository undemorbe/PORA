import 'package:equatable/equatable.dart';

abstract class MemberEntity extends Equatable {
  final String id;
  final String name;
  final String? surname;
  final String? imageUrl;
  final String joinedAt;
  final String colorCode;

  const MemberEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.joinedAt,
    required this.colorCode,
    this.surname,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, joinedAt, colorCode, surname];
}
