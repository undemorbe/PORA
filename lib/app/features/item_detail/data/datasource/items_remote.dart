import 'package:pora/app/features/lists/data/models/products/product_model.dart';
import 'package:pora/app/features/item_detail/data/models/add_item_response.dart';
import 'package:pora/app/internal/network/api_client/api_client.dart';

/// Data source. Кидает `Exception` — сервис оборачивает в `Failure`.
abstract class ItemsRemote {
  Future<ProductModel> getItem({required String itemId});
  Future<AddItemResponse> addItem({
    required String listId,
    required Map<String, dynamic> body,
  });
  Future<void> updateItem({
    required String itemId,
    required Map<String, dynamic> body,
  });
  Future<void> deleteItem({required String itemId});
  Future<void> notify({
    required String itemId,
    required Map<String, dynamic> body,
  });
  Future<void> markBought({required String itemId, required bool checked});
}

class ItemsRemoteImpl implements ItemsRemote {
  final ApiClient apiClient;
  const ItemsRemoteImpl({required this.apiClient});

  @override
  Future<ProductModel> getItem({required String itemId}) =>
      apiClient.getItem(itemId: itemId);

  @override
  Future<AddItemResponse> addItem({
    required String listId,
    required Map<String, dynamic> body,
  }) => apiClient.addItem(listId: listId, body: body);

  @override
  Future<void> updateItem({
    required String itemId,
    required Map<String, dynamic> body,
  }) => apiClient.updateItem(itemId: itemId, body: body);

  @override
  Future<void> deleteItem({required String itemId}) =>
      apiClient.deleteItem(itemId: itemId);

  @override
  Future<void> notify({
    required String itemId,
    required Map<String, dynamic> body,
  }) => apiClient.notifyAboutItem(itemId: itemId, body: body);

  @override
  Future<void> markBought({required String itemId, required bool checked}) =>
      apiClient.markItemBought(itemId: itemId, body: {'checked': checked});
}
