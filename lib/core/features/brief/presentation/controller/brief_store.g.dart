// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brief_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BriefStore on _BriefStoreBase, Store {
  late final _$_selectedProductsAtom = Atom(
    name: '_BriefStoreBase._selectedProducts',
    context: context,
  );

  ObservableSet<BriefProductEntity> get selectedProducts {
    _$_selectedProductsAtom.reportRead();
    return super._selectedProducts;
  }

  @override
  ObservableSet<BriefProductEntity> get _selectedProducts => selectedProducts;

  @override
  set _selectedProducts(ObservableSet<BriefProductEntity> value) {
    _$_selectedProductsAtom.reportWrite(value, super._selectedProducts, () {
      super._selectedProducts = value;
    });
  }

  late final _$allProductsAtom = Atom(
    name: '_BriefStoreBase.allProducts',
    context: context,
  );

  @override
  ObservableSet<BriefProductEntity> get allProducts {
    _$allProductsAtom.reportRead();
    return super.allProducts;
  }

  @override
  set allProducts(ObservableSet<BriefProductEntity> value) {
    _$allProductsAtom.reportWrite(value, super.allProducts, () {
      super.allProducts = value;
    });
  }

  late final _$_BriefStoreBaseActionController = ActionController(
    name: '_BriefStoreBase',
    context: context,
  );

  @override
  bool addToSelectedProducts(BriefProductEntity product) {
    final _$actionInfo = _$_BriefStoreBaseActionController.startAction(
      name: '_BriefStoreBase.addToSelectedProducts',
    );
    try {
      return super.addToSelectedProducts(product);
    } finally {
      _$_BriefStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromSelected(BriefProductEntity product) {
    final _$actionInfo = _$_BriefStoreBaseActionController.startAction(
      name: '_BriefStoreBase.removeFromSelected',
    );
    try {
      return super.removeFromSelected(product);
    } finally {
      _$_BriefStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteProduct(BriefProductEntity product) {
    final _$actionInfo = _$_BriefStoreBaseActionController.startAction(
      name: '_BriefStoreBase.deleteProduct',
    );
    try {
      return super.deleteProduct(product);
    } finally {
      _$_BriefStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool isContainsProduct(BriefProductEntity product) {
    final _$actionInfo = _$_BriefStoreBaseActionController.startAction(
      name: '_BriefStoreBase.isContainsProduct',
    );
    try {
      return super.isContainsProduct(product);
    } finally {
      _$_BriefStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
allProducts: ${allProducts}
    ''';
  }
}
