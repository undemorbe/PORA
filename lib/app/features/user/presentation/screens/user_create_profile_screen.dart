import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/features/user/presentation/store/user_profile_store.dart';
import 'package:pora/app/features/user/presentation/widgets/profile_photo_picker.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_snackbar.dart';

@RoutePage()
class UserCreateProfilePage extends StatefulWidget {
  const UserCreateProfilePage({super.key});

  @override
  State<UserCreateProfilePage> createState() => _UserCreateProfilePageState();
}

class _UserCreateProfilePageState extends State<UserCreateProfilePage> {
  final UserProfileStore userStore = UserProfileStore();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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
                  const OnboardingProgressHeader(step: 3),
                  const SizedBox(height: 28),
                  Text(
                    context.l10n.userCreateProfileTitle,
                    style: PoraText.display,
                  ),
                  const SizedBox(height: PoraSpacing.md),
                  Text(
                    context.l10n.userCreateProfileSubtitle,
                    style: PoraText.subtitle,
                  ),
                  const SizedBox(height: PoraSpacing.xxl),
                  // avatar
                  Center(
                    child: ProfilePhotoPickerUserCreation(
                      onTap: () async {
                        await userStore.setProfileImage();
                      },
                      userProfileStore: userStore,
                    ),
                  ),

                  const SizedBox(height: PoraSpacing.xxl),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    style: PoraText.bodyLarge.copyWith(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: context.l10n.userCreateProfileNameHint,
                    ),
                    controller: nameController,
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
                    onPressed: () async {
                      await userStore.pushUserInformation(
                        name: nameController.text,
                      );
                      if (!context.mounted) return;
                      context.router.push(const BriefRoute());
                    },
                    child: Text(
                      context.l10n.userCreateProfileSkip,
                      style: PoraText.bodyLarge.copyWith(
                        color: PoraColors.textSubtle,
                      ),
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.sm),
                  PoraPrimaryButton(
                    label: context.l10n.userCreateProfileNext,
                    onPressed: () async {
                      if (context.mounted && nameController.text.isNotEmpty) {
                        await userStore.pushUserInformation(
                          name: nameController.text,
                        );
                        if (!context.mounted) return;
                        context.router.push(const BriefRoute());
                      } else {
                        PoraSnackbar.show(
                          context,
                          message: context.l10n.userCreateProfileNameRequired,
                        );
                      }
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
