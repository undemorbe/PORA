import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Круглый аватар: сетевое фото если есть, иначе инициал на цветном фоне.
class PoraAvatar extends StatelessWidget {
  const PoraAvatar({
    super.key,
    required this.initial,
    this.color,
    this.size = PoraSizes.avatarXs,
    this.ring,
    this.imageUrl,
  });

  final String initial;
  final Color? color;
  final double size;
  final String? imageUrl;

  /// Обводка (для перекрывающихся аватаров — цвет фона).
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final borderSide = ring != null
        ? Border.all(color: ring!, width: 2)
        : null;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? PoraColors.primary,
        shape: BoxShape.circle,
        border: borderSide,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: kPoraFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
          color: PoraColors.inkInverse,
        ),
      ),
    );

    if (!hasImage) return fallback;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.of(context).devicePixelRatio).round(),
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
      ),
    );
  }
}
