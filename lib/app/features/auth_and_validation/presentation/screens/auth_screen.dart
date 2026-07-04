import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/auth/presentation/controller/privacy_store.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';

@RoutePage()
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PrivacyStore privacyStore = PrivacyStore();
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
                  const OnboardingProgressHeader(step: 3),
                  const SizedBox(height: 28),
                  //! Localize
                  Text('Почти тут', style: PoraText.display),
                  const SizedBox(height: PoraSpacing.md),
                  Text(
                    'Введите номер телефона — пришлём код для входа.',
                    style: PoraText.subtitle,
                  ),
                  const SizedBox(height: PoraSpacing.xxl),
                  TextField(
                    keyboardType: TextInputType.phone,
                    style: PoraText.bodyLarge.copyWith(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: '+7 900 000-00-00',
                      prefixIcon: Icon(PhosphorIconsRegular.phone, size: 18),
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
                  InkWell(
                    onTap: () {
                      privacyStore.openPrivacy();
                    },
                    child: Text(
                      'Продолжая, вы принимаете Условия и Политику конфиденциальности',
                      style: PoraText.small.copyWith(
                        height: 1.4,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.md),
                  PoraPrimaryButton(label: 'Присоединиться', onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
