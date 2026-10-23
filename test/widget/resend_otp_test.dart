import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/auth_and_validation/presentation/widgets/resend_otp.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('countdown starts immediately — code was just sent', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(ResendOtp(onTap: () => taps++)));
    final l10n = AppLocalizations.of(tester.element(find.byType(ResendOtp)))!;

    expect(find.text(l10n.otpResend), findsNothing);
    expect(find.textContaining(l10n.sendAgainAfter), findsOneWidget);

    await tester.pump(const Duration(seconds: 31));
    expect(find.text(l10n.otpResend), findsOneWidget);

    // двойной тап — один запрос, отсчёт снова пошёл
    await tester.tap(find.text(l10n.otpResend));
    await tester.pump();
    expect(find.text(l10n.otpResend), findsNothing);
    expect(taps, 1);

    await tester.pump(const Duration(seconds: 31));
  });
}
