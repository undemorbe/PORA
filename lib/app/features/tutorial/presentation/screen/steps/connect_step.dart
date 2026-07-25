import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_finger.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_frame.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_row_tile.dart';
import 'package:pora/app/features/tutorial/presentation/widgets/tutorial_ticker.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/context_colors.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Шаг «Присоединиться»: пришло сообщение с invite-ссылкой →
/// тап по ссылке → app deep-link'ом добавляет пользователя в общий список.
///
/// Реальная фича: route `/api/families/join/:link_code` → `InvitationConnectRoute`.
class ConnectStep extends StatelessWidget {
  const ConnectStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 2800),
        builder: (context, t) {
          final phase = _ConnectPhase.from(t);
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 40,
                top: 8,
                child: Opacity(
                  opacity: 1 - phase.groupOpacity,
                  child: _InviteMessage(
                    text: l.tutorialSampleInviteMessage,
                    code: l.tutorialSampleInviteCode,
                    linkHighlight: phase.linkHighlight,
                  ),
                ),
              ),
              if (phase.showFinger)
                TutorialFinger(
                  position: const Offset(140, 44),
                  scale: phase.linkHighlight ? 0.85 : 1.0,
                ),
              Positioned(
                left: 0,
                right: 0,
                top: 140 + (1 - phase.groupOpacity) * 24,
                child: Opacity(
                  opacity: phase.groupOpacity,
                  child: _JoinedGroupTile(title: l.tutorialSampleGroupFamily),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Фазы шага:
///   0..0.35 — сообщение видно, палец подъезжает
///   0.35..0.55 — tap (линк подсвечивается)
///   0.55..1 — сообщение затухает, карточка группы всплывает снизу
class _ConnectPhase {
  const _ConnectPhase({
    required this.linkHighlight,
    required this.groupOpacity,
    required this.showFinger,
  });

  final bool linkHighlight;
  final double groupOpacity;
  final bool showFinger;

  factory _ConnectPhase.from(double t) {
    final linkHighlight = t > 0.35 && t < 0.55;
    final groupOpacity = t < 0.55
        ? 0.0
        : Curves.easeOutCubic.transform(((t - 0.55) / 0.45).clamp(0.0, 1.0));
    return _ConnectPhase(
      linkHighlight: linkHighlight,
      groupOpacity: groupOpacity,
      showFinger: t < 0.6,
    );
  }
}

/// Пузырь-сообщение с текстом и invite-ссылкой (кликабельным превью).
class _InviteMessage extends StatelessWidget {
  const _InviteMessage({
    required this.text,
    required this.code,
    required this.linkHighlight,
  });

  final String text;
  final String code;
  final bool linkHighlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(PoraSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: PoraRadii.md,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: PoraText.small.copyWith(color: c.ink)),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(
              horizontal: PoraSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: linkHighlight
                  ? PoraColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: PoraRadii.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIconsRegular.link,
                  size: 14,
                  color: PoraColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'pora.app/j/$code',
                  style: PoraText.small.copyWith(
                    color: PoraColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedGroupTile extends StatelessWidget {
  const _JoinedGroupTile({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return TutorialRowTile(
      title: title,
      leading: const Icon(
        PhosphorIconsFill.usersThree,
        size: 22,
        color: PoraColors.primary,
      ),
      trailing: const Icon(
        PhosphorIconsRegular.check,
        size: 20,
        color: PoraColors.success,
      ),
    );
  }
}
