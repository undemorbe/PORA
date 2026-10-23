import 'dart:async';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:pora/core/features/auth_and_validation/data/datasource/local/secure_tokens.dart';
import 'package:pora/core/features/settings/presentation/store/settings_store.dart';
import 'package:pora/core/features/user/domain/repository/user/user_repository.dart';
import 'package:pora/core/features/user/domain/usecase/user/delete_account.dart';
import 'package:pora/core/features/user/domain/usecase/user/logout.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';
import 'package:pora/core/internal/offline/outbox.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';

import '../helpers/fake_local_db.dart';

/// Порядок шагов выхода/удаления фиксируем общим журналом.
final _log = <String>[];

class _FakeUserRepository implements UserRepository {
  bool deleteFails = false;

  @override
  Future<Either<Failure, Success>> logout() async {
    _log.add('logout');
    return Right(const ServerSuccess());
  }

  @override
  Future<Either<Failure, Success>> deleteAccount() async {
    _log.add('delete');
    if (deleteFails) return Left(const NetworkFailure());
    return Right(const ServerSuccess());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tmp;
  late FakeLocalDB db;
  late _FakeUserRepository repo;
  late AuthState auth;
  var canSend = true;
  Future<SendOutcome> Function(List<Map<String, dynamic>>) send = (_) async =>
      SendOutcome.sent;

  final sink = BackendEventSink.instance;

  setUpAll(() async {
    tmp = Directory.systemTemp.createTempSync('pora_settings_teardown');
    Hive.init(tmp.path);
    db = FakeLocalDB();
    await sink.attach(
      db: db,
      sender: (events) => send(events),
      canSend: () => canSend,
      platform: 'android',
      appVersion: '1.0.0',
    );
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    tmp.deleteSync(recursive: true);
  });

  setUp(() async {
    _log.clear();
    canSend = true;
    send = (events) async {
      _log.add('send:${events.length}');
      return SendOutcome.sent;
    };
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'a',
      'refresh_token': 'r',
    });
    repo = _FakeUserRepository();
    auth = AuthState()..setAuthenticated();
    GetIt.I
      ..registerFactory<LogoutUseCase>(() => LogoutUseCase(repository: repo))
      ..registerFactory<DeleteAccountUseCase>(
        () => DeleteAccountUseCase(repository: repo),
      )
      ..registerSingleton<Outbox>(Outbox())
      ..registerSingleton<TokensSecureStore>(TokensSecureStore())
      ..registerSingleton<AuthState>(auth);
    await sink.clear();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<Object?> stored() =>
      db.get(key: BackendEventSink.storageKey, boxName: LocalDBNames.settings);

  test('logout flushes queued events before the server logout, then clears '
      'the queue', () async {
    sink
      ..track('screen_view', {'screen': 'HomeRoute'})
      ..track('ai_chat_opened');

    await SettingsStore().logout();

    expect(_log, ['send:2', 'logout']);
    expect(sink.pending, isEmpty);
    expect(await stored(), isNull);
    expect(await GetIt.I<TokensSecureStore>().getAccessToken(), isNull);
    expect(auth.isAuthenticated, isFalse);
  });

  test('logout clears unsent events when the flush fails', () async {
    send = (events) async {
      _log.add('send:${events.length}');
      return SendOutcome.retry;
    };
    sink.track('ai_chat_opened');

    await SettingsStore().logout();

    expect(_log, ['send:1', 'logout']);
    expect(sink.pending, isEmpty, reason: 'next user must not inherit them');
    expect(await stored(), isNull);
  });

  test('logout is not blocked by a hanging analytics request', () async {
    final previous = logoutAnalyticsFlushTimeout;
    logoutAnalyticsFlushTimeout = const Duration(milliseconds: 50);
    addTearDown(() => logoutAnalyticsFlushTimeout = previous);
    final hang = Completer<SendOutcome>();
    addTearDown(() => hang.complete(SendOutcome.sent));
    send = (events) {
      _log.add('send:${events.length}');
      return hang.future;
    };
    sink.track('ai_chat_opened');

    await SettingsStore().logout().timeout(const Duration(seconds: 2));

    expect(_log, ['send:1', 'logout']);
    expect(sink.pending, isEmpty);
    expect(auth.isAuthenticated, isFalse);
  });

  test('deleteAccount never sends events of the deleted account, only '
      'clears them', () async {
    sink
      ..track('screen_view', {'screen': 'SettingsRoute'})
      ..track('support_message_sent');

    final ok = await SettingsStore().deleteAccount();

    expect(ok, isTrue);
    expect(_log, ['delete']);
    expect(sink.pending, isEmpty);
    expect(await stored(), isNull);
    expect(auth.isAuthenticated, isFalse);
  });

  test('failed deleteAccount keeps the session and its queue', () async {
    repo.deleteFails = true;
    canSend = false; // не даём периодическому flush'у вмешаться
    sink.track('ai_chat_opened');

    final ok = await SettingsStore().deleteAccount();

    expect(ok, isFalse);
    expect(_log, ['delete']);
    expect([for (final e in sink.pending) e.name], ['ai_chat_opened']);
    expect(auth.isAuthenticated, isTrue);
  });
}
