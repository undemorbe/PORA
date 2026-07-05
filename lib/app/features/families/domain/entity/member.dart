import 'package:equatable/equatable.dart';

abstract class MemberEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String joinedAt;
  final String colorCode;

  const MemberEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.joinedAt,
    required this.colorCode,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, joinedAt, colorCode];
}
