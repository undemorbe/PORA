import 'package:equatable/equatable.dart';

abstract class TokensEntity extends Equatable {
  final String accessToken;
  final String refreshToken;

  /// Статус пользователя из ответа verify-otp (например, `notRegistered`).
  /// Может отсутствовать (refresh-эндпоинт его не отдаёт).
  final String? status;

  const TokensEntity({
    required this.accessToken,
    required this.refreshToken,
    this.status,
  });

  /// Значение статуса для незарегистрированного пользователя.
  static const String statusNotRegistered = 'notRegistered';

  /// true — пользователь уже зарегистрирован (нужен экран «Вспомнили вас»),
  /// false — новый пользователь (нужен экран создания профиля).
  bool get isRegistered => status != statusNotRegistered;

  @override
  List<Object?> get props => [accessToken, refreshToken, status];
}
