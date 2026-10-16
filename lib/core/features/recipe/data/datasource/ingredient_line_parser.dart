import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/recipe_units.dart';

/// Разбирает одну строку ингредиента («2 ст. ложки сахара», «Мука — 200 г»,
/// «1½ cups flour, sifted», «1 (14 oz) can tomatoes») в [RecipeIngredient]
/// с канонической единицей ([RecipeUnits]).
///
/// Чистая функция без I/O — покрыта unit-тестами.
abstract final class IngredientLineParser {
  static final String _num =
      '(?:\\d+\\s+\\d+\\s*/\\s*\\d+'
      '|\\d+\\s*/\\s*\\d+'
      '|\\d+\\s*[${RecipeUnits.fractionChars}]'
      '|\\d+(?:[.,]\\d+)?'
      '|[${RecipeUnits.fractionChars}])';

  static final String _qty = '$_num(?:\\s*(?:[-–—]|to|до)\\s*$_num)?';

  /// Единица должна заканчиваться на границе слова: иначе «г» съест
  /// начало слова «горсть».
  static final String _unit = '(?:${RecipeUnits.pattern})\\.?(?![\\p{L}])';

  static final RegExp _prefix = RegExp(
    '^(?<qty>$_qty)\\s*(?:(?<unit>$_unit)\\s*)?(?:of\\s+)?(?<name>\\S.*)\$',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _suffix = RegExp(
    '^(?<name>.*?\\S)\\s*(?:[-–—:,]\\s*|\\s+)'
    '(?<qty>$_qty)\\s*(?:(?<unit>$_unit))?\\s*\$',
    caseSensitive: false,
    unicode: true,
  );

  /// «Соль — щепотка», «Зелень: пучок».
  static final RegExp _suffixUnitOnly = RegExp(
    '^(?<name>.*?\\S)\\s*[-–—:,]\\s*(?<unit>$_unit)\\s*\$',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _amountOnly = RegExp(
    '^(?<qty>$_qty)\\s*(?<unit>$_unit)?\\s*\$',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _taste = RegExp(
    r'(?:^|[\s,;(—–-])'
    r'(по вкусу|по желанию|для подачи|для украшения|опционально|'
    r'to taste|optional|as needed|for serving|for garnish)'
    r'(?=$|[\s,;).])',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _parens = RegExp(r'\(([^()]*)\)|\[([^\[\]]*)\]');

  /// Сноски рецепта: «Note 1», «примечание 2», «*».
  static final RegExp _footnote = RegExp(
    r'^(?:note|notes|примечание|прим|см\.?\s*примечание)\s*\d*\.?$|^\*+$',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _heading = RegExp(
    r'^(?:ингредиенты|продукты|состав|ingredients?)(?:$|[\s(:])',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _bullet = RegExp(r'^[\s•·*▢□☐✓✔▪◦●○‣⁃>-]+');

  /// Подготовительные действия после запятой — уходят в note:
  /// «flour, sifted», «лук, мелко нарезанный».
  static final RegExp _prepNote = RegExp(
    r'^(?:finely |roughly |thinly |freshly |coarsely |lightly )?'
    r'(?:chopped|diced|minced|sliced|grated|peeled|softened|melted|beaten|'
    r'crushed|cubed|shredded|sifted|divided|drained|rinsed|room temperature|'
    r'at room temperature|cut|halved|quartered|plus more|or more|'
    r'мелко|крупно|тонко|нарезан|натёрт|натерт|измельч|очищен|размягч|'
    r'растоплен|комнатной температуры|порезан|без косточ|без кожи)',
    caseSensitive: false,
    unicode: true,
  );

  static String clean(String value) => value
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u202F', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static RecipeIngredient parse(String raw) {
    final original = clean(raw);
    var line = original.replaceFirst(_bullet, '').trim();
    final notes = <String>[];

    // 1. Скобки: «(about 200 g)», «(14 oz)». Если в основной части нет
    //    количества — используем количество из скобок.
    String? parenAmount;
    // Вложенные скобки «((~250g/8oz each) (Note 1))» — снимаем изнутри.
    for (var guard = 0; guard < 4 && _parens.hasMatch(line); guard++) {
      line = line.replaceAllMapped(_parens, (m) {
        final inner = clean(m[1] ?? m[2] ?? '');
        if (inner.isEmpty || _footnote.hasMatch(inner)) return ' ';
        if (_amountOnly.hasMatch(inner)) {
          parenAmount ??= inner;
        } else {
          notes.add(inner);
        }
        return ' ';
      });
    }
    line = clean(line);

    // 2. «по вкусу» / «to taste».
    final taste = _taste.firstMatch(line);
    if (taste != null) {
      notes.add(taste[1]!.toLowerCase());
      line = clean(
        line.replaceRange(taste.start, taste.end, ' '),
      ).replaceAll(RegExp(r'[\s,;:—–-]+$'), '');
    }

    String? quantity;
    String? unit;
    var name = line;

    final prefix = _prefix.firstMatch(line);
    final suffix = prefix == null ? _suffix.firstMatch(line) : null;
    final unitOnly = prefix == null && suffix == null
        ? _suffixUnitOnly.firstMatch(line)
        : null;

    if (prefix != null) {
      quantity = prefix.namedGroup('qty');
      unit = prefix.namedGroup('unit');
      name = prefix.namedGroup('name')!;
    } else if (suffix != null) {
      quantity = suffix.namedGroup('qty');
      unit = suffix.namedGroup('unit');
      name = suffix.namedGroup('name')!;
    } else if (unitOnly != null) {
      unit = unitOnly.namedGroup('unit');
      name = unitOnly.namedGroup('name')!;
    }

    if (quantity == null && parenAmount != null) {
      final m = _amountOnly.firstMatch(parenAmount!)!;
      quantity = m.namedGroup('qty');
      unit = m.namedGroup('unit');
    } else if (parenAmount != null) {
      notes.add(parenAmount!);
    }

    name = _cleanName(name, notes);
    if (name.isEmpty) {
      name = _cleanName(line, notes);
      if (name.isEmpty) name = original;
      quantity = null;
      unit = null;
    }

    return RecipeIngredient(
      name: name,
      quantity: quantity == null
          ? null
          : RecipeUnits.normalizeQuantity(quantity),
      unit: RecipeUnits.canonical(unit),
      note: notes.isEmpty ? null : notes.join('; '),
      raw: original,
    );
  }

  static String _cleanName(String value, List<String> notes) {
    var name = clean(value)
        .replaceFirst(RegExp(r'^(?:of|из|для)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'^[\s,;:—–-]+|[\s,;:—–-]+$'), '');

    final comma = name.indexOf(',');
    if (comma > 0) {
      final tail = name.substring(comma + 1).trim();
      if (_prepNote.hasMatch(tail)) {
        notes.add(tail);
        name = name.substring(0, comma).trim();
      }
    }
    return name.replaceAll(RegExp(r'[\s,;:—–.-]+$'), '').trim();
  }

  /// Похожа ли строка на ингредиент.
  ///
  /// [strict] — для свободного текста страницы: требуем количество или
  /// «по вкусу». Для элементов из явного ingredient-контейнера (`li` внутри
  /// `.ingredients`) достаточно короткой строки — «Соль», «Перец».
  static bool looksLikeIngredient(String value, {bool strict = true}) {
    final cleaned = clean(value);
    if (cleaned.length < 2 || cleaned.length > 200) return false;

    final lower = cleaned.toLowerCase().replaceAll(RegExp(r'[:.]$'), '');
    const ignored = {
      'ingredients',
      'ingredient',
      'ингредиенты',
      'продукты',
      'состав',
      'для теста',
      'для соуса',
      'для начинки',
      'для крема',
      'for the sauce',
      'for the dough',
      'for the filling',
      'print',
      'pin',
      'jump to recipe',
      'show more',
    };
    if (ignored.contains(lower)) return false;
    if (_heading.hasMatch(lower) &&
        !RegExp(r'^\S+\s*[-–—:]\s*\d').hasMatch(lower)) {
      return false;
    }
    // Таймкоды и шаги приготовления.
    if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(cleaned)) return false;
    if (RegExp(r'^(?:шаг|step)\s*\d', caseSensitive: false).hasMatch(cleaned)) {
      return false;
    }

    if (RegExp(r'\d|[½⅓⅔¼¾⅛]').hasMatch(cleaned)) return true;
    if (_taste.hasMatch(' $lower')) return true;
    if (strict) return false;

    // Нестрого: короткое название без предложений.
    final words = cleaned.split(' ').length;
    return words <= 8 && !RegExp(r'[.!?]\s').hasMatch(cleaned);
  }
}
