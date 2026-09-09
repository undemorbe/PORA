import 'package:pora/core/internal/errors/failure.dart';
import 'package:pora/core/internal/extensions/either.dart';
import 'package:pora/core/internal/logging/logger.dart';
import 'package:pora/core/internal/offline/outbox.dart';

/// Обработчик одного типа операции: выполняет реальный remote-вызов.
/// Должен бить по сети НАПРЯМУЮ (remote), не через сервис с outbox — иначе
/// при повторном офлайне операция уйдёт в очередь снова (петля).
typedef OutboxHandler =
    Future<Either<Failure, Object?>> Function(Map<String, dynamic> args);

class OutboxReplayer {
  OutboxReplayer({required this.outbox});

  final Outbox outbox;
  final Map<String, OutboxHandler> _handlers = {};
  bool _flushing = false;

  void register(String kind, OutboxHandler handler) {
    _handlers[kind] = handler;
  }

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final entries = await outbox.all();
      if (entries.isEmpty) return;
      Logger.talker.info('Outbox flush: ${entries.length} pending');
      for (final entry in entries) {
        final handler = _handlers[entry.kind];
        if (handler == null) {
          Logger.talker.warning('Outbox: no handler for ${entry.kind}, drop');
          await outbox.remove(entry.id);
          continue;
        }
        entry.attempts++;
        await outbox.update(entry);

        final res = await handler(entry.args);
        if (res.isRight) {
          await outbox.remove(entry.id);
          continue;
        }

        final failure = res.left;
        if (failure.isConnectivity) {
          // Связь снова пропала — прекращаем, остальное проиграем позже.
          Logger.talker.info('Outbox flush paused: connectivity lost');
          break;
        }
        // Постоянная ошибка — запись «отравленная», убираем.
        Logger.talker.warning(
          'Outbox: dropping ${entry.kind} after permanent error: '
          '${failure.message}',
        );
        await outbox.remove(entry.id);
      }
    } catch (e, s) {
      Logger.talker.error('Outbox flush failed', e, s);
    } finally {
      _flushing = false;
    }
  }
}
