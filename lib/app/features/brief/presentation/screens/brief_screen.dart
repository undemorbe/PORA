import 'package:auto_route/auto_route.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';

/// Онбординг-бриф — «Что у вас часто заканчивается?». Решает cold start
/// движка предсказаний: пользователь отмечает частые продукты.
@RoutePage()
class BriefPage extends StatelessWidget {
  const BriefPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final products = <(String, String, bool)>[
      ('🥛', l.briefItemMilk, true),
      ('🍞', l.briefItemBread, true),
      ('🥚', l.briefItemEggs, false),
      ('☕', l.briefItemCoffee, true),
      ('🧀', l.briefItemCheese, false),
      ('🍌', l.briefItemBananas, false),
      ('🧈', l.briefItemButter, false),
      ('💧', l.briefItemWater, false),
      ('🥦', l.briefItemVegetables, false),
      ('🍅', l.briefItemTomatoes, false),
      ('🍝', l.briefItemPasta, false),
      ('🍗', l.briefItemChicken, false),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  PoraSpacing.screen,
                  PoraSpacing.sm,
                  PoraSpacing.screen,
                  PoraSpacing.sm,
                ),
                children: [
                  const OnboardingProgressHeader(step: 1),

                  const SizedBox(height: PoraSpacing.lg),

                  Text(l.briefTitle, style: PoraText.display),
                  const SizedBox(height: PoraSpacing.md),
                  Text(l.briefSubtitle, style: PoraText.subtitle),
                  const SizedBox(height: PoraSpacing.xxl),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        for (final (emoji, name, selected) in products)
                          PoraChip(
                            label: name,
                            leading: emoji,
                            selected: selected,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      context.router.navigate(HomeRoute());
                    },
                    child: Text(
                      l.briefSkip,
                      style: PoraText.bodyLarge.copyWith(
                        color: PoraColors.textSubtle,
                      ),
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.sm),
                  PoraPrimaryButton(
                    label: l.briefNext,
                    onPressed: () => context.router.push(HomeRoute()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
