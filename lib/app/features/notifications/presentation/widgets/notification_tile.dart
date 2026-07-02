import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_icon_tile.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';

/// Строка уведомления: иконка-плитка · заголовок/текст · время/действие · точка непрочитанного.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.emoji,
    required this.tileColor,
    required this.title,
    required this.body,
    this.time,
    this.mini = false,
    this.unread = false,
  });

  final String emoji;
  final Color tileColor;
  final String title;
  final String body;
  final String? time;
  final bool mini;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(PoraSpacing.lg, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PoraIconTile.emoji(
            emoji,
            color: tileColor,
            size: 38,
            emojiSize: 18,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: PoraSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PoraText.itemTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: unread ? PoraColors.ink : const Color(0xFF8C8275),
                  ),
                ),
                const SizedBox(height: 3),
                Text(body, style: PoraText.caption.copyWith(height: 1.4)),
                if (mini) ...[
                  const SizedBox(height: PoraSpacing.sm),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: PoraPill(label: '＋ В список'),
                  ),
                ] else if (time != null) ...[
                  const SizedBox(height: PoraSpacing.xs),
                  Text(
                    time!,
                    style: PoraText.small.copyWith(
                      color: const Color(0xFFB3A998),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: PoraSpacing.sm),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: unread ? PoraColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
