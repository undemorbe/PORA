import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Открывает канал к [url] с access-токеном [token].
typedef WsChannelFactory = WebSocketChannel Function(Uri url, String token);

/// Читает актуальный access-токен (на каждой попытке — он мог обновиться).
typedef WsTokenReader = Future<String?> Function();

class AppWebsocket {
  AppWebsocket._({WsChannelFactory? channelFactory, WsTokenReader? readToken})
    : _channelFactory = channelFactory ?? _ioChannel,
      _readToken =
          readToken ?? (() => GetIt.I<TokensSecureStore>().getAccessToken());

  static final instance = AppWebsocket._();

  @visibleForTesting
  AppWebsocket.forTesting({
    required WsChannelFactory channelFactory,
    required WsTokenReader readToken,
  }) : this._(channelFactory: channelFactory, readToken: readToken);

  //! Backoff переподключения
  static const baseRetryDelay = Duration(seconds: 3);
  static const maxRetryDelay = Duration(seconds: 60);

  /// 3с, 6с, 12с … не больше [maxRetryDelay]. Попытки не ограничены —
  /// пока [_shouldRun], сокет поднимется после любого числа обрывов.
  @visibleForTesting
  static Duration retryDelay(int attempt) {
    final factor = 1 << math.min(attempt, 10);
    final ms = baseRetryDelay.inMilliseconds * factor;
    return Duration(milliseconds: math.min(ms, maxRetryDelay.inMilliseconds));
  }

  static WebSocketChannel _ioChannel(Uri url, String token) =>
      IOWebSocketChannel.connect(
        url,
        headers: {'Authorization': 'Bearer $token'},
        pingInterval: const Duration(seconds: 30),
        // Зависший handshake не должен блокировать переподключение навсегда.
        connectTimeout: const Duration(seconds: 15),
      );

  final WsChannelFactory _channelFactory;
  final WsTokenReader _readToken;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _shouldRun = false;
  // connect() читает токен — параллельный вызов не должен открыть второй канал.
  bool _connecting = false;
  Uri? _url;
  int _retryAttempts = 0;

  /// Подряд неудачных попыток; сбрасывается, когда канал реально открылся.
  @visibleForTesting
  int get retryAttempts => _retryAttempts;

  @visibleForTesting
  bool get hasChannel => _channel != null;

  @visibleForTesting
  bool get hasPendingReconnect => _reconnectTimer?.isActive ?? false;

  final _events = StreamController<WsDataModel>.broadcast();
  Stream<WsDataModel> get events => _events.stream;

  Future<void> connect(Uri wsUrl) async {
    _shouldRun = true;
    _url = wsUrl;
    // Уже подключены — второй канал продублировал бы каждое событие
    // (и каждый refresh, который оно запускает).
    if (_channel != null || _connecting) return;
    // Явный connect (логин, resume, таймер) заменяет отложенную попытку.
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _connecting = true;
    String? token;
    try {
      token = await _readToken();
    } catch (e) {
      Logger.talker.warning('ws token read failed: $e');
      _connecting = false;
      _scheduleReconnect();
      return;
    }
    _connecting = false;
    // Пока читали токен, мог случиться disconnect() (logout).
    if (!_shouldRun || _channel != null) return;
    // Нет токена — нет сессии; после логина connect() вызовет AuthState.
    if (token == null) return;
    Logger.talker.debug('token exists, starting connecting');

    final WebSocketChannel channel;
    try {
      channel = _channelFactory(wsUrl, token);
    } catch (e) {
      Logger.talker.warning('ws connect failed: $e');
      _scheduleReconnect();
      return;
    }
    _channel = channel;

    _subscription = channel.stream.listen(
      _onData,
      onError: (Object e) {
        // Колбэки закрытого/заменённого канала игнорируем.
        if (!identical(_channel, channel)) return;
        Logger.talker.warning('Ws error: $e');
        _onClosed();
      },
      onDone: () {
        if (!identical(_channel, channel)) return;
        Logger.talker.info('ws closed');
        _onClosed();
      },
      cancelOnError: true,
    );
    unawaited(_awaitReady(channel));
  }

  /// Канал реально открыт → backoff с нуля. Ошибка handshake'а (нет сети,
  /// протухший токен → 401) приходит и в `stream`, переподключение — там;
  /// здесь только гасим её, чтобы не было необработанного async-исключения.
  Future<void> _awaitReady(WebSocketChannel channel) async {
    try {
      await channel.ready;
    } catch (e) {
      Logger.talker.debug('ws handshake failed: $e');
      return;
    }
    if (!identical(_channel, channel)) return;
    _retryAttempts = 0;
    Logger.talker.info('ws connected');
  }

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw);
      WsDataModel event = WsDataModel.fromJson(data);
      Logger.talker.debug('Ws data getted');

      _events.add(event);
    } catch (e) {
      Logger.talker.warning('ws bad frame');
    }
  }

  void _onClosed() {
    _channel = null;
    _subscription = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    final url = _url;
    if (!_shouldRun || url == null) return;
    _reconnectTimer?.cancel();
    final delay = retryDelay(_retryAttempts);
    _retryAttempts++;
    Logger.talker.debug('ws reconnect in ${delay.inSeconds}s');
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(connect(url));
    });
  }

  /// Свежие условия (вернулись из фона, появилась сеть): не ждём backoff.
  /// Ничего не делает после [disconnect] и при живом канале.
  void reconnectNow() {
    final url = _url;
    if (!_shouldRun || url == null) return;
    if (_channel != null || _connecting) return;
    _retryAttempts = 0;
    unawaited(connect(url));
  }

  Future<void> disconnect() async {
    Logger.talker.debug('Ws disconnect');

    _shouldRun = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _retryAttempts = 0;
    // Обнуляем синхронно, чтобы connect() сразу после disconnect() не
    // принял закрывающийся канал за живой.
    final channel = _channel;
    _channel = null;
    // Поле обнуляем до await: connect() во время отмены не должен потерять
    // свою новую подписку.
    final cancelled = _subscription?.cancel();
    _subscription = null;
    await cancelled;
    try {
      await channel?.sink.close(WebSocketStatus.normalClosure);
    } catch (e) {
      Logger.talker.debug('ws close failed: $e');
    }
  }
}
