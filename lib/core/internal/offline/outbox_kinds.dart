/// Идентификаторы типов offline-операций. Должны совпадать между местом
/// постановки в очередь (service) и регистрацией обработчика (DI).
abstract class OutboxKinds {
  static const itemMarkBought = 'item.markBought';
  static const itemDelete = 'item.delete';
  static const itemUpdate = 'item.update';
  static const itemNotify = 'item.notify';

  /// Какие ранее поставленные операции над тем же товаром теряют смысл,
  /// когда в очередь встаёт [kind]. notify не схлопывается: каждое
  /// сообщение — отдельное. update несёт полное состояние товара, включая
  /// актуальный `checked`, поэтому поглощает и ранние markBought; обратное
  /// неверно — markBought не знает остальных полей правки.
  static Set<String> supersededBy(String kind) => switch (kind) {
    itemMarkBought => const {itemMarkBought},
    itemUpdate => const {itemUpdate, itemMarkBought},
    itemDelete => const {itemMarkBought, itemUpdate, itemNotify, itemDelete},
    _ => const <String>{},
  };
}
