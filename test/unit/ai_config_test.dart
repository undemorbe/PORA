import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pora/core/features/predictions_ai/data/config/ai_config.dart';
import 'package:pora/core/features/predictions_ai/data/prefs/ai_config_prefs.dart';

import '../helpers/fake_local_db.dart';

void main() {
  late FakeLocalDB db;
  late AiConfigPrefs prefs;
  late AiConfig config;

  setUp(() {
    dotenv.loadFromString(
      envString: 'AI_API_KEY=ENV_KEY\n'
          'AI_MODEL=ENV_MODEL\n'
          'AI_CHAT_MODEL=ENV_CHAT\n'
          'AI_TIP_MODEL=ENV_TIP\n',
    );
    db = FakeLocalDB();
    prefs = AiConfigPrefs(db: db);
    config = AiConfig(prefs);
  });

  test('no user key → everything from .env', () async {
    await config.reload();
    expect(config.hasCustomKey, isFalse);
    expect(config.apiKey, 'ENV_KEY');
    expect(config.poraModel, 'ENV_CHAT');
    expect(config.tipsModel, 'ENV_TIP');
    expect(config.isCustom, isFalse);
  });

  test('user key + custom pora, empty tips → tips falls back to env', () async {
    await prefs.save(apiKey: 'USER_KEY', poraModel: 'USER_PORA', tipsModel: '');
    await config.reload();
    expect(config.hasCustomKey, isTrue);
    expect(config.apiKey, 'USER_KEY');
    expect(config.poraModel, 'USER_PORA');
    // tips model default from env, but requests go with the user key.
    expect(config.tipsModel, 'ENV_TIP');
    expect(config.isCustom, isTrue);
  });

  test('user key + both models', () async {
    await prefs.save(
      apiKey: 'K',
      poraModel: 'P',
      tipsModel: 'T',
    );
    await config.reload();
    expect(config.apiKey, 'K');
    expect(config.poraModel, 'P');
    expect(config.tipsModel, 'T');
  });

  test('reset restores env defaults', () async {
    await prefs.save(apiKey: 'K', poraModel: 'P', tipsModel: 'T');
    await config.reload();
    await prefs.reset();
    await config.reload();
    expect(config.hasCustomKey, isFalse);
    expect(config.apiKey, 'ENV_KEY');
    expect(config.poraModel, 'ENV_CHAT');
  });
}
