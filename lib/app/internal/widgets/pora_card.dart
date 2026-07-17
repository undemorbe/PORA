import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Скруглённая карточка-поверхность с мягкой тенью.
/// [onTap] — если задан, оборачивается в `Material + InkWell` (ripple).
class PoraCard extends StatelessWidget {
  const PoraCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = PoraRadii.card,
    this.color,
    this.imageUrl,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final String? imageUrl;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.surface;
    final decorated = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        boxShadow: PoraShadows.card,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: child,
    );
    if (onTap == null) return decorated;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: PoraColors.primaryTint,
        highlightColor: PoraColors.primaryTint.withValues(alpha: 0.3),
        child: decorated,
      ),
    );
  }
}
