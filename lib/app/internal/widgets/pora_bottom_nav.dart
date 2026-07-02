import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

enum PoraTab { list, pora, order, profile }

/// Нижняя навигация приложения (Список · Пора · Заказ · Профиль).
class PoraBottomNav extends StatelessWidget {
  const PoraBottomNav({super.key, required this.current, this.onTap});

  final PoraTab current;
  final ValueChanged<PoraTab>? onTap;

  static const _items = <(PoraTab, IconData, String)>[
    (PoraTab.list, PhosphorIconsRegular.listChecks, 'Список'),
    (PoraTab.pora, PhosphorIconsRegular.clock, 'Пора'),
    (PoraTab.order, PhosphorIconsRegular.shoppingCart, 'Заказ'),
    (PoraTab.profile, PhosphorIconsRegular.user, 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: PoraSizes.tabBarHeight,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (tab, icon, label) in _items)
              Expanded(
                child: _Tab(
                  tab: tab,
                  icon: icon,
                  label: label,
                  active: tab == current,
                  onTap: onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  final PoraTab tab;
  final IconData icon;
  final String label;
  final bool active;
  final ValueChanged<PoraTab>? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? PoraColors.primary : PoraColors.textSubtle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: PoraText.micro.copyWith(color: color)),
        ],
      ),
    );
  }
}
