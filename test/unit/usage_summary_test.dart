import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/internal/analytics/usage/usage_day.dart';
import 'package:pora/core/internal/analytics/usage/usage_summary.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

UsageDay day(
  DateTime date, {
  int opens = 1,
  int added = 0,
  int bought = 0,
  Map<int, int> hours = const {},
  Map<String, int> boughtNames = const {},
  Map<String, int> sections = const {},
}) {
  var u = UsageDay(
    date: date,
    opens: opens,
    added: added,
    bought: bought,
    boughtNames: boughtNames,
    addedSections: sections,
  );
  hours.forEach((h, n) {
    for (var i = 0; i < n; i++) {
      u = u.bumpHour(h);
    }
  });
  return u;
}

void main() {
  final now = DateTime(2026, 10, 6, 14);

  group('UsageSummary.compute', () {
    test('empty input → zeros, no streak', () {
      final s = UsageSummary.compute(days: [], periodDays: 7, now: now);
      expect(s.hasData, isFalse);
      expect(s.currentStreak, 0);
      expect(s.bestStreak, 0);
      expect(s.series, hasLength(7));
      expect(s.completionRate, isNull);
      expect(s.peakDayPart, isNull);
    });

    test('totals only within period, previous period separated', () {
      final s = UsageSummary.compute(
        days: [
          day(d(2026, 10, 6), added: 3, bought: 2),
          day(d(2026, 9, 30), added: 1), // первый день 7-дневного периода
          day(d(2026, 9, 29), added: 10, bought: 4), // прошлый период
        ],
        periodDays: 7,
        now: now,
      );
      expect(s.added, 4);
      expect(s.bought, 2);
      expect(s.prevAdded, 10);
      expect(s.prevBought, 4);
      expect(s.activeDays, 2);
      expect(s.completionRate, closeTo(0.5, 1e-9));
      expect(UsageSummary.deltaPercent(s.added, s.prevAdded), -60);
    });

    test(
      'current streak survives morning without activity (counts from yesterday)',
      () {
        final s = UsageSummary.compute(
          days: [day(d(2026, 10, 5)), day(d(2026, 10, 4)), day(d(2026, 10, 3))],
          periodDays: 7,
          now: now,
        );
        expect(s.currentStreak, 3);
        expect(s.bestStreak, 3);
      },
    );

    test('best streak kept after a gap; extra active days merged', () {
      final s = UsageSummary.compute(
        days: [
          day(d(2026, 9, 1)),
          day(d(2026, 9, 2)),
          day(d(2026, 9, 3)),
          day(d(2026, 9, 4)),
          day(d(2026, 10, 6)),
        ],
        periodDays: 30,
        now: now,
        // серверный логин вчера продлевает серию до 2
        extraActiveDays: [DateTime(2026, 10, 5, 9)],
      );
      expect(s.currentStreak, 2);
      expect(s.bestStreak, 4);
    });

    test('streak across DST switch is not broken', () {
      // В Европе переход на зимнее время — последнее воскресенье октября.
      final s = UsageSummary.compute(
        days: [for (var i = 24; i <= 28; i++) day(d(2026, 10, i))],
        periodDays: 7,
        now: DateTime(2026, 10, 28, 20),
      );
      expect(s.currentStreak, 5);
    });

    test('90-day period is bucketed by weeks ending today', () {
      final s = UsageSummary.compute(
        days: [day(d(2026, 10, 6), added: 2), day(d(2026, 10, 1), added: 1)],
        periodDays: 90,
        now: now,
      );
      expect(s.series.length, 13); // ceil(90 / 7)
      expect(s.series.last.added, 3);
      expect(s.series.last.active, isTrue);
    });

    test('peak day part, weekday, top bought & sections aggregate', () {
      final s = UsageSummary.compute(
        days: [
          day(
            d(2026, 10, 5), // понедельник
            hours: {19: 3, 8: 1},
            boughtNames: {'Молоко': 2, 'Хлеб': 1},
            sections: {'Молочное': 2},
          ),
          day(
            d(2026, 10, 6),
            hours: {20: 1},
            boughtNames: {'молоко': 1},
            sections: {'Молочное': 1, 'Выпечка': 1},
          ),
        ],
        periodDays: 7,
        now: now,
      );
      expect(s.peakDayPart, DayPart.evening);
      expect(s.peakWeekday, DateTime.monday);
      expect(s.topBought.first.name, 'Молоко');
      expect(s.topBought.first.count, 3); // регистр не важен
      expect(s.topSections.first.name, 'Молочное');
      expect(s.topSections.first.count, 3);
    });

    test('heatmap holds last 28 days only', () {
      final s = UsageSummary.compute(
        days: [day(d(2026, 10, 6)), day(d(2026, 8, 1))],
        periodDays: 90,
        now: now,
      );
      expect(s.activityByDay.keys, [d(2026, 10, 6)]);
    });
  });

  group('UsageDay', () {
    test('json round-trip keeps all counters', () {
      final src = day(
        d(2026, 10, 6),
        opens: 2,
        added: 3,
        bought: 1,
        hours: {7: 2},
        boughtNames: {'Сыр': 1},
        sections: {'Молочное': 3},
      ).copyWith(seconds: 120, deleted: 1, recipes: 1, aiMessages: 4);
      final back = UsageDay.fromJson(src.toJson())!;
      expect(back.toJson(), src.toJson());
      expect(back.hourAt(7), 2);
    });

    test('broken json → null', () {
      expect(UsageDay.fromJson({'date': 'nope'}), isNull);
      expect(UsageDay.fromJson({}), isNull);
    });
  });

  group('DayPartHours', () {
    test('boundaries', () {
      expect(DayPartHours.of(4), DayPart.night);
      expect(DayPartHours.of(5), DayPart.morning);
      expect(DayPartHours.of(12), DayPart.afternoon);
      expect(DayPartHours.of(17), DayPart.evening);
      expect(DayPartHours.of(23), DayPart.night);
    });
  });
}
