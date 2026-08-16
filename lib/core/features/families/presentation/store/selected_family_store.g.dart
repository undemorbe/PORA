// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_family_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SelectedFamilyStore on _SelectedFamilyStoreBase, Store {
  late final _$currentAtom = Atom(
    name: '_SelectedFamilyStoreBase.current',
    context: context,
  );

  @override
  FamilyEntity? get current {
    _$currentAtom.reportRead();
    return super.current;
  }

  @override
  set current(FamilyEntity? value) {
    _$currentAtom.reportWrite(value, super.current, () {
      super.current = value;
    });
  }

  late final _$_SelectedFamilyStoreBaseActionController = ActionController(
    name: '_SelectedFamilyStoreBase',
    context: context,
  );

  @override
  void select(FamilyEntity? family) {
    final _$actionInfo = _$_SelectedFamilyStoreBaseActionController.startAction(
      name: '_SelectedFamilyStoreBase.select',
    );
    try {
      return super.select(family);
    } finally {
      _$_SelectedFamilyStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
current: ${current}
    ''';
  }
}
