import 'package:pora/core/features/families/data/models/member_model.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.name,
    required super.id,
    required super.quantity,
    required super.unit,
    required super.priority,
    required super.urgent,
    required super.checked,
    required super.remindEveryDay,
    super.section,
    super.addedBy,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final added = json['added-by'];
    return ProductModel(
      name: json['name'] as String,
      id: json['id'] as String,
      section: (json['section'] as String?) ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unit: (json['unit'] as String?) ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      urgent: (json['urgent'] as bool?) ?? false,
      checked: (json['checked'] as bool?) ?? false,
      remindEveryDay: json['remind-every-day'] as bool?,
      addedBy: added is Map<String, dynamic>
          ? MemberModel.fromJson(added)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final by = addedBy;
    return {
      'name': name,
      'id': id,
      'section': section,
      'quantity': quantity,
      'unit': unit,
      'priority': priority,
      'urgent': urgent,
      'checked': checked,
      'remind-every-day': remindEveryDay,
      if (by is MemberModel) 'added-by': by.toJson(),
    };
  }
}
