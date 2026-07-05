extension Validating on String {
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegExp.hasMatch(email);
  }

  bool isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    final phoneRegExp = RegExp(r"^\+?[1-9]\d{6,14}$");

    return phoneRegExp.hasMatch(cleanPhone);
  }

  /// Только цифры (для OTP-кода и подобного ввода).
  bool get isValidNumbers => RegExp(r'^\d+$').hasMatch(this);
}
