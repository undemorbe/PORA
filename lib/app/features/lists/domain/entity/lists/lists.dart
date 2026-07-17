import 'package:equatable/equatable.dart';
import 'package:pora/app/features/lists/domain/entity/lists/list_section.dart';

abstract class ListEntity extends Equatable {
  final String id;
  final String name;
  final List<ListSectionEntity> sections;

  const ListEntity({
    required this.id,
    required this.name,
    required this.sections,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [id, name, sections];
}
