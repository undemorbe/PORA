import 'package:equatable/equatable.dart';

class BriefProductEntity extends Equatable {
  final String title;
  final String? leading;

  const BriefProductEntity({required this.title, this.leading});

  @override
  // TODO: implement props
  List<Object?> get props => [title, leading];
}
