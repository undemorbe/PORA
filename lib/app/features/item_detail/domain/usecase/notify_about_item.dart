import 'package:pora/app/features/item_detail/domain/repository/items_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/errors/success.dart';
import 'package:pora/app/internal/extensions/either.dart';

class NotifyAboutItemUseCase {
  final ItemsRepository repository;
  const NotifyAboutItemUseCase({required this.repository});

  Future<Either<Failure, Success>> call({
    required String itemId,
    required List<String>? to,
    required String message,
  }) =>
      repository.notify(itemId: itemId, to: to, message: message);
}
