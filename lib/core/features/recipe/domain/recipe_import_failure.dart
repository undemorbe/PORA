import 'package:pora/core/internal/errors/failure.dart';

/// Причина сбоя импорта рецепта — для аналитики и сообщения в UI.
enum RecipeScrapeErrorKind { invalidUrl, http, noIngredients, youtube }

/// Сбой импорта рецепта с причиной [kind].
class RecipeImportFailure extends ServerFailure {
  const RecipeImportFailure(super.message, {required this.kind});

  final RecipeScrapeErrorKind kind;

  @override
  List<Object?> get props => [message, kind];
}
