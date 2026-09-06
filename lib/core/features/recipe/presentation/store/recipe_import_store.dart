import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/families/domain/usecase/create_family.dart';
import 'package:pora/core/features/groups/presentation/store/groups_store.dart';
import 'package:pora/core/features/item_detail/domain/usecase/add_item.dart';
import 'package:pora/core/features/lists/domain/usecase/create_list.dart';
import 'package:pora/core/features/user/domain/usecase/user/get_user.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/usecase/parse_recipe_from_url.dart';
part 'recipe_import_store.g.dart';

class RecipeImportStore = _RecipeImportStoreBase with _$RecipeImportStore;

/// Строка UI: ингредиент + возможный найденный дубль.
class RecipeRow {
  final RecipeIngredient ingredient;

  RecipeRow({required this.ingredient});
}

abstract class _RecipeImportStoreBase with Store {
  _RecipeImportStoreBase({required this.lid}) : fid = null;

  final String lid;
  final String? fid;

  @observable
  String url = '';

  @observable
  RecipeEntity? recipe;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  ObservableList<RecipeRow> rows = ObservableList<RecipeRow>();

  @observable
  ObservableSet<int> selected = ObservableSet<int>();

  @computed
  int get selectedCount => selected.length;

  @action
  void setUrl(String value) => url = value;

  @action
  void toggle(int index) {
    if (selected.contains(index)) {
      selected.remove(index);
    } else {
      selected.add(index);
    }
  }

  @action
  Future<void> parse({String languageCode = 'ru'}) async {
    if (url.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    final result = await GetIt.I<ParseRecipeFromUrlUseCase>().call(
      url: url,
      languageCode: languageCode,
    );
    isLoading = false;
    if (result.isLeft) {
      recipe = null;
      rows = ObservableList<RecipeRow>();
      selected = ObservableSet<int>();
      errorMessage = result.left.message;
      return;
    }

    recipe = result.right;
    rows = ObservableList<RecipeRow>.of(
      result.right.ingredients.map(
        (ingredient) => RecipeRow(ingredient: ingredient),
      ),
    );
    selected = ObservableSet<int>.of(List<int>.generate(rows.length, (i) => i));
  }

  /// Возвращает список ошибок (может быть пустым).
  @action
  Future<List<String>> addSelected() async {
    final errs = <String>[];
    final addUC = GetIt.I<AddItemUseCase>();

    for (var i = 0; i < rows.length; i++) {
      if (!selected.contains(i)) continue;
      final ing = rows[i].ingredient;
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

  int _parseQty(String? raw) {
    if (raw == null) return 1;
    final match = RegExp(r'\d+').firstMatch(raw);
    return int.tryParse(match?.group(0) ?? '') ?? 1;
  }

  @action
  void reset() {
    recipe = null;
    rows = ObservableList<RecipeRow>();
    selected = ObservableSet<int>();
    errorMessage = null;
    url = '';
  }

  /// Заливает все ингредиенты рецепта в готовый список [targetLid].
  /// Используется когда пользователь выбрал существующий список (не создаёт новый).
  /// Возвращает список ошибок (пустой = OK).
  @action
  Future<List<String>> addRecipeToExistingList(String targetLid) async {
    final r = recipe;
    if (r == null || r.ingredients.isEmpty) return const [];
    isLoading = true;
    final errs = <String>[];
    final addUC = GetIt.I<AddItemUseCase>();
    for (final ing in r.ingredients) {
      final res = await addUC.call(
        listId: targetLid,
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
    isLoading = false;
    return errs;
  }

  /// Создаёт общую группу (family+list) с именем рецепта и заливает
  /// в лист все ингредиенты. Возвращает `lid` или `null`.
  @action
  Future<String?> createSharedGroupFromRecipe() async {
    final r = recipe;
    if (r == null || r.ingredients.isEmpty) return null;
    isLoading = true;
    errorMessage = null;

    // 1. createFamily.
    final famRes = await GetIt.I<CreateFamilyUseCase>().call(name: r.title);
    if (famRes.isLeft) {
      isLoading = false;
      errorMessage = famRes.left.message;
      return null;
    }
    String? fid;
    try {
      final decoded = jsonDecode(famRes.right) as Map<String, dynamic>;
      fid = decoded['id'] as String?;
    } catch (_) {}
    if (fid == null) {
      isLoading = false;
      errorMessage = 'Family id missing';
      return null;
    }

    // 2. createList(name, fid).
    final listRes = await GetIt.I<CreateListUseCase>().call(
      name: r.title,
      fid: fid,
    );
    if (listRes.isLeft) {
      isLoading = false;
      errorMessage = listRes.left.message;
      return null;
    }

    // 3. Refresh groups + найти созданный лист.
    final groupsStore = GetIt.I<GroupsStore>();
    await groupsStore.load();
    String? newLid;
    for (final g in groupsStore.groups) {
      if (g.familyId == fid && g.list.name == r.title) {
        newLid = g.list.id;
        break;
      }
    }
    if (newLid == null) {
      isLoading = false;
      errorMessage = 'List id lookup failed';
      return null;
    }

    // 4. Добавляем ингредиенты.
    final errs = await addRecipeToExistingList(newLid);
    if (errs.isNotEmpty) {
      errorMessage = errs.first;
    }
    isLoading = false;
    return newLid;
  }

  /// Создаёт новый персональный список с именем рецепта и заливает в него
  /// все ингредиенты (без dedup — новый пустой лист).
  /// Возвращает `lid` нового списка или `null` если что-то пошло не так.
  @action
  Future<String?> createListFromRecipe() async {
    final r = recipe;
    if (r == null || r.ingredients.isEmpty) return null;
    isLoading = true;
    errorMessage = null;

    final createRes = await GetIt.I<CreateListUseCase>().call(name: r.title);
    if (createRes.isLeft) {
      isLoading = false;
      errorMessage = createRes.left.message;
      return null;
    }

    // Backend не возвращает lid — берём из /user/me новейший список
    // с матчащимся именем.
    final userRes = await GetIt.I<GetUserUseCase>().call();
    String? newLid;
    if (userRes.isRight) {
      final lists = userRes.right.selfLists ?? const [];
      final matches = lists.where((l) => l.name == r.title).toList();
      if (matches.isNotEmpty) {
        // Берём последний в списке (обычно новый в конце). Если id ISO-like
        // — можно сортировать; для простоты — последний.
        newLid = matches.last.id;
      }
    }

    if (newLid == null) {
      isLoading = false;
      errorMessage = 'List created, but id lookup failed';
      return null;
    }

    // Добавляем все ингредиенты.
    final addUC = GetIt.I<AddItemUseCase>();
    for (final ing in r.ingredients) {
      await addUC.call(
        listId: newLid,
        name: ing.name,
        section: 'Разное',
        quantity: _parseQty(ing.quantity),
        unit: ing.unit ?? '',
        priority: 0,
        urgent: false,
        remindEveryDays: null,
      );
    }

    isLoading = false;
    return newLid;
  }
}
