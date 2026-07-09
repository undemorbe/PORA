import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/save_tokens.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/send_otp.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/verify_otp.dart';
import 'package:pora/app/features/onboarding/domain/usecase/update_sawed_onboarding.dart';
part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  @observable
  bool? success;

  @observable
  String? scaffoldMessage;

  @observable
  bool? isLoading;

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
    final result = await GetIt.I<VerifyOtpUseCase>().call(
      destination: destination,
      otp: code,
    );
    if (result.isRight) {
      isLoading = false;
      success = true;
      await GetIt.I<SaveTokensUseCase>().call(tokens: result.right);
      await GetIt.I<UpdateIsSawedOnboardingUseCase>().call(isSawed: true);
    } else {
      isLoading = false;
      success = false;
      //! Localize
      scaffoldMessage = 'Invalid OTP';
    }
  }
}
