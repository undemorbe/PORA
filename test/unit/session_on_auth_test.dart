import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/bootstrap/app_bootstrap.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';

void main() {
  test('login after logout in the same run starts a backend session', () {
    expect(
      shouldStartSessionOnAuth(
        AuthStatus.unauthenticated,
        AuthStatus.authenticated,
        alreadyQueued: false,
      ),
      isTrue,
    );
  });

  test('first login after a logged-out cold start reuses the queued '
      'session_start', () {
    expect(
      shouldStartSessionOnAuth(
        AuthStatus.unauthenticated,
        AuthStatus.authenticated,
        alreadyQueued: true,
      ),
      isFalse,
    );
  });

  test('cold start (unknown → authenticated) does not — the lifecycle '
      'listener already emitted session_start', () {
    for (final queued in [true, false]) {
      expect(
        shouldStartSessionOnAuth(
          AuthStatus.unknown,
          AuthStatus.authenticated,
          alreadyQueued: queued,
        ),
        isFalse,
      );
    }
  });

  test('no session on any other transition', () {
    for (final prev in AuthStatus.values) {
      for (final next in AuthStatus.values) {
        if (prev == AuthStatus.unauthenticated &&
            next == AuthStatus.authenticated) {
          continue;
        }
        expect(
          shouldStartSessionOnAuth(prev, next, alreadyQueued: false),
          isFalse,
          reason: '$prev → $next',
        );
      }
    }
  });
}
