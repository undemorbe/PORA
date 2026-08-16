import 'package:flutter/material.dart';

/// Хелпер вокруг `MediaQuery.disableAnimationsOf(context)` для явной проверки
/// в build'ах виджетов. Пользователи с включённой iOS/Android опцией
/// «Reduce Motion» получают статику вместо циклических пульсов/шейков.
class MotionGate {
  const MotionGate._();

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
