import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/core/features/auth_and_validation/data/models/jwt_models/tokens_model.dart';
import 'package:pora/core/features/auth_and_validation/domain/usecase/save_tokens.dart';
import 'package:pora/core/features/auth_and_validation/domain/usecase/send_otp.dart';
import 'package:pora/core/features/auth_and_validation/domain/usecase/verify_otp.dart';
import 'package:pora/core/features/onboarding/domain/usecase/update_sawed_onboarding.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/notifications/notification_service.dart';
part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  @observable
  bool? success;

  @observable
  String? scaffoldMessage;

  @observable
  bool? isLoading;

  /// Статус из verify-otp: `notRegistered` — новый пользователь.
  @observable
  String? status;

  /// true — нужен экран создания профиля (новый пользователь).
  /// Только точное `notRegistered` ведёт на создание профиля; всё
  /// остальное (включая null/registered) — «Вспомнили вас» → главный экран.
  bool get needsProfile => status?.trim() == 'notRegistered';

  @action
  Future<void> sendOtp({required String destination}) async {
    isLoading = true;
    final result = await GetIt.I<SendOtpUseCase>().call(
      destination: destination,
    );
    if (result.isRight) {
      isLoading = false;
      success = true;
    } else {
      success = false;
      isLoading = false;
      scaffoldMessage = result.left.message;
    }
  }

  @action
  Future<void> verifyOtp({
    required String destination,
    required String code,
  }) async {
    isLoading = true;
    final notifications = NotificationService.instance;
    final result = await GetIt.I<VerifyOtpUseCase>().call(
      destination: destination,
      otp: code,
      deviceToken: notifications.fcmToken,
      deviceType: notifications.deviceType,
    );
    if (result.isRight) {
      success = true;
      status = result.right.status;
      Logger.talker.info(
        'verifyOtp OK → status="$status", needsProfile=$needsProfile',
      );
      isLoading = false;
      await GetIt.I<SaveTokensUseCase>().call(tokens: result.right);
      await GetIt.I<UpdateIsSawedOnboardingUseCase>().call(isSawed: true);
      // Авторизацию (AuthState.setAuthenticated) выставляем НЕ здесь, а в момент
      // перехода в защищённую зону — иначе reevaluateListenable срабатывает
      // прямо во время replaceAll и сбрасывает только что открытый маршрут.
    } else {
      if (dotenv.getBool("DEBUG")) {
        isLoading = false;
        status = 'notRegistered';
        success = true;
        await GetIt.I<SaveTokensUseCase>().call(
          tokens: TokensModel(
            accessToken: 'accessToken',
            refreshToken: 'refreshToken',
          ),
        );
        await GetIt.I<UpdateIsSawedOnboardingUseCase>().call(isSawed: true);
      } else {
        isLoading = false;
        success = false;
        //! Localize!!!!!!!
        scaffoldMessage = 'Invalid OTP';
      }
    }
  }
}
