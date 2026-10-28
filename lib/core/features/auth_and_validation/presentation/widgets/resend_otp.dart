import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/theme/text/app_text_styles.dart';
import 'package:pora/core/internal/theme/themes_colors/light_colors/app_colors.dart';

class ResendOtp extends StatefulWidget {
  const ResendOtp({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  State<ResendOtp> createState() => _ResendOtpState();
}

class _ResendOtpState extends State<ResendOtp> {
  bool _isTapped = false;
  int _secondsRemain = 30;
  Timer? _timer;

  // Код уже отправлен при входе на экран — повтор раньше 30 с сервер
  // отклонит (лимит отправки OTP), поэтому отсчёт идёт сразу.
  @override
  void initState() {
    super.initState();
    _isTapped = true;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _decrementSecond();
    });
  }

  void _decrementSecond() {
    if (_secondsRemain <= 0) {
      setState(() {
        _isTapped = false;
        _timer?.cancel();
        _secondsRemain = 30;
      });
    } else {
      setState(() {
        _secondsRemain--;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTapped) {
      return Text(
        '${context.l10n.sendAgainAfter} $_secondsRemain',
        style: PoraText.body.copyWith(color: PoraColors.primaryDark),
      );
    } else {}
    return InkWell(
      hoverColor: PoraColors.primary,
      onTap: () {
        // Сразу блокируем повтор: двойной тап не шлёт второй запрос
        setState(() => _isTapped = true);
        _startTimer();
        widget.onTap();
      },
      child: Text(
        context.l10n.otpResend,
        style: PoraText.subtitle.copyWith(
          color: PoraColors.primary,
          fontSize: 18,
        ),
      ),
    );
  }
}
