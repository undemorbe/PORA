import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/profile_photo_picker.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';

/// Онбординг, шаг 2 — имя и фото профиля.
@RoutePage()
class OnboardingProfilePage extends StatelessWidget {
  const OnboardingProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PoraSpacing.screen,
                  PoraSpacing.sm,
                  PoraSpacing.screen,
                  PoraSpacing.sm,
                ),
                children: [
                  const OnboardingProgressHeader(step: 2),
                  const SizedBox(height: 28),
                  Text('Как вас зовут?', style: PoraText.display),
                  const SizedBox(height: PoraSpacing.md),
                  Text(
                    'Добавьте имя и фото — их увидит партнёр в общем списке.',
                    style: PoraText.subtitle,
                  ),
                  const SizedBox(height: PoraSpacing.xxl),
                  Center(child: ProfilePhotoPicker(onTap: () {})),
                  const SizedBox(height: PoraSpacing.xxl),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    style: PoraText.bodyLarge.copyWith(fontSize: 18),
                    decoration: const InputDecoration(hintText: 'Ваше имя'),
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
                    onPressed: () =>
                        context.router.push(const OnboardingRegisterRoute()),
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
                    onPressed: () =>
                        context.router.push(const OnboardingRegisterRoute()),
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
