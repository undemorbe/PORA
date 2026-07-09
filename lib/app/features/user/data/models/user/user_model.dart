import 'package:json_annotation/json_annotation.dart';
import 'package:pora/app/features/user/data/models/user/user_update_model.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    this.id,
    this.name,
    this.surname,
    this.phone,
    this.email,
    this.imageUrl,
    this.selfLists,
  });

  final String? id;
  final String? name;
  final String? surname;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final List<String>? selfLists;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity u) => UserModel(
    id: u.id,
    name: u.name,
    surname: u.surname,
    phone: u.phone,
    email: u.email,
    imageUrl: u.imageUrl,
    selfLists: u.selfLists,
  );

  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    surname: surname,
    phone: phone,
    email: email,
    imageUrl: imageUrl,
    selfLists: selfLists,
  );

  /// Тело запроса обновления: только реально изменённые поля.
  /// Пустые/неизменные (null или '') отбрасываем — они не попадут в JSON
  /// (includeIfNull: false) и не перезапишут данные пустым значением.
  UserUpdateModel toUpdateModel() => UserUpdateModel(
    phone: _orNull(phone),
    email: _orNull(email),
    name: _orNull(name),
    surname: _orNull(surname),
  );

  static String? _orNull(String? v) => (v == null || v.isEmpty) ? null : v;
}
