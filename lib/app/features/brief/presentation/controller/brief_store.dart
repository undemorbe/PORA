import 'package:mobx/mobx.dart';
part 'brief_store.g.dart';

//! CREATE LOGIC
class BriefStore = _BriefStoreBase with _$BriefStore;

abstract class _BriefStoreBase with Store {
  @action
  void updateProducts() {}
  @action
  void getProductsOrSections() {}
}
