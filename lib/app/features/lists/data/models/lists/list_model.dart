import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/lists/data/models/converters/section_converter.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
part 'list_model.g.dart';

@JsonSerializable()
@ListSectionConverter()
class ListModel extends ListEntity {
  const ListModel({
    required super.id,
    required super.name,
    required super.sections,
  });
  factory ListModel.fromJson(Map<String, dynamic> json) =>
      _$ListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListModelToJson(this);
}
