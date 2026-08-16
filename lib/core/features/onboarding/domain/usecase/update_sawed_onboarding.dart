import 'package:pora/core/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/errors/success.dart';
import 'package:pora/core/internal/extensions/either.dart';

class UpdateIsSawedOnboardingUseCase {
  final OnboardingRepository onboardingRepository;

  UpdateIsSawedOnboardingUseCase({required this.onboardingRepository});
  Future<Either<Failure, Success>> call({required bool isSawed}) async {
    try {
      await onboardingRepository.updateIsSawedOnboarding(isSawed: isSawed);
      return Right(const LocalDBSuccess());
    } on Exception {
      return Left(const UnexpectedFailure('Local db failure'));
    }
  }
}
