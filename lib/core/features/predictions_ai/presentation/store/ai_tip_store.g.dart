// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tip_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AiTipStore on _AiTipStoreBase, Store {
  late final _$tipAtom = Atom(name: '_AiTipStoreBase.tip', context: context);

  @override
  String? get tip {
    _$tipAtom.reportRead();
    return super.tip;
  }

  @override
  set tip(String? value) {
    _$tipAtom.reportWrite(value, super.tip, () {
      super.tip = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_AiTipStoreBase.isLoading',
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

  late final _$fromFallbackAtom = Atom(
    name: '_AiTipStoreBase.fromFallback',
    context: context,
  );

  @override
  bool get fromFallback {
    _$fromFallbackAtom.reportRead();
    return super.fromFallback;
  }

  @override
  set fromFallback(bool value) {
    _$fromFallbackAtom.reportWrite(value, super.fromFallback, () {
      super.fromFallback = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    '_AiTipStoreBase.load',
    context: context,
  );

  @override
  Future<void> load({
    required String topic,
    required String languageCode,
    required List<String> fallbackList,
  }) {
    return _$loadAsyncAction.run(
      () => super.load(
        topic: topic,
        languageCode: languageCode,
        fallbackList: fallbackList,
      ),
    );
  }

  @override
  String toString() {
    return '''
tip: ${tip},
isLoading: ${isLoading},
fromFallback: ${fromFallback}
    ''';
  }
}
