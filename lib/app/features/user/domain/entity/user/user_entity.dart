import 'package:equatable/equatable.dart';

/// Доменная сущность пользователя.
class UserEntity extends Equatable {
  const UserEntity({
    this.id,
    this.name,
    this.surname,
    this.imageUrl,
    this.selfLists,
  });

  final String? id;
  final String? name;
  final String? surname;
  final String? imageUrl;

  /// Идентификаторы списков покупок пользователя.
  final List<String>? selfLists;

  @override
  List<Object?> get props => [id, name, surname, imageUrl, selfLists];
}
