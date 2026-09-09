import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/errors/api_error_code.dart';
import 'package:pora/core/internal/errors/failure.dart';

void main() {
  group('Failure.isConnectivity', () {
    test('network & timeout are connectivity', () {
      expect(const NetworkFailure().isConnectivity, isTrue);
      expect(const TimeoutFailure().isConnectivity, isTrue);
    });

    test('4xx / validation / server are NOT connectivity', () {
      expect(const ValidationFailure('x').isConnectivity, isFalse);
      expect(const ServerFailure('x').isConnectivity, isFalse);
      expect(const CacheMissFailure().isConnectivity, isFalse);
      expect(
        const NotFoundFailure(code: ApiErrorCode.unknown, message: 'nf')
            .isConnectivity,
        isFalse,
      );
    });
  });

  group('specialised ApiFailures', () {
    test('NotFound/Conflict are ApiFailure with status', () {
      const nf = NotFoundFailure(code: ApiErrorCode.unknown, message: 'nf');
      const cf = ConflictFailure(code: ApiErrorCode.unknown, message: 'cf');
      expect(nf, isA<ApiFailure>());
      expect(nf.statusCode, 404);
      expect(cf, isA<ApiFailure>());
      expect(cf.statusCode, 409);
    });

    test('RateLimitFailure carries retryAfterSeconds', () {
      const rl = RateLimitFailure(message: 'slow', retryAfterSeconds: 30);
      expect(rl, isA<ApiFailure>());
      expect(rl.statusCode, 429);
      expect(rl.retryAfterSeconds, 30);
    });

    test('ApiFailure.isAuthLoss', () {
      const a = ApiFailure(code: ApiErrorCode.unauthorized, message: 'x');
      const b = ApiFailure(code: ApiErrorCode.unknown, message: 'x');
      expect(a.isAuthLoss, isTrue);
      expect(b.isAuthLoss, isFalse);
    });
  });
}
