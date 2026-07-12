import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

/// Доменная сущность пользователя.
class UserEntity extends Equatable {
  const UserEntity({
    this.id,
    this.name,
    this.surname,
    this.phone,
    this.email,
    this.imageUrl,
    this.selfLists,
  });

  final String? id;
  final String? name;
  final String? surname;
  final String? phone;
  final String? email;
  @JsonKey(name: 'image-url')
  final String? imageUrl;

  /// Идентификаторы списков покупок пользователя.
  @JsonKey(name: 'lists')
  final List<String>? selfLists;

  @override
  List<Object?> get props => [
    id,
    name,
    surname,
    phone,
    email,
    imageUrl,
    selfLists,
  ];
}
