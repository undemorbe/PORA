import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/features/groups/domain/entity/group.dart';
import 'package:pora/app/features/lists/domain/entity/products/product.dart';
import 'package:pora/app/features/lists/presentation/widgets/list_item_tile.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/extensions/string_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

const int _kPreviewProductsLimit = 3;

/// Карточка группы = один список + аватары участников + превью продуктов.
/// Slidable → Invite (only shared) + Delete.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, required this.onDelete});

  final GroupEntity group;
  final Future<void> Function() onDelete;

  static const double _avatar = 28;
  static const double _overlap = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final list = group.list;
    final items = <ProductEntity>[for (final s in list.sections) ...s.items];
    final visible = items.take(_kPreviewProductsLimit).toList();
    final hidden = items.length - visible.length;
    final ring = c.surface;

    void open() => context.router.push(
      ListRoute(listId: list.id, listName: list.name, members: group.members),
    );

    final body = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: open,
      child: PoraCard(
        padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.lg,
                PoraSpacing.md,
                PoraSpacing.lg,
                PoraSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(list.name, style: PoraText.heading)),
                  if (group.members.isNotEmpty)
                    _AvatarStack(members: group.members, ring: ring),
                  if (group.isPersonal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: PoraColors.primaryTint,
                        borderRadius: PoraRadii.pill,
                      ),
                      child: Text(
                        context.l10n.groupPersonal,
                        style: PoraText.small.copyWith(
                          color: PoraColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoraSpacing.lg,
                  vertical: PoraSpacing.md,
                ),
                child: Text(
                  context.l10n.familiesNoUrgent,
                  style: PoraText.subtitle.copyWith(color: c.textSubtle),
                ),
              )
            else
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: PoraSpacing.lg,
                    endIndent: PoraSpacing.lg,
                    color: c.divider,
                  ),
                ListItemTile(
                  item: visible[i],
                  addedBy: visible[i].addedBy,
                  isCompact: true,
                  onTap: open,
                ),
              ],
            if (hidden > 0)
              InkWell(
                onTap: open,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PoraSpacing.lg,
                    vertical: PoraSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${context.l10n.showAll} ($hidden)',
                        style: PoraText.button.copyWith(
                          color: PoraColors.primary,
                        ),
                      ),
                      const Spacer(),
                      const PhosphorIcon(
                        PhosphorIconsRegular.caretRight,
                        size: 18,
                        color: PoraColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: PoraRadii.card,
      child: Slidable(
        key: ValueKey('group_${list.id}'),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: group.isPersonal ? 0.28 : 0.56,
          children: [
            if (!group.isPersonal && group.familyId != null)
              SlidableAction(
                onPressed: (ctx) =>
                    ctx.router.push(InviteRoute(familyId: group.familyId!)),
                backgroundColor: PoraColors.primary,
                foregroundColor: PoraColors.inkInverse,
                icon: PhosphorIconsFill.userPlus,
                label: context.l10n.settingsInvitePill,
              ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: PoraColors.danger,
              foregroundColor: PoraColors.inkInverse,
              icon: PhosphorIconsFill.trash,
              label: context.l10n.delete,
            ),
          ],
        ),
        child: body,
      ),
    );
  }
}

extension _CtxL on BuildContext {
  // helper — оба callback'а внутри Slidable получают собственный ctx.
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.members, required this.ring});

  final List<MemberEntity> members;
  final Color ring;

  static const double _avatar = 28;
  static const double _overlap = 18;
  static const int _maxShown = 3;

  @override
  Widget build(BuildContext context) {
    final shown = members.take(_maxShown).toList();
    final extra = members.length - shown.length;
    final width =
        _avatar + (shown.length - 1) * _overlap + (extra > 0 ? 22 : 0);
    return SizedBox(
      width: width,
      height: _avatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * _overlap,
              child: PoraAvatar(
                initial: shown[i].name.initials,
                color: memberColor(shown[i], i),
                imageUrl: shown[i].imageUrl,
                size: _avatar,
                ring: ring,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * _overlap,
              child: Container(
                width: _avatar,
                height: _avatar,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primaryTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: PoraText.micro.copyWith(
                    color: PoraColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
