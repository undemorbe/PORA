import 'dart:async';
import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:pora/core/internal/analytics/analytics_service.dart';
import 'package:pora/core/internal/analytics/usage/usage_tracker.dart';
import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
import 'package:pora/core/features/settings/domain/usecase/send_support_msg.dart';
import 'package:pora/core/features/user/domain/entity/user/user_entity.dart';
import 'package:pora/core/internal/cache/hive_json_cache.dart';
import 'package:pora/core/internal/di/export.dart';
import 'package:pora/core/internal/offline/outbox.dart';
part 'settings_store.g.dart';

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
    await GetIt.I<LogoutUseCase>().call();
    await _clearSession();
  }

  @observable
  bool isDeletingAccount = false;

  /// Безвозвратно удаляет аккаунт. Возвращает `false` при ошибке сервера —
  /// локальная сессия тогда остаётся, UI покажет snackbar.
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
    final tokensStore = GetIt.I<TokensSecureStore>();
    await tokensStore.clearTokens();
    // Чистим весь offline-cache — новый юзер не должен видеть чужие снапшоты.
    await HiveJsonCache.clear();
    // Неотправленные операции принадлежат ушедшему юзеру — с токеном
    // следующего их проигрывать нельзя.
    await GetIt.I<Outbox>().clear();
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
