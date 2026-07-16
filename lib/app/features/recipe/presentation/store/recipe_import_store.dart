import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/item_detail/domain/usecase/add_item.dart';
import 'package:pora/app/features/item_detail/domain/usecase/update_item.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/domain/usecase/get_list_data.dart';
import 'package:pora/app/features/recipe/data/datasource/boyer_moore.dart';
import 'package:pora/app/features/recipe/domain/entity/recipe.dart';
import 'package:pora/app/features/recipe/domain/entity/recipe_ingredient.dart';
import 'package:pora/app/features/recipe/domain/usecase/parse_recipe_from_url.dart';
part 'recipe_import_store.g.dart';

class RecipeImportStore = _RecipeImportStoreBase with _$RecipeImportStore;

/// Строка UI: ингредиент + возможный найденный дубль.
class RecipeRow {
  final RecipeIngredient ingredient;

  /// Совпадение из существующего списка (null — новый продукт).
  final ProductEntity? duplicate;

  RecipeRow({required this.ingredient, this.duplicate});

  bool get hasDuplicate => duplicate != null;
}

abstract class _RecipeImportStoreBase with Store {
  _RecipeImportStoreBase({required this.lid, this.fid});

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

  /// Selected indexes.
  /// Смысл:
  ///  - non-dup строка: checked → добавить в список; unchecked → пропустить.
  ///  - dup строка: checked (default) → пропустить (уже есть);
  ///    unchecked → добавить/увеличить quantity (см. `addSelected`).
  @observable
  ObservableSet<int> selected = ObservableSet<int>();

  ListEntity? _existingList;

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
  Future<void> loadExisting() async {
    final resp = await GetIt.I<GetConcreteListUseCase>().call(lid: lid);
    if (resp.isRight) _existingList = resp.right;
  }

  @action
  Future<void> parse() async {
    if (url.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    // Гарантируем что список актуален для dedup.
    if (_existingList == null) await loadExisting();

    final result = await GetIt.I<ParseRecipeFromUrlUseCase>().call(url: url);
    isLoading = false;
    if (result.isLeft) {
      recipe = null;
      rows = ObservableList<RecipeRow>();
      selected = ObservableSet<int>();
      errorMessage = result.left.message;
      return;
    }

    recipe = result.right;
    rows = ObservableList<RecipeRow>.of(_buildRows(result.right.ingredients));
    // Дефолт selected:
    //  - non-dup checked (добавить),
    //  - dup checked (пропустить — user сам снимет чтобы форсить).
    selected = ObservableSet<int>.of(
      List<int>.generate(rows.length, (i) => i),
    );
  }

  List<RecipeRow> _buildRows(List<RecipeIngredient> ings) {
    final existing = _existingList?.sections
            .expand<ProductEntity>((s) => s.items)
            .toList() ??
        const <ProductEntity>[];
    return ings.map((ing) {
      final dup = _findDuplicate(ing, existing);
      return RecipeRow(ingredient: ing, duplicate: dup);
    }).toList();
  }

  ProductEntity? _findDuplicate(
    RecipeIngredient ing,
    List<ProductEntity> existing,
  ) {
    final needle = _normalize(ing.name);
    if (needle.isEmpty) return null;
    for (final p in existing) {
      final hay = _normalize(p.name);
      // Boyer-Moore либо substring в обе стороны.
      if (boyerMooreContains(hay, needle) ||
          boyerMooreContains(needle, hay)) {
        return p;
      }
    }
    return null;
  }

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Возвращает список ошибок (может быть пустым).
  @action
  Future<List<String>> addSelected() async {
    final errs = <String>[];
    final addUC = GetIt.I<AddItemUseCase>();
    final updateUC = GetIt.I<UpdateItemUseCase>();

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final isChecked = selected.contains(i);

      if (row.hasDuplicate) {
        // dup + checked → пропустить (уже в списке).
        if (isChecked) continue;
        // dup + unchecked → добавить количество к существующему через
        // PUT /items/{iid}.
        final dup = row.duplicate!;
        final section = dup.section.isNotEmpty
            ? dup.section
            : (_sectionForItem(dup) ?? 'Разное');
        final addQty = _parseQty(row.ingredient.quantity);
        final res = await updateUC.call(
          itemId: dup.id,
          name: dup.name,
          section: section,
          quantity: dup.quantity + addQty,
          unit: dup.unit,
          priority: dup.priority,
          urgent: dup.urgent,
          remindEveryDays: null,
        );
        if (res.isLeft) errs.add(res.left.message);
      } else {
        // non-dup: checked → добавить, unchecked → пропустить.
        if (!isChecked) continue;
        final ing = row.ingredient;
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
    }
    return errs;
  }

  String? _sectionForItem(ProductEntity item) {
    final sections = _existingList?.sections;
    if (sections == null) return null;
    for (final s in sections) {
      if (s.items.any((p) => p.id == item.id)) return s.name;
    }
    return null;
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
}

