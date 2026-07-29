import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Шаг 9. Settings: крутящаяся шестерёнка + три переключателя, каждый — со своей фазой.
class SettingsStep extends StatelessWidget {
  const SettingsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 4000),
        builder: (context, t) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: _SpinningGear(angle: t * 6.283),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 84,
                child: _SwitchRow(
                  label: l.tutorialSampleToggleTheme,
                  on: (t * 2) % 1 > 0.5,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 138,
                child: _SwitchRow(
                  label: l.tutorialSampleToggleNotif,
                  on: ((t + 0.3) * 2) % 1 > 0.5,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 192,
                child: _SwitchRow(
                  label: l.tutorialSampleToggleConfirm,
                  on: ((t + 0.6) * 2) % 1 > 0.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpinningGear extends StatelessWidget {
  const _SpinningGear({required this.angle});
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: angle,
        child: const Icon(
          PhosphorIconsFill.gear,
          size: 56,
          color: PoraColors.primary,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.on});
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: PoraSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.md,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: PoraText.itemTitle)),
          _Knob(on: on),
        ],
      ),
    );
  }
}

class _Knob extends StatelessWidget {
  const _Knob({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 22,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: on ? PoraColors.primary : context.colors.border,
        borderRadius: PoraRadii.pill,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
