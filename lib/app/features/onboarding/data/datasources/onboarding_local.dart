import 'package:pora/app/internal/local_storage/abstract_local_db.dart';

class OnboardingLocaleDataSource {
  final ILocalDB iLocalDB;

  OnboardingLocaleDataSource({required this.iLocalDB});

  Future<bool> hasCompletedOnboarding() async {
    return await iLocalDB.get(
      key: 'onboarding_completed',
      boxName: LocalDBNames.settings,
    );
  }
}
