import 'package:share_plus/share_plus.dart';

abstract class SharingRepository {
  Future<void> shareUri({required String uri});
  Future<void> shareText({required String text});
}

class SharingRepositoryImpl implements SharingRepository {
  final SharePlus _sharePlus = SharePlus.instance;

  @override
  Future<void> shareText({required String text}) async {
    await _sharePlus.share(ShareParams(text: text));
  }

  @override
  Future<void> shareUri({required String uri}) async {
    final params = ShareParams(uri: Uri.parse(uri));
    await _sharePlus.share(params);
  }
}
