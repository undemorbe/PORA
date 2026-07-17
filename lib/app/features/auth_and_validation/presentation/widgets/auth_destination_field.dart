import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/internal/extensions/l10n_extension.dart';
import 'package:pora/app/internal/extensions/string_extension.dart';
import 'package:pora/app/internal/formatters/email_input_formatter.dart';
import 'package:pora/app/internal/formatters/phone_input_formatter.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/theme/light_colors/app_colors.dart';

/// Режим ввода: телефон или почта.
enum AuthFieldMode { phone, email }

/// Умный форматтер: определяет режим по вводу (если не зафиксирован
/// вручную), применяет нужный форматтер и сообщает режим наверх.
class _SmartAuthFormatter extends TextInputFormatter {
  _SmartAuthFormatter({required this.forcedMode, required this.onResolved});

  final AuthFieldMode? Function() forcedMode;
  final ValueChanged<AuthFieldMode> onResolved;

  static const _phone = PhoneInputFormatter();
  static const _email = EmailInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final mode = forcedMode() ?? _detect(newValue.text);
    onResolved(mode);
    return mode == AuthFieldMode.phone
        ? _phone.formatEditUpdate(oldValue, newValue)
        : _email.formatEditUpdate(oldValue, newValue);
  }

  static AuthFieldMode _detect(String text) {
    if (text.isEmpty) return AuthFieldMode.phone;
    if (RegExp(r'[a-zA-Zа-яА-Я@]').hasMatch(text)) return AuthFieldMode.email;
    return AuthFieldMode.phone;
  }
}

class AuthDestinationField extends StatefulWidget {
  const   AuthDestinationField({
    super.key,
    this.initMode,
    required this.controller,
    this.onModeChanged,
  });
  final bool? initMode;
  final TextEditingController controller;
  final ValueChanged<AuthFieldMode>? onModeChanged;

  @override
  State<AuthDestinationField> createState() => _AuthDestinationFieldState();
}

class _AuthDestinationFieldState extends State<AuthDestinationField> {
  // AuthFieldMode _mode = AuthFieldMode.phone;
  late AuthFieldMode _mode = widget.initMode == true
      ? AuthFieldMode.email
      : AuthFieldMode.phone;

  bool _manual = false;

  late final _SmartAuthFormatter _formatter = _SmartAuthFormatter(
    forcedMode: () => _manual ? _mode : null,
    onResolved: _onModeResolved,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() => setState(() {}); // подсветка валидности

  void _onModeResolved(AuthFieldMode mode) {
    if (mode == _mode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _manual || _mode == mode) return;
      setState(() => _mode = mode);
      widget.onModeChanged?.call(mode);
    });
  }

  void _toggleMode() {
    final next = _mode == AuthFieldMode.phone
        ? AuthFieldMode.email
        : AuthFieldMode.phone;
    setState(() {
      _manual = true;
      _mode = next;
    });
    widget.onModeChanged?.call(next);
    final reformatted = next == AuthFieldMode.phone
        ? PhoneInputFormatter.format(widget.controller.text)
        : EmailInputFormatter.format(widget.controller.text);
    widget.controller.value = TextEditingValue(
      text: reformatted,
      selection: TextSelection.collapsed(offset: reformatted.length),
    );
  }

  bool get _isPhone => _mode == AuthFieldMode.phone;

  bool get _isValid {
    final t = widget.controller.text;
    if (t.isEmpty) return false;
    return _isPhone ? t.isValidPhone(t) : t.isValidEmail(t);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isValid ? PoraColors.success : PoraColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: !_isPhone,
          style: PoraText.bodyLarge.copyWith(fontSize: 18),
          inputFormatters: [_formatter],
          decoration: InputDecoration(
            hintText: _isPhone ? '+7 900 000-00-00' : 'you@example.com',
            prefixIcon: _ModeToggleButton(
              isPhone: _isPhone,
              onTap: _toggleMode,
              iconColor: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.isPhone,
    required this.onTap,
    required this.iconColor,
  });

  final bool isPhone;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: isPhone
          ? context.l10n.authSwitchToEmail
          : context.l10n.authSwitchToPhone,
      splashRadius: 22,
      icon: _AnimatedSwap(
        child: PhosphorIcon(
          key: ValueKey(isPhone),
          isPhone
              ? PhosphorIconsRegular.phone
              : PhosphorIconsRegular.envelopeSimple,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }
}

class _AnimatedSwap extends StatelessWidget {
  const _AnimatedSwap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1).animate(anim),
          child: RotationTransition(
            turns: Tween<double>(begin: -0.18, end: 0).animate(anim),
            child: child,
          ),
        ),
      ),
      child: child,
    );
  }
}
