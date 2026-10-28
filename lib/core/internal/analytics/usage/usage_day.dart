/// Счётчики использования приложения за один локальный день.
///
/// Иммутабельная модель — `UsageTracker` заменяет день целиком через
/// `copyWith`/`bump*`. JSON-ключи короткие и kebab-case (хранится локально,
/// до 180 дней × ~0.5 KB).
class UsageDay {
  const UsageDay({
    required this.date,
    this.opens = 0,
    this.seconds = 0,
    this.added = 0,
    this.bought = 0,
    this.deleted = 0,
    this.listsOpened = 0,
    this.listsCreated = 0,
    this.recipes = 0,
    this.aiMessages = 0,
    this.hours = const [],
    this.boughtNames = const {},
    this.addedSections = const {},
    this.screens = const {},
  });

  /// Полночь локального дня.
  final DateTime date;

  /// Запуски/возвраты в приложение (сессии).
  final int opens;

  /// Суммарное время в приложении (foreground), секунды.
  final int seconds;
  final int added;
  final int bought;
  final int deleted;
  final int listsOpened;
  final int listsCreated;
  final int recipes;
  final int aiMessages;

  /// 24 ячейки — сколько действий было в каждый час. Пусто = нулей.
  final List<int> hours;

  /// Имя продукта → сколько раз отмечен купленным.
  final Map<String, int> boughtNames;

  /// Секция (категория) → сколько продуктов добавлено.
  final Map<String, int> addedSections;

  /// Имя экрана → сколько раз открыт.
  final Map<String, int> screens;

  /// Был ли юзер активен в этот день хоть как-то.
  bool get isActive =>
      opens > 0 ||
      added > 0 ||
      bought > 0 ||
      deleted > 0 ||
      listsOpened > 0 ||
      recipes > 0 ||
      aiMessages > 0;

  /// Количество «действий» (без учёта времени/открытий).
  int get actions =>
      added + bought + deleted + listsCreated + recipes + aiMessages;

  int hourAt(int h) => h < hours.length ? hours[h] : 0;

  static String keyOf(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  String get key => keyOf(date);

  UsageDay copyWith({
    int? opens,
    int? seconds,
    int? added,
    int? bought,
    int? deleted,
    int? listsOpened,
    int? listsCreated,
    int? recipes,
    int? aiMessages,
    List<int>? hours,
    Map<String, int>? boughtNames,
    Map<String, int>? addedSections,
    Map<String, int>? screens,
  }) {
    return UsageDay(
      date: date,
      opens: opens ?? this.opens,
      seconds: seconds ?? this.seconds,
      added: added ?? this.added,
      bought: bought ?? this.bought,
      deleted: deleted ?? this.deleted,
      listsOpened: listsOpened ?? this.listsOpened,
      listsCreated: listsCreated ?? this.listsCreated,
      recipes: recipes ?? this.recipes,
      aiMessages: aiMessages ?? this.aiMessages,
      hours: hours ?? this.hours,
      boughtNames: boughtNames ?? this.boughtNames,
      addedSections: addedSections ?? this.addedSections,
      screens: screens ?? this.screens,
    );
  }

  /// Новый день с +1 в часовой ячейке [hour].
  UsageDay bumpHour(int hour) {
    final next = List<int>.filled(24, 0);
    for (var i = 0; i < hours.length && i < 24; i++) {
      next[i] = hours[i];
    }
    next[hour.clamp(0, 23)]++;
    return copyWith(hours: next);
  }

  static Map<String, int> bumpKey(Map<String, int> src, String key) {
    final k = key.trim();
    if (k.isEmpty) return src;
    return {...src, k: (src[k] ?? 0) + 1};
  }

  Map<String, dynamic> toJson() => {
    'date': key,
    if (opens > 0) 'opens': opens,
    if (seconds > 0) 'seconds': seconds,
    if (added > 0) 'added': added,
    if (bought > 0) 'bought': bought,
    if (deleted > 0) 'deleted': deleted,
    if (listsOpened > 0) 'lists-opened': listsOpened,
    if (listsCreated > 0) 'lists-created': listsCreated,
    if (recipes > 0) 'recipes': recipes,
    if (aiMessages > 0) 'ai-messages': aiMessages,
    if (hours.any((h) => h > 0)) 'hours': hours,
    if (boughtNames.isNotEmpty) 'bought-names': boughtNames,
    if (addedSections.isNotEmpty) 'added-sections': addedSections,
    if (screens.isNotEmpty) 'screens': screens,
  };

  /// `null` — если запись битая (нет/кривая дата).
  static UsageDay? fromJson(Map<dynamic, dynamic> json) {
    final raw = json['date'];
    final parsed = raw is String ? DateTime.tryParse(raw) : null;
    if (parsed == null) return null;
    int i(String k) => (json[k] as num?)?.toInt() ?? 0;
    Map<String, int> m(String k) {
      final v = json[k];
      if (v is! Map) return const {};
      return {
        for (final e in v.entries)
          if (e.value is num) e.key.toString(): (e.value as num).toInt(),
      };
    }

    final hoursRaw = json['hours'];
    return UsageDay(
      date: dayOf(parsed),
      opens: i('opens'),
      seconds: i('seconds'),
      added: i('added'),
      bought: i('bought'),
      deleted: i('deleted'),
      listsOpened: i('lists-opened'),
      listsCreated: i('lists-created'),
      recipes: i('recipes'),
      aiMessages: i('ai-messages'),
      hours: hoursRaw is List
          ? hoursRaw.map((e) => (e as num?)?.toInt() ?? 0).toList()
          : const [],
      boughtNames: m('bought-names'),
      addedSections: m('added-sections'),
      screens: m('screens'),
    );
  }
}
