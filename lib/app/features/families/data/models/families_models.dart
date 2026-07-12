import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/families/data/models/family_model.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
part 'families_models.g.dart';

@JsonSerializable()
class FamiliesModels extends FamiliesEntity {
  const FamiliesModels({required this.families}) : super(families: families);
  @override
  final List<FamilyModel> families;

  factory FamiliesModels.fromJson(Map<String, dynamic> json) =>
      _$FamiliesModelsFromJson(json);
  Map<String, dynamic> toJson() => _$FamiliesModelsToJson(this);
}
