import 'package:pora/core/features/lists/data/models/lists/list_section_model.dart';
import 'package:pora/core/features/lists/domain/entity/lists/lists.dart';

class ListModel extends ListEntity {
  const ListModel({
    required super.id,
    required super.name,
    required super.sections,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    final raw = json['sections'] as List?;
    return ListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sections: (raw ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ListSectionModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sections': sections
        .whereType<ListSectionModel>()
        .map((s) => s.toJson())
        .toList(),
  };
}
