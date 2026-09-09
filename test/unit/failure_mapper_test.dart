import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/failure_mapper.dart';

DioException _dio(
  DioExceptionType type, {
  int? status,
  Object? body,
  Map<String, List<String>>? headers,
}) {
  final opts = RequestOptions(path: '/x');
  return DioException(
    requestOptions: opts,
    type: type,
    response: status == null
        ? null
        : Response<dynamic>(
            requestOptions: opts,
            statusCode: status,
            data: body,
            headers: headers == null ? null : Headers.fromMap(headers),
          ),
  );
}

void main() {
  group('FailureMapper', () {
    test('timeouts → TimeoutFailure', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(FailureMapper.map(_dio(t)), isA<TimeoutFailure>());
      }
    });

    test('connectionError → NetworkFailure', () {
      expect(
        FailureMapper.map(_dio(DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
    });

    test('404 → NotFoundFailure', () {
      final f = FailureMapper.map(
        _dio(DioExceptionType.badResponse, status: 404),
      );
      expect(f, isA<NotFoundFailure>());
    });

    test('409 → ConflictFailure', () {
      final f = FailureMapper.map(
        _dio(DioExceptionType.badResponse, status: 409),
      );
      expect(f, isA<ConflictFailure>());
    });

    test('429 → RateLimitFailure with retry-after', () {
      final f = FailureMapper.map(
        _dio(
          DioExceptionType.badResponse,
          status: 429,
          headers: {
            'retry-after': ['45'],
          },
        ),
      );
      expect(f, isA<RateLimitFailure>());
      expect((f as RateLimitFailure).retryAfterSeconds, 45);
    });

    test('500 → ApiFailure (generic)', () {
      final f = FailureMapper.map(
        _dio(DioExceptionType.badResponse, status: 500),
      );
      expect(f, isA<ApiFailure>());
      expect(f, isNot(isA<NotFoundFailure>()));
      expect((f as ApiFailure).statusCode, 500);
    });

    test('backend error body message is surfaced', () {
      final f = FailureMapper.map(
        _dio(
          DioExceptionType.badResponse,
          status: 400,
          body: {
            'error': {'code': 'BAD', 'message': 'Nope'},
          },
        ),
      );
      expect(f, isA<ApiFailure>());
      expect(f.message, 'Nope');
    });

    test('FormatException → ServerFailure, other → UnexpectedFailure', () {
      expect(
        FailureMapper.map(const FormatException('bad json')),
        isA<ServerFailure>(),
      );
      expect(FailureMapper.map(StateError('x')), isA<UnexpectedFailure>());
    });
  });
}
