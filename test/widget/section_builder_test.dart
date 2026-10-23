import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/lists/data/models/lists/list_model.dart';
import 'package:pora/core/features/lists/data/models/lists/list_section_model.dart';
import 'package:pora/core/features/lists/data/models/lists/lists_array_model.dart';
import 'package:pora/core/features/lists/data/models/products/product_model.dart';
import 'package:pora/core/features/lists/presentation/store/lists_store.dart';
import 'package:pora/core/features/lists/presentation/widgets/section_builder.dart';
import 'package:pora/core/internal/localization/l10n/generated/app_localizations.dart';
import 'package:pora/core/internal/theme/themes_colors/app_themes.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: PoraTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

ProductModel _product({
  String id = 'p1',
  int quantity = 2,
  String unit = 'шт',
  int priority = 2,
}) => ProductModel(
  name: 'Milk',
  id: id,
  quantity: quantity,
  unit: unit,
  priority: priority,
  urgent: false,
  checked: false,
  remindEveryDay: null,
);

void main() {
  testWidgets('empty concrete list shows empty state, not an error', (
    tester,
  ) async {
    final store = ListStore();
    runInAction(
      () => store.list = const ListModel(id: 'l1', name: 'L', sections: []),
    );
    await tester.pumpWidget(
      _wrap(SectionBuilder(listStore: store, isPreview: false, lid: 'l1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No products yet'), findsOneWidget);
    expect(
      find.text('Tap “Add” to put the first one on the list'),
      findsOneWidget,
    );
    expect(find.text('Try refreshing'), findsNothing);
  });

  testWidgets('search without matches still says nothing found', (
    tester,
  ) async {
    final store = ListStore();
    runInAction(() {
      store.list = ListModel(
        id: 'l1',
        name: 'L',
        sections: [
          ListSectionModel(name: 'Молочное', items: [_product()]),
        ],
      );
      store.query = 'zzz';
    });
    await tester.pumpWidget(
      _wrap(SectionBuilder(listStore: store, isPreview: false, lid: 'l1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing found'), findsOneWidget);
    expect(find.text('No products yet'), findsNothing);
  });

  testWidgets('missing list after load keeps the refresh hint', (tester) async {
    final store = ListStore();
    await tester.pumpWidget(
      _wrap(SectionBuilder(listStore: store, isPreview: false, lid: 'l1')),
    );
    expect(find.text('Try refreshing'), findsOneWidget);
  });

  testWidgets('rows show localized priority, unit and section', (tester) async {
    final store = ListStore();
    runInAction(
      () => store.list = ListModel(
        id: 'l1',
        name: 'L',
        sections: [
          ListSectionModel(name: 'Молочное', items: [_product()]),
          ListSectionModel(
            name: 'Прочее',
            items: [_product(id: 'p2', unit: 'bottle', priority: 3)],
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      _wrap(SectionBuilder(listStore: store, isPreview: false, lid: 'l1')),
    );
    await tester.pumpAndSettle();

    // SectionLabel рисует заголовок капсом.
    expect(find.text('DAIRY'), findsOneWidget);
    expect(find.text('OTHER'), findsOneWidget);
    expect(find.text('МОЛОЧНОЕ'), findsNothing);
    expect(find.text('Qty: 2 pcs'), findsOneWidget);
    expect(find.text('Qty: 2 bottle'), findsOneWidget);
    expect(find.text('Priority: Medium'), findsOneWidget);
    expect(find.text('Priority: High'), findsOneWidget);
  });

  testWidgets('preview without lists shows lists empty state', (tester) async {
    final store = ListStore();
    runInAction(
      () => store.listsWithPreview = const ListsArrayModel(lists: []),
    );
    await tester.pumpWidget(
      _wrap(SectionBuilder(listStore: store, isPreview: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text("You don't have any lists yet"), findsOneWidget);
    expect(find.text('Maybe you should create a new one?'), findsOneWidget);
    expect(find.text('Try refreshing'), findsNothing);
  });
}
