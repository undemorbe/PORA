import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

enum PoraTab { list, pora, profile }

/// Плавающая нижняя навигация в стиле Apple:
///   - iOS → liquid-glass (реальный blur backdrop) через `liquid_glass_easy`.
///   - Android/other → tinted BackdropFilter капсула.
///
/// Виджет рисуется поверх контента (используй `Stack` или
/// `Scaffold.floatingActionButton…`). Адаптивная ширина: min(360, screen-32),
/// центрирован, с bottom padding = SafeArea + 16.
class PoraBottomNav extends StatelessWidget {
  const PoraBottomNav({super.key, required this.current, this.onTap});

  final PoraTab current;
  final ValueChanged<PoraTab>? onTap;

  static const _order = [PoraTab.list, PoraTab.pora, PoraTab.profile];

  static const _icons = {
    PoraTab.list: PhosphorIconsRegular.listChecks,
    PoraTab.pora: PhosphorIconsRegular.clock,
    PoraTab.profile: PhosphorIconsRegular.user,
  };

  static const _iconsFill = {
    PoraTab.list: PhosphorIconsFill.listChecks,
    PoraTab.pora: PhosphorIconsFill.clock,
    PoraTab.profile: PhosphorIconsFill.user,
  };

  String _label(BuildContext context, PoraTab t) => switch (t) {
        PoraTab.list => context.l10n.navList,
        PoraTab.pora => context.l10n.navPora,
        PoraTab.profile => context.l10n.navProfile,
      };

  int get _selectedIndex => _order.indexOf(current);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final w = MediaQuery.of(context).size.width;
    final barWidth = w > 400 ? 360.0 : w - 32.0;

    if (Platform.isIOS) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8 : 16),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: barWidth,
              child: LiquidGlassBottomNavBar(
                selectedIndex: _selectedIndex,
                onChanged: (i) => onTap?.call(_order[i]),
                width: barWidth,
                height: 64,
                margin: EdgeInsets.zero,
                items: [
                  for (final t in _order)
                    LiquidGlassTabBarItem(
                      icon: _icons[t]!,
                      selectedIcon: _iconsFill[t],
                      label: _label(context, t),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return _AndroidFloatingBar(
      width: barWidth,
      current: current,
      onTap: onTap,
      order: _order,
      icons: _icons,
      iconsFill: _iconsFill,
      labelOf: (t) => _label(context, t),
    );
  }
}

class _AndroidFloatingBar extends StatelessWidget {
  const _AndroidFloatingBar({
    required this.width,
    required this.current,
    required this.onTap,
    required this.order,
    required this.icons,
    required this.iconsFill,
    required this.labelOf,
  });

  final double width;
  final PoraTab current;
  final ValueChanged<PoraTab>? onTap;
  final List<PoraTab> order;
  final Map<PoraTab, IconData> icons;
  final Map<PoraTab, IconData> iconsFill;
  final String Function(PoraTab) labelOf;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: width,
                height: 64,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: c.border.withValues(alpha: 0.6),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (final t in order)
                      Expanded(
                        child: _Tab(
                          active: t == current,
                          icon: t == current ? iconsFill[t]! : icons[t]!,
                          label: labelOf(t),
                          onTap: () => onTap?.call(t),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? PoraColors.primary : context.colors.textSubtle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? PoraColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: PhosphorIcon(
                icon,
                size: 22,
                color: color,
                key: ValueKey(active),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: PoraText.micro.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
