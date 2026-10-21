import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/item_detail/data/datasource/local_prefs.dart';
import 'package:pora/core/features/item_detail/domain/usecase/delete_item.dart';
import 'package:pora/core/features/item_detail/domain/usecase/get_item.dart';
import 'package:pora/core/features/item_detail/domain/usecase/mark_item_bought.dart';
import 'package:pora/core/features/item_detail/domain/usecase/notify_about_item.dart';
import 'package:pora/core/features/item_detail/domain/usecase/update_item.dart';
import 'package:pora/core/features/lists/domain/entity/products/product.dart';
import 'package:pora/core/internal/errors/success.dart';
part 'item_details_store.g.dart';

/// Локальная копия товара с подменёнными полями (оптимистичный toggle,
/// офлайн-правка). `id` и `addedBy` всегда берутся из `src`; `null` в
/// параметре значит «оставить как в `src`».
class _PatchedProduct extends ProductEntity {
  _PatchedProduct(
    ProductEntity src, {
    bool? checked,
    String? name,
    String? section,
    int? quantity,
    String? unit,
    int? priority,
    bool? urgent,
    int? remindEveryDay,
  }) : super(
         name: name ?? src.name,
         id: src.id,
         section: section ?? src.section,
         quantity: quantity ?? src.quantity,
         unit: unit ?? src.unit,
         priority: priority ?? src.priority,
         urgent: urgent ?? src.urgent,
         checked: checked ?? src.checked,
         remindEveryDay: remindEveryDay ?? src.remindEveryDay,
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

  /// Последняя успешная write-операция ушла в offline-очередь, а не на
  /// сервер — экран показывает «отправим, когда появится сеть».
  @observable
  bool lastWriteQueued = false;

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

  /// PUT /items/{iid}. `null` в любом параметре — оставить текущее
  /// значение (в том числе напоминание); `checked` всегда уходит текущий,
  /// чтобы правка не сняла отметку «куплено».
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
    final next = _PatchedProduct(
      current,
      name: name,
      section: section,
      quantity: quantity,
      unit: unit,
      priority: priority,
      urgent: urgent,
      remindEveryDay: remindEveryDays,
    );
    isLoading = true;
    final res = await GetIt.I<UpdateItemUseCase>().call(
      itemId: itemId,
      name: next.name,
      section: next.section,
      quantity: next.quantity,
      unit: next.unit,
      priority: next.priority,
      urgent: next.urgent,
      checked: next.checked,
      remindEveryDays: next.remindEveryDay,
    );
    isLoading = false;
    if (res.isRight) {
      final queued = res.right is QueuedSuccess;
      lastWriteQueued = queued;
      // Офлайн GET отдаст лишь кэш — применяем правку локально; с сервера
      // перечитываем только после реального успеха.
      if (queued) {
        item = next;
      } else {
        await load();
      }
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
      lastWriteQueued = res.right is QueuedSuccess;
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
      name: cur.name,
    );
    if (res.isRight) {
      lastWriteQueued = res.right is QueuedSuccess;
      return true;
    }
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
    if (res.isRight) {
      lastWriteQueued = res.right is QueuedSuccess;
      return true;
    }
    errorMessage = res.left.message;
    return false;
  }
}
