// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_details_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ItemDetailsStore on _ItemDetailsStoreBase, Store {
  late final _$itemAtom = Atom(
    name: '_ItemDetailsStoreBase.item',
    context: context,
  );

  @override
  ProductEntity? get item {
    _$itemAtom.reportRead();
    return super.item;
  }

  @override
  set item(ProductEntity? value) {
    _$itemAtom.reportWrite(value, super.item, () {
      super.item = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_ItemDetailsStoreBase.isLoading',
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
    name: '_ItemDetailsStoreBase.errorMessage',
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

  late final _$isDeletedAtom = Atom(
    name: '_ItemDetailsStoreBase.isDeleted',
    context: context,
  );

  @override
  bool get isDeleted {
    _$isDeletedAtom.reportRead();
    return super.isDeleted;
  }

  @override
  set isDeleted(bool value) {
    _$isDeletedAtom.reportWrite(value, super.isDeleted, () {
      super.isDeleted = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    '_ItemDetailsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$saveAsyncAction = AsyncAction(
    '_ItemDetailsStoreBase.save',
    context: context,
  );

  @override
  Future<bool> save({
    String? name,
    String? section,
    int? quantity,
    String? unit,
    int? priority,
    bool? urgent,
    int? remindEveryDays,
  }) {
    return _$saveAsyncAction.run(
      () => super.save(
        name: name,
        section: section,
        quantity: quantity,
        unit: unit,
        priority: priority,
        urgent: urgent,
        remindEveryDays: remindEveryDays,
      ),
    );
  }

  late final _$deleteAsyncAction = AsyncAction(
    '_ItemDetailsStoreBase.delete',
    context: context,
  );

  @override
  Future<bool> delete() {
    return _$deleteAsyncAction.run(() => super.delete());
  }

  late final _$toggleBoughtAsyncAction = AsyncAction(
    '_ItemDetailsStoreBase.toggleBought',
    context: context,
  );

  @override
  Future<bool> toggleBought() {
    return _$toggleBoughtAsyncAction.run(() => super.toggleBought());
  }

  @override
  String toString() {
    return '''
item: ${item},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isDeleted: ${isDeleted}
    ''';
  }
}
