// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_topics_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TipTopicsStore on _TipTopicsStoreBase, Store {
  Computed<List<TipTopic>>? _$activeTopicsComputed;

  @override
  List<TipTopic> get activeTopics =>
      (_$activeTopicsComputed ??= Computed<List<TipTopic>>(
        () => super.activeTopics,
        name: '_TipTopicsStoreBase.activeTopics',
      )).value;
  Computed<List<({bool enabled, TipTopic topic})>>?
  _$predefinedWithStateComputed;

  @override
  List<({bool enabled, TipTopic topic})> get predefinedWithState =>
      (_$predefinedWithStateComputed ??=
              Computed<List<({bool enabled, TipTopic topic})>>(
                () => super.predefinedWithState,
                name: '_TipTopicsStoreBase.predefinedWithState',
              ))
          .value;
  Computed<List<TipTopic>>? _$customTopicsComputed;

  @override
  List<TipTopic> get customTopics =>
      (_$customTopicsComputed ??= Computed<List<TipTopic>>(
        () => super.customTopics,
        name: '_TipTopicsStoreBase.customTopics',
      )).value;

  late final _$disabledPredefinedIdsAtom = Atom(
    name: '_TipTopicsStoreBase.disabledPredefinedIds',
    context: context,
  );

  @override
  ObservableSet<String> get disabledPredefinedIds {
    _$disabledPredefinedIdsAtom.reportRead();
    return super.disabledPredefinedIds;
  }

  @override
  set disabledPredefinedIds(ObservableSet<String> value) {
    _$disabledPredefinedIdsAtom.reportWrite(
      value,
      super.disabledPredefinedIds,
      () {
        super.disabledPredefinedIds = value;
      },
    );
  }

  late final _$customTextsAtom = Atom(
    name: '_TipTopicsStoreBase.customTexts',
    context: context,
  );

  @override
  ObservableList<String> get customTexts {
    _$customTextsAtom.reportRead();
    return super.customTexts;
  }

  @override
  set customTexts(ObservableList<String> value) {
    _$customTextsAtom.reportWrite(value, super.customTexts, () {
      super.customTexts = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_TipTopicsStoreBase.isLoading',
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

  late final _$loadAsyncAction = AsyncAction(
    '_TipTopicsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$togglePredefinedAsyncAction = AsyncAction(
    '_TipTopicsStoreBase.togglePredefined',
    context: context,
  );

  @override
  Future<void> togglePredefined(String id) {
    return _$togglePredefinedAsyncAction.run(() => super.togglePredefined(id));
  }

  late final _$addCustomAsyncAction = AsyncAction(
    '_TipTopicsStoreBase.addCustom',
    context: context,
  );

  @override
  Future<void> addCustom(String text) {
    return _$addCustomAsyncAction.run(() => super.addCustom(text));
  }

  late final _$removeCustomAsyncAction = AsyncAction(
    '_TipTopicsStoreBase.removeCustom',
    context: context,
  );

  @override
  Future<void> removeCustom(String text) {
    return _$removeCustomAsyncAction.run(() => super.removeCustom(text));
  }

  @override
  String toString() {
    return '''
disabledPredefinedIds: ${disabledPredefinedIds},
customTexts: ${customTexts},
isLoading: ${isLoading},
activeTopics: ${activeTopics},
predefinedWithState: ${predefinedWithState},
customTopics: ${customTopics}
    ''';
  }
}
