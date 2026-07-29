import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/lists/data/models/lists/list_section_model.dart';
import 'package:pora/core/features/lists/domain/entity/lists/list_section.dart';

class ListSectionConverter
    implements JsonConverter<ListSectionEntity, Map<String, dynamic>> {
  const ListSectionConverter();

  @override
  ListSectionEntity fromJson(Map<String, dynamic> json) =>
      ListSectionModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ListSectionEntity object) =>
      (object as ListSectionModel).toJson();
}
