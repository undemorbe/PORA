import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:pora/core/features/notifications/domain/entity/notification_entity.dart';
import 'package:pora/core/internal/notifications/notification_service.dart';
part 'notifications_store.g.dart';

/// Фильтр по типу — pill'ы над списком. `all` — без фильтра.
enum NotificationFilter { all, urgent, prediction, promo, other }

class NotificationsStore = _NotificationsStoreBase with _$NotificationsStore;

abstract class _NotificationsStoreBase with Store {
  final NotificationService service;

  _NotificationsStoreBase({NotificationService? service})
    : service = service ?? NotificationService.instance;

  @observable
  ObservableList<NotificationEntity> items =
      ObservableList<NotificationEntity>();

  @observable
  bool isLoading = false;

  @observable
  NotificationFilter filter = NotificationFilter.all;

  @computed
  int get unreadCount => items.where((n) => n.unread).length;

  @computed
  List<NotificationEntity> get filtered {
    if (filter == NotificationFilter.all) return items.toList();
    return items.where((n) {
      final t = n.data['type']?.toString() ?? '';
      return switch (filter) {
        NotificationFilter.urgent => t == 'urgent',
        NotificationFilter.prediction => t == 'prediction',
        NotificationFilter.promo => t == 'promo',
        NotificationFilter.other =>
          t.isEmpty || !const {'urgent', 'prediction', 'promo'}.contains(t),
        NotificationFilter.all => true,
      };
    }).toList();
  }

  /// Группирует `filtered` по локальным датам. UI сам форматирует label.
  List<({DateTime day, List<NotificationEntity> items})> groupedByDay() {
    final byKey = <DateTime, List<NotificationEntity>>{};
    for (final n in filtered) {
      final local = n.receivedAt.toLocal();
      final key = DateTime(local.year, local.month, local.day);
      (byKey[key] ??= []).add(n);
    }
    final keys = byKey.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) => (day: k, items: byKey[k]!)).toList();
  }

  StreamSubscription<NotificationEntity>? _sub;

  @action
  Future<void> load() async {
    isLoading = true;
    final history = await service.loadHistory();
    items = ObservableList.of(history);
    isLoading = false;
    _sub ??= service.notifications$.listen(_onIncoming);
  }

  @action
  void _onIncoming(NotificationEntity n) {
    items.removeWhere((e) => e.id == n.id);
    items.insert(0, n);
  }

  @action
  Future<void> markAllRead() async {
    await service.markAllRead();
    items = ObservableList.of(items.map((n) => n.copyWith(unread: false)));
  }

  @action
  Future<void> markRead(String id) async {
    await service.markAsRead(id);
    final idx = items.indexWhere((e) => e.id == id);
    if (idx >= 0) items[idx] = items[idx].copyWith(unread: false);
  }

  @action
  Future<void> delete(String id) async {
    await service.deleteById(id);
    items.removeWhere((e) => e.id == id);
  }

  @action
  Future<void> clearAll() async {
    await service.clear();
    items.clear();
  }

  @action
  void setFilter(NotificationFilter f) => filter = f;

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
