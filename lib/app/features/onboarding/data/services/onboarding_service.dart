import 'package:pora/app/features/onboarding/data/datasources/onboarding_local.dart';
import 'package:pora/app/features/onboarding/domain/entity/section_entity.dart';
import 'package:pora/app/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingService extends OnboardingRepository {
  final OnboardingLocaleDataSource onboardingLocaleDataSource;

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
  Future<void> selectSection({required SectionEntity sections}) async {
    // TODO: implement selectSection
    throw UnimplementedError();
  }
}
