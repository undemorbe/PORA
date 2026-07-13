import 'package:equatable/equatable.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';

abstract class ListsArrayEntity extends Equatable {
  final List<ListSectionEntity> lists;

  const ListsArrayEntity({required this.lists});

  @override
  List<Object?> get props => [lists];
}
