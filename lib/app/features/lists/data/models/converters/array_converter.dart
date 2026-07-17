import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/lists/data/models/lists/list_model.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';

class ListEntityConverter
    implements JsonConverter<ListEntity, Map<String, dynamic>> {
  const ListEntityConverter();

  @override
  ListEntity fromJson(Map<String, dynamic> json) => ListModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ListEntity object) =>
      (object as ListModel).toJson();
}
