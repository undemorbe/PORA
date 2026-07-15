import 'package:pora/app/internal/JWT_access/domain/entity/tokens_entity.dart';
import 'package:pora/app/internal/JWT_access/domain/repositories/tokens_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class RefreshTokenUseCase {
  final TokensRepository tokensRepository;
  const RefreshTokenUseCase({required this.tokensRepository});

  Future<Either<Failure, TokensEntity>?> call() async {
    final tokens = await tokensRepository.getTokens();
    if (tokens.isRight) {
      return await tokensRepository
          .refreshTokens(refreshToken: tokens.right.refreshToken)
          .then((value) {
            if (value.isRight) {
              tokensRepository.saveTokens(tokens: value.right);
            }
            return value;
          });
    }
    return Left(const UnexpectedFailure('Unexpected'));
  }
}
