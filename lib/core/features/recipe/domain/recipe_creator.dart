import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:pora/core/features/families/domain/usecase/create_family.dart';
import 'package:pora/core/features/item_detail/domain/usecase/add_item.dart';
import 'package:pora/core/features/lists/domain/usecase/create_list.dart';
import 'package:pora/core/features/add_item/domain/add_item_defaults.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/recipe_units.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';

/// Универсальный executor рецепт-таргетинга. Один код для recipe_import_screen
/// и для chat message (когда AI вернул `<recipe>` тег).
class RecipeCreator {
  const RecipeCreator._();

  /// Создаёт общую группу с именем рецепта, добавляет все ингредиенты.
  /// Возвращает lid или null.
  static Future<String?> createShared(RecipeEntity recipe) async {
    if (recipe.ingredients.isEmpty) return null;
    final famRes = await GetIt.I<CreateFamilyUseCase>().call(
      name: recipe.title,
    );
    if (famRes.isLeft) return null;
    String? fid;
    try {
      fid = (jsonDecode(famRes.right) as Map<String, dynamic>)['id'] as String?;
    } catch (_) {}
    if (fid == null) return null;

    final listRes = await GetIt.I<CreateListUseCase>().call(
      name: recipe.title,
      fid: fid,
    );
    if (listRes.isLeft) return null;

    // create-list сразу отдаёт id; GroupsStore обновится по WS-событию семьи.
    final lid = listRes.right;
    await _addAll(recipe, lid);
    return lid;
  }

  /// Создаёт личный список + заливает ингредиенты.
  static Future<String?> createPersonal(RecipeEntity recipe) async {
    if (recipe.ingredients.isEmpty) return null;
    final res = await GetIt.I<CreateListUseCase>().call(name: recipe.title);
    if (res.isLeft) return null;

    final lid = res.right;
    await _addAll(recipe, lid);
    return lid;
  }

  /// Заливает ингредиенты в существующий список.
  /// Возвращает список ошибок (пустой = OK).
  static Future<List<String>> addToExisting(
    RecipeEntity recipe,
    String lid,
  ) async {
    return _addAll(recipe, lid);
  }

  static Future<List<String>> _addAll(RecipeEntity recipe, String lid) =>
      addIngredients(recipe.ingredients, lid);

  /// Добавляет ингредиенты в список [lid]: количество и единица переводятся
  /// в единицы списка покупок ([RecipeUnits.toShopping]) — «0.5 кг» станет
  /// «500 г», «2 ст. л.» — «1 шт». Возвращает ошибки (пустой = OK).
  static Future<List<String>> addIngredients(
    Iterable<RecipeIngredient> ingredients,
    String lid,
  ) async {
    final errs = <String>[];
    final addUC = GetIt.I<AddItemUseCase>();
    for (final ing in ingredients) {
      final shopping = RecipeUnits.toShopping(ing.quantity, ing.unit);
      final res = await addUC.call(
        listId: lid,
        name: ing.name,
        section: AddItemDefaults.defaultSection,
        quantity: shopping.quantity,
        unit: shopping.unit,
        priority: 0,
        urgent: false,
        remindEveryDays: null,
      );
      if (res.isLeft) errs.add(res.left.message);
    }
    if (ingredients.isNotEmpty) {
      AnalyticsService.instance.logRecipeItemsAdded(
        count: ingredients.length,
        failed: errs.length,
      );
    }
    return errs;
  }
}
