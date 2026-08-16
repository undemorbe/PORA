// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StatisticsStore on _StatisticsStoreBase, Store {
  Computed<int>? _$streakDaysComputed;

  @override
  int get streakDays => (_$streakDaysComputed ??= Computed<int>(
    () => super.streakDays,
    name: '_StatisticsStoreBase.streakDays',
  )).value;

  late final _$loginsAtom = Atom(
    name: '_StatisticsStoreBase.logins',
    context: context,
  );

  @override
  ObservableList<DateTime> get logins {
    _$loginsAtom.reportRead();
    return super.logins;
  }

  @override
  set logins(ObservableList<DateTime> value) {
    _$loginsAtom.reportWrite(value, super.logins, () {
      super.logins = value;
    });
  }

  late final _$isLoginsLoadingAtom = Atom(
    name: '_StatisticsStoreBase.isLoginsLoading',
    context: context,
  );

  @override
  bool get isLoginsLoading {
    _$isLoginsLoadingAtom.reportRead();
    return super.isLoginsLoading;
  }

  @override
  set isLoginsLoading(bool value) {
    _$isLoginsLoadingAtom.reportWrite(value, super.isLoginsLoading, () {
      super.isLoginsLoading = value;
    });
  }

  late final _$loginsErrorAtom = Atom(
    name: '_StatisticsStoreBase.loginsError',
    context: context,
  );

  @override
  String? get loginsError {
    _$loginsErrorAtom.reportRead();
    return super.loginsError;
  }

  @override
  set loginsError(String? value) {
    _$loginsErrorAtom.reportWrite(value, super.loginsError, () {
      super.loginsError = value;
    });
  }

  late final _$allProductsAtom = Atom(
    name: '_StatisticsStoreBase.allProducts',
    context: context,
  );

  @override
  ObservableList<ProductEntity> get allProducts {
    _$allProductsAtom.reportRead();
    return super.allProducts;
  }

  @override
  set allProducts(ObservableList<ProductEntity> value) {
    _$allProductsAtom.reportWrite(value, super.allProducts, () {
      super.allProducts = value;
    });
  }

  late final _$isProductsLoadingAtom = Atom(
    name: '_StatisticsStoreBase.isProductsLoading',
    context: context,
  );

  @override
  bool get isProductsLoading {
    _$isProductsLoadingAtom.reportRead();
    return super.isProductsLoading;
  }

  @override
  set isProductsLoading(bool value) {
    _$isProductsLoadingAtom.reportWrite(value, super.isProductsLoading, () {
      super.isProductsLoading = value;
    });
  }

  late final _$productsErrorAtom = Atom(
    name: '_StatisticsStoreBase.productsError',
    context: context,
  );

  @override
  String? get productsError {
    _$productsErrorAtom.reportRead();
    return super.productsError;
  }

  @override
  set productsError(String? value) {
    _$productsErrorAtom.reportWrite(value, super.productsError, () {
      super.productsError = value;
    });
  }

  late final _$popularProductsAtom = Atom(
    name: '_StatisticsStoreBase.popularProducts',
    context: context,
  );

  @override
  ObservableList<PopularProductEntity> get popularProducts {
    _$popularProductsAtom.reportRead();
    return super.popularProducts;
  }

  @override
  set popularProducts(ObservableList<PopularProductEntity> value) {
    _$popularProductsAtom.reportWrite(value, super.popularProducts, () {
      super.popularProducts = value;
    });
  }

  late final _$isPopularLoadingAtom = Atom(
    name: '_StatisticsStoreBase.isPopularLoading',
    context: context,
  );

  @override
  bool get isPopularLoading {
    _$isPopularLoadingAtom.reportRead();
    return super.isPopularLoading;
  }

  @override
  set isPopularLoading(bool value) {
    _$isPopularLoadingAtom.reportWrite(value, super.isPopularLoading, () {
      super.isPopularLoading = value;
    });
  }

  late final _$popularErrorAtom = Atom(
    name: '_StatisticsStoreBase.popularError',
    context: context,
  );

  @override
  String? get popularError {
    _$popularErrorAtom.reportRead();
    return super.popularError;
  }

  @override
  set popularError(String? value) {
    _$popularErrorAtom.reportWrite(value, super.popularError, () {
      super.popularError = value;
    });
  }

  late final _$loadAllAsyncAction = AsyncAction(
    '_StatisticsStoreBase.loadAll',
    context: context,
  );

  @override
  Future<void> loadAll() {
    return _$loadAllAsyncAction.run(() => super.loadAll());
  }

  late final _$loadLoginTimesAsyncAction = AsyncAction(
    '_StatisticsStoreBase.loadLoginTimes',
    context: context,
  );

  @override
  Future<void> loadLoginTimes() {
    return _$loadLoginTimesAsyncAction.run(() => super.loadLoginTimes());
  }

  late final _$loadAllProductsAsyncAction = AsyncAction(
    '_StatisticsStoreBase.loadAllProducts',
    context: context,
  );

  @override
  Future<void> loadAllProducts() {
    return _$loadAllProductsAsyncAction.run(() => super.loadAllProducts());
  }

  late final _$loadPopularProductsAsyncAction = AsyncAction(
    '_StatisticsStoreBase.loadPopularProducts',
    context: context,
  );

  @override
  Future<void> loadPopularProducts() {
    return _$loadPopularProductsAsyncAction.run(
      () => super.loadPopularProducts(),
    );
  }

  @override
  String toString() {
    return '''
logins: ${logins},
isLoginsLoading: ${isLoginsLoading},
loginsError: ${loginsError},
allProducts: ${allProducts},
isProductsLoading: ${isProductsLoading},
productsError: ${productsError},
popularProducts: ${popularProducts},
isPopularLoading: ${isPopularLoading},
popularError: ${popularError},
streakDays: ${streakDays}
    ''';
  }
}
