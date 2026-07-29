import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class RecipeRepository {
  /// Парсит рецепт с внешней URL. Приоритет JSON-LD (schema.org/Recipe),
  /// fallback на HTML-эвристики.
  Future<Either<Failure, RecipeEntity>> parseFromUrl(String url);
}
