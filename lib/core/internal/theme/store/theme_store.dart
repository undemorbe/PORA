import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';
part 'theme_store.g.dart';

class ThemeStore = _ThemeStoreBase with _$ThemeStore;

const _kThemeKey = 'theme-mode';

abstract class _ThemeStoreBase with Store {
  @observable
  ThemeMode themeMode = ThemeMode.system;

  @action
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _db()?.set(
      key: _kThemeKey,
      value: _encode(mode),
      boxName: LocalDBNames.settings,
    );
  }

  @action
  Future<void> initialiseTheme() async {
    final raw = await _db()?.get(
      key: _kThemeKey,
      boxName: LocalDBNames.settings,
    );
    themeMode = _decode(raw as String?);
  }

  ILocalDB<dynamic>? _db() {
    try {
      return GetIt.I.isRegistered<ILocalDB<dynamic>>()
          ? GetIt.I<ILocalDB<dynamic>>()
          : null;
    } catch (_) {
      return null;
    }
  }

  String _encode(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  ThemeMode _decode(String? v) => switch (v) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
