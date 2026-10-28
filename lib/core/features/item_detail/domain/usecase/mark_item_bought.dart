import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class MarkItemBoughtUseCase {
  final ItemsRepository repository;
  const MarkItemBoughtUseCase({required this.repository});

  /// [name] — имя продукта для персональной статистики («что покупаете
  /// чаще всего»); опционально, если вызывающий его не знает.
  Future<Either<Failure, Success>> call({
    required String itemId,
    required bool checked,
    String? name,
  }) async {
    final res = await repository.markBought(itemId: itemId, checked: checked);
    if (res.isRight && checked) {
      AnalyticsService.instance.logItemMarkedBought(name: name);
    }
    return res;
  }
}
