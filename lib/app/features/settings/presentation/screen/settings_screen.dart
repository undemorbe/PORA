import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/settings/presentation/widgets/delivery_value.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
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
            Text(context.l10n.settingsTitle, style: PoraText.title),
            const SizedBox(height: PoraSpacing.lg),

            const ProfileCard(),
            const SizedBox(height: PoraSpacing.xl),

            SectionLabel(context.l10n.settingsHouseholdSection),
            const PoraRowsCard(children: [HouseholdMembersRow()]),
            const SizedBox(height: PoraSpacing.xl),

            SectionLabel(context.l10n.settingsAppSection),
            PoraRowsCard(
              children: [
                PoraSettingRow(
                  icon: PhosphorIconsRegular.bell,
                  label: context.l10n.settingsNotifications,
                  trailing: PoraSettingRow.chevron,
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.shoppingCart,
                  label: context.l10n.settingsDelivery,
                  trailing: const DeliveryValue(),
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.star,
                  label: context.l10n.settingsProAd,
                  trailing: PoraPill(label: context.l10n.settingsTryPill),
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.lock,
                  label: context.l10n.settingsPrivacy,
                  trailing: PoraSettingRow.chevron,
                ),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),

            PoraRowsCard(
              children: [
                PoraSettingRow(
                  icon: PhosphorIconsRegular.info,
                  label: context.l10n.settingsAboutPora,
                  trailing: PoraSettingRow.chevron,
                ),
                PoraSettingRow(
                  icon: PhosphorIconsRegular.signOut,
                  label: context.l10n.settingsLogout,
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
