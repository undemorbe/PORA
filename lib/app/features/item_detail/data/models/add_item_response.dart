/// Ответ `POST /lists/{lid}/items` — только id созданного товара.
class AddItemResponse {
  final String id;
  const AddItemResponse({required this.id});

  factory AddItemResponse.fromJson(Map<String, dynamic> json) =>
      AddItemResponse(id: json['id'] as String);
}
