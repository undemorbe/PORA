import 'package:pora/app/features/families/domain/entity/family.dart';
import 'package:pora/app/features/families/domain/entity/link_code.dart';

abstract class FamilyRepository {
  Future<List<FamilyEntity>> getFamilies();
  Future<FamilyEntity> createFamily({required String name});
  Future<LinkCodeEntity> getFamilyInviteCode({required String familyId});
}
