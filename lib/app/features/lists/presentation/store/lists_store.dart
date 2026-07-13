import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
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
  bool? isLoading;

  @observable
  bool? isSuccess;

  @observable
  ListsArrayEntity? listsWithPreview;

  @computed
  int get productsAmount {
    int num = 0;
    list?.sections.map((section) {
      num += section.items.length;
    });
    return num;
  }

  @action
  Future<void> getConcreteList({required String lid}) async {
    isSuccess = null;
    isLoading = true;

    final response = await getIt<GetConcreteListUseCase>().call(lid: lid);
    if (response.isRight) {
      isLoading = false;
      isSuccess = true;
      list = response.right;
    } else {
      isLoading = false;
      isSuccess = false;
    }
  }

  @action
  Future<void> getFamilyLists({required String fid}) async {
    isSuccess = null;
    isLoading = true;
    final response = await getIt<GetFamiliesListsUseCase>().call(fid: fid);
    if (response.isRight) {
      isLoading = false;
      isSuccess = true;
      //! Freezed must be added
      listsWithPreview = response.right;
    } else {
      isLoading = false;
      isSuccess = false;
    }
  }

  @action
  Future<void> deleteList({required String lid}) async {
    final response = await getIt<DeleteListUseCase>().call(lid: lid);
    if (response.isRight) {
      isLoading = false;
      isSuccess = true;
    } else {
      isLoading = false;
      isSuccess = false;
    }
  }

  @action
  Future<void> createList({required String name, String? fid}) async {
    final response = await getIt<CreateListUseCase>().call(
      name: name,
      fid: fid,
    );
    if (response.isRight) {
      isLoading = false;
      isSuccess = true;
    } else {
      isLoading = false;
      isSuccess = false;
    }
  }
}
