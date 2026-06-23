import 'package:hive/hive.dart';
import 'package:pora/app/internal/local_storage/abstract_local_db.dart';

class HiveLocalDB<T> implements LocalDBInterface<T> {
  
  @override
  List<String>? _boxes = ['settings','user','cache'];

  @override
  Future<void> clear({String? concreteBoxName}) async {
    if (concreteBoxName != null) {
      await Hive.deleteBoxFromDisk(concreteBoxName);
      return;
    }

    if (_boxes != null) {
      for (var key in _boxes!) {
        await Hive.deleteBoxFromDisk(key);
      }
    }
  }

  @override
  Future<void> delete({required String key, String? baseName}) async {
    final box = await Hive.openBox<T>(baseName ?? key);
    await box.delete(key);
    await box.close();
  }

  @override
  T? get({required String key, String? baseName}) {
    final box = Hive.box(baseName ?? '');
    return box.get(key);
  }

  @override
  Future<void> init() async {
    // Инициализация Hive
    // await Hive.initFlutter();
  }

  @override
  Future<void> set({required String key, required T value, String? baseName}) async {
    final box = await Hive.openBox<T>(baseName ?? key);
    await box.put(key, value);
  }
  
  @override
  Future<void> closeDB({String? concreteBoxName}) async {
    if (concreteBoxName != null) {
      await Hive.box<T>(concreteBoxName).close();
      return;
    }
    
    if (_boxes != null) {
      for (var key in _boxes!) {
        await Hive.box<T>(key).close();
      }
    }
  }
}