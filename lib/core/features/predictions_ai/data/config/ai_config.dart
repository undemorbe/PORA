import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pora/core/features/predictions_ai/data/prefs/ai_config_prefs.dart';

/// Единый источник правды по конфигурации Pora-AI.
class AiConfig {
  AiConfig(this._prefs);

  final AiConfigPrefs _prefs;

  String _userKey = '';
  String _userPora = '';
  String _userTips = '';

  /// Перечитывает пользовательские значения из prefs в снапшот.
  Future<void> reload() async {
    _userKey = (await _prefs.apiKey()) ?? '';
    _userPora = (await _prefs.poraModel()) ?? '';
    _userTips = (await _prefs.tipsModel()) ?? '';
  }

  bool get hasCustomKey => _userKey.trim().isNotEmpty;

  /// Использует ли приложение хоть одно пользовательское переопределение.
  bool get isCustom =>
      hasCustomKey &&
      (_userPora.trim().isNotEmpty || _userTips.trim().isNotEmpty);

  String get apiKey => hasCustomKey ? _userKey.trim() : _envKey;

  String get poraModel {
    if (hasCustomKey && _userPora.trim().isNotEmpty) return _userPora.trim();
    return _envChatModel;
  }

  String get tipsModel {
    if (hasCustomKey && _userTips.trim().isNotEmpty) return _userTips.trim();
    return _envTipModel;
  }

  //! --- .env defaults ---
  String get _envKey => dotenv.maybeGet('AI_API_KEY')?.trim() ?? '';
  String get _envChatModel =>
      (dotenv.maybeGet('AI_CHAT_MODEL')?.trim().isNotEmpty ?? false)
      ? dotenv.get('AI_CHAT_MODEL').trim()
      : (dotenv.maybeGet('AI_MODEL')?.trim() ?? '');
  String get _envTipModel =>
      (dotenv.maybeGet('AI_TIP_MODEL')?.trim().isNotEmpty ?? false)
      ? dotenv.get('AI_TIP_MODEL').trim()
      : (dotenv.maybeGet('AI_MODEL')?.trim() ?? '');
}
