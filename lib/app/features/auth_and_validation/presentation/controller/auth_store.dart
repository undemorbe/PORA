import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/send_otp.dart';
import 'package:pora/app/features/auth_and_validation/domain/usecase/verify_otp.dart';
part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  @observable
  bool? success;

  @observable
  String? scaffoldMessage;

  @action
  Future<void> sendOtp({required String destination}) async {
    final result = await GetIt.I<SendOtpUseCase>().call(
      destination: destination,
    );
    if (result.isRight) {
      success = true;
    } else {
      success = false;
      scaffoldMessage = result.left.message;
    }
  }

  @action
  Future<void> verifyOtp({
    required String destination,
    required String code,
  }) async {
    final result = await GetIt.I<VerifyOtpUseCase>().call(
      destination: destination,
      otp: code,
    );
    if (result.isRight) {
      success = true;
    } else {
      success = false;
      //! Localize
      scaffoldMessage = 'Invalid OTP';
    }
  }
}
