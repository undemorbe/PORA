import 'package:equatable/equatable.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/families/domain/entity/product.dart';
import 'package:pora/app/features/families/domain/entity/shopping_list.dart';

abstract class FamilyEntity extends Equatable {
  final String id;
  final String name;
  final List<MemberEntity> members;
  final MemberEntity owner;
  final String createdAt;
  final bool isCurrent;

  /// Превью срочных продуктов семьи (агрегируется бэкендом).
  final List<ProductEntity> highPriorityProducts;

  /// Списки покупок семьи (их может быть несколько).
  final List<ShoppingListEntity> lists;

  const FamilyEntity({
    required this.id,
    required this.name,
    required this.members,
    required this.owner,
    required this.createdAt,
    required this.isCurrent,
    required this.highPriorityProducts,
    required this.lists,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    members,
    owner,
    createdAt,
    isCurrent,
    highPriorityProducts,
    lists,
  ];
}
