import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/features/auth_and_validation/presentation/controller/auth_store.dart';
import 'package:pora/app/features/auth_and_validation/presentation/controller/privacy_store.dart';
import 'package:pora/app/features/auth_and_validation/presentation/widgets/pinput.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';

@RoutePage()
class OTPConfirmationPage extends StatelessWidget {
  // ignore: non_constant_identifier_names
  const OTPConfirmationPage({
    super.key,
    required this.authStore,
    // ignore: non_constant_identifier_names
    required this.OTPController,
    required this.isPhone,
    required this.destinationController,
    required this.privacyStore,
  });
  final AuthStore authStore;
  final bool isPhone;
  final PrivacyStore privacyStore;
  final TextEditingController destinationController;
  // ignore: non_constant_identifier_names
  final TextEditingController OTPController;
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
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const OnboardingProgressHeader(step: 2),
                const SizedBox(height: 28),
                //! Localize
                Text('Осталось немного!', style: PoraText.display),
                const SizedBox(height: PoraSpacing.md + 5),
                //! Localize
                Column(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      'Введите код отправленный на ',
                      style: PoraText.subtitle,
                    ),
                    Text(
                      '${destinationController.text}',
                      style: PoraText.caption,
                    ),
                  ],
                ),
                const SizedBox(height: PoraSpacing.xxl),
    
                //! pinput
                PinputRoundedWithCustomCursor(
                  onCompleted: (value) => authStore.verifyOtp(
                    destination: destinationController.text,
                    code: OTPController.text,
                  ),
                  controller: OTPController,
                ),
    
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .center,
                  children: [
                    Text(
                      'Не получили код?',
                      style: PoraText.subtitle.copyWith(fontSize: 14),
                    ),
                    Text(
                      'Отправить еще раз',
                      style: PoraText.subtitle.copyWith(
                        color: PoraColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
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
                Observer(
                  builder: (_) {
                    return PoraPrimaryButton(
                      label: 'Проверить код',
                      isLoading: authStore.isLoading,
                      onPressed: () async {
                        await authStore.verifyOtp(
                          destination: destinationController.text,
                          code: OTPController.text,
                        ).whenComplete(
                          () {
                            
                            if (authStore.success == true && context.mounted) {
                              context.router.navigate(
                                const FamiliesRoute()
                              );
                            }else {
                              if(!context.mounted) return;
                              PoraSnackbar.show(context, message: authStore.scaffoldMessage ?? 'Ошибка');
                              authStore.success = null;
                            }
                          },
                        );
                      },
                    );
                  },
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
