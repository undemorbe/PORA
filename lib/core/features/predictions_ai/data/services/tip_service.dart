import 'package:pora/core/features/predictions_ai/data/datasource/tip_remote.dart';
import 'package:pora/core/features/predictions_ai/domain/entity/tip.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/tip_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class TipService implements TipRepository {
  final TipRemote tipRemote;

  const TipService({required this.tipRemote});

  @override
  Future<Either<Failure, TipEntity>> getCulinarTip({
    required Map<String, dynamic> body,
  }) async {
    return await tipRemote.getCulinarTip(body: body);
  }
}
