enum LocalDBNames {
  settings,
  user,
  cache,
}

abstract class LocalDBInterface<T> {
  T? get({required String key, String? baseName});
  Future<void> set({required String key, required T value, String? baseName});
  Future<void> delete({required String key, String? baseName});
  Future<void> init();
  Future<void> clear({String? concreteBoxName});
  Future<void> closeDB({String? concreteBoxName});
  List<String>? _boxes;
}