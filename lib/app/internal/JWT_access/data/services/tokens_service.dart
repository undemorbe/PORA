import 'package:pora/app/internal/JWT_access/data/datasource/local/secure.dart';
import 'package:pora/app/internal/JWT_access/data/datasource/remote/remote_tokens.dart';
import 'package:pora/app/internal/JWT_access/data/models/tokens_model.dart';
import 'package:pora/app/internal/JWT_access/domain/entity/tokens_entity.dart';
import 'package:pora/app/internal/JWT_access/domain/repositories/tokens_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class TokensService extends TokensRepository {
  TokensService({
    required this.tokensRemoteDataSource,
    required this.tokensSecureStore,
  });

  final TokensRemoteDataSource tokensRemoteDataSource;
  final TokensSecureStore tokensSecureStore;

  @override
  Future<Either<Failure, TokensEntity>> refreshTokens({
    required String refreshToken,
  }) async {
    try {
      return Right(
        await tokensRemoteDataSource.refreshTokens(refreshToken: refreshToken),
      );
    } catch (e) {
      throw Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTokens({
    required TokensEntity tokens,
  }) async {
    try {
      return Right(
        await tokensSecureStore.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
      );
    } catch (e) {
      throw Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TokensEntity>> getTokens() async {
    try {
      final accessToken = await tokensSecureStore.getAccessToken();
      final refreshToken = await tokensSecureStore.getRefreshToken();
      return Right(
        TokensModel(
          accessToken: accessToken ?? '',
          refreshToken: refreshToken ?? '',
        ),
      );
    } catch (e) {
      throw Left(UnexpectedFailure(e.toString()));
    }
  }
}
