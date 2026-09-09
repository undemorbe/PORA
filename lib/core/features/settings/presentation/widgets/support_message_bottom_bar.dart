import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/constant/additional_constants.dart';
import 'package:pora/core/internal/theme/context_colors.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';
import 'package:pora/core/internal/widgets/pora_buttons.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';

/// Открывает модальный лист «Написать в поддержку».
/// [onSend] возвращает `true` при успешной отправке — лист сам закроется
/// и покажет подтверждение.
Future<void> showSupportMessageSheet(
  BuildContext context, {
  required Future<bool> Function(String text) onSend,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SupportMessageSheet(onSend: onSend),
  );
}

class _SupportMessageSheet extends StatefulWidget {
  const _SupportMessageSheet({required this.onSend});

  final Future<bool> Function(String text) onSend;

  @override
  State<_SupportMessageSheet> createState() => _SupportMessageSheetState();
}

class _SupportMessageSheetState extends State<_SupportMessageSheet> {
  final _controller = TextEditingController();
  bool _sending = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final l = context.l10n;
    if (text.isEmpty) {
      PoraSnackbar.show(context, message: l.supportEmptyError);
      return;
    }
    setState(() => _sending = true);
    final ok = await widget.onSend(text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      Navigator.of(context).pop();
      PoraSnackbar.show(context, message: l.supportSent);
    } else {
      PoraSnackbar.show(context, message: l.supportFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: PoraRadii.cardR),
        ),
        padding: const EdgeInsets.fromLTRB(
          PoraSpacing.lg,
          PoraSpacing.md,
          PoraSpacing.lg,
          PoraSpacing.lg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: PoraSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PoraSpacing.sm),
                    decoration: const BoxDecoration(
                      color: PoraColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIconsFill.lifebuoy,
                      color: PoraColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: PoraSpacing.md),
                  Expanded(
                    child: Text(l.supportMessage, style: PoraText.navTitle),
                  ),
                ],
              ),
              const SizedBox(height: PoraSpacing.sm),
              Text(
                l.supportMessageBottomSheetTopDescription,
                style: PoraText.small.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: PoraSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: PoraRadii.input,
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: PoraSpacing.md,
                  vertical: PoraSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: PoraSpacing.md),
                      child: Icon(
                        PhosphorIconsRegular.chatText,
                        color: colors.textSubtle,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: PoraSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_sending,
                        minLines: 3,
                        maxLines: 8,
                        maxLength: 1000,
                        textInputAction: TextInputAction.newline,
                        style: PoraText.body,
                        decoration: InputDecoration(
                          hintText: l.supportSheetHint,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PoraSpacing.md),
              PoraPrimaryButton(
                label: l.supportMessageBottomSheetSendButton,
                icon: PhosphorIconsFill.paperPlaneTilt,
                isLoading: _sending,
                onPressed: _hasText && !_sending ? _send : null,
              ),
              const SizedBox(height: PoraSpacing.sm),
              PoraOutlineButton(
                label: l.cancel,
                onPressed: _sending ? null : () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: PoraSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.envelopeSimple,
                    size: 14,
                    color: colors.textSubtle,
                  ),
                  const SizedBox(width: PoraSpacing.xs),
                  Flexible(
                    child: Text(
                      l.supportMessageBottomSheetUnderButtonText,
                      style: PoraText.micro.copyWith(color: colors.textSubtle),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
