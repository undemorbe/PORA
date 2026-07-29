import 'package:pora/core/features/recipe/data/datasource/recipe_scraper.dart';
import 'package:pora/core/features/recipe/domain/entity/recipe.dart';
import 'package:pora/core/features/recipe/domain/repository/recipe_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';

class RecipeService implements RecipeRepository {
  final RecipeScraper scraper;

  const RecipeService({required this.scraper});

  @override
  Future<Either<Failure, RecipeEntity>> parseFromUrl(String url) async {
    if (url.trim().isEmpty) {
      return Left(const ValidationFailure('URL is empty'));
    }
    try {
      final recipe = await scraper.scrape(url);
      return Right(recipe);
    } on RecipeScrapeException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
