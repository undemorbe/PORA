import 'package:pora/core/features/predictions_ai/domain/entity/tip.dart';
import 'package:pora/core/features/predictions_ai/domain/repository/tip_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class GetTipUseCase {
  final TipRepository tipRepository;

  const GetTipUseCase({required this.tipRepository});

  Future<Either<Failure, TipEntity>> call({
    required Map<String, dynamic> body,
  }) async {
    return await tipRepository.getCulinarTip(body: body);
  }
}
