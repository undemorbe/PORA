import 'package:equatable/equatable.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';

abstract class ProductEntity extends Equatable {
  final String name;
  final String id;

  /// Название секции (backend возвращает в `GET /items/{iid}`). Не всегда
  /// доступно в контекстах list-view (там section группируется snapshot'ом),
  /// поэтому пустая строка допустима.
  final String section;
  final int quantity;
  final String unit;
  final int priority;
  final bool urgent;
  final bool checked;
  final bool? remindEveryDay;

  /// Для личных списков поле отсутствует — null.
  final MemberEntity? addedBy;

  const ProductEntity({
    required this.name,
    required this.id,
    required this.quantity,
    required this.unit,
    required this.priority,
    required this.urgent,
    required this.checked,
    required this.remindEveryDay,
    this.section = '',
    this.addedBy,
  });

  @override
  List<Object?> get props => [
    name,
    id,
    section,
    quantity,
    unit,
    priority,
    urgent,
    checked,
    remindEveryDay,
    addedBy,
  ];
}
