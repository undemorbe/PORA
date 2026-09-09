import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_glass.dart';

/// Круглая кнопка-иконка (40x40): surface + border, либо iOS liquid-glass.
/// Опциональный badge (счётчик непрочитанных). Единый компонент для хедер-
/// кнопок (колокольчик, переключатель вида, insights) — убирает дубли.
class PoraCircleIconButton extends StatelessWidget {
  const PoraCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.size = 40,
    this.iconSize = 20,
    this.glass = false,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final double size;
  final double iconSize;

  /// iOS: обернуть в liquid-glass (на других платформах — solid).
  final bool glass;

  /// Если > 0 — рисуем красный badge со счётчиком.
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final iconWidget = Icon(icon, size: iconSize, color: iconColor ?? c.ink);

    final content = badgeCount != null && badgeCount! > 0
        ? Stack(
            alignment: Alignment.center,
            children: [iconWidget, _Badge(count: badgeCount!)],
          )
        : iconWidget;

    final solid = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.surface,
        shape: BoxShape.circle,
        border: Border.all(color: c.border, width: 1),
      ),
      child: content,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: glass
          ? PoraGlass(
              cornerRadius: size / 2,
              fallback: solid,
              child: SizedBox(
                width: size,
                height: size,
                child: Center(child: content),
              ),
            )
          : solid,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 6,
      top: 6,
      child: Container(
        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: const BoxDecoration(
          color: PoraColors.danger,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 9 ? '9+' : '$count',
          style: PoraText.micro.copyWith(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
