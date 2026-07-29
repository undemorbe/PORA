import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';
part 'localization_store.g.dart';

class LocalizationStore = _LocalizationStoreBase with _$LocalizationStore;

const _kLocaleKey = 'locale';

abstract class _LocalizationStoreBase with Store {
  @observable
  String currentLocale = 'en';

  @action
  Future<void> setCurrentLocale({required String newLocale}) async {
    currentLocale = _normalize(newLocale);
    await _db()?.set(
      key: _kLocaleKey,
      value: currentLocale,
      boxName: LocalDBNames.settings,
    );
  }

  @action
  Future<void> initialise({ILocalDB? localDB}) async {
    final saved = await (localDB ?? _db())?.get(
      key: _kLocaleKey,
      boxName: LocalDBNames.settings,
    );
    final raw = (saved as String?) ?? Platform.localeName;
    currentLocale = _normalize(raw);
  }

  /// `ru_RU`/`ru_RU.UTF-8` → `ru`.
  String _normalize(String raw) => raw.split(RegExp('[_.]')).first;

  ILocalDB<dynamic>? _db() {
    try {
      return GetIt.I.isRegistered<ILocalDB<dynamic>>()
          ? GetIt.I<ILocalDB<dynamic>>()
          : null;
    } catch (_) {
      return null;
    }
  }
}
