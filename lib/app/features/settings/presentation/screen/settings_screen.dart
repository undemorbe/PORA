import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/auth_and_validation/presentation/controller/privacy_store.dart';
import 'package:pora/app/features/settings/presentation/store/settings_store.dart';
import 'package:pora/app/features/settings/presentation/widgets/delivery_value.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/features/settings/presentation/widgets/profile_card.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Экран настроек: профиль, хозяйство, группы настроек.
@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsStore settingsStore;

  final PrivacyStore privacyStore = PrivacyStore();

  @override
  void initState() {
    super.initState();
    settingsStore = SettingsStore()..getUserMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: () => settingsStore.getUserMe(),
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

              Observer(
                builder: (_) {
                  return ProfileCard(
                    settingsStore: settingsStore,
                    name:
                        "${settingsStore.user?.name ?? 'You'} ${settingsStore.user?.surname ?? ''}",
                    imageUrl: settingsStore.user?.imageUrl,
                    colorOfAvatar: PoraColors.primary,
                    email:
                        (settingsStore.user?.phone ??
                            settingsStore.user?.email) ??
                        'unknown@unk.nown',
                  );
                },
              ),
              const SizedBox(height: PoraSpacing.xl),

              SectionLabel(context.l10n.listsYour),

              //! Personal lists — invite/members не показываем.
              PoraRowsCard(
                children: [
                  PoraSettingRow(
                    icon: PhosphorIconsRegular.user,
                    label: context.l10n.personal,
                    trailing: PoraSettingRow.chevron,
                    onTap: () => context.router.push(
                      PreviewListsRoute(isPersonal: true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: PoraSpacing.xl),

              SectionLabel(context.l10n.settingsAppSection),
              PoraRowsCard(
                children: [
                  PoraSettingRow(
                    icon: PhosphorIconsRegular.bell,
                    label: context.l10n.settingsNotifications,
                    trailing: PoraSettingRow.chevron,
                    onTap: () =>
                        context.router.push(const NotificationsRoute()),
                  ),
                  PoraSettingRow(
                    icon: PhosphorIconsRegular.shoppingCart,
                    label: context.l10n.settingsDelivery,
                    trailing: const DeliveryValue(),
                  ),
                  PoraSettingRow(
                    icon: PhosphorIconsRegular.gear,
                    label: context.l10n.advancedSettings,
                    trailing: PoraSettingRow.chevron,
                    onTap: () =>
                        context.router.push(const AdvancedSettingsRoute()),
                  ),
                  PoraSettingRow(
                    icon: PhosphorIconsRegular.lock,
                    label: context.l10n.settingsPrivacy,
                    trailing: PoraSettingRow.chevron,
                    onTap: () => privacyStore.openPrivacy(),
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
                    onTap: () => showAboutDialog(context: context),
                  ),
                  PoraSettingRow(
                    icon: PhosphorIconsRegular.signOut,
                    label: context.l10n.settingsLogout,
                    danger: true,
                    onTap: () => settingsStore.logout(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
