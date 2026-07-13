import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/lists/data/models/converters/section_converter.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
part 'lists_array_model.g.dart';

@JsonSerializable()
@ListSectionConverter()
class ListsArrayModel extends ListsArrayEntity {
  const ListsArrayModel({required super.lists});

  factory ListsArrayModel.fromJson(Map<String, dynamic> json) =>
      _$ListsArrayModelFromJson(json);
  Map<String, dynamic> toJson() => _$ListsArrayModelToJson(this);
}
