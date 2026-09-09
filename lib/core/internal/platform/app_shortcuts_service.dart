import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/router/app_router.dart';
import 'package:pora/core/internal/router/app_router.gr.dart';
import 'package:quick_actions/quick_actions.dart';

/// App Shortcuts (Android long-press иконки; на iOS — Home Screen Quick
/// Actions, работает так же). Быстрые действия: открыть списки, Pora-AI,
/// добавить товар.
class AppShortcutsService {
  AppShortcutsService._();
  static final AppShortcutsService instance = AppShortcutsService._();

  final QuickActions _quickActions = const QuickActions();

  static const _openLists = 'action_open_lists';
  static const _openPora = 'action_open_pora';
  static const _addItem = 'action_add_item';

  /// [listsLabel]/[poraLabel]/[addLabel] — уже локализованные подписи.
  Future<void> init({
    required String listsLabel,
    required String poraLabel,
    required String addLabel,
  }) async {
    try {
      _quickActions.initialize(_handle);
      await _quickActions.setShortcutItems(<ShortcutItem>[
        ShortcutItem(type: _openLists, localizedTitle: listsLabel),
        ShortcutItem(type: _openPora, localizedTitle: poraLabel),
        ShortcutItem(type: _addItem, localizedTitle: addLabel),
      ]);
    } catch (e, s) {
      Logger.talker.warning('AppShortcuts init failed', e, s);
    }
  }

  void _handle(String type) {
    final router = GetIt.I<AppRouter>();
    switch (type) {
      case _openPora:
        router.navigate(const PredictionsRoute());
      case _addItem:
      // Товар добавляется в конкретный список → ведём к спискам, выбор там.
      case _openLists:
      default:
        router.navigate(const GroupsRoute());
    }
  }
}
