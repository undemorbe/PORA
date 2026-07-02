import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
part 'theme_store.g.dart';

class ThemeStore = _ThemeStoreBase with _$ThemeStore;

abstract class _ThemeStoreBase with Store {
  @observable
  ThemeMode themeMode = ThemeMode.system;

  @action
  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
  }

  @action
  void initialiseTheme() {
    // TODO: Load theme from storage or use system default
    // For now, we'll just use the system default
  }
}
