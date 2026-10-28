import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/network/single_flight.dart';

void main() {
  group('SingleFlight', () {
    test('concurrent calls share one task', () async {
      final flight = SingleFlight<int>();
      final gate = Completer<int>();
      var calls = 0;
      Future<int> task() {
        calls++;
        return gate.future;
      }

      final a = flight.run(task);
      final b = flight.run(task);
      expect(flight.isRunning, isTrue);
      gate.complete(42);

      expect(await a, 42);
      expect(await b, 42);
      expect(calls, 1);
    });

    test('next call after completion runs again', () async {
      final flight = SingleFlight<int>();
      var calls = 0;
      Future<int> task() async => ++calls;

      expect(await flight.run(task), 1);
      expect(flight.isRunning, isFalse);
      expect(await flight.run(task), 2);
    });

    test('error releases the slot', () async {
      final flight = SingleFlight<int>();
      await expectLater(
        flight.run(() async => throw StateError('boom')),
        throwsStateError,
      );
      expect(flight.isRunning, isFalse);
      expect(await flight.run(() async => 7), 7);
    });
  });
}
