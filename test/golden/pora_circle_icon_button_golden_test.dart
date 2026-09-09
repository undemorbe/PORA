import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';
import 'package:pora/core/internal/widgets/pora_circle_icon_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: PoraTheme.light,
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    body: Center(child: Padding(padding: const EdgeInsets.all(8), child: child)),
  ),
);

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testWidgets('circle button with badge — golden', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PoraCircleIconButton(
          icon: PhosphorIconsRegular.bell,
          onTap: () {},
          badgeCount: 3,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PoraCircleIconButton),
      matchesGoldenFile('goldens/circle_button_badge.png'),
    );
  });
}
