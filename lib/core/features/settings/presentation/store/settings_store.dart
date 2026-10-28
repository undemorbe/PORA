import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/backend/backend_event_sink.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
import 'package:pora/core/features/settings/domain/usecase/send_support_msg.dart';
import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/offline/outbox.dart';
part 'settings_store.g.dart';

/// Сколько logout ждёт отправки аналитики: зависший запрос (Dio-таймауты по
/// 30 с) не должен держать пользователя на экране настроек.
@visibleForTesting
Duration logoutAnalyticsFlushTimeout = const Duration(seconds: 5);

class SettingsStore = _SettingsStoreBase with _$SettingsStore;

abstract class _SettingsStoreBase with Store {
  @observable
  UserEntity? user;

  @computed
  String? get profileImageUrl => user?.imageUrl;

  @observable
  File? profileImageFile;

  @observable
  bool? isLoadingImage;

  @action
  Future<void> setProfileImage() async {
    final imagePicker = GetIt.I<ImagePicker>();
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    try {
      isLoadingImage = true;

      // Run the pipeline
      final File? processedImage =
          await ImageProcessingService.RepublicImageProcess(
            File(pickedFile.path),
          );

      if (processedImage != null) {
        profileImageFile = processedImage;
        await GetIt.I<UpdateUserUseCase>()
            .call(image: File(processedImage.path))
            .whenComplete(() => getUserMe());
        isLoadingImage = false;
      }
    } catch (e) {
      Logger.talker.error("Error processing image: $e");
    } finally {
      isLoadingImage = false;
    }
  }

  @action
  Future<void> getUserMe() async {
    final user = await GetIt.I<GetUserUseCase>().call();
    if (user.isRight) {
      this.user = user.right;
    }
  }

  @action
  Future<void> logout() async {
    // Пока токен жив (до серверного logout) — отправляем накопленные события
    // текущего юзера. Не дождались — остаток вычистит _clearSession.
    await BackendEventSink.instance.flush().timeout(
      logoutAnalyticsFlushTimeout,
      onTimeout: () {},
    );
    await GetIt.I<LogoutUseCase>().call();
    await _clearSession();
  }

  @observable
  bool isDeletingAccount = false;

  /// Безвозвратно удаляет аккаунт. Возвращает `false` при ошибке сервера —
  /// локальная сессия тогда остаётся, UI покажет snackbar.
  /// Аналитику удалённого аккаунта не досылаем — только чистим очередь.
  @action
  Future<bool> deleteAccount() async {
    isDeletingAccount = true;
    try {
      final res = await GetIt.I<DeleteAccountUseCase>().call();
      if (res.isLeft) return false;
      await _clearSession();
      return true;
    } finally {
      isDeletingAccount = false;
    }
  }

  Future<void> _clearSession() async {
    // Неотправленные операции принадлежат ушедшему юзеру — с токеном
    // следующего их проигрывать нельзя. Чистим до токенов, чтобы flush
    // не успел проиграть их без авторизации.
    await GetIt.I<Outbox>().clear();
    // События ушедшего юзера не смешиваем с событиями следующего; чистим до
    // токенов — фоновый flush не успеет отправить их с чужой авторизацией.
    await BackendEventSink.instance.clear();
    final tokensStore = GetIt.I<TokensSecureStore>();
    await tokensStore.clearTokens();
    // Чистим весь offline-cache — новый юзер не должен видеть чужие снапшоты.
    await HiveJsonCache.clear();
    await UsageTracker.instance.clear();
    GetIt.I<AuthState>().setUnauthenticated();
  }

  @observable
  bool isSendingSupport = false;

  /// Отправляет сообщение в поддержку. Возвращает `true` при успехе,
  /// `false` — пустой текст или ошибка отправки (UI покажет snackbar).
  @action
  Future<bool> sendSupportMessage({required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    isSendingSupport = true;
    try {
      final res = await GetIt.I<SendSupportMsgUseCase>().call(
        message: MessageEntity(title: 'User support request', message: trimmed),
      );
      if (res.isRight) {
        unawaited(AnalyticsService.instance.logSupportMessageSent());
      }
      return res.isRight;
    } finally {
      isSendingSupport = false;
    }
  }
}
