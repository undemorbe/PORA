import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/bootstrap/app_bootstrap.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';

void main() {
  test('login after logout in the same run starts a backend session', () {
    expect(
      shouldStartSessionOnAuth(
        AuthStatus.unauthenticated,
        AuthStatus.authenticated,
      ),
      isTrue,
    );
  });

  test('cold start (unknown → authenticated) does not — the lifecycle '
      'listener already emitted session_start', () {
    expect(
      shouldStartSessionOnAuth(AuthStatus.unknown, AuthStatus.authenticated),
      isFalse,
    );
  });

  test('no session on any other transition', () {
    for (final prev in AuthStatus.values) {
      for (final next in AuthStatus.values) {
        if (prev == AuthStatus.unauthenticated &&
            next == AuthStatus.authenticated) {
          continue;
        }
        expect(
          shouldStartSessionOnAuth(prev, next),
          isFalse,
          reason: '$prev → $next',
        );
      }
    }
  });
}
