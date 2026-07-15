import 'package:pora/app/features/lists/data/models/lists/list_model.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';

class ListsArrayModel extends ListsArrayEntity {
  const ListsArrayModel({required super.lists});

  factory ListsArrayModel.fromJson(Map<String, dynamic> json) {
    final raw = json['lists'] as List?;
    return ListsArrayModel(
      lists: (raw ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ListModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lists': lists
            .whereType<ListModel>()
            .map((l) => l.toJson())
            .toList(),
      };
}
