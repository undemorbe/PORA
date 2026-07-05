import 'package:equatable/equatable.dart';

abstract class LinkCodeEntity extends Equatable{
  final String linkCode;
  final String linkUrl;

  const LinkCodeEntity({required this.linkCode, required this.linkUrl});
  @override
  List<Object?> get props => [linkCode, linkUrl];
}