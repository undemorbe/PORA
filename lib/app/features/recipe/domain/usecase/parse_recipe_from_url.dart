import 'package:pora/app/features/recipe/domain/entity/recipe.dart';
import 'package:pora/app/features/recipe/domain/repository/recipe_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class ParseRecipeFromUrlUseCase {
  final RecipeRepository repository;

  const ParseRecipeFromUrlUseCase({required this.repository});

  Future<Either<Failure, RecipeEntity>> call({required String url}) {
    return repository.parseFromUrl(url);
  }
}
