import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/settings/presentation/widgets/delivery_value.dart';
import 'package:pora/app/features/settings/presentation/widgets/household_members_row.dart';
import 'package:pora/app/features/settings/presentation/widgets/profile_card.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_bottom_nav.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Экран настроек: профиль, хозяйство, группы настроек.
@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const PoraBottomNav(current: PoraTab.profile),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            6,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            Text('Настройки', style: PoraText.title),
            const SizedBox(height: PoraSpacing.lg),

            const ProfileCard(),
            const SizedBox(height: PoraSpacing.xl),

            const SectionLabel('Хозяйство'),
            const PoraRowsCard(children: [HouseholdMembersRow()]),
            const SizedBox(height: PoraSpacing.xl),

            const SectionLabel('Приложение'),
            const PoraRowsCard(
              children: [
                PoraSettingRow(
                  icon: PhosphorIconsRegular.bell,
                  label: 'Уведомления',
                  trailing: PoraSettingRow.chevron,
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.shoppingCart,
                  label: 'Доставка',
                  trailing: DeliveryValue(),
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.star,
                  label: 'Pora+ · без рекламы',
                  trailing: PoraPill(label: 'Попробовать'),
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.lock,
                  label: 'Приватность и данные',
                  trailing: PoraSettingRow.chevron,
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            const PoraRowsCard(
              children: [
                PoraSettingRow(
                  icon: PhosphorIconsRegular.info,
                  label: 'О Pora',
                  trailing: PoraSettingRow.chevron,
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.signOut,
                  label: 'Выйти',
                  danger: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
