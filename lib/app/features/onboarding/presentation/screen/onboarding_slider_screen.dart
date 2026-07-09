import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_slide_view.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/router/app_router.gr.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';
import 'package:pora/app/internal/widgets/pora_buttons.dart';

/// Вступительный онбординг-слайдер (свайп 3 слайда).
@RoutePage()
class OnboardingSliderPage extends StatefulWidget {
  const OnboardingSliderPage({super.key});

  @override
  State<OnboardingSliderPage> createState() => _OnboardingSliderPageState();
}

class _OnboardingSliderPageState extends State<OnboardingSliderPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slideCount = 3;

  List<OnboardingSlide> _slidesOf(BuildContext context) {
    final l = context.l10n;
    return [
      OnboardingSlide(
        const Color(0xFFFCEBC9),
        '🥗',
        l.onboardingSlide1Title,
        l.onboardingSlide1Body,
      ),
      OnboardingSlide(
        const Color(0xFFE6F0E6),
        '👩‍❤️‍👨',
        l.onboardingSlide2Title,
        l.onboardingSlide2Body,
      ),
      OnboardingSlide(
        const Color(0xFFFAE7DF),
        '🔮',
        l.onboardingSlide3Title,
        l.onboardingSlide3Body,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slideCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else if (_index == _slideCount - 1) {
      context.router.navigate(const AuthRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final slides = _slidesOf(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                6,
                PoraSpacing.screen,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.router.navigate(const AuthRoute());
                    },
                    child: Text(
                      l.onboardingSkip,
                      style: PoraText.bodyLarge.copyWith(
                        color: PoraColors.textSubtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: slides.length,
                itemBuilder: (context, i) =>
                    OnboardingSlideView(slide: slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? PoraColors.primary
                          : const Color(0xFFE0D5C4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PoraSpacing.screen,
                0,
                PoraSpacing.screen,
                40,
              ),
              child: PoraPrimaryButton(
                label: _index == slides.length - 1
                    ? l.onboardingStart
                    : l.onboardingNext,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
