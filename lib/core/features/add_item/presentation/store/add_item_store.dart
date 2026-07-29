import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/features/item_detail/domain/usecase/add_item.dart';
part 'add_item_store.g.dart';

class AddItemStore = _AddItemStoreBase with _$AddItemStore;

abstract class _AddItemStoreBase with Store {
  _AddItemStoreBase({required this.lid});

  final String lid;

  @observable
  String name = '';

  @observable
  int quantity = 1;

  @observable
  String unit = AddItemDefaults.defaultUnit;

  @observable
  String section = AddItemDefaults.defaultSection;

  @observable
  int priority = 1;

  @observable
  bool urgent = false;

  @observable
  bool remind = false;

  @observable
  int remindDays = AddItemDefaults.remindDaysMin;

  @observable
  bool busy = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasCustomUnit => !AddItemDefaults.units.contains(unit);

  @computed
  bool get hasCustomSection =>
      !AddItemDefaults.sections.any((s) => s.$2 == section);

  @computed
  bool get canSubmit => name.trim().isNotEmpty && !busy;

  @action
  void setName(String v) => name = v;

  @action
  void setUnit(String v) => unit = v;

  @action
  void setSection(String v) => section = v;

  @action
  void setPriority(int v) => priority = v;

  @action
  void toggleUrgent(bool v) => urgent = v;

  @action
  void toggleRemind(bool v) => remind = v;

  @action
  void setRemindDays(int v) {
    final clamped = v.clamp(
      AddItemDefaults.remindDaysMin,
      AddItemDefaults.remindDaysMax,
    );
    remindDays = clamped;
  }

  @action
  void increment() => quantity = quantity + 1;

  @action
  void decrement() {
    if (quantity > 1) quantity = quantity - 1;
  }

  /// Возвращает true если продукт создан.
  @action
  Future<bool> submit() async {
    if (!canSubmit) return false;
    busy = true;
    errorMessage = null;
    final res = await GetIt.I<AddItemUseCase>().call(
      listId: lid,
      name: name.trim(),
      section: section,
      quantity: quantity,
      unit: unit,
      priority: priority,
      urgent: urgent,
      remindEveryDays: remind ? remindDays : null,
    );
    busy = false;
    if (res.isRight) return true;
    errorMessage = res.left.message;
    return false;
  }
}
