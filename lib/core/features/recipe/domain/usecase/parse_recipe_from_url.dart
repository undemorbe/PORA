import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/repository/recipe_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class ParseRecipeFromUrlUseCase {
  final RecipeRepository repository;

  const ParseRecipeFromUrlUseCase({required this.repository});

  Future<Either<Failure, RecipeEntity>> call({
    required String url,
    required String languageCode,
  }) {
    return repository.parseFromUrl(url, languageCode: languageCode);
  }
}
