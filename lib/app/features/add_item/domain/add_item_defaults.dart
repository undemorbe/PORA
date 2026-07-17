/// Дефолтные значения для селекторов при создании продукта.
/// Backend не имеет фиксированного enum'а — принимает произвольные строки.
class AddItemDefaults {
  const AddItemDefaults._();

  static const List<String> units = ['шт', 'г', 'кг', 'мл', 'л', 'уп'];

  /// (emoji, name). Name уходит на backend, emoji — только UI.
  static const List<(String, String)> sections = [
    ('🥦', 'Овощи и фрукты'),
    ('🥛', 'Молочное'),
    ('🍝', 'Бакалея'),
    ('🧃', 'Напитки'),
    ('🍞', 'Хлеб'),
    ('🧀', 'Разное'),
  ];

  static const String defaultUnit = 'шт';
  static const String defaultSection = 'Разное';

  static const int remindDaysMin = 1;
  static const int remindDaysMax = 7;
}
