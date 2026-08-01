/// Backend error codes из контракта:
///   INVALID_INPUT / INVALID_PHONE / OTP_EXPIRED / OTP_INCORRECT /
///   UNAUTHORIZED / ACCESS_TOKEN_EXPIRED / REFRESH_TOKEN_EXPIRED /
///   NOT_FOUND / FORBIDDEN / CONFLICT / FILE_TOO_LARGE / INTERNAL_ERROR
///
/// Приходит в теле ответа `{"error": {"code": "…", "message": "…"}}`.
enum ApiErrorCode {
  invalidInput('INVALID_INPUT'),
  invalidPhone('INVALID_PHONE'),
  otpExpired('OTP_EXPIRED'),
  otpIncorrect('OTP_INCORRECT'),
  unauthorized('UNAUTHORIZED'),
  accessTokenExpired('ACCESS_TOKEN_EXPIRED'),
  refreshTokenExpired('REFRESH_TOKEN_EXPIRED'),
  notFound('NOT_FOUND'),
  forbidden('FORBIDDEN'),
  conflict('CONFLICT'),
  fileTooLarge('FILE_TOO_LARGE'),
  internalError('INTERNAL_ERROR'),
  unknown('UNKNOWN');

  const ApiErrorCode(this.wire);

  /// Строка как приходит с бэка.
  final String wire;

  static ApiErrorCode fromWire(String? code) {
    if (code == null || code.isEmpty) return ApiErrorCode.unknown;
    for (final v in ApiErrorCode.values) {
      if (v.wire == code) return v;
    }
    return ApiErrorCode.unknown;
  }
}
