import 'package:auto_route/auto_route.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pora/core/features/brief/presentation/controller/brief_store.dart';
import 'package:pora/core/features/brief/presentation/widgets/brief_creation_dialogue.dart';
import 'package:pora/core/features/brief/presentation/widgets/selection_chip.dart';
import 'package:pora/core/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/core/features/tutorial/data/tutorial_prefs.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_chip.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';

/// Онбординг-бриф — «Что у вас часто заканчивается?». Решает cold start
/// движка предсказаний: пользователь отмечает частые продукты.
@RoutePage()
class BriefPage extends StatelessWidget {
  const BriefPage({super.key});

  /// Завершение онбординга нового пользователя. Если tutorial ещё не
  /// показывали — открываем его (`fromSettings: false` → он сам выдаст auth
  /// и уведёт в MainShell). Иначе идём в главный экран напрямую.
  Future<void> _enterApp(BuildContext context) async {
    final seen = await GetIt.I<TutorialPrefs>().hasSeen();
    if (!context.mounted) return;
    if (seen) {
      GetIt.I<AuthState>().setAuthenticated();
      context.router.replaceAll([const MainShellRoute()]);
    } else {
      context.router.replaceAll([TutorialRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final briefStore = GetIt.I<BriefStore>()..getBrief();
    final l = context.l10n;
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
                  const OnboardingProgressHeader(step: 4),

                  const SizedBox(height: PoraSpacing.lg),

                  Text(l.briefTitle, style: PoraText.display),
                  const SizedBox(height: PoraSpacing.md),
                  Text(l.briefSubtitle, style: PoraText.subtitle),
                  const SizedBox(height: PoraSpacing.xxl),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Observer(
                      builder: (_) {
                        return Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: [
                            ...briefStore.allProducts.map(
                              (product) => PoraSelectionChip(
                                briefStore: briefStore,
                                briefProductEntity: product,
                              ),
                            ),

                            PoraChip(
                              label: context.l10n.briefAddYourOwn,
                              leading: '+',
                              onTap: () async {
                                await showAdaptiveDialog(
                                  context: context,
                                  builder: (context) {
                                    return BriefCreationDialogue(
                                      briefStore: briefStore,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
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
                    onPressed: () => _enterApp(context),
                    child: Text(
                      l.briefSkip,
                      style: PoraText.bodyLarge.copyWith(
                        color: context.colors.textSubtle,
                      ),
                    ),
                  ),
                  const SizedBox(height: PoraSpacing.sm),
                  PoraPrimaryButton(
                    label: l.briefNext,
                    onPressed: () {
                      if (briefStore.selectedProducts.isEmpty) {
                        PoraSnackbar.show(context, message: l.briefSnackBar);
                        return;
                      }
                      briefStore.postBrief();
                      _enterApp(context);
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
