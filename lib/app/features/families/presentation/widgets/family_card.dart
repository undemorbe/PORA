import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/family.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/internal/di/export.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/extensions/string_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';

/// Карточка семьи: аватары участников (инициалы из members), название,
class FamilyCard extends StatelessWidget {
  const FamilyCard({super.key, required this.family, this.onTap});

  final FamilyEntity family;
  final VoidCallback? onTap;

  static const double _avatar = 32;
  static const double _overlap = 20;

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.surface;
    final List<MemberEntity> members = [
      family.owner,
      if (family.members != null) ...family.members!.whereType<MemberEntity>(),
    ];
    final avatarsWidth = members.isEmpty
        ? 0.0
        : _avatar + (members.length - 1) * _overlap;
    return ClipRRect(
      borderRadius: PoraRadii.card,
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                context.router.navigate(InviteRoute(familyId: family.id));
              },
              backgroundColor: PoraColors.primary,
              foregroundColor: PoraColors.progressTrack,
              icon: PhosphorIcons.plus,
              label: context.l10n.settingsInvitePill,
            ),
          ],
        ),
        child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: PoraCard(
          padding: const EdgeInsets.symmetric(
            horizontal: PoraSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: avatarsWidth,
                height: _avatar,
                child: Stack(
                  children: [
                    for (var i = 0; i < members.length; i++)
                      Positioned(
                        left: i * _overlap,
                        child: PoraAvatar(
                          initial: members[i].name.initials,
                          color: memberColor(members[i], i),
                          imageUrl: members[i].imageUrl,
                          size: _avatar,
                          ring: ring,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: PoraSpacing.sm),
              Text(family.name),
              const PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: 20,
                color: Color(0xFFC9BEAE),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
