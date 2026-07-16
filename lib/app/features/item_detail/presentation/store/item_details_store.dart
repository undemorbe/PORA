import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/item_detail/data/datasource/local_prefs.dart';
import 'package:pora/app/features/item_detail/domain/usecase/delete_item.dart';
import 'package:pora/app/features/item_detail/domain/usecase/get_item.dart';
import 'package:pora/app/features/item_detail/domain/usecase/mark_item_bought.dart';
import 'package:pora/app/features/item_detail/domain/usecase/notify_about_item.dart';
import 'package:pora/app/features/item_detail/domain/usecase/update_item.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
part 'item_details_store.g.dart';

class _PatchedProduct extends ProductEntity {
  _PatchedProduct(ProductEntity src, {required bool checked})
      : super(
          name: src.name,
          id: src.id,
          section: src.section,
          quantity: src.quantity,
          unit: src.unit,
          priority: src.priority,
          urgent: src.urgent,
          checked: checked,
          remindEveryDay: src.remindEveryDay,
          addedBy: src.addedBy,
        );
}

class ItemDetailsStore = _ItemDetailsStoreBase with _$ItemDetailsStore;

abstract class _ItemDetailsStoreBase with Store {
  _ItemDetailsStoreBase({required this.itemId});

  final String itemId;

  @observable
  ProductEntity? item;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isDeleted = false;

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    final res = await GetIt.I<GetItemUseCase>().call(itemId: itemId);
    isLoading = false;
    if (res.isRight) {
      item = res.right;
    } else {
      errorMessage = res.left.message;
    }
  }

  @action
  Future<bool> save({
    String? name,
    String? section,
    int? quantity,
    String? unit,
    int? priority,
    bool? urgent,
    int? remindEveryDays,
  }) async {
    final current = item;
    if (current == null) return false;
    isLoading = true;
    final res = await GetIt.I<UpdateItemUseCase>().call(
      itemId: itemId,
      name: name ?? current.name,
      section: section ?? current.section,
      quantity: quantity ?? current.quantity,
      unit: unit ?? current.unit,
      priority: priority ?? current.priority,
      urgent: urgent ?? current.urgent,
      remindEveryDays: remindEveryDays,
    );
    isLoading = false;
    if (res.isRight) {
      await load();
      return true;
    }
    errorMessage = res.left.message;
    return false;
  }

  @action
  Future<bool> delete() async {
    isLoading = true;
    final res = await GetIt.I<DeleteItemUseCase>().call(itemId: itemId);
    isLoading = false;
    if (res.isRight) {
      isDeleted = true;
      return true;
    }
    errorMessage = res.left.message;
    return false;
  }

  Future<bool> shouldSkipDeleteConfirm() =>
      GetIt.I<ItemDetailsPrefs>().shouldSkipDeleteConfirm();

  Future<void> setSkipDeleteConfirm(bool v) =>
      GetIt.I<ItemDetailsPrefs>().setSkipDeleteConfirm(v);

  /// PATCH /items/{iid}/bought — оптимистично меняем локально, откатываем
  /// при ошибке.
  @action
  Future<bool> toggleBought() async {
    final cur = item;
    if (cur == null) return false;
    final target = !cur.checked;
    item = _PatchedProduct(cur, checked: target);
    final res = await GetIt.I<MarkItemBoughtUseCase>().call(
      itemId: itemId,
      checked: target,
    );
    if (res.isRight) return true;
    item = _PatchedProduct(cur, checked: !target);
    errorMessage = res.left.message;
    return false;
  }

  /// Отправляет уведомление о продукте.
  /// [to] `null` = всем; иначе список user id.
  Future<bool> notify({
    required List<String>? to,
    required String message,
  }) async {
    final res = await GetIt.I<NotifyAboutItemUseCase>().call(
      itemId: itemId,
      to: to,
      message: message,
    );
    if (res.isRight) return true;
    errorMessage = res.left.message;
    return false;
  }
}
