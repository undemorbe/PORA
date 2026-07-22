import 'package:auto_route/auto_route.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/brief/domain/entity/brief_product.dart';
import 'package:pora/app/features/brief/presentation/controller/brief_store.dart';
import 'package:pora/app/features/brief/presentation/widgets/creation_dialogue.dart';
import 'package:pora/app/features/brief/presentation/widgets/selection_chip.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_progress_header.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/guard/auth_state.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';

/// Онбординг-бриф — «Что у вас часто заканчивается?». Решает cold start
/// движка предсказаний: пользователь отмечает частые продукты.
@RoutePage()
class BriefPage extends StatelessWidget {
  const BriefPage({super.key});

  /// Завершение онбординга нового пользователя: выдаём авторизацию перед
  /// входом в защищённую зону, затем открываем главный экран.
  void _enterApp(BuildContext context) {
    GetIt.I<AuthState>().setAuthenticated();
    context.router.replaceAll([const MainShellRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final briefStore = GetIt.I<BriefStore>();
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
                            
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  final product = briefStore.allProducts
                                      .elementAt(index);
                                  return PoraSelectionChip(
                                    briefStore: briefStore,
                                    briefProductEntity: product,
                                  );
                                },
                                itemCount: briefStore.allProducts.length,
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
                    onPressed: () => _enterApp(context),
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
