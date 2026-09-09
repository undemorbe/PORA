import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/notifications/presentation/store/notifications_store.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_circle_icon_button.dart';

/// Колокольчик с live-badge непрочитанных — открывает `NotificationsRoute`.
/// Читает shared `NotificationsStore` из DI (одна инстанция на приложение).
class NotifBell extends StatelessWidget {
  const NotifBell({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<NotificationsStore>();
    return Observer(
      builder: (_) => PoraCircleIconButton(
        icon: PhosphorIconsRegular.bell,
        iconColor: PoraColors.primary,
        badgeCount: store.unreadCount,
        onTap: onTap,
      ),
    );
  }
}
