import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';

/// Экран со списком участников. `ownerId` подсвечивает владельца.
@RoutePage()
class MembersPage extends StatelessWidget {
  const MembersPage({super.key, required this.members, this.ownerId});

  final List<MemberEntity> members;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            PoraSpacing.sm,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            ScreenBackHeader(title: context.l10n.membersScreenTitle),
            const SizedBox(height: PoraSpacing.lg),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: PoraSpacing.xxl),
                child: Center(
                  child: Text(
                    context.l10n.familiesNoUrgent,
                    style: PoraText.subtitle,
                  ),
                ),
              )
            else
              PoraRowsCard(
                children: [
                  for (var i = 0; i < members.length; i++)
                    _MemberRow(
                      member: members[i],
                      index: i,
                      isOwner: members[i].id == ownerId,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.index,
    required this.isOwner,
  });

  final MemberEntity member;
  final int index;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final fullName = member.surname == null
        ? member.name
        : '${member.name} ${member.surname}';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PoraSpacing.lg,
        vertical: PoraSpacing.md,
      ),
      child: Row(
        children: [
          PoraAvatar(
            initial: member.name.isEmpty ? '?' : member.name[0],
            color: memberColor(member, index),
            imageUrl: member.imageUrl,
            size: 44,
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: PoraText.itemTitle.copyWith(color: c.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  isOwner ? l.owner : l.member,
                  style: PoraText.small.copyWith(
                    color: isOwner ? PoraColors.primaryDark : c.textSubtle,
                    fontWeight: isOwner ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
