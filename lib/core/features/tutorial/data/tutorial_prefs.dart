import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

/// Флаг «пользователь видел туториал». Хранится в общем settings-боксе.
class TutorialPrefs {
  TutorialPrefs(this._db);

  final ILocalDB _db;
  static const _seenKey = 'tutorial-seen';

  Future<bool> hasSeen() async {
    final v = await _db.get(key: _seenKey, boxName: LocalDBNames.settings);
    assert(v is bool);
    return v == true;
  }

  Future<void> markSeen() =>
      _db.set(key: _seenKey, value: true, boxName: LocalDBNames.settings);

  Future<void> reset() =>
      _db.delete(key: _seenKey, boxName: LocalDBNames.settings);
}
