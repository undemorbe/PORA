import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product.dart';
import 'package:pora/core/features/brief/domain/entity/brief_product_list.dart';
import 'package:pora/core/features/brief/domain/usecases/get_brief.dart';
import 'package:pora/core/features/brief/domain/usecases/post_brief.dart';
part 'brief_store.g.dart';

//! CREATE LOGIC
class BriefStore = _BriefStoreBase with _$BriefStore;

abstract class _BriefStoreBase with Store {
  //Logic
  @readonly
  ObservableSet<BriefProductEntity> _selectedProducts = ObservableSet();

  //UI
  @observable
  ObservableSet<BriefProductEntity> allProducts = ObservableSet();

  @action
  bool addToSelectedProducts(BriefProductEntity product) {
    if (allProducts.contains(product)) {
      if (_selectedProducts.contains(product)) {
        return false;
      }
      _selectedProducts.add(product);
      return true;
    }
    _selectedProducts.add(product);
    allProducts.add(product);
    return true;
  }

  @action
  void removeFromSelected(BriefProductEntity product) {
    _selectedProducts.remove(product);
  }

  @action
  void deleteProduct(BriefProductEntity product) {
    allProducts.remove(product);
    removeFromSelected(product);
  }

  @action
  bool isContainsProduct(BriefProductEntity product) {
    return _selectedProducts.contains(product);
  }

  //Api
  Future<void> postBrief() async {
    final repo = GetIt.I<PostBriefUseCase>();
    await repo.call(
      products: BriefProductListEntity(products: _selectedProducts.toList()),
    );
  }

  Future<void> getBrief() async {
    final repo = GetIt.I<GetBriefUseCase>();
    final briefList = await repo.call();
    _selectedProducts.addAll(briefList.products);
  }
}
