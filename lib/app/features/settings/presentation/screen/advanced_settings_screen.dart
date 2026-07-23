import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/item_detail/data/datasource/local_prefs.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/localization/l10n/locales.dart';
import 'package:pora/app/internal/localization/store/localization_store.dart';
import 'package:pora/app/internal/notifications/device_token_sync.dart';
import 'package:pora/app/internal/notifications/notification_service.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/theme/store/theme_store.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';
import 'package:pora/app/internal/widgets/screen_back_header.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

@RoutePage()
class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  AuthorizationStatus? _notifStatus;
  bool _askBeforeDelete = true;

  @override
  void initState() {
    super.initState();
    _refreshPermission();
    _loadDeletePref();
  }

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Future<void> _refreshPermission() async {
    if (!_firebaseReady) return;
    try {
      final s = await FirebaseMessaging.instance.getNotificationSettings();
      if (!mounted) return;
      setState(() => _notifStatus = s.authorizationStatus);
    } catch (_) {
      /* Firebase не инициализирован / нет push profile */
    }
  }

  Future<void> _requestPermission() async {
    if (!_firebaseReady) return;
    try {
      final s = await FirebaseMessaging.instance.requestPermission();
      if (!mounted) return;
      setState(() => _notifStatus = s.authorizationStatus);
    } catch (_) {}
  }

  Future<void> _loadDeletePref() async {
    final skip = await GetIt.I<ItemDetailsPrefs>().shouldSkipDeleteConfirm();
    if (!mounted) return;
    setState(() => _askBeforeDelete = !skip);
  }

  Future<void> _setDeletePref(bool ask) async {
    setState(() => _askBeforeDelete = ask);
    await GetIt.I<ItemDetailsPrefs>().setSkipDeleteConfirm(!ask);
  }

  Future<void> _resyncDeviceToken() async {
    await syncDeviceToken();
    if (!mounted) return;
    PoraSnackbar.show(context, message: context.l10n.tokenSynced);
    setState(() {}); // rerender для обновления token preview
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          child: ListView(
            key: ValueKey(context.l10n.advancedSettings),
            padding: const EdgeInsets.fromLTRB(
              PoraSpacing.screen,
              PoraSpacing.sm,
              PoraSpacing.screen,
              PoraSpacing.xxl,
            ),
            children: [
              ScreenBackHeader(title: l.advancedSettings),
              const SizedBox(height: PoraSpacing.lg),

              SectionLabel(l.appearance),
              const _ThemePicker(),
              const SizedBox(height: PoraSpacing.lg),

              SectionLabel(l.language),
              const _LanguagePicker(),
              const SizedBox(height: PoraSpacing.lg),

              SectionLabel(l.notificationsPermission),
              PoraRowsCard(
                children: [
                  _PermissionRow(
                    status: _notifStatus,
                    onRequest: _requestPermission,
                  ),
                  _PushTokenRow(onResync: _resyncDeviceToken),
                ],
              ),
              const SizedBox(height: PoraSpacing.lg),

              SectionLabel(l.confirmations),
              PoraRowsCard(
                children: [
                  SwitchListTile.adaptive(
                    title: Text(l.askBeforeDelete, style: PoraText.itemTitle),
                    secondary: const Icon(PhosphorIconsRegular.trash),
                    value: _askBeforeDelete,
                    onChanged: _setDeletePref,
                  ),
                ],
              ),
              const SizedBox(height: PoraSpacing.lg),

              SectionLabel(l.about),
              PoraRowsCard(
                children: [
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.question),
                    title: Text(l.showTutorial, style: PoraText.itemTitle),
                    trailing: const Icon(PhosphorIconsRegular.caretRight),
                    onTap: () =>
                        context.router.push(TutorialRoute(fromSettings: true)),
                  ),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.info),
                    title: Text(l.version, style: PoraText.itemTitle),
                    trailing: Text('1.0.0', style: PoraText.small),
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

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<ThemeStore>();
    final l = context.l10n;
    return Observer(
      builder: (context) => PoraRowsCard(
        children: [
          for (final entry in const [
            (ThemeMode.system, PhosphorIconsRegular.deviceMobile),
            (ThemeMode.light, PhosphorIconsRegular.sun),
            (ThemeMode.dark, PhosphorIconsRegular.moon),
          ])
            RadioListTile<ThemeMode>.adaptive(
              value: entry.$1,
              groupValue: store.themeMode,
              onChanged: (v) {
                if (v != null) store.setThemeMode(v);
              },
              activeColor: PoraColors.primary,
              radioBackgroundColor: WidgetStateColor.resolveWith((_) {
                return Theme.of(context).colorScheme.onSurface;
              }),
              secondary: Icon(entry.$2),
              title: Text(_label(l, entry.$1), style: PoraText.itemTitle),
            ),
        ],
      ),
    );
  }

  String _label(dynamic l, ThemeMode m) => switch (m) {
    ThemeMode.system => l.themeSystem,
    ThemeMode.light => l.themeLight,
    ThemeMode.dark => l.themeDark,
  };
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  static const _labels = {
    'ru': 'Русский',
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
  };

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<LocalizationStore>();
    return Observer(
      builder: (context) => PoraRowsCard(
        children: [
          for (final locale in Locales.supportedLocales)
            RadioListTile<String>.adaptive(
              value: locale.languageCode,

              groupValue: store.currentLocale,
              onChanged: (v) {
                if (v != null) store.setCurrentLocale(newLocale: v);
              },
              activeColor: PoraColors.primary,
              title: Text(
                _labels[locale.languageCode] ?? locale.languageCode,
                style: PoraText.itemTitle,
              ),
            ),
        ],
      ),
    );
  }
}

class _PushTokenRow extends StatelessWidget {
  const _PushTokenRow({required this.onResync});
  final VoidCallback onResync;

  @override
  Widget build(BuildContext context) {
    final token = NotificationService.instance.fcmToken;
    final preview = token == null
        ? '—'
        : '${token.substring(0, token.length.clamp(0, 12))}…';
    return ListTile(
      leading: const Icon(PhosphorIconsRegular.key),
      title: Text(context.l10n.pushToken, style: PoraText.itemTitle),
      subtitle: Text(
        preview,
        style: PoraText.small.copyWith(color: context.colors.textSubtle),
      ),
      trailing: TextButton(
        onPressed: onResync,
        child: Text(context.l10n.resync),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.status, required this.onRequest});
  final AuthorizationStatus? status;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (label, color, canRequest) = switch (status) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => (l.granted, PoraColors.success, false),
      AuthorizationStatus.denied => (l.denied, PoraColors.danger, true),
      _ => (l.notDetermined, context.colors.textMuted, true),
    };
    return ListTile(
      leading: const Icon(PhosphorIconsRegular.bell),
      title: Text(l.notificationsPermission, style: PoraText.itemTitle),
      subtitle: Text(label, style: PoraText.small.copyWith(color: color)),
      trailing: canRequest
          ? TextButton(onPressed: onRequest, child: Text(l.requestPermission))
          : const Icon(Icons.check, color: PoraColors.success),
    );
  }
}
