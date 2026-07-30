import 'package:dio/dio.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/tip.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/logging/logger.dart';

abstract class TipRemote {
  Future<Either<Failure, TipEntity>> getCulinarTip({
    required Map<String, dynamic> body,
  });
}

class TipRemoteImpl implements TipRemote {
  final Dio aiApiClient;

  const TipRemoteImpl({required this.aiApiClient});

  @override
  Future<Either<Failure, TipEntity>> getCulinarTip({
    required Map<String, dynamic> body,
  }) async {
    final response = await aiApiClient.get('/chat/completions', data: body);
    final data = response.data;
    Logger.talker.debug(data);
    return Right(TipEntity(title: 'title', subtitle: ' subtitle'));
  }
}
