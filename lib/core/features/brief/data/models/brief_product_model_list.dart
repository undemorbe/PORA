import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/brief/data/models/brief_product_model.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';

part 'brief_product_model_list.g.dart';

@JsonSerializable()
class BriefProductModelList extends BriefProductListEntity {
  @JsonKey(name: 'brief-items')
  final List<BriefProductModel> items;
  const BriefProductModelList({required this.items}) : super(products: items);

  factory BriefProductModelList.fromJson(Map<String, dynamic> json) =>
      _$BriefProductModelListFromJson(json);

  Map<String, dynamic> toJson() => _$BriefProductModelListToJson(this);

  factory BriefProductModelList.fromEntityList(BriefProductListEntity entity) {
    return BriefProductModelList(
      items: entity.products
          .map((product) => BriefProductModel.fromEntity(product))
          .toList(),
    );
  }
}
