import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/logging/logger.dart';
part 'connectivity_store.g.dart';

/// Singleton — отслеживает статус интернета через connectivity_plus.
/// `online` — true если хоть один транспорт (wifi/mobile/ethernet) доступен.
class ConnectivityStore = _ConnectivityStoreBase with _$ConnectivityStore;

abstract class _ConnectivityStoreBase with Store {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @observable
  bool online = true;

  @action
  Future<void> init() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      _apply(initial);
      _sub ??= _connectivity.onConnectivityChanged.listen(
        _apply,
        onError: (Object e) =>
            Logger.talker.warning('connectivity stream error: $e'),
      );
    } on MissingPluginException catch (e) {
      // Native side ещё не подключён (свежий cold-build нужен).
      Logger.talker.warning('connectivity_plus plugin missing: $e');
      online = true; // fail-open — не блокируем UX баннером.
    } catch (e, s) {
      Logger.talker.error('connectivity init failed', e, s);
      online = true;
    }
  }

  @action
  void _apply(List<ConnectivityResult> results) {
    online = results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> recheck() async {
    try {
      _apply(await _connectivity.checkConnectivity());
    } on MissingPluginException {
      online = true;
    } catch (_) {
      /* keep last known */
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
