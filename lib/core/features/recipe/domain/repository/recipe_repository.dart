import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

abstract class RecipeRepository {
  /// Парсит рецепт с внешней URL. Порядок:
  /// JSON-LD → HTML-эвристики → AI-парсер очищенного текста.
  /// [languageCode] прокидывается в AI-fallback (кухня локализуется).
  Future<Either<Failure, RecipeEntity>> parseFromUrl(
    String url, {
    String languageCode,
  });
}
