import 'package:flutter/services.dart';
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

  @action
  Future<void> copyToClipboard(String textToCopy) async {
    await Clipboard.setData(ClipboardData(text: textToCopy));
  }

  Future<void> connectToFamily({
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
    } else {
      isSuccess == false;
      isLoading == false;
    }
  }

  //! Connect someone
  @observable
  LinkCodeEntity? linkCodes;

  @action
  Future<LinkCodeEntity?> generateLinkCode({
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
      return linkCode.right;
    } else {
      isSuccess == false;
      isLoading == false;
      return null;
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
