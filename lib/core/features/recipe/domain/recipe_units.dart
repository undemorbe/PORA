import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';

/// Единицы рецептов: канонизация (RU/EN словоформы → `g`, `tbsp`, …),
/// локализация для UI и перевод в единицы списка покупок
/// ([AddItemDefaults.units]).
///
/// Общая точка для детерминированного парсера, AI-нормализатора и чата —
/// раньше у каждого был свой словарь, и результат зависел от пути разбора.
abstract final class RecipeUnits {
  /// Каноническая единица → словоформы (без точек, нижний регистр).
  static const Map<String, List<String>> _forms = {
    'g': ['г', 'гр', 'грамм', 'грамма', 'граммов', 'g', 'gr', 'gram', 'grams'],
    'kg': [
      'кг',
      'килограмм',
      'килограмма',
      'килограммов',
      'kg',
      'kilogram',
      'kilograms',
    ],
    'mg': ['мг', 'mg'],
    'ml': [
      'мл',
      'миллилитр',
      'миллилитра',
      'миллилитров',
      'ml',
      'milliliter',
      'milliliters',
      'millilitre',
      'millilitres',
    ],
    'l': [
      'л',
      'литр',
      'литра',
      'литров',
      'l',
      'liter',
      'liters',
      'litre',
      'litres',
    ],
    'pcs': [
      'шт',
      'штук',
      'штуки',
      'штука',
      'кусок',
      'куска',
      'кусков',
      'кусочек',
      'кусочка',
      'кусочков',
      'pc',
      'pcs',
      'piece',
      'pieces',
    ],
    'tbsp': [
      'ст л',
      'ст ложка',
      'ст ложки',
      'ст ложек',
      'ст лож',
      'стл',
      'столовая ложка',
      'столовые ложки',
      'столовых ложек',
      'столовой ложки',
      'tbsp',
      'tbs',
      'tbl',
      'tablespoon',
      'tablespoons',
    ],
    'tsp': [
      'ч л',
      'ч ложка',
      'ч ложки',
      'ч ложек',
      'ч лож',
      'чл',
      'чайная ложка',
      'чайные ложки',
      'чайных ложек',
      'чайной ложки',
      'tsp',
      'teaspoon',
      'teaspoons',
    ],
    'cup': ['стакан', 'стакана', 'стаканов', 'cup', 'cups'],
    'oz': ['oz', 'ounce', 'ounces', 'унц', 'унция', 'унции', 'унций'],
    'lb': ['lb', 'lbs', 'pound', 'pounds', 'фунт', 'фунта', 'фунтов'],
    'clove': ['зубчик', 'зубчика', 'зубчиков', 'clove', 'cloves'],
    'can': ['банка', 'банки', 'банок', 'can', 'cans', 'tin', 'tins'],
    'bunch': ['пучок', 'пучка', 'пучков', 'bunch', 'bunches'],
    'pinch': ['щепотка', 'щепотки', 'щепоток', 'щепоть', 'pinch', 'pinches'],
    'pack': [
      'упаковка',
      'упаковки',
      'упаковок',
      'уп',
      'пачка',
      'пачки',
      'пачек',
      'pack',
      'packs',
      'package',
      'packages',
      'packet',
      'packets',
    ],
    'slice': ['ломтик', 'ломтика', 'ломтиков', 'slice', 'slices'],
  };

  static final Map<String, String> _aliases = {
    for (final entry in _forms.entries)
      for (final form in entry.value) form: entry.key,
    // Уже локализованные русские сокращения (вывод [localize]).
    'ст л': 'tbsp',
    'ч л': 'tsp',
  };

  static const Map<String, String> _russian = {
    'g': 'г',
    'kg': 'кг',
    'mg': 'мг',
    'ml': 'мл',
    'l': 'л',
    'pcs': 'шт',
    'tbsp': 'ст. л.',
    'tsp': 'ч. л.',
    'cup': 'стакан',
    'oz': 'унц.',
    'lb': 'фунт',
    'clove': 'зубчик',
    'can': 'банка',
    'bunch': 'пучок',
    'pinch': 'щепотка',
    'pack': 'уп',
    'slice': 'ломтик',
  };

  /// Regex-альтернатива всех словоформ (длинные первыми), допускает точки и
  /// пробелы внутри сокращений: «ст.л.», «ст. ложки», «ч.л».
  static final String pattern = () {
    final forms = _aliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return forms
        .map(
          (f) => f
              .split(' ')
              .map(RegExp.escape)
              .join(r'\.?\s*')
              .replaceAllMapped(
                // «стл»/«чл» пишут и как «ст.л».
                RegExp(r'^(ст|ч)(л)$'),
                (m) => '${m[1]}\\.?${m[2]}',
              ),
        )
        .join('|');
  }();

