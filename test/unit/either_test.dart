import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/extensions/either.dart';

void main() {
  group('Either', () {
    test('Left/Right identity', () {
      final Either<String, int> l = Left('e');
      final Either<String, int> r = Right(42);
      expect(l.isLeft, isTrue);
      expect(l.isRight, isFalse);
      expect(r.isRight, isTrue);
      expect(l.left, 'e');
      expect(r.right, 42);
    });

    test('fold picks the right branch', () {
      final Either<String, int> r = Right(10);
      final Either<String, int> l = Left('boom');
      expect(r.fold((_) => -1, (v) => v * 2), 20);
      expect(l.fold((e) => e.length, (_) => 0), 4);
    });

    test('map transforms Right, passes Left through', () {
      expect((Right<String, int>(3)).map((v) => v + 1).right, 4);
      expect((Left<String, int>('x')).map((v) => v + 1).isLeft, isTrue);
    });

    test('flatMap chains, short-circuits on Left', () {
      Either<String, int> parse(int v) => v > 0 ? Right(v) : Left('neg');
      expect((Right<String, int>(5)).flatMap(parse).right, 5);
      expect((Right<String, int>(-1)).flatMap(parse).left, 'neg');
      expect((Left<String, int>('e')).flatMap(parse).left, 'e');
    });

    test('mapLeft transforms Left only', () {
      expect((Left<String, int>('e')).mapLeft((e) => e.toUpperCase()).left, 'E');
      expect((Right<String, int>(1)).mapLeft((e) => 'x').right, 1);
    });

    test('getOrElse / rightOrNull / leftOrNull', () {
      expect((Right<String, int>(7)).getOrElse(0), 7);
      expect((Left<String, int>('e')).getOrElse(0), 0);
      expect((Right<String, int>(7)).rightOrNull, 7);
      expect((Left<String, int>('e')).rightOrNull, isNull);
      expect((Left<String, int>('e')).leftOrNull, 'e');
      expect((Right<String, int>(7)).leftOrNull, isNull);
    });

    test('onSuccess / onFailure side-effects', () {
      var s = 0, f = 0;
      (Right<String, int>(1)).onSuccess((_) => s++).onFailure((_) => f++);
      (Left<String, int>('e')).onSuccess((_) => s++).onFailure((_) => f++);
      expect(s, 1);
      expect(f, 1);
    });
  });
}
