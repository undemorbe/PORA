import 'package:flutter/material.dart';
import 'package:pora/app/features/settings/presentation/store/settings_store.dart';
import 'package:pora/app/features/settings/presentation/widgets/profile_photo_picker.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';

/// Карточка профиля пользователя в настройках.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.name = 'Борис',
    this.email = 'stankovb08@gmail.com',
    this.onTap,
    required this.settingsStore,
    this.ringColor,
    this.colorOfAvatar,
    this.imageUrl,
  });

  final String name;
  final String email;
  final String? imageUrl;
  final Color? colorOfAvatar;
  final VoidCallback? onTap;
  final Color? ringColor;
  final SettingsStore settingsStore;

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
            Center(
              child: ProfilePhotoPickerSettings(
                onTap: () async {
                  await settingsStore.setProfileImage();
                },
                settingsStore: settingsStore,
              ),
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
