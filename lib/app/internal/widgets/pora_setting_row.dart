import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Строка настройки/детали: иконка · подпись · трейлинг (шеврон/пилюля/тумблер).
class PoraSettingRow extends StatelessWidget {
  const PoraSettingRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final bool danger;
  final VoidCallback? onTap;

  /// Стандартный шеврон-трейлинг.
  static const chevron = PhosphorIcon(
    PhosphorIconsRegular.caretRight,
    size: 20,
    color: Color(0xFFC9BEAE),
  );

  @override
  Widget build(BuildContext context) {
    final color = danger ? PoraColors.danger : PoraColors.ink;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
            PhosphorIcon(icon, size: 18, color: color),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: PoraText.itemTitle.copyWith(color: color)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: PoraSpacing.xxs),
                      child: Text(subtitle!, style: PoraText.small),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
