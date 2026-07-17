// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NotificationsStore on _NotificationsStoreBase, Store {
  Computed<int>? _$unreadCountComputed;

  @override
  int get unreadCount => (_$unreadCountComputed ??= Computed<int>(
    () => super.unreadCount,
    name: '_NotificationsStoreBase.unreadCount',
  )).value;

  late final _$itemsAtom = Atom(
    name: '_NotificationsStoreBase.items',
    context: context,
  );

  @override
  ObservableList<NotificationEntity> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(ObservableList<NotificationEntity> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_NotificationsStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    '_NotificationsStoreBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$markAllReadAsyncAction = AsyncAction(
    '_NotificationsStoreBase.markAllRead',
    context: context,
  );

  @override
  Future<void> markAllRead() {
    return _$markAllReadAsyncAction.run(() => super.markAllRead());
  }

  late final _$markReadAsyncAction = AsyncAction(
    '_NotificationsStoreBase.markRead',
    context: context,
  );

  @override
  Future<void> markRead(String id) {
    return _$markReadAsyncAction.run(() => super.markRead(id));
  }

  late final _$_NotificationsStoreBaseActionController = ActionController(
    name: '_NotificationsStoreBase',
    context: context,
  );

  @override
  void _onIncoming(NotificationEntity n) {
    final _$actionInfo = _$_NotificationsStoreBaseActionController.startAction(
      name: '_NotificationsStoreBase._onIncoming',
    );
    try {
      return super._onIncoming(n);
    } finally {
      _$_NotificationsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
items: ${items},
isLoading: ${isLoading},
unreadCount: ${unreadCount}
    ''';
  }
}
