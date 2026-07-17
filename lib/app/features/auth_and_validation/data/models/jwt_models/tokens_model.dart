import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/auth_and_validation/domain/entity/tokens_entity.dart';
part 'tokens_model.g.dart';

@JsonSerializable(createJsonSchema: true)
class TokensModel extends TokensEntity {
  // Бэкенд отдаёт ключи через дефис: access-token / refresh-token.
  const TokensModel({
    @JsonKey(name: 'access-token') required super.accessToken,
    @JsonKey(name: 'refresh-token') required super.refreshToken,
    @JsonKey(name: 'status') super.status,
  });

  factory TokensModel.fromJson(Map<String, dynamic> json) =>
      _$TokensModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}
