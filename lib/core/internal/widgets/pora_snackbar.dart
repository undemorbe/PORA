import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Тип уведомления — задаёт акцентный цвет и иконку по умолчанию.
enum PoraSnackType { success, failure, info }

extension _PoraSnackTypeStyle on PoraSnackType {
  Color get accent => switch (this) {
    PoraSnackType.success => PoraColors.success,
    PoraSnackType.failure => PoraColors.danger,
    PoraSnackType.info => PoraColors.primary,
  };

  IconData get icon => switch (this) {
    PoraSnackType.success => PhosphorIconsFill.checkCircle,
    PoraSnackType.failure => PhosphorIconsFill.warningCircle,
    PoraSnackType.info => PhosphorIconsFill.info,
  };
}

/// Фирменный снекбар Pora: плавающая карточка с акцентной полосой,
/// иконкой в тонированном круге и сообщением.
///
/// ```dart
/// PoraSnackbar.show(context, message: 'Код отправлен', type: PoraSnackType.success);
/// ```
abstract final class PoraSnackbar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    PoraSnackType type = PoraSnackType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    return messenger.showSnackBar(
      build(message: message, type: type, icon: icon, duration: duration),
    );
  }

  /// Собирает [SnackBar] без показа — для тонкой настройки на месте.
  static SnackBar build({
    required String message,
    PoraSnackType type = PoraSnackType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    return SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(PoraSpacing.lg),
      dismissDirection: DismissDirection.horizontal,
      content: _PoraSnackContent(
        message: message,
        accent: type.accent,
        icon: icon ?? type.icon,
      ),
    );
  }
}

class _PoraSnackContent extends StatelessWidget {
  const _PoraSnackContent({
    required this.message,
    required this.accent,
    required this.icon,
  });

  final String message;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: PoraRadii.card,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: PoraRadii.card,
          border: Border.all(color: c.border),
          boxShadow: PoraShadows.card,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Акцентная полоса слева.
              Container(width: 6, color: accent),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: PhosphorIcon(icon, size: 22, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        style: PoraText.body.copyWith(
                          color: c.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
