import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/app/features/auth_and_validation/presentation/controller/auth_store.dart';
import 'package:pora/app/features/auth_and_validation/presentation/widgets/auth_destination_field.dart';
import 'package:pora/app/features/auth_and_validation/presentation/controller/privacy_store.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/extensions/string_validation_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';

@RoutePage()
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthStore authStore = AuthStore();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  int whichFieldIsActive = 0;
  @override
  Widget build(BuildContext context) {
    final PrivacyStore privacyStore = PrivacyStore();
    final l = context.l10n;
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
                  const OnboardingProgressHeader(step: 1),
                  const SizedBox(height: 28),
                  Text(l.authTitle, style: PoraText.display),
                  const SizedBox(height: PoraSpacing.md),
                  Text(l.authSubtitle, style: PoraText.subtitle),
                  const SizedBox(height: PoraSpacing.xxl),
                  AuthDestinationField(controller: destinationController, ),
                  const SizedBox(height: PoraSpacing.xxl),
                  
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
                      l.authPrivatePolicy,
                      style: PoraText.small.copyWith(
                        height: 1.4,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.md),
                  PoraPrimaryButton(
                    label: l.authJoinButton,
                    onPressed: () async {
                      await authStore
                          .sendOtp(destination: destinationController.text)
                          .whenComplete(() {
                            //! UPD WHEN authStore.success is not null
                            if ((authStore.success == true &&
                                    context.mounted) ||
                                (dotenv.getBool('DEBUG') && context.mounted)) {
                              context.router.navigate(
                                OTPConfirmationRoute(
                                  authStore: authStore,
                                  isPhone: destinationController.text
                                      .isValidPhone(destinationController.text),
                                  privacyStore: privacyStore,
                                  OTPController: otpController,
                                  destinationController: destinationController,
                                ),
                              );
                            } else {
                              if (!context.mounted) return;
                              PoraSnackbar.show(
                                context,
                                message: authStore.scaffoldMessage ?? l.commonError,
                              );
                              authStore.success == null;
                            }
                          });
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
