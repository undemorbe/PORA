import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';

class HiveLocalDB<T> implements ILocalDB<T> {
  @override
  Future<void> clear({required LocalDBNames boxName}) async {
    await Hive.deleteBoxFromDisk(boxName.name);
  }

  @override
  Future<void> delete({
    required String key,
    required LocalDBNames boxName,
  }) async {
    final box = await Hive.openBox<T>(boxName.name);
    await box.delete(key);
    await box.close();
  }

  @override
  Future<T?> get({required String key, required LocalDBNames boxName}) async {
    final box = await Hive.openBox<T>(boxName.name);
    final value = box.get(key);
    await box.close();
    return value;
  }

  @override
  Future<void> init() async {
    // Инициализация Hive
    await Hive.initFlutter();
  }

  @override
  Future<void> set({
    required String key,
    required T value,
    required LocalDBNames boxName,
  }) async {
    final box = await Hive.openBox<T>(boxName.name);
    await box.put(key, value);
    await box.close();
  }

  @override
  Future<void> closeDB({required LocalDBNames boxName}) async {
    await Hive.box<T>(boxName.name).close();
  }
}
