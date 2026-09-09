import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/cache/offline_policy.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_store.dart';

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    getIt.reset();
    getIt.registerSingleton<ConnectivityStore>(ConnectivityStore());
  });

  test('online: cache served only for connectivity failures', () {
    getIt<ConnectivityStore>().online = true;
    expect(canServeCache(const NetworkFailure()), isTrue);
    expect(canServeCache(const TimeoutFailure()), isTrue);
    expect(canServeCache(const ValidationFailure('x')), isFalse);
    expect(canServeCache(const ServerFailure('x')), isFalse);
  });

  test('offline: cache served for any failure', () {
    getIt<ConnectivityStore>().online = false;
    expect(canServeCache(const ValidationFailure('x')), isTrue);
    expect(canServeCache(const ServerFailure('x')), isTrue);
    expect(canServeCache(const NetworkFailure()), isTrue);
  });
}
