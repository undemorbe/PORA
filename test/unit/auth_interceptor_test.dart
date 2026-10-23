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
        // Отдельный Dio для повтора: повтор через тот же Dio с
        // QueuedInterceptorsWrapper ждал бы очередь onError, занятую
        // исходным запросом, если и он вернёт 401.
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
