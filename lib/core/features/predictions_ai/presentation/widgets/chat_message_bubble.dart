import 'package:flutter/material.dart';
import 'package:pora/core/internal/theme/additional_constants.dart';
import 'package:pora/core/internal/theme/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/light_colors/app_colors.dart';

/// Пузырь сообщения в чате. Юзер — справа, primary bg; ассистент — слева, surface bg.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.fromUser,
  });

  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: child,
        ),
      ),
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(
              horizontal: PoraSpacing.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: fromUser ? PoraColors.primary : c.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(fromUser ? 16 : 4),
                bottomRight: Radius.circular(fromUser ? 4 : 16),
              ),
              border: fromUser ? null : Border.all(color: c.border, width: 1),
            ),
            child: SelectableText(
              text,
              style: PoraText.bodyLarge.copyWith(
                color: fromUser ? Colors.white : c.ink,
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
