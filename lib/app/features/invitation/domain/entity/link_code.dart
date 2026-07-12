import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class LinkCodeEntity extends Equatable {
  
  @JsonKey(name: 'link-code')
  final String linkCode;

  @JsonKey(name: 'link-url')
  final String linkUrl;

  const LinkCodeEntity({required this.linkCode, required this.linkUrl});

  @override
  List<Object?> get props => [linkCode, linkUrl];
}
