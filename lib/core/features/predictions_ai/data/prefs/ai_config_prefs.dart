import 'package:hive/hive.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

class AiConfigPrefs {
  const AiConfigPrefs({required this.db});

  final ILocalDB<dynamic> db;

  static const _apiKeyKey = 'ai-api-key';
  static const _poraModelKey = 'ai-pora-model';
  static const _tipsModelKey = 'ai-tips-model';

  Future<String?> apiKey() => _read(_apiKeyKey);
  Future<String?> poraModel() => _read(_poraModelKey);
  Future<String?> tipsModel() => _read(_tipsModelKey);

  Future<void> save({
    required String apiKey,
    required String poraModel,
    required String tipsModel,
  }) async {
    await _write(_apiKeyKey, apiKey);
    await _write(_poraModelKey, poraModel);
    await _write(_tipsModelKey, tipsModel);
  }

  /// Полный сброс на дефолты из .env.
  Future<void> reset() async {
    await db.delete(key: _apiKeyKey, boxName: LocalDBNames.settings);
    await db.delete(key: _poraModelKey, boxName: LocalDBNames.settings);
    await db.delete(key: _tipsModelKey, boxName: LocalDBNames.settings);
  }

  Future<String?> _read(String key) async {
    try {
      final v = await db.get(key: key, boxName: LocalDBNames.settings);
      if (v is String && v.trim().isNotEmpty) return v.trim();
      return null;
    } on HiveError {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await db.delete(key: key, boxName: LocalDBNames.settings);
    } else {
      await db.set(key: key, value: trimmed, boxName: LocalDBNames.settings);
    }
  }
}
