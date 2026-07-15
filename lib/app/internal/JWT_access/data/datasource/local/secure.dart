import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokensSecureStore {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Сохраняем токены
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Получаем access токен
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Получаем refresh токен
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Синхронный метод для interceptor (кэшируем токен в памяти)
  String? _cachedAccessToken;
  DateTime? _tokenExpiry;

  String? get accessTokenSync {
    // Если токен истек, возвращаем null (будет вызвано обновление)
    if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
      return null;
    }
    return _cachedAccessToken;
  }

  void updateCache(String? token, {DateTime? expiry}) {
    _cachedAccessToken = token;
    _tokenExpiry = expiry;
  }

  // Очищаем токены (выход из системы)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    _cachedAccessToken = null;
    _tokenExpiry = null;
  }
}
