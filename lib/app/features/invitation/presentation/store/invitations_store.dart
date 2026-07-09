import 'package:mobx/mobx.dart';
import 'package:pora/app/features/invitation/domain/entity/link_code.dart';
import 'package:pora/app/internal/di/export.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';
import 'package:pora/app/internal/share/share_conf.dart';
part 'invitations_store.g.dart';

class InvitationsStore = _InvitationsStoreBase with _$InvitationsStore;

abstract class _InvitationsStoreBase with Store {
  //! Connect to
  @observable
  bool? isLoading;

  @observable
  bool? isSuccess;

  @observable
  String? linkCode;

  Future<Either<Failure, Success>> connectToFamily({
    required String code,
  }) async {
    isLoading == true;
    isSuccess == null;
    final result = await GetIt.I<ConnectWithInviteCodeUseCase>().call(
      code: code,
    );
    if (result.isRight) {
      isSuccess == true;
      isLoading == false;
      return Right(result.right);
    } else {
      isSuccess == false;
      isLoading == false;
      return Left(result.left);
    }
  }

  //! Connect someone
  @observable
  LinkCodeEntity? linkCodes;

  @action
  Future<Either<Failure, LinkCodeEntity>> generateLinkCode({
    required String familyId,
  }) async {
    isSuccess == null;
    isLoading == true;
    final linkCode = await GetIt.I<GetInviteCodeUseCase>().call(
      familyId: familyId,
    );
    if (linkCode.isRight) {
      isSuccess == true;
      isLoading == false;
      return Right(linkCode.right);
    } else {
      isSuccess == false;
      isLoading == false;
      return Left(linkCode.left);
    }
  }

  @action
  Future<void> shareLinkCode({required String linkCode}) async {
    try {
      await GetIt.I<SharingRepository>().shareUri(uri: linkCode);
    } catch (e) {
      await GetIt.I<SharingRepository>().shareText(text: linkCode);
    }
  }
}
