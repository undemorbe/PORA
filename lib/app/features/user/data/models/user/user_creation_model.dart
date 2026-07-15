import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/user/domain/entity/user/user_creation_entity.dart';
part 'user_creation_model.g.dart';
@JsonSerializable()
class UserCreationModel extends UserCreationEntity{
  const UserCreationModel({required super.name, super.image, super.surname});

  factory UserCreationModel.fromJson(Map<String, dynamic> json) => _$UserCreationModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserCreationModelToJson(this);
  
}