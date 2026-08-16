import 'package:json_annotation/json_annotation.dart';
part 'user_update_model.g.dart';

/// Тело запроса PATCH /user/update.
/// Отправляем ТОЛЬКО те поля, что реально меняем — null-поля исключаются
/// из JSON (`includeIfNull: false`), чтобы не перезаписать данные пустым.
@JsonSerializable(includeIfNull: false)
class UserUpdateModel {
  const UserUpdateModel({this.phone, this.email, this.name, this.surname});

  final String? phone;
  final String? email;
  final String? name;
  final String? surname;

  factory UserUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateModelToJson(this);
}
