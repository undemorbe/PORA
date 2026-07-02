/// Предсказание пополнения (экран «Пора докупить»).
class Prediction {
  const Prediction({
    required this.emoji,
    required this.name,
    required this.meta,
  });

  final String emoji;
  final String name;
  final String meta; // «~раз в 7 дней · куплено 6 дней назад»
}
