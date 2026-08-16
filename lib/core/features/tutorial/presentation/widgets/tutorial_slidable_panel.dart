import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';

/// Панель-действие, выезжающая из-под tile при свайпе (invite/delete).
///
/// Рендерится ЗА tile'ом в `Stack`, её [width] расширяется по мере свайпа —
/// действие «проявляется» естественным образом.
///
/// [side]:
///   - `Alignment.centerLeft` — иконка/label жмутся к левому краю (действие
///     слева, свайп tile вправо).
///   - `Alignment.centerRight` — к правому (действие справа, свайп влево).
class TutorialSlidablePanel extends StatelessWidget {
  const TutorialSlidablePanel({
    super.key,
    required this.width,
    required this.color,
    required this.icon,
    required this.side,
    this.label,
  });

  final double width;
  final Color color;
  final IconData icon;
  final Alignment side;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.clamp(0.0, double.infinity),
      height: 52,
      alignment: side,
      padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.md),
      decoration: BoxDecoration(color: color, borderRadius: PoraRadii.md),
      child: Row(
        mainAxisAlignment: side == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: PoraText.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ],
      ),
    );
  }
}
