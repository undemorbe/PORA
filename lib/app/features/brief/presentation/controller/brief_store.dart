import 'package:mobx/mobx.dart';
part 'brief_store.g.dart';

class BriefStore = _BriefStoreBase with _$BriefStore;

abstract class _BriefStoreBase with Store {
  @action
  void updateProducts() {}
  @action
  void getProductsOrSections() {}
}
