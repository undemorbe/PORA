import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

/// Хранит состояние тем в `LocalDBNames.settings`:
///   - `tip-topics-disabled` — `List<String>` ID predefined-тем которые юзер выключил
///   - `tip-topics-custom`   — `List<String>` raw-text custom тем
///
/// UI поверх этого сам вычисляет активный набор.
class TipTopicsPrefs {
  TipTopicsPrefs(this._db);

  final ILocalDB _db;

  static const _disabledKey = 'tip-topics-disabled';
  static const _customKey = 'tip-topics-custom';

  Future<List<String>> disabledPredefined() async {
    final raw = await _db.get(
      key: _disabledKey,
      boxName: LocalDBNames.settings,
    );
    return _asStringList(raw);
  }

  Future<List<String>> customTexts() async {
    final raw =
        await _db.get(key: _customKey, boxName: LocalDBNames.settings);
    return _asStringList(raw);
  }

  Future<void> setDisabledPredefined(List<String> ids) =>
      _db.set(
        key: _disabledKey,
        value: ids,
        boxName: LocalDBNames.settings,
      );

  Future<void> setCustomTexts(List<String> texts) =>
      _db.set(key: _customKey, value: texts, boxName: LocalDBNames.settings);

  Future<void> togglePredefined(String id) async {
    final current = await disabledPredefined();
    if (current.contains(id)) {
      await setDisabledPredefined(current.where((e) => e != id).toList());
    } else {
      await setDisabledPredefined([...current, id]);
    }
  }

  Future<void> addCustom(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final current = await customTexts();
    if (current.contains(trimmed)) return;
    await setCustomTexts([...current, trimmed]);
  }

  Future<void> removeCustom(String text) async {
    final current = await customTexts();
    await setCustomTexts(current.where((e) => e != text).toList());
  }

  List<String> _asStringList(dynamic raw) {
    if (raw is List) return raw.whereType<String>().toList();
    return const [];
  }
}
