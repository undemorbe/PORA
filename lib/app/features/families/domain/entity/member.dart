import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class MemberEntity extends Equatable {
  final String id;
  final String name;
  final String? surname;
  @JsonKey(name: 'image-url')
  final String? imageUrl;

  @JsonKey(name: 'joined-at')
  final String joinedAt;
  @JsonKey(name: 'color')
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
