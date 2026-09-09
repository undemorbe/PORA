/// Идентификаторы типов offline-операций. Должны совпадать между местом
/// постановки в очередь (service) и регистрацией обработчика (DI).
abstract class OutboxKinds {
  static const itemMarkBought = 'item.markBought';
  static const itemDelete = 'item.delete';
  static const itemUpdate = 'item.update';
  static const itemNotify = 'item.notify';
}
