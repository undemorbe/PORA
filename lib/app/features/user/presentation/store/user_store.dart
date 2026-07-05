import 'package:mobx/mobx.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';
part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  @observable
  UserEntity? user;

  @action
  void setUserInformation({String? name, String? surname, String? image}) {}

  @action
  UserEntity? getUserFromInternet() {
    return user;
  }
}
