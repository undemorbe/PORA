import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:pora/app/internal/links/uri_launcher.dart';
part 'privacy_store.g.dart';

class PrivacyStore = _PrivacyStoreBase with _$PrivacyStore;

abstract class _PrivacyStoreBase with Store {
  @action
  Future<void> openPrivacy() async {
    final privacyUri = dotenv.get('PRIVACY_POLICY_URL');
    await GetIt.I.get<IUriLauncher>().launchUri(uri: privacyUri);
  }
}
