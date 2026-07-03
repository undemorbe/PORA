import 'package:pora/app/features/onboarding/domain/entity/section_entity.dart';

abstract class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();
  //! Conveer
  Stream<List<SectionEntity>> getSections();
  //! Selected sections
  Future<void> selectSection({required SectionEntity sections});
}
