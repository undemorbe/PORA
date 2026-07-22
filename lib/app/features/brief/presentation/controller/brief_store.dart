import 'package:mobx/mobx.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product.dart';
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
    if(allProducts.contains(product)){

      if(_selectedProducts.contains(product)){
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
  void deleteProduct(BriefProductEntity product){
    allProducts.remove(product);
    removeFromSelected(product);
  }

  @action
  bool isContainsProduct(BriefProductEntity product) {
    return _selectedProducts.contains(product);
  }

  @action
  void getSelectedProducts() {}
}
