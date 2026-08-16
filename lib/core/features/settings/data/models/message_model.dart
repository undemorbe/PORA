import 'package:json_annotation/json_annotation.dart';
import 'package:pora/core/features/settings/domain/entity/message_entity.dart';
part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends MessageEntity {
  const MessageModel({required super.title, required super.message});

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
