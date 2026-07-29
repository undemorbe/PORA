import 'package:pora/core/features/invitation/domain/entity/link_code.dart';
import 'package:pora/core/features/invitation/domain/repository/invitations_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetInviteCodeUseCase {
  final InvitationsRepository invitationsRepository;

  const GetInviteCodeUseCase({required this.invitationsRepository});

  Future<Either<Failure, LinkCodeEntity>> call({
    required String familyId,
  }) async {
    final result = await invitationsRepository.getInviteCode(
      familyId: familyId,
    );
    if (result.isRight) {
      return Right(result.right);
    }
    return Left(result.left);
  }
}
