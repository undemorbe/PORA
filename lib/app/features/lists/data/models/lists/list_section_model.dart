import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/lists/data/models/converters/product_converter.dart';
import 'package:pora/app/features/lists/data/models/converters/section_converter.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';
part 'list_section_model.g.dart';

@JsonSerializable()
@ListSectionConverter()
@ProductConverter()
class ListSectionModel extends ListSectionEntity {
  const ListSectionModel({
    required super.name,
    required super.items,
    required super.id,
  });
  factory ListSectionModel.fromJson(Map<String, dynamic> json) =>
      _$ListSectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListSectionModelToJson(this);
}
