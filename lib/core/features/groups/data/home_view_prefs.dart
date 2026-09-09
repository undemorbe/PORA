import 'package:hive/hive.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

/// Настройка отображения главной (groups): list или grid.
/// Ключ kebab-case `home-view-grid` в [LocalDBNames.settings].
class HomeViewPrefs {
  const HomeViewPrefs(this._db);

  final ILocalDB<dynamic> _db;

  static const _gridKey = 'home-view-grid';

  Future<bool> isGrid() async {
    try {
      final v = await _db.get(key: _gridKey, boxName: LocalDBNames.settings);
      return v == true;
    } on HiveError {
      return false;
    }
  }

  Future<void> setGrid(bool value) =>
      _db.set(key: _gridKey, value: value, boxName: LocalDBNames.settings);
}
