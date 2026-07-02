import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';

/// Модель слайда онбординга.
class OnboardingSlide {
  const OnboardingSlide(this.color, this.emoji, this.title, this.body);

  final Color color;
  final String emoji;
  final String title;
  final String body;
}

/// Один слайд онбординг-слайдера.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: slide.color,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C4C38).withOpacity(0.14),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Text(slide.emoji, style: const TextStyle(fontSize: 74)),
          ),
          const SizedBox(height: 38),
          Text(
            slide.title,
            style: PoraText.display,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              slide.body,
              style: PoraText.subtitle.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
