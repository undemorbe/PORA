import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/families/domain/entity/member.dart';
import 'package:pora/app/internal/extensions/color_parser.dart';
import 'package:pora/app/internal/extensions/string_extension.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';

/// Шапка списка: заголовок + подпись + действия + аватары участников.
class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.members,
    this.onSearch,
    this.onRecipe,
    this.onNotifications,
    this.onMembersTap,
    this.onBack,
  });

  final String title;
  final String subtitle;

  final List<MemberEntity> members;

  final VoidCallback? onSearch;
  final VoidCallback? onRecipe;
  final VoidCallback? onNotifications;
  final VoidCallback? onMembersTap;
  final VoidCallback? onBack;

  static const double _avatar = 34;
  static const double _overlap = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PhosphorIcon(
                PhosphorIconsRegular.caretLeft,
                size: 24,
                color: context.colors.ink,
              ),
            ),
          ),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PoraText.title.copyWith(color: context.colors.ink),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: PoraText.caption.copyWith(
                  color: context.colors.textSubtle,
                ),
              ),
            ],
          ),
        ),
        if (onSearch != null)
          _HeaderAction(
            icon: PhosphorIconsRegular.magnifyingGlass,
            onTap: onSearch!,
          ),
        if (onRecipe != null)
          _HeaderAction(icon: PhosphorIconsRegular.link, onTap: onRecipe!),
        if (onNotifications != null)
          _HeaderAction(
            icon: PhosphorIconsRegular.bell,
            onTap: onNotifications!,
          ),
        const SizedBox(width: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onMembersTap,
          child: SizedBox(
            height: _avatar,
            width: _avatar + (members.length - 1) * _overlap,
            child: Stack(
              children: [
                for (var i = 0; i < members.length; i++)
                  Positioned(
                    left: i * _overlap,
                    child: PoraAvatar(
                      initial: members[i].name.initials,
                      color: memberColor(members[i], (i % 10) % 4),
                      size: _avatar,
                      imageUrl: members[i].imageUrl,
                      ring: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: PhosphorIcon(icon, size: 22, color: context.colors.ink),
      ),
    );
  }
}
