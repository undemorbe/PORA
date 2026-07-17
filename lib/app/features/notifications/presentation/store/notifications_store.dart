import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:pora/app/features/notifications/domain/entity/notification_entity.dart';
import 'package:pora/app/internal/notifications/notification_service.dart';
part 'notifications_store.g.dart';

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

  @computed
  int get unreadCount => items.where((n) => n.unread).length;

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

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
