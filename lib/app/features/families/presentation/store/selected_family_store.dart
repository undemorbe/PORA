import 'package:mobx/mobx.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
part 'selected_family_store.g.dart';

/// Singleton — хранит выбранную семью между экранами (preview → concrete →
/// members). Позволяет получить `owner` и `members` без пробрасывания
/// через route args.
class SelectedFamilyStore = _SelectedFamilyStoreBase with _$SelectedFamilyStore;

abstract class _SelectedFamilyStoreBase with Store {
  @observable
  FamilyEntity? current;

  @action
  void select(FamilyEntity? family) {
    current = family;
  }
}