  static String _key(String raw) => raw
      .toLowerCase()
      .replaceAll('.', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Каноническая единица или `null`, если [raw] не похоже на единицу.
  static String? canonical(String? raw) {
    if (raw == null) return null;
    final key = _key(raw);
    if (key.isEmpty) return null;
    if (_forms.containsKey(key)) return key;
    return _aliases[key] ?? _aliases[key.replaceAll(' ', '')];
  }

  /// Единица для показа пользователю на языке [languageCode].
  /// Неизвестные единицы возвращаются как есть.
  static String? localize(String? raw, String languageCode) {
    if (raw == null || raw.trim().isEmpty) return null;
    final canon = canonical(raw);
    if (canon == null) return raw.trim();
    if (languageCode.toLowerCase().startsWith('ru')) {
      return _russian[canon] ?? canon;
    }
    return canon;
  }

  static const Map<String, String> _unicodeFractions = {
    '½': '1/2',
    '⅓': '1/3',
    '⅔': '2/3',
    '¼': '1/4',
    '¾': '3/4',
    '⅕': '1/5',
    '⅛': '1/8',
    '⅜': '3/8',
    '⅝': '5/8',
    '⅞': '7/8',
  };

  static const String fractionChars = '½⅓⅔¼¾⅕⅛⅜⅝⅞';

  /// `1½` → `1 1/2`, `½` → `1/2`, «2 – 3» → `2-3`.
  static String normalizeQuantity(String raw) {
    var value = raw.trim();
    _unicodeFractions.forEach((char, ascii) {
      value = value.replaceAllMapped(
        RegExp('(\\d?)\\s*$char'),
        (m) => m[1]!.isEmpty ? ascii : '${m[1]} $ascii',
      );
    });
    return value
        .replaceAll(RegExp(r'\s*/\s*'), '/')
        .replaceAll(RegExp(r'\s*(?:[-–—]|\s+to\s+|\s+до\s+)\s*'), '-')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Числовое значение количества; для диапазона берётся верхняя граница
  /// (в магазине лучше взять с запасом).
  static double? parseQuantity(String? raw) {
    if (raw == null) return null;
    final normalized = normalizeQuantity(raw).replaceAll(',', '.');
    final parts = normalized.split('-');
    final value = parts.last.trim().isEmpty ? parts.first : parts.last;
    return _parseNumber(value.trim());
  }

  static double? _parseNumber(String value) {
    final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(value);
    if (mixed != null) {
      final den = int.parse(mixed[3]!);
      if (den == 0) return null;
      return int.parse(mixed[1]!) + int.parse(mixed[2]!) / den;
    }
    final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(value);
    if (frac != null) {
      final den = int.parse(frac[2]!);
      if (den == 0) return null;
      return int.parse(frac[1]!) / den;
    }
    final number = RegExp(r'\d+(?:\.\d+)?').firstMatch(value);
    return number == null ? null : double.tryParse(number[0]!);
  }

  /// Переводит количество рецепта в позицию списка покупок: целое число и
  /// единица из [AddItemDefaults.units].
  ///
  /// - дробные кг/л → г/мл (`0.5 кг` → `500 г`, а не `0 кг`);
  /// - кухонные меры (ложки, стаканы, щепотки, зубчики) → `1 шт`:
  ///   «2 ст. л. масла» в магазине — это одна бутылка масла;
  /// - всё неизвестное округляется вверх, минимум 1.
  static ({int quantity, String unit}) toShopping(
    String? quantity,
    String? unit,
  ) {
    final value = parseQuantity(quantity);
    final canon = canonical(unit);
    const fallback = (quantity: 1, unit: AddItemDefaults.defaultUnit);

    int up(double v) => v <= 0 ? 1 : v.ceil();

    switch (canon) {
      case 'g':
        return (quantity: up(value ?? 1), unit: 'г');
      case 'mg':
        return (quantity: 1, unit: 'г');
      case 'ml':
        return (quantity: up(value ?? 1), unit: 'мл');
      case 'kg':
        if (value != null && value != value.roundToDouble()) {
          return (quantity: up(value * 1000), unit: 'г');
        }
        return (quantity: up(value ?? 1), unit: 'кг');
      case 'l':
        if (value != null && value != value.roundToDouble()) {
          return (quantity: up(value * 1000), unit: 'мл');
        }
        return (quantity: up(value ?? 1), unit: 'л');
      case 'oz':
        return (quantity: up((value ?? 1) * 28.35), unit: 'г');
      case 'lb':
        return (quantity: up((value ?? 1) * 453.6), unit: 'г');
      case 'pcs':
      case 'slice':
        return (quantity: up(value ?? 1), unit: 'шт');
      case 'can':
      case 'pack':
        return (quantity: up(value ?? 1), unit: 'уп');
      case 'tbsp':
      case 'tsp':
      case 'cup':
      case 'pinch':
      case 'clove':
      case 'bunch':
        return fallback;
      default:
        if (canon == null && value != null) {
          return (quantity: up(value), unit: AddItemDefaults.defaultUnit);
        }
        return fallback;
    }
  }
}
