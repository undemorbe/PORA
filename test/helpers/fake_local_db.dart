import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

/// In-memory реализация [ILocalDB] для тестов (по бокс+ключ).
class FakeLocalDB implements ILocalDB<dynamic> {
  final Map<String, dynamic> _store = {};

  String _k(String key, LocalDBNames box) => '${box.name}::$key';

  @override
  Future<dynamic> get({required String key, required LocalDBNames boxName}) async =>
      _store[_k(key, boxName)];

  @override
  Future<void> set({
    required String key,
    required dynamic value,
    required LocalDBNames boxName,
  }) async {
    _store[_k(key, boxName)] = value;
  }

  @override
  Future<void> delete({
    required String key,
    required LocalDBNames boxName,
  }) async {
    _store.remove(_k(key, boxName));
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> clear({required LocalDBNames boxName}) async {
    _store.removeWhere((k, _) => k.startsWith('${boxName.name}::'));
  }

  @override
  Future<void> closeDB({required LocalDBNames boxName}) async {}
}
