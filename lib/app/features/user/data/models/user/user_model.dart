import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    this.id,
    this.name,
    this.surname,
    this.imageUrl,
    this.selfLists,
  });

  final String? id;
  final String? name;
  final String? surname;
  final String? imageUrl;
  final List<String>? selfLists;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity u) => UserModel(
    id: u.id,
    name: u.name,
    surname: u.surname,
    imageUrl: u.imageUrl,
    selfLists: u.selfLists,
  );

  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    surname: surname,
    imageUrl: imageUrl,
    selfLists: selfLists,
  );
}
