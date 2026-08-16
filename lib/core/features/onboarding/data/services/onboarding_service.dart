import 'package:pora/core/features/onboarding/data/datasources/onboarding_local.dart';
import 'package:pora/core/features/onboarding/domain/entity/section_entity.dart';
import 'package:pora/core/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingService extends OnboardingRepository {
  final OnboardingLocalDataSourceImpl onboardingLocaleDataSource;

  OnboardingService({required this.onboardingLocaleDataSource});

  @override
  Stream<List<SectionEntity>> getSections() {
    // TODO: implement getSections
    throw UnimplementedError();
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return await onboardingLocaleDataSource.hasCompletedOnboarding();
  }

  @override
  Future<void> updateIsSawedOnboarding({required bool isSawed}) async {
    return await onboardingLocaleDataSource.updateIsSawedOnboarding(
      isSawed: isSawed,
    );
  }

  @override
  Future<void> selectSection({required SectionEntity sections}) async {
    // TODO: implement selectSection
    throw UnimplementedError();
  }
}
