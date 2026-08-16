import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/features/tutorial/data/tutorial_prefs.dart';
import 'package:pora/core/features/tutorial/presentation/widgets/tutorial_illustration.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:pora/core/internal/router/guard/auth_state.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';

/// Host-экран tutorial'а. Держит PageView, dots и Skip/Next/Done.
/// Иллюстрации — в `steps/*_step.dart`, диспетчер — `TutorialIllustration`.
/// Открывается после brief'а (первый вход) и опционально из настроек.
@RoutePage()
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key, this.fromSettings = false});

  /// Если `true` — по завершению просто pop'аем (уже в приложении).
  /// Если `false` — идём в MainShell и выдаём auth (первый вход).
  final bool fromSettings;

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final _pageController = PageController();
  int _index = 0;

  static const _stepsCount = 9;

  /// Порядок должен совпадать со switch'ем в `TutorialIllustration.build`.
  List<_StepData> _steps(BuildContext ctx) {
    final l = ctx.l10n;
    return [
      _StepData(l.tutorialInviteTitle, l.tutorialInviteBody),
      _StepData(l.tutorialConnectTitle, l.tutorialConnectBody),
      _StepData(l.tutorialAddTitle, l.tutorialAddBody),
      _StepData(l.tutorialEditTitle, l.tutorialEditBody),
      _StepData(l.tutorialNotifyTitle, l.tutorialNotifyBody),
      _StepData(l.tutorialDeleteTitle, l.tutorialDeleteBody),
      _StepData(l.tutorialAiTitle, l.tutorialAiBody),
      _StepData(l.tutorialSettingsTitle, l.tutorialSettingsBody),
      _StepData(l.tutorialOutroTitle, l.tutorialOutroBody),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await GetIt.I<TutorialPrefs>().markSeen();
    if (!mounted) return;
    if (widget.fromSettings) {
      context.router.maybePop();
    } else {
      GetIt.I<AuthState>().setAuthenticated();
      context.router.replaceAll([const MainShellRoute()]);
    }
  }

  void _next() {
    if (_index == _stepsCount - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = _steps(context);
    final isLast = _index == _stepsCount - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onSkip: _finish,
              skipLabel: l.tutorialSkip,
              title: l.tutorialTitle,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _stepsCount,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PoraSpacing.screen,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: PoraSpacing.lg),
                      TutorialIllustration(step: i),
                      const SizedBox(height: PoraSpacing.xl),
                      Text(
                        steps[i].title,
                        style: PoraText.display,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PoraSpacing.md),
                      Text(
                        steps[i].body,
                        style: PoraText.subtitle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _Dots(count: _stepsCount, index: _index),
            const SizedBox(height: PoraSpacing.lg),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                PoraSpacing.xxl,
              ),
              child: PoraPrimaryButton(
                label: isLast ? l.tutorialDone : l.tutorialNext,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  const _StepData(this.title, this.body);
  final String title;
  final String body;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onSkip,
    required this.skipLabel,
    required this.title,
  });

  final VoidCallback onSkip;
  final String skipLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PoraSpacing.screen,
        PoraSpacing.sm,
        PoraSpacing.screen,
        0,
      ),
      child: Row(
        children: [
          Text(title, style: PoraText.itemTitle),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            child: Text(
              skipLabel,
              style: PoraText.small.copyWith(color: context.colors.textSubtle),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? PoraColors.primary : c.border,
              borderRadius: PoraRadii.pill,
            ),
          ),
      ],
    );
  }
}
