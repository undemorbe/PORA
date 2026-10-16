import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppWebsocket {
  AppWebsocket._();
  static final instance = AppWebsocket._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _shouldRun = false;
  int retryAttempts = 0;

  final _events = StreamController<WsDataModel>.broadcast();
  Stream<WsDataModel> get events => _events.stream;

  Future<void> connect(Uri wsUrl) async {
    _shouldRun = true;
    // Уже подключены — второй канал продублировал бы каждое событие
    // (и каждый refresh, который оно запускает).
    if (_channel != null) return;
    final token = await GetIt.I<TokensSecureStore>().getAccessToken();
    if (token == null) return;
    // Параллельный connect() мог успеть открыть канал, пока читали токен.
    if (_channel != null) return;
    Logger.talker.debug('token exists, starting connecting');

    _channel = IOWebSocketChannel.connect(
      wsUrl,
      headers: {'Authorization': 'Bearer $token'},
      pingInterval: const Duration(seconds: 30),
    );

    _subscription = _channel!.stream.listen(
      _onData,
      onError: (e) {
        Logger.talker.critical('Ws error: $e');
        _dropChannel();
        _scheduleReconnect(wsUrl);
      },
      onDone: () {
        Logger.talker.info('ws closed');
        _dropChannel();
        _scheduleReconnect(wsUrl);
      },
      cancelOnError: true,
    );
  }

  Future<void> _onData(dynamic raw) async {
    try {
      final data = jsonDecode(raw);
      WsDataModel event = WsDataModel.fromJson(data);
      Logger.talker.debug('Ws data getted');
      retryAttempts = 0;

      _events.add(event);
    } catch (e) {
      Logger.talker.warning('ws bad frame');
    }
  }

  void _dropChannel() {
    _channel = null;
    _subscription = null;
  }

  void _scheduleReconnect(Uri url) async {
    if (!_shouldRun) return;
    if (retryAttempts == 10) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () => connect(url));
    retryAttempts++;
  }

  Future<void> disconnect() async {
    Logger.talker.debug('Ws disconnect');

    _shouldRun = false;
    _reconnectTimer?.cancel();
    // Обнуляем синхронно, чтобы connect() сразу после disconnect() не
    // принял закрывающийся канал за живой.
    final channel = _channel;
    _channel = null;
    await _subscription?.cancel();
    _subscription = null;
    await channel?.sink.close(WebSocketStatus.normalClosure);
  }
}
