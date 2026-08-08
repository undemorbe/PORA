import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pora/core/internal/extensions/l10n_extension.dart';
import 'package:pora/core/internal/network/connectivity/connectivity_store.dart';
import 'package:pora/core/internal/widgets/pora_snackbar.dart';

/// Утилита-guard для write-операций. Если нет сети — показывает snackbar
/// «Нет интернета» и возвращает false. Все mutating-callsites должны
/// проверять её перед вызовом remote usecase.
///
/// Пример:
/// ```dart
/// if (!await ConnectivityGuard.checkWrite(context)) return;
/// await addUseCase.call(...);
/// ```
class ConnectivityGuard {
  const ConnectivityGuard._();

  /// Возвращает true если можно писать (есть интернет). Иначе показывает
  /// snackbar и возвращает false. [context] нужен для snackbar.
  static Future<bool> checkWrite(BuildContext context) async {
    final store = GetIt.I<ConnectivityStore>();
    if (store.online) return true;
    // Двойная проверка на случай если stream не подтянул событие.
    await store.recheck();
    if (store.online) return true;
    if (context.mounted) {
      PoraSnackbar.show(
        context,
        message: context.l10n.offlineWriteBlocked,
      );
    }
    return false;
  }

  /// Быстрая синхронная проверка без snackbar — для gate'ов внутри UI.
  static bool isOnline() => GetIt.I<ConnectivityStore>().online;
}
