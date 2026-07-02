import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pora/app/features/onboarding/presentation/widgets/onboarding_slide_view.dart';
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

  static const _slides = <OnboardingSlide>[
    OnboardingSlide(
      Color(0xFFFCEBC9),
      '🧾',
      'Рецепт → список\nза секунды',
      'Киньте ссылку на рецепт — Pora соберёт ингредиенты и уберёт то, что уже есть.',
    ),
    OnboardingSlide(
      Color(0xFFE6F0E6),
      '👩‍❤️‍👨',
      'Один список\nна двоих',
      'Добавляйте вместе — видно, кто что внёс. Партнёр захватит нужное по дороге домой.',
    ),
    OnboardingSlide(
      Color(0xFFFAE7DF),
      '🔮',
      'Pora знает,\nкогда пора',
      'По вашим покупкам подскажет, что скоро закончится, и закажет в один тап.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {},
                    child: Text(
                      'Пропустить',
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
                itemCount: _slides.length,
                itemBuilder: (context, i) =>
                    OnboardingSlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
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
                label: _index == _slides.length - 1 ? 'Начать' : 'Далее',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
