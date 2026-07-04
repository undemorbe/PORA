import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/onboarding/domain/entity/section_entity.dart';
part 'section_model.g.dart';

@JsonSerializable()
class SectionModel extends SectionEntity {
  const SectionModel({required super.title});

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);
  Map<String, dynamic> toJson() => _$SectionModelToJson(this);
}
