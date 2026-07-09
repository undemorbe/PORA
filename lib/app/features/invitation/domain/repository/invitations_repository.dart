import 'package:pora/app/features/invitation/domain/entity/link_code.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class InvitationsRepository {
  Future<Either<Failure, LinkCodeEntity>> getInviteCode({
    required String familyId,
  });
  Future<Either<Failure, Success>> connectWithInviteCode({
    required String code,
  });
}
