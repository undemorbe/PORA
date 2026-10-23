import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/network/websocket/app_websocket.dart';
import 'package:pora/core/internal/network/websocket/model/ws_data_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Канал без сети: тест сам решает, открылся ли он и когда оборвался.
class _FakeChannel implements WebSocketChannel {
  _FakeChannel(this.token);

  final String token;
  final _ready = Completer<void>();
  // onCancel с Future из зоны fakeAsync: без него cancel() отдаёт
  // root-zone future, и продолжение disconnect() не видно flushMicrotasks.
  final _controller = StreamController<dynamic>(onCancel: () async {});
  bool closedByClient = false;

  void open() => _ready.complete();

  /// Handshake не удался (нет сети / 401): как IOWebSocketChannel —
  /// ошибка и в `ready`, и в stream, затем close.
  void failHandshake() {
    _ready.completeError(WebSocketChannelException('refused'));
    _controller.addError(WebSocketChannelException('refused'));
    _controller.close();
  }

  void drop() => _controller.close();

  void push(String frame) => _controller.add(frame);

  @override
  Future<void> get ready => _ready.future;

  @override
  Stream get stream => _controller.stream;

  @override
  WebSocketSink get sink => _FakeSink(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this._channel);
  final _FakeChannel _channel;

  @override
  Future close([int? closeCode, String? closeReason]) async {
    _channel.closedByClient = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final url = Uri.parse('ws://localhost/ws');
  late List<_FakeChannel> channels;
  late String? token;
  late AppWebsocket ws;

  setUp(() {
    channels = [];
    token = 'access-1';
    ws = AppWebsocket.forTesting(
      channelFactory: (_, t) {
        final c = _FakeChannel(t);
        channels.add(c);
        return c;
      },
      readToken: () async => token,
    );
  });

  test('retryDelay doubles from 3s and caps at 60s', () {
    expect(AppWebsocket.retryDelay(0), const Duration(seconds: 3));
    expect(AppWebsocket.retryDelay(1), const Duration(seconds: 6));
    expect(AppWebsocket.retryDelay(2), const Duration(seconds: 12));
    expect(AppWebsocket.retryDelay(4), const Duration(seconds: 48));
    expect(AppWebsocket.retryDelay(5), const Duration(seconds: 60));
    expect(AppWebsocket.retryDelay(500), const Duration(seconds: 60));
  });

  test('keeps reconnecting after more than 10 failed attempts', () {
    fakeAsync((async) {
      ws.connect(url);
      async.flushMicrotasks();
      for (var i = 0; i < 15; i++) {
        expect(channels, hasLength(i + 1));
        channels.last.failHandshake();
        async.flushMicrotasks();
        expect(ws.hasPendingReconnect, isTrue, reason: 'attempt $i');
        async.elapse(AppWebsocket.maxRetryDelay);
      }
      expect(channels, hasLength(16));
      expect(ws.retryAttempts, 15);
    });
  });

  test('attempts reset once the channel is open, not on data', () {
    fakeAsync((async) {
      ws.connect(url);
      async.flushMicrotasks();
      channels.last.failHandshake();
      async.flushMicrotasks();
      async.elapse(AppWebsocket.retryDelay(0));
      channels.last.failHandshake();
      async.flushMicrotasks();
      expect(ws.retryAttempts, 2);

      async.elapse(AppWebsocket.retryDelay(1));
      channels.last.open();
      async.flushMicrotasks();
      expect(ws.retryAttempts, 0);

      // Тихий обрыв без единого кадра → снова короткая задержка.
      channels.last.drop();
      async.flushMicrotasks();
      async.elapse(AppWebsocket.retryDelay(0));
      expect(channels, hasLength(4));
    });
  });

  test('each attempt reads the current access token', () {
    fakeAsync((async) {
      ws.connect(url);
      async.flushMicrotasks();
      channels.last.failHandshake();
      async.flushMicrotasks();
      token = 'access-2';
      async.elapse(AppWebsocket.retryDelay(0));
      expect(channels.map((c) => c.token), ['access-1', 'access-2']);
    });
  });

  test('a single channel for concurrent connect calls', () {
    fakeAsync((async) {
      ws.connect(url);
      ws.connect(url);
      async.flushMicrotasks();
      ws.connect(url);
      async.flushMicrotasks();
      expect(channels, hasLength(1));
    });
  });

  test('disconnect stops reconnects and closes the channel', () {
    fakeAsync((async) {
      ws.connect(url);
      async.flushMicrotasks();
      channels.last.open();
      async.flushMicrotasks();
      ws.disconnect();
      async.flushMicrotasks();
      expect(channels.last.closedByClient, isTrue);
      expect(ws.hasChannel, isFalse);
      async.elapse(const Duration(minutes: 5));
      ws.reconnectNow();
      async.flushMicrotasks();
      expect(channels, hasLength(1));
    });
  });

  test('disconnect while reading the token opens nothing', () {
    fakeAsync((async) {
      ws.connect(url);
      ws.disconnect();
      async.flushMicrotasks();
      expect(channels, isEmpty);
      expect(ws.hasPendingReconnect, isFalse);
    });
  });

  test('reconnectNow skips the backoff wait', () {
    fakeAsync((async) {
      ws.connect(url);
      async.flushMicrotasks();
      for (var i = 0; i < 5; i++) {
        channels.last.failHandshake();
        async.flushMicrotasks();
        async.elapse(AppWebsocket.maxRetryDelay);
      }
      channels.last.failHandshake();
      async.flushMicrotasks();
      expect(channels, hasLength(6));

      ws.reconnectNow();
      async.flushMicrotasks();
      expect(channels, hasLength(7));
      expect(ws.hasPendingReconnect, isFalse);
    });
  });

  test('frames are forwarded to events', () {
    fakeAsync((async) {
      final got = [];
      final sub = ws.events.listen(got.add);
      ws.connect(url);
      async.flushMicrotasks();
      channels.last
        ..open()
        ..push('not json')
        ..push('{"list-id": "l1"}');
      async.flushMicrotasks();
      expect(got, [const WsDataModel(null, 'l1', null)]);
      sub.cancel();
    });
  });
}
