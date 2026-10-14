import 'dart:async';
import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/analytics/usage/usage_day.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Локальная статистика пользования (источник данных для экрана Insights).
///
/// Хранит дневные счётчики [UsageDay] в одном ключе `usage-days-v1`
/// (`LocalDBNames.settings`). Запись дебаунсится; [flush] — при уходе
/// приложения в фон. До [attach] события буферизуются в памяти, так что
/// трекер безопасно дёргать из любого места (в т.ч. до готовности DI).
///
/// [days] — `ObservableMap`: экраны в `Observer`/`@computed` реагируют на
/// новые события без ручного refresh.
class UsageTracker {
  UsageTracker({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static final UsageTracker instance = UsageTracker();

  static const storageKey = 'usage-days-v1';
  static const retentionDays = 180;
  static const _maxPending = 200;
  static const _persistDelay = Duration(milliseconds: 1500);

  final DateTime Function() _clock;
  final ObservableMap<String, UsageDay> days = ObservableMap();
  final List<UsageDay Function(UsageDay)> _pending = [];
  final List<DateTime> _pendingAt = [];

  ILocalDB<dynamic>? _db;
  Timer? _persistTimer;
  DateTime? _sessionStart;

  bool get isAttached => _db != null;

  /// Подгружает историю и проигрывает накопленные до attach события.
  Future<void> attach(ILocalDB<dynamic> db) async {
    if (_db != null) return;
    _db = db;
    try {
      final raw = await db.get(key: storageKey, boxName: LocalDBNames.settings);
      final loaded = _decode(raw);
      final cutoff = UsageDay.dayOf(
        _clock(),
      ).subtract(const Duration(days: retentionDays));
      runInAction(() {
        for (final d in loaded) {
          if (d.date.isBefore(cutoff)) continue;
          // Не затираем события, пришедшие до attach.
          days.putIfAbsent(d.key, () => d);
        }
      });
    } catch (e, s) {
      Logger.talker.warning('UsageTracker: load failed', e, s);
    }
    for (var i = 0; i < _pending.length; i++) {
      _apply(_pending[i], at: _pendingAt[i], persist: false);
    }
    _pending.clear();
    _pendingAt.clear();
    _schedulePersist();
  }

  //! --- События ---

  /// Начало сессии (холодный старт или возврат из фона).
  /// Повторный вызов в рамках живой сессии (inactive → resumed) игнорируется.
  void sessionStarted() {
    if (_sessionStart != null) return;
    _sessionStart = _clock();
    _record((d) => d.copyWith(opens: d.opens + 1), hour: true);
  }

  /// Конец сессии — копим foreground-время в день начала сессии.
  void sessionEnded() {
    final start = _sessionStart;
    _sessionStart = null;
    if (start == null) return;
    final secs = _clock().difference(start).inSeconds;
    // Защита от мусора (часы перевели, процесс «уснул» без pause).
    if (secs <= 0 || secs > const Duration(hours: 6).inSeconds) return;
    _record((d) => d.copyWith(seconds: d.seconds + secs), at: start);
    unawaited(flush());
  }

  void itemAdded({String? section}) => _record(
    (d) => d.copyWith(
      added: d.added + 1,
      addedSections: section == null
          ? d.addedSections
          : UsageDay.bumpKey(d.addedSections, section),
    ),
    hour: true,
  );

  void itemBought({String? name}) => _record(
    (d) => d.copyWith(
      bought: d.bought + 1,
      boughtNames: name == null
          ? d.boughtNames
          : UsageDay.bumpKey(d.boughtNames, name),
    ),
    hour: true,
  );

  void itemDeleted() =>
      _record((d) => d.copyWith(deleted: d.deleted + 1), hour: true);

  void listOpened() =>
      _record((d) => d.copyWith(listsOpened: d.listsOpened + 1), hour: true);

  void listCreated() =>
      _record((d) => d.copyWith(listsCreated: d.listsCreated + 1), hour: true);

  void recipeImported() =>
      _record((d) => d.copyWith(recipes: d.recipes + 1), hour: true);

  void aiMessageSent() =>
      _record((d) => d.copyWith(aiMessages: d.aiMessages + 1), hour: true);

  void screenViewed(String name) =>
      _record((d) => d.copyWith(screens: UsageDay.bumpKey(d.screens, name)));

  /// Полная очистка (logout — новый юзер не должен видеть чужую статистику).
  Future<void> clear() async {
    _persistTimer?.cancel();
    _pending.clear();
    _pendingAt.clear();
    runInAction(days.clear);
    try {
      await _db?.delete(key: storageKey, boxName: LocalDBNames.settings);
    } catch (e, s) {
      Logger.talker.warning('UsageTracker: clear failed', e, s);
    }
  }

  /// Немедленная запись на диск (pause/detach).
  Future<void> flush() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    final db = _db;
    if (db == null) return;
    try {
      final payload = jsonEncode([for (final d in days.values) d.toJson()]);
      await db.set(
        key: storageKey,
        value: payload,
        boxName: LocalDBNames.settings,
      );
    } catch (e, s) {
      Logger.talker.warning('UsageTracker: persist failed', e, s);
    }
  }

  //! --- internals ---

  void _record(
    UsageDay Function(UsageDay) update, {
    bool hour = false,
    DateTime? at,
  }) {
    final when = at ?? _clock();
    UsageDay apply(UsageDay d) {
      final next = update(d);
      return hour ? next.bumpHour(when.hour) : next;
    }

    if (_db == null) {
      if (_pending.length >= _maxPending) return;
      _pending.add(apply);
      _pendingAt.add(when);
      return;
    }
    _apply(apply, at: when);
  }

  void _apply(
    UsageDay Function(UsageDay) update, {
    required DateTime at,
    bool persist = true,
  }) {
    final date = UsageDay.dayOf(at);
    final key = UsageDay.keyOf(date);
    runInAction(() {
      days[key] = update(days[key] ?? UsageDay(date: date));
    });
    if (persist) _schedulePersist();
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(_persistDelay, () => unawaited(flush()));
  }

  static List<UsageDay> _decode(Object? raw) {
    if (raw is! String || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final e in decoded)
        if (e is Map) ?UsageDay.fromJson(e),
    ];
  }
}
