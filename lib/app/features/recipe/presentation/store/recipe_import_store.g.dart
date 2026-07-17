// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_import_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RecipeImportStore on _RecipeImportStoreBase, Store {
  Computed<int>? _$selectedCountComputed;

  @override
  int get selectedCount => (_$selectedCountComputed ??= Computed<int>(
    () => super.selectedCount,
    name: '_RecipeImportStoreBase.selectedCount',
  )).value;

  late final _$urlAtom = Atom(
    name: '_RecipeImportStoreBase.url',
    context: context,
  );

  @override
  String get url {
    _$urlAtom.reportRead();
    return super.url;
  }

  @override
  set url(String value) {
    _$urlAtom.reportWrite(value, super.url, () {
      super.url = value;
    });
  }

  late final _$recipeAtom = Atom(
    name: '_RecipeImportStoreBase.recipe',
    context: context,
  );

  @override
  RecipeEntity? get recipe {
    _$recipeAtom.reportRead();
    return super.recipe;
  }

  @override
  set recipe(RecipeEntity? value) {
    _$recipeAtom.reportWrite(value, super.recipe, () {
      super.recipe = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_RecipeImportStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_RecipeImportStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$rowsAtom = Atom(
    name: '_RecipeImportStoreBase.rows',
    context: context,
  );

  @override
  ObservableList<RecipeRow> get rows {
    _$rowsAtom.reportRead();
    return super.rows;
  }

  @override
  set rows(ObservableList<RecipeRow> value) {
    _$rowsAtom.reportWrite(value, super.rows, () {
      super.rows = value;
    });
  }

  late final _$selectedAtom = Atom(
    name: '_RecipeImportStoreBase.selected',
    context: context,
  );

  @override
  ObservableSet<int> get selected {
    _$selectedAtom.reportRead();
    return super.selected;
  }

  @override
  set selected(ObservableSet<int> value) {
    _$selectedAtom.reportWrite(value, super.selected, () {
      super.selected = value;
    });
  }

  late final _$loadExistingAsyncAction = AsyncAction(
    '_RecipeImportStoreBase.loadExisting',
    context: context,
  );

  @override
  Future<void> loadExisting() {
    return _$loadExistingAsyncAction.run(() => super.loadExisting());
  }

  late final _$parseAsyncAction = AsyncAction(
    '_RecipeImportStoreBase.parse',
    context: context,
  );

  @override
  Future<void> parse() {
    return _$parseAsyncAction.run(() => super.parse());
  }

  late final _$addSelectedAsyncAction = AsyncAction(
    '_RecipeImportStoreBase.addSelected',
    context: context,
  );

  @override
  Future<List<String>> addSelected() {
    return _$addSelectedAsyncAction.run(() => super.addSelected());
  }

  late final _$_RecipeImportStoreBaseActionController = ActionController(
    name: '_RecipeImportStoreBase',
    context: context,
  );

  @override
  void setUrl(String value) {
    final _$actionInfo = _$_RecipeImportStoreBaseActionController.startAction(
      name: '_RecipeImportStoreBase.setUrl',
    );
    try {
      return super.setUrl(value);
    } finally {
      _$_RecipeImportStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggle(int index) {
    final _$actionInfo = _$_RecipeImportStoreBaseActionController.startAction(
      name: '_RecipeImportStoreBase.toggle',
    );
    try {
      return super.toggle(index);
    } finally {
      _$_RecipeImportStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_RecipeImportStoreBaseActionController.startAction(
      name: '_RecipeImportStoreBase.reset',
    );
    try {
      return super.reset();
    } finally {
      _$_RecipeImportStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
url: ${url},
recipe: ${recipe},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
rows: ${rows},
selected: ${selected},
selectedCount: ${selectedCount}
    ''';
  }
}
