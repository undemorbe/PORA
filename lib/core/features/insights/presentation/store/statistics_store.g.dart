// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StatisticsStore on _StatisticsStoreBase, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading => (_$isLoadingComputed ??= Computed<bool>(
    () => super.isLoading,
    name: '_StatisticsStoreBase.isLoading',
  )).value;
  Computed<UsageSummary>? _$usageComputed;

  @override
  UsageSummary get usage => (_$usageComputed ??= Computed<UsageSummary>(
    () => super.usage,
    name: '_StatisticsStoreBase.usage',
  )).value;
  Computed<List<PopularProductEntity>>? _$dueSoonComputed;

  @override
  List<PopularProductEntity> get dueSoon =>
      (_$dueSoonComputed ??= Computed<List<PopularProductEntity>>(
        () => super.dueSoon,
        name: '_StatisticsStoreBase.dueSoon',
      )).value;
  Computed<List<CountEntry>>? _$categoriesComputed;

  @override
  List<CountEntry> get categories =>
      (_$categoriesComputed ??= Computed<List<CountEntry>>(
        () => super.categories,
        name: '_StatisticsStoreBase.categories',
      )).value;
  Computed<int>? _$uniqueProductsComputed;

  @override
  int get uniqueProducts => (_$uniqueProductsComputed ??= Computed<int>(
    () => super.uniqueProducts,
    name: '_StatisticsStoreBase.uniqueProducts',
  )).value;
  Computed<int>? _$remindersCountComputed;

  @override
  int get remindersCount => (_$remindersCountComputed ??= Computed<int>(
    () => super.remindersCount,
    name: '_StatisticsStoreBase.remindersCount',
  )).value;
  Computed<int>? _$urgentCountComputed;

  @override
  int get urgentCount => (_$urgentCountComputed ??= Computed<int>(
    () => super.urgentCount,
    name: '_StatisticsStoreBase.urgentCount',
  )).value;
  Computed<CountEntry?>? _$championComputed;

  @override
  CountEntry? get champion => (_$championComputed ??= Computed<CountEntry?>(
    () => super.champion,
    name: '_StatisticsStoreBase.champion',
  )).value;

  late final _$periodAtom = Atom(
    name: '_StatisticsStoreBase.period',
    context: context,
  );

  @override
  int get period {
    _$periodAtom.reportRead();
    return super.period;
  }

  @override
  set period(int value) {
    _$periodAtom.reportWrite(value, super.period, () {
      super.period = value;
    });
  }

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

  late final _$_hydrateFromCacheAsyncAction = AsyncAction(
    '_StatisticsStoreBase._hydrateFromCache',
    context: context,
  );

  @override
  Future<void> _hydrateFromCache() {
    return _$_hydrateFromCacheAsyncAction.run(() => super._hydrateFromCache());
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

  late final _$_StatisticsStoreBaseActionController = ActionController(
    name: '_StatisticsStoreBase',
    context: context,
  );

  @override
  void setPeriod(int days) {
    final _$actionInfo = _$_StatisticsStoreBaseActionController.startAction(
      name: '_StatisticsStoreBase.setPeriod',
    );
    try {
      return super.setPeriod(days);
    } finally {
      _$_StatisticsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
period: ${period},
logins: ${logins},
isLoginsLoading: ${isLoginsLoading},
loginsError: ${loginsError},
allProducts: ${allProducts},
isProductsLoading: ${isProductsLoading},
productsError: ${productsError},
popularProducts: ${popularProducts},
isPopularLoading: ${isPopularLoading},
popularError: ${popularError},
isLoading: ${isLoading},
usage: ${usage},
dueSoon: ${dueSoon},
categories: ${categories},
uniqueProducts: ${uniqueProducts},
remindersCount: ${remindersCount},
urgentCount: ${urgentCount},
champion: ${champion}
    ''';
  }
}
