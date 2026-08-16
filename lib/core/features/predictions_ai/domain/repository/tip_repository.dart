import 'package:pora/core/features/predictions_ai/domain/entity/tip.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class TipRepository {
  Future<Either<Failure, TipEntity>> getCulinarTip({
    required Map<String, dynamic> body,
  });
}
