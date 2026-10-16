import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/features/auth_and_validation/domain/repository/tokens_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/network/single_flight.dart';

class RefreshTokenUseCase {
  final TokensRepository tokensRepository;
  const RefreshTokenUseCase({required this.tokensRepository});

  /// Фоновый refresh из AppBootstrap и 401 в AuthInterceptor могут совпасть —
  /// второй /authorize/refresh с тем же refresh-токеном не шлём.
  static final _flight = SingleFlight<Either<Failure, TokensEntity>?>();

  Future<Either<Failure, TokensEntity>?> call() => _flight.run(_refresh);

  Future<Either<Failure, TokensEntity>?> _refresh() async {
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
