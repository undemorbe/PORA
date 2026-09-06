import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

class HiveLocalDB<T> implements ILocalDB<T> {
  final Map<LocalDBNames, Future<Box<dynamic>>> _boxes = {};
  bool _initialized = false;

  Future<Box<dynamic>> _open(LocalDBNames boxName) {
    return _boxes.putIfAbsent(
      boxName,
      () => Hive.isBoxOpen(boxName.name)
          ? Future.value(Hive.box<dynamic>(boxName.name))
          : Hive.openBox<dynamic>(boxName.name),
    );
  }

  @override
  Future<void> clear({required LocalDBNames boxName}) async {
    await (await _open(boxName)).clear();
  }

  @override
  Future<void> delete({
    required String key,
    required LocalDBNames boxName,
  }) async {
    final box = await _open(boxName);
    await box.delete(key);
  }

  @override
  Future<T?> get({required String key, required LocalDBNames boxName}) async {
    try {
      final value = (await _open(boxName)).get(key);
      return value is T ? value : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  @override
  Future<void> set({
    required String key,
    required T value,
    required LocalDBNames boxName,
  }) async {
    final box = await _open(boxName);
    await box.put(key, value);
  }

  @override
  Future<void> closeDB({required LocalDBNames boxName}) async {
    final pendingBox = _boxes.remove(boxName);
    if (pendingBox != null) {
      await (await pendingBox).close();
    } else if (Hive.isBoxOpen(boxName.name)) {
      await Hive.box<dynamic>(boxName.name).close();
    }
  }
}
