import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/platform/shared_content_holder.dart';
import 'package:pora/core/internal/router/app_router.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Share-to-app (Android-эксклюзив по задаче; на iOS требует Share Extension —
class ShareIntentService {
  ShareIntentService._();
  static final ShareIntentService instance = ShareIntentService._();

  StreamSubscription<List<SharedMediaFile>>? _sub;

  /// Регулярка для вычленения первой http(s)-ссылки из текста.
  static final _urlRe = RegExp(r'https?://[^\s]+', caseSensitive: false);

  Future<void> init() async {
    // Только Android в рамках задачи (на iOS Share Extension не настроен).
    if (!Platform.isAndroid) return;
    try {
      // Шаринг при холодном старте.
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      _handle(initial);
      // Шаринг, пока приложение уже запущено.
      _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
        _handle,
        onError: (Object e) => Logger.talker.warning('share stream error: $e'),
      );
    } catch (e, s) {
      Logger.talker.warning('ShareIntentService init failed', e, s);
    }
  }

  void _handle(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    // Ищем URL в тексте/пути любого из шаринг-элементов.
    String? url;
    for (final f in files) {
      final match = _urlRe.firstMatch(f.path);
      if (match != null) {
        url = match.group(0);
        break;
      }
    }
    if (url == null) return;

    SharedContentHolder.instance.setRecipeUrl(url);
    // Требуется завершить текущие сообщения после обработки (иначе повторный
    // resume снова отдаст тот же intent на некоторых устройствах).
    ReceiveSharingIntent.instance.reset();

    // Ведём к спискам — там пользователь выберет, куда импортировать рецепт.
    try {
      GetIt.I<AppRouter>().navigate(const GroupsRoute());
    } catch (e, s) {
      Logger.talker.warning('share navigate failed', e, s);
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
