import 'package:pora/app/features/invitation/domain/repository/invitations_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class ConnectWithInviteCodeUseCase {
  final InvitationsRepository invitationsRepository;

  const ConnectWithInviteCodeUseCase({required this.invitationsRepository});

  Future<Either<Failure, Success>> call({required String code}) async {
    final result = await invitationsRepository.connectWithInviteCode(
      code: code,
    );
    if (result.isRight) {
      return Right(result.right);
    }
    return Left(result.left);
  }
}
