import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobx/mobx.dart';
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
    final initial = await _connectivity.checkConnectivity();
    _apply(initial);
    _sub ??= _connectivity.onConnectivityChanged.listen(_apply);
  }

  @action
  void _apply(List<ConnectivityResult> results) {
    online = results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> recheck() async {
    _apply(await _connectivity.checkConnectivity());
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
