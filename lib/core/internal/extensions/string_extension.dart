extension Validating on String {
  bool isValidEmail() {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegExp.hasMatch(this);
  }

  bool isValidPhone() {
    final cleanPhone = replaceAll(RegExp(r'[\s\-()]'), '');

    final phoneRegExp = RegExp(r"^\+?[1-9]\d{9,14}$");

    return phoneRegExp.hasMatch(cleanPhone);
  }

  bool get isValidNumbers => RegExp(r'^\d+$').hasMatch(this);
}

extension Initials on String {
  String get initials {
    return isEmpty ? '?' : substring(0, 1).toUpperCase();
  }
}
