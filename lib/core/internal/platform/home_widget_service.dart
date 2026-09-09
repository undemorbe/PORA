import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:pora/core/internal/logging/logger.dart';

/// Home-screen widget (Android-эксклюзив по задаче). Толкает в нативный
/// AppWidget краткую сводку: сколько товаров нужно купить и первые позиции.
class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();

  // Ключи, которые читает нативный provider (SharedPreferences).
  static const _kCount = 'pora_needed_count';
  static const _kItems = 'pora_needed_items';

  // Имя нативного provider'а (класс Kotlin) для updateWidget.
  static const _androidProvider = 'PoraWidgetProvider';

  /// Обновляет виджет: [count] — сколько всего нужно купить, [items] — первые
  /// названия для превью.
  Future<void> update({required int count, required List<String> items}) async {
    if (!Platform.isAndroid) return; // iOS-виджет — отдельная нативная работа
    try {
      await HomeWidget.saveWidgetData<int>(_kCount, count);
      await HomeWidget.saveWidgetData<String>(_kItems, items.take(3).join('\n'));
      await HomeWidget.updateWidget(androidName: _androidProvider);
    } catch (e, s) {
      Logger.talker.warning('HomeWidget update failed', e, s);
    }
  }

  /// Чистит виджет (например, при logout).
  Future<void> clear() => update(count: 0, items: const []);
}
