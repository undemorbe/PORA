abstract class AuthAbstract {

  void getOtpFromPhone();
  
  void getOtpFromEmail();

  Map<String, dynamic> confirmOtp({required String otp});

}
