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

/// Шаг «Пинг срочно нужно»: тап по красной кнопке «!» на продукте →
/// партнёр получает push с именем отправителя и телом уведомления.
///
/// Реальная фича: push через FCM участникам группы.
class NotifyStep extends StatelessWidget {
  const NotifyStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TutorialFrame(
      child: TutorialTicker(
        duration: const Duration(milliseconds: 2800),
        builder: (context, t) {
          final phase = _NotifyPhase.from(t);
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 4,
                child: _PushBanner(
                  sender: l.tutorialSamplePushSender,
                  body: l.tutorialSamplePushBody,
                  opacity: phase.pushOpacity,
                  offsetY: phase.pushOffsetY,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 120,
                child: TutorialRowTile(
                  title: l.tutorialSampleMilk,
                  trailing: _UrgentButton(pressed: phase.pressed),
                ),
              ),
              TutorialFinger(
                position: Offset(220 + (phase.pressed ? -3 : 0), 128),
                scale: phase.pressed ? 0.85 : 1.0,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Фазы анимации notify:
///   0..0.35 — палец подъезжает к «!»
///   0.35..0.55 — tap (кнопка «утоплена»)
///   0.55..1 — push-баннер съезжает сверху
class _NotifyPhase {
  const _NotifyPhase({
    required this.pressed,
    required this.pushOpacity,
    required this.pushOffsetY,
  });

  final bool pressed;
  final double pushOpacity;
  final double pushOffsetY;

  factory _NotifyPhase.from(double t) {
    final pressed = t > 0.35 && t < 0.55;
    final pushOpacity = t < 0.55
        ? 0.0
        : Curves.easeOut.transform(((t - 0.55) / 0.35).clamp(0.0, 1.0));
    final pushOffsetY = (1 - pushOpacity) * -24;
    return _NotifyPhase(
      pressed: pressed,
      pushOpacity: pushOpacity,
      pushOffsetY: pushOffsetY,
    );
  }
}

/// Красная круглая кнопка «!» справа в tile — семантика: пинг участнику.
class _UrgentButton extends StatelessWidget {
  const _UrgentButton({required this.pressed});
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: PoraColors.danger,
        shape: BoxShape.circle,
        boxShadow: pressed
            ? [
                BoxShadow(
                  color: PoraColors.danger.withValues(alpha: 0.5),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: const Icon(
        PhosphorIconsBold.exclamationMark,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

/// Системный push-баннер с аватаром отправителя, заголовком и телом.
class _PushBanner extends StatelessWidget {
  const _PushBanner({
    required this.sender,
    required this.body,
    required this.opacity,
    required this.offsetY,
  });

  final String sender;
  final String body;
  final double opacity;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PoraSpacing.md,
            vertical: PoraSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: PoraRadii.md,
            border: Border.all(color: c.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SenderAvatar(sender: sender),
              const SizedBox(width: PoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PORA',
                          style: PoraText.small.copyWith(
                            color: c.textSubtle,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•  ${_now()}',
                          style: PoraText.small.copyWith(color: c.textSubtle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sender,
                      style: PoraText.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(body, style: PoraText.small.copyWith(color: c.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Статичная «пуш-метка времени». Дата запрещена в hot-path'ах анимаций.
  String _now() => 'now';
}

class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.sender});
  final String sender;

  @override
  Widget build(BuildContext context) {
    final initial = sender.isEmpty ? '?' : sender.characters.first;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: PoraColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial.toUpperCase(),
        style: PoraText.small.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
