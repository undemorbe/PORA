import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists_array.dart';
import 'package:pora/app/features/lists/domain/usecase/create_list.dart';
import 'package:pora/app/features/lists/domain/usecase/delete_list.dart';
import 'package:pora/app/features/lists/domain/usecase/get_families_lists.dart';
import 'package:pora/app/features/lists/domain/usecase/get_list_data.dart';
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
        byId.putIfAbsent(p.addedBy.id, () => p.addedBy);
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
      }
    } else {
      isSuccess = false;
      errorMessage = response.left.message;
    }
  }
}

class _RemovedList extends ListsArrayEntity {
  const _RemovedList(List<ListEntity> lists) : super(lists: lists);
}

class _FilteredSection extends ListSectionEntity {
  const _FilteredSection({required super.name, required super.items});
}
