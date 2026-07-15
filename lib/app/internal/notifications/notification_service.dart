import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pora/app/features/notifications/domain/entity/notification_entity.dart';
import 'package:pora/app/internal/logging/logger.dart';
import 'package:pora/app/internal/notifications/deep_link_handler.dart';
import 'package:pora/app/internal/notifications/device_token_sync.dart';

/// Имя Hive-бокса для истории уведомлений.
/// Хранится под собственным ключом (не через [ILocalDB]), т.к. background
/// isolate из FCM handler не имеет доступа к DI-контейнеру.
const String kNotificationsBoxName = 'notifications';

/// Android channel для локальных уведомлений в foreground.
const AndroidNotificationChannel _kAndroidChannel = AndroidNotificationChannel(
  'main_channel',
  'Main',
  description: 'Основной канал уведомлений',
  importance: Importance.high,
);

/// Top-level handler для FCM в background/terminated.
/// Должен быть top-level или static + помечен `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>(kNotificationsBoxName);
  final entity = _messageToEntity(message, unread: true);
  await box.put(entity.id, jsonEncode(entity.toJson()));
}

NotificationEntity _messageToEntity(
  RemoteMessage message, {
  required bool unread,
}) {
  final id = message.messageId ??
      DateTime.now().microsecondsSinceEpoch.toString();
  return NotificationEntity(
    id: id,
    title: message.notification?.title,
    body: message.notification?.body,
    data: Map<String, dynamic>.from(message.data),
    receivedAt: message.sentTime ?? DateTime.now(),
    unread: unread,
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Ленивое — обращение к `FirebaseMessaging.instance` до
  /// `Firebase.initializeApp()` бросает `[core/no-app]`. Инициализируется
  /// в [init] после того как Firebase готов.
  late final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationEntity> _stream =
      StreamController<NotificationEntity>.broadcast();

  String? _fcmToken;
  bool _initialized = false;

  /// Последний известный FCM токен (для передачи в auth).
  String? get fcmToken => _fcmToken;

  /// Тип устройства для контракта `/authorize/verify-otp`.
  String get deviceType => Platform.isIOS ? 'ios' : 'android';

  /// Поток новых входящих уведомлений (foreground/opened/initial).
  /// Background-события пишутся в Hive из отдельного изолата — поток на
  /// них не срабатывает, но UI получит их через `loadHistory()` при
  /// следующем открытии страницы.
  Stream<NotificationEntity> get notifications$ => _stream.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Firebase уже должен быть initialized выше по стеку (AppBootstrap).
    _fcm = FirebaseMessaging.instance;

    await Hive.openBox<String>(kNotificationsBoxName);

    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_kAndroidChannel);

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      Logger.talker.warning('FCM permission denied');
      return;
    }

    if (Platform.isIOS) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _fcmToken = await _fcm.getToken();
    Logger.talker.info('FCM token: $_fcmToken');

    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      Logger.talker.info('FCM token refreshed: $token');
      // Отправляем на бэкенд если пользователь уже authed.
      syncDeviceToken();
    });

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedApp);

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      await _persist(initial, unread: false);
      // Cold-start: роутер/auth ещё не готовы — pending раскроется в bindToAuth.
      await DeepLinkHandler.instance.handle(
        Map<String, dynamic>.from(initial.data),
      );
    }
  }

  Future<void> _onForeground(RemoteMessage message) async {
    await _persist(message, unread: true);
    await _showLocal(message);
  }

  Future<void> _onOpenedApp(RemoteMessage message) async {
    await _persist(message, unread: false);
    await DeepLinkHandler.instance.handle(
      Map<String, dynamic>.from(message.data),
    );
  }

  Future<void> _persist(
    RemoteMessage message, {
    required bool unread,
  }) async {
    final box = await _openBox();
    final entity = _messageToEntity(message, unread: unread);
    await box.put(entity.id, jsonEncode(entity.toJson()));
    if (!_stream.isClosed) _stream.add(entity);
  }

  Future<void> _showLocal(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;
    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _kAndroidChannel.id,
          _kAndroidChannel.name,
          channelDescription: _kAndroidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Все сохранённые уведомления, отсортированы от новых к старым.
  Future<List<NotificationEntity>> loadHistory() async {
    final box = await _openBox();
    final list = <NotificationEntity>[];
    for (final raw in box.values) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        list.add(NotificationEntity.fromJson(decoded));
      } catch (e, s) {
        Logger.talker.error('Notification decode failed', e, s);
      }
    }
    list.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return list;
  }

  Future<void> markAsRead(String id) async {
    final box = await _openBox();
    final raw = box.get(id);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final entity =
          NotificationEntity.fromJson(decoded).copyWith(unread: false);
      await box.put(id, jsonEncode(entity.toJson()));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final box = await _openBox();
    for (final key in box.keys.toList()) {
      final raw = box.get(key);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final entity =
            NotificationEntity.fromJson(decoded).copyWith(unread: false);
        await box.put(key, jsonEncode(entity.toJson()));
      } catch (_) {}
    }
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
  }

  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    _fcmToken = null;
  }

  Future<void> _onLocalTap(NotificationResponse response) async {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      await DeepLinkHandler.instance.handle(data);
    } catch (e, s) {
      Logger.talker.error('Local notification payload decode failed', e, s);
    }
  }

  Future<Box<String>> _openBox() async {
    if (Hive.isBoxOpen(kNotificationsBoxName)) {
      return Hive.box<String>(kNotificationsBoxName);
    }
    return Hive.openBox<String>(kNotificationsBoxName);
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _stream.close();
  }
}
