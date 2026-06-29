enum LocalDBNames {
  settings,
  user,
  cache,
  auth,
}

abstract class ILocalDB<T> {
  T? get({required String key, String? baseName});
  Future<void> set({required String key, required T value, String? baseName});
  Future<void> delete({required String key, String? baseName});
  Future<void> init();
  Future<void> clear();
  Future<void> closeDB();
  String? _box;
}