// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ThemeStore on _ThemeStoreBase, Store {
  late final _$themeModeAtom = Atom(
    name: '_ThemeStoreBase.themeMode',
    context: context,
  );

  @override
  ThemeMode get themeMode {
    _$themeModeAtom.reportRead();
    return super.themeMode;
  }

  @override
  set themeMode(ThemeMode value) {
    _$themeModeAtom.reportWrite(value, super.themeMode, () {
      super.themeMode = value;
    });
  }

  late final _$setThemeModeAsyncAction = AsyncAction(
    '_ThemeStoreBase.setThemeMode',
    context: context,
  );

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return _$setThemeModeAsyncAction.run(() => super.setThemeMode(mode));
  }

  late final _$initialiseThemeAsyncAction = AsyncAction(
    '_ThemeStoreBase.initialiseTheme',
    context: context,
  );

  @override
  Future<void> initialiseTheme() {
    return _$initialiseThemeAsyncAction.run(() => super.initialiseTheme());
  }

  @override
  String toString() {
    return '''
themeMode: ${themeMode}
    ''';
  }
}
