import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/recipe/data/datasource/ingredient_line_parser.dart';
import 'package:pora/core/features/recipe/domain/recipe_units.dart';

void main() {
  group('IngredientLineParser.parse', () {
    void expectLine(
      String line, {
      required String name,
      String? quantity,
      String? unit,
      String? note,
    }) {
      final r = IngredientLineParser.parse(line);
      expect(r.name, name, reason: 'name of "$line"');
      expect(r.quantity, quantity, reason: 'quantity of "$line"');
      expect(r.unit, unit, reason: 'unit of "$line"');
      if (note != null) expect(r.note, note, reason: 'note of "$line"');
      expect(r.raw, isNotEmpty);
    }

    test('russian prefix with full unit word', () {
      expectLine(
        '2 ст. ложки сахара',
        name: 'сахара',
        quantity: '2',
        unit: 'tbsp',
      );
      expectLine(
        '3 зубчика чеснока',
        name: 'чеснока',
        quantity: '3',
        unit: 'clove',
      );
      expectLine('200г муки', name: 'муки', quantity: '200', unit: 'g');
      expectLine('1 ч.л. соли', name: 'соли', quantity: '1', unit: 'tsp');
    });

    test('russian suffix forms (russianfood/povar style)', () {
      expectLine('Мука - 200 г', name: 'Мука', quantity: '200', unit: 'g');
      expectLine(
        'Капуста белокочанная — 1,2 кг',
        name: 'Капуста белокочанная',
        quantity: '1,2',
        unit: 'kg',
      );
      expectLine('Яйца 2 шт.', name: 'Яйца', quantity: '2', unit: 'pcs');
      expectLine(
        'Соль - 1/2 ч. ложки (по вкусу)',
        name: 'Соль',
        quantity: '1/2',
        unit: 'tsp',
        note: 'по вкусу',
      );
      expectLine('Молоко: 500 мл', name: 'Молоко', quantity: '500', unit: 'ml');
    });

    test('unit is not eaten from the start of a word', () {
      expectLine('2 горсти орехов', name: 'горсти орехов', quantity: '2');
      expectLine('1 лимон', name: 'лимон', quantity: '1');
      expectLine('2 large eggs', name: 'large eggs', quantity: '2');
    });

    test('taste markers become notes', () {
      expectLine('Соль - по вкусу', name: 'Соль', note: 'по вкусу');
      expectLine('Black pepper, to taste', name: 'Black pepper');
      expectLine('Перец — щепотка', name: 'Перец', unit: 'pinch');
    });

    test('english fractions, mixed numbers and ranges', () {
      expectLine(
        '1½ cups flour, sifted',
        name: 'flour',
        quantity: '1 1/2',
        unit: 'cup',
        note: 'sifted',
      );
      expectLine(
        '1 1/2 tablespoons olive oil',
        name: 'olive oil',
        quantity: '1 1/2',
        unit: 'tbsp',
      );
      expectLine('½ tsp salt', name: 'salt', quantity: '1/2', unit: 'tsp');
      expectLine(
        '2-3 зубчика чеснока',
        name: 'чеснока',
        quantity: '2-3',
        unit: 'clove',
      );
      expectLine(
        '2 to 3 cups of milk',
        name: 'milk',
        quantity: '2-3',
        unit: 'cup',
      );
    });

    test('parentheses: amount fallback and notes', () {
      expectLine(
        '1 (14 oz) can diced tomatoes',
        name: 'diced tomatoes',
        quantity: '1',
        unit: 'can',
        note: '14 oz',
      );
      expectLine('Мука (200 г)', name: 'Мука', quantity: '200', unit: 'g');
      expectLine(
        'Сахар 1 стакан (200 г)',
        name: 'Сахар',
        quantity: '1',
        unit: 'cup',
      );
    });

    test('bullets and nbsp are stripped', () {
      expectLine('▢ 2 eggs', name: 'eggs', quantity: '2');
      expectLine('• Мука – 200 г', name: 'Мука', quantity: '200', unit: 'g');
    });

    test('lines without amount keep whole text as name', () {
      expectLine('Масло 82%', name: 'Масло 82%');
      expectLine('Свежий укроп', name: 'Свежий укроп');
    });
  });

  group('IngredientLineParser.looksLikeIngredient', () {
    test('strict mode requires amount or taste marker', () {
      expect(IngredientLineParser.looksLikeIngredient('200 г муки'), isTrue);
      expect(IngredientLineParser.looksLikeIngredient('Соль по вкусу'), isTrue);
      expect(IngredientLineParser.looksLikeIngredient('Соль'), isFalse);
    });

    test('relaxed mode accepts short names, rejects headings and steps', () {
      bool relaxed(String v) =>
          IngredientLineParser.looksLikeIngredient(v, strict: false);
      expect(relaxed('Соль'), isTrue);
      expect(relaxed('Ингредиенты'), isFalse);
      expect(relaxed('Для теста:'), isFalse);
      expect(relaxed('0:45 нарезаем лук'), isFalse);
      expect(relaxed('Шаг 1'), isFalse);
      expect(
        relaxed('Смешайте муку с сахаром. Добавьте яйца и хорошо взбейте.'),
        isFalse,
      );
    });
  });

  group('RecipeUnits', () {
    test('canonical and localize', () {
      expect(RecipeUnits.canonical('ст. л.'), 'tbsp');
      expect(RecipeUnits.canonical('Tablespoons'), 'tbsp');
      expect(RecipeUnits.canonical('граммов'), 'g');
      expect(RecipeUnits.canonical('банан'), isNull);
      expect(RecipeUnits.localize('tbsp', 'ru'), 'ст. л.');
      expect(RecipeUnits.localize('pcs', 'ru'), 'шт');
      expect(RecipeUnits.localize('шт', 'en'), 'pcs');
      expect(RecipeUnits.localize('handful', 'en'), 'handful');
      // Локализованный вывод снова канонизируется (идемпотентность).
      expect(RecipeUnits.canonical(RecipeUnits.localize('tsp', 'ru')), 'tsp');
    });

    test('parseQuantity', () {
      expect(RecipeUnits.parseQuantity('1,5'), 1.5);
      expect(RecipeUnits.parseQuantity('1 1/2'), 1.5);
      expect(RecipeUnits.parseQuantity('½'), 0.5);
      expect(RecipeUnits.parseQuantity('2-3'), 3);
      expect(RecipeUnits.parseQuantity('2 – 3'), 3);
      expect(RecipeUnits.parseQuantity(null), isNull);
      expect(RecipeUnits.parseQuantity('1/0'), isNull);
    });

    test('toShopping converts to list units', () {
      expect(RecipeUnits.toShopping('0.5', 'kg'), (quantity: 500, unit: 'г'));
      expect(RecipeUnits.toShopping('1,5', 'л'), (quantity: 1500, unit: 'мл'));
      expect(RecipeUnits.toShopping('2', 'kg'), (quantity: 2, unit: 'кг'));
      expect(RecipeUnits.toShopping('2', 'tbsp'), (quantity: 1, unit: 'шт'));
      expect(RecipeUnits.toShopping('2-3', 'шт'), (quantity: 3, unit: 'шт'));
      expect(RecipeUnits.toShopping('1', 'банка'), (quantity: 1, unit: 'уп'));
      expect(RecipeUnits.toShopping('2.5', null), (quantity: 3, unit: 'шт'));
      expect(RecipeUnits.toShopping(null, null), (quantity: 1, unit: 'шт'));
      expect(RecipeUnits.toShopping('8', 'oz'), (quantity: 227, unit: 'г'));
    });
  });
}
