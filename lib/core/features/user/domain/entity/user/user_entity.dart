import 'package:equatable/equatable.dart';
import 'package:pora/core/features/lists/domain/entity/lists/lists.dart';

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
  final String? imageUrl;

  /// Личные списки покупок пользователя.
  final List<ListEntity>? selfLists;

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
