import 'package:equatable/equatable.dart';
import 'package:pora/app/features/lists/domain/entity/lists/lists.dart';

abstract class ListsArrayEntity extends Equatable {
  final List<ListEntity> lists;

  const ListsArrayEntity({required this.lists});

  @override
  List<Object?> get props => [lists];
}
