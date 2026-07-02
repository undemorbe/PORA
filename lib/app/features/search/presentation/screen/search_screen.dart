import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:pora/app/features/search/presentation/widgets/result_row.dart';
import 'package:pora/app/internal/theme/additional_constants.dart';
import 'package:pora/app/internal/theme/app_text_styles.dart';
import 'package:pora/app/internal/widgets/pora_chip.dart';
import 'package:pora/app/internal/widgets/pora_rows_card.dart';
import 'package:pora/app/internal/widgets/section_label.dart';

/// Поиск продуктов и рецептов с живой фильтрацией.
@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _products = <(String, String)>[
    ('🥛', 'Молоко'),
    ('🍞', 'Хлеб'),
    ('🥚', 'Яйца'),
    ('🥑', 'Авокадо'),
    ('🍌', 'Бананы'),
    ('☕', 'Кофе'),
    ('🍝', 'Паста спагетти'),
    ('🧀', 'Сыр пармезан'),
    ('🍗', 'Курица'),
    ('🍅', 'Помидоры'),
    ('🥦', 'Брокколи'),
    ('🍋', 'Лимон'),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = _products
        .where((p) => p.$2.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PoraSpacing.screen,
            6,
            PoraSpacing.screen,
            PoraSpacing.xxl,
          ),
          children: [
            Text('Поиск', style: PoraText.title),
            const SizedBox(height: PoraSpacing.lg),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              style: PoraText.body,
              decoration: const InputDecoration(
                hintText: 'Продукт или рецепт…',
                prefixIcon: Icon(
                  PhosphorIconsRegular.magnifyingGlass,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: PoraSpacing.lg),
            const Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                PoraChip(label: 'Всё', dense: true, selected: true),
                PoraChip(label: 'Овощи', leading: '🥦', dense: true),
                PoraChip(label: 'Молочное', leading: '🥛', dense: true),
                PoraChip(label: 'Бакалея', leading: '🍝', dense: true),
                PoraChip(label: 'Рецепты', leading: '🍳', dense: true),
              ],
            ),
            const SizedBox(height: PoraSpacing.lg),
            const SectionLabel('Результаты'),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: PoraSpacing.lg),
                child: Center(
                  child: Text('Ничего не найдено', style: PoraText.subtitle),
                ),
              )
            else
              PoraRowsCard(
                children: [
                  for (final (emoji, name) in results)
                    ResultRow(emoji: emoji, name: name),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
