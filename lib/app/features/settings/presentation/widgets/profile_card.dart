import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_avatar.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';

/// Карточка профиля пользователя в настройках.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.name = 'Борис',
    this.email = 'stankovb08@gmail.com',
    this.onTap,
    this.ringColor,this.colorOfAvatar, this.imageUrl
  });

  final String name;
  final String email;
  final String? imageUrl;
  final Color? colorOfAvatar;
  final VoidCallback? onTap;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PoraCard(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
             PoraAvatar(
              imageUrl: imageUrl,
              initial: name[0],
              color: colorOfAvatar,
              ring: ringColor,
              size: PoraSizes.avatarLg,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: PoraText.navTitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(email, style: PoraText.caption),
                ],
              ),
            ),
            PoraSettingRow.chevron,
          ],
        ),
      ),
    );
  }
}
