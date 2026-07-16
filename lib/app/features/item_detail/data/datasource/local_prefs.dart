import 'package:hive/hive.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';

/// Локальные настройки для item_details:
///   `skip-delete-confirm` — user выключил подтверждение удаления.
class ItemDetailsPrefs {
  final ILocalDB<dynamic> db;
  const ItemDetailsPrefs({required this.db});

  static const _skipDeleteKey = 'skip-delete-confirm';

  Future<bool> shouldSkipDeleteConfirm() async {
    try {
      final v = await db.get(
        key: _skipDeleteKey,
        boxName: LocalDBNames.settings,
      );
      return v == true;
    } on HiveError {
      return false;
    }
  }

  Future<void> setSkipDeleteConfirm(bool value) async {
    await db.set(
      key: _skipDeleteKey,
      value: value,
      boxName: LocalDBNames.settings,
    );
  }
}
