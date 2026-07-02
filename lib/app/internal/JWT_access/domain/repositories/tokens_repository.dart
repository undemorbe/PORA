import 'package:pora/app/internal/JWT_access/domain/entity/tokens_entity.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

abstract class TokensRepository {
  Future<Either<Failure, TokensEntity>> refreshTokens({
    required String refreshToken,
  });
  Future<Either<Failure, void>> saveTokens({required TokensEntity tokens});
  Future<Either<Failure, TokensEntity>> getTokens();
}
