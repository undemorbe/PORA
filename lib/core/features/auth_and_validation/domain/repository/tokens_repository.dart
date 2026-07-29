import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class TokensRepository {
  Future<Either<Failure, TokensEntity>> refreshTokens({
    required String refreshToken,
  });
  Future<Either<Failure, void>> saveTokens({required TokensEntity tokens});
  Future<Either<Failure, TokensEntity>> getTokens();
}
