import 'dart:async';

import 'package:flutter/widgets.dart' show Locale;
import 'package:pora/core/internal/cache/cache_keys.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/offline/outbox_replayer.dart';
import 'package:pora/core/internal/widgets/app_messenger.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';

/// Глобальные побочные эффекты flush: для отброшенных записей
/// инвалидирует оптимистичный кэш товара и показывает snackbar.
/// Перезагрузку открытых экранов делают сами экраны (подписка на
/// [OutboxReplayer.events]).
class OutboxSyncEffects {
  OutboxSyncEffects({required this.replayer, required this.localeCode});

  final OutboxReplayer replayer;

  /// Код текущей локали. BuildContext здесь нет, поэтому строки берём
  /// через lookup по сохранённому коду; неподдерживаемые коды → `en`.
  final String Function() localeCode;

  StreamSubscription<FlushOutcome>? _sub;

  void start() {
    _sub ??= replayer.events.listen((o) => unawaited(handle(o)));
  }

  /// Никогда не бросает: вызывается через `unawaited`, ошибка ушла бы
  /// в zone как необработанная.
  Future<void> handle(FlushOutcome outcome) async {
    try {
      if (outcome.dropped.isEmpty) return;
      for (final entry in outcome.dropped) {
        final itemId = entry.args['item-id'];
        if (itemId is String) {
          await HiveJsonCache.invalidate(CacheKeys.item(itemId));
        }
      }
      final l = _localizations();
      appMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          PoraSnackbar.build(
            message: l.offlineSyncDropped(outcome.dropped.length),
            type: PoraSnackType.failure,
          ),
        );
    } catch (e, s) {
      Logger.talker.error('OutboxSyncEffects failed', e, s);
    }
  }

  /// `lookupAppLocalizations` бросает FlutterError на неподдерживаемой
  /// локали (`es`, `zh-Hans` и т.п.) — берём языковой код и откатываемся
  /// на `en`.
  AppLocalizations _localizations() {
    final code = localeCode().split(RegExp('[-_]')).first;
    final locale = Locale(code);
    return lookupAppLocalizations(
      AppLocalizations.delegate.isSupported(locale) ? locale : _fallback,
    );
  }

  static const _fallback = Locale('en');

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
