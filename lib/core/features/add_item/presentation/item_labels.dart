import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';

/// Подписи для показа полей товара. Хранимые значения (int priority,
/// русские units/sections из [AddItemDefaults]) не меняются — переводится
/// только отображение. Пользовательские значения возвращаются как есть.
extension ItemLabelsX on AppLocalizations {
  /// 1 → Low, 2 → Medium, 3 → High. Вне диапазона прижимаем к краям
  /// (0 — товар без priority в ответе, считаем «низким»).
  String priorityName(int priority) {
    if (priority <= AddItemDefaults.priorityLow) return priorityLow;
    if (priority == AddItemDefaults.priorityMed) return priorityMed;
    return priorityHigh;
  }

  /// Каноническая единица («шт», «кг», …) → локализованная. Свою — как есть.
  String unitName(String unit) {
    final u = unit.trim();
    return switch (u) {
      'шт' => unitPcs,
      'г' => unitG,
      'кг' => unitKg,
      'мл' => unitMl,
      'л' => unitL,
      'уп' => unitPack,
      _ => u,
    };
  }

  /// Каноническая секция («Молочное», серверное «Прочее», …) →
  /// локализованная. Свою — как есть.
  String sectionName(String section) {
    final s = section.trim();
    return switch (s) {
      'Овощи и фрукты' => sectionProduce,
      'Молочное' => sectionDairy,
      'Бакалея' => sectionPantry,
      'Напитки' => sectionDrinks,
      'Хлеб' => sectionBread,
      'Разное' => sectionMisc,
      AddItemDefaults.othersSection => sectionOther,
      _ => s,
    };
  }

  /// «1 шт» → «1 pcs»; пустая единица — только число.
  String quantityWithUnit(int quantity, String unit) {
    final u = unitName(unit);
    return u.isEmpty ? '$quantity' : '$quantity $u';
  }
}
