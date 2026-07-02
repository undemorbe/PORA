import 'package:mobx/mobx.dart';
import 'dart:io';

import 'package:pora/app/internal/local_storage/abstract_local_db.dart';
part 'localization_store.g.dart';

class LocalizationStore = _LocalizationStoreBase with _$LocalizationStore;

abstract class _LocalizationStoreBase with Store {
  @observable
  String currentLocale = 'en';

  @action
  void setCurrentLocale({required String newLocale}) {
    currentLocale = newLocale;
  }

  @action
  Future<void> initialise({ILocalDB? localDB}) async {
    var locale =
        await localDB?.get(key: 'key', boxName: LocalDBNames.settings) ??
        Platform.localeName;
    setCurrentLocale(newLocale: locale);
  }
}
