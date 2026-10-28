import 'package:pora/core/internal/analytics/usage/usage_day.dart';

/// Часть суток для «когда вы активнее всего».
enum DayPart { morning, afternoon, evening, night }

extension DayPartHours on DayPart {
  /// Утро 05–11, день 12–16, вечер 17–22, ночь 23–04.
  static DayPart of(int hour) {
    if (hour >= 5 && hour < 12) return DayPart.morning;
    if (hour >= 12 && hour < 17) return DayPart.afternoon;
    if (hour >= 17 && hour < 23) return DayPart.evening;
    return DayPart.night;
  }
}

/// Точка графика активности (день или неделя — см. [UsageSummary.series]).
class ActivityPoint {
  const ActivityPoint({
    required this.start,
    required this.added,
    required this.bought,
    required this.active,
  });

  final DateTime start;
  final int added;
  final int bought;

  /// Был ли хоть один активный день в бакете.
  final bool active;

  int get total => added + bought;
}

/// Именованный счётчик (топ купленных / категории / экраны).
class CountEntry {
  const CountEntry(this.name, this.count);
  final String name;
  final int count;
}

/// Агрегат статистики пользования за период из дневных [UsageDay].
///
/// Чистая функция от входа (без I/O, без DateTime.now — время передаётся),
/// поэтому легко тестируется.
class UsageSummary {
  const UsageSummary({
    required this.periodDays,
    required this.opens,
    required this.seconds,
    required this.added,
    required this.bought,
    required this.deleted,
    required this.listsOpened,
    required this.listsCreated,
    required this.recipes,
    required this.aiMessages,
    required this.activeDays,
    required this.prevAdded,
    required this.prevBought,
    required this.prevActiveDays,
    required this.series,
    required this.hours,
    required this.weekdays,
    required this.topBought,
    required this.topSections,
    required this.currentStreak,
    required this.bestStreak,
    required this.activityByDay,
  });

  final int periodDays;
  final int opens;
  final int seconds;
  final int added;
  final int bought;
  final int deleted;
  final int listsOpened;
  final int listsCreated;
  final int recipes;
  final int aiMessages;
  final int activeDays;

  /// Те же метрики за предыдущий равный период — для трендов.
  final int prevAdded;
  final int prevBought;
  final int prevActiveDays;

  /// Ряд для графика: по дням (≤31 день) или по неделям (длиннее).
  final List<ActivityPoint> series;

  /// 24 ячейки — действия по часам за период.
  final List<int> hours;

  /// 7 ячеек — действия по дням недели (0 = понедельник).
  final List<int> weekdays;

  final List<CountEntry> topBought;
  final List<CountEntry> topSections;

  /// Дней подряд до сегодня (вчера тоже засчитывается, если сегодня ещё
  /// не заходили — серия не «сгорает» утром).
  final int currentStreak;
  final int bestStreak;

  /// Интенсивность по дням (последние 28 дней) — для heatmap.
  final Map<DateTime, int> activityByDay;

  static const empty = UsageSummary(
    periodDays: 0,
    opens: 0,
    seconds: 0,
    added: 0,
    bought: 0,
    deleted: 0,
    listsOpened: 0,
    listsCreated: 0,
    recipes: 0,
    aiMessages: 0,
    activeDays: 0,
    prevAdded: 0,
    prevBought: 0,
    prevActiveDays: 0,
    series: [],
    hours: [],
    weekdays: [],
    topBought: [],
    topSections: [],
    currentStreak: 0,
    bestStreak: 0,
    activityByDay: {},
  );

  bool get hasData => activeDays > 0 || added > 0 || bought > 0;

  /// Доля купленного от добавленного, 0..1. `null` — если не добавляли.
  double? get completionRate =>
      added == 0 ? null : (bought / added).clamp(0.0, 1.0).toDouble();

  int get minutes => (seconds / 60).round();

  /// Средняя сессия в минутах (`null` — если не было сессий).
  double? get avgSessionMinutes => opens == 0 ? null : seconds / 60 / opens;

  /// Пиковая часть суток (`null` — нет действий).
  DayPart? get peakDayPart {
    if (hours.every((h) => h == 0)) return null;
    final parts = dayParts;
    var best = DayPart.morning;
    for (final p in DayPart.values) {
      if ((parts[p] ?? 0) > (parts[best] ?? 0)) best = p;
    }
    return best;
  }

  Map<DayPart, int> get dayParts {
    final res = {for (final p in DayPart.values) p: 0};
    for (var h = 0; h < hours.length; h++) {
      final p = DayPartHours.of(h);
      res[p] = res[p]! + hours[h];
    }
    return res;
  }

  /// Самый активный день недели, 1..7 (`DateTime.monday`..), либо `null`.
  int? get peakWeekday {
    if (weekdays.every((w) => w == 0)) return null;
    var best = 0;
    for (var i = 1; i < weekdays.length; i++) {
      if (weekdays[i] > weekdays[best]) best = i;
    }
    return best + 1;
  }

  /// Изменение в процентах к прошлому периоду; `null` — нет базы сравнения.
  static int? deltaPercent(int current, int previous) {
    if (previous == 0) return null;
    return (((current - previous) / previous) * 100).round();
  }

