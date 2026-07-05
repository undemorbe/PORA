import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:pora/app/internal/extensions/string_validation_extension.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// 6-значный OTP-ввод в фирменном стиле Pora.
class PinputRoundedWithCustomCursor extends StatefulWidget {
  const PinputRoundedWithCustomCursor({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  @override
  State<PinputRoundedWithCustomCursor> createState() =>
      _PinputRoundedWithCustomCursorState();
}

class _PinputRoundedWithCustomCursorState
    extends State<PinputRoundedWithCustomCursor> {
  static const int _length = 6;

  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: PoraSizes.fieldHeight,
      textStyle: PoraText.code.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: PoraColors.ink,
      ),
      decoration: BoxDecoration(
        color: PoraColors.surface,
        borderRadius: PoraRadii.input,
        border: Border.all(color: PoraColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: PoraColors.primaryTint,
      borderRadius: PoraRadii.input,
      border: Border.all(color: PoraColors.primary, width: 1.6),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: PoraColors.primaryTint,
      borderRadius: PoraRadii.input,
      border: Border.all(color: PoraColors.primary),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      color: PoraColors.surface,
      borderRadius: PoraRadii.input,
      border: Border.all(color: PoraColors.danger, width: 1.4),
    );

    return Form(
      key: _formKey,
      child: Pinput(
        length: _length,
        controller: widget.controller,
        focusNode: _focusNode,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
        separatorBuilder: (_) => const SizedBox(width: PoraSpacing.sm),
        keyboardType: TextInputType.number,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        closeKeyboardWhenCompleted: true,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        errorTextStyle: PoraText.small.copyWith(color: PoraColors.danger),
        validator: (value) {
          if (value == null || value.length < _length) {
            return 'Введите 6-значный код';
          }
          if (!value.isValidNumbers) {
            //!Localize
            return 'Код состоит только из цифр';
          }
          return null;
        },
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: PoraColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        onCompleted: (pin) {
          if (_formKey.currentState?.validate() == true) {
            widget.onCompleted?.call(pin);
          }
        },
      ),
    );
  }
}
