import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
import 'package:pora/app/features/families/domain/usecase/create_family.dart';
import 'package:pora/app/features/families/domain/usecase/delete_family.dart';
import 'package:pora/app/features/families/domain/usecase/get_families.dart';
part 'families_store.g.dart';

class FamiliesStore = _FamiliesStoreBase with _$FamiliesStore;

abstract class _FamiliesStoreBase with Store {
  @observable
  ObservableList<FamilyEntity> families = ObservableList<FamilyEntity>();

  @observable
  bool? isLoading;

  @observable
  bool? success;

  @action
  Future<void> getFamilies() async {
    success = null;
    isLoading = true;
    final response = await GetIt.I<GetFamiliesUseCase>().call();
    if (response.isRight) {
      families.clear();
      families.addAll(response.right);
      isLoading = false;
      success = true;
    } else {
      isLoading = false;
      success = false;
    }
  }

  @action
  Future<void> deleteFamily({required String fid}) async {
    await GetIt.I<DeleteFamilyUseCase>().call(familyId: fid);
  }

  @action
  Future<void> createFamily({required String name}) async {
    await GetIt.I<CreateFamilyUseCase>().call(name: name);
  }
}
