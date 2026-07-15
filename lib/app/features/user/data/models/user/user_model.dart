import 'package:pora/app/features/lists/data/models/lists/list_model.dart';
import 'package:pora/app/features/user/data/models/user/user_update_model.dart';
import 'package:pora/app/features/user/domain/entity/user/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.name,
    super.surname,
    super.phone,
    super.email,
    super.imageUrl,
    super.selfLists,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawLists = json['lists'] as List?;
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      imageUrl: json['image-url'] as String?,
      selfLists: rawLists
          ?.whereType<Map<String, dynamic>>()
          .map(ListModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'surname': surname,
        'phone': phone,
        'email': email,
        'image-url': imageUrl,
        'lists': selfLists
            ?.whereType<ListModel>()
            .map((l) => l.toJson())
            .toList(),
      };

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

  UserUpdateModel toUpdateModel() => UserUpdateModel(
        phone: _orNull(phone),
        email: _orNull(email),
        name: _orNull(name),
        surname: _orNull(surname),
      );

  static String? _orNull(String? v) => (v == null || v.isEmpty) ? null : v;
}
