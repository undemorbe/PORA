import 'package:equatable/equatable.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';

abstract class ProductEntity extends Equatable {
  final String name;
  final String id;
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
    this.addedBy,
  });

  @override
  List<Object?> get props => [
        name,
        id,
        quantity,
        unit,
        priority,
        urgent,
        checked,
        remindEveryDay,
        addedBy,
      ];
}
