import 'package:pora/core/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class NotifyAboutItemUseCase {
  final ItemsRepository repository;
  const NotifyAboutItemUseCase({required this.repository});

  Future<Either<Failure, Success>> call({
    required String itemId,
    required List<String>? to,
    required String message,
  }) => repository.notify(itemId: itemId, to: to, message: message);
}
