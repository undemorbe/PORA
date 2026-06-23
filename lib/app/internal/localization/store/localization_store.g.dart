// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LocalizationStore on _LocalizationStoreBase, Store {
  late final _$currentLocaleAtom = Atom(
    name: '_LocalizationStoreBase.currentLocale',
    context: context,
  );

  @override
  String get currentLocale {
    _$currentLocaleAtom.reportRead();
    return super.currentLocale;
  }

  @override
  set currentLocale(String value) {
    _$currentLocaleAtom.reportWrite(value, super.currentLocale, () {
      super.currentLocale = value;
    });
  }

  late final _$_LocalizationStoreBaseActionController = ActionController(
    name: '_LocalizationStoreBase',
    context: context,
  );

  @override
  void setCurrentLocale({required String newLocale}) {
    final _$actionInfo = _$_LocalizationStoreBaseActionController.startAction(
      name: '_LocalizationStoreBase.setCurrentLocale',
    );
    try {
      return super.setCurrentLocale(newLocale: newLocale);
    } finally {
      _$_LocalizationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initialise({LocalDBInterface<dynamic>? localDB}) {
    final _$actionInfo = _$_LocalizationStoreBaseActionController.startAction(
      name: '_LocalizationStoreBase.initialise',
    );
    try {
      return super.initialise(localDB: localDB);
    } finally {
      _$_LocalizationStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentLocale: ${currentLocale}
    ''';
  }
}
