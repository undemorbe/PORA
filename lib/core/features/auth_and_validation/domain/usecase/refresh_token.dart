import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/features/auth_and_validation/domain/repository/tokens_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class RefreshTokenUseCase {
  final TokensRepository tokensRepository;
  const RefreshTokenUseCase({required this.tokensRepository});

  Future<Either<Failure, TokensEntity>?> call() async {
    final tokens = await tokensRepository.getTokens();
    if (tokens.isRight && tokens.right.refreshToken.isNotEmpty) {
      final refreshed = await tokensRepository.refreshTokens(
        refreshToken: tokens.right.refreshToken,
      );
      if (refreshed.isRight) {
        await tokensRepository.saveTokens(tokens: refreshed.right);
      }
      return refreshed;
    }
    return Left(const UnexpectedFailure('Unexpected'));
  }
}
