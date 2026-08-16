// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AiChatStore on _AiChatStoreBase, Store {
  Computed<bool>? _$isEmptyComputed;

  @override
  bool get isEmpty => (_$isEmptyComputed ??= Computed<bool>(
    () => super.isEmpty,
    name: '_AiChatStoreBase.isEmpty',
  )).value;

  late final _$historyAtom = Atom(
    name: '_AiChatStoreBase.history',
    context: context,
  );

  @override
  ObservableList<AiMessage> get history {
    _$historyAtom.reportRead();
    return super.history;
  }

  @override
  set history(ObservableList<AiMessage> value) {
    _$historyAtom.reportWrite(value, super.history, () {
      super.history = value;
    });
  }

  late final _$isBusyAtom = Atom(
    name: '_AiChatStoreBase.isBusy',
    context: context,
  );

  @override
  bool get isBusy {
    _$isBusyAtom.reportRead();
    return super.isBusy;
  }

  @override
  set isBusy(bool value) {
    _$isBusyAtom.reportWrite(value, super.isBusy, () {
      super.isBusy = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_AiChatStoreBase.errorMessage',
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

  late final _$sendAsyncAction = AsyncAction(
    '_AiChatStoreBase.send',
    context: context,
  );

  @override
  Future<void> send({required String text, required String languageCode}) {
    return _$sendAsyncAction.run(
      () => super.send(text: text, languageCode: languageCode),
    );
  }

  late final _$_AiChatStoreBaseActionController = ActionController(
    name: '_AiChatStoreBase',
    context: context,
  );

  @override
  void reset() {
    final _$actionInfo = _$_AiChatStoreBaseActionController.startAction(
      name: '_AiChatStoreBase.reset',
    );
    try {
      return super.reset();
    } finally {
      _$_AiChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
history: ${history},
isBusy: ${isBusy},
errorMessage: ${errorMessage},
isEmpty: ${isEmpty}
    ''';
  }
}
