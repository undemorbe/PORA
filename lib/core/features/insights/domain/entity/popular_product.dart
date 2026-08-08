import 'package:equatable/equatable.dart';

/// Продукт из статистики популярности.
/// - [name] — имя продукта.
/// - [quantity] — суммарно сколько раз/единиц покупали.
/// - [howOftenEnds] — приблизительно раз в сколько дней «заканчивается»
///   (среднее по всем вхождениям продукта в списки этого юзера и других).
/// - [currentDay] — `howOftenEnds / lastTimeBuyed`. Прогресс к «пора купить».
///   Значение ≥ 1 = уже пора; < 1 = сколько относительной жизни ещё осталось.
class PopularProductEntity extends Equatable {
  const PopularProductEntity({
    required this.name,
    required this.quantity,
    required this.howOftenEnds,
    required this.currentDay,
  });

  final String name;
  final int quantity;
  final int howOftenEnds;
  final double currentDay;

  @override
  List<Object?> get props => [name, quantity, howOftenEnds, currentDay];
}
