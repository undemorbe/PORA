import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:pora/core/features/families/domain/usecase/create_family.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/features/item_detail/domain/usecase/add_item.dart';
import 'package:pora/core/features/lists/domain/usecase/create_list.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/user/domain/usecase/user/get_user.dart';

/// Универсальный executor рецепт-таргетинга. Один код для recipe_import_screen
/// и для chat message (когда AI вернул `<recipe>` тег).
class RecipeCreator {
  const RecipeCreator._();

  /// Создаёт общую группу с именем рецепта, добавляет все ингредиенты.
  /// Возвращает lid или null.
  static Future<String?> createShared(RecipeEntity recipe) async {
    if (recipe.ingredients.isEmpty) return null;
    final famRes =
        await GetIt.I<CreateFamilyUseCase>().call(name: recipe.title);
    if (famRes.isLeft) return null;
    String? fid;
    try {
      fid = (jsonDecode(famRes.right) as Map<String, dynamic>)['id']
          as String?;
    } catch (_) {}
    if (fid == null) return null;

    final listRes = await GetIt.I<CreateListUseCase>()
        .call(name: recipe.title, fid: fid);
    if (listRes.isLeft) return null;

    final groups = GetIt.I<GroupsStore>();
    await groups.load();
    String? lid;
    for (final g in groups.groups) {
      if (g.familyId == fid && g.list.name == recipe.title) {
        lid = g.list.id;
        break;
      }
    }
    if (lid == null) return null;
    await _addAll(recipe, lid);
    return lid;
  }

  /// Создаёт личный список + заливает ингредиенты.
  static Future<String?> createPersonal(RecipeEntity recipe) async {
    if (recipe.ingredients.isEmpty) return null;
    final res = await GetIt.I<CreateListUseCase>().call(name: recipe.title);
    if (res.isLeft) return null;

    final userRes = await GetIt.I<GetUserUseCase>().call();
    if (userRes.isLeft) return null;
    final matches = (userRes.right.selfLists ?? const [])
        .where((l) => l.name == recipe.title)
        .toList();
    if (matches.isEmpty) return null;
    final lid = matches.last.id;
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

  static Future<List<String>> _addAll(RecipeEntity recipe, String lid) async {
    final errs = <String>[];
    final addUC = GetIt.I<AddItemUseCase>();
    for (final ing in recipe.ingredients) {
      final res = await addUC.call(
        listId: lid,
        name: ing.name,
        section: 'Разное',
        quantity: _parseQty(ing.quantity),
        unit: ing.unit ?? '',
        priority: 0,
        urgent: false,
        remindEveryDays: null,
      );
      if (res.isLeft) errs.add(res.left.message);
    }
    return errs;
  }

  static int _parseQty(String? raw) {
    if (raw == null) return 1;
    final m = RegExp(r'\d+').firstMatch(raw);
    return int.tryParse(m?.group(0) ?? '') ?? 1;
  }
}
