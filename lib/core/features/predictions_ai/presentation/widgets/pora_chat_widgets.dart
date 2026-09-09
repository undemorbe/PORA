import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

// Презентационные под-виджеты чата PORA (вынесены из pora_chat_sheet.dart).

class ChatSheetGrabber extends StatelessWidget {
  const ChatSheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class ChatSheetHeader extends StatelessWidget {
  const ChatSheetHeader({super.key, required this.heroTag});
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        PoraSpacing.screen,
        PoraSpacing.sm,
        PoraSpacing.screen,
        PoraSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PoraColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsFill.sparkle,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: PoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.chatSheetTitle,
                  style: PoraText.itemTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l.chatSheetSubtitle,
                  style: PoraText.small.copyWith(
                    color: context.colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.x, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.samples,
    required this.onSampleTap,
  });

  final List<String> samples;
  final ValueChanged<String> onSampleTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(PoraSpacing.screen),
      children: [
        const SizedBox(height: PoraSpacing.lg),
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PoraColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            PhosphorIconsFill.sparkle,
            size: 30,
            color: PoraColors.primary,
          ),
        ),
        const SizedBox(height: PoraSpacing.md),
        Text(
          l.chatEmptyTitle,
          style: PoraText.itemTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l.chatEmptyExamplesLabel,
          style: PoraText.small.copyWith(color: c.textSubtle),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PoraSpacing.md),
        for (final s in samples)
          ChatSampleChip(text: s, onTap: () => onSampleTap(s)),
      ],
    );
  }
}

class ChatSampleChip extends StatelessWidget {
  const ChatSampleChip({super.key, required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(PoraSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsRegular.magicWand,
                size: 14,
                color: PoraColors.primary,
              ),
              const SizedBox(width: PoraSpacing.sm),
              Expanded(child: Text(text, style: PoraText.small)),
              const Icon(
                PhosphorIconsRegular.arrowRight,
                size: 14,
                color: PoraColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});
  @override
  State<ChatTypingIndicator> createState() => ChatTypingIndicatorState();
}

class ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: PoraSpacing.screen, bottom: 4),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              return Row(
                children: List.generate(3, (i) {
                  final p = ((_c.value + i * 0.2) % 1);
                  final s = 0.6 + 0.4 * (1 - (2 * p - 1).abs()).clamp(0, 1);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Transform.scale(
                      scale: s,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: PoraColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: PoraSpacing.sm),
          Text(
            context.l10n.chatTyping,
            style: PoraText.small.copyWith(color: context.colors.textSubtle),
          ),
        ],
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key, 
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: PoraSpacing.screen,
        right: PoraSpacing.screen,
        top: PoraSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + PoraSpacing.md,
      ),
      // Обычный TextField: цвета/бордер/hint берутся из InputDecorationTheme
      // (app_themes.dart). Send-кнопка вешается как suffixIcon.
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => onSend(),
        style: PoraText.bodyLarge,
        decoration: InputDecoration(
          hintText: context.l10n.chatInputHint,
          filled: true,
          fillColor: context.colors.surfaceAlt,
          prefixIcon: const Icon(
            PhosphorIconsRegular.sparkle,
            size: 18,
            color: PoraColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: context.colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: PoraColors.primary, width: 1.4),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChatSendBtn(busy: busy, onTap: onSend),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 40,
          ),
        ),
      ),
    );
  }
}

class ChatSendBtn extends StatelessWidget {
  const ChatSendBtn({super.key, required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: busy
              ? PoraColors.primary.withValues(alpha: 0.5)
              : PoraColors.primary,
          shape: BoxShape.circle,
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                PhosphorIconsBold.paperPlaneTilt,
                color: Colors.white,
                size: 18,
              ),
      ),
    );
  }
}
