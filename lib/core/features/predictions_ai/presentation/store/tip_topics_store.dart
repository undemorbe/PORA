import 'package:mobx/mobx.dart';
import 'package:pora/core/features/predictions_ai/data/prefs/tip_topics_prefs.dart';
import 'package:pora/core/features/predictions_ai/domain/tip/predefined_topics.dart';
import 'package:pora/core/features/predictions_ai/domain/tip/tip_topic.dart';

part 'tip_topics_store.g.dart';

/// Управляет пулом тем «Совета дня». UI на них подписывается через Observer.
class TipTopicsStore = _TipTopicsStoreBase with _$TipTopicsStore;

abstract class _TipTopicsStoreBase with Store {
  _TipTopicsStoreBase({required this.prefs}) {
    load();
  }

  final TipTopicsPrefs prefs;

  @observable
  ObservableSet<String> disabledPredefinedIds = ObservableSet<String>();

  @observable
  ObservableList<String> customTexts = ObservableList<String>();

  @observable
  bool isLoading = true;

  /// Все темы: predefined (за вычетом disabled) + custom. Порядок стабилен.
  @computed
  List<TipTopic> get activeTopics {
    final res = <TipTopic>[];
    for (final key in PredefinedTipTopics.keys) {
      if (!disabledPredefinedIds.contains(key)) {
        res.add(TipTopic.predefined(key));
      }
    }
    for (final text in customTexts) {
      res.add(TipTopic.custom(text));
    }
    return res;
  }

  /// Все predefined с их статусом (для UI-чипов в settings).
  @computed
  List<({TipTopic topic, bool enabled})> get predefinedWithState {
    return PredefinedTipTopics.keys
        .map(
          (key) => (
            topic: TipTopic.predefined(key),
            enabled: !disabledPredefinedIds.contains(key),
          ),
        )
        .toList();
  }

  @computed
  List<TipTopic> get customTopics =>
      customTexts.map(TipTopic.custom).toList();

  @action
  Future<void> load() async {
    isLoading = true;
    final disabled = await prefs.disabledPredefined();
    final custom = await prefs.customTexts();
    disabledPredefinedIds = ObservableSet.of(disabled);
    customTexts = ObservableList.of(custom);
    isLoading = false;
  }

  @action
  Future<void> togglePredefined(String id) async {
    if (disabledPredefinedIds.contains(id)) {
      disabledPredefinedIds.remove(id);
    } else {
      disabledPredefinedIds.add(id);
    }
    await prefs.setDisabledPredefined(disabledPredefinedIds.toList());
  }

  @action
  Future<void> addCustom(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || customTexts.contains(trimmed)) return;
    customTexts.add(trimmed);
    await prefs.setCustomTexts(customTexts.toList());
  }

  @action
  Future<void> removeCustom(String text) async {
    customTexts.remove(text);
    await prefs.setCustomTexts(customTexts.toList());
  }
}
