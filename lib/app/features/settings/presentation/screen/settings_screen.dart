import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/auth_and_validation/data/datasource/local/secure_tokens.dart';
import 'package:pora/app/features/settings/presentation/widgets/delivery_value.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/features/settings/presentation/widgets/household_members_row.dart';
import 'package:pora/app/features/settings/presentation/widgets/profile_card.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_pill.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_setting_row.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Экран настроек: профиль, хозяйство, группы настроек.
@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  //! refactor later — вынести в clean architecture (usecase + repository + store).
  // Контракт: POST /authorize/logout с access-токеном в заголовке;
  // после запроса access-токен удаляется на устройстве.
  Future<void> _logout(BuildContext context) async {
    final tokensStore = GetIt.I<TokensSecureStore>();
    final dio = GetIt.I<Dio>();
    try {
      final access = await tokensStore.getAccessToken();
      await dio.post(
        '/authorize/logout',
        options: Options(
          headers: {if (access != null) 'Authorization': 'Bearer $access'},
        ),
      );
    } catch (e) {
      // Даже если сервер не ответил — выходим локально.
      Logger.talker.warning('logout request failed: $e');
    } finally {
      // Токен удаляется на мобилке независимо от ответа сервера.
      await tokensStore.clearTokens();
      GetIt.I<AuthState>().setUnauthenticated();
      if (context.mounted) {
        context.router.replaceAll([const AuthRoute()]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            PoraRowsCard(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: const HouseholdMembersRow(),
                  onTap: () => context.router.push(InviteRoute(familyId: '')),
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
                  onTap: () => context.router.push(const NotificationsRoute()),
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
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
