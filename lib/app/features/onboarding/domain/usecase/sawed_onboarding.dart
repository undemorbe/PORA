import 'package:pora/app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:pora/app/internal/errors/failure.dart';
import 'package:pora/app/internal/extensions/either.dart';

class IsSawedOnboardingUseCase {
  final OnboardingRepository onboardingRepository;

  IsSawedOnboardingUseCase({required this.onboardingRepository});
  Future<Either<Failure, bool>> call() async {
    bool? result = await onboardingRepository.hasCompletedOnboarding();

    if (result == true) {
      return Right(true);
    } else if (result == false) {
      return Right(false);
    }
    return Left(const UnexpectedFailure('Onboarding not completed'));
  }
}
