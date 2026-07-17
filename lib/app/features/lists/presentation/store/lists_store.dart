import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/usecase/create_list.dart';
import 'package:pora/app/features/lists/domain/usecase/delete_list.dart';
import 'package:pora/app/features/lists/domain/usecase/get_families_lists.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/domain/usecase/get_list_data.dart';
import 'package:pora/app/features/item_detail/domain/usecase/delete_item.dart';
import 'package:pora/app/features/item_detail/domain/usecase/mark_item_bought.dart';
import 'package:pora/app/features/user/domain/usecase/user/get_user.dart';
part 'lists_store.g.dart';

class ListStore = _ListStoreBase with _$ListStore;

abstract class _ListStoreBase with Store {
  final getIt = GetIt.I;

  @observable
  ListEntity? list;

  @observable
  bool isLoading = false;

  @observable
  bool? isSuccess;

  @observable
  String? errorMessage;

  @observable
  ListsArrayEntity? listsWithPreview;

  /// Локальный поиск по продуктам concrete list.
  @observable
  String query = '';

  @computed
  int get productsAmount {
    final sections = list?.sections;
    if (sections == null) return 0;
    return sections.fold<int>(0, (acc, s) => acc + s.items.length);
  }

  /// Секции с продуктами, отфильтрованными по [query]. Пустые секции
  /// после фильтра выпадают.
  @computed
  List<ListSectionEntity> get filteredSections {
    final sections = list?.sections ?? const <ListSectionEntity>[];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sections;
    final result = <ListSectionEntity>[];
    for (final s in sections) {
      final items = s.items
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
      if (items.isEmpty) continue;
      result.add(_FilteredSection(name: s.name, items: items));
    }
    return result;
  }

  /// Уникальные участники, засветившиеся в текущем list (сборка из
  /// `product.addedBy`). Fallback для случая когда members не пришли
  /// аргументом (deeplink).
  @computed
  List<MemberEntity> get derivedMembers {
    final sections = list?.sections;
    if (sections == null) return const [];
    final byId = <String, MemberEntity>{};
    for (final s in sections) {
      for (final p in s.items) {
        final by = p.addedBy;
        if (by == null) continue;
        byId.putIfAbsent(by.id, () => by);
      }
    }
    return byId.values.toList();
  }

  @action
  void setQuery(String value) => query = value;

  @action
  void clearQuery() => query = '';

  @action
  Future<void> getConcreteList({required String lid}) async {
    isSuccess = null;
    errorMessage = null;
    isLoading = true;

    final response = await getIt<GetConcreteListUseCase>().call(lid: lid);
    isLoading = false;
    if (response.isRight) {
      isSuccess = true;
      list = response.right;
    } else {
      isSuccess = false;
      errorMessage = response.left.message;
    }
  }

  @action
  Future<void> getFamilyLists({required String fid}) async {
    isSuccess = null;
    errorMessage = null;
    isLoading = true;
    final response = await getIt<GetFamiliesListsUseCase>().call(fid: fid);
    isLoading = false;
    if (response.isRight) {
      isSuccess = true;
      listsWithPreview = response.right;
    } else {
      isSuccess = false;
      errorMessage = response.left.message;
    }
  }

  @action
  Future<bool> toggleItemBought({required String itemId}) async {
    final cur = list;
    if (cur == null) return false;
    ProductEntity? found;
    for (final s in cur.sections) {
      for (final p in s.items) {
        if (p.id == itemId) {
          found = p;
          break;
        }
      }
      if (found != null) break;
    }
    if (found == null) return false;
    final target = !found.checked;
    _patchItem(itemId, checked: target);
    final res = await getIt<MarkItemBoughtUseCase>().call(
      itemId: itemId,
      checked: target,
    );
    if (res.isRight) return true;
    _patchItem(itemId, checked: !target);
    errorMessage = res.left.message;
    return false;
  }

  void _patchItem(String itemId, {required bool checked}) {
    final cur = list;
    if (cur == null) return;
    final newSections = cur.sections.map((s) {
      final items = s.items.map((p) {
        if (p.id != itemId) return p;
        return _CheckedProduct(p, checked: checked);
      }).toList();
      return _FilteredSection(name: s.name, items: items);
    }).toList();
    list = _ConcreteList(id: cur.id, name: cur.name, sections: newSections);
  }

  @action
  Future<void> deleteItem({required String itemId}) async {
    final res = await getIt<DeleteItemUseCase>().call(itemId: itemId);
    if (res.isRight) {
      // Оптимистично убираем item из loaded list.
      final cur = list;
      if (cur != null) {
        final newSections = cur.sections
            .map(
              (s) => _FilteredSection(
                name: s.name,
                items: s.items.where((p) => p.id != itemId).toList(),
              ),
            )
            .where((s) => s.items.isNotEmpty)
            .toList();
        list = _ConcreteList(id: cur.id, name: cur.name, sections: newSections);
      }
    } else {
      errorMessage = res.left.message;
    }
  }

  @action
  Future<void> deleteList({required String lid}) async {
    final response = await getIt<DeleteListUseCase>().call(lid: lid);
    isLoading = false;
    if (response.isRight) {
      isSuccess = true;
      final current = listsWithPreview;
      if (current != null) {
        listsWithPreview = _RemovedList(
          current.lists.where((l) => l.id != lid).toList(),
        );
      }
    } else {
      isSuccess = false;
      errorMessage = response.left.message;
    }
  }

  @action
  Future<void> createList({required String name, String? fid}) async {
    final response = await getIt<CreateListUseCase>().call(
      name: name,
      fid: fid,
    );
    isLoading = false;
    if (response.isRight) {
      isSuccess = true;
      if (fid != null) {
        await getFamilyLists(fid: fid);
      } else {
        await loadPersonalLists();
      }
    } else {
      isSuccess = false;
      errorMessage = response.left.message;
    }
  }

  /// Личные списки — читаются из `user/me`, не отдельным endpoint.
  @action
  Future<void> loadPersonalLists() async {
    isSuccess = null;
    errorMessage = null;
    isLoading = true;
    final response = await getIt<GetUserUseCase>().call();
    isLoading = false;
    if (response.isRight) {
      isSuccess = true;
      listsWithPreview = _PersonalArray(response.right.selfLists ?? const []);
    } else {
      isSuccess = false;
      errorMessage = response.left.message;
    }
  }
}

class _PersonalArray extends ListsArrayEntity {
  const _PersonalArray(List<ListEntity> lists) : super(lists: lists);
}

class _RemovedList extends ListsArrayEntity {
  const _RemovedList(List<ListEntity> lists) : super(lists: lists);
}

class _FilteredSection extends ListSectionEntity {
  const _FilteredSection({required super.name, required super.items});
}

class _ConcreteList extends ListEntity {
  const _ConcreteList({
    required super.id,
    required super.name,
    required super.sections,
  });
}

class _CheckedProduct extends ProductEntity {
  _CheckedProduct(ProductEntity src, {required bool checked})
    : super(
        name: src.name,
        id: src.id,
        section: src.section,
        quantity: src.quantity,
        unit: src.unit,
        priority: src.priority,
        urgent: src.urgent,
        checked: checked,
        remindEveryDay: src.remindEveryDay,
        addedBy: src.addedBy,
      );
}
