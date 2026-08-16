import 'package:pora/core/features/auth_and_validation/domain/entity/tokens_entity.dart';
import 'package:pora/core/features/auth_and_validation/domain/repository/tokens_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class SaveTokensUseCase {
  final TokensRepository tokensRepository;
  const SaveTokensUseCase({required this.tokensRepository});

  Future<Either<Failure, void>> call({required TokensEntity tokens}) async {
    final result = await tokensRepository.saveTokens(tokens: tokens);
    if (result.isRight) {
      return Right(result.right);
    }
    return Left(result.left);
  }
}
