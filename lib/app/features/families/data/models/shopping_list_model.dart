import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/data/models/product_model.dart';
import 'package:pora/app/features/families/domain/entity/shopping_list.dart';
part 'shopping_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingListModel extends ShoppingListEntity {
  @JsonKey(name: 'highPriorityProducts')
  final List<ProductModel> highPriorityProductsModels;

  const ShoppingListModel({
    required super.id,
    required super.name,
    required this.highPriorityProductsModels,
  }) : super(highPriorityProducts: highPriorityProductsModels);

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingListModelToJson(this);
}
