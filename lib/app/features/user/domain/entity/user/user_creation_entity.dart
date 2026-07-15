import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class UserCreationEntity extends Equatable {
  final String name;
  final String? surname;
  final File? image;
  
  const UserCreationEntity({
    required this.name,
    this.surname,
    this.image,
  });

  @override
  List<Object?> get props => [name, surname, image];
}