import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/families/domain/usecase/create_family.dart';
import 'package:pora/core/features/lists/domain/usecase/create_list.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/recipe_creator.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/core/features/recipe/domain/usecase/parse_recipe_from_url.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/features/recipe/domain/recipe_import_failure.dart';
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
    final watch = Stopwatch()..start();
    final result = await GetIt.I<ParseRecipeFromUrlUseCase>().call(
      url: url,
      languageCode: languageCode,
    );
    isLoading = false;
    final host = Uri.tryParse(url.trim())?.host ?? '';
    if (result.isLeft) {
      recipe = null;
      rows = ObservableList<RecipeRow>();
      selected = ObservableSet<int>();
      errorMessage = result.left.message;
      AnalyticsService.instance.logRecipeImportFailed(
        reason: _failureReason(result.left),
        host: host,
        durationMs: watch.elapsedMilliseconds,
      );
      return;
    }

    recipe = result.right;
    AnalyticsService.instance.logRecipeImport(
      source: host.contains('youtu') ? 'youtube' : 'web',
      extractor: result.right.extractor,
      host: host,
      ingredients: result.right.ingredients.length,
      durationMs: watch.elapsedMilliseconds,
    );
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
    final picked = [
      for (var i = 0; i < rows.length; i++)
        if (selected.contains(i)) rows[i].ingredient,
    ];
    return RecipeCreator.addIngredients(picked, lid);
  }

  static String _failureReason(Failure failure) {
    if (failure is RecipeImportFailure) return failure.kind.name;
    if (failure.isConnectivity) return 'network';
    return failure.runtimeType.toString();
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
    final errs = await RecipeCreator.addIngredients(r.ingredients, targetLid);
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

    // 3. create-list сразу отдаёт id; GroupsStore обновится по WS-событию.
    final newLid = listRes.right;

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

    final newLid = createRes.right;

    // Добавляем все ингредиенты.
    await RecipeCreator.addIngredients(r.ingredients, newLid);

    isLoading = false;
    return newLid;
  }
}