  /// Собирает сводку за последние [periodDays] дней, включая [now].
  ///
  /// [extraActiveDays] — активные дни из внешних источников (например
  /// серверные логины): учитываются в streak/heatmap/active days.
  static UsageSummary compute({
    required Iterable<UsageDay> days,
    required int periodDays,
    required DateTime now,
    Iterable<DateTime> extraActiveDays = const [],
  }) {
    final today = UsageDay.dayOf(now);
    final start = _shift(today, -(periodDays - 1));
    final prevStart = _shift(start, -periodDays);

    final byKey = <String, UsageDay>{for (final d in days) d.key: d};

    // Все активные дни (локальные + внешние) — для streak/heatmap.
    final activeSet = <DateTime>{
      for (final d in days)
        if (d.isActive) d.date,
      for (final t in extraActiveDays) UsageDay.dayOf(t.toLocal()),
    };
    final extraCounts = <DateTime, int>{};
    for (final t in extraActiveDays) {
      final d = UsageDay.dayOf(t.toLocal());
      extraCounts[d] = (extraCounts[d] ?? 0) + 1;
    }

    var opens = 0, seconds = 0, added = 0, bought = 0, deleted = 0;
    var listsOpened = 0, listsCreated = 0, recipes = 0, ai = 0;
    var activeDays = 0, prevAdded = 0, prevBought = 0, prevActive = 0;
    final hours = List<int>.filled(24, 0);
    final weekdays = List<int>.filled(7, 0);
    final boughtNames = <String, CountEntry>{};
    final sections = <String, int>{};
    final daily = <ActivityPoint>[];

    for (var i = 0; i < periodDays * 2; i++) {
      final date = _shift(prevStart, i);
      final d = byKey[UsageDay.keyOf(date)];
      final isActive = activeSet.contains(date);
      final inPeriod = !date.isBefore(start);
      if (!inPeriod) {
        prevAdded += d?.added ?? 0;
        prevBought += d?.bought ?? 0;
        if (isActive) prevActive++;
        continue;
      }
      if (isActive) activeDays++;
      daily.add(
        ActivityPoint(
          start: date,
          added: d?.added ?? 0,
          bought: d?.bought ?? 0,
          active: isActive,
        ),
      );
      if (d == null) {
        weekdays[date.weekday - 1] += extraCounts[date] ?? 0;
        continue;
      }
      opens += d.opens;
      seconds += d.seconds;
      added += d.added;
      bought += d.bought;
      deleted += d.deleted;
      listsOpened += d.listsOpened;
      listsCreated += d.listsCreated;
      recipes += d.recipes;
      ai += d.aiMessages;
      var dayActions = 0;
      for (var h = 0; h < 24; h++) {
        hours[h] += d.hourAt(h);
        dayActions += d.hourAt(h);
      }
      weekdays[date.weekday - 1] += dayActions > 0
          ? dayActions
          : (extraCounts[date] ?? 0);
      d.boughtNames.forEach((name, c) {
        final k = name.toLowerCase();
        final prev = boughtNames[k];
        boughtNames[k] = CountEntry(prev?.name ?? name, (prev?.count ?? 0) + c);
      });
      d.addedSections.forEach((s, c) => sections[s] = (sections[s] ?? 0) + c);
    }

    final topBought = boughtNames.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final topSections = [
      for (final e in sections.entries) CountEntry(e.key, e.value),
    ]..sort((a, b) => b.count.compareTo(a.count));

    final heat = <DateTime, int>{};
    for (var i = 27; i >= 0; i--) {
      final date = _shift(today, -i);
      final d = byKey[UsageDay.keyOf(date)];
      final v =
          (d == null ? 0 : d.actions + d.opens) + (extraCounts[date] ?? 0);
      if (v > 0) heat[date] = v;
    }

    final streaks = _streaks(activeSet, today);

    return UsageSummary(
      periodDays: periodDays,
      opens: opens,
      seconds: seconds,
      added: added,
      bought: bought,
      deleted: deleted,
      listsOpened: listsOpened,
      listsCreated: listsCreated,
      recipes: recipes,
      aiMessages: ai,
      activeDays: activeDays,
      prevAdded: prevAdded,
      prevBought: prevBought,
      prevActiveDays: prevActive,
      series: periodDays > 31 ? _weekly(daily) : daily,
      hours: hours,
      weekdays: weekdays,
      topBought: topBought.take(10).toList(),
      topSections: topSections.take(8).toList(),
      currentStreak: streaks.$1,
      bestStreak: streaks.$2,
      activityByDay: heat,
    );
  }

  static List<ActivityPoint> _weekly(List<ActivityPoint> daily) {
    final res = <ActivityPoint>[];
    // Бакеты по 7 дней с конца — последний бакет всегда заканчивается сегодня.
    for (var end = daily.length; end > 0; end -= 7) {
      final from = (end - 7).clamp(0, end);
      final chunk = daily.sublist(from, end);
      res.add(
        ActivityPoint(
          start: chunk.first.start,
          added: chunk.fold(0, (a, p) => a + p.added),
          bought: chunk.fold(0, (a, p) => a + p.bought),
          active: chunk.any((p) => p.active),
        ),
      );
    }
    return res.reversed.toList();
  }

  /// (current, best). Current считается от сегодня, а если сегодня пусто —
  /// от вчера.
  static (int, int) _streaks(Set<DateTime> active, DateTime today) {
    if (active.isEmpty) return (0, 0);
    final sorted = active.toList()..sort();
    var best = 1, run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = _daysBetween(sorted[i - 1], sorted[i]);
      run = gap == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }
    var cursor = active.contains(today) ? today : _shift(today, -1);
    var current = 0;
    while (active.contains(cursor)) {
      current++;
      cursor = _shift(cursor, -1);
    }
    return (current, best < current ? current : best);
  }

  /// Календарный сдвиг (без Duration — устойчив к переходу на летнее время).
  static DateTime _shift(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  /// Разница в календарных днях (устойчива к переходу на летнее время).
  static int _daysBetween(DateTime a, DateTime b) => DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}
