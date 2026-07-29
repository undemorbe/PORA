import 'package:pora/core/features/invitation/data/datasource/remote_invitations.dart';
import 'package:pora/core/features/invitation/domain/entity/link_code.dart';
import 'package:pora/core/features/invitation/domain/repository/invitations_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class InvitationsService extends InvitationsRepository {
  final RemoteInvitations remoteInvitations;

  InvitationsService({required this.remoteInvitations});

  @override
  Future<Either<Failure, Success>> connectWithInviteCode({
    required String code,
  }) async {
    final result = await remoteInvitations.connectWithInviteCode(code: code);
    if (result.isRight) {
      return Right(result.right);
    }
    return Left(result.left);
  }

  @override
  Future<Either<Failure, LinkCodeEntity>> getInviteCode({
    required String familyId,
  }) async {
    final result = await remoteInvitations.getInviteCode(familyId: familyId);
    if (result.isRight) {
      return Right(result.right);
    }
    return Left(result.left);
  }
}
