import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/features/add_item/presentation/item_labels.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';

AppLocalizations _l(String code) => lookupAppLocalizations(Locale(code));

void main() {
  group('priorityName', () {
    test('maps 1/2/3 to Low/Medium/High like the add screen', () {
      final l = _l('en');
      expect(l.priorityName(AddItemDefaults.priorityLow), 'Low');
      expect(l.priorityName(AddItemDefaults.priorityMed), 'Medium');
      expect(l.priorityName(AddItemDefaults.priorityHigh), 'High');
    });

    test('clamps out-of-range values', () {
      final l = _l('en');
      expect(l.priorityName(0), 'Low');
      expect(l.priorityName(7), 'High');
    });
  });

  group('unitName', () {
    test('every preset unit is translated for en/de/fr/zh', () {
      for (final code in ['en', 'de', 'fr', 'zh']) {
        final l = _l(code);
        for (final u in AddItemDefaults.units) {
          final label = l.unitName(u);
          expect(label, isNotEmpty, reason: '$code/$u');
          // «г»/«кг»/… — кириллица в нерусском UI = непереведённый пресет.
          expect(
            RegExp('[а-яё]', caseSensitive: false).hasMatch(label),
            isFalse,
            reason: '$code/$u → $label',
          );
        }
      }
    });

    test('ru keeps canonical values, en shows latin abbreviations', () {
      expect(_l('ru').unitName('шт'), 'шт');
      expect(_l('en').unitName('шт'), 'pcs');
      expect(_l('en').unitName('уп'), 'pack');
      expect(_l('de').unitName(' кг '), 'kg');
    });

    test('custom units stay as typed', () {
      expect(_l('en').unitName('bottle'), 'bottle');
      expect(_l('en').unitName('бутылка'), 'бутылка');
      expect(_l('en').unitName(''), '');
    });

    test('quantityWithUnit formats number with localized unit', () {
      expect(_l('en').quantityWithUnit(1, 'шт'), '1 pcs');
      expect(_l('en').quantityWithUnit(3, ''), '3');
      expect(_l('ru').quantityWithUnit(500, 'г'), '500 г');
    });
  });

  group('sectionName', () {
    test('every preset section and server «Прочее» is translated', () {
      final names = [
        for (final (_, name) in AddItemDefaults.sections) name,
        AddItemDefaults.othersSection,
      ];
      for (final code in ['en', 'de', 'fr', 'zh']) {
        final l = _l(code);
        final labels = names.map(l.sectionName).toList();
        for (var i = 0; i < names.length; i++) {
          expect(
            RegExp('[а-яё]', caseSensitive: false).hasMatch(labels[i]),
            isFalse,
            reason: '$code/${names[i]} → ${labels[i]}',
          );
        }
        // «Разное» и «Прочее» — разные секции, подписи не должны совпасть.
        expect(labels.toSet().length, names.length, reason: code);
      }
    });

    test('ru shows canonical names unchanged', () {
      final l = _l('ru');
      for (final (_, name) in AddItemDefaults.sections) {
        expect(l.sectionName(name), name);
      }
      expect(l.sectionName(AddItemDefaults.othersSection), 'Прочее');
    });

    test('en labels and custom passthrough', () {
      final l = _l('en');
      expect(l.sectionName('Молочное'), 'Dairy');
      expect(l.sectionName('Разное'), 'Miscellaneous');
      expect(l.sectionName('Прочее'), 'Other');
      expect(l.sectionName('Snacks'), 'Snacks');
    });
  });

  group('count plurals', () {
    test('en', () {
      final l = _l('en');
      expect(l.productsCount(1), '1 product');
      expect(l.productsCount(0), '0 products');
      expect(l.productsCount(5), '5 products');
      expect(l.listsCount(1), '1 list');
      expect(l.listsCount(2), '2 lists');
      expect(l.peopleCount(1), '1 person');
      expect(l.peopleCount(3), '3 people');
    });

    test('ru', () {
      final l = _l('ru');
      expect(l.productsCount(1), '1 продукт');
      expect(l.productsCount(3), '3 продукта');
      expect(l.productsCount(5), '5 продуктов');
      expect(l.productsCount(21), '21 продукт');
      expect(l.listsCount(2), '2 списка');
      expect(l.listsCount(11), '11 списков');
      expect(l.peopleCount(2), '2 человека');
      expect(l.peopleCount(5), '5 человек');
    });

    test('de/fr/zh', () {
      expect(_l('de').productsCount(1), '1 Produkt');
      expect(_l('de').productsCount(2), '2 Produkte');
      expect(_l('fr').listsCount(1), '1 liste');
      expect(_l('fr').listsCount(4), '4 listes');
      expect(_l('zh').productsCount(1), '1 件商品');
      expect(_l('zh').listsCount(3), '3 个清单');
    });
  });
}
