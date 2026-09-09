import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/widgets/pora_circle_icon_button.dart';

/// Переключатель список/сетка на главной. iOS → liquid-glass круг.
class ViewModeToggle extends StatelessWidget {
  const ViewModeToggle({super.key, required this.isGrid, required this.onTap});

  final bool isGrid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PoraCircleIconButton(
      icon: isGrid ? PhosphorIconsRegular.rows : PhosphorIconsRegular.gridFour,
      glass: true,
      onTap: onTap,
    );
  }
}
