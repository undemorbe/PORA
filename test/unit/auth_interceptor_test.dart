import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/network/api_client/api_client.dart';
import 'package:pora/core/internal/network/interceptors/auth_interceptor.dart';

/// Адаптер, отвечающий 401 на любой запрос.
class _Unauthorized implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString('', 401);
  }

  @override
  void close({bool force = false}) {}
}

/// Адаптер, запоминающий опции запроса и отвечающий 202.
class _Capture implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString('', 202);
  }

  @override
  void close({bool force = false}) {}
}

/// Первый запрос — 401, повтор — обрыв сети.
class _UnauthorizedThenOffline implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (calls++ == 0) return ResponseBody.fromString('', 401);
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'offline',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Unauthorized adapter;
  late int refreshes;
  late int refreshFailures;
  late Dio dio;

  setUp(() {
    adapter = _Unauthorized();
    refreshes = 0;
    refreshFailures = 0;
    dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: () => 'stale',
        onRefresh: () async {
          refreshes++;
          return 'fresh';
        },
        onRefreshFailed: () => refreshFailures++,
        dioProvider: () => Dio()..httpClientAdapter = adapter,
      ),
    );
  });

  test('401 on a skip-auth-refresh request passes through untouched', () async {
    await expectLater(
      dio.post<void>(
        '/analytics/events',
        options: Options(extra: {AuthInterceptor.skipAuthRefreshKey: true}),
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(refreshes, 0);
    expect(refreshFailures, 0);
    expect(adapter.calls, 1, reason: 'no retry with another token');
  });

  test('401 on a regular request still refreshes and retries', () async {
    await expectLater(dio.get<void>('/user/me'), throwsA(isA<DioException>()));
    expect(refreshes, 1);
    expect(adapter.calls, 2);
  });

  test('retry through the same Dio that 401s again does not hang', () async {
    final failures = <int>[];
    final same = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = adapter;
    same.interceptors.add(
      AuthInterceptor(
        tokenProvider: () => 'stale',
        onRefresh: () async => 'fresh',
        onRefreshFailed: () => failures.add(1),
        dioProvider: () => same,
      ),
    );

    await expectLater(
      same.get<void>('/user/me').timeout(const Duration(seconds: 2)),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(adapter.calls, 2);
    expect(failures, [1], reason: '401 with a fresh token ends the session');
  });

  test('network error on retry keeps the session', () async {
    final flaky = _UnauthorizedThenOffline();
    final failures = <int>[];
    final client = Dio(BaseOptions(baseUrl: 'http://localhost'))
      ..httpClientAdapter = flaky;
    client.interceptors.add(
      AuthInterceptor(
        tokenProvider: () => 'stale',
        onRefresh: () async => 'fresh',
        onRefreshFailed: () => failures.add(1),
        dioProvider: () => client,
      ),
    );

    await expectLater(
      client.get<void>('/user/me').timeout(const Duration(seconds: 2)),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );
    expect(failures, isEmpty);
  });

  test('401 from /refresh itself ends the session without retry', () async {
    await expectLater(
      dio.get<void>('/authorize/refresh'),
      throwsA(isA<DioException>()),
    );
    expect(refreshes, 0);
    expect(refreshFailures, 1);
    expect(adapter.calls, 1);
  });

  test('refresh sends the token in a POST body, not the URL', () async {
    final capture = _Capture();
    final client = ApiClient(
      Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = capture,
    );
    try {
      await client.refreshTokens(body: {'refresh-token': 'r1'});
    } catch (_) {
      // _Capture отвечает 202 без тела — парсинг ответа не важен
    }
    final sent = capture.last!;
    expect(sent.method, 'POST');
    expect(sent.path, '/authorize/refresh');
    expect(sent.uri.query, isEmpty);
    expect(sent.data, {'refresh-token': 'r1'});
  });

  test('ApiClient marks analytics requests with skip-auth-refresh', () async {
    final capture = _Capture();
    final client = ApiClient(
      Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = capture,
    );
    await client.sendAnalyticsEvents(body: {'events': <Object>[]});
    expect(capture.last?.extra[AuthInterceptor.skipAuthRefreshKey], isTrue);
  });
}
