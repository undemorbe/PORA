import 'package:auto_route/auto_route.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:flutter/material.dart';
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

  static const _products = <(String, String, bool)>[
    ('🥛', 'Молоко', true),
    ('🍞', 'Хлеб', true),
    ('🥚', 'Яйца', false),
    ('☕', 'Кофе', true),
    ('🧀', 'Сыр', false),
    ('🍌', 'Бананы', false),
    ('🧈', 'Масло', false),
    ('💧', 'Вода', false),
    ('🥦', 'Овощи', false),
    ('🍅', 'Помидоры', false),
    ('🍝', 'Паста', false),
    ('🍗', 'Курица', false),
  ];

  @override
  Widget build(BuildContext context) {
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

                  Text(
                    'Что у вас часто заканчивается?',
                    style: PoraText.display,
                  ),
                  const SizedBox(height: PoraSpacing.md),
                  Text(
                    'Отметьте продукты — Pora напомнит вовремя. Это можно пропустить.',
                    style: PoraText.subtitle,
                  ),
                  const SizedBox(height: PoraSpacing.xxl),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        for (final (emoji, name, selected) in _products)
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
                      'Пропустить',
                      style: PoraText.bodyLarge.copyWith(
                        color: PoraColors.textSubtle,
                      ),
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.sm),
                  PoraPrimaryButton(
                    label: 'Далее',
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
