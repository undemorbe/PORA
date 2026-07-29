// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'families_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FamiliesStore on _FamiliesStoreBase, Store {
  late final _$familiesAtom = Atom(
    name: '_FamiliesStoreBase.families',
    context: context,
  );

  @override
  ObservableList<FamilyEntity> get families {
    _$familiesAtom.reportRead();
    return super.families;
  }

  @override
  set families(ObservableList<FamilyEntity> value) {
    _$familiesAtom.reportWrite(value, super.families, () {
      super.families = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_FamiliesStoreBase.isLoading',
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

  late final _$successAtom = Atom(
    name: '_FamiliesStoreBase.success',
    context: context,
  );

  @override
  bool? get success {
    _$successAtom.reportRead();
    return super.success;
  }

  @override
  set success(bool? value) {
    _$successAtom.reportWrite(value, super.success, () {
      super.success = value;
    });
  }

  late final _$getFamiliesAsyncAction = AsyncAction(
    '_FamiliesStoreBase.getFamilies',
    context: context,
  );

  @override
  Future<void> getFamilies() {
    return _$getFamiliesAsyncAction.run(() => super.getFamilies());
  }

  late final _$deleteFamilyAsyncAction = AsyncAction(
    '_FamiliesStoreBase.deleteFamily',
    context: context,
  );

  @override
  Future<void> deleteFamily({required String fid}) {
    return _$deleteFamilyAsyncAction.run(() => super.deleteFamily(fid: fid));
  }

  late final _$createFamilyAsyncAction = AsyncAction(
    '_FamiliesStoreBase.createFamily',
    context: context,
  );

  @override
  Future<void> createFamily({required String name}) {
    return _$createFamilyAsyncAction.run(() => super.createFamily(name: name));
  }

  @override
  String toString() {
    return '''
families: ${families},
isLoading: ${isLoading},
success: ${success}
    ''';
  }
}
