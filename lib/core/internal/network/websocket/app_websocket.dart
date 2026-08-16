import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppWebsocket {
  AppWebsocket._();
  static final instance = AppWebsocket._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _shouldRun = false;

  final _events = StreamController<WsDataModel>.broadcast();
  Stream<WsDataModel> get events => _events.stream;

  Future<void> connect(Uri wsUrl) async {
    _shouldRun = true;
    final token = await GetIt.I<TokensSecureStore>().getAccessToken();
    if (token == null) return;
    Logger.talker.debug('token exists, starting connecting');

    // _channel = IOWebSocketChannel.connect(
    //   wsUrl,
    //   headers: {'Authorization': 'Bearer $token'},
    //   pingInterval: const Duration(seconds: 30),
    // );

    //   _subscription = _channel!.stream.listen(
    //     _onData,
    //     onError: (e) {
    //       Logger.talker.critical('Ws error: $e');
    //       _scheduleReconnect(wsUrl);
    //     },
    //     onDone: () {
    //       Logger.talker.info('ws closed');
    //       _scheduleReconnect(wsUrl);
    //     },
    //     cancelOnError: true
    //   );
  }

  Future<void> _onData(dynamic raw) async {
    try {
      final data = jsonDecode(raw);
      WsDataModel event = WsDataModel.fromJson(data);
      Logger.talker.debug('Ws data getted');

      _events.add(event);
    } catch (e) {
      Logger.talker.warning('ws bad frame');
    }
  }

  void _scheduleReconnect(Uri url) async {
    if (!_shouldRun) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () => connect(url));
  }

  Future<void> disconnect() async {
    Logger.talker.debug('Ws disconnect');

    _shouldRun = false;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close(WebSocketStatus.normalClosure);
    _channel = null;
    _subscription = null;
  }
}
