import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';

/// Шапка экрана: кнопка «назад» слева, заголовок по центру, опц. трейлинг справа.
class ScreenBackHeader extends StatelessWidget {
  const ScreenBackHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.router.maybePop(),
              child: const PhosphorIcon(
                PhosphorIconsRegular.caretLeft,
                size: 26,
              ),
            ),
          ),
          Text(title, style: PoraText.navTitle),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      ),
    );
  }
}
