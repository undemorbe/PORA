import 'package:flutter/material.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Круглый аватар: сетевое фото → fallback инициал на цветном фоне.
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
    final hasImage =
        imageUrl != null &&
        imageUrl!.isNotEmpty &&
        Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? PoraColors.primary,
        shape: BoxShape.circle,
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

    // Border живёт снаружи ClipOval — иначе обрезается.
    Widget wrap(Widget child) {
      if (ring == null) return child;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring!, width: 2),
        ),
        child: Padding(padding: const EdgeInsets.all(2), child: child),
      );
    }

    if (!hasImage) return wrap(fallback);

    return wrap(
      ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            Logger.talker.warning('Avatar image failed: $imageUrl → $error');
            return fallback;
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            // Плавное появление: fade fallback → image.
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: fallback,
            );
          },
        ),
      ),
    );
  }
}
