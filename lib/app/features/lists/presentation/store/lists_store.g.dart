// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ListStore on _ListStoreBase, Store {
  Computed<int>? _$productsAmountComputed;

  @override
  int get productsAmount => (_$productsAmountComputed ??= Computed<int>(
    () => super.productsAmount,
    name: '_ListStoreBase.productsAmount',
  )).value;

  late final _$listAtom = Atom(name: '_ListStoreBase.list', context: context);

  @override
  ListEntity? get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ListEntity? value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_ListStoreBase.isLoading',
    context: context,
  );

  @override
  bool? get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool? value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isSuccessAtom = Atom(
    name: '_ListStoreBase.isSuccess',
    context: context,
  );

  @override
  bool? get isSuccess {
    _$isSuccessAtom.reportRead();
    return super.isSuccess;
  }

  @override
  set isSuccess(bool? value) {
    _$isSuccessAtom.reportWrite(value, super.isSuccess, () {
      super.isSuccess = value;
    });
  }

  late final _$listsWithPreviewAtom = Atom(
    name: '_ListStoreBase.listsWithPreview',
    context: context,
  );

  @override
  ListsArrayEntity? get listsWithPreview {
    _$listsWithPreviewAtom.reportRead();
    return super.listsWithPreview;
  }

  @override
  set listsWithPreview(ListsArrayEntity? value) {
    _$listsWithPreviewAtom.reportWrite(value, super.listsWithPreview, () {
      super.listsWithPreview = value;
    });
  }

  late final _$getConcreteListAsyncAction = AsyncAction(
    '_ListStoreBase.getConcreteList',
    context: context,
  );

  @override
  Future<void> getConcreteList({required String lid}) {
    return _$getConcreteListAsyncAction.run(
      () => super.getConcreteList(lid: lid),
    );
  }

  late final _$getFamilyListsAsyncAction = AsyncAction(
    '_ListStoreBase.getFamilyLists',
    context: context,
  );

  @override
  Future<void> getFamilyLists({required String fid}) {
    return _$getFamilyListsAsyncAction.run(
      () => super.getFamilyLists(fid: fid),
    );
  }

  late final _$deleteListAsyncAction = AsyncAction(
    '_ListStoreBase.deleteList',
    context: context,
  );

  @override
  Future<void> deleteList({required String lid}) {
    return _$deleteListAsyncAction.run(() => super.deleteList(lid: lid));
  }

  late final _$createListAsyncAction = AsyncAction(
    '_ListStoreBase.createList',
    context: context,
  );

  @override
  Future<void> createList({required String name, String? fid}) {
    return _$createListAsyncAction.run(
      () => super.createList(name: name, fid: fid),
    );
  }

  @override
  String toString() {
    return '''
list: ${list},
isLoading: ${isLoading},
isSuccess: ${isSuccess},
listsWithPreview: ${listsWithPreview},
productsAmount: ${productsAmount}
    ''';
  }
}
