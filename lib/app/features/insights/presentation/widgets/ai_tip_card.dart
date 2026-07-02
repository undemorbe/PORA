import 'package:flutter/material.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Терракотовая карточка ИИ-совета по вкусу пользователя.
class AiTipCard extends StatelessWidget {
  const AiTipCard({
    super.key,
    required this.kicker,
    required this.title,
    required this.body,
    required this.action,
    this.onAction,
  });

  final String kicker;
  final String title;
  final String body;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PoraColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: PoraShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: PoraText.micro.copyWith(
              color: const Color(0xFFFCE6DE),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: PoraText.heading.copyWith(
              fontSize: 19,
              color: PoraColors.inkInverse,
            ),
          ),
          const SizedBox(height: PoraSpacing.sm),
          Text(
            body,
            style: PoraText.body.copyWith(
              color: const Color(0xFFFFF1EC),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: PoraColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  action,
                  style: PoraText.body.copyWith(
                    color: PoraColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
