import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Круглый аватар-инициал (метка «от кого», участники семьи, профиль).
class PoraAvatar extends StatelessWidget {
  const PoraAvatar({
    super.key,
    required this.initial,
    required this.color,
    this.size = PoraSizes.avatarXs,
    this.ring,
  });

  final String initial;
  final Color color;
  final double size;

  /// Обводка (для перекрывающихся аватаров — цвет фона).
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ring != null ? Border.all(color: ring!, width: 2) : null,
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
  }
}
