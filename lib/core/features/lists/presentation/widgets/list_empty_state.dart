import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

/// Пустое состояние списков/товаров: иконка в круге + заголовок + подпись.
/// Стиль совпадает с пустыми уведомлениями и `GroupsEmptyState`.
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = PhosphorIconsFill.shoppingCart,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PoraSpacing.screen,
          vertical: PoraSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              tween: Tween(begin: 0.6, end: 1.0),
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: PoraColors.primary),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            Text(
              title,
              style: PoraText.itemTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: PoraText.small.copyWith(color: c.textSubtle),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
