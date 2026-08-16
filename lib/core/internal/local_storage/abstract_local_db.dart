enum LocalDBNames { settings, user, cache, auth }

abstract class ILocalDB<T> {
  Future<T?> get({required String key, required LocalDBNames boxName});
  Future<void> set({
    required String key,
    required T value,
    required LocalDBNames boxName,
  });
  Future<void> delete({required String key, required LocalDBNames boxName});
  Future<void> init();
  Future<void> clear({required LocalDBNames boxName});
  Future<void> closeDB({required LocalDBNames boxName});
}
