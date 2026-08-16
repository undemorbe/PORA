import 'package:talker_flutter/talker_flutter.dart';

abstract class Logger {
  static final logger = TalkerLogger();
  static final talker = TalkerFlutter.init(logger: logger);
}
