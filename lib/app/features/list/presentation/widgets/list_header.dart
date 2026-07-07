import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
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
  });

  final String title;
  final String subtitle;

  /// Участники: (инициал, цвет). Аватары накладываются друг на друга.
  final List<(String, Color)> members;

  final VoidCallback? onSearch;
  final VoidCallback? onRecipe;
  final VoidCallback? onNotifications;

  static const double _avatar = 34;
  static const double _overlap = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: PoraText.title),
              const SizedBox(height: 6),
              Text(subtitle, style: PoraText.caption),
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
          _HeaderAction(icon: PhosphorIconsRegular.bell, onTap: onNotifications!),
        const SizedBox(width: 6),
        SizedBox(
          height: _avatar,
          width: _avatar + (members.length - 1) * _overlap,
          child: Stack(
            children: [
              for (var i = 0; i < members.length; i++)
                Positioned(
                  left: i * _overlap,
                  child: PoraAvatar(
                    initial: members[i].$1,
                    color: members[i].$2,
                    size: _avatar,
                    ring: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
            ],
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
        child: PhosphorIcon(icon, size: 22, color: PoraColors.ink),
      ),
    );
  }
}
