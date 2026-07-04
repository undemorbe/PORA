import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/auth_and_validation/JWT_access/domain/entity/tokens_entity.dart';
part 'tokens_model.g.dart';

@JsonSerializable(createJsonSchema: true)
class TokensModel extends TokensEntity {
  const TokensModel({required super.accessToken, required super.refreshToken});

  factory TokensModel.fromJson(Map<String, dynamic> json) =>
      _$TokensModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}
