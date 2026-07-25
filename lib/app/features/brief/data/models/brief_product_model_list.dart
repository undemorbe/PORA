import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/brief/data/models/brief_product_model.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product_list.dart';

part 'brief_product_model_list.g.dart';

@JsonSerializable(includeIfNull: true)
class BriefProductModelList extends BriefProductListEntity {
  @JsonKey(name: 'brief-items')
  final List<BriefProductModel> items;
  const BriefProductModelList({required this.items}) : super(products: items);

  factory BriefProductModelList.fromJson(Map<String, dynamic> json) =>
      _$BriefProductModelListFromJson(json);

  Map<String, dynamic> toJson() => _$BriefProductModelListToJson(this);
}
