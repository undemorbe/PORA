import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';
import 'package:pora/core/internal/widgets/pora_circle_icon_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: PoraTheme.light, home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders icon and fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        PoraCircleIconButton(
          icon: PhosphorIconsRegular.bell,
          onTap: () => taps++,
        ),
      ),
    );
    expect(find.byIcon(PhosphorIconsRegular.bell), findsOneWidget);
    await tester.tap(find.byType(PoraCircleIconButton));
    expect(taps, 1);
  });

  testWidgets('badge shows exact count', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PoraCircleIconButton(
          icon: PhosphorIconsRegular.bell,
          onTap: () {},
          badgeCount: 3,
        ),
      ),
    );
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('badge caps at 9+', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PoraCircleIconButton(
          icon: PhosphorIconsRegular.bell,
          onTap: () {},
          badgeCount: 25,
        ),
      ),
    );
    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('no badge when count is 0/null', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PoraCircleIconButton(
          icon: PhosphorIconsRegular.bell,
          onTap: () {},
          badgeCount: 0,
        ),
      ),
    );
    expect(find.textContaining('0'), findsNothing);
  });
}
