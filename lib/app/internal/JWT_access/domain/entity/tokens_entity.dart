import 'package:equatable/equatable.dart';

class TokensEntity extends Equatable {
  final String accessToken;
  final String refreshToken;

  const TokensEntity({required this.accessToken, required this.refreshToken});

  @override
  List<Object> get props => [accessToken, refreshToken];
}
