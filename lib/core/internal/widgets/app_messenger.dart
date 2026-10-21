import 'package:flutter/material.dart';

/// Глобальный ScaffoldMessenger — для snackbar'ов без BuildContext экрана
/// (результаты фоновой синхронизации offline-очереди).
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();
