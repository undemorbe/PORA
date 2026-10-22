import 'package:equatable/equatable.dart';
import 'package:pora/core/features/families/domain/entity/member.dart';
import 'package:pora/core/features/lists/domain/entity/lists/lists.dart';

/// «Группа» = один список.
/// Личная группа — `familyId == null`, `members` пуст.
/// Общая — привязана к family (backend требование), `members` из неё.
class GroupEntity extends Equatable {
  final ListEntity list;
  final List<MemberEntity> members;
  final String? ownerId;
  final String? familyId;

  const GroupEntity({
    required this.list,
    this.members = const [],
    this.ownerId,
    this.familyId,
  });

  bool get isPersonal => familyId == null;

  /// Личную группу удаляет её хозяин; общую — только владелец семьи
  /// (DELETE /families для остальных → 403). `userId == null` — ещё не
  /// известен: общую не удаляем.
  bool canDelete(String? userId) =>
      isPersonal || (userId != null && ownerId == userId);

  /// Не-владелец общей группы может только выйти из семьи.
  bool canLeave(String? userId) =>
      !isPersonal && userId != null && ownerId != userId;

  @override
  List<Object?> get props => [list, members, ownerId, familyId];
}
