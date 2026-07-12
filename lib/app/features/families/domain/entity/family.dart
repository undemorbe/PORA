import 'package:equatable/equatable.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';

abstract class FamiliesEntity extends Equatable {
  final List<FamilyEntity> families;

  const FamiliesEntity({required this.families});

  @override
  List<Object?> get props => [families];
}

abstract class FamilyEntity extends Equatable {
  final String id;
  final String name;
  final List<MemberEntity> members;
  final MemberEntity owner;
  final bool? isCurrent;
  final String createdAt;

  const FamilyEntity({
    required this.id,
    required this.name,
    required this.members,
    required this.owner,
    required this.createdAt,
    required this.isCurrent,
  });

  @override
  List<Object?> get props => [id, name, members, owner, createdAt, isCurrent];
}
