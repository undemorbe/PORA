import 'package:equatable/equatable.dart';
import 'package:pora/core/internal/local_storage/abstract_local_db.dart';

abstract class OnboardingLocalDataSource extends Equatable {
  final ILocalDB iLocaDB;
  Future<bool> hasCompletedOnboarding();
  Future<void> updateIsSawedOnboarding({required bool isSawed});
  const OnboardingLocalDataSource({required this.iLocaDB});
  @override
  List<Object?> get props => [iLocaDB];
}

class OnboardingLocalDataSourceImpl extends OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl({required this.iLocalDB})
    : super(iLocaDB: iLocalDB);

  final ILocalDB iLocalDB;

  @override
  Future<bool> hasCompletedOnboarding() async {
    return await iLocalDB.get(
          key: 'onboarding_completed',
          boxName: LocalDBNames.settings,
        ) ??
        false;
  }

  @override
  Future<void> updateIsSawedOnboarding({required bool isSawed}) async {
    await iLocalDB.set(
      key: 'onboarding_completed',
      value: isSawed,
      boxName: LocalDBNames.settings,
    );
  }
}
