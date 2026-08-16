import 'package:equatable/equatable.dart';

/// Продукт для превью (например, high-priority позиции, которые бэкенд
/// уже отобрал и отдаёт готовым списком).
abstract class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String emoji;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.emoji,
  });

  @override
  List<Object?> get props => [id, name, emoji];
}
