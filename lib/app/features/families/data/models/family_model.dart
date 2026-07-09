import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/data/models/member_model.dart';
import 'package:pora/app/features/families/data/models/product_model.dart';
import 'package:pora/app/features/families/data/models/shopping_list_model.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
part 'family_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FamilyModel extends FamilyEntity {
  @JsonKey(name: 'members')
  final List<MemberModel> membersModels;

  @JsonKey(name: 'owner')
  final MemberModel ownerModel;

  @JsonKey(name: 'highPriorityProducts')
  final List<ProductModel> highPriorityProductsModels;

  @JsonKey(name: 'lists')
  final List<ShoppingListModel> listsModels;

  const FamilyModel({
    required super.id,
    required super.name,
    required this.membersModels,
    required this.ownerModel,
    required super.createdAt,
    required super.isCurrent,
    this.highPriorityProductsModels = const [],
    this.listsModels = const [],
  }) : super(
         members: membersModels,
         owner: ownerModel,
         highPriorityProducts: highPriorityProductsModels,
         lists: listsModels,
       );

  factory FamilyModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyModelFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyModelToJson(this);
}
